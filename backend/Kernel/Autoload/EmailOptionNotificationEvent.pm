# --
# Kernel/Autoload/EmailOptionNotificationEvent.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

use Kernel::System::Ticket::Event::NotificationEvent;

package Kernel::System::Ticket::Event::NotificationEvent;

use strict;
use warnings;

use List::Util qw(first);
use Mail::Address;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::CustomerUser',
    'Kernel::System::CheckItem',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Email',
    'Kernel::System::Group',
    'Kernel::System::HTMLUtils',
    'Kernel::System::JSON',
    'Kernel::System::Log',
    'Kernel::System::NotificationEvent',
    'Kernel::System::Queue',
    'Kernel::System::SystemAddress',
    'Kernel::System::TemplateGenerator',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
    'Kernel::System::DateTime',
    'Kernel::System::User',
    'Kernel::System::CheckItem',
);

sub _NotificationFilter {
    my ( $Self, %Param ) = @_;

    # check needed params
    for my $Needed (qw(Ticket Notification DynamicFieldConfigLookup)) {
        return if !$Param{$Needed};
    }

    # set local values
    my %Notification = %{ $Param{Notification} };

    # get dynamic field backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    # get the search article fields to retrieve values for
    my %ArticleSearchableFields = $ArticleObject->ArticleSearchableFieldsList();
       
    KEY:
    for my $Key ( sort keys %{ $Notification{Data} } ) {

        # TODO: This function here should be fixed to not use hardcoded attribute values!
        # ignore not ticket related attributes
        next KEY if $Key eq 'Recipients';
        next KEY if $Key eq 'SkipRecipients';
        next KEY if $Key eq 'RecipientAgents';
        next KEY if $Key eq 'RecipientGroups';
        next KEY if $Key eq 'RecipientRoles';
        next KEY if $Key eq 'TransportEmailTemplate';
        next KEY if $Key eq 'Events';
        next KEY if $Key eq 'ArticleSenderTypeID';
        next KEY if $Key eq 'ArticleIsVisibleForCustomer';
        next KEY if $Key eq 'ArticleCommunicationChannelID';
        next KEY if $Key eq 'ArticleAttachmentInclude';
        next KEY if $Key eq 'IsVisibleForCustomer';
        next KEY if $Key eq 'Transports';
        next KEY if $Key eq 'OncePerDay';
        next KEY if $Key eq 'VisibleForAgent';
        next KEY if $Key eq 'VisibleForAgentTooltip';
        next KEY if $Key eq 'LanguageID';
        next KEY if $Key eq 'SendOnOutOfOffice';
        next KEY if $Key eq 'AgentEnabledByDefault';
        next KEY if $Key eq 'EmailSecuritySettings';
        next KEY if $Key eq 'EmailSigningCrypting';
        next KEY if $Key eq 'EmailMissingCryptingKeys';
        next KEY if $Key eq 'EmailMissingSigningKeys';
        next KEY if $Key eq 'EmailDefaultSigningKeys';
        next KEY if $Key eq 'NotificationType';

        # START BLOCK SUP
        next KEY if $Key eq 'IsVisibleForAgentEmailOption';
        next KEY if $Key eq 'IsVisibleForCustomerEmailOption';
        # END BLOCK SUP

        # ignore article searchable fields
        next KEY if $ArticleSearchableFields{$Key};

        # skip transport related attributes
        if ( $Key =~ m{ \A ( Recipient | Transport ) }xms ) {
            next KEY;
        }

        # check ticket attributes
        next KEY if !defined $Notification{Data}->{$Key};
        next KEY if !defined $Notification{Data}->{$Key}->[0];
        next KEY if !@{ $Notification{Data}->{$Key} };
        my $Match = 0;

        VALUE:
        for my $Value ( @{ $Notification{Data}->{$Key} } ) {

            next VALUE if !defined $Value;

            # check if key is a search dynamic field
            if ( $Key =~ m{\A Search_DynamicField_}xms ) {

                # remove search prefix
                my $DynamicFieldName = $Key;

                $DynamicFieldName =~ s{Search_DynamicField_}{};

                # get the dynamic field config for this field
                my $DynamicFieldConfig = $Param{DynamicFieldConfigLookup}->{$DynamicFieldName};

                next VALUE if !$DynamicFieldConfig;

                my $IsNotificationEventCondition = $DynamicFieldBackendObject->HasBehavior(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Behavior           => 'IsNotificationEventCondition',
                );

                next VALUE if !$IsNotificationEventCondition;

                # Get match value from the dynamic field backend, if applicable (bug#12257).
                my $MatchValue;
                my $SearchFieldParameter = $DynamicFieldBackendObject->SearchFieldParameterBuild(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Profile            => {
                        $Key => $Value,
                    },
                );
                if ( defined $SearchFieldParameter->{Parameter}->{Equals} ) {
                    $MatchValue = $SearchFieldParameter->{Parameter}->{Equals};
                }
                else {
                    $MatchValue = $Value;
                }

                $Match = $DynamicFieldBackendObject->ObjectMatch(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Value              => $MatchValue,
                    ObjectAttributes   => $Param{Ticket},
                );

                last VALUE if $Match;
            }
            else {

                if (
                    $Param{Ticket}->{$Key}
                    && $Value eq $Param{Ticket}->{$Key}
                    )
                {
                    $Match = 1;
                    last VALUE;
                }
            }
        }

        return if !$Match;
    }

    # match article types only on ArticleCreate or ArticleSend event
    if (
        ( ( $Param{Event} eq 'ArticleCreate' ) || ( $Param{Event} eq 'ArticleSend' ) )
        && $Param{Data}->{ArticleID}
        )
    {
        my $BackendObject = $ArticleObject->BackendForArticle(
            TicketID  => $Param{Data}->{TicketID},
            ArticleID => $Param{Data}->{ArticleID},
        );

        my %Article = $BackendObject->ArticleGet(
            TicketID      => $Param{Data}->{TicketID},
            ArticleID     => $Param{Data}->{ArticleID},
            DynamicFields => 0,
        );

        # Check for active article filters:
        #   - SenderTypeID
        #   - IsVisibleForCustomer
        #   - CommunicationChannelID
        ARTICLE_FILTER:
        for my $ArticleFilter (qw(ArticleSenderTypeID ArticleIsVisibleForCustomer ArticleCommunicationChannelID)) {
            next ARTICLE_FILTER if !$Notification{Data}->{$ArticleFilter};

            my $Match = 0;
            VALUE:
            for my $Value ( @{ $Notification{Data}->{$ArticleFilter} } ) {
                next VALUE if !defined $Value;

                my $ArticleField = $ArticleFilter;
                $ArticleField =~ s/^Article//;

                if ( $Value == $Article{$ArticleField} ) {
                    $Match = 1;
                    last VALUE;
                }
            }

            return if !$Match;
        }

        my %ArticleData = $BackendObject->ArticleSearchableContentGet(
            TicketID  => $Param{Data}->{TicketID},
            ArticleID => $Param{Data}->{ArticleID},
            UserID    => $Param{UserID},
        );

        # check article backend fields
        KEY:
        for my $Key ( sort keys %ArticleSearchableFields ) {

            next KEY if !$Notification{Data}->{$Key};

            my $Match = 0;
            VALUE:
            for my $Value ( @{ $Notification{Data}->{$Key} } ) {

                next VALUE if !$Value;

                if ( $ArticleData{$Key}->{String} =~ /\Q$Value\E/i ) {
                    $Match = 1;
                    last VALUE;
                }
            }

            return if !$Match;
        }
    }

    return 1;

}

