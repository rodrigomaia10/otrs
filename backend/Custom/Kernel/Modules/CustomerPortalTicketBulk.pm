# --
# Kernel/Modules/CustomerPortalTicketBulk.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * ccresencio@serviceup.com.br
# * jsantos@serviceup.com.br
# * jguedes@serviceup.com.br
# -- 

package Kernel::Modules::CustomerPortalTicketBulk;

use strict;
use warnings;

use utf8;

use Encode qw(decode encode);
use File::Basename;

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
    
    my $ParamObject                = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject               = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject               = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomerUserObject         = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my $ConfigBulk = $ConfigObject->Get("CustomerPortal::Core::TicketBulk");



    if ( $Self->{Subaction} eq 'AJAXIgnoreLockedTicketIDs' ) {

        # my @ValidTicketIDs;
        # my @IgnoreLockedTicketIDs;
        # my $TicketIDs = $ParamObject->GetParam( Param => 'TicketIDs' );
        # if ($TicketIDs) {
        #     $TicketIDs = $Kernel::OM->Get('Kernel::System::JSON')->Decode(
        #         Data => $TicketIDs
        #     );

        # }

        # my $Config        = $ConfigObject->Get("Ticket::Frontend::$Self->{Action}");
        # my @TicketIDArray = split( /;/, $TicketIDs );

        # if ( $Config->{RequiredLock} ) {
        #     for my $TicketID (@TicketIDArray) {
        #         if ( $TicketObject->TicketLockGet( TicketID => $TicketID ) ) {
        #             my $AccessOk = $TicketObject->OwnerCheck(
        #                 TicketID => $TicketID,
        #                 OwnerID  => $Self->{UserID},
        #             );
        #             if ($AccessOk) {
        #                 push @ValidTicketIDs, $TicketID;
        #             }
        #             else {
        #                 push @IgnoreLockedTicketIDs, $TicketID;
        #             }
        #         }
        #         else {
        #             push @ValidTicketIDs, $TicketID;
        #         }
        #     }
        # }
        # else {
        #     @ValidTicketIDs = @TicketIDArray;
        # }

        # my %DialogWarning;
        # my @IgnoreLockedTicketNumber;
        # if ( @IgnoreLockedTicketIDs && !@ValidTicketIDs ) {
        #     for my $TicketID (@IgnoreLockedTicketIDs) {
        #         my $TicketNumber = $TicketObject->TicketNumberLookup(
        #             TicketID => $TicketID,
        #         );
        #         push @IgnoreLockedTicketNumber, $TicketNumber;

        #     }

        #     if ( $Config->{RequiredLock} ) {
        #         if ( scalar @IgnoreLockedTicketNumber > 1 ) {
        #             %DialogWarning = (
        #                 Message => $LayoutObject->{LanguageObject}->Translate(
        #                     "The following tickets were ignored because they are locked by another agent or you don't have write access to tickets: %s.",
        #                     join( ", ", @IgnoreLockedTicketNumber ),
        #                 )
        #             );
        #         }
        #         else {
        #             %DialogWarning = (
        #                 Message => $LayoutObject->{LanguageObject}->Translate(
        #                     "The following ticket was ignored because it is locked by another agent or you don't have write access to ticket: %s.",
        #                     join( ", ", @IgnoreLockedTicketNumber ),
        #                 )
        #             );
        #         }
        #     }
        #     else {
        #         %DialogWarning = (
        #             Message => Translatable('You need to select at least one ticket.'),
        #         );
        #     }
        # }

        # return $LayoutObject->Attachment(
        #     ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        #     Content     => $Kernel::OM->Get('Kernel::System::JSON')->Encode(
        #         Data => {
        #             Message => $DialogWarning{Message} || '',
        #         }
        #     ),
        #     Type    => 'inline',
        #     NoCache => 1,
        # );
    }
    
    if ( !$Self->{Subaction} || $Self->{Subaction} eq 'Do' ) {

        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => 'Bulk' );

        # check if bulk feature is enabled
        if ( 1 == 2 ) {

            $LayoutObject->Block(
                Name => 'Error',
                Data => {
                    Message => 'Bulk feature is not enabled!',
                    Comment => 'Bulk feature is not enabled!',
                },
            );

            # build output
            

            $Output .= $LayoutObject->Output(
                TemplateFile => "CustomerPortalTicketBulk",
                # Data         => \%Message,
            );

            $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

            return $Output;
        }

        # get involved tickets, filtering empty TicketIDs
        my @ValidTicketIDs;
        my @IgnoreLockedTicketIDs;
        my @TicketIDs = sort grep {$_}
            $ParamObject->GetArray( Param => 'TicketID' );



        TICKET:
        for my $TicketID ( @TicketIDs ) {

            my $Access = $TicketObject->TicketCustomerPermission(
                Type     => 'ro',
                TicketID => $TicketID,
                UserID   => $Self->{UserID},
            );

            if (!$Access) {
                next TICKET;
            }

            push @ValidTicketIDs, $TicketID;
        }

        # # make the ticket IDs available in javascript
        # $LayoutObject->AddJSData(
        #     Key   => 'ValidTicketIDs',
        #     Value => \@ValidTicketIDs,
        # );

        # # declare the variables for all the parameters
        my %Error;
        my %Time;
        my %GetParam;

        # my %DynamicFieldValues;
        # my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

        # # cycle trough the activated dynamic fields of this screen
        # DYNAMICFIELD:
        # for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        #     next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        #     $DynamicFieldValues{ $DynamicFieldConfig->{Name} } = $DynamicFieldBackendObject->EditFieldValueGet(
        #         DynamicFieldConfig => $DynamicFieldConfig,
        #         ParamObject        => $ParamObject,
        #         LayoutObject       => $LayoutObject,
        #     );
        # }

        # # convert dynamic field values into a structure for ACLs
        # my %DynamicFieldACLParameters;
        # DYNAMICFIELD:
        # for my $DynamicField ( sort keys %DynamicFieldValues ) {
        #     next DYNAMICFIELD if !$DynamicField;
        #     next DYNAMICFIELD if !$DynamicFieldValues{$DynamicField};

        #     $DynamicFieldACLParameters{ 'DynamicField_' . $DynamicField } = $DynamicFieldValues{$DynamicField};
        # }
        # $GetParam{DynamicField} = \%DynamicFieldACLParameters;

        # # get needed objects
        my $StateObject = $Kernel::OM->Get('Kernel::System::State');

        # get all parameters and check for errors
        if ( $Self->{Subaction} eq 'Do' ) {

            # challenge token check for write action
            $LayoutObject->ChallengeTokenCheck();

            # get all parameters
            for my $Key (
                qw(ServiceID OwnerID Owner ResponsibleID Responsible PriorityID Priority QueueID Queue Subject
                Body IsVisibleForCustomer TypeID StateID State MergeToSelection MergeTo LinkTogether
                EmailSubject EmailBody EmailTimeUnits NewStateID
                LinkTogetherParent Unlock MergeToChecked MergeToOldestChecked)
                )
            {
                $GetParam{$Key} = $ParamObject->GetParam( Param => $Key ) || '';
            }

        #     for my $Key (qw(TimeUnits)) {
        #         $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
        #     }

            # get time stamp based on user time zone
            %Time = $LayoutObject->TransformDateSelection(
                Year   => $ParamObject->GetParam( Param => 'Year' ),
                Month  => $ParamObject->GetParam( Param => 'Month' ),
                Day    => $ParamObject->GetParam( Param => 'Day' ),
                Hour   => $ParamObject->GetParam( Param => 'Hour' ),
                Minute => $ParamObject->GetParam( Param => 'Minute' ),
            );

        #     if ( $GetParam{'MergeToSelection'} eq 'OptionMergeTo' ) {
        #         $GetParam{'MergeToChecked'} = 'checked';
        #     }
        #     elsif ( $GetParam{'MergeToSelection'} eq 'OptionMergeToOldest' ) {
        #         $GetParam{'MergeToOldestChecked'} = 'checked';
        #     }

        #     # check some stuff
        #     if (
        #         $GetParam{Subject}
        #         && $ConfigObject->Get('Ticket::Frontend::AccountTime')
        #         && $ConfigObject->Get('Ticket::Frontend::NeedAccountedTime')
        #         && $GetParam{TimeUnits} eq ''
        #         )
        #     {
        #         $Error{'TimeUnitsInvalid'} = 'ServerError';
        #     }

        #     if (
        #         $GetParam{EmailSubject}
        #         && $ConfigObject->Get('Ticket::Frontend::AccountTime')
        #         && $ConfigObject->Get('Ticket::Frontend::NeedAccountedTime')
        #         && $GetParam{EmailTimeUnits} eq ''
        #         )
        #     {
        #         $Error{'EmailTimeUnitsInvalid'} = 'ServerError';
        #     }

            # Body and Subject must both be filled in or both be empty
            if ( $GetParam{Subject} eq '' && $GetParam{Body} ne '' ) {
                $Error{'SubjectInvalid'} = 'ServerError';
            }
            if ( $GetParam{Subject} ne '' && $GetParam{Body} eq '' ) {
                $Error{'BodyInvalid'} = 'ServerError';
            }

        #     # Email Body and Email Subject must both be filled in or both be empty
        #     if ( $GetParam{EmailSubject} eq '' && $GetParam{EmailBody} ne '' ) {
        #         $Error{'EmailSubjectInvalid'} = 'ServerError';
        #     }
        #     if ( $GetParam{EmailSubject} ne '' && $GetParam{EmailBody} eq '' ) {
        #         $Error{'EmailBodyInvalid'} = 'ServerError';
        #     }

            # check if pending date must be validated
            if ( $GetParam{NewStateID}  ) {

                my %StateData = $StateObject->StateGet(
                    ID => $GetParam{NewStateID},
                );
                
                if ( $StateData{TypeName} =~ /^pending/i ) {

                    # create datetime object
                    my $PendingDateTimeObject = $Kernel::OM->Create(
                        'Kernel::System::DateTime',
                        ObjectParams => {
                            %Time,
                            Second => 0,
                        },
                    );

                    # get current system epoch
                    my $CurSystemDateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
                    if (
                        !$PendingDateTimeObject
                        || $PendingDateTimeObject < $CurSystemDateTimeObject
                        )
                    {
                        $Error{'DateInvalid'} = 'ServerError';
                    }
                }
            }

        }

        # # process tickets
        my @TicketIDSelected;
        # my $LockedTickets = '';
        my $ActionFlag    = 0;
        # $Param{TicketsWereLocked} = 0;

        my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

        TICKETID:
        for my $TicketID (@ValidTicketIDs) {

            my %Ticket = $TicketObject->TicketGet(
                TicketID      => $TicketID,
                DynamicFields => 0,
            );

            # do some actions on tickets
            if ( ( $Self->{Subaction} eq 'Do' ) && ( !%Error ) ) {

                # challenge token check for write action
                $LayoutObject->ChallengeTokenCheck();

                # add note
                my $ArticleID;
                if ( $GetParam{'Subject'} && $GetParam{'Body'} ) {

                    my $MimeType = 'text/plain';

                    if ( $LayoutObject->{BrowserRichText} ) {
                        $MimeType = 'text/html';

                        # verify html document
                        $GetParam{'Body'} = $LayoutObject->RichTextDocumentComplete(
                            String => $GetParam{'Body'},
                        );
                    }
                    my $InternalArticleBackendObject = $ArticleObject->BackendForChannel( ChannelName => 'Internal' );

                    $ArticleID = $InternalArticleBackendObject->ArticleCreate(
                        TicketID             => $TicketID,
                        SenderType           => 'agent',
                        IsVisibleForCustomer => 1,
                        From                 => "\"$Self->{UserFullname}\" <$Self->{UserEmail}>",
                        Subject              => $GetParam{'Subject'},
                        Body                 => $GetParam{'Body'},
                        MimeType             => $MimeType,
                        Charset              => $LayoutObject->{UserCharset},
                        UserID               => 1,
                        HistoryType          => 'AddNote',
                        HistoryComment       => '%%Bulk',
                    );
                }

                if ( $ConfigBulk->{State} && $GetParam{NewStateID} ) {

                    $TicketObject->TicketStateSet(
                        TicketID     => $TicketID,
                        StateID      => $GetParam{NewStateID},
                        UserID       => 1,
                    );

                    # unlock the ticket after close
                    my %StateData = $StateObject->StateGet(
                        ID => $GetParam{NewStateID},
                    );

                    # set unlock on close state
                    if ( $StateData{TypeName} =~ /^close/i ) {
                        $TicketObject->TicketLockSet(
                            TicketID => $TicketID,
                            Lock     => 'unlock',
                            UserID   => 1,
                        );
                    }

                    # set pending time on pending state
                    elsif ( $StateData{TypeName} =~ /^pending/i ) {

                        # set pending time
                        $TicketObject->TicketPendingTimeSet(
                            UserID   => 1,
                            TicketID => $TicketID,
                            %Time,
                        );
                    }

                    my $Success = $TicketObject->HistoryAdd(
                        Name         => 'Status changed through portal mass action by client user ' . $Self->{UserFullname},
                        HistoryType  => 'Misc',
                        TicketID     => $TicketID,
                        CreateUserID => 1,
                    );

                    # aqui
                }

                $ActionFlag = 1;
            }
        }

        # # notify user about actions (errors)
        # if (@TicketsWithError) {
        #     my $NotificationError = $LayoutObject->{LanguageObject}->Translate(
        #         "The following tickets were ignored because they are locked by another agent or you don't have write access to these tickets: %s.",
        #         join( ", ", @TicketsWithError ),
        #     );

        #     $Output .= $LayoutObject->Notify(
        #         Priority => 'Error',
        #         Data     => $NotificationError,
        #     );
        # }

        # # notify user about actions (notices)
        # if (@TicketsWithLockNotice) {
        #     my $NotificationNotice = $LayoutObject->{LanguageObject}->Translate(
        #         "The following tickets were locked: %s.",
        #         join( ", ", @TicketsWithLockNotice ),
        #     );

        #     $Output .= $LayoutObject->Notify(
        #         Priority => 'Notice',
        #         Data     => $NotificationNotice,
        #     );
        # }

        # redirect
        if ($ActionFlag) {

        #     if ( IsArrayRefWithData( \@NonUpdatedTickets ) ) {
        #         my $NonUpdatedTicketsString = join ', ', @NonUpdatedTickets;
        #         $Kernel::OM->Get('Kernel::System::Cache')->Set(
        #             Type  => 'Ticket',
        #             TTL   => 60,
        #             Key   => 'NonUpdatedTicketsString-' . $Self->{UserID},
        #             Value => $NonUpdatedTicketsString,
        #         );
        #     }

        #     my $DestURL = defined $MainTicketID
        #         ? "Action=AgentTicketZoom;TicketID=$MainTicketID"
        #         : ( $Self->{LastScreenOverview} || 'Action=AgentDashboard' );

            my $DestURL = $Self->{LastScreenOverview} . ';BulkStatus=1';

            return $LayoutObject->PopupClose(
                URL => $DestURL,
            );
        }

        $Output .= $Self->_Mask(
            %Param,
            %GetParam,
            # %Time,
            TicketIDs        => \@ValidTicketIDs,
            # LockedTickets    => $LockedTickets,
            # Errors           => \%Error,
            # BulkModules      => \@BulkModules,
            # DynamicFieldHTML => \%DynamicFieldHTML,
        );
        $Output .= $LayoutObject->Footer(
            Type => 'Small',
        );
        return $Output;

    }

    return 1;


}

sub _Mask {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    # prepare errors!
    if ( $Param{Errors} ) {
        for my $KeyError ( sort keys %{ $Param{Errors} } ) {
            $Param{$KeyError} = $LayoutObject->Ascii2Html( Text => $Param{Errors}->{$KeyError} );
        }
    }

    $LayoutObject->Block(
        Name => 'BulkAction',
        Data => \%Param,
    );

    $LayoutObject->Block(
        Name => 'CancelClosePopup',
        Data => {%Param},
    );

    # remember ticket ids
    if ( $Param{TicketIDs} ) {
        for my $TicketID ( @{ $Param{TicketIDs} } ) {
            $LayoutObject->Block(
                Name => 'UsedTicketID',
                Data => {
                    TicketID => $TicketID,
                },
            );
        }
    }

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # my $Config = $ConfigObject->Get("Ticket::Frontend::$Self->{Action}");

    # $Param{IsVisibleForCustomer} //= $Config->{IsVisibleForCustomerDefault} // 0;

    my $ConfigBulk = $ConfigObject->Get("CustomerPortal::Core::TicketBulk");

    # build next states string
    if ( $ConfigBulk->{State} ) {

        my $StateObject = $Kernel::OM->Get('Kernel::System::State');

        my %List = $StateObject->StateList(
            UserID => 1,
        );

        my %StateList;

        my %Wanted = map { $_ => 1 } @{ $ConfigBulk->{State} };

        for my $ID ( keys %List ) {
            if ( $Wanted{ $List{$ID} } ) {
                $StateList{$ID} = $List{$ID};
            }
        }

        $Param{NextStatesStrg} = $LayoutObject->BuildSelection(
            Data => \%StateList,
            Name => 'NewStateID',
            PossibleNone => 1,
            Class => 'Modernize',
        );

        $LayoutObject->Block(
            Name => 'State',
            Data => \%Param,
        );


        STATE_ID:
        for my $StateID ( sort keys %StateList ) {
            next STATE_ID if !$StateID;
            my %StateData = $StateObject->StateGet( ID => $StateID );
            next STATE_ID if $StateData{TypeName} !~ /pending/i;
            $Param{DateString} = $LayoutObject->BuildDateSelection(
                %Param,
                Format               => 'DateInputFormatLong',
                DiffTime             => $ConfigObject->Get('Ticket::Frontend::PendingDiffTime') || 0,
                Class                => $Param{Errors}->{DateInvalid} || '',
                Validate             => 1,
                ValidateDateInFuture => 1,
            );
            $LayoutObject->Block(
                Name => 'StatePending',
                Data => \%Param,
            );
            last STATE_ID;
        }
    }

    # # types
    # if ( $ConfigObject->Get('Ticket::Type') && $Config->{TicketType} ) {
    #     my %TypeList = $Self->_GetTypes(
    #         %Param,
    #         Action => $Self->{Action},
    #         UserID => $Self->{UserID},
    #     );
    #     $Param{TypeStrg} = $LayoutObject->BuildSelection(
    #         Data         => \%TypeList,
    #         PossibleNone => 1,
    #         Name         => 'TypeID',
    #         SelectedID   => $Param{TypeID},
    #         Sort         => 'AlphanumericValue',
    #         Translation  => 0,
    #         Class        => 'Modernize',
    #     );
    #     $LayoutObject->Block(
    #         Name => 'Type',
    #         Data => {%Param},
    #     );
    # }

    # # owner list
    # if ( $Config->{Owner} ) {
    #     my %OwnerList = $Self->_GetOwners(
    #         %Param,
    #         Action => $Self->{Action},
    #         UserID => $Self->{UserID},
    #     );
    #     $Param{OwnerStrg} = $LayoutObject->BuildSelection(
    #         Data         => \%OwnerList,
    #         Name         => 'OwnerID',
    #         Translation  => 0,
    #         SelectedID   => $Param{OwnerID},
    #         PossibleNone => 1,
    #         Class        => 'Modernize',
    #     );
    #     $LayoutObject->Block(
    #         Name => 'Owner',
    #         Data => \%Param,
    #     );
    # }

    # # responsible list
    # if ( $ConfigObject->Get('Ticket::Responsible') && $Config->{Responsible} ) {
    #     my %ResponsibleList = $Self->_GetResponsibles(
    #         %Param,
    #         Action => $Self->{Action},
    #         UserID => $Self->{UserID},
    #     );
    #     $Param{ResponsibleStrg} = $LayoutObject->BuildSelection(
    #         Data         => \%ResponsibleList,
    #         PossibleNone => 1,
    #         Name         => 'ResponsibleID',
    #         Translation  => 0,
    #         SelectedID   => $Param{ResponsibleID},
    #         Class        => 'Modernize',
    #     );
    #     $LayoutObject->Block(
    #         Name => 'Responsible',
    #         Data => \%Param,
    #     );
    # }

    # # build move queue string
    # my %QueueList = $Self->_GetQueues(
    #     %Param,
    #     Type   => 'move_into',
    #     UserID => $Self->{UserID},
    #     Action => $Self->{Action},
    # );
    # $Param{MoveQueuesStrg} = $LayoutObject->AgentQueueListOption(
    #     Data           => { %QueueList, '' => '-' },
    #     Multiple       => 0,
    #     Size           => 0,
    #     Name           => 'QueueID',
    #     OnChangeSubmit => 0,
    #     Class          => 'Modernize',
    # );

    # # get priority
    # if ( $Config->{Priority} ) {
    #     my %Priority;
    #     my %PriorityList = $Self->_GetPriorities(
    #         %Param,
    #         UserID => $Self->{UserID},
    #         Action => $Self->{Action},
    #     );
    #     if ( !$Config->{PriorityDefault} ) {
    #         $PriorityList{''} = '-';
    #     }
    #     if ( !$Param{PriorityID} ) {
    #         if ( $Config->{PriorityDefault} ) {
    #             $Priority{SelectedValue} = $Config->{PriorityDefault};
    #         }
    #     }
    #     else {
    #         $Priority{SelectedID} = $Param{PriorityID};
    #     }
    #     $Param{PriorityStrg} = $LayoutObject->BuildSelection(
    #         Data => \%PriorityList,
    #         Name => 'PriorityID',
    #         %Priority,
    #         Class => 'Modernize',

    #     );
    #     $LayoutObject->Block(
    #         Name => 'Priority',
    #         Data => \%Param,
    #     );
    # }

    # # show time accounting box
    # if ( $ConfigObject->Get('Ticket::Frontend::AccountTime') ) {
    #     my $IsTimeUnitsRequired = $ConfigObject->Get('Ticket::Frontend::NeedAccountedTime');
    #     $LayoutObject->AddJSData(
    #         Key   => 'TimeUnitsRequired',
    #         Value => $IsTimeUnitsRequired || '',
    #     );

    #     my $TimeUnitsInputType = $ConfigObject->Get('Ticket::Frontend::AccountTimeType') // 'Text';
    #     $LayoutObject->AddJSData(
    #         Key   => 'TimeUnitsInputType',
    #         Value => $TimeUnitsInputType,
    #     );

    #     $Param{TimeUnitsBlock} = $LayoutObject->TimeUnits(
    #         ID        => 'TimeUnits',
    #         Name      => 'TimeUnits',
    #         TimeUnits => $Param{TimeUnits},
    #     );

    #     $LayoutObject->Block(
    #         Name => 'TimeUnits',
    #         Data => \%Param,
    #     );

    #     $Param{EmailTimeUnitsBlock} = $LayoutObject->TimeUnits(
    #         ID        => 'EmailTimeUnits',
    #         Name      => 'EmailTimeUnits',
    #         TimeUnits => $Param{EmailTimeUnits},
    #     );
    #     $LayoutObject->Block(
    #         Name => 'EmailTimeUnits',
    #         Data => \%Param,
    #     );
    # }

    # $Param{LinkTogetherYesNoOption} = $LayoutObject->BuildSelection(
    #     Data       => $ConfigObject->Get('YesNoOptions'),
    #     Name       => 'LinkTogether',
    #     SelectedID => $Param{LinkTogether} // 0,
    #     Class      => 'Modernize',
    # );

    # $Param{UnlockYesNoOption} = $LayoutObject->BuildSelection(
    #     Data       => $ConfigObject->Get('YesNoOptions'),
    #     Name       => 'Unlock',
    #     SelectedID => $Param{Unlock} // 1,
    #     Class      => 'Modernize',
    # );

    # add rich text editor for note & email
    if ( $LayoutObject->{BrowserRichText} ) {

        # use height/width defined for this screen
        $Param{RichTextHeight} = 100;
        $Param{RichTextWidth}  = '75%';

        # set up rich text editor
        $LayoutObject->SetRichTextParameters(
            Data => \%Param,
        );
    }

    # # reload parent window
    # if ( $Param{TicketsWereLocked} ) {

    #     my $URL = $Self->{LastScreenOverview};

    #     # add session if no cookies are enabled
    #     if ( $Self->{SessionID} && !$Self->{SessionIDCookie} ) {
    #         $URL .= ';' . $Self->{SessionName} . '=' . $Self->{SessionID};
    #     }

    #     $LayoutObject->AddJSData(
    #         Key   => 'TicketBulkURL',
    #         Value => $LayoutObject->{Baselink} . $URL,
    #     );

    #     # show undo&close link
    #     $LayoutObject->Block(
    #         Name => 'UndoClosePopup',
    #         Data => {%Param},
    #     );
    # }
    # else {

    #     # show cancel&close link
    #     $LayoutObject->Block(
    #         Name => 'CancelClosePopup',
    #         Data => {%Param},
    #     );
    # }

    # my @DynamicFieldNames;
    # my %DynamicFieldConfigs;

    # # cycle trough the activated dynamic fields of this screen
    # DYNAMICFIELD:
    # for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
    #     next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

    #     # skip fields for which HTML could not be retrieved
    #     if ( !IsHashRefWithData( $Param{DynamicFieldHTML}->{ $DynamicFieldConfig->{Name} } ) ) {
    #         next DYNAMICFIELD;
    #     }

    #     # get HTML strings from ParamObject
    #     my $IsChecked         = 'false';
    #     my $RequireActivation = 'false';
    #     my $DynamicFieldHTML  = $Param{DynamicFieldHTML}->{ $DynamicFieldConfig->{Name} };

    #     if ( $Config->{DynamicFieldRequireActivation} ) {
    #         $RequireActivation = 'true';
    #         my $DynamicFieldSet = $ParamObject->GetParam(
    #             Param => 'DynamicField_' . $DynamicFieldConfig->{Name} . 'Used'
    #         );

    #         # set DynamicField_NAMEUsed checkbox to true if it is set before or if mandatory (2)
    #         if ( $DynamicFieldSet || $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2 ) {
    #             $IsChecked = 'true';
    #         }
    #     }

    #     $LayoutObject->Block(
    #         Name => 'DynamicField',
    #         Data => {
    #             Name  => $DynamicFieldConfig->{Name},
    #             Label => $DynamicFieldHTML->{Label},
    #             Field => $DynamicFieldHTML->{Field},
    #         },
    #     );

    #     $DynamicFieldConfigs{ 'DynamicField_' . $DynamicFieldConfig->{Name} } = {
    #         Name              => $DynamicFieldConfig->{Name},
    #         RequireActivation => $RequireActivation || 'false',
    #         IsChecked         => $IsChecked || 'false',
    #     };

    #     push @DynamicFieldNames, 'DynamicField_' . $DynamicFieldConfig->{Name};
    # }

    # # send data to JS
    # $LayoutObject->AddJSData(
    #     Key   => 'DynamicFieldNames',
    #     Value => \@DynamicFieldNames,
    # );
    # $LayoutObject->AddJSData(
    #     Key   => 'DynamicFieldConfigs',
    #     Value => \%DynamicFieldConfigs,
    # );

    # my $TreeView = 0;
    # if ( $ConfigObject->Get('Ticket::Frontend::ListType') eq 'tree' ) {
    #     $TreeView = 1;
    # }

    # # services
    # if ( $ConfigObject->Get('Ticket::Service') && $Config->{Service} ) {
    #     my $Services = $Self->_GetServices(
    #         %Param,
    #         TicketIDs => $Param{TicketIDs},
    #         QueueID   => $Param{QueueID},
    #         UserID    => $Self->{UserID},
    #     );

    #     # reset previous ServiceID to reset SLA-List if no service is selected
    #     if ( !$Param{ServiceID} || !$Services->{ $Param{ServiceID} } ) {
    #         $Param{ServiceID} = '';
    #     }

    #     my $CSSClass = "Modernize " . ( $Config->{ServiceMandatory} ? 'Validate_Required ' : '' );

    #     $Param{ServiceStrg} = $LayoutObject->BuildSelection(
    #         Data         => $Services,
    #         Name         => 'ServiceID',
    #         SelectedID   => $Param{ServiceID},
    #         Class        => $CSSClass,
    #         PossibleNone => 1,
    #         TreeView     => $TreeView,
    #         Sort         => 'TreeView',
    #         Translation  => 0,
    #         Max          => 200,
    #     );

    #     $LayoutObject->Block(
    #         Name => 'Service',
    #         Data => {
    #             ServiceMandatory => $Config->{ServiceMandatory} || 0,
    #             %Param,
    #         },
    #     );
    # }

    # my @BulkModules = @{ $Param{BulkModules} };

    # # call Display() in all ticket bulk modules
    # if (@BulkModules) {

    #     my @BulkModuleContent;

    #     MODULEOBJECT:
    #     for my $ModuleObject (@BulkModules) {
    #         next MODULEOBJECT if !$ModuleObject->can('Display');

    #         my $ModuleContent = $ModuleObject->Display(
    #             Errors => $Param{Errors},
    #             UserID => $Self->{UserID},
    #         );

    #         push @BulkModuleContent, $ModuleContent;
    #     }

    #     $Param{BulkModuleContent} = \@BulkModuleContent;
    # }

    # get output back
    return $LayoutObject->Output(
        TemplateFile => 'CustomerPortalTicketBulk',
        Data         => \%Param,
    );
}
