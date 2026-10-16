# --
# Kernel/Modules/CustomerPortalTicketZoom.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * msantos@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalTicketZoom;

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

    my $CommunicationChannelObject = $Kernel::OM->Get('Kernel::System::CommunicationChannel');
    my $CustomerPortalObject       = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $BackendObject              = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ConfigObject               = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject               = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject               = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject                = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $QueueObject                = $Kernel::OM->Get('Kernel::System::Queue');
    my $JSONObject                 = $Kernel::OM->Get('Kernel::System::JSON');
    my $Config                     = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::CustomerTicketMessage");
    my $UserObject                 = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $EnableCopyTickets          = $ConfigObject->Get('CustomerPortal::CompanyTickets::ToEnableTicketsWithUserInCopy');

    my %GetParam;

    $GetParam{TicketNumber} = $ParamObject->GetParam( Param => 'TicketNumber' );
    $GetParam{New}          = $ParamObject->GetParam( Param => 'New' );
    $GetParam{FormID}       = $Self->{FormID};

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "MyTickets",
        %{$Self}
    );

    my $ServicesNotAllowed = $ConfigObject->Get('CustomerPortal::Core::ServicesNotAllowed');
    my $HiddeQueues = $ConfigObject->Get("CustomerPortal::Core::HiddeTicketsByQueue");

    if ( $GetParam{TicketNumber} ) {

        my $TicketID = $TicketObject->TicketIDLookup(
            TicketNumber => $GetParam{TicketNumber},
            UserID       => $Self->{UserID},
        );

        my %Ticket = $TicketObject->TicketGet(
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

        if ( grep { $_ eq $Ticket{Queue} } @{ $HiddeQueues } ) {
            return $LayoutObject->CustomerNoPermission( WithHeader => 'yes' );
        }

        if ( $ServicesNotAllowed ) {

            if ( $Ticket{ServiceID} ) {

                if ( grep( $Ticket{ServiceID} eq $_, @{ $ServicesNotAllowed } ) && $Ticket{CustomerUserID} ne $Self->{UserID} ){
                    return $LayoutObject->CustomerNoPermission( WithHeader => 'yes' );
                }
            }
        }
    }

    my $ConfigCustomer = $ConfigObject->Get("Ticket::Frontend::CustomerTicketZoom");

    # To DynamicFields of information
    # get dynamic field config for frontend module
    my $DynamicFieldFilter         = $ConfigCustomer->{DynamicField};
    my $FollowUpDynamicFieldFilter = $ConfigCustomer->{FollowUpDynamicField};

    # get the dynamic fields for ticket object
    my $FollowUpDynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $FollowUpDynamicFieldFilter || {},
    );

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    if ( $Self->{Subaction} eq 'ReplyCustomerTicket' ) {

        my $ArticleObject     = $Kernel::OM->Get('Kernel::System::Ticket::Article');
        my $UploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

        $GetParam{TicketID}    = $ParamObject->GetParam( Param => 'TicketID' );
        $GetParam{Body}        = $ParamObject->GetParam( Param => 'Body' );
        $GetParam{StateID}     = $ParamObject->GetParam( Param => 'StateID' );
        $GetParam{PriorityID}  = $ParamObject->GetParam( Param => 'PriorityID' );

        $LayoutObject->ChallengeTokenCheck( Type => 'Customer' );

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $GetParam{TicketID},
            DynamicFields => 0,
            UserID        => 1,
        );

        # get follow up option (possible or not)
        my $QueueObject      = $Kernel::OM->Get('Kernel::System::Queue');
        my $FollowUpPossible = $QueueObject->GetFollowUpOption(
            QueueID => $Ticket{QueueID},
        );

        # get lock option (should be the ticket locked - if closed - after the follow up)
        my $Lock = $QueueObject->GetFollowUpLockOption(
            QueueID => $Ticket{QueueID},
        );

        my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');
        my $StateObject = $Kernel::OM->Get('Kernel::System::State');

        # get ticket state details
        my %State = $StateObject->StateGet(
            ID => $Ticket{StateID},
        );

        my %Priority;

        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
        my $EnablePriorityInMyTickets = $ConfigObject->Get('CustomerPortal::Core::EnablePriorityInMyTickets');

        if ($EnablePriorityInMyTickets == 1){

            %Priority = $PriorityObject->PriorityGet(
                ID => $Ticket{PriorityID},
            );
        }

        if ( $FollowUpPossible =~ /(new ticket|reject)/i && $State{TypeName} =~ /^close/i ) {
            my $Output = $LayoutObject->CustomerHeader(
                Title => Translatable('Error'),
            );
            $Output .= $LayoutObject->CustomerWarning(
                Message => Translatable('Can\'t reopen ticket, not possible in this queue!'),
                Comment => Translatable('Create a new ticket!'),
            );

            $Output .= $LayoutObject->CustomerFooter();
            return $Output;
        }

        my $From = "$Self->{UserFullname} <$Self->{UserEmail}>";

        my $MimeType = 'text/plain';

        if ( $LayoutObject->{BrowserRichText} ) {
            $MimeType = 'text/html';

            # verify html document
            $GetParam{Body} = $LayoutObject->RichTextDocumentComplete(
                String => $GetParam{Body},
            );
        }

        # set state
        my $NextState = $ConfigCustomer->{StateDefault} || 'open';
        if ( $GetParam{StateID} && $ConfigCustomer->{State} ) {
            my %NextStateData = $StateObject->StateGet( ID => $GetParam{StateID} );
            $NextState = $NextStateData{Name};
        }


        my $PrioritySet = $ConfigCustomer->{Priority} || '3 normal';
        # set priority
        if ( $GetParam{PriorityID} && $ConfigCustomer->{Priority} ) {
            my %SetPriority = $PriorityObject->PriorityGet( PriorityID => $GetParam{PriorityID}, UserID => 1,);
            $PrioritySet = $SetPriority{Name};
        }
    

        my $HideNextStateByService = $ConfigObject->Get("CustomerPortal::Core::HideNextStateByService");

        if ( ( $Ticket{ServiceID} ~~ @{ $HideNextStateByService } ) ) {
            $NextState = $Ticket{State};
        }

        # change state if
        # customer set another state
        # or the ticket is not new
        if ( !( $Ticket{ServiceID} ~~ @{ $HideNextStateByService } ) && ( $Ticket{StateType} !~ /^new/ || $GetParam{StateID} ) ) {

            $TicketObject->StateSet(
                TicketID => $Self->{TicketID},
                State    => $NextState,
                UserID   => $ConfigObject->Get('CustomerPanelUserID'),
            );

            # set unlock on close state
            if ( $NextState =~ /^close/i ) {
                $TicketObject->TicketLockSet(
                    TicketID => $GetParam{TicketID},
                    Lock     => 'unlock',
                    UserID   => $ConfigObject->Get('CustomerPanelUserID'),
                );
            }
        }

         if ($EnablePriorityInMyTickets == 1){
            
            my $Success = $TicketObject->TicketPrioritySet(
                TicketID => $Self->{TicketID},
                Priority => $PrioritySet,
                UserID   => $ConfigObject->Get('CustomerPanelUserID'),
            );
        }

        

        my $ArticleID = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
            TicketID             => $GetParam{TicketID},
            IsVisibleForCustomer => 1,
            SenderType           => $Config->{SenderType},
            From                 => $From,
            Subject              => $Ticket{Title},
            Body                 => $GetParam{Body},
            MimeType             => $MimeType,
            Charset              => $LayoutObject->{UserCharset},
            UserID               => $ConfigObject->Get('CustomerPanelUserID'),
            OrigHeader           => {
                From    => $From,
                To      => 'System',
                Subject => $GetParam{Subject},
                Body    => $LayoutObject->RichText2Ascii( String => $GetParam{Body} ),
            },
            HistoryType      => 'FollowUp',
            HistoryComment   => $LayoutObject->{LanguageObject}->Translate("Response added via CustomerPortal interface to ticket") . "[$Ticket{TicketNumber}]" || '%%',
            AutoResponseType => 'auto follow up',
        );

        if ( !$ArticleID ) {
            my $Output = $LayoutObject->CustomerHeader(
                Title => Translatable('Error'),
            );
            $Output .= $LayoutObject->CustomerError();
            $Output .= $LayoutObject->CustomerFooter();
            return $Output;
        }

        # get all articles of this ticket, that are visible for the customer
        my @ArticleList = $ArticleObject->ArticleList(
            TicketID             => $Self->{TicketID},
            IsVisibleForCustomer => 1,
            DynamicFields        => 0,
        );

        my @ArticleBox;
        my $ArticleBackendObject;

        ARTICLEMETADATA:
        for my $ArticleMetaData (@ArticleList) {

            next ARTICLEMETADATA if !$ArticleMetaData;
            next ARTICLEMETADATA if !IsHashRefWithData(\%{$ArticleMetaData});

            $ArticleBackendObject = $ArticleObject->BackendForArticle( %{$ArticleMetaData} );

            my %ArticleData = $ArticleBackendObject->ArticleGet(
                TicketID  => $Self->{TicketID},
                ArticleID => $ArticleMetaData->{ArticleID},
                RealNames => 1,
            );

            # Get channel specific fields
            my %ArticleFields = $LayoutObject->ArticleFields(
                TicketID  => $Self->{TicketID},
                ArticleID => $ArticleMetaData->{ArticleID},
            );

            $ArticleData{Subject}      = $ArticleFields{Subject};
            $ArticleData{FromRealname} = $ArticleFields{Sender};

            # Get attachment index.
            my %AtmIndex = $ArticleBackendObject->ArticleAttachmentIndex(
                ArticleID        => $ArticleMetaData->{ArticleID},
                ExcludePlainText => 1,
                ExcludeHTMLBody  => 1,
                ExcludeInline    => 1,
            );

            if ( IsHashRefWithData( \%AtmIndex ) ) {
                $ArticleData{Attachment} = \%AtmIndex;
            }

            push @ArticleBox, \%ArticleData;
        }

        # get pre loaded attachment
        my @AttachmentData = $UploadCacheObject->FormIDGetAllFilesData(
            FormID => $Self->{FormID}
        );

        # get submit attachment
        my %UploadStuff = $ParamObject->GetUploadAll(
            Param => 'file_upload',
        );

        if (%UploadStuff) {
            push @AttachmentData, \%UploadStuff;
        }

        # write attachments
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
                if ( $GetParam{Body} !~ /(\Q$ContentIDHTMLQuote\E|\Q$ContentID\E)/i ) {
                    next ATTACHMENT;
                }
            }

            # write existing file to backend
            $ArticleBackendObject->ArticleWriteAttachment(
                %{$Attachment},
                ArticleID => $ArticleID,
                UserID    => $ConfigObject->Get('CustomerPanelUserID'),
            );
        }

        # redirect to zoom view
        return $LayoutObject->Redirect(
            OP => "Action=CustomerPortalTicketZoom;TicketNumber=$Ticket{TicketNumber}",
        );

    }
    elsif ( $Self->{Subaction} eq 'CustomerResponse' ) {

        my $AutoResponseObject = $Kernel::OM->Get('Kernel::System::AutoResponse');
        my $UploadCacheObject  = $Kernel::OM->Get('Kernel::System::Web::UploadCache');
        my $ArticleObject      = $Kernel::OM->Get('Kernel::System::Ticket::Article');
        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
        my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        $GetParam{TicketID}               = $Self->{TicketID};
        $GetParam{Body}                   = $ParamObject->GetParam( Param => 'Body' );
        $GetParam{StateID}                = $ParamObject->GetParam( Param => 'StateID' );
        $GetParam{PriorityID}             = $ParamObject->GetParam( Param => 'PriorityID' );
        $GetParam{ErrorStateQueueMessage} = $ParamObject->GetParam( Param => 'ErrorStateQueueMessage' );
        $GetParam{ErrorNoBody}            = $ParamObject->GetParam( Param => 'ErrorNoBody' );
        $GetParam{ReplayAll}              = $ParamObject->GetParam( Param => 'ReplayAll' );
        $GetParam{DynamicFields}          = $ParamObject->GetParam( Param => 'DynamicFields' );

        $GetParam{DynamicFields} = $JSONObject->Decode(
            Data => $GetParam{DynamicFields},
        );

        $LayoutObject->ChallengeTokenCheck( Type => 'Customer' );

        my $JSON = "{}";

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $GetParam{TicketID},
            DynamicFields => 0,         # Optional, default 0. To include the dynamic field values for this ticket on the return structure.
            UserID        => 1,
        );

        # get follow up option (possible or not)
        my $QueueObject      = $Kernel::OM->Get('Kernel::System::Queue');
        my $FollowUpPossible = $QueueObject->GetFollowUpOption(
            QueueID => $Ticket{QueueID},
        );

        # get lock option (should be the ticket locked - if closed - after the follow up)
        my $Lock = $QueueObject->GetFollowUpLockOption(
            QueueID => $Ticket{QueueID},
        );

        my $StateObject = $Kernel::OM->Get('Kernel::System::State');
        my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');

        # get ticket state details
        my %State = $StateObject->StateGet(
            ID => $Ticket{StateID},
        );

        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
        my $EnablePriorityInMyTickets = $ConfigObject->Get('CustomerPortal::Core::EnablePriorityInMyTickets');
        
        # set state
        my $NextState = $ConfigCustomer->{StateDefault};

        my $HideNextStateByService = $ConfigObject->Get("CustomerPortal::Core::HideNextStateByService");
        my $HideNextStateByState   = $ConfigObject->Get("CustomerPortal::Core::HideNextStateByState");

        if ( ( $Ticket{ServiceID} ~~ @{ $HideNextStateByService } ) ) {
            $NextState = $Ticket{State};
        }

        if ( ( $Ticket{State} ~~ @{ $HideNextStateByState } ) ) {
            $NextState = $Ticket{State};
        }

        my @Array;
        if ( !$GetParam{Body} ) {

            if($GetParam{ErrorNoBody} == undef){
                $LayoutObject->Block(
                    Name => 'ErrorNoBody',
                    Data => {
                        Message => $LayoutObject->{LanguageObject}->Translate('Enter an answer to submit'),
                    },
                );
            }
        }
        else {

            if ( $FollowUpPossible =~ /(new ticket|reject)/i && $State{TypeName} =~ /^close/i ) {

                if ( $GetParam{ErrorStateQueueMessage} == undef ) {
                    $LayoutObject->Block(
                        Name => 'ErrorStateQueueMessage',
                        Data => {
                            Message => $LayoutObject->{LanguageObject}->Translate('Can\'t reopen ticket, not possible in this queue!'),
                            Comment => $LayoutObject->{LanguageObject}->Translate('Create a new ticket!'),
                        },
                    );
                }
            }
            else {

                my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
                
                my %QueueData = $QueueObject->GetSystemAddress( QueueID => $Ticket{QueueID}, );
                
                my $FromQueue = "$Self->{UserFullname} <$QueueData{Email}>";
                
                my $From = "$Self->{UserFullname} <$Self->{UserEmail}>";

                my $MimeType = 'text/plain';

                if ( $LayoutObject->{BrowserRichText} ) {
                    $MimeType = 'text/html';

                    # verify html document
                    $GetParam{Body} = $LayoutObject->RichTextDocumentComplete(
                        String => $GetParam{Body},
                    );
                }

                if ( $GetParam{StateID} && $ConfigCustomer->{State} ) {
                    my %NextStateData = $StateObject->StateGet( ID => $GetParam{StateID} );
                    $NextState = $NextStateData{Name};
                }  



                my $PrioritySetResponse = $ConfigCustomer->{Priority} || '3 normal';
                if ( $GetParam{PriorityID} && $ConfigCustomer->{Priority} ) {
                    my %PrioritySet = $PriorityObject->PriorityGet( PriorityID  => $GetParam{PriorityID}, UserID => 1 );
                    $PrioritySetResponse = $PrioritySet{Name};
                }               
                
                # change state if
                # customer set another state
                # or the ticket is not new
                if (
                    !( $Ticket{ServiceID} ~~ @{ $HideNextStateByService } ) &&
                    !( $Ticket{State} ~~ @{ $HideNextStateByState } ) &&
                    ($Ticket{StateType} !~ /^new/ || $GetParam{StateID}) 
                ) {

                    $TicketObject->StateSet(
                        TicketID => $GetParam{TicketID},
                        State    => $NextState,
                        UserID   => $ConfigObject->Get('CustomerPanelUserID'),
                    );

                    # set unlock on close state
                    if ( $NextState =~ /^close/i ) {
                        $TicketObject->TicketLockSet(
                            TicketID => $GetParam{TicketID},
                            Lock     => 'unlock',
                            UserID   => $ConfigObject->Get('CustomerPanelUserID'),
                        );
                    }
                }

                if ($EnablePriorityInMyTickets == 1){

                    my $Success = $TicketObject->TicketPrioritySet(
                        TicketID => $GetParam{TicketID},
                        Priority => $PrioritySetResponse,
                        UserID   => $ConfigObject->Get('CustomerPanelUserID'),
                    );

                }
                #  Ajax - Init to DynamicField
                my $DynamicFieldOfConfig = $DynamicFieldObject->DynamicFieldListGet(
                    Valid       => 1,
                    ObjectType  => ['Ticket'],
                    FieldFilter => $DynamicFieldFilter || {},
                );

                #get Dynamic fields from ParamObject
                my %DynamicFieldValues;

                my %ErrorDynamicField;

                my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

                # cycle trough the activated Dynamic Fields for this screen
                DYNAMICFIELD:
                for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {

                    next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

                    if ( $DynamicFieldConfig->{FieldType} eq "Date" || $DynamicFieldConfig->{FieldType} eq "DateTime" ) {

                        if ( $GetParam{DynamicFields}->{"DynamicField_$DynamicFieldConfig->{Name}Used"} ) {

                            my $Day    = $GetParam{DynamicFields}->{"DynamicField_$DynamicFieldConfig->{Name}Day"} || '';
                            my $Month  = $GetParam{DynamicFields}->{"DynamicField_$DynamicFieldConfig->{Name}Month"} || '';
                            my $Year   = $GetParam{DynamicFields}->{"DynamicField_$DynamicFieldConfig->{Name}Year"} || '';
                            my $Hour   = $GetParam{DynamicFields}->{"DynamicField_$DynamicFieldConfig->{Name}Hour"} || '';
                            my $Minute = $GetParam{DynamicFields}->{"DynamicField_$DynamicFieldConfig->{Name}Minute"} || '';

                            $DynamicFieldValues{ $DynamicFieldConfig->{Name} } = sprintf("%04d-%02d-%02d %02d:%02d:00", $Year, $Month, $Day, $Hour, $Minute);
                        }
                    }
                    else {
                        $DynamicFieldValues{ $DynamicFieldConfig->{Name} } = $GetParam{DynamicFields}->{"DynamicField_$DynamicFieldConfig->{Name}"};
                    }

                    if ( $FollowUpDynamicFieldFilter->{$DynamicFieldConfig->{Name}} == 2 && !$DynamicFieldValues{ $DynamicFieldConfig->{Name} } ) {

                        $LayoutObject->Block(
                            Name => 'ErrorNoBody',
                            Data => {
                                Message => $LayoutObject->{LanguageObject}->Translate('Dynamic field %s is required!', $DynamicFieldConfig->{Name} ),
                            },
                        );

                        $ErrorDynamicField{ErrorDynamicField} = 1;
                        $ErrorDynamicField{Name} = $DynamicFieldConfig->{Name};
                    }

                    my $Success = 1;
                    if( $DynamicFieldConfig->{FieldType} eq 'SelectDB' ){
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

                        $Success = $BackendObject->EditFieldValueValidate(
                            DynamicFieldConfig   => $DynamicFieldConfig,
                            PossibleValuesFilter => $PossibleValuesFilter,
                            ParamObject          => $ParamObject,
                        );
                    }
                    else{
                        $Success = $BackendObject->FieldValueValidate(
                            DynamicFieldConfig => $DynamicFieldConfig,
                            Value              => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                            UserID             => 1,
                        );
                    }
                 
                    if ( !$Success ) {

                        $LayoutObject->Block(
                            Name => 'ErrorNoBody',
                            Data => {
                                Message => $LayoutObject->{LanguageObject}->Translate('Dynamic field value %s is invalid!', $DynamicFieldConfig->{Name} ),
                            },
                        );

                        $ErrorDynamicField{ErrorDynamicField} = 1;
                        $ErrorDynamicField{Name} = $DynamicFieldConfig->{Name};
                    }
                }

                if ( $ErrorDynamicField{ErrorDynamicField} ) {

                    my $OutputError = $LayoutObject->Output(
                        TemplateFile => 'CustomerPortalTicketZoomResponse',
                    );

                    $JSON = $JSONObject->Encode(
                        Data => {
                            HTMLString        => $OutputError,
                            ErrorDynamicField => 1,
                            DynamicFieldName  => $ErrorDynamicField{Name},
                        },
                    );

                    return $LayoutObject->Attachment(
                        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                        Content     => $JSON,
                        Type        => 'inline',
                        NoCache     => 1,
                    );
                }

                DYNAMICFIELD:
                for my $DynamicFieldName ( keys %DynamicFieldValues ){
        
                    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                        Name => $DynamicFieldName,
                    );

                    next DYNAMICFIELD if $DynamicFieldConfig->{ObjectType} ne 'Ticket';

                    # set the value
                    my $Success = $BackendObject->ValueSet(
                        DynamicFieldConfig => $DynamicFieldConfig,
                        ObjectID           => $Self->{TicketID},
                        Value              => $DynamicFieldValues{$DynamicFieldName},
                        UserID             => $ConfigObject->Get('CustomerPanelUserID'),
                    );

                    if ( $Success ) {

                        for my $DynamicFieldConfigOfConfig ( @{$DynamicFieldOfConfig} ) {     

                            my %DFFieldToReturn;

                            if( $DynamicFieldConfigOfConfig->{Name} eq $DynamicFieldName ){

                                $DFFieldToReturn{Name}  = $DynamicFieldName;
                                $DFFieldToReturn{Value} = $GetParam{DynamicFields}->{ $DynamicFieldName };
                                $DFFieldToReturn{Label} = $DynamicFieldConfig->{Label};

                                push @Array, \%DFFieldToReturn;
                            }                           
                        }
                    }
                }

                my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

                # get all articles of this ticket, that are visible for the customer
                my @ArticleList = $ArticleObject->ArticleList(
                    TicketID  => $GetParam{TicketID},
                    IsVisibleForCustomer => 1,
                );
            	
                my $ArticleID;

                my @AttachmentData = $UploadCacheObject->FormIDGetAllFilesData(
                    FormID => $Self->{FormID}
                );

                # get submit attachment
                my %UploadStuff = $ParamObject->GetUploadAll(
                    Param => 'file_upload',
                );

                if (%UploadStuff) {
                    push @AttachmentData, \%UploadStuff;
                }

                for my $AR (@ArticleList){
                    
                    my @AttachmentReplayAll;

                    my $ArticleBackendObject = $ArticleObject->BackendForArticle( %{$AR} );

                    my %ArticleData = $ArticleBackendObject->ArticleGet(
                        TicketID  => $GetParam{TicketID},
                        ArticleID => $ArticleList[-1]->{ArticleID},
                        RealNames => 1,
                    );

                    if($AR->{ArticleID} == $ArticleList[-1]->{ArticleID}){
                        # write attachments
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
                                if ( $GetParam{Body} !~ /(\Q$ContentIDHTMLQuote\E|\Q$ContentID\E)/i ) {
                                    next ATTACHMENT;
                                }
                            }

                            push @AttachmentReplayAll, $Attachment;
                            
                        }
                    }

                    if ($AR->{ArticleID} == $ArticleList[-1]->{ArticleID} && $GetParam{ReplayAll} == 1 ){

                        $ArticleID = $ArticleBackendObject->ArticleSend(
                            TicketID   => $GetParam{TicketID},
                            SenderType => $Config->{SenderType},
                            IsVisibleForCustomer => 1, 
                            UserID               => $ConfigObject->Get('CustomerPanelUserID'),
                            From        => $FromQueue,
                            To          => $ArticleData{To},
                            Cc          => $ArticleData{Cc},
                            ReplyTo     => $ArticleData{ReplyTo},
                            Subject     => $Ticket{Title},
                            Body        => $GetParam{Body},
                            InReplyTo   => $ArticleData{InReplyTo},
                            Charset     => $LayoutObject->{UserCharset},
                            MimeType    => $MimeType,
                            Attachment  => \@AttachmentReplayAll,
                            HistoryType    => 'FollowUp',
                            HistoryComment => $LayoutObject->{LanguageObject}->Translate("Response added via CustomerPortal interface to ticket") . "[$Ticket{TicketNumber}]" || '%%',
                        );
                    }
                }
                
                if ($GetParam{ReplayAll} == 0){
                    
                    $ArticleID = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
                        TicketID             => $GetParam{TicketID},
                        IsVisibleForCustomer => 1,
                        SenderType           => $Config->{SenderType},
                        From                 => $From,
                        Subject              => $Ticket{Title},
                        Body                 => $GetParam{Body},
                        MimeType             => $MimeType,
                        Charset              => $LayoutObject->{UserCharset},
                        UserID               => $ConfigObject->Get('CustomerPanelUserID'),
                        OrigHeader           => {
                            From    => $From,
                            To      => 'System',
                            Subject => $GetParam{Subject},
                            Body    => $LayoutObject->RichText2Ascii( String => $GetParam{Body} ),
                        },
                        HistoryType      => 'FollowUp',
                        HistoryComment   => $LayoutObject->{LanguageObject}->Translate("Response added via CustomerPortal interface to ticket") . "[$Ticket{TicketNumber}]" || '%%',
                        AutoResponseType => 'auto follow up',
                    );

                }

                # End to DynamicField

                if ( !$ArticleID ) {
                    $LayoutObject->Block(
                        Name => 'Errors',
                        Data => {
                            Message => $LayoutObject->{LanguageObject}->Translate('Error!'),
                        },
                    );
                }

                my @ArticleBox;
                my $ArticleBackendObject = $ArticleObject->BackendForArticle( TicketID => $GetParam{TicketID}, ArticleID => $ArticleID );
                
                if($GetParam{ReplayAll} == 0){
                    # get pre loaded attachment
                    my @AttachmentData = $UploadCacheObject->FormIDGetAllFilesData(
                        FormID => $Self->{FormID}
                    );

                    # get submit attachment
                    my %UploadStuff = $ParamObject->GetUploadAll(
                        Param => 'file_upload',
                    );

                    if (%UploadStuff) {
                        push @AttachmentData, \%UploadStuff;
                    }

                    # write attachments
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
                            if ( $GetParam{Body} !~ /(\Q$ContentIDHTMLQuote\E|\Q$ContentID\E)/i ) {
                                next ATTACHMENT;
                            }
                        }

                        # write existing file to backend
                        $ArticleBackendObject->ArticleWriteAttachment(
                            %{$Attachment},
                            ArticleID => $ArticleID,
                            UserID    => $ConfigObject->Get('CustomerPanelUserID'),
                        );
                    }
                }

                my %ArticleData = $ArticleBackendObject->ArticleGet(
                    TicketID  => $GetParam{TicketID},
                    ArticleID => $ArticleID,
                    RealNames => 1,
                );

                my $CustomerAge;
                my $SenderTypeClass;

                if( $ArticleData{SenderType} eq 'agent' ||  $ArticleData{SenderType} eq 'system'){
                    $SenderTypeClass =  'AgentResponseCard';
                }else{
                    $SenderTypeClass =  'CustomerResponseCard';
                }

                # next article if not createTime
                next ATTACHMENT if !$ArticleData{CreateTime};

                # Calculate difference between article create time and now in seconds.
                my $ArticleCreateTimeObject = $Kernel::OM->Create(
                    'Kernel::System::DateTime',
                    ObjectParams => {
                        String => $ArticleData{CreateTime},
                    },
                );

                my $Delta = $ArticleCreateTimeObject->Delta(
                        DateTimeObject => $Kernel::OM->Create('Kernel::System::DateTime'),
                );

                my $CreateTimeInHours = $LayoutObject->CustomerAge(
                    Age   => 1,
                    Space => ' ',
                );

                # Render article content.
                my $ArticleContent = $LayoutObject->ArticlePreview(
                    TicketID  => $GetParam{TicketID},
                    ArticleID => $ArticleData{ArticleID},
                );

                # Init images get
                my $Content = $LayoutObject->Output(
                    Template => '[% Data.HTML %]',
                    Data     => {
                        HTML => $ArticleContent,
                    },
                );

                my %Data = (
                    Content            => $Content,
                    ContentAlternative => '',
                    ContentID          => '',
                    ContentType        => 'text/html; charset="utf-8"',
                    Disposition        => "inline",
                    FilesizeRaw        => bytes::length($Content),
                );

                my $URL = 'Action=CustomerTicketAttachment;Subaction=HTMLView'
                . ";TicketID=$GetParam{TicketID};ArticleID=$ArticleData{ArticleID};FileID=";

                # replace links to inline images in html content
                my %AtmBox = $ArticleBackendObject->ArticleAttachmentIndex(
                    ArticleID => $ArticleData{ArticleID},
                    ExcludePlainText => 1,
                    ExcludeHTMLBody  => 1,
                );

                # reformat rich text document to have correct charset and links to
                # inline documents


                %Data = $LayoutObject->RichTextDocumentServe(
                    Data        => \%Data,
                    URL         => $URL,
                    Attachments => \%AtmBox,
                );

                # To remove the html of Znuny
                # $Data{Content} =~ s|style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;| "" |g;
                $Data{Content} =~ s|style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;| style="font-family:'Montserrat', 'Helvetica Neue', Arial, sans-serif; color: #393939;; |g;

                $LayoutObject->Block(
                    Name => 'MessageBodyResponseCustomer',
                    Data => {
                        Body           => $ArticleData{Body},
                        SenderType     => $SenderTypeClass,
                        FromRealname   => $ArticleData{FromRealname},
                        Age            => $CreateTimeInHours,
                        CreateTime     => $ArticleData{CreateTime},
                        TicketID       => $GetParam{TicketID},
                        ArticleID      => $ArticleData{ArticleID},
                        ArticleContent => $Data{Content},
                        Attachments    => \%AtmBox,
                        URL            => $URL
                    },
                );

                for my $Attch (keys %AtmBox){
                    $LayoutObject->Block(
                        Name => 'MessageBodyAttchResponseCustomer',
                        Data => {
                            Link        => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=CustomerTicketAttachment;TicketID=$GetParam{TicketID};ArticleID=$ArticleData{ArticleID};FileID=$Attch",
                            Filename    => $AtmBox{$Attch}{Filename},
                            FilesizeRaw => $AtmBox{$Attch}{FilesizeRaw},
                        }
                    );
                }
            }
        }

        my $OutputReload = $LayoutObject->Output(
            TemplateFile => 'CustomerPortalTicketZoomResponse',
        );
        
        my $PriorityName;

        if ($EnablePriorityInMyTickets == 1){
            $PriorityName = $PriorityObject->PriorityLookup(
                PriorityID => $GetParam{PriorityID},
            );

        }
        
        $JSON = $JSONObject->Encode(
            Data => {
                HTMLString  => $OutputReload,
                TicketState => $LayoutObject->{LanguageObject}->Translate($NextState),
                DynamicFieldsSpan => \@Array,
                PriorityName =>  $LayoutObject->{LanguageObject}->Translate($PriorityName),
            },
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    elsif ( $Self->{Subaction} eq 'AJAXUpdate' ) {
        # get Dynamic fields from ParamObject
        my %DynamicFieldValues;

        my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
        my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
        my $EnablePriorityInMyTickets = $ConfigObject->Get('CustomerPortal::Core::EnablePriorityInMyTickets');


        my $FollowUpDynamicField = $DynamicFieldObject->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => [ 'Ticket', 'Article' ],
            FieldFilter => $FollowUpDynamicFieldFilter || {},
        );

        $GetParam{StateID}  = $ParamObject->GetParam( Param => 'StateID' );
        $GetParam{PriorityID}  = $ParamObject->GetParam( Param => 'PriorityID' );

        # reduce the dynamic fields to only the ones that are designed for customer interface
        my @CustomerDynamicFields;
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {            
            
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $IsCustomerInterfaceCapable = $BackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsCustomerInterfaceCapable',
            );
            next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

            push @CustomerDynamicFields, $DynamicFieldConfig;
        }

        $FollowUpDynamicField = \@CustomerDynamicFields;

        # create html strings for all dynamic fields
        my %DynamicFieldHTML;

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

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
                if ( IsHashRefWithData($PossibleValues) ) {

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

            my $ValidationResult = $BackendObject->EditFieldValueValidate(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                ParamObject          => $ParamObject,
                Mandatory =>
                    $ConfigCustomer->{FollowUpDynamicField}->{ $DynamicFieldConfig->{Name} }
                    == 2,
            );

            if ( !IsHashRefWithData($ValidationResult) ) {
                my $Output = $LayoutObject->CustomerHeader(
                    Title => Translatable('Error'),
                );
                $Output .= $LayoutObject->CustomerError(
                    Message => $LayoutObject->{LanguageObject}
                        ->Translate( 'Could not perform validation on field %s!', $DynamicFieldConfig->{Label} ),
                    Comment => Translatable('Please contact the administrator.'),
                );
                $Output .= $LayoutObject->CustomerFooter();
                return $Output;
            }

            # propagate validation error to the Error variable to be detected by the frontend
            if ( $ValidationResult->{ServerError} ) {
                # $Error{ $DynamicFieldConfig->{Name} } = ' ServerError';

                # make FollowUp visible to correctly show the error
                $GetParam{FollowUpVisible} = 'Visible';
            }

            # get field html
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } = $BackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                Mandatory            => $ConfigCustomer->{FollowUpDynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                ServerError          => $ValidationResult->{ServerError}  || '',
                ErrorMessage         => $ValidationResult->{ErrorMessage} || '',
                LayoutObject         => $LayoutObject,
                ParamObject          => $ParamObject,
                AJAXUpdate           => 1,
                UpdatableFields      => $Self->_GetFieldsToUpdate(),
            );
        }

        $Param{DynamicFieldHTML} = \%DynamicFieldHTML;

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            # extract the dynamic field value from the web request
            $DynamicFieldValues{ $DynamicFieldConfig->{Name} } = $BackendObject->EditFieldValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ParamObject        => $ParamObject,
                LayoutObject       => $LayoutObject,
            );
        }

        # convert dynamic field values into a structure for ACLs
        my %DynamicFieldACLParameters;
        DYNAMICFIELD:
        for my $DynamicField ( sort keys %DynamicFieldValues ) {
            next DYNAMICFIELD if !$DynamicField;
            next DYNAMICFIELD if !$DynamicFieldValues{$DynamicField};

            $DynamicFieldACLParameters{ 'DynamicField_' . $DynamicField } = $DynamicFieldValues{$DynamicField};
        }
        $GetParam{DynamicField} = \%DynamicFieldACLParameters;

        # get TicketID
        if ( !$GetParam{TicketID} ) {
            $GetParam{TicketID} =
                $Self->{TicketID} ||
                $ParamObject->GetParam( Param => 'TicketID' );
        }

        my $CustomerUser = $Self->{UserID};

        my $NextStates = $Self->_GetNextStates(
            %GetParam,
            CustomerUserID => $CustomerUser || '',
            TicketID       => $Self->{TicketID},
        );

        # update Dynamic Fields Possible Values via AJAX
        my @DynamicFieldAJAX;

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

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
                Action         => $Self->{Action},
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
            push @DynamicFieldAJAX, {
                Name        => 'DynamicField_' . $DynamicFieldConfig->{Name},
                Data        => $DataValues,
                SelectedID  => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                Translation => $DynamicFieldConfig->{Config}->{TranslatableValues} || 0,
                Max         => 100,
            };

        }

        my $JSON = $LayoutObject->BuildSelectionJSON(
            [
                {
                    Name        => 'StateID',
                    Data        => $NextStates,
                    SelectedID  => $GetParam{StateID},
                    Translation => 1,
                    Max         => 100,
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
    else {

        my $TicketID = $TicketObject->TicketIDLookup(
            TicketNumber => $GetParam{TicketNumber},
            UserID       => $Self->{UserID},
        );

        # ticket id lookup
        if ( !$Self->{TicketID} && $GetParam{TicketNumber} ) {
            $Self->{TicketID} = $TicketObject->TicketIDLookup(
                TicketNumber => $GetParam{TicketNumber},
                UserID       => $Self->{UserID},
            );
        }

        if ( $GetParam{TicketNumber} && !$Self->{TicketID} ) {
            return $LayoutObject->CustomerNoPermission( WithHeader => 'yes' );
        }

        # check needed stuff
        if ( !$Self->{TicketID} ) {

            my $Output = $LayoutObject->CustomerHeader(
                Title => Translatable('Error'),
            );

            $Output .= $LayoutObject->CustomerError(
                Message => Translatable('Need TicketID!'),
            );

            $Output .= $LayoutObject->CustomerFooter();

            return $Output;
        }

        # check permissions
        my $Access = $TicketObject->TicketCustomerPermission(
            Type     => 'ro',
            TicketID => $Self->{TicketID},
            UserID   => $Self->{UserID},
        );

        if( $EnableCopyTickets eq 'Yes' ){
            my %User = $UserObject->CustomerUserDataGet(
                User => $Self->{UserLogin},
            );

            my $UserEmail = $User{UserEmail};

            my @CcTickets = $TicketObject->TicketSearch(
                TicketID            => $Self->{TicketID},  
                Result              => 'ARRAY',
                MIMEBase_Cc         => '%' . $UserEmail . '%',
                UserID              => 1,
            );

            my @DynamicFieldCcTickets = $TicketObject->TicketSearch(
                TicketID                => $Self->{TicketID},  
                Result                  => 'ARRAY',
                DynamicField_CustomerCC => {
                    Like => '%' . $UserEmail . '%'
                },
                UserID                  => 1,
            );

            if ( grep { $_ == $Self->{TicketID} } @CcTickets, @DynamicFieldCcTickets ) {
                $Access = 1;
            }
        }

        # error screen, don't show ticket
        if ( !$Access ) {
            return $LayoutObject->CustomerNoPermission( WithHeader => 'yes' );
        }

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            DynamicFields => 1,
            UserID        => 1,
            Extended      => 1
        );

        $GetParam{Title} = $Ticket{Title};

        my $ShowBackNewTicket = $ConfigObject->Get('CustomerPortal::CustomerTicketZoom::ShowBackNewTicket');

        if ( $ShowBackNewTicket ) {

            $LayoutObject->Block(
                Name => 'BackNewTicket',
                Data => {
                    TicketNumber => $Ticket{TicketNumber},
                    ProcessID    => $Ticket{DynamicField_ProcessManagementProcessID},
                },
            );
        }

        # ticket type
        my $ConfigCustomer = $ConfigObject->Get("Ticket::Frontend::CustomerTicketZoom");

        if ( $ConfigObject->Get('Ticket::Type') && $ConfigCustomer->{AttributesView}->{Type} ) {

            my %Type = $Kernel::OM->Get('Kernel::System::Type')->TypeGet(
                Name => $Ticket{Type},
            );

            $LayoutObject->Block(
                Name => 'Type',
                Data => {
                    Valid => $Type{ValidID},
                    Type => $Ticket{Type},
                }
            );
        }
        
        # ticket service
        if ($Ticket{Service} && $ConfigObject->Get('Ticket::Service') && $ConfigCustomer->{AttributesView}->{Service}) {
            $LayoutObject->Block(
                Name => 'Service',
                Data => {
                    Service => $Ticket{Service},
                }
            );

            if ($Ticket{SLAID} && $ConfigObject->Get('Ticket::Service') && $ConfigCustomer->{AttributesView}->{SLA}) {
                $LayoutObject->Block(
                    Name => 'SLA',
                    Data => {
                        SLA => $Ticket{SLA},
                    }
                );
            }
        }

        my $EnableCustomerTicketZoomSLA = $ConfigObject->Get("CustomerPortal::Core::ToEnableCustomerTicketZoomSLA");

        if ($EnableCustomerTicketZoomSLA){

            if ( $Ticket{SLAID} && $ConfigObject->Get('Ticket::Service') ) {

                my $EnableSolutionTime      = $ConfigObject->Get('CustomerPortal::Core::CustomerTicketZoomSLA::EnableSolutionTimeForAllCustomers');
                my $EnableFirstResponseTime = $ConfigObject->Get('CustomerPortal::Core::CustomerTicketZoomSLA::EnableFirstResponseTimeForAllCustomers');
                

                my %Ticket = $TicketObject->TicketGet(
                    TicketID      => $TicketID,
                    UserID        => 1,
                    Extended      => 1
                );    

                # to enable solution time or first response time for all customer regardless of the type
                if ( $EnableSolutionTime || $EnableFirstResponseTime ) {

                    # show solution time
                    if ( $EnableSolutionTime ) {

                        my %SolutionTimeValues = $Self->_GetSLASolutionTime(
                            TicketNumber => $Ticket{TicketNumber},
                        );

                        if ( IsHashRefWithData(\%SolutionTimeValues) ) {

                            $LayoutObject->Block(
                                Name => 'SLACustomSolution',
                                Data => {
                                    SolutionTimeLimit      => $SolutionTimeValues{SolutionTimeLimit},
                                    SolutionTimeSpent      => $SolutionTimeValues{SolutionTimeSpent},
                                    EscalationSolutionTime => $Ticket{EscalationSolutionTime}
                                }
                            );
                        }
                    }

                    # show first response time
                    if ( $EnableFirstResponseTime ) {

                        my %FirstResponseTimeValues = $Self->_GetSLAFirstResponseTime(
                            TicketNumber => $Ticket{TicketNumber},
                        );

                        if ( IsHashRefWithData(\%FirstResponseTimeValues) ) {

                            $LayoutObject->Block(
                                Name => 'SLACustomResponse',
                                Data => {
                                    FirstResponseTimeLimit   => $FirstResponseTimeValues{FirstResponseTimeLimit},
                                    FirstResponseTimeSpent   => $FirstResponseTimeValues{FirstResponseTimeSpent},
                                    EscalationResponseTime   => $Ticket{EscalationSolutionTime}
                                }
                            );
                        }
                    }
                }
                else {

                    my $CustomerMapping = $ConfigObject->Get('CustomerPortal::Core::CustomerTicketZoomSLA::CustomerMapping');
                    my $TypeMapping = $ConfigObject->Get('CustomerPortal::Core::CustomerTicketZoomSLA::TypeMapping');

                    if( $Ticket{CustomerID} ~~ @{ $CustomerMapping } ){                    

                        if ( IsArrayRefWithData( \@{ $TypeMapping->{Incident} }  ) ) {

                            if ( $Ticket{Type} ~~ @{ $TypeMapping->{Incident} } ) {

                                my %FirstResponseTimeValues = $Self->_GetSLAFirstResponseTime(
                                    TicketNumber => $Ticket{TicketNumber},
                                );

                                if ( IsHashRefWithData(\%FirstResponseTimeValues) ) {

                                    $LayoutObject->Block(
                                        Name => 'SLACustomResponse',
                                        Data => {
                                            FirstResponseTimeLimit   => $FirstResponseTimeValues{FirstResponseTimeLimit},
                                            FirstResponseTimeSpent   => $FirstResponseTimeValues{FirstResponseTimeSpent},
                                            EscalationResponseTime   => $Ticket{EscalationSolutionTime}
                                        }
                                    );
                                }
                                        
                                my %SolutionTimeValues = $Self->_GetSLASolutionTime(
                                    TicketNumber => $Ticket{TicketNumber},
                                );

                                if ( IsHashRefWithData(\%SolutionTimeValues) ) {

                                    $LayoutObject->Block(
                                        Name => 'SLACustomSolution',
                                        Data => {
                                            SolutionTimeLimit      => $SolutionTimeValues{SolutionTimeLimit},
                                            SolutionTimeSpent      => $SolutionTimeValues{SolutionTimeSpent},
                                            EscalationSolutionTime => $Ticket{EscalationSolutionTime}
                                        }
                                    );
                                }
                            }
                        }

                        if ( IsArrayRefWithData( \@{ $TypeMapping->{Request} }  ) ) {

                            if ( $Ticket{Type} ~~ @{ $TypeMapping->{Request} } ) {

                                my %SolutionTimeValues = $Self->_GetSLASolutionTime(
                                    TicketNumber => $Ticket{TicketNumber},
                                );

                                if ( IsHashRefWithData(\%SolutionTimeValues) ) {

                                    $LayoutObject->Block(
                                        Name => 'SLACustomSolution',
                                        Data => {
                                            SolutionTimeLimit      => $SolutionTimeValues{SolutionTimeLimit},
                                            SolutionTimeSpent      => $SolutionTimeValues{SolutionTimeSpent},
                                            EscalationSolutionTime => $Ticket{EscalationSolutionTime}
                                        }
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }
        my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
        my $StateObject    = $Kernel::OM->Get('Kernel::System::State');    
        my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');

        # get ticket state details
        my %State = $StateObject->StateGet(
            ID => $Ticket{StateID},
        );

        
        my $EnablePriorityInMyTickets = $ConfigObject->Get('CustomerPortal::Core::EnablePriorityInMyTickets');

        if ($EnablePriorityInMyTickets == 1){

            my %Lise = $PriorityObject->PriorityGet(
                PriorityID => $Ticket{PriorityID},
                UserID     => 1,
            );   
        }

        # Message Response block
        my $FollowUpPossible = $QueueObject->GetFollowUpOption(
            QueueID => $Ticket{QueueID},
        );

        my $FollowUpAttr = 1;

        if ( ( $FollowUpPossible =~ /(new ticket|reject)/i && $State{TypeName} =~ /^closed/i ) || $State{TypeName} =~ /(^merged)/i ) {

            $FollowUpAttr = 0;
        }

        my $UserAvatar = $CustomerPortalLayoutObject->_GetUserAvatar( UserEmail => $Self->{UserEmail} );

        # ticket state
        if ( $ConfigCustomer->{AttributesView}->{State} ) {
            $LayoutObject->Block(
                Name => 'State',
                Data => {
                    State => $Ticket{State},
                }
            );
        }

        # build next states string
        if ( $ConfigCustomer->{State} ) {
            my $NextStates = $Self->_GetNextStates(
                %Param,
                %Ticket,
                Action         => $Self->{Action},
                CustomerUserID => $Self->{UserID}
            );

            my %StateSelected;

            if ( $Param{StateID} ) {
                $StateSelected{SelectedID} = $Param{StateID};
            }
            else {
                $StateSelected{SelectedValue} = $ConfigCustomer->{StateDefault};
            }

            # Check ACL
            my $ACL = $TicketObject->TicketAcl(
                %Ticket,
                Action         => $Self->{Action},
                CustomerUserID => $Self->{UserID},
                ReturnType     => 'Ticket',
                ReturnSubType  => 'State',
                Data           => \%{$NextStates}
            );

            if ( $ACL ) {
                my %NextStates2 = $TicketObject->TicketAclData();

                $Param{NextStatesStrg} = $LayoutObject->BuildSelection(
                    Data => \%NextStates2,
                    Name => 'StateID',
                    Class => "NextState NextStateZoom",
                    %StateSelected,
                );
            }
            else {

                $Param{NextStatesStrg} = $LayoutObject->BuildSelection(
                    Data => $NextStates,
                    Name => 'StateID',
                    Class => "NextState NextStateZoom",
                    %StateSelected,
                );
            }
        }

        # ticket priority
        if ( $ConfigCustomer->{AttributesView}->{Priority} ) {
            $LayoutObject->Block(
                Name => 'Priority',
                Data => {
                    Priority => $Ticket{Priority},
                }
            );
        }

        # ticket queue
        if ( $ConfigCustomer->{AttributesView}->{Queue} ) {
            $LayoutObject->Block(
                Name => 'Queue',
                Data =>{
                    Queue => $Ticket{Queue},
                }
            );
        }

        my $AgentUserObject = $Kernel::OM->Get('Kernel::System::User');

        # ticket owner
        if ( $ConfigCustomer->{AttributesView}->{Owner} ) {
            my $OwnerName = $AgentUserObject->UserName(
                UserID => $Ticket{OwnerID},
            );
            $LayoutObject->Block(
                Name => 'Owner',
                Data => { OwnerName => $OwnerName },
            );
        }

        # ticket age
        if ( $ConfigCustomer->{AttributesView}->{Age} ) {
            # age design
            $Ticket{Age} = $LayoutObject->CustomerAge(
                Age   => $Ticket{Age},
                Space => ' '
            );

            $LayoutObject->Block(
                Name => 'Age',
                Data => { Age => $Ticket{Age} },
            );
        }

        # ticket responsible
        if (
            $ConfigObject->Get('Ticket::Responsible')
            &&
            $ConfigCustomer->{AttributesView}->{Responsible}
            )
        {
            my $ResponsibleName = $AgentUserObject->UserName(
                UserID => $Ticket{ResponsibleID},
            );
            $LayoutObject->Block(
                Name => 'Responsible',
                Data => {
                    ResponsibleName => $ResponsibleName,
                },
            );
        }

        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
        my $EnableAccountedTimeInTicket = $ConfigObject->Get("CustomerPortal::Core::EnableAccountedTimeInTicket");

        # ticket time units/accounted time
        if ( $EnableAccountedTimeInTicket ) {
          
            $Ticket{TicketTimeUnits} = $TicketObject->TicketAccountedTimeGet(
                TicketID => $Ticket{TicketID},
            );

            my $TimeAccounted = _ConvertSecondsToHHMMSS($Ticket{TicketTimeUnits}*60);

            $LayoutObject->Block(
                Name => 'TicketTimeUnits',
                Data => { TicketTimeUnits => $TimeAccounted },
            );           
        }

        # check if ticket is normal or process ticket
        my $IsProcessTicket = $TicketObject->TicketCheckForProcessType(
            'TicketID' => $Self->{TicketID},
        );

        my $HideActivity = 0;
        my $FlagProcess  = 0;

        # show process widget  and activity dialogs on process tickets
        if ( $IsProcessTicket ) {

            $FlagProcess = 1;

            # get the DF where the ProcessEntityID is stored
            my $ProcessEntityIDField = 'DynamicField_' . $ConfigObject->Get("Process::DynamicFieldProcessManagementProcessID");

            # get the DF where the AtivityEntityID is stored
            my $ActivityEntityIDField = 'DynamicField_' . $ConfigObject->Get("Process::DynamicFieldProcessManagementActivityID");


            # create additional objects for process management
            my $ActivityDialogObject = $Kernel::OM->Get('Kernel::System::ProcessManagement::ActivityDialog');
            my $ActivityObject       = $Kernel::OM->Get('Kernel::System::ProcessManagement::Activity');
            my $ProcessObject        = $Kernel::OM->Get('Kernel::System::ProcessManagement::Process');
            my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');

            my $ProcessData = $ProcessObject->ProcessGet(
                ProcessEntityID => $Ticket{$ProcessEntityIDField},
            );

            my $ActivityData = $ActivityObject->ActivityGet(
                Interface        => 'CustomerInterface',
                ActivityEntityID => $Ticket{$ActivityEntityIDField},
            );

            my $HideResponseActivity = $ConfigObject->Get("CustomerPortal::Core::HideButtonResponseActivity");

            if ( $Ticket{$ActivityEntityIDField} && $Ticket{$ActivityEntityIDField} eq $HideResponseActivity->{$Ticket{$ActivityEntityIDField}} ) {
                $HideActivity = 1;
            }

            # output process information in the sidebar
            $LayoutObject->Block(
                Name => 'ProcessData',
                Data => {
                    Process  => $ProcessData->{Name}  || '',
                    Activity => $ActivityData->{Name} || '',
                },
            );

            # output the process widget the the main screen
            $LayoutObject->Block(
                Name => 'ProcessWidget',
                Data => {
                    WidgetTitle => $Param{WidgetTitle},
                },
            );

            # get next activity dialogs
            my $NextActivityDialogs;
            if ( $Ticket{$ActivityEntityIDField} ) {
                $NextActivityDialogs = $ActivityData;
            }

            if ( IsHashRefWithData($NextActivityDialogs) && $ConfigObject->Get("CustomerPortal::Core::ShowNextActivityDialog") ) {

                # we don't need the whole Activity config,
                # just the Activity Dialogs of the current Activity
                if ( IsHashRefWithData( $NextActivityDialogs->{ActivityDialog} ) ) {
                    %{$NextActivityDialogs} = %{ $NextActivityDialogs->{ActivityDialog} };
                }
                else {
                    $NextActivityDialogs = {};
                }

                # we have to check if the current user has the needed permissions to view the
                # different activity dialogs, so we loop over every activity dialog and check if there
                # is a permission configured. If there is a permission configured we check this
                # and display/hide the activity dialog link
                my %PermissionRights;
                my %PermissionActivityDialogList;
                ACTIVITYDIALOGPERMISSION:
                for my $Index ( sort { $a <=> $b } keys %{$NextActivityDialogs} ) {

                    my $CurrentActivityDialogEntityID = $NextActivityDialogs->{$Index};

                    my $CurrentActivityDialog         = $ActivityDialogObject->ActivityDialogGet(
                        ActivityDialogEntityID => $CurrentActivityDialogEntityID,
                        Interface              => 'CustomerInterface',
                    );

                    # create an interface lookup-list
                    my %InterfaceLookup = map { $_ => 1 } @{ $CurrentActivityDialog->{Interface} };

                    next ACTIVITYDIALOGPERMISSION if !$InterfaceLookup{CustomerInterface};

                    if ( $CurrentActivityDialog->{Permission} ) {

                        # performance-boost/cache
                        if ( !defined $PermissionRights{ $CurrentActivityDialog->{Permission} } ) {
                            $PermissionRights{ $CurrentActivityDialog->{Permission} }
                                = $TicketObject->TicketCustomerPermission(
                                Type     => $CurrentActivityDialog->{Permission},
                                TicketID => $Ticket{TicketID},
                                UserID   => $Self->{UserID},
                                );
                        }

                        if ( !$PermissionRights{ $CurrentActivityDialog->{Permission} } ) {
                            next ACTIVITYDIALOGPERMISSION;
                        }
                    }

                    $PermissionActivityDialogList{$Index} = $CurrentActivityDialogEntityID;
                }

                # reduce next activity dialogs to the ones that have permissions
                $NextActivityDialogs = \%PermissionActivityDialogList;

                # get ACL restrictions
                my $ACL = $TicketObject->TicketAcl(
                    Data           => \%PermissionActivityDialogList,
                    TicketID       => $Ticket{TicketID},
                    Action         => $Self->{Action},
                    ReturnType     => 'ActivityDialog',
                    ReturnSubType  => '-',
                    CustomerUserID => $Self->{UserID},
                );

                if ($ACL) {
                    %{$NextActivityDialogs} = $TicketObject->TicketAclData();
                }

                $LayoutObject->Block(
                    Name => 'NextActivities',
                );

                for my $NextActivityDialogKey ( sort { $a <=> $b } keys %{$NextActivityDialogs} ) {

                    my $ActivityDialogData = $ActivityDialogObject->ActivityDialogGet(
                        ActivityDialogEntityID => $NextActivityDialogs->{$NextActivityDialogKey},
                        Interface              => 'CustomerInterface',
                    );
                    $LayoutObject->Block(
                        Name => 'ActivityDialog',
                        Data => {
                            ActivityDialogEntityID => $NextActivityDialogs->{$NextActivityDialogKey},
                            Name                   => $ActivityDialogData->{Name},
                            ProcessEntityID        => $Ticket{$ProcessEntityIDField},
                            TicketID               => $Ticket{TicketID},
                        },
                    );
                }

                if ( !IsHashRefWithData($NextActivityDialogs) ) {
                    $LayoutObject->Block(
                        Name => 'NoActivityDialog',
                        Data => {},
                    );
                }
            }
        }

        if ( !$HideActivity ) {
            $LayoutObject->Block(
                Name => 'MessageResponse',
                Data => {
                    FollowUpAttr => $FollowUpAttr,
                    Avatar       => $UserAvatar->{Avatar} || '/znuny-web/skins/Customer/default/img/supportWhite.svg',
                }
            );
        }
        
        my $HideNextStateByService = $ConfigObject->Get("CustomerPortal::Core::HideNextStateByService");
        my $HideNextStateByState   = $ConfigObject->Get("CustomerPortal::Core::HideNextStateByState");

        $GetParam{FlagShowUpdateTiket} = 0;
        
        # hide the answer button depending on the activity id
        if ( ( $FlagProcess == 0) || ( $FlagProcess == 1 && $HideActivity == 0 ) ) {

            $LayoutObject->Block(
                Name => 'ButtonResponse',
                Data => {},
            );

            if( $ConfigCustomer->{State} && !( $Ticket{State} ~~ @{ $HideNextStateByState } ) ) {

                if( $ConfigCustomer->{State} && !( $Ticket{ServiceID} ~~ @{ $HideNextStateByService } ) ){

                    $LayoutObject->Block(
                        Name => 'FollowUpState',
                        Data => \%Param,
                    );

                    $GetParam{FlagShowUpdateTiket} = 1;
                }
            }
        }

        if($EnablePriorityInMyTickets == 1){
            my %ListPriority = $PriorityObject->PriorityList(
                Valid => 1,
            );

            $Param{Priority} = $LayoutObject->BuildSelection(
                Data       => \%ListPriority,
                Name       => 'PriorityID',
                Class      => "Modernize",
                SelectedID => $Ticket{PriorityID},
            );

            $LayoutObject->Block(
                Name => 'PriorityList',
                Data => \%Param,
            );

            $GetParam{FlagShowUpdateTiket} = 1;
        }

        # Init DynamicField render

        # get the dynamic fields for ticket object
        my $FollowUpDynamicField = $DynamicFieldObject->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => [ 'Ticket', 'Article' ],
            FieldFilter => $FollowUpDynamicFieldFilter || {},
        );

        my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        # reduce the dynamic fields to only the ones that are designed for customer interface
        my @CustomerDynamicFields;
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {            
            
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $IsCustomerInterfaceCapable = $BackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsCustomerInterfaceCapable',
            );
            next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

            push @CustomerDynamicFields, $DynamicFieldConfig;
        }

        $FollowUpDynamicField = \@CustomerDynamicFields;

        # create html strings for all dynamic fields
        my %DynamicFieldHTML;

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

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
                if ( IsHashRefWithData($PossibleValues) ) {

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

            # get field html
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } = $BackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                PossibleValuesFilter => $PossibleValuesFilter,
                Mandatory            => $ConfigCustomer->{FollowUpDynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                ServerError          => '',
                ErrorMessage         => '',
                LayoutObject         => $LayoutObject,
                ParamObject          => $ParamObject,
                AJAXUpdate           => 1,
                UpdatableFields      => $Self->_GetFieldsToUpdate(),
                Value                => $Ticket{'DynamicField_' . $DynamicFieldConfig->{Name}}                
            );
        }

        $Param{DynamicFieldHTML} = \%DynamicFieldHTML;
        
        # Dynamic fields
        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            # skip fields that HTML could not be retrieved
            next DYNAMICFIELD if !IsHashRefWithData(
                $Param{DynamicFieldHTML}->{ $DynamicFieldConfig->{Name} }
            );

            # get the html strings form $Param
            my $DynamicFieldHTML = $Param{DynamicFieldHTML}->{ $DynamicFieldConfig->{Name} };
            
            $LayoutObject->Block(
                Name => 'FollowUpDynamicField',
                Data => {
                    Name  => $DynamicFieldConfig->{Name},
                    Label => $DynamicFieldHTML->{Label},
                    Field => $DynamicFieldHTML->{Field},
                },
            );

            $GetParam{FlagShowUpdateTiket} = 1;
        }

        # End DynamicField render

          

        # get the dynamic fields for ticket object
        my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => ['Ticket'],
            FieldFilter => $DynamicFieldFilter || {},
        );

        # cycle trough the activated Dynamic Fields for ticket object
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{$DynamicField} ) {
            next DYNAMICFIELD if !IsHashRefWithData(\%{$DynamicFieldConfig});

            # skip the dynamic field if is not designed for customer interface
            my $IsCustomerInterfaceCapable = $BackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsCustomerInterfaceCapable',
            );
            next DYNAMICFIELD if !$IsCustomerInterfaceCapable;

            my $Value = $BackendObject->ValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $TicketID,
            );

            next DYNAMICFIELD if !defined $Value;
            next DYNAMICFIELD if $Value eq "";

            # get print string for this dynamic field
            my $ValueStrg = $BackendObject->DisplayValueRender(
                DynamicFieldConfig => $DynamicFieldConfig,
                Value              => $Value,
                ValueMaxChars      => 25,
                LayoutObject       => $LayoutObject,
            );

            my $Label = $DynamicFieldConfig->{Label};

            $LayoutObject->Block(
                Name => 'TicketDynamicField',
                Data => {
                    Label => $Label,
                    DynamicFieldName => "DynamicField_" . $DynamicFieldConfig->{Name}
                },
            );

            if ( $DynamicFieldConfig->{Config}->{Link} ) {
                $LayoutObject->Block(
                    Name => 'TicketDynamicFieldLink',
                    Data => {
                        Value                       => $ValueStrg->{Value},
                        Title                       => $ValueStrg->{Title},
                        Link                        => $DynamicFieldConfig->{Config}->{Link},
                        LinkPreview                 => $DynamicFieldConfig->{Config}->{LinkPreview},
                        $DynamicFieldConfig->{Name} => $ValueStrg->{Value},
                    },
                );
            }
            else {
                $LayoutObject->Block(
                    Name => 'TicketDynamicFieldPlain',
                    Data => {
                        Value => $ValueStrg->{Value},
                        Title => $ValueStrg->{Title},
                        DynamicFieldName => "DynamicField_" . $DynamicFieldConfig->{Name}
                    },
                );
            }
        }

        # To articles of ticket
        my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

        # get all articles of this ticket, that are visible for the customer
        my @ArticleList = $ArticleObject->ArticleList(
            TicketID             => $TicketID,
            IsVisibleForCustomer => 1,
            DynamicFields        => 0,
        );

        # get params
        my $ZoomExpand = $ParamObject->GetParam( Param => 'ZoomExpand' );
        if ( !defined $ZoomExpand ) {
            $ZoomExpand = $ConfigObject->Get('Ticket::Frontend::CustomerTicketZoom')->{CustomerZoomExpand} || '';
        }

        # Expand option
        my $ExpandOption   = ( $ZoomExpand ? 'One'              : 'All' );
        my $ExpandTextDesc = ( $ZoomExpand ? 'Show one article' : 'Show all articles' );
        my $ExpandText     = ( $ZoomExpand ? 'Minimize' : 'Expand' );

        $LayoutObject->Block(
            Name => 'Expand',
            Data => {
                ZoomExpand     => !$ZoomExpand,
                ExpandOption   => $ExpandOption,
                ExpandTextDesc => $ExpandTextDesc,
                ExpandText     => $ExpandText,
                TicketNumber   => $Ticket{TicketNumber},
                %Param,
            },
        );

        my @ArticleBox;
        my $ArticleBackendObject;

        ARTICLEMETADATA:
        for my $ArticleMetaData ( @ArticleList ) {

            next ARTICLEMETADATA if !$ArticleMetaData;
            next ARTICLEMETADATA if !IsHashRefWithData(\%{$ArticleMetaData});
            
            $ArticleBackendObject = $ArticleObject->BackendForArticle( %{$ArticleMetaData} );

            my %ArticleData = $ArticleBackendObject->ArticleGet(
                TicketID  => $TicketID,
                ArticleID => $ArticleMetaData->{ArticleID},
                RealNames => 1,
            );

                      

            next ARTICLEMETADATA if ( !$ArticleMetaData->{ArticleID} );

            # Get channel specific fields
            my %ArticleFields = $LayoutObject->ArticleFields(
                TicketID  => $TicketID,
                ArticleID => $ArticleMetaData->{ArticleID},
            );

            $ArticleData{Subject}      = $ArticleFields{Subject};
            $ArticleData{FromRealname} = $ArticleFields{Sender};

            # Get attachment index.
            my %AtmIndex = $ArticleBackendObject->ArticleAttachmentIndex(
                ArticleID        => $ArticleMetaData->{ArticleID},
                ExcludePlainText => 1,
                ExcludeHTMLBody  => 1,
                ExcludeInline    => 1,
            );

            if ( IsHashRefWithData( \%AtmIndex ) ) {
                $ArticleData{Attachment} = \%AtmIndex;
            }

            push @ArticleBox, \%ArticleData;
        }

        my $AccountedTimeShow = $ConfigObject->Get('Ticket::Frontend::CustomerTicketZoom')->{ZoomTimeDisplay};
        my $ArticleIndex = 1;
        ARTICLETEMPLETE:
        for my $ArticleTemplate ( @ArticleBox ) {

            my $CustomerAge;
            my $SenderTypeClass;

            if ( $ArticleTemplate->{SenderType} eq 'agent' ||  $ArticleTemplate->{SenderType} eq 'system' ) {
                $SenderTypeClass =  'AgentResponseCard';
            }
            else {
                $SenderTypeClass =  'CustomerResponseCard';
            }

            # next article if not createTime
            next ARTICLETEMPLETE if !$ArticleTemplate->{CreateTime};

            # Calculate difference between article create time and now in seconds.
            my $ArticleCreateTimeObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String => $ArticleTemplate->{CreateTime},
                },
            );

            my $Delta = $ArticleCreateTimeObject->Delta(
                DateTimeObject => $Kernel::OM->Create('Kernel::System::DateTime'),
            );

            my $CreateTimeInHours = $LayoutObject->CustomerAge(
                Age   => $Delta->{AbsoluteSeconds},
                Space => ' ',
            );

            # Render article content.
            my $ArticleContent = $LayoutObject->ArticlePreview(
                TicketID  => $TicketID,
                ArticleID => $ArticleTemplate->{ArticleID},
            );

            # Init images get
            my $Content = $LayoutObject->Output(
                Template => '[% Data.HTML %]',
                Data     => {
                    HTML => $ArticleContent,
                },
            );

            my %Data = (
                Content            => $Content,
                ContentAlternative => '',
                ContentID          => '',
                ContentType        => 'text/html; charset="utf-8"',
                Disposition        => "inline",
                FilesizeRaw        => bytes::length($Content),
            );

            my $URL = 'Action=CustomerTicketAttachment;Subaction=HTMLView'
                . ";TicketID=$TicketID;ArticleID=$ArticleTemplate->{ArticleID};FileID=";

            # replace links to inline images in html content
            my %AtmBox = $ArticleBackendObject->ArticleAttachmentIndex(
                ArticleID => $ArticleTemplate->{ArticleID},
                ExcludePlainText => 1,
                ExcludeHTMLBody  => 1,
            );

            # reformat rich text document to have correct charset and links to
            # inline documents

            my $LoadExternalImages = $ParamObject->GetParam(
                Param => 'LoadExternalImages'
            ) || 0;

            # safety check only on customer article
            if ( !$LoadExternalImages && $ArticleTemplate->{SenderType} ne 'customer' ) {
                $LoadExternalImages = 1;
            }

            %Data = $LayoutObject->RichTextDocumentServe(
                Data               => \%Data,
                URL                => $URL,
                Attachments        => \%AtmBox,
                LoadExternalImages => $LoadExternalImages,
            );

            # To remove the html of Znuny
            $Data{Content} =~ s|style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;| "" |g;

            if ( $Data{Content} eq '' ){
                $Data{Content} = $ArticleTemplate->{Body};
            }

            my %IframeArticle;

            # $ZoomExpand = 1;

            # $IframeArticle{Collapse}     = "collapsed";

            # $ZoomExpand = 0;


            # last article
            if ( $ArticleList[-1]->{ArticleID} eq $ArticleTemplate->{ArticleID} || $ZoomExpand ) {

                $IframeArticle{ArticleLink}  = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=CustomerPortalArticleContent;TicketID=$TicketID;ArticleID=$ArticleTemplate->{ArticleID};";
                $IframeArticle{ArticleTitle} = "about:blank";
                $IframeArticle{Accordion}    = "show";
                $IframeArticle{Collapse}     = "";
                $IframeArticle{AriaExpanded} = "true";
                $IframeArticle{ClassIframe}  = 'VisibleFrame';

            }
            else {
                $IframeArticle{ArticleLink}  = "about:blank";
                $IframeArticle{ArticleTitle} = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=CustomerPortalArticleContent;TicketID=$TicketID;ArticleID=$ArticleTemplate->{ArticleID};";
                $IframeArticle{Collapse}     = "collapsed";
                $IframeArticle{AriaExpanded} = "false";
            }

            # check if article should be expanded (visible)
            if ( $ArticleList[-1]->{ArticleID} eq $ArticleTemplate->{ArticleID} || $ZoomExpand ) {
                # $ShownArticles++;
            }

            my ($Email) = $ArticleTemplate->{From} =~ /<(.*)>/;

            my $Avatar = $CustomerPortalLayoutObject->_GetUserAvatar(
                UserEmail => $Email
            );

            my $TypeSender = ( $ArticleTemplate->{SenderType} eq 'customer' ? 'Customer' : 'Agent' );

            my %CommunicationChannel = $CommunicationChannelObject->ChannelGet(
                ChannelID => $ArticleTemplate->{CommunicationChannelID},
            );

            if ( $CommunicationChannel{DisplayName} eq 'Znuny' ) {
                $CommunicationChannel{DisplayName} = 'System';
            }

            my $SenderName = $LayoutObject->{LanguageObject}->Translate( $TypeSender ) . " via " . $LayoutObject->{LanguageObject}->Translate( $CommunicationChannel{DisplayName} );

            my $AccountedTime = $ArticleObject->ArticleAccountedTimeGet(
                ArticleID => $ArticleTemplate->{ArticleID},
            );

            $AccountedTime = $LayoutObject->CustomerAge(
                Age   => $AccountedTime * 60,
                Space => ' ',
            );

            
            my $GetArticleTextDisplay = $ConfigObject->Get('CustomerPortal::Core::ArticleDisplayText');

            my $Preview = $ArticleTemplate->{Body};

            if ( $GetArticleTextDisplay == 2 ){
                $Preview = $ArticleTemplate->{Subject}{Value};
            }
            
            if ($ArticleTemplate->{ArticleID} == $ArticleList[-1]->{ArticleID}){

                my $TempSpl = split(/,/, $ArticleTemplate->{To});

                if ($ArticleTemplate->{Cc} || $TempSpl > 1 ){
                    
                    $LayoutObject->Block(
                        Name => 'ReplayAll',
                        Data => {},
                    );

                }
            }

            my $ScrollBarInMyTickets = $ConfigObject->Get('CustomerPortal::Core::ScrollBarInMyTickets');

            my $StyleScrollBar;
            
            if( $ScrollBarInMyTickets == 1 ){
                $StyleScrollBar = "overflow-y:scroll; height:500px";
            }

            $LayoutObject->Block(
                Name => 'MessageBody',
                Data => {
                    Body           => $ArticleTemplate->{Body},
                    Preview        => $Preview,
                    SenderType     => $SenderTypeClass,
                    SenderName     => $SenderName,
                    FromRealname   => $ArticleTemplate->{FromRealname}{Realname},
                    Age            => $CreateTimeInHours,
                    AccountedTime  => $AccountedTime || '',
                    AccountedTimeShow => $AccountedTimeShow,
                    CreateTime     => $ArticleTemplate->{CreateTime},
                    TicketID       => $TicketID,
                    ArticleID      => $ArticleTemplate->{ArticleID},
                    ArticleContent => $Data{Content},
                    Attachments    => \%AtmBox,
                    URL            => $URL,
                    ArticleLink    => $IframeArticle{ArticleLink},
                    ArticleTitle   => $IframeArticle{ArticleTitle},
                    ClassIframe    => $IframeArticle{ClassIframe},
                    Accordion      => $IframeArticle{Accordion},
                    Collapse       => $IframeArticle{Collapse},
                    AriaExpanded   => $IframeArticle{AriaExpanded},
                    Avatar         => $Avatar->{Avatar} || '/znuny-web/skins/Customer/default/img/supportWhite.svg',
                    StyleScrollBar => $StyleScrollBar,
                    ArticleIndex   => $ArticleIndex,
                },
            );

            $ArticleIndex += 1;

            for my $Attch (keys %AtmBox){

                $LayoutObject->Block(
                    Name => 'MessageBodyAttchPreview',
                    Data => {
                        Link => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=CustomerTicketAttachment;TicketID=$TicketID;ArticleID=$ArticleTemplate->{ArticleID};FileID=$Attch",
                        Filename => $AtmBox{$Attch}{Filename},
                        FilesizeRaw => $AtmBox{$Attch}{FilesizeRaw},
                    }
                );
                
                $LayoutObject->Block(
                    Name => 'MessageBodyAttch',
                    Data => {
                        Link => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=CustomerTicketAttachment;TicketID=$TicketID;ArticleID=$ArticleTemplate->{ArticleID};FileID=$Attch",
                        Filename => $AtmBox{$Attch}{Filename},
                        FilesizeRaw => $AtmBox{$Attch}{FilesizeRaw},
                    }
                );
            }
        }

        $GetParam{TicketID} = $TicketID;

        # add rich text editor
        if ( $LayoutObject->{BrowserRichText} ) {

            # use width defined for this screen

            # send data to JS
            $LayoutObject->AddJSData(
                Key   => 'RichText',
                Value => {
                    Width => "96.7%",
                    Height => '65'
                },
            );
        }

        # Show last tickets CustomerPortal::Core::ShowLastTickets

        my $ShowLastTickets = $ConfigObject->Get("CustomerPortal::Core::ShowLastTickets");

        if ( $ShowLastTickets ) {

            my @LastTicketIDs = $TicketObject->TicketSearch(
                Result            => 'ARRAY',
                Limit             => $ShowLastTickets,
                CustomerUserLogin => $Self->{UserID},
                CustomerUserID    => $Self->{UserID},
                OrderBy           => 'Down',
                SortBy            => 'Age',
            );

            $LayoutObject->Block(
                Name => 'LastTickets',
            );

            TICKET:
            for my $LastTicketID ( @LastTicketIDs ) {

                my %LastTickets = $TicketObject->TicketGet(
                    TicketID      => $LastTicketID,
                    DynamicFields => 0,
                    UserID        => 1,
                );

                if ( grep { $_ eq $LastTickets{Queue} } @{ $HiddeQueues } ) {
                    next TICKET;
                }

                $LayoutObject->Block(
                    Name => 'LastTicketsRow',
                    Data => {
                        Title        => $LastTickets{Title},
                        TicketNumber => $LastTickets{TicketNumber},
                    },
                );
            }
        }

        #  To action title
        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');
        my $OriginalTitle = '';

        if( $ActionTitle->{CustomerPortalTicketZoom} ){
            $OriginalTitle = $ActionTitle->{CustomerPortalTicketZoom};
        }
        else{
            $OriginalTitle = $Ticket{TicketNumber};
        }

        $GetParam{MenuType} = $ConfigObject->Get('CustomerPortal::Core::MenuType');


        # build output
        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $OriginalTitle);
        $Output   .= $LayoutObject->Output(
            Data         => {
                %GetParam,
            },
            TemplateFile => 'CustomerPortalTicketZoom',
        );
        $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }
}

sub _GetNextStates {
    my ( $Self, %Param ) = @_;

    my %NextStates;
    if ( $Param{TicketID} ) {
        %NextStates = $Kernel::OM->Get('Kernel::System::Ticket')->TicketStateList(
            %Param,
            Action         => 'CustomerTicketZoom',
            CustomerUserID => $Self->{UserID},
            Type           => undef,
        );
    }
    return \%NextStates;
}

sub _GetSLASolutionTime {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalObject   = $Kernel::OM->Get('Kernel::System::CustomerPortal');

    # to get SLA Solution
    my %SLASolutionReports = $CustomerPortalObject->SLASolutionGet(
        TN      => $Param{TicketNumber},
        UserID  => 1,
    );

    my %SolutionTimeValues;

    if ( IsHashRefWithData(\%SLASolutionReports) ) {

        my $SolutionTimeSpent = $Kernel::OM->Create(
            'Kernel::System::DateTime',
            ObjectParams => {
                String   => $SLASolutionReports{SolutionTime},
            }
        );

        my $SolutionTimeLimit = $Kernel::OM->Create(
            'Kernel::System::DateTime',
            ObjectParams => {
                String   => $SLASolutionReports{SolutionTimeLimit},
            }
        );

        %SolutionTimeValues = (
            "SolutionTimeLimit"  => $SolutionTimeLimit->ToString(),
            "SolutionTimeSpent"  => $SolutionTimeSpent->ToString(),
        );
    }

    return %SolutionTimeValues;
}

sub _GetSLAFirstResponseTime {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalObject   = $Kernel::OM->Get('Kernel::System::CustomerPortal');

    # to get SLA Solution
    my %SLAResponseReports = $CustomerPortalObject->SLAResponseGet(
        TN      => $Param{TicketNumber},
        UserID  => 1,
    );

    my %FirstResponseTimeValues;

    if ( IsHashRefWithData(\%SLAResponseReports) ) {

        my $FirstResponseTimeSpent = $Kernel::OM->Create(
            'Kernel::System::DateTime',
            ObjectParams => {
                String   => $SLAResponseReports{ResponseTime},
            }
        );

        my $FirstResponseTimeLimit = $Kernel::OM->Create(
            'Kernel::System::DateTime',
            ObjectParams => {
                String   => $SLAResponseReports{ResponseTimeLimit},
            }
        );

        %FirstResponseTimeValues = (
            "FirstResponseTimeLimit"  => $FirstResponseTimeLimit->ToString(),
            "FirstResponseTimeSpent"  => $FirstResponseTimeSpent->ToString(),
        );
    }

    return %FirstResponseTimeValues;
}

sub _GetFieldsToUpdate {
    my ( $Self, %Param ) = @_;

    my @UpdatableFields;

    # set the fields that can be updatable via AJAXUpdate
    if ( !$Param{OnlyDynamicFields} ) {
        @UpdatableFields = qw( ServiceID SLAID PriorityID StateID);
    }

    my $Config                     = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Self->{Action}");
    my $FollowUpDynamicFieldFilter = $Config->{FollowUpDynamicField};

    # get the dynamic fields for ticket object
    my $FollowUpDynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $FollowUpDynamicFieldFilter || {},
    );

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$FollowUpDynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $IsACLReducible = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsACLReducible',
        );
        next DYNAMICFIELD if !$IsACLReducible;

        push @UpdatableFields, 'DynamicField_' . $DynamicFieldConfig->{Name};
    }

    return \@UpdatableFields;
}

sub _ConvertSecondsToHHMMSS {

	my $Time = $_[0];

    if($_[0] < 0){
        $_[0] = $_[0] *-1;
    }

    my $hourz=int($_[0]/3600);

    my $leftover=$_[0] % 3600;

    my $minz=int($leftover/60);

    my $secz=int($leftover % 60);

    if ( $Time < 0 ){
		return sprintf ("-%02d:%02d:%02d", $hourz,$minz,$secz)
	}
	else{
		return sprintf ("%02d:%02d:%02d", $hourz,$minz,$secz)
	}
}

1;