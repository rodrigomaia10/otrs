# --
# Kernel/Modules/NewTicketService.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * Jguedes@serviceup.com.br
# * ccresencio@serviceup.com.br
# * gbolsoni@serviceup.com.br
# --

package Kernel::Modules::NewTicketService;

use strict;
use warnings;

use utf8;

use Encode qw(decode encode);
use File::Basename;
use Digest::MD5 qw(md5_hex);

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get form id
    $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FormID' );

    # create form id
    if ( !$Self->{FormID} ) {
        $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::UploadCache')->FormIDCreate();
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $QueueObject   = $Kernel::OM->Get('Kernel::System::Queue');
    my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $Config        = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::CustomerTicketMessage");
    my $FormLocation  = $ConfigObject->Get("CustomerPortal::Core::CustomServiceFormLocation");

    my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    # get params
    my %GetParam;

    for my $Key (qw( Subject Body PriorityID TypeID ServiceID SLAID Expand Dest DataES TicketNumber CustomerID ContractID )) {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }
    
    $GetParam{FormID} = $Self->{FormID};

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "Services",
        %{$Self}
    );

    # ACL compatibility translation
    my %ACLCompatGetParam;
    $ACLCompatGetParam{OwnerID} = $GetParam{NewUserID};

    # get Dynamic fields from ParamObject
    my %DynamicFieldValues;

    # get the dynamic fields for this screen
    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $Config->{DynamicField} || {},
    );

    my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # reduce the dynamic fields to only the ones that are designed for customer interface
    my @CustomerDynamicFields;
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

        my $IsCustomerInterfaceCapable = $BackendObject->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsCustomerInterfaceCapable',
        );
        next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

        push @CustomerDynamicFields, $DynamicFieldConfig;
    }

    $DynamicField = \@CustomerDynamicFields;

    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
    my $CustomFormObject;
    my @DynamicFieldsCSForm;

    if ( $MainObject->Require( 'Kernel::System::CustomServiceForm', Silent => 1 ) ) {
        
        $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

        my $EnableCustomServiceForm = $ConfigObject->Get("CustomerPortal::Core::ToEnableCustomServiceForm");

        if ($EnableCustomServiceForm && $GetParam{ServiceID} && $Kernel::OM->Get('Kernel::System::CustomServiceForm')){

            my $FormSearch = $CustomFormObject->CustomFormSearch(
                ServiceID   => $GetParam{ServiceID},
            );
            
            if($FormSearch){
                my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
                    FormID => $FormSearch,
                );

                my $List = $DynamicFieldObject->DynamicFieldListGet();

                for my $CurrentField ( @{ $Fields } ) {
                    my ($DF, $Name) = split /DynamicField_/, $CurrentField->{Name};

                    for my $Listed ( @{ $List } ){
                        if( $Name eq $Listed->{Name} ){                         
                            push @DynamicFieldsCSForm, $Listed;
                        }
                    }

                }
            }

        }

    }


    my @FilterDF = ( @DynamicFieldsCSForm, @{$DynamicField} );

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @FilterDF  ) {
        next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

        if ( $DynamicFieldConfig->{FieldType} eq 'FileSystem' ) {

            $DynamicFieldValues{ $DynamicFieldConfig->{Name} } = 1;
        }
        else {

            # extract the dynamic field value from the web request
            $DynamicFieldValues{ $DynamicFieldConfig->{Name} } =
                $BackendObject->EditFieldValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ParamObject        => $ParamObject,
                LayoutObject       => $LayoutObject,
            );
        }
    }

    # convert dynamic field values into a structure for ACLs
    my %DynamicFieldACLParameters;
    DYNAMICFIELD:
    for my $DynamicField ( sort keys %DynamicFieldValues ) {
        next DYNAMICFIELD if !$DynamicField;
        next DYNAMICFIELD if !$DynamicFieldValues{$DynamicField};

        $DynamicFieldACLParameters{ 'DynamicField_' . $DynamicField } = $DynamicFieldValues{$DynamicField};
    }

    if ( $Self->{Subaction} eq 'StoreNew' ) {

        my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');
        my $ArticleObject  = $Kernel::OM->Get('Kernel::System::Ticket::Article');
        my $TypeObject     = $Kernel::OM->Get('Kernel::System::Type');
        my $SLAObject      = $Kernel::OM->Get('Kernel::System::SLA');

        my $ArticleBackendObject = $ArticleObject->BackendForChannel( ChannelName => 'Internal' );

        my $NextScreen = 'Services';
        my %Error;
        my %ErrorLabel;

        my $QueueNameConfig = $ConfigObject->Get('CustomerPortal::NewTicket::QueueName');
        my $NewQueueID      = $QueueObject->QueueLookup( Queue => $QueueNameConfig );

        my $SLAIDConfig = $ConfigObject->Get('CustomerPortal::NewTicket::SLAID');

        my $UploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

        # get all attachments meta data
        my @Attachments = $UploadCacheObject->FormIDGetAllFilesMeta(
            FormID => $Self->{FormID},
        );

        # create html strings for all dynamic fields
        my %DynamicFieldHTML;

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

            my $PossibleValuesFilter;

            my $IsACLReducible = $BackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );

            if ($IsACLReducible) {

                # get PossibleValues
                my $PossibleValues = $BackendObject->PossibleValuesGet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                );

                # check if field has PossibleValues property in its configuration
                if ( IsHashRefWithData(\%{$PossibleValues}) ) {

                    # convert possible values key => value to key => key for ACLs using a Hash slice
                    my %AclData = %{$PossibleValues};
                    @AclData{ keys %AclData } = keys %AclData;

                    # set possible values filter from ACLs
                    my $ACL = $TicketObject->TicketAcl(
                        %GetParam,
                        Action         => $Self->{Action},
                        TicketID       => $Self->{TicketID},
                        ReturnType     => 'Ticket',
                        ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                        Data           => \%AclData,
                        CustomerUserID => $Self->{UserID},
                    );
                    if ($ACL) {
                        my %Filter = $TicketObject->TicketAclData();

                        # convert Filer key => key back to key => value using map
                        %{$PossibleValuesFilter} = map { $_ => $PossibleValues->{$_} }
                            keys %Filter;
                    }
                }
            }

            my $ValidationResult;

            # do not validate on attachment upload or GetParam Expand
            if ( !$GetParam{Expand} ) {

                $ValidationResult = $BackendObject->EditFieldValueValidate(
                    DynamicFieldConfig   => $DynamicFieldConfig,
                    PossibleValuesFilter => $PossibleValuesFilter,
                    ParamObject          => $ParamObject,
                    Mandatory            =>
                        $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                );

                if ( !IsHashRefWithData(\%{$ValidationResult}) ) {
                    my $Output = $LayoutObject->CustomerHeader( Title => 'Error' );
                    $Output .= $LayoutObject->CustomerError(
                        Message =>
                            $LayoutObject->{LanguageObject}
                            ->Translate( 'Could not perform validation on field %s!', $DynamicFieldConfig->{Label} ),
                        Comment => Translatable('Please contact the administrator.'),
                    );
                    $Output .= $LayoutObject->CustomerFooter();
                    return $Output;
                }

                # propagate validation error to the Error variable to be detected by the frontend
                if ( $ValidationResult->{ServerError} ) {
                    $Error{ $DynamicFieldConfig->{Name} } = ' ServerError';
                    $ErrorLabel{ $DynamicFieldConfig->{Name} } = 'Error validating dynamic field.';
                }
            }

            # get field html
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } = $BackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                Mandatory            => $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                ServerError          => $ValidationResult->{ServerError}  || '',
                ErrorMessage         => $ValidationResult->{ErrorMessage} || '',
                LayoutObject         => $LayoutObject,
                ParamObject          => $ParamObject,
                AJAXUpdate           => 1,
                UpdatableFields      => $Self->_GetFieldsToUpdate(),
            );

        }

        # rewrap body if no rich text is used
        if ( $GetParam{Body} && !$LayoutObject->{BrowserRichText} ) {

            $GetParam{Body} = $LayoutObject->WrapPlainText(
                MaxCharacters => $ConfigObject->Get('Ticket::Frontend::TextAreaNote'),
                PlainText     => $GetParam{Body},
            );
        }


        # check queue
        if ( !$NewQueueID && !$GetParam{Expand} ) {
            $Error{QueueInvalid} = 'ServerError';
            $ErrorLabel{ QueueInvalid } = 'Please, check that the queue has been configured correctly.';
        }

        # prevent tamper with (Queue/Dest), see bug#9408
        if ($NewQueueID) {

            # get the original list of queues to display
            my $Tos = $Self->_GetTos(
                %GetParam,
                %ACLCompatGetParam,
                QueueID => $NewQueueID,
            );

            # check if current selected QueueID exists in the list of queues,\
            # otherwise rise an error
            if ( !$Tos->{$NewQueueID} ) {
                $Error{QueueInvalid} = 'ServerError';
                $ErrorLabel{ QueueInvalid } = 'Please, check if current selected QueueID exists in the list of queues.';
            }
        }

        # check subject
        if ( !$GetParam{Subject} ) { 
            $Error{SubjectInvalid} = 'ServerError';
            $ErrorLabel{ SubjectInvalid } = 'Please, check the subject provided.';
        }

        # check body
        if ( !$GetParam{Body} ) {
            $Error{BodyInvalid} = 'ServerError';
            $ErrorLabel{ BodyInvalid } = 'Please, check the body provided.';
        }

        if ( $GetParam{Expand} ) {
            %Error = ();
            $Error{Expand} = 1;
        }
        

        # check mandatory service
        if (
            $ConfigObject->Get('Ticket::Service')
            && $Config->{Service}
            && $Config->{ServiceMandatory}
            && !$GetParam{ServiceID}
            )
        {
            $Error{'ServiceIDInvalid'} = 'ServerError';
            $ErrorLabel{ ServiceIDInvalid } = 'Please, report a valid service to continue.';
        }

        my %ServiceData = $ServiceObject->ServiceGet(
            ServiceID => $GetParam{ServiceID},
            UserID    => 1,
        );

        if (%Error) {

			$GetParam{Title}       = 'New Ticket';
			$GetParam{Active}      = 'Services';
			$GetParam{ServiceID}   = $ParamObject->GetParam( Param => 'ServiceID' );
			$GetParam{ServiceName} = $ServiceData{Name};

			$LayoutObject->Block(
				Name => 'NewTicketService',
				Data => \%GetParam
			);

            for my $ErrorToShow ( keys %ErrorLabel ){

                $LayoutObject->Block(
                    Name => 'Errors',
                    Data => {
                        Message => $LayoutObject->{LanguageObject}->Translate( $ErrorLabel{$ErrorToShow} )
                    }
                );
            }
            
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService});

            $Output .= $Self->_MaskNew(
				TemplateFile     => 'NewTicketService',
                Attachments      => \@Attachments,
                %GetParam,
                ToSelected       => $NewQueueID,
                QueueID          => $NewQueueID,
                DynamicFieldHTML => \%DynamicFieldHTML,
                Errors           => \%Error,
                FormID           => $Self->{FormID}
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck( Type => 'Customer' );

        # if customer is not allowed to set priority, set it to default
        if ( !$Config->{Priority} ) {

            my $PriorityID = $PriorityObject->PriorityLookup(
                Priority => $Config->{PriorityDefault},
            );

            if($ServiceData{ServiceTicketPriority}){
                $GetParam{PriorityID} = $PriorityObject->PriorityLookup( Priority => $ServiceData{ServiceTicketPriority} );
                $GetParam{Priority}   = $ServiceData{ServiceTicketPriority};
            }
            else{
                $GetParam{PriorityID} = $PriorityID;
                $GetParam{Priority}   = $Config->{PriorityDefault};
            }
        }
        else{
            if($ServiceData{ServiceTicketPriority}){
                $GetParam{PriorityID} = $PriorityObject->PriorityLookup( Priority => $ServiceData{ServiceTicketPriority} );
            }
        }

        # Get Queue of service preference to ticket
        if($ServiceData{ServiceTicketQueue} ){
            $NewQueueID = $QueueObject->QueueLookup( Queue => $ServiceData{ServiceTicketQueue} );
        }

        # Get Type of service preference to ticket
        if($ServiceData{ServiceTicketType}){
            $GetParam{TypeID} = $TypeObject->TypeLookup( Type => $ServiceData{ServiceTicketType} );
        }
        else{
            if( $Config->{TicketType} && !$GetParam{TypeID} ){
                $GetParam{TypeID} = $TypeObject->TypeLookup( Type => $Config->{TicketTypeDefault} );
            }
        }

        # Get SLA of service preference to ticket
        if($ServiceData{ServiceTicketSLA}){
            $SLAIDConfig = $SLAObject->SLALookup(Name => $ServiceData{ServiceTicketSLA});
        }

        my $OwnerID = $ConfigObject->Get('CustomerPanelUserID');

        # Get Owner of service preference to ticket
        if($ServiceData{ServiceTicketOwner} ){
            $OwnerID = $ServiceData{ServiceTicketOwner};
        }

        my $CustomerID =  $Self->{UserCustomerID};
        if ( $GetParam{CustomerID} ){
            $CustomerID =  $GetParam{CustomerID};
        }       

        my $SetContract = $ConfigObject->Get('CustomerPortal::Core::ContractWithRelationServiceContractEnable');

        my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

        my $DynamicFieldContract = $DynamicFieldObject->DynamicFieldGet(
            Name => 'CustomerContract',
        );

        if($SetContract == 1){

            my $ContractObject = $Kernel::OM->Get('Kernel::System::ContractManagement');

            my %List = $ContractObject->ContractCompany(
                CustomerID => $Self->{CustomerID},
                Valid      => 1,
            );

            for my $Index (keys %List){
                $GetParam{ContractID} = $Index;
            }

        }

        # create new ticket, do db insert
        my $TicketID = $TicketObject->TicketCreate(
            QueueID      => $NewQueueID,
            TypeID       => $GetParam{TypeID},
            ServiceID    => $GetParam{ServiceID},
            SLAID        => $GetParam{SLAID}|| $SLAIDConfig,
            Title        => $GetParam{Subject},
            PriorityID   => $GetParam{PriorityID},
            Priority     => $GetParam{Priority},
            Lock         => 'unlock',
            State        => $Config->{StateDefault},
            CustomerID   => $CustomerID,
            CustomerUser => $Self->{UserLogin},
            OwnerID      => $OwnerID,
            UserID       => $ConfigObject->Get('CustomerPanelUserID'),
        );

        if ( !$TicketID ) {

            $GetParam{Title}       = 'New Ticket';
			$GetParam{Active}      = 'Services';
			$GetParam{ServiceID}   = $ParamObject->GetParam( Param => 'ServiceID' );
			$GetParam{ServiceName} = $ServiceData{Name};

			$LayoutObject->Block(
				Name => 'NewTicketService',
				Data => \%GetParam
			);

            $LayoutObject->Block(
                Name => 'Errors',
                Data => {
                    Message => $LayoutObject->{LanguageObject}->Translate('Error creating ticket! Contact your system administrator.')
                }
            );
            
            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService});

            $Output .= $Self->_MaskNew(
				TemplateFile     => 'NewTicketService',
                Attachments      => \@Attachments,
                %GetParam,
                ToSelected       => $NewQueueID,
                QueueID          => $NewQueueID,
                DynamicFieldHTML => \%DynamicFieldHTML,
                Errors           => \%Error,
                FormID           => $Self->{FormID}
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }
        
        if($SetContract == 1){
            my $Success = $BackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldContract,
                ObjectID           => $TicketID,
                Value              => $GetParam{ContractID}, 
                UserID             => 1,
            );
        }

        if($ServiceData{ServiceTicketResponsible} ){

            my $Success = $TicketObject->TicketResponsibleSet(
                TicketID  => $TicketID,
                NewUserID => $ServiceData{ServiceTicketResponsible},
                UserID    => 1,
            );
        }

        for (my $i=1; $i <= 9; $i++) {

            my $ConfigNumber = "0".$i;

            my $ServiceDynamicField = "ServiceDynamicField".$ConfigNumber;
        
            if($ServiceData{ $ServiceDynamicField } ){

                my $PrefConfigDFName = $ConfigObject->Get('ServicePreferences')->{$ServiceDynamicField}{DFName};

                my $SelectedDynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $PrefConfigDFName,
                );

                my $ValueToSet = $ServiceData{ $ServiceDynamicField };
                
                if($SelectedDynamicField->{FieldType} eq 'Multiselect'){

                    my @ValuesMulti = split /;/, $ServiceData{ $ServiceDynamicField };

                    $ValueToSet = \@ValuesMulti;
                }
                elsif($SelectedDynamicField->{FieldType} eq 'Date'){

                    my @ValuesDate = split /;/, $ServiceData{ $ServiceDynamicField };

                    if($ValuesDate[2] < 10){
                        $ValuesDate[2] = "0$ValuesDate[2]";
                    }

                    if($ValuesDate[1] < 10){
                        $ValuesDate[1] = "0$ValuesDate[1]";
                    }

                    $ValueToSet = "$ValuesDate[3]-$ValuesDate[2]-$ValuesDate[1] 00:00:00";
                }
                elsif($SelectedDynamicField->{FieldType} eq 'DateTime'){

                    my @ValuesDateTime = split /;/, $ServiceData{ $ServiceDynamicField };

                    if($ValuesDateTime[2] < 10){
                        $ValuesDateTime[2] = "0$ValuesDateTime[2]";
                    }

                    if($ValuesDateTime[1] < 10){
                        $ValuesDateTime[1] = "0$ValuesDateTime[1]";
                    }

                    if($ValuesDateTime[4] < 10){
                        $ValuesDateTime[4] = "0$ValuesDateTime[4]";
                    }

                    if($ValuesDateTime[5] < 10){
                        $ValuesDateTime[5] = "0$ValuesDateTime[5]";
                    }

                    $ValueToSet = "$ValuesDateTime[3]-$ValuesDateTime[2]-$ValuesDateTime[1] $ValuesDateTime[4]:$ValuesDateTime[5]:00";
                }

                # set the value to service dynamic field
                my $Success = $BackendObject->ValueSet(
                    DynamicFieldConfig => $SelectedDynamicField,
                    ObjectID           => $TicketID,
                    Value              => $ValueToSet,
                    UserID             => $ConfigObject->Get('CustomerPanelUserID'),
                );
            }
        }

        # set ticket dynamic fields
        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {

            next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});
            next DYNAMICFIELD if $DynamicFieldConfig->{ObjectType} ne 'Ticket';

            # set the value
            my $Success = $BackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $TicketID,
                Value              => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                UserID             => $ConfigObject->Get('CustomerPanelUserID'),
            );
        }

        my $OpenTicketByContract = $ConfigObject->Get('CustomerPortal::Core::OpenTicketByContract');

        # get field contract
        my $DynamicFieldContract = $DynamicFieldObject->DynamicFieldGet(
            Name => 'CustomerContract',
        );

        if ( $OpenTicketByContract && IsHashRefWithData($DynamicFieldContract) && $GetParam{ContractID} ) {

            # set the value
            my $Success = $BackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldContract,
                ObjectID           => $TicketID,
                Value              => $GetParam{ContractID},
                UserID             => $ConfigObject->Get('CustomerPanelUserID'),
            );
        }

        if ( $ConfigObject->Get('CustomerPortal::Core::ShowDynamicFieldImpactOperation') ) {

            # get field contract
            my $DynamicFieldImpactOperation = $DynamicFieldObject->DynamicFieldGet(
                Name => 'ImpactOperation',
            );

            # extract the dynamic field value from the web request
            my $ImpactOperation = $BackendObject->EditFieldValueGet(
                DynamicFieldConfig => $DynamicFieldImpactOperation,
                ParamObject        => $ParamObject,
                LayoutObject       => $LayoutObject,
            );

            # set the value
            my $Success = $BackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldImpactOperation,
                ObjectID           => $TicketID,
                Value              => $ImpactOperation,
                UserID             => $ConfigObject->Get('CustomerPanelUserID'),
            );
            
        }

        my $MimeType = 'text/plain';

        if ( $LayoutObject->{BrowserRichText} ) {
            $MimeType = 'text/html';

            # verify html document
            $GetParam{Body} = $LayoutObject->RichTextDocumentComplete(
                String => $GetParam{Body},
            );
        }

        my $PlainBody = $GetParam{Body};

        if ( $LayoutObject->{BrowserRichText} ) {
            $PlainBody = $LayoutObject->RichText2Ascii( String => $GetParam{Body} );
        }

        # create article
        my $FullName = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerName(
            UserLogin => $Self->{UserLogin},
        );

        my $From = "\"$FullName\" <$Self->{UserEmail}>";

        my $ArticleID = $ArticleBackendObject->ArticleCreate(
            TicketID             => $TicketID,
            IsVisibleForCustomer => 1,
            SenderType           => $Config->{SenderType},
            From                 => $From,
            Subject              => $GetParam{Subject},
            Body                 => $GetParam{Body},
            MimeType             => $MimeType,
            Charset              => $LayoutObject->{UserCharset},
            UserID               => $ConfigObject->Get('CustomerPanelUserID'),
            HistoryType          => $Config->{HistoryType},
            HistoryComment       => $Config->{HistoryComment} || '%%',
            AutoResponseType     => ( $ConfigObject->Get('AutoResponseForWebTickets') ) ? 'auto reply' : '',
            OrigHeader => {
                From    => $From,
                To      => $Self->{UserLogin},
                Subject => $GetParam{Subject},
                Body    => $PlainBody,
            },
            Queue => $QueueObject->QueueLookup( QueueID => $NewQueueID ),
        );

        if ( !$ArticleID ) {

            my $Output = $LayoutObject->CustomerHeader( Title => 'Error' );
            $Output .= $LayoutObject->CustomerError();
            $Output .= $LayoutObject->CustomerFooter();

            return $Output;
        }

        # set article dynamic fields
        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});
            next DYNAMICFIELD if $DynamicFieldConfig->{ObjectType} ne 'Article';

            # set the value
            my $Success = $BackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $ArticleID,
                Value              => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                UserID             => $ConfigObject->Get('CustomerPanelUserID'),
            );
        }

        # get pre loaded attachment
        my @AttachmentData = $UploadCacheObject->FormIDGetAllFilesData(
            FormID => $Self->{FormID},
        );

        # get submitted attachment
        my %UploadStuff = $ParamObject->GetUploadAll(
            Param => 'FileUpload',
        );

        if (%UploadStuff) {
            push @AttachmentData, \%UploadStuff;
        }

        $MimeType = 'text/plain';

        if ( $LayoutObject->{BrowserRichText} ) {

            $MimeType = 'text/html';

            # remove unused inline images
            my @NewAttachmentData;
            ATTACHMENT:
            for my $Attachment (@AttachmentData) {

                my $ContentID = $Attachment->{ContentID};

                if (
                    $ContentID
                    && ( $Attachment->{ContentType} =~ /image/i )
                    && ( $Attachment->{Disposition} eq 'inline' )
                    )
                {
                    my $ContentIDHTMLQuote = $LayoutObject->Ascii2Html(
                        Text => $ContentID,
                    );

                    # workaround for link encode of rich text editor, see bug#5053
                    my $ContentIDLinkEncode = $LayoutObject->LinkEncode($ContentID);
                    $GetParam{Body} =~ s/(ContentID=)$ContentIDLinkEncode/$1$ContentID/g;

                    # ignore attachment if not linked in body
                    next ATTACHMENT if $GetParam{Body} !~ /(\Q$ContentIDHTMLQuote\E|\Q$ContentID\E)/i;
                }

                # remember inline images and normal attachments
                push @NewAttachmentData, \%{$Attachment};
            }

            @AttachmentData = @NewAttachmentData;

            # verify html document
            $GetParam{Body} = $LayoutObject->RichTextDocumentComplete(
                String => $GetParam{Body},
            );
        }

        # write attachments
        for my $Attachment (@AttachmentData) {

            $ArticleBackendObject->ArticleWriteAttachment(
                %{$Attachment},
                TicketID  => $TicketID,
                ArticleID => $ArticleID,
                UserID    => 1,
            );
        }

        # remove pre submitted attachments
        $UploadCacheObject->FormIDRemove( FormID => $Self->{FormID} );

        my $TicketNumber = $TicketObject->TicketNumberLookup(
            TicketID => $TicketID,
        );

        # redirect
        return $LayoutObject->Redirect(
            OP => "Action=CustomerPortalTicketZoom;TicketNumber=".$TicketNumber,
        );
    }
    # ------------------------------------------------------------ #
    # AJAXUpdate
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AJAXUpdate' ) {
        
        my @ParamNames = $ParamObject->GetParamNames();

        my %DynamicFieldParams;
        #Get DynamicField params
        foreach my $Param ( @ParamNames ){

            if( $Param =~ 'DynamicField_' ){
                $DynamicFieldParams{$Param} = $ParamObject->GetParam( Param => $Param );
            }
        }

        $GetParam{DynamicField} = \%DynamicFieldParams;

        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');
        my $CustomFormObject;
        my @DynamicFieldsCSForm;

        if ( $MainObject->Require( 'Kernel::System::CustomServiceForm', Silent => 1 ) ) {
            $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

            my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

            my $FormSearch = $CustomFormObject->CustomFormSearch(
                ServiceID   => $GetParam{ServiceID},
            );
            
            if($FormSearch){
                my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
                    FormID => $FormSearch,
                );

                my $List = $DynamicFieldObject->DynamicFieldListGet();

                for my $CurrentField ( @{ $Fields } ) {
                    my ($DF, $Name) = split /DynamicField_/, $CurrentField->{Name};

                    for my $Listed ( @{ $List } ){
                        if( $Name eq $Listed->{Name} ){                         
                            push @DynamicFieldsCSForm, $Listed;
                        }
                    }

                }

            }
        }

        my $Dest = $ParamObject->GetParam( Param => 'Dest' ) || '';

        my $CustomerUser = $Self->{UserID};

        my $QueueID = '';

        if ( $Dest =~ /^(\d{1,100})\|\|.+?$/ ) {
            $QueueID = $1;
        }

        # get list type
        my $TreeView = 0;

        if ( $ConfigObject->Get('Ticket::Frontend::ListType') eq 'tree' ) {
            $TreeView = 1;
        }
        

        my $Tos = $Self->_GetTos(
            %GetParam,
            %ACLCompatGetParam,
            QueueID => $QueueID,
        );
        

        my $NewTos;

        if ($Tos) {

            TOs:
            for my $KeyTo ( sort keys %{$Tos} ) {

                next TOs if ( $Tos->{$KeyTo} eq '-' );

                $NewTos->{"$KeyTo||$Tos->{$KeyTo}"} = $Tos->{$KeyTo};
            }
        }

        my $Priorities = $Self->_GetPriorities(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,
        );

        my $FieldTypePriority = $ConfigObject->Get('CustomerPortal::Core::FieldTypePriority');

        if ( $FieldTypePriority ) {
            $Priorities->{''} = '';
        }

        my $Services = $Self->_GetServices(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,
        );

        my $SLAs = $Self->_GetSLAs(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,
            Services       => $Services,
        );

        my $Types = $Self->_GetTypes(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,
        );

        # update Dynamic Fields Possible Values via AJAX
        my @DynamicFieldAJAX;

        my @DynamicFieldsFilter = ( @{$DynamicField}, @DynamicFieldsCSForm );

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @DynamicFieldsFilter  ) {
            next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

            my $IsACLReducible = $BackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );
            next DYNAMICFIELD if !$IsACLReducible;

            my $PossibleValues = $BackendObject->PossibleValuesGet(
                DynamicFieldConfig => $DynamicFieldConfig,
            );
            # convert possible values key => value to key => key for ACLs using a Hash slice
            my %AclData = %{$PossibleValues};
            @AclData{ keys %AclData } = keys %AclData;

            # set possible values filter from ACLs
            my $ACL = $TicketObject->TicketAcl(
                %GetParam,
                %ACLCompatGetParam,
                Action         => $Self->{Action},
                QueueID        => $QueueID || 0,
                ReturnType     => 'Ticket',
                ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                Data           => \%AclData,
                CustomerUserID => $Self->{UserID},
            );
            
            if ($ACL) {
                my %Filter = $TicketObject->TicketAclData();

                # convert Filer key => key back to key => value using map
                %{$PossibleValues} = map { $_ => $PossibleValues->{$_} } keys %Filter;
            }

            my $DataValues = $BackendObject->BuildSelectionDataGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                PossibleValues     => $PossibleValues,
                Value              => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
            ) || $PossibleValues;

            
            
            
            # add dynamic field to the list of fields to update
            push(
                @DynamicFieldAJAX,
                {
                    Name        => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data        => $DataValues,
                    SelectedID  => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                    Translation => $DynamicFieldConfig->{Config}->{TranslatableValues} || 0,
                    Max         => 100,
                }
            );
        }

        my $JSON = $LayoutObject->BuildSelectionJSON(
            [
                {
                    Name         => 'Dest',
                    Data         => $NewTos,
                    SelectedID   => $Dest,
                    Translation  => 0,
                    PossibleNone => 0,
                    TreeView     => $TreeView,
                    Max          => 100,
                },
                {
                    Name         => 'PriorityID',
                    Data         => $Priorities,
                    SelectedID   => $GetParam{PriorityID},
                    Translation  => 1,
                    Max          => 100,
                },
                {
                    Name         => 'SLAID',
                    Data         => $SLAs,
                    SelectedID   => $GetParam{SLAID},
                    PossibleNone => 1,
                    Translation  => 0,
                    Max          => 100,
                },
                {
                    Name         => 'TypeID',
                    Data         => $Types,
                    SelectedID   => $GetParam{TypeID},
                    PossibleNone => 1,
                    Translation  => 0,
                    Max          => 100,
                },
                @DynamicFieldAJAX,
            ],
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    else{
      
        $GetParam{DynamicField} = \%DynamicFieldACLParameters;

        $GetParam{Title}  = 'New Ticket';
        $GetParam{Active} = 'Services';

        $GetParam{ServiceID} = $ParamObject->GetParam( Param => 'ServiceID' );

        # $GetParam{DisableAttribute} = "disabled";

        # return all Services in relation with CustomerUser.
        my @CustomerServicesAllowed = $ServiceObject->CustomerUserServiceMemberList(
            Result            => 'ARRAY',
            CustomerUserLogin => $Self->{UserID},
            UserID            => 1,
        );

        if ( !($GetParam{ServiceID} ~~ @CustomerServicesAllowed ) ) {
            
            $GetParam{Message} = $LayoutObject->{LanguageObject}->Translate("This service is not available to the logged in user.");
            $GetParam{Comment} = $LayoutObject->{LanguageObject}->Translate("You are not allowed to access this service. Please contact the responsible team for more information.");

            $LayoutObject->Block(
                Name => 'Error',
                Data => \%GetParam,
            );

            my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService});

            $Output .= $LayoutObject->Output(
                TemplateFile => "NewTicketService",
                Data         => \%GetParam,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }


        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

        my $OpenTicketByContract = $ConfigObject->Get('CustomerPortal::Core::OpenTicketByContract');

        # get field contract
        my $DynamicFieldContract = $DynamicFieldObject->DynamicFieldGet(
            Name => 'CustomerContract',
        );

        if ( $OpenTicketByContract && IsHashRefWithData($DynamicFieldContract) ) {

            if ( $GetParam{ContractID} eq undef) {

                $GetParam{Message} = $LayoutObject->{LanguageObject}->Translate("Contract not selected.");
                $GetParam{Comment} = $LayoutObject->{LanguageObject}->Translate("Call opening without a contract is not available. Please contact the responsible team for more information.");

                $LayoutObject->Block(
                    Name => 'Error',
                    Data => \%GetParam,
                );

                my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService});

                $Output .= $LayoutObject->Output(
                    TemplateFile => "NewTicketService",
                    Data         => \%GetParam,
                );

                $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

                return $Output;
            }

            my $ContractAndServicesObject = $Kernel::OM->Get('Kernel::System::ContractAndServices');
            my $ContractObject            = $Kernel::OM->Get('Kernel::System::ContractManagement');

            my %Data = $ContractObject->GetPermissionServiceContractUserClient(
                CustomerUser => $Self->{UserID},
                CustomerID   => $Self->{UserCustomerID},
                ServiceID    => $GetParam{ServiceID},
            );

            if ( !$Data{$GetParam{ContractID}} ) {

                $GetParam{Message} = $LayoutObject->{LanguageObject}->Translate("This contract is not available to the logged in user.");
                $GetParam{Comment} = $LayoutObject->{LanguageObject}->Translate("This contract is not associated with the service informed in the URL. Please contact the responsible team for more information.");

                $LayoutObject->Block(
                    Name => 'Error',
                    Data => \%GetParam,
                );

                my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService});

                $Output .= $LayoutObject->Output(
                    TemplateFile => "NewTicketService",
                    Data         => \%GetParam,
                );

                $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

                return $Output;
                
            }

            # return all Services in relation with CustomerUser.
            my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
                Result            => 'HASH',
                CustomerUserLogin => $Self->{UserID},
                UserID            => 1,
            );

            # return all services in relation with contract
            my @ServiceData2 = $ContractAndServicesObject->ContractAndServicesList(
                ContractID => $GetParam{ContractID},
                UserID     => $Self->{UserID}
            );      

            # filter Services based on relation with CustomerUser and KeepChildren config.
            my %ServiceList;
            my @ServicesArray;

            for my $FilterServiceID ( @ServiceData2 ) {

                if($CustomerServices{$FilterServiceID}){
                    $ServiceList{$FilterServiceID} = $CustomerServices{$FilterServiceID};
                    push @ServicesArray, $FilterServiceID;
                }
            }       

            for my $ServiceID ( keys %ServiceList ) {

                my %ServiceData = $ServiceObject->ServiceGet(
                    ServiceID      => $ServiceID,
                    CustomerUserID => $Self->{UserID} || '',
                    UserID         => 1,
                );

                # get parentent list
                my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
                    ServiceID      => $ServiceData{ServiceID},
                    CustomerUserID => $Self->{UserID} || '',
                    UserID         => 1,
                );

                for my $Key ( @{$ServiceParentsList} ) {

                    @ServicesArray = grep {$_ ne $Key} @ServicesArray;
                }
            }

            my $TotalServices = scalar @ServicesArray;

            if ( !($GetParam{ServiceID} ~~ @ServicesArray ) ) {

                $GetParam{Message} = $LayoutObject->{LanguageObject}->Translate("This service is not available for that contract.");
                $GetParam{Comment} = $LayoutObject->{LanguageObject}->Translate("You are not allowed to access this Contract-Service association. Please contact the responsible team for more information.");

                $LayoutObject->Block(
                    Name => 'Error',
                    Data => \%GetParam,
                );

                my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService});

                $Output .= $LayoutObject->Output(
                    TemplateFile => "NewTicketService",
                    Data         => \%GetParam,
                );

                $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

                return $Output;
            }
        }

        my %ServiceData = $ServiceObject->ServiceGet(
            ServiceID => $GetParam{ServiceID},
            UserID    => 1,
        );

        $GetParam{ServiceName} = $ServiceData{Name};
        $GetParam{ServiceName} =~ s|::| -> |g;
        $GetParam{FormID}      = $Self->{FormID};

        
        my $ServiceOpeningWaitTimeConfig = $ConfigObject->Get('ServicePreferences')->{ServiceOpeningWaitTime};
        if( $ServiceOpeningWaitTimeConfig && $ServiceData{ServiceOpeningWaitTime} ) {

            # Search last ticket created in selected service by current user
            my @LastServiceTicketIDs = $TicketObject->TicketSearch(
                Result => 'ARRAY',

                CustomerUserID => $Self->{UserID},
                Limit => 1,
                ServiceIDs => [$GetParam{ServiceID}],
                OrderBy => 'Down',  
                SortBy  => 'TicketNumber',
            );

            if( @LastServiceTicketIDs ) {

                # Get ticket information
                my $LastServiceTicketID = $LastServiceTicketIDs[0];
                my %LastServiceTicket   = $TicketObject->TicketGet(
                    TicketID => $LastServiceTicketID
                );

                # Define create time from ticket
                my $DateTimeNowObject = $Kernel::OM->Create('Kernel::System::DateTime');
                my $DateTimeFromTicketObject = $Kernel::OM->Create(
                    'Kernel::System::DateTime',
                    ObjectParams => {
                        String   => $LastServiceTicket{Created},
                    }
                );
                $DateTimeFromTicketObject->Add(
                    Days => $ServiceData{ServiceOpeningWaitTime}
                );

                my $IsGreater = $DateTimeFromTicketObject->Compare( DateTimeObject => $DateTimeNowObject);
                if( $IsGreater > 0 ) {
                    $GetParam{ErrorTitle} = $LayoutObject->{LanguageObject}->Translate("You can't open a new ticket in this service yet.");
                    $GetParam{Message} = $LayoutObject->{LanguageObject}->Translate("Plase, wait until %s.", $DateTimeFromTicketObject->Format( Format => '%Hh%M de %d/%m/%Y' ));

                    my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService});

                    $LayoutObject->Block(
                        Name => 'Error',
                        Data => \%GetParam,
                    );

                    $Output .= $LayoutObject->Output(
                        TemplateFile => "NewTicketService",
                        Data         => \%GetParam,
                    );

                    $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

                    return $Output;
                }
            }
        }  

        # Create HTML to NavBar 
        my $HTML;

        my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
            ServiceID => $ServiceData{ServiceID},
            UserID    => 1,
        );

        #Get default Queue ID if none is set
        my $QueueDefaultID;


        if ( !$GetParam{Dest} && !$Param{ToSelected} ) {

            my $QueueDefault = $Config->{'QueueDefault'} || '';

            if ($QueueDefault) {

                $QueueDefaultID = $QueueObject->QueueLookup( Queue => $QueueDefault );

                if ($QueueDefaultID) {
                    $Param{ToSelected} = $QueueDefaultID . '||' . $QueueDefault;
                }
 
                $ACLCompatGetParam{QueueID} = $QueueDefaultID;
            }

            # warn if there is no (valid) default queue and the customer can't select one
            elsif ( !$Config->{'Queue'} ) {

                $LayoutObject->CustomerFatalError(
                    Message => $LayoutObject->{LanguageObject}->Translate( 'Check SysConfig setting for %s::QueueDefault.', $Self->{Action} ),
                    Comment => Translatable('Please contact the administrator.'),
                );

                return;
            }
        }
        elsif ( $GetParam{Dest} ) {

            my ( $QueueIDParam, $QueueParam ) = split( /\|\|/, $GetParam{Dest} );

            my $QueueIDLookup = $QueueObject->QueueLookup( Queue => $QueueParam );

            if ( $QueueIDLookup && $QueueIDLookup eq $QueueIDParam ) {

                my $CustomerPanelOwnSelection = $Kernel::OM->Get('Kernel::Config')->Get('CustomerPanelOwnSelection');

                if ( %{ $CustomerPanelOwnSelection // {} } ) {
                    $Param{ToSelected} = $QueueIDParam . '||' . $CustomerPanelOwnSelection->{$QueueParam};
                }
                else {
                    $Param{ToSelected} = $GetParam{Dest};
                }

                $ACLCompatGetParam{QueueID} = $QueueIDLookup;
                
            }
        }       

        
        my @BlockFieldsDefault = split(',', $ServiceData{PortalDisbledFieldDefault});

        my $AttachmentConfig = 0;

        if( grep(/Attachment/, @BlockFieldsDefault) ){
            $AttachmentConfig = 1;
        }

        $LayoutObject->Block(
            Name => 'NewTicketService',
            Data => {
                %GetParam,
                DestID => $ACLCompatGetParam{QueueID},
                AttachmentConfig => $AttachmentConfig,
                FormLocation     => $FormLocation,
            }
        );

        # create html strings for all dynamic fields
        my %DynamicFieldHTML;
        
        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            
            next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

            my $PossibleValuesFilter;

            my $IsACLReducible = $BackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );

            if ($IsACLReducible) {

                # get PossibleValues
                my $PossibleValues = $BackendObject->PossibleValuesGet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                );

                # check if field has PossibleValues property in its configuration
                if ( IsHashRefWithData(\%{$PossibleValues}) ) {
                    # convert possible values key => value to key => key for ACLs using a Hash slice
                    my %AclData = %{$PossibleValues};

                    @AclData{ keys %AclData } = keys %AclData;

                    # set possible values filter from ACLs
                    my $ACL = $TicketObject->TicketAcl(
                        %GetParam,
                        %ACLCompatGetParam,
                        Action         => $Self->{Action},
                        TicketID       => $Self->{TicketID},
                        ReturnType     => 'Ticket',
                        ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                        Data           => \%AclData,
                        CustomerUserID => $Self->{UserID},
                    );

                    if ($ACL) {
                        my %Filter = $TicketObject->TicketAclData();

                        # convert Filer key => key back to key => value using map
                        %{$PossibleValuesFilter} = map { $_ => $PossibleValues->{$_} } keys %Filter;
                    }
                }
            }

            my $AdditionalClass = '';

            if($DynamicFieldConfig->{FieldType} eq 'TextArea'){
                $AdditionalClass = 'TextAreaClass';
            }

            # get field html
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } = $BackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                Mandatory            => $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                LayoutObject         => $LayoutObject,
                ParamObject          => $ParamObject,
                AJAXUpdate           => 1,
                UpdatableFields      => $Self->_GetFieldsToUpdate(),
                Class                => $AdditionalClass
            );
          
        }

        # print form
        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{NewTicketService}); 

        $Output .= $Self->_MaskNew(
            TemplateFile     => 'NewTicketService',
            ToSelected       => $Param{ToSelected},
            DynamicFieldHTML => \%DynamicFieldHTML,
            %GetParam,
            %ACLCompatGetParam
        );

        $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }
}

sub _GetFieldsToCustomServiceForm {
    my ( $Self, %Param ) = @_;

    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    my $CustomFormObject;

    if ( $MainObject->Require( 'Kernel::System::CustomServiceForm', Silent => 1 ) ) {
        $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    }

    
    my $LayoutObject     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject      = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject       = $Kernel::OM->Get('Kernel::System::JSON');

    # get params
    my $ServiceID = $Param{ServiceID};

    my $FormSearch = $CustomFormObject->CustomFormSearch(
    	ServiceID => $ServiceID,
    );

    my %DataResponseNoForm = (
        FormHTML => 'No Form.'
    );

    if (!$FormSearch) {
    	return 1;
    }

    my ($Name, $Interface) = split /OTRS/, $Self->{SessionName};

    #  Get Custom Form
    my %CustomDynamicForm = $CustomFormObject->CustomFormGet(
        FormID => $FormSearch,
        UserID => $Self->{UserID}
    );

    if($Interface ne $CustomDynamicForm{Interface} && $CustomDynamicForm{Interface} ne 'OnBothInterfaces') {
        # send HTML response
        return 1;
    }

    my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
        FormID => $FormSearch,
    );

    return $Fields;
}

sub _RenderDynamicField {
    my ( $Self, %Param ) = @_;

    # get layout object
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $LayoutObject            = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    
    for my $Needed (qw(FieldName)) {

        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => $LayoutObject->{LanguageObject}->Translate( 'Parameter %s is missing in %s.', $Needed, '_RenderDynamicField' ),
            };
        }
    }

    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => 'Ticket',
    );

    my $DynamicFieldConfig = ( grep { $_->{Name} eq $Param{FieldName} } @{$DynamicField} )[0];

    if ( !IsHashRefWithData(\%{$DynamicFieldConfig}) ) {

        my $Message = "DynamicFieldConfig missing for field: $Param{FieldName}, or is not a Ticket Dynamic Field!";

        # log error but does not stop the execution as it could be an old Article
        # DynamicField, see bug#11666
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $Message,
        );

        return {
            Success => 1,
            HTML    => '',
        };
    }

    my $PossibleValuesFilter;

    # get dynamic field backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
        DynamicFieldConfig => $DynamicFieldConfig,
        Behavior           => 'IsACLReducible',
    );

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    if ($IsACLReducible) {

        # get PossibleValues
        my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
            DynamicFieldConfig => $DynamicFieldConfig,
        );

        # All Ticket DynamicFields
        # used for ACL checking
        my %DynamicFieldCheckParam = map { $_ => $Param{GetParam}{$_} }
            grep {m{^DynamicField_}xms} ( keys %{ $Param{GetParam} } );

        # check if field has PossibleValues property in its configuration
        if ( IsHashRefWithData(\%{$PossibleValues}) ) {

            # convert possible values key => value to key => key for ACLs using a Hash slice
            my %AclData = %{$PossibleValues};

            @AclData{ keys %AclData } = keys %AclData;

            my %UserType = ();

            if($Self->{UserType} eq 'User') {
                $UserType{UserID} = $Self->{UserID};
            }
            else{
                $UserType{CustomerUserID} = $Self->{UserID};
            }

            # set possible values filter from ACLs
            my $ACL = $TicketObject->TicketAcl(
                %{ $Param{GetParam} },
                DynamicField  => \%DynamicFieldCheckParam,
                Action        => $Self->{Action},
                ReturnType    => 'Ticket',
                ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                Data          => \%AclData,
                %UserType,
            );

            if ($ACL) {
                my %Filter = $TicketObject->TicketAclData();

                # convert Filer key => key back to key => value using map
                %{$PossibleValuesFilter} = map { $_ => $PossibleValues->{$_} } keys %Filter;
            }
        }
    }

    my $ServerError;

    if ( IsHashRefWithData( \%{$Param{Error}} ) ) {
        if (
            defined $Param{Error}->{ $Param{FieldName} }
            && $Param{Error}->{ $Param{FieldName} } ne ''
            )
        {
            $ServerError = 1;
        }
    }

    my $ErrorMessage = '';

    if ( IsHashRefWithData( \%{$Param{ErrorMessages}} ) ) {
        if (
            defined $Param{ErrorMessages}->{ $Param{FieldName} }
            && $Param{ErrorMessages}->{ $Param{FieldName} } ne ''
            )
        {
            $ErrorMessage = $Param{ErrorMessages}->{ $Param{FieldName} };
        }
    }

    $Param{GetParam}->{ 'DynamicField_' . $Param{FieldName} } = $Param{GetParam}->{ 'DynamicField_' . $Param{FieldName} } || '';

    my $DefaultValue;

    if( ($Param{GetParam}{ 'DynamicField_' . $Param{FieldName} } eq "" || $Param{GetParam}{ 'DynamicField_' . $Param{FieldName} } =~ /^ *$/) &&
         exists $DynamicFieldConfig->{Config}->{DefaultValue}){
        $DefaultValue = $DynamicFieldConfig->{Config}->{DefaultValue};
    }
    else{
        $DefaultValue = $Param{GetParam}{ 'DynamicField_' . $Param{FieldName} };
    }

    my $DynamicFieldHTML = $DynamicFieldBackendObject->EditFieldRender(
        DynamicFieldConfig   => $DynamicFieldConfig,
        PossibleValuesFilter => $PossibleValuesFilter,
        Value                => $DefaultValue,
        LayoutObject         => $LayoutObject,
        ParamObject          => $Kernel::OM->Get('Kernel::System::Web::Request'),
        AJAXUpdate           => 1,
        Mandatory            => $Param{Display} == 2,
        UpdatableFields      => $Param{AJAXUpdatableFields},
        ServerError          => $ServerError,
        ErrorMessage         => $ErrorMessage,
    );

    my %Data;

    if($DynamicFieldConfig->{FieldType} eq 'FieldSet'){
        %Data = (
            Name      => $DynamicFieldConfig->{Name},
            Label     => $DynamicFieldHTML->{Label},
            Content   => $DynamicFieldHTML->{Field},
            FieldType => $DynamicFieldConfig->{FieldType},
        );
    }
    else{
        %Data = (
            Name      => $DynamicFieldConfig->{Name},
            Label     => $DynamicFieldHTML->{Label},
            Content   => $DynamicFieldHTML->{Field},
            FieldType => $DynamicFieldConfig->{FieldType},
        );

    }

    return \%Data;
}

sub _GetFieldsToUpdate {
    my ( $Self, %Param ) = @_;

    my @UpdatableFields;

    # set the fields that can be updatable via AJAXUpdate
    if ( !$Param{OnlyDynamicFields} ) {
        @UpdatableFields = qw( Dest ServiceID SLAID PriorityID );
    }

    my $Config = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Self->{Action}");

    # get the dynamic fields for this screen
    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $Config->{DynamicField} || {},
    );

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

        my $IsACLReducible = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsACLReducible',
        );
        next DYNAMICFIELD if !$IsACLReducible;

        push @UpdatableFields, 'DynamicField_' . $DynamicFieldConfig->{Name};
    }

    return \@UpdatableFields;
}

sub _MaskNew {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $ServiceObject      = $Kernel::OM->Get('Kernel::System::Service');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');
    my $SLAObject          = $Kernel::OM->Get('Kernel::System::SLA');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');

    my %ServiceData = $ServiceObject->ServiceGet(
        ServiceID => $Param{ServiceID},
        UserID    => 1,
    );

    if($Self->{FormID}){
        $Param{FormID} = $Self->{FormID};
    }
    
    
    $Param{Errors}->{QueueInvalid} = $Param{Errors}->{QueueInvalid} || '';

    my $DynamicFieldNames = $Self->_GetFieldsToUpdate(
        OnlyDynamicFields => 1,
    );

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get list type
    my $TreeView = 0;

    if ( $ConfigObject->Get('Ticket::Frontend::ListType') eq 'tree' ) {
        $TreeView = 0;
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $Config       = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::CustomerTicketMessage");

    if ( $Config->{Queue} ) {

        # check own selection
        my %NewTos = ( '', '-' );

        my $Module = $ConfigObject->Get('CustomerPanel::NewTicketQueueSelectionModule')
            || 'Kernel::Output::HTML::CustomerNewTicket::QueueSelectionGeneric';

        if ( $Kernel::OM->Get('Kernel::System::Main')->Require($Module) ) {

            my $Object = $Module->new(
                %{$Self},
                SystemAddress => $Kernel::OM->Get('Kernel::System::SystemAddress'),
                Debug         => $Self->{Debug},
            );

            # log loaded module
            if ( $Self->{Debug} && $Self->{Debug} > 1 ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'debug',
                    Message  => "Module: $Module loaded!",
                );
            }

            %NewTos = (
                $Object->Run(
                    Env       => $Self,
                    ACLParams => \%Param
                ),
                ( '', => '-' )
            );
        }
        else {
            return $LayoutObject->FatalError();
        }

        # build to string
        if (%NewTos) {
            for ( sort keys %NewTos ) {
                $NewTos{"$_||$NewTos{$_}"} = $NewTos{$_};
                delete $NewTos{$_};
            }
        }

		my $Disabled = 0;
		if( !IsHashRefWithData(\%NewTos) ){
			$Disabled = 1;
		}

        $Param{ToStrg} = $LayoutObject->AgentQueueListOption(
            Data       => \%NewTos,
            Multiple   => 0,
            Size       => 0,
			Disabled   => $Disabled,
            Name       => 'Dest',
            Class      => "form-control" . $Param{Errors}->{QueueInvalid},
            SelectedID => $Param{ToSelected} || $Param{QueueID},
            TreeView   => $TreeView,
        );

        $LayoutObject->Block(
            Name => 'Queue',
            Data => {
                %Param,
                QueueInvalid => $Param{Errors}->{QueueInvalid},
            },
        );
    }

    my $ImpactOperation = $ConfigObject->Get('CustomerPortal::Core::ShowDynamicFieldImpactOperation');

    if ( $ImpactOperation ~~ [ 1, 2 ]  ) {

        my $ServicesShowImpact = $ConfigObject->Get('CustomerPortal::Core::ServicesShowDynamicFieldImpactOperation');

        my $FlagShow = 0;

        if ( !@{ $ServicesShowImpact } ) {

            $FlagShow = 1;
        }

        for my $ShowService ( @{ $ServicesShowImpact } ) {

            if ( grep { /\b\Q$ShowService\E\b/ } $ServiceData{Name} ) {

                $FlagShow = 1;
            }
        }

        if ( $FlagShow ) {

            my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
            my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');

            my $DynamicFieldFixed = $DynamicFieldObject->DynamicFieldGet(
                Name => 'ImpactOperation',
            );

            my $DynamicFieldFixed2 = $BackendObject->EditFieldRender(
                DynamicFieldConfig => $DynamicFieldFixed,
                LayoutObject       => $LayoutObject,
                ParamObject        => $ParamObject,
            );

            my $ToSetBold = 'ToSetBold' if $ImpactOperation ~~ (1, 2);

            $LayoutObject->Block(
                Name => 'DynamicFieldFixed',
                Data => {
                    Label => $DynamicFieldFixed2->{Label},
                    Field => $DynamicFieldFixed2->{Field},
                    Bold  => $ToSetBold,
                },
            );
        }
    }

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    if( $ConfigObject->Get('CustomerPortal::CompanyTickets::ToEnableUserCustomerRelationsInOpenScreen') eq 'Yes' ){

        my @CustomerIDs = $CustomerUserObject->CustomerIDs(
            User => $Self->{UserID},
        );

        my %Companies;

        for my $CustomerID ( @CustomerIDs ) {

            my %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
                CustomerID => $CustomerID,
            );

            if( $CustomerCompany{CustomerID} ){
                $Companies{$CustomerCompany{CustomerID}} = $CustomerCompany{CustomerCompanyName};

            }

        }

        $Param{CustomerIDStrg} = $LayoutObject->BuildSelection(
            Data       => \%Companies,
            Name       => 'CustomerID',
            Class      => 'Validate_Required form-control Modernize',
            SelectedID => $Self->{UserCustomerID}
        );

        $LayoutObject->Block(
            Name => 'CustomerID',
            Data => \%Param,
        );
    }

    # get priority
    if ( $Config->{Priority} ) {

        my $FieldTypePriority = $ConfigObject->Get('CustomerPortal::Core::FieldTypePriority');

        my %Priorities = $TicketObject->TicketPriorityList(
            %Param,
            CustomerUserID => $Self->{UserID},
            Action         => $Self->{Action},
        );

        # build priority string
        my %PriorityConfig;

        my $ClassPriority = '';
        my $BlockPriority = 'Priority';

        if ( $Param{PriorityID} ) {
            $PriorityConfig{SelectedID} = $Param{PriorityID};
        }
        # Display the field as mandatory and the default option is empty.
        elsif ( $FieldTypePriority ) {

            $ClassPriority                = 'Validate_Required';
            $BlockPriority                = 'PriorityMandatory';
            $PriorityConfig{PossibleNone} = 1;
        }
        elsif ( $ServiceData{ServiceTicketPriority} ) {
            $PriorityConfig{SelectedValue} = $ServiceData{ServiceTicketPriority},
        }
        else {
            $PriorityConfig{SelectedValue} = $Config->{PriorityDefault} || '3 normal';
        }

        $Param{Priority} = $PriorityConfig{SelectedValue};

		my $Disabled = 0;

		if( !IsHashRefWithData(\%Priorities) ){
			$Disabled = 1;
		}      

        $Param{PriorityStrg} = $LayoutObject->BuildSelection(
            Data     => \%Priorities,
            Name     => 'PriorityID',
			Disabled => $Disabled,
            Class    => "$ClassPriority form-control Modernize",
            %PriorityConfig,
        );

        $LayoutObject->Block(
            Name => $BlockPriority,
            Data => \%Param,
        );
    }

    if ( $Config->{TicketType} ) {

        my %Types = $TicketObject->TicketTypeList(
            %Param,
            Action         => $Self->{Action},
            CustomerUserID => $Self->{UserID}
        );

        # build priority string
        my %TypeSelected;

        if ( $Config->{'TicketTypeDefault'} && !$Param{TypeID} ) {
            my %ReverseType = reverse %Types;
            $Param{TypeID} = $ReverseType{ $Config->{'TicketTypeDefault'} };
            $TypeSelected{SelectedValue} = $Param{TypeID};
        }

		my $Disabled = 0;

		if( !IsHashRefWithData(\%Types) ){
			$Disabled = 1;
		}

        $Param{TypeStrg} = $LayoutObject->BuildSelection(
            Data         => \%Types,
            Name         => 'TypeID',
			Disabled     => $Disabled,
            Class        => 'Validate_Required form-control Modernize',
            PossibleNone => 1,
            Translation  => 0,
            %TypeSelected
        );

        $LayoutObject->Block(
            Name => 'TypeID',
            Data => \%Param,
        );
    }

    if ( ($Config->{SLA} || $Config->{SLAMandatory}) ){        

        my %SLAs = $TicketObject->TicketSLAList(
            %Param,
            ServiceID      => $Param{ServiceID},
            CustomerUserID => $Self->{UserID},
            QueueID        => $Param{QueueID}
        );       

        # build priority string
        my %SLASelected;

        if ( $Param{SLAID} ) {
            $SLASelected{SelectedValue} = $Param{SLAID};
        }        

		my $Disabled = 0;

	    if( !IsHashRefWithData(\%SLAs) && !$Config->{SLAMandatory} ){
		 	$Disabled = 1;
		}

        my $SLAClass = 'form-control Modernize';

        if ( $Config->{SLAMandatory} ){
            $SLAClass = 'Validate_Required form-control Modernize';
        }      

        $Param{SLAStrg} = $LayoutObject->BuildSelection(
            Data         => \%SLAs,
            Name         => 'SLAID',
			Disabled     => $Disabled,
            Class        => $SLAClass,
            SelectedValue => $ServiceData{ServiceTicketSLA},
            PossibleNone  => 0,
            %SLASelected,
        );

        if( $Config->{SLAMandatory} ) {
            $LayoutObject->Block(
                Name => 'MandatorySLAID',
                Data => \%Param,
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'SLAID',
                Data => \%Param,
            );
        }
    }


	#sla
	my %Services;
    if ( $Param{QueueID} || $Param{TicketID} ) {
        %Services = $TicketObject->TicketServiceList(
            %Param,
            Action         => $Self->{Action},
            CustomerUserID => $Self->{UserID},
        );
    }

    # prepare errors
    if ( $Param{Errors} ) {
        for ( sort keys %{ $Param{Errors} } ) {
            $Param{$_} = $Param{Errors}->{$_};
        }
    }

    # get the dynamic fields for this screen
    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $Config->{DynamicField} || {},
    );

    # reduce the dynamic fields to only the ones that are designed for customer interface
    my @CustomerDynamicFields;
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

        my $IsCustomerInterfaceCapable = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsCustomerInterfaceCapable',
        );
        next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

        push @CustomerDynamicFields, $DynamicFieldConfig;
    }

    $DynamicField = \@CustomerDynamicFields;

    # Dynamic fields
    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

        # skip fields that HTML could not be retrieved
        next DYNAMICFIELD if !IsHashRefWithData(
            $Param{DynamicFieldHTML}->{ $DynamicFieldConfig->{Name} }
        );

        # get the html strings form $Param
        my $DynamicFieldHTML = $Param{DynamicFieldHTML}->{ $DynamicFieldConfig->{Name} };

        my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
        my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');
        my $ConfigDF      = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::CustomerTicketMessage");

        # if is mandatory
        if($ConfigDF->{DynamicField}{$DynamicFieldConfig->{Name}} eq '2'){
            $DynamicFieldConfig->{Label} = "* ". $DynamicFieldConfig->{Label};
        }

        my $ColMDField    = 'col-md-4';
        my $CardClass     = 'card';
        my $CardBodyClass = 'card-body-dfField';

        if($DynamicFieldConfig->{FieldType} eq 'FieldSet'){

            $ColMDField    = 'col-md-12';
            $CardClass     = 'CardOfFieldSet';
            $CardBodyClass = 'CardBodyClassFieldSet';
        }

        $LayoutObject->Block(
            Name => 'DynamicField',
            Data => {
                Name          => $DynamicFieldConfig->{Name},
                Label         => $DynamicFieldHTML->{Label},
                LabelName     => $DynamicFieldConfig->{Label},
                Field         => $DynamicFieldHTML->{Field},
                ColMDField    => $ColMDField,
                CardClass     => $CardClass,
                CardBodyClass => $CardBodyClass,
            },
        );

        # example of dynamic fields order customization
        $LayoutObject->Block(
            Name => 'DynamicField_' . $DynamicFieldConfig->{Name},
            Data => {
                Name  => $DynamicFieldConfig->{Name},
                Label => $DynamicFieldHTML->{Label},
                Field => $DynamicFieldHTML->{Field},
            },
        );
    }

    # show attachments
    ATTACHMENT:
    for my $Attachment ( @{ $Param{Attachments} } ) {
        if (
            $Attachment->{ContentID}
            && $LayoutObject->{BrowserRichText}
            && ( $Attachment->{ContentType} =~ /image/i )
            && ( $Attachment->{Disposition} eq 'inline' )
            )
        {
            next ATTACHMENT;
        }

        push @{ $Param{AttachmentList} }, $Attachment;
    }

    # add rich text editor
    if ( $LayoutObject->{BrowserRichText} ) {

        # use height/width defined for this screen
        $Param{RichTextHeight} = $Config->{RichTextHeight} || 0;
        $Param{RichTextWidth}  = $Config->{RichTextWidth}  || 0;

        # set up customer rich text editor
        $LayoutObject->CustomerSetRichTextParameters(
            Data => \%Param,
        );

        # send data to JS
        # $LayoutObject->AddJSData(
        #     Key   => 'RichText',
        #     Value => {
        #         Height => '139'
        #     },
        # );
    }

    $Param{ServiceName} = $ServiceData{Name};
    $Param{ServiceName} =~ s|::| -> |g;

    # Create HTML to NavBar 
    my $HTML;

    my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
        ServiceID => $ServiceData{ServiceID},
        UserID    => 1,
    );

    my $OpenTicketByContract = $ConfigObject->Get('CustomerPortal::Core::OpenTicketByContract');

    # get field contract
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'CustomerContract',
    );

    if ( $OpenTicketByContract && IsHashRefWithData($DynamicField) && $Param{ContractID}) {

        my $ContractObject = $Kernel::OM->Get('Kernel::System::ContractManagement');

        my %ContractData = $ContractObject->ContractGet(
            ContractID => $Param{ContractID},
            UserID     => $Self->{UserID},
        );

        $LayoutObject->Block(
            Name => 'ContractName',
            Data => {
                ContractID   => $Param{ContractID},
                ContractName => $ContractData{Name},
            }                
        );

        for my $ServiceParentID( @{$ServiceParentsList} ) {
        
            my %ServiceDataParent = $ServiceObject->ServiceGet(
                ServiceID => $ServiceParentID,
                UserID    => 1,
            );

            $LayoutObject->Block(
                Name => 'LinkOfContractService',
                Data => {
                    ServiceParentID  => $ServiceDataParent{ParentID},
                    ServiceNameShort => $ServiceDataParent{NameShort},
                    LastService      => '0',
                }                
            );
        }    

        $LayoutObject->Block(
            Name => 'LinkOfContractService',
            Data => {
                ServiceParentID  => $ServiceData{ParentID},
                ServiceNameShort => $ServiceData{NameShort},
                LastService      => '1',
            }                
        );
    }
    else {

        my $FirstService = 1;
        for my $ServiceParentID( @{$ServiceParentsList} ) {

            my %ServiceDataParent = $ServiceObject->ServiceGet(
                ServiceID => $ServiceParentID,
                UserID    => 1,
            );           

            $LayoutObject->Block(
                Name => 'LinkOfService',
                Data => {
                    ServiceParentID  => $ServiceDataParent{ParentID},
                    ServiceNameShort => $ServiceDataParent{NameShort},
                    LastService      => 0,
                    FirstService     => $FirstService
                }                
            );

            $FirstService  = 0;
        }    

        $LayoutObject->Block(
            Name => 'LinkOfService',
            Data => {
                ServiceParentID  => $ServiceData{ParentID},
                ServiceNameShort => $ServiceData{NameShort},
                LastService      => 1,
            }                
        );
    }

    my $ConfigTitleStyle = $ConfigObject->Get('CustomerPortal::Core::StyleTitleCustomerServiceForm');

    my $StyleTitleForm = '';
    
    for my $Key ( keys  %{ $ConfigTitleStyle } ) {

        $StyleTitleForm .= "$Key: $ConfigTitleStyle->{$Key};";
    }

    my $EnableCustomServiceForm = $ConfigObject->Get("CustomerPortal::Core::ToEnableCustomServiceForm");
    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    if ($EnableCustomServiceForm && $Param{ServiceID}&& $MainObject->Require( 'Kernel::System::CustomServiceForm', Silent => 1 ) ) {

        my $FormDirection = $ConfigObject->Get("CustomerPortal::Core::CustomServiceFormDirection");

        my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

        my $ReturnFields = $Self->_GetFieldsToCustomServiceForm(
            ServiceID => $Param{ServiceID},
        );

        if($ReturnFields ne '1'){

            #  Get custom form
            my $FormSearch = $CustomFormObject->CustomFormSearch(
                ServiceID => $Param{ServiceID},
            );

            if ($FormSearch) {

                my ($Name, $Interface) = split /OTRS/, $Self->{SessionName};

                #  Get Custom Form
                my %CustomDynamicForm = $CustomFormObject->CustomFormGet(
                    FormID => $FormSearch,
                    UserID => $Self->{UserID}
                );

                if($Interface eq $CustomDynamicForm{Interface} || $CustomDynamicForm{Interface} eq 'OnBothInterfaces') {
                    # send HTML response
                    $LayoutObject->Block(
                        Name => 'DescriptionCustomServiceForm',
                        Data => {
                            DescriptionShort  => $CustomDynamicForm{Description},
                            TitleStyle        => $StyleTitleForm,
                        },
                    );
                }
            }

            if ( $FormDirection == 1) {
                $LayoutObject->Block( Name => 'CustomServiceFormHorizontal' );
            }
            else {
                $LayoutObject->Block( Name => 'CustomServiceFormVertical' );
            }
       
            # Loop through ActivityDialogFields and render their output
            DYNAMICFIELD:
            for my $CurrentField ( @{$ReturnFields} ) {

                if ( !IsHashRefWithData(\%{$CurrentField}) ) {

                    my $Message = $LayoutObject->{LanguageObject}->Translate(
                        'Can\'t get data for Field "%s" of ActivityDialog "%s"!',
                        $CurrentField->{Name}
                    );

                    $LayoutObject->FatalError(
                        Message => $Message,
                    );
                }

                # We render just visible ActivityDialogFields
                next DYNAMICFIELD if !$CurrentField->{Display};

                # render DynamicFields
                if ( $CurrentField->{Name} =~ m{^DynamicField_(.*)}xms ) {

                    my $DynamicFieldName = $1;
                    
                    my $Response = $Self->_RenderDynamicField(
                        FieldName        => $DynamicFieldName,
                        DescriptionShort => $CurrentField->{DescriptionShort},
                        Display          => $CurrentField->{Display},
                        Mask             => $CurrentField->{Mask},
                        GetParam         => \%Param
                    );

                    my $ColMDField    = 'col-md-4';
                    my $CardClass     = 'card';
                    my $NameBlock     = 'Card';
                    my $CardBodyClass = 'card-body-dfField';

                    if($Response->{FieldType} eq 'FieldSet'){

                        $ColMDField    = 'col-md-12';
                        $CardClass     = 'CardOfFieldSet';
                        $NameBlock     = 'Card';
                        $CardBodyClass = 'CardBodyClassFieldSet';
                    }

                    if ( $FormDirection == 1) {
                        $ColMDField    = 'col-md-5';
                        $CardClass     = 'form-horizontal';
                        $NameBlock     = 'Horizontal';
                        $CardBodyClass = '';
                    }

                    $LayoutObject->Block(
                        Name => 'DynamicFieldCustomServiceForm' . $NameBlock,
                        Data => {
                            Name             => $Response->{Name},
                            Label            => $Response->{Label},
                            LabelName        => $Response->{Label},
                            Field            => $Response->{Content},
                            ColMDField       => $ColMDField,
                            CardClass        => $CardClass,
                            CardBodyClass    => $CardBodyClass,
                            ShortDescription => $CurrentField->{DescriptionShort},
                        },
                    ); 

                    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
                        Valid      => 1,
                        ObjectType => 'Ticket',
                    );

                    my $DynamicFieldConfig = ( grep { $_->{Name} eq $Response->{Name} } @{$DynamicField} )[0];

                    my $JSONStringRegex = '';
                    #To treat as dynamic field regex
                    my @ArrayOfRegex = $DynamicFieldConfig->{Config}->{RegExList};
                
                    if($DynamicFieldConfig->{Config}->{RegExList}){

                        my @ArrayOfRegexValue;

                        for my  $ValueHash ( @ArrayOfRegex){

                            for my $Value ( @$ValueHash) {

                                if($Value->{Value}){
                                    push @ArrayOfRegexValue, {
                                        Value => $Value->{Value},
                                        ErrorMessage => $Value->{ErrorMessage},
                                    }
                                }
                            }
                        }
                        $JSONStringRegex = $JSONObject->Encode(
                            Data => \@ArrayOfRegexValue,
                        );
                    }    

                    my $FieldSelector = '#DynamicField_' . $Response->{Name};
               
                    #To treat as dynamic field regex
                    if ( $DynamicFieldConfig->{Config}->{RegExList} ) {

                        $DynamicFieldConfig->{Config}->{RegExList}[0]->{ErrorMessage} = $DynamicFieldConfig->{Config}->{RegExList}[0]->{ErrorMessage} || '';

                        $LayoutObject->AddJSOnDocumentComplete( Code => <<"EOF");

                        \$('$FieldSelector').on('blur', function (Event) {
                            var ArrayOfRegex = $JSONStringRegex;
                            var DynamicField = '$FieldSelector';
                            Event.preventDefault();    
                            Core.Customer.CustomerPortalNewTickets.RegToField(ArrayOfRegex, 'DynamicField_$DynamicFieldConfig->{Name}');

                        });
EOF
                    }                   
                }
            }
        }
    }

    if ( $ConfigObject->Get("CustomerPortal::Core::ShowDescriptionServiceInNewTicket") ) {
        
        $LayoutObject->Block(
            Name => 'DescriptionService',
            Data => {
                Description => $ServiceData{ServiceDescription},
                TitleStyle  => $StyleTitleForm,
            },
        );
    }
    my $EnableServiceTemplate = $ConfigObject->Get("CustomerPortal::Core::ToEnableServiceTemplate");
    my @BlockFieldsDefault = split(',', $ServiceData{PortalDisbledFieldDefault});


    my $TextLabel = $ConfigObject->Get("CustomerPortal::Core::NameOfLabelBody");

    if($EnableServiceTemplate && $Kernel::OM->Get('Kernel::System::ServiceTemplate')){

        my $ServiceTemplateObject = $Kernel::OM->Get('Kernel::System::ServiceTemplate');

        my %TemplateData = $ServiceTemplateObject->TemplateGetByService(
            ServiceID => $Param{ServiceID},
            UserID    => $Self->{UserID},
        );

        if ( $TemplateData{Subject} eq '-') {
            $TemplateData{Subject} = '';
        }

        $LayoutObject->Block(
            Name => 'Subject',
            Data => {
                Subject => $Param{Subject} || $TemplateData{Subject}
            },
        );
        
        
        $LayoutObject->Block(
            Name => 'Body',
            Data => {
                Body      => $Param{Body} || $TemplateData{Response},
                TextLabel => $TextLabel
            },
        );            
    }
    else{
        my $ToEnableServiceNameAsSubject = $ConfigObject->Get('CustomerPortal::Core::ToEnableServiceNameAsSubject');
       

        if($ToEnableServiceNameAsSubject eq '1') {

            my $ServiceName = $ServiceObject->ServiceLookup(
                ServiceID => $Param{ServiceID},
            );

            $LayoutObject->Block(
                Name => 'SubjectWithService',
                Data => {
                    ServiceName  =>	$ServiceName,
                },
            );
        }
        else {

            my $BlockSubject = 0;
            my $DefaultTextSubject;

            for my $FieldsToBlock (@BlockFieldsDefault){

                if ($FieldsToBlock eq 'Subject'){
                    $BlockSubject = 1;
                }
            }

            if($BlockSubject != 1){

                $LayoutObject->Block(
                    Name => 'Subject',
                    Data => {
                        Subject => $Param{Subject},
                    },
                );
            }
            else{
                $LayoutObject->Block(
                    Name => 'Subject',
                    Data => {
                        Subject => $LayoutObject->{LanguageObject}->Translate('New Ticket'),
                        DefaultSubject => 1,
                    },
                );
            }

        }

        if( !grep(/Body/, @BlockFieldsDefault) ){

            $LayoutObject->Block(
                Name => 'Body',
                Data => {
                    Body => $Param{Body},
                    TextLabel => $TextLabel
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'Body',
                Data => {
                    Body => $LayoutObject->{LanguageObject}->Translate('New Ticket'),
                    DefaultBody => 1,
                },
            );
        }
     
    }

    my $EnabledTextTools = $ConfigObject->Get('CustomerPortal::Core::EnabledRichTextTools');
    $LayoutObject->Block(
        Name => 'TextConfig',
        Data => {
            Data => $EnabledTextTools,
        },
    );
 
    # send data to JS
    $LayoutObject->AddJSData(
        Key   => 'DynamicFieldNames',
        Value => $DynamicFieldNames,
    );
    
    # get output back
    return $LayoutObject->Output(
        TemplateFile => $Param{TemplateFile},
        Data         => \%Param,
    );
}

sub _GetTos {
    my ( $Self, %Param ) = @_;

    # check own selection
    my %NewTos = ( '', '-' );

    my $Module = $Kernel::OM->Get('Kernel::Config')->Get('CustomerPanel::NewTicketQueueSelectionModule')
        || 'Kernel::Output::HTML::CustomerNewTicket::QueueSelectionGeneric';

    if ( $Kernel::OM->Get('Kernel::System::Main')->Require($Module) ) {

        my $Object = $Module->new(
            %{$Self},
            SystemAddress => $Kernel::OM->Get('Kernel::System::SystemAddress'),
            Debug         => $Self->{Debug},
        );

        # log loaded module
        if ( $Self->{Debug} && $Self->{Debug} > 1 ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'debug',
                Message  => "Module: $Module loaded!",
            );
        }

        %NewTos = (
            $Object->Run(
                Env       => $Self,
                ACLParams => \%Param
            ),
            ( '', => '-' )
        );
    }
    else {
        return $Kernel::OM->Get('Kernel::Output::HTML::Layout')->FatalDie(
            Message => "Could not load $Module!",
        );
    }

    return \%NewTos;
}

sub _GetPriorities {
    my ( $Self, %Param ) = @_;

    # get priority
    my %Priorities;

    if ( $Param{QueueID} || $Param{TicketID} ) {
        %Priorities = $Kernel::OM->Get('Kernel::System::Ticket')->TicketPriorityList(
            %Param,
            Action         => $Self->{Action},
            CustomerUserID => $Self->{UserID},
        );
    }

    return \%Priorities;
}

sub _GetTypes {
    my ( $Self, %Param ) = @_;

    # get type
    my %Type;

    
    

    if ( $Param{QueueID} || $Param{TicketID} ) {
        %Type = $Kernel::OM->Get('Kernel::System::Ticket')->TicketTypeList(
            %Param,
            Action         => $Self->{Action},
            CustomerUserID => $Self->{UserID},
        );
    }

    return \%Type;
}

sub _GetServices {
    my ( $Self, %Param ) = @_;

    # get service
    my %Service;

    # check needed
    return \%Service if !$Param{QueueID} && !$Param{TicketID};

    # get options for default services for unknown customers
    my $DefaultServiceUnknownCustomer
        = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Service::Default::UnknownCustomer');

    # get service list
    if ( $Param{CustomerUserID} || $DefaultServiceUnknownCustomer ) {
        %Service = $Kernel::OM->Get('Kernel::System::Ticket')->TicketServiceList(
            %Param,
            Action         => $Self->{Action},
            CustomerUserID => $Self->{UserID},
        );
    }

    return \%Service;
}

sub _GetSLAs {
    my ( $Self, %Param ) = @_;

    # get sla
    my %SLA;
    if ( $Param{ServiceID} && $Param{Services} && %{ $Param{Services} } ) {
        if ( $Param{Services}->{ $Param{ServiceID} } ) {
            %SLA = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSLAList(
                %Param,
                Action         => $Self->{Action},
                CustomerUserID => $Self->{UserID},
            );
        }
    }

    return \%SLA;
}

1;