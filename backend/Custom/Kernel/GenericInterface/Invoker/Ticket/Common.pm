# --
# Kernel/GenericInterface/Invoker/Ticket/Common.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * ccresencio@serviceup.com.br
# * jsantos@serviceup.com.br
# * dparavani@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::GenericInterface::Invoker::Ticket::Common;

use strict;
use warnings;

# prevent 'Used once' warning for Kernel::OM
use Kernel::System::ObjectManager;

our $ObjectManagerDisabled = 1;

use MIME::Base64;
use Storable;
use Kernel::System::VariableCheck qw(:all);

=head1 NAME

Kernel::GenericInterface::Invoker::Ticket::Common - common Invoker functions

=head1 DESCRIPTION

All common functions for Tickets.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    use Kernel::GenericInterface::Invoker::Ticket::Common;

    my $TicketCommonObject = Kernel::GenericInterface::Invoker::Ticket::Common->new(
        DebuggerObject     => $DebuggerObject,
        Invoker            => 'TicketCreate', # example
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (qw( DebuggerObject Invoker WebserviceID )) {
        if ( !$Param{$Needed} ) {
            return {
                Success      => 0,
                ErrorMessage => "Got no $Needed!"
            };
        }

        $Self->{$Needed} = $Param{$Needed};
    }

    return $Self;
}

=head2 PrepareRequest()

prepare the invocation of the configured remote web-service.

    my $Result = $InvokerObject->PrepareRequest(
        Data => {                                               # data payload
            TicketID => 123,
            ArticleID => 123,                                   # optional
        },
    );

Result example:
    {
        Data => {
            Ticket => {
                Title         => 'some ticket title',
                Queue         => 'some queue name',
                Lock          => 'some lock name',              # optional
                Type          => 'some type name',              # optional
                Service       => 'some service name',           # optional
                SLA           => 'some SLA name',               # optional
                State         => 'some state name',
                Priority      => 'some priority name',
                Owner         => 'some user login',             # optional
                Responsible   => 'some user login',             # optional
                CustomerUser  => 'some customer user login',
                PendingTime {       # optional
                    Year   => 2011,
                    Month  => 12
                    Day    => 03,
                    Hour   => 23,
                    Minute => 05,
                },
            },
            Article => {
                SenderType       => 'some sender type name',    # optional
                AutoResponseType => 'some auto response type',  # optional
                From             => 'some from string',         # optional
                Subject          => 'some subject',
                Body             => 'some body'

                ContentType      => 'some content type',        # ContentType or MimeType and Charset is requieed
                MimeType         => 'some mime type',
                Charset          => 'some charset',
                TimeUnit         => 123,                        # optional
            },

            DynamicField => [                                   # optional
                {
                    Name   => 'some name',
                    Value  => 'Value',                          # value type depends on the dynamic field
                },
                # ...
            ],

            Attachment => [
                {
                    Content     => 'content'                    # base64 encoded
                    ContentType => 'some content type'
                    Filename    => 'some fine name'
                },
                # ...
            ],
        },
    };

=cut

sub PrepareRequest {
    my ( $Self, %Param ) = @_;

    # TODO: Add Authentification for Request:
    # UserLogin
    # CustomerUserLogin
    # SessionID
    # Password

    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $CustomerUserObject        = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject             = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    # my $ArticleBackendObject      = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::MyBackend');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check needed stuff
    if ( !IsHashRefWithData( $Param{Data} ) ) {
        return $Self->ReturnError(
            ErrorCode    => 'TicketCreate.MissingData',
            ErrorMessage => $Self->{Invoker} . ": The request data is invalid!",
        );
    }

    if ( !$Param{Data}->{TicketID} && !$Param{Data}->{TicketNumber} ) {
        return $Self->ReturnError(
            ErrorCode    => 'TicketCreate.MissingTicketNumber',
            ErrorMessage => $Self->{Invoker} . ": TicketID or TicketNumber is required!",
        );
    }

    # check TicketID
    my $TicketID  = $Param{Data}->{TicketID};
    my $ArticleID = $Param{Data}->{ArticleID};

    if ( !$TicketID ) {
        return $Self->ReturnError(
            ErrorCode    => 'TicketCreate.MissingTicketID',
            ErrorMessage => $Self->{Invoker} . ": User does not have access to the ticket!",
        );
    }

    my %TicketRaw = $TicketObject->TicketGet(
        TicketID      => $TicketID,
        DynamicFields => 0,
        UserID        => 1,
    );

    if ( !IsHashRefWithData( \%TicketRaw ) ) {
        return $Self->ReturnError(
            ErrorCode    => 'TicketCreate.AccessDenied',
            ErrorMessage => $Self->{Invoker} . ": User does not have access to the ticket!",
        );
    }

    my $WebserviceObject = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice');

    # get webservice configuration
    my $Webservice = $WebserviceObject->WebserviceGet(
        ID => $Self->{WebserviceID},
    );

    # get invoker config
    my $InvokerConfig = $Webservice->{Config}->{Requester}->{Invoker}->{ $Self->{Invoker} };

    # Determine if we have an old configuration, that we need to define fallbacks for.
    # In that case, we update the current webservice with the new default values.
    my $WebserviceConfigNeedsUpdate = 0;

    # fallback configuration settings for ArticleFields
    if ( !defined $InvokerConfig->{ArticleFields} ) {

        $WebserviceConfigNeedsUpdate = 1;
        $InvokerConfig->{ArticleFields} = [
            'ArticleSenderType',
            'Attachment',
            'Body',
            'Charset',
            'CommunicationChannel',
            'ContentType',
            'CustomerVisibility',
            'From',
            'MimeType',
            'SenderType',
            'Subject',
            'TimeUnit',
        ];
    }

    # fallback configuration settings for TicketFields
    if ( !defined $InvokerConfig->{TicketFields} ) {

        $WebserviceConfigNeedsUpdate = 1;

        $InvokerConfig->{TicketFields} = [
            'CustomerUser',
            'Lock',
            'Owner',
            'PendingTime',
            'Priority',
            'Queue',
            'Responsible',
            'Service',
            'SLA',
            'State',
            'Title',
            'Type',
        ];
    }

    # fallback configuration settings for DynamicFieldsArticle
    if ( !defined $InvokerConfig->{DynamicFieldsArticle} ) {

        $WebserviceConfigNeedsUpdate = 1;

        my $DynamicFieldListArticle = $DynamicFieldObject->DynamicFieldList(
            ObjectType => ['Article'],
            ResultType => 'HASH',
        );

        my @DFArticleList = values %{$DynamicFieldListArticle};

        $InvokerConfig->{DynamicFieldsArticle} = \@DFArticleList;
    }

    # fallback configuration settings for DynamicFieldsTicket
    if ( !defined $InvokerConfig->{DynamicFieldsTicket} ) {

        $WebserviceConfigNeedsUpdate = 1;

        my $DynamicFieldListTicket = $DynamicFieldObject->DynamicFieldList(
            ObjectType => ['Ticket'],
            ResultType => 'HASH',
        );

        my @DFTicketList = values %{$DynamicFieldListTicket};

        $InvokerConfig->{DynamicFieldsTicket} = \@DFTicketList;
    }

    # update webservice configuration, if we added fallback values
    if ($WebserviceConfigNeedsUpdate) {

        # setup the fallback fields
        $Webservice->{Config}->{Requester}->{Invoker}->{ $Self->{Invoker} } = $InvokerConfig;

        my $Success = $WebserviceObject->WebserviceUpdate(
            ID      => $Self->{WebserviceID},
            Name    => $Webservice->{Name},
            Config  => $Webservice->{Config},
            ValidID => 1,
            UserID  => 1,
        );

        if ( !$Success ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => $Self->{Invoker}
                    . ": Can\'t update webservice with fallback configuration!",
            );
        }
    }

    # get only first articles
    my $OnlyFirstArticle = $InvokerConfig->{OnlyFirstArticle};

    # get count of last articles
    my $CountLastArticle = IsPositiveInteger( $InvokerConfig->{CountLastArticle} ) ? $InvokerConfig->{CountLastArticle} : 0;

    # get return attachments
    my $ReturnAttachments = $InvokerConfig->{ReturnAttachments};

    # Get the list of dynamic fields for object article.
    my $ArticleDynamicFieldList = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldList(
        ObjectType => 'Article',
        ResultType => 'HASH',
    );

    # create a lookup list for easy search
    my %ArticleDynamicFieldLookup = reverse %{$ArticleDynamicFieldList};

    my @AttachmentData;
    my @ArticleBox;
    my @ArticleBoxRaw;

    if ( (!$ArticleID) && ( ($CountLastArticle == 0 || $CountLastArticle == 1) && $OnlyFirstArticle == 0 ) ) {

        my @Articles = $ArticleObject->ArticleList(
            TicketID => $TicketID,
            OnlyLast => 1,
        );

        if ( IsArrayRefWithData( $InvokerConfig->{ArticleSenderType} ) ) {
            my %ArticleSenderTypes = $Kernel::OM->Get('Kernel::System::Ticket::Article')->ArticleSenderTypeList();
            my %ReverseArticleSenderTypes = reverse %ArticleSenderTypes;
            my %Filter = map { $ReverseArticleSenderTypes{$_} => 1 } @{ $InvokerConfig->{ArticleSenderType} };

            @Articles = grep { $Filter{ $_->{SenderTypeID} } } @Articles;
        }

        $ArticleID = $Articles[0]->{ArticleID};
    }
    elsif ( (!$ArticleID) && ( $OnlyFirstArticle == 1 && $CountLastArticle == 0 ) ) {

        my @Articles = $ArticleObject->ArticleList(
            TicketID  => $TicketID,
            OnlyFirst => 1,
        );

        $ArticleID = $Articles[0]->{ArticleID};
    }

    # get one article with article id or more articles
    if ($ArticleID) {
        my $ArticleBackendObject = $Kernel::OM->Get('Kernel::System::Ticket::Article')->BackendForArticle(
            TicketID  => $TicketID,
            ArticleID => $ArticleID,
        );

        my %ArticleRaw = $ArticleBackendObject->ArticleGet(
            TicketID      => $TicketID,
            ArticleID     => $ArticleID,
            DynamicFields => 1,
            UserID        => 1,
        );

        if ( IsHashRefWithData( \%ArticleRaw ) ) {
            $ArticleRaw{CommunicationChannel} = $ArticleBackendObject->ChannelNameGet();
            push @ArticleBoxRaw, \%ArticleRaw;
        }
    }
    else {

        # Filter by customer visibility.
        my $IsVisibleForCustomer;
        if (
            IsInteger( $InvokerConfig->{CustomerVisibility} )
            && ( $InvokerConfig->{CustomerVisibility} == 0 || $InvokerConfig->{CustomerVisibility} == 1 )
            )
        {
            $IsVisibleForCustomer = $InvokerConfig->{CustomerVisibility};
        }

        my @ArticleList = $Kernel::OM->Get('Kernel::System::Ticket::Article')->ArticleList(
            TicketID             => $TicketID,
            IsVisibleForCustomer => $IsVisibleForCustomer,
        );

        # Filter by sender types.
        if ( IsArrayRefWithData( $InvokerConfig->{ArticleSenderType} ) ) {
            my %ArticleSenderTypes = $Kernel::OM->Get('Kernel::System::Ticket::Article')->ArticleSenderTypeList();
            my %ReverseArticleSenderTypes = reverse %ArticleSenderTypes;
            my %Filter = map { $ReverseArticleSenderTypes{$_} => 1 } @{ $InvokerConfig->{ArticleSenderType} };

            @ArticleList = grep { $Filter{ $_->{SenderTypeID} } } @ArticleList;
        }

        # Filter by communication channel.
        if ( IsArrayRefWithData( $InvokerConfig->{CommunicationChannel} ) ) {
            my @CommunicationChannels = $Kernel::OM->Get('Kernel::System::CommunicationChannel')->ChannelList(
                ValidID => 1,
            );
            my %Channels = map { $_->{DisplayName} => $_->{ChannelID} } @CommunicationChannels;
            my %Filter   = map { $Channels{$_}     => 1 } @{ $InvokerConfig->{CommunicationChannel} };

            @ArticleList = grep { $Filter{ $_->{CommunicationChannelID} } } @ArticleList;
        }

        # Ensure most recent article comes first (for article count limit).
        my $CountArticle = 0;

        ARTICLE:
        for my $Article ( reverse @ArticleList ) {

            last ARTICLE if $CountArticle >= $CountLastArticle;

            my $ArticleBackendObject = $Kernel::OM->Get('Kernel::System::Ticket::Article')->BackendForArticle(
                TicketID  => $TicketID,
                ArticleID => $Article->{ArticleID},
            );

            my %ArticleRaw = $ArticleBackendObject->ArticleGet(
                TicketID      => $TicketID,
                ArticleID     => $Article->{ArticleID},
                DynamicFields => 1,
                UserID        => 1,
            );

            next ARTICLE if !IsHashRefWithData( \%ArticleRaw );

            $ArticleRaw{CommunicationChannel} = $ArticleBackendObject->ChannelNameGet();
            push @ArticleBoxRaw, \%ArticleRaw;

            $CountArticle++;
        }
    }

    ARTICLE:
    for my $Article (@ArticleBoxRaw) {
        my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article')->BackendForArticle(
            TicketID  => $TicketID,
            ArticleID => $Article->{ArticleID},
        );

        # Skip Articles which don't support attachments.
        next ARTICLE if !$ArticleObject->can('ArticleAttachmentIndex');

        # get attachment index (without attachments)
        my %AtmIndex = $ArticleObject->ArticleAttachmentIndex(
            OnlyMyBackend => 1,
            ArticleID     => $Article->{ArticleID},
        );

        next ARTICLE if !IsHashRefWithData( \%AtmIndex );

        my @Attachments;
        ATTACHMENT:
        for my $FileID ( sort keys %AtmIndex ) {
            next ATTACHMENT if !$FileID;
            my %Attachment = $ArticleObject->ArticleAttachment(
                ArticleID     => $Article->{ArticleID},
                FileID        => $FileID,
                UserID        => 1,
                OnlyMyBackend => 1,
            );

            next ATTACHMENT if !IsHashRefWithData( \%Attachment );

            # use 'utf8' instead of 'utf-8'
            # because Operation TicketCreate/TicketUpdate
            # currently does not accept 'utf-8'
            $Attachment{ContentType} =~ s{utf-8}{utf8};

            # convert content to base64
            $Attachment{Content} = encode_base64( $Attachment{Content} );

            $Attachment{FileID}   = $FileID;
            $Attachment{MimeType} = $Attachment{ContentType};
            $Attachment{MimeType} =~ s{ [,;] [ ]* charset= .+ \z }{}xmsi;

            # remove empty attributes
            ATTRIBUTE:
            for my $Attribute ( sort keys %Attachment ) {
                next ATTRIBUTE if $Attribute eq 'ContentType';
                next ATTRIBUTE if $Attribute eq 'Content';
                next ATTRIBUTE if IsStringWithData( $Attachment{$Attribute} );
                delete $Attachment{$Attribute};
            }

            push @Attachments,    Storable::dclone( \%Attachment );
            push @AttachmentData, \%Attachment;
        }

        # set attachments data
        $Article->{Attachment} = \@Attachments;
    }

    # prepare selected article dynamic fields
    my $DynamicFieldArticleList = $DynamicFieldObject->DynamicFieldListGet(
        ObjectType => ['Article'],
    );

    my %DynamicFieldArticleSelected;

    SELECTEDDYNAMICFIELD:
    for my $SelectedDynamicField ( @{ $InvokerConfig->{DynamicFieldsTicket} } ) {

        next SELECTEDDYNAMICFIELD if !$SelectedDynamicField;

        $DynamicFieldArticleSelected{$SelectedDynamicField} = 1;
    }

    # prepare selected article fields (keys)
    my %ArticleFieldsSelected;

    ARTICLEFIELD:
    for my $ArticleField ( @{ $InvokerConfig->{ArticleFields} } ) {

        next ARTICLEFIELD if !$ArticleField;

        $ArticleFieldsSelected{$ArticleField} = 1;
        $ArticleFieldsSelected{ArticleID} = 1;
    }

    my @ArticleDynamicFieldsOneArticle;

    # pre-compile dynamic field name search regex
    my $DynamicFieldNameRegex = qr{\A DynamicField_(.*) \z}xms;

    for my $ArticleRaw (@ArticleBoxRaw) {
        my %Article;
        my @ArticleDynamicFields;

        # remove all dynamic fields from main article hash and set them into an array.
        ATTRIBUTE:
        for my $Attribute ( sort keys %{$ArticleRaw} ) {

            if ( $Attribute =~ m{$DynamicFieldNameRegex}xms ) {

                my $DynamicFieldName = $1;

                # skip fields of wrong type or not selected in invoker config
                next ATTRIBUTE if !$DynamicFieldArticleSelected{$DynamicFieldName};
                next ATTRIBUTE if !$ArticleDynamicFieldLookup{$DynamicFieldName};

                push @ArticleDynamicFields, {
                    Name  => $DynamicFieldName,
                    Value => $ArticleRaw->{$Attribute},
                };
                next ATTRIBUTE;
            }

            next ATTRIBUTE if !IsStringWithData( $ArticleFieldsSelected{$Attribute} );

            if ( $Attribute eq 'Charset' || $Attribute eq 'ContentType' ) {

                # use 'utf8' instead of 'utf-8'
                # because Operation TicketCreate/TicketUpdate
                # currently does not accept 'utf-8'
                $ArticleRaw->{$Attribute} =~ s{utf-8}{utf8};
            }

            $Article{$Attribute} = $ArticleRaw->{$Attribute};
        }

        # add dynamic fields array into 'DynamicField' hash key if fields are available
        if ( IsArrayRefWithData( \@ArticleDynamicFields ) ) {
            $Article{DynamicField} = \@ArticleDynamicFields;
        }

        if ( $CountLastArticle == 1 ) {
            @ArticleDynamicFieldsOneArticle = @ArticleDynamicFields;
        }

        # Add accounted time if selected.
        if ( $ArticleFieldsSelected{TimeUnit} ) {

            my $AccountedTime = $Kernel::OM->Get('Kernel::System::Ticket::Article')->ArticleAccountedTimeGet(
                ArticleID => $ArticleRaw->{ArticleID},
            );

            if ($AccountedTime) {

                $Article{TimeUnit} = $AccountedTime;
            }
        }

        push @ArticleBox, \%Article;
    }

    # prepare the selected ticket dynamic fields from invoker config
    my @DynamicFieldTicketData;
    my $DynamicFieldTicketList = $DynamicFieldObject->DynamicFieldListGet(
        ObjectType => ['Ticket'],
    );

    my %DynamicFieldTicketSelected;

    SELECTEDDYNAMICFIELD:
    for my $SelectedDynamicField ( @{ $InvokerConfig->{DynamicFieldsTicket} } ) {

        next SELECTEDDYNAMICFIELD if !$SelectedDynamicField;

        $DynamicFieldTicketSelected{$SelectedDynamicField} = 1;
    }

    # process the ticket dynamic fields
    DYNAMICFIELD:
    for my $DynamicField ( @{$DynamicFieldTicketList} ) {

        next DYNAMICFIELD if !IsHashRefWithData($DynamicField);
        next DYNAMICFIELD if !$DynamicFieldTicketSelected{ $DynamicField->{Name} };

        my $Value = $DynamicFieldBackendObject->ValueGet(
            DynamicFieldConfig => $DynamicField,
            ObjectID           => $TicketID,
        );

        if ( $DynamicField->{FieldType} eq 'FileSystem' ) {

            my $FileSystemValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue');

            my $Files = $FileSystemValueObject->ValueFileGet(
                FieldID  => $DynamicField->{ID},
                ObjectID => $TicketID,
            );

            my @Attachments;
            for my $File ( @{ $Files } ) {

                push @Attachments, {
                    'ContentType' => $File->{ContentType},
                    'Filename'    => $File->{Filename},
                    'FileID'      => $File->{FileID},
                    'Disposition' => $File->{Disposition},
                    'Content'     => encode_base64( $File->{Content} )
                };
            }

            push @DynamicFieldTicketData, {
                'Name'  => $DynamicField->{Name},
                'Value' => \@Attachments,
            };

            next DYNAMICFIELD;
        }

        if ( defined $Value ) {
            push @DynamicFieldTicketData, {
                'Name'  => $DynamicField->{Name},
                'Value' => $Value,
            };
        }
    }

    # get ticket data
    my %TicketData;

    ATTRIBUTE:
    for my $Attribute ( @{ $InvokerConfig->{TicketFields} } ) {
        if ( $Attribute eq 'CustomerUser' ) {
            next ATTRIBUTE if !$TicketRaw{CustomerUserID};

            my %CustomerUserData = $CustomerUserObject->CustomerUserDataGet(
                User => $TicketRaw{CustomerUserID},
            );

            $TicketData{CustomerUser} = $CustomerUserData{UserLogin};
        }
        elsif ( $Attribute eq 'PendingTime' ) {
            next ATTRIBUTE if !$TicketRaw{RealTillTimeNotUsed};

            my $DateTimeObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    Epoch => $TicketRaw{RealTillTimeNotUsed},
                },
            );
            my $DateTime = $DateTimeObject->Get();

            $TicketData{PendingTime} = {
                Year   => $DateTime->{Year},
                Month  => $DateTime->{Month},
                Day    => $DateTime->{Day},
                Hour   => $DateTime->{Hour},
                Minute => $DateTime->{Minute},
            };
        }
        elsif ( IsStringWithData( $TicketRaw{$Attribute} ) ) {
            $TicketData{$Attribute} = $TicketRaw{$Attribute};
        }
    }

    # prepare return data
    # use old structure if we have one article
    my %ReturnData = (
        TicketID     => $TicketRaw{TicketID},
        TicketNumber => $TicketRaw{TicketNumber},
        Ticket       => \%TicketData,
    );

    # add attachments with old structure
    if ( $ReturnAttachments == 1 && IsArrayRefWithData( \@AttachmentData ) ) {
        $ReturnData{Attachment} = \@AttachmentData;
    }

    # add dynamic fields with old and new structure
    if ( IsArrayRefWithData( \@DynamicFieldTicketData ) ) {
        $ReturnData{Ticket}->{DynamicField} = Storable::dclone( \@DynamicFieldTicketData );
        if ( $CountLastArticle > 1 ) {
            $ReturnData{DynamicField} = Storable::dclone( \@DynamicFieldTicketData );
        }

        if ( $InvokerConfig->{MappingOutbound}->{Config}->{DecodeJSON} ) {

            my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

            my @DynamicFieldNames = split( ' ', $InvokerConfig->{MappingOutbound}->{Config}->{DecodeJSON} );

            for my $DynamicFieldData ( @DynamicFieldTicketData ) {

                if ( grep( /^$DynamicFieldData->{Name}$/, @DynamicFieldNames ) ) {
                    $ReturnData{"DynamicField_$DynamicFieldData->{Name}_Decode"} = $JSONObject->Decode(
                        Data => $DynamicFieldData->{Value},
                    );
                }
            }
        }
    }
    if ( $CountLastArticle == 1 ) {
        my @DynamicFieldDataCombined = ( @DynamicFieldTicketData, @ArticleDynamicFieldsOneArticle );

        if ( IsArrayRefWithData( \@DynamicFieldDataCombined ) ) {
            $ReturnData{DynamicField} = Storable::dclone( \@DynamicFieldDataCombined );
        }
    }

    # Add the BodyHTML tag
    for my $index (0 .. $#ArticleBox ) {
        
        my $ArticleBackendObject = $ArticleObject->BackendForArticle(
            TicketID => $TicketID,
            ArticleID => $ArticleBox[$index]->{ArticleID}
        );

        my %ArticleData = $ArticleBackendObject->ArticleGet(
            TicketID  => $TicketID,
            ArticleID => $ArticleBox[$index]->{ArticleID},
        );

        my $HTML = $LayoutObject->ArticlePreview(
            %ArticleData,
        );

        $ArticleBox[$index]->{BodyHTML} = $HTML;
    }

    # add articles with old and new structure
    if ( IsArrayRefWithData( \@ArticleBox ) ) {
        $ReturnData{Ticket}->{Article} = \@ArticleBox;

        ARTICLE:
        for my $Article (@ArticleBox) {
            my $ClonedArticle = Storable::dclone($Article);
            delete $ClonedArticle->{Attachment};

            if ( $CountLastArticle == 1 ) {
                $ReturnData{Article} = $ClonedArticle;
                last ARTICLE;
            }

            push @{ $ReturnData{Article} }, $ClonedArticle;
        }
    }

    if ( $InvokerConfig->{MappingOutbound}->{Config}->{OwnerCustomerData} ) {

        my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
        my $UserObject         = $Kernel::OM->Get('Kernel::System::User');

        my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
            User => $TicketRaw{CustomerUserID},
        );

        my %Owner = $UserObject->GetUserData(
            UserID => $TicketRaw{OwnerID},
        );

        delete $CustomerUser{CompanyConfig};
        delete $CustomerUser{Config};

        $ReturnData{CustomerUser} = \%CustomerUser;
        $ReturnData{Owner}        = \%Owner;
    }

    $Self->{RequestData} = \%Param;

    return {
        Success => 1,
        Data    => \%ReturnData,
    };
}

=head2 HandleResponse()

handle response data of the configured remote web-service.

    my $Result = $InvokerObject->HandleResponse(
        ResponseSuccess      => 1,              # success status of the remote web-service
        ResponseErrorMessage => '',             # in case of web-service error
        Data => {                               # data payload
            ...
        },
    );

    $Result = {
        Success         => 1,                   # 0 or 1
        ErrorMessage    => '',                  # in case of error
        Data            => {                    # data payload after Invoker
            ...
        },
    };

=cut

sub HandleResponse {
    my ( $Self, %Param ) = @_;

    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # if there was an error in the response, forward it
    if ( !$Param{ResponseSuccess} && !$Param{Data} ) {
        if ( !IsStringWithData( $Param{ResponseErrorMessage} ) ) {
            return $Self->ReturnError(
                ErrorCode    => 'TicketCreate.ResponseError',
                ErrorMessage => $Self->{Invoker}
                    . ": Got response error, but no response error message!",
            );
        }
        return {
            Success      => 0,
            ErrorMessage => $Param{ResponseErrorMessage},
        };
    }

    # get webservice configuration
    my $Webservice = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceGet(
        ID => $Self->{WebserviceID},
    );

    # get invoker config
    my $InvokerConfig         = $Webservice->{Config}->{Requester}->{Invoker}->{ $Self->{Invoker} };
    my $SelectedDynamicFields = $InvokerConfig->{DynamicFieldList};

    # get data for dynamic field
    my %DynamicFieldData = $Self->_GenerateDynamicFieldData(
        DynamicFieldNames => $SelectedDynamicFields,
        Data              => $Param{Data},
    );

    # transfer the dynamic field values from response data to the matched local dynamic fields
    if (%DynamicFieldData) {
        for my $DynamicFieldName ( sort keys %DynamicFieldData ) {
            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => $DynamicFieldName,
            );
            if ( IsHashRefWithData($DynamicFieldConfig) ) {
                if (
                    !IsStringWithData( $DynamicFieldData{$DynamicFieldName} )
                    && !IsArrayRefWithData( $DynamicFieldData{$DynamicFieldName} )
                    )
                {
                    $DynamicFieldData{$DynamicFieldName} = '';
                }

                my $Success = $DynamicFieldBackendObject->ValueSet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    ObjectID           => $Self->{RequestData}->{Data}->{"$DynamicFieldConfig->{ObjectType}ID"},
                    Value              => $DynamicFieldData{$DynamicFieldName},
                    UserID             => 1,
                );

                if ( !$Success ) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => $Self->{Invoker}
                            . ": Can\'t set response values for dynamic field!",
                    );
                }
            }
            else {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => $Self->{Invoker}
                        . ": Dynamic field for response values not found!",
                );
            }
        }
    }

    # set the ticket id from response data to dynamic field
    # use the sysconfig option as fallback
    my $ResponsibleFieldTicketID = $InvokerConfig->{TicketIdToDynamicField};
    if ( !$ResponsibleFieldTicketID ) {
        my $ResponseDynamicFields = $ConfigObject->Get('InBox::TicketInvoker::Settings::ResponseDynamicField');
        if ( IsHashRefWithData($ResponseDynamicFields) ) {

            DYNAMICFIELD:
            for my $Field ( sort keys %{$ResponseDynamicFields} ) {
                next DYNAMICFIELD if $Field != $Self->{WebserviceID};

                $ResponsibleFieldTicketID = $ResponseDynamicFields->{$Field};
                last DYNAMICFIELD;
            }
        }
    }

    if ( IsStringWithData($ResponsibleFieldTicketID) ) {
        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $ResponsibleFieldTicketID,
        );

        if (
            IsHashRefWithData($DynamicFieldConfig)
            && IsStringWithData( $Param{Data}->{TicketID} )
            )
        {

            my $Success = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $Self->{RequestData}->{Data}->{TicketID},
                Value              => $Param{Data}->{TicketID},
                UserID             => 1,
            );

            if ( !$Success ) {
                return $Self->ReturnError(
                    ErrorCode    => 'TicketCreate.ResponseDynamicFieldValueSet',
                    ErrorMessage => $Self->{Invoker}
                        . ": Can\'t set response values for dynamic field!",
                );
            }
        }
        elsif ( !IsHashRefWithData($DynamicFieldConfig) ) {
            return $Self->ReturnError(
                ErrorCode    => 'TicketCreate.ResponseDynamicFieldValueGet',
                ErrorMessage => $Self->{Invoker}
                    . ": Dynamic field for response values not found!",
            );
        }
    }

    return {
        Success => 1,
        Data    => $Param{Data},
    };
}

=head2 ReturnError()

helper function to return an error message.

    my $Return = $CommonObject->ReturnError(
        ErrorCode    => Ticket.AccessDenied,
        ErrorMessage => 'You dont have rights to access this ticket',
    );

=cut

sub ReturnError {
    my ( $Self, %Param ) = @_;

    $Self->{DebuggerObject}->Error(
        Summary => $Param{ErrorCode},
        Data    => $Param{ErrorMessage},
    );

    # return structure
    return {
        Success      => 0,
        ErrorMessage => "$Param{ErrorCode}: $Param{ErrorMessage}",
        Data         => {
            Error => {
                ErrorCode    => $Param{ErrorCode},
                ErrorMessage => $Param{ErrorMessage},
            },
        },
    };
}

sub _GenerateDynamicFieldData {
    my ( $Self, %Param ) = @_;

    return () if !IsArrayRefWithData( $Param{DynamicFieldNames} );

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # Compile received data for ticket and article(s) into one uniform structure.
    my @StructureArray;
    STRUCTURE:
    for my $Structure (
        $Param{Data}->{Ticket},
        $Param{Data}->{Article},
        $Param{Data}->{Ticket}->{Article},
        )
    {
        if ( IsHashRefWithData($Structure) ) {
            push @StructureArray, Storable::dclone($Structure);
        }
        elsif ( IsArrayRefWithData($Structure) ) {
            push @StructureArray, @{ Storable::dclone($Structure) };
        }
    }

    # Extract dynamic fields from structure.
    my @ReceivedDynamicFields;
    STRUCTURE:
    for my $Structure (@StructureArray) {
        if ( IsHashRefWithData( $Structure->{DynamicField} ) ) {
            push @ReceivedDynamicFields, $Structure->{DynamicField};
        }
        elsif ( IsArrayRefWithData( $Structure->{DynamicField} ) ) {
            push @ReceivedDynamicFields, @{ $Structure->{DynamicField} };
        }
    }

    # Get values for configured dynamic fields from received data.
    my %DynamicFieldData;
    DYNAMICFIELDNAME:
    for my $DynamicField ( @{ $Param{DynamicFieldNames} } ) {
        
        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $DynamicField,
        );
        next DYNAMICFIELDNAME if !IsHashRefWithData($DynamicFieldConfig);

        my $DynamicFieldName = $DynamicFieldConfig->{Name};

        my @MatchedFields = grep { $_->{Name} eq $DynamicFieldName } @ReceivedDynamicFields;
        next DYNAMICFIELDNAME if !@MatchedFields;

        # Should we have more than one match (e.g. ArticleDynamicField in more than one received article), the first one wins.
        $DynamicFieldData{$DynamicFieldName} = $MatchedFields[0]->{Value};
    }

    return %DynamicFieldData;
}

1;