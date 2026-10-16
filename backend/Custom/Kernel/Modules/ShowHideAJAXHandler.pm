# --
# Kernel/Modules/ShowHideAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * nfreitas@serviceup.com.br
# * ccresencio@serviceup.com.br
# * dparavani@serviceup.com.br
# * jguedes@serviceup.com.br
# * gbolsoni@serviceup.com.br
# --

package Kernel::Modules::ShowHideAJAXHandler;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get objects
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject               = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject                = $Kernel::OM->Get('Kernel::System::JSON');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ServiceObject             = $Kernel::OM->Get('Kernel::System::Service');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');

    my $JSON = '';

    # ------------------------------------------------------------ #
    # ajax get ACL
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'GetACLs' ) {

        my $JSONString = $ParamObject->GetParam( Param => 'Params');

        my $Params = $JSONObject->Decode(
            Data => $JSONString,
        );
        
        for my $Key ( keys %{ $Params }){
            $Param{GetParam}->{$Key} = $Params->{$Key} || '';
        }

        my $Action = $ParamObject->GetParam( Param => 'TicketAction');
        
        if ( $Action eq 'NewTicketProcess' && $Param{GetParam}->{ProcessEntityID} eq '' && $Param{GetParam}->{TicketID} ne '' ) {

            my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => "ProcessManagementProcessID",
            );

            my $Value = $BackendObject->ValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $Param{GetParam}->{TicketID},
            );

            $Param{GetParam}->{ProcessEntityID} = $Value;
        }

        my $DynamicFields;

        $Param{GetParam}->{ProcessEntityID} = $Param{GetParam}->{ProcessEntityID} || '';

        if ( $Param{GetParam}->{ProcessEntityID} ne '' && ( $Action eq 'AgentTicketProcess' || $Action eq 'CustomerTicketProcess' || $Action eq 'NewTicketProcess' || $Action eq 'AgentTicketProcessBulk' ) ) {

            $DynamicFields = $Self->_ProcessGetParam(
                Action => $Action,
                Param  => \%{ $Param{GetParam} }
            );
        }
        elsif ( $Action eq 'NewTicketService' ) {
            # To CustomerPortal
            $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $ConfigObject->Get("Ticket::Frontend::CustomerTicketMessage")->{DynamicField} || {},
            );
        }
        elsif ( $Action eq 'CustomerPortalTicketZoom' ) {
            # To CustomerPortal TicketZoom
            $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $ConfigObject->Get("Ticket::Frontend::CustomerTicketZoom")->{FollowUpDynamicField} || {},
            );
        }
        elsif ( $Action eq 'CustomerTicketZoom' ) {
            $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $ConfigObject->Get("Ticket::Frontend::CustomerTicketZoom")->{FollowUpDynamicField} || {},
            );
           
        }
        elsif ( $Action eq 'AgentTicketServiceFormFields' ) {

            my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

            my %Ticket = $TicketObject->TicketGet(
                TicketID      => $Param{GetParam}->{TicketID},
            );

            my $ServiceID = $Ticket{ServiceID};

            my %Service = $ServiceObject->ServiceGet(
                ServiceID => $ServiceID,
                UserID    => 1,
            );

            my $ServiceName = $Service{Name};

            my $List = $CustomFormObject->CustomFormListGet(
                UserID => 1,
            );

            my $FieldFilter = {};

            for my $Form (@{$List}) {
                next if !$Form->{Services}; 

                if ( grep { $_ eq $ServiceName } @{ $Form->{Services} } ) {

                    for my $Field (@{ $Form->{DynamicFields} }) {
                        if ( $Field->{Name} =~ /^DynamicField_(.+)$/ ) {
                            $FieldFilter->{$1} = 1;
                        }
                    }

                    last;
                }
            }

            $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $FieldFilter || {},
            );

        }
        else {
            my $FieldFilter = {};

            if( $ConfigObject->Get("Ticket::Frontend::$Action") ){

                $FieldFilter = $ConfigObject->Get("Ticket::Frontend::$Action")->{DynamicField};

            }

            if ( $Action eq 'AgentEasyCategorization' ){

                my $ListDynamicEasy = $ConfigObject->Get("InBox::EasyCategorization::Config")->{DynamicFields};

                my %FilterEasy;

                for my $Item ( @{$ListDynamicEasy} ) {
            

                    $FilterEasy{$Item} = 1;    

                }

                $FieldFilter = \%FilterEasy; 

            }

            $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $FieldFilter,
            );
            
        }

        my $EnableCustomServiceForm = $ConfigObject->Get("ShowHideField::Core::ToEnableCustomServiceForm");
        
        my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

        if ( $EnableCustomServiceForm && $Params->{ServiceID} && $MainObject->Require( 'Kernel::System::CustomServiceForm', Silent => 1 ) ) {
        
            my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

            my $FormSearch = $CustomFormObject->CustomFormSearch(
                ServiceID => $Params->{ServiceID},
            );

            if ( $FormSearch ) {

                my $FormFields = $CustomFormObject->CustomFormDynamicFieldList(
                    FormID => $FormSearch, 
                );

                for my $Field ( @{$FormFields} ) {

                    my @Aux = split /DynamicField_/ , $Field->{Name};
                    
                    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                        Name => $Aux[1],
                    );

                    push @{$DynamicFields}, $DynamicField;
                }
            }
        }

        my $JSONStringFieldValues = $ParamObject->GetParam( Param => 'FieldValues');
        my $TargetChange = $ParamObject->GetParam( Param => 'TargetChange');

        # get Dynamic fields form ParamObject
        my $DynamicFieldValues = $JSONObject->Decode(
            Data => $JSONStringFieldValues,
        );

        $Param{GetParam}->{DynamicField} = $DynamicFieldValues;

        my $FieldsScreen;
        for my $Field ( keys %{ $DynamicFieldValues } ) {
            $FieldsScreen->{$Field} = 1;
        }

        my $IsACLFields;
        if ( $FieldsScreen ) {
            $IsACLFields = $Self->CheckDynamicFieldACL( NameMatch => $TargetChange, Fields => $FieldsScreen );  
        }  

        my @ACLFields;

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $DynamicFields } ) {

            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
            next DYNAMICFIELD if ! (grep { $_ eq $DynamicFieldConfig->{Name} } @{ $IsACLFields }  ) && $Action ne 'NewTicketProcess';

            #next DYNAMICFIELD if !( $DynamicFieldConfig->{Name} ~~ @{ $IsACLFields } ) && $Action ne 'NewTicketProcess' ;

            my $PossibleValues;
            my %AclData;

            if ( $DynamicFieldConfig->{FieldType} ne 'Dropdown' ) {

                $PossibleValues = '';
            }
            else {
                $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                );
                
                # convert possible values key => value to key => key for ACLs using a Hash slice
                %AclData = %$PossibleValues;
                @AclData{ keys %AclData } = keys %AclData;

            }

            # set possible values filter from ACLs
            my $ACL;

            if ( $Action eq 'CustomerTicketMessage' || $Action eq 'CustomerTicketProcess' || $Action eq 'NewTicketProcess' || $Action eq 'NewTicketService' || $Action eq 'PublicProcessForm' || $Action eq 'CustomerPortalTicketZoom' ) {

                $ACL = $TicketObject->TicketAcl(
                    %{ $Param{GetParam} },
                    ReturnType     => 'ShowHide',
                    ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data           => \%AclData,
                    Action         => $Action,
                    CustomerUserID => $Self->{UserID},
                    ACLType        => 'ShowHide',
                );
            }
            else {
                $ACL = $TicketObject->TicketAcl(
                    %{ $Param{GetParam} },
                    ReturnType    => 'ShowHide',
                    ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data          => \%AclData,
                    Action        => $Action,
                    UserID        => $Self->{UserID},
                    ACLType       => 'ShowHide',
                );
            }

            if ( $ACL ) {

                my %Filter = $TicketObject->TicketAclData();
 
                push @ACLFields, {
                    Field     => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    FieldType => $DynamicFieldConfig->{FieldType},
                    ShowHide  => keys %Filter
                };
            }
        }

        for my $Field (
            qw( Type Dest Queue NewQueueID Priority NewPriorityID State NewStateID Owner NewOwnerID NewUserID
                Responsible NewResponsibleID Service SLA Subject RichText Signature Attachment TimeUnits Lock Title )
        ) {

            my %AllData;

            if ( $Field eq 'Type' ) {
                my $TypeObject = $Kernel::OM->Get('Kernel::System::Type');
                %AllData = $TypeObject->TypeList(
                    Valid => 1
                );
            }
            elsif ( $Field eq 'Service' ) {
                my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');
                %AllData = $ServiceObject->ServiceList(
                    Valid  => 1,
                    UserID => $Self->{UserID},
                );
            }
            elsif ( $Field eq 'SLA' ) {
                my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');
                %AllData = $SLAObject->SLAList(
                    UserID    => 1,
                );
            }
            elsif ( $Field eq 'Queue' || $Field eq 'NewQueueID' || $Field eq 'Dest' ) {
                my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
                %AllData = $QueueObject->QueueList(
                    UserID    => 1,
                );
            }
            elsif ( $Field eq 'Priority' || $Field eq 'NewPriorityID' ) {
                my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');
                %AllData = $PriorityObject->PriorityList(
                    UserID    => 1,
                );
            }
            elsif ( $Field eq 'State' || $Field eq 'NewStateID' ) {
                my $StateObject = $Kernel::OM->Get('Kernel::System::State');
                %AllData = $StateObject->StateList(
                    UserID    => 1,
                );
            }
            elsif ( $Field eq 'Owner' || $Field eq 'NewOwnerID' || $Field eq 'NewUserID' || $Field eq 'Responsible' || $Field eq 'NewResponsibleID' ) {
                my $UserObject = $Kernel::OM->Get('Kernel::System::User');
                %AllData = $UserObject->UserList(
                    Type          => 'Short',
                    Valid         => 1
                );
            }
            elsif ( $Field eq 'Lock' ) {
                my $LockObject = $Kernel::OM->Get('Kernel::System::Lock');
                %AllData = $LockObject->LockList(
                    UserID    => 1,
                );
            }

            # set possible values filter from ACLs
            my $ACL;

            if ( $Action eq 'CustomerTicketMessage' || $Action eq 'CustomerTicketProcess' || $Action eq 'NewTicketProcess' || $Action eq 'NewTicketService' || $Action eq 'CustomerPortalTicketZoom' ) {

                $ACL = $TicketObject->TicketAcl(
                    %{ $Param{GetParam} },
                    Action        => $Action,
                    ReturnType    => 'ShowHide',
                    ReturnSubType => $Field,
                    Data          => \%AllData,
                    CustomerUserID => $Self->{UserID},
                );

            }
            else {

                $ACL = $TicketObject->TicketAcl(
                    %{ $Param{GetParam} },
                    Action        => $Action,
                    ReturnType    => 'ShowHide',
                    ReturnSubType => $Field,
                    Data          => \%AllData,
                    UserID        => $Self->{UserID},
                );
            }

            if ( $ACL ) {
                my %Filter = $TicketObject->TicketAclData();

                my $FieldName = $Field . 'ID';

                if (
                    $Field eq 'NewPriorityID' ||
                    $Field eq 'NewStateID' ||
                    $Field eq 'NewQueueID' ||
                    $Field eq 'Dest' ||
                    $Field eq 'NewOwnerID' ||
                    $Field eq 'NewUserID' ||
                    $Field eq 'NewResponsibleID' ||
                    $Field eq 'Subject' ||
                    $Field eq 'RichText' ||
                    $Field eq 'Signature' ||
                    $Field eq 'Attachment' ||
                    $Field eq 'Title' ||
                    $Field eq 'TimeUnits'
                ) {
                    $FieldName = $Field;
                }
              
                push @ACLFields, {
                    Field     => $FieldName,
                    FieldType => 'Default',
                    ShowHide  => keys %Filter
                };
            }
        }

        $JSON = $JSONObject->Encode(
            Data => \@ACLFields
        );
    }
    # ------------------------------------------------------------ #
    # ajax get View Dynamic Fields
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'GetViewFields' ) {
        
        # Verification required for interaction with ProcessFieldReadOnly module if installed
        my $EnableProcessFieldReadOnly = $ConfigObject->Get("ProcessFieldReadOnly::Core::FieldTypes");
        my $FlagProcessFieldReadOnly = 0;

        if ($EnableProcessFieldReadOnly) {
            $FlagProcessFieldReadOnly = 1;
        }

        my $Action = $ParamObject->GetParam( Param => 'TicketAction');

        my @Fields;

        if ( $Action eq 'AgentTicketProcess' || $Action eq 'CustomerTicketProcess' || $Action eq 'NewTicketProcess' || $Action eq 'AgentTicketProcessBulk' ) {

            my $JSONString = $ParamObject->GetParam( Param => 'Params');

            my $Params = $JSONObject->Decode(
                Data => $JSONString,
            );

            if($Params->{ProcessEntityID} && $Params->{ActivityDialogEntityID}){
                my $DynamicFields = $Self->_ProcessGetParam(
                    Action => $Action,
                    Param  => \%{$Params}
                );

                for ( @{ $DynamicFields } ){
                    push @Fields, 'DynamicField_' . $_->{Name};
                }
            }
        }
        elsif ( $Action eq 'NewTicketService' ) {

            # To CustomerPortal
            my $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $ConfigObject->Get("Ticket::Frontend::CustomerTicketMessage")->{DynamicField} || {},
            );

            my $ServiceID = $ParamObject->GetParam( Param => 'ServiceID' );
            my $EnableCustomServiceForm = $ConfigObject->Get("ShowHideField::Core::ToEnableCustomServiceForm");

            if ( $EnableCustomServiceForm && $ServiceID && $Kernel::OM->Get('Kernel::System::CustomServiceForm') ) {

                my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

                my $FormSearch = $CustomFormObject->CustomFormSearch(
                    ServiceID => $ServiceID,
                );

                if ( $FormSearch ) {

                    my $FormFields = $CustomFormObject->CustomFormDynamicFieldList(
                        FormID => $FormSearch, 
                    );
                    
                    for my $Field ( @{$FormFields} ) {

                        my @Aux = split /DynamicField_/ , $Field->{Name};
                        
                        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                            Name => $Aux[1],
                        );

                        push @{$DynamicFields}, $DynamicField;
                    }
                }
            }

            for ( @{ $DynamicFields } )  {
                push @Fields, 'DynamicField_' . $_->{Name};
            }
        }
        elsif( $Action eq 'CustomerPortalTicketZoom' ){
            # To CustomerPortal TicketZoom
            my $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $ConfigObject->Get("Ticket::Frontend::CustomerTicketZoom")->{FollowUpDynamicField} || {},
            );
            
            for ( @{ $DynamicFields } )  {
                push @Fields, 'DynamicField_' . $_->{Name};
            }
        }
        elsif( $Action eq 'CustomerTicketZoom' ){
            my $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $ConfigObject->Get("Ticket::Frontend::CustomerTicketZoom")->{FollowUpDynamicField} || {},
            );
            
            for ( @{ $DynamicFields } )  {
                push @Fields, 'DynamicField_' . $_->{Name};
            }
        }
        elsif ( $Action eq 'AgentTicketServiceFormFields' ) {

            my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

            my %Ticket = $TicketObject->TicketGet(
                TicketID      => $Param{GetParam}->{TicketID},
            );

            my $ServiceID = $Ticket{ServiceID};

            my %Service = $ServiceObject->ServiceGet(
                ServiceID => $ServiceID,
                UserID    => 1,
            );

            my $ServiceName = $Service{Name};

            my $List = $CustomFormObject->CustomFormListGet(
                UserID => 1,
            );

            my $FieldFilter = {};

            for my $Form (@{$List}) {
                next if !$Form->{Services}; 

                if ( grep { $_ eq $ServiceName } @{ $Form->{Services} } ) {

                    for my $Field (@{ $Form->{DynamicFields} }) {
                        if ( $Field->{Name} =~ /^DynamicField_(.+)$/ ) {
                            $FieldFilter->{$1} = 1;
                        }
                    }

                    last;
                }
            }

            my $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $FieldFilter || {},
            );

            for ( @{ $DynamicFields } )  {
                push @Fields, 'DynamicField_' . $_->{Name};
            }
        }
        else {

            my $FieldFilter = {};

            if( $ConfigObject->Get("Ticket::Frontend::$Action") ){

                $FieldFilter = $ConfigObject->Get("Ticket::Frontend::$Action")->{DynamicField};

            }

            if ( $Action eq 'AgentEasyCategorization' ){

                my $ListDynamicEasy = $ConfigObject->Get("InBox::EasyCategorization::Config")->{DynamicFields};

                my %FilterEasy;

                for my $Item ( @{$ListDynamicEasy} ) {
            

                    $FilterEasy{$Item} = 1;    

                }

                $FieldFilter = \%FilterEasy; 

            }

            my $DynamicFields = $DynamicFieldObject->DynamicFieldListGet(
                Valid       => 1,
                ObjectType  => [ 'Ticket', 'Article' ],
                FieldFilter => $FieldFilter,
            );

            my $ServiceID = $ParamObject->GetParam( Param => 'ServiceID' );
            my $EnableCustomServiceForm = $ConfigObject->Get("ShowHideField::Core::ToEnableCustomServiceForm");

            if ( $EnableCustomServiceForm && $ServiceID && $Kernel::OM->Get('Kernel::System::CustomServiceForm') ) {

                my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

                my $FormSearch = $CustomFormObject->CustomFormSearch(
                    ServiceID => $ServiceID,
                );

                if ( $FormSearch ) {

                    my $FormFields = $CustomFormObject->CustomFormDynamicFieldList(
                        FormID => $FormSearch, 
                    );
                    
                    for my $Field ( @{$FormFields} ) {

                        my @Aux = split /DynamicField_/ , $Field->{Name};
                        
                        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                            Name => $Aux[1],
                        );

                        push @{$DynamicFields}, $DynamicField;
                    }
                }
            }

            for ( @{ $DynamicFields } ) {
                push @Fields, 'DynamicField_' . $_->{Name};
            }
        }

        push @Fields, $FlagProcessFieldReadOnly;

        $JSON = $JSONObject->Encode(
            Data => \@Fields
        );
    }
    
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
};

sub _ProcessGetParam {
    my( $Self, %Param ) = @_;

    # get layout object
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject               = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my %GetParam = %{$Param{Param}};

    for my $Needed (qw(ProcessEntityID)) {
        if ( !$GetParam{$Needed} ) {
            $LayoutObject->FatalError(
                Message => $LayoutObject->{LanguageObject}->Translate( 'Parameter %s is missing in %s.', $Needed, '_ProcessGetParam' ),
            );
        }
    }

    # get activity dialog object
    my $ActivityDialogObject = $Kernel::OM->Get('Kernel::System::ProcessManagement::ActivityDialog');

    # create process object
    $Kernel::OM->ObjectParamAdd(
        'Kernel::System::ProcessManagement::Process' => {
            ActivityObject         => $Kernel::OM->Get('Kernel::System::ProcessManagement::Activity'),
            ActivityDialogObject   => $ActivityDialogObject,
            TransitionObject       => $Kernel::OM->Get('Kernel::System::ProcessManagement::Transition'),
            TransitionActionObject => $Kernel::OM->Get('Kernel::System::ProcessManagement::TransitionAction'),
        }
    );

    my $ProcessObject = $Kernel::OM->Get('Kernel::System::ProcessManagement::Process');

    my $ProcessEntityID        = $GetParam{ProcessEntityID};
    my $ActivityDialogEntityID = $GetParam{ActivityDialogEntityID};
    my @Fields;

    if ( !$ActivityDialogEntityID ) {

        my $Process = $ProcessObject->ProcessGet(
            ProcessEntityID => $ProcessEntityID,
        );

        $ActivityDialogEntityID = $Process->{StartActivityDialog};
    }

    my $ActivityActivityDialog = $ProcessObject->ProcessStartpointGet(
        ProcessEntityID => $ProcessEntityID,
    );

    my $Interface = 'AgentInterface';
    if($Param{Action} eq 'CustomerTicketProcess' || $Param{Action} eq 'NewTicketProcess'){
        $Interface = 'CustomerInterface';
    }

    my $ActivityDialog = $ActivityDialogObject->ActivityDialogGet(
        ActivityDialogEntityID => $ActivityDialogEntityID,
        Interface              => $Interface,
    );

    $Param{Param}->{ActivityEntityID} = $ActivityActivityDialog->{Activity};

    # Get the activitydialogs's Submit Param's or Config Params
    DIALOGFIELD:
    for my $CurrentField ( @{ $ActivityDialog->{FieldOrder} } ) {

        if ( $CurrentField =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldName = $1;
            
            # note - this function can be improved, to avoid searching all fields in the system for 1 process
            my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
                Valid      => 1,
                # ObjectType => 'Ticket',
                ObjectType => ['Ticket', 'Article'],
            );

            # Get the Config of the current DynamicField (the first element of the grep result array)
            my $DynamicFieldConfig = ( grep { $_->{Name} eq $DynamicFieldName } @{$DynamicField} )[0];

            # Get DynamicField Values
            push @Fields, $DynamicFieldConfig;
        }
    }
    return \@Fields;
};

sub CheckDynamicFieldACL {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Fields} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need Name!",
        );
        return;
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL  => "SELECT D.name, ( SELECT COUNT(id) FROM acl WHERE config_change LIKE CONCAT('%', D.name, '%') LIMIT 1) FROM dynamic_field D"
    );

    my @Fields;
    while ( my @Row = $DBObject->FetchrowArray() ) {

        if ( $Row[1] && ($Param{Fields}->{"DynamicField_$Row[0]"} || $Param{Fields}->{"DynamicField_$Row[0]Used"} ) ) {
        	push @Fields, $Row[0];
        }
    }

    return \@Fields;
}

1;