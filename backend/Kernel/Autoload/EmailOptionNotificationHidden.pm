# --
# Kernel/Autoload/EmailOptionNotificationHidden.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# * dparavani@serviceup.com.br
# --

use Kernel::System::Ticket::Article;

package Kernel::System::Ticket::Article;

use strict;
use warnings;

use utf8;

use parent qw(Kernel::System::EventHandler);

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Cache',
    'Kernel::System::CommunicationChannel',
    'Kernel::System::DB',
    'Kernel::System::DynamicFieldValue',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::Ticket::Article::Backend::Invalid',
    'Kernel::System::Ticket',
    'Kernel::System::Valid',
);

=head2 _MetaArticleList()

Returns an array-hash with the meta articles of the current ticket.

    my @MetaArticles = $ArticleObject->_MetaArticleList(
        TicketID => 123,
    );

Returns:

    (
        {
            ArticleID              => 1,
            TicketID               => 2,
            ArticleNumber          => 1,                        # sequential number of article in the ticket
            CommunicationChannelID => 1,
            SenderTypeID           => 1,
            IsVisibleForCustomer   => 0,
            CreateBy               => 1,
            CreateTime             => '2017-03-01 00:00:00',
            ChangeBy               => 1,
            ChangeTime             => '2017-03-01 00:00:00',
        },
        { ... },
    )


=cut

sub _MetaArticleList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID!'
        );
        return;
    }

    my $CacheKey = '_MetaArticleList::' . $Param{TicketID};

    my $Cached = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );

    if ( ref $Cached eq 'ARRAY' ) {
        return @{$Cached};
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # START BLOCK SUP
    if ( !$Param{ShowAllArticles} ) {

        return if !$DBObject->Prepare(
            SQL => '
                SELECT id, ticket_id, communication_channel_id, article_sender_type_id, is_visible_for_customer,
                            create_by, create_time, change_by, change_time
                FROM article
                WHERE ticket_id = ?
                AND article_sender_type_id != 4
                ORDER BY id ASC',
            Bind => [ \$Param{TicketID} ],
        );        
    }
    else {
        return if !$DBObject->Prepare(
            SQL => '
                SELECT id, ticket_id, communication_channel_id, article_sender_type_id, is_visible_for_customer,
                            create_by, create_time, change_by, change_time
                FROM article
                WHERE ticket_id = ?
                ORDER BY id ASC',
            Bind => [ \$Param{TicketID} ],
        );        
    }
    # END BLOCK SUP

    my @Index;
    my $Count;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        my %Result;
        $Result{ArticleID}              = $Row[0];
        $Result{TicketID}               = $Row[1];
        $Result{CommunicationChannelID} = $Row[2];
        $Result{SenderTypeID}           = $Row[3];
        $Result{IsVisibleForCustomer}   = $Row[4];
        $Result{CreateBy}               = $Row[5];
        $Result{CreateTime}             = $Row[6];
        $Result{ChangeBy}               = $Row[7];
        $Result{ChangeTime}             = $Row[8];
        $Result{ArticleNumber}          = ++$Count;
        push @Index, \%Result;

    }

    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \@Index,
    );

    return @Index;
}


=head2 ArticleList()

Returns an filtered array of base article data for a ticket.

    my @Articles = $ArticleObject->ArticleList(

        TicketID               => 123,

        # Optional filters, these can be combined:

        ArticleID              => 234,                # optional, limit to one article (if present on a ticket)
        CommunicationChannel   => 'Email',            # optional, to limit to a certain CommunicationChannel
        CommunicationChannelID => 2,                  # optional, to limit to a certain CommunicationChannelID
        SenderType             => 'customer',         # optional, to limit to a certain article SenderType
        SenderTypeID           => 2,                  # optional, to limit to a certain article SenderTypeID
        IsVisibleForCustomer   => 0,                  # optional, to limit to a certain visibility

        # After filtering, you can also limit to first or last found article only:

        OnlyFirst              => 0,                  # optional, only return first match
        OnlyLast               => 0,                  # optional, only return last match
    );

Returns a list with base article data (no back end related data included):

    (
        {
            ArticleID              => 1,
            TicketID               => 2,
            ArticleNumber          => 1,                        # sequential number of article in the ticket
            CommunicationChannelID => 1,
            SenderTypeID           => 1,
            IsVisibleForCustomer   => 0,
            CreateBy               => 1,
            CreateTime             => '2017-03-01 00:00:00',
            ChangeBy               => 1,
            ChangeTime             => '2017-03-01 00:00:00',
        },
        { ... }
    )

Please note that you need to use L<ArticleGet()|Kernel::System::Ticket::Article::Backend::Base/ArticleGet()> via the
article backend objects to access the full backend-specific article data hash for each article.

    for my $MetaArticle (@Articles) {
        my %Article = $ArticleObject->BackendForArticle( %{$MetaArticle} )->ArticleGet( %{$MetaArticle} );
    }

=cut

sub ArticleList {
    my ( $Self, %Param ) = @_;

    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID!',
        );
        return;
    }

    if ( $Param{OnlyFirst} && $Param{OnlyLast} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'OnlyFirst and OnlyLast cannot be used together!',
        );
        return;
    }

    # START BLOCK SUP
    my ($Package, $Filename, $Line, $Subroutine) = caller(1);

    my @MetaArticleList = $Self->_MetaArticleList(
        %Param,
        ShowAllArticles => $Subroutine eq 'Kernel::System::Ticket::TicketDelete' ? 1 : 0
    );
    # END BLOCK SUP
    
    return if !@MetaArticleList;

    if ( $Param{ArticleID} ) {
        @MetaArticleList = grep { $_->{ArticleID} == $Param{ArticleID} } @MetaArticleList;
    }

    if ( $Param{CommunicationChannel} || $Param{CommunicationChannelID} ) {
        my %CommunicationChannel = $Kernel::OM->Get('Kernel::System::CommunicationChannel')->ChannelGet(
            ChannelID   => scalar $Param{CommunicationChannelID},
            ChannelName => scalar $Param{CommunicationChannel},
        );
        if ( !%CommunicationChannel ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "CommunicationChannel $Param{CommunicationChannel} was not found!",
            );
            return;
        }
        @MetaArticleList = grep { $_->{CommunicationChannelID} == $CommunicationChannel{ChannelID} } @MetaArticleList;

    }

    if ( $Param{SenderType} || $Param{SenderTypeID} ) {
        my $SenderTypeID = $Param{SenderTypeID} || $Self->ArticleSenderTypeLookup( SenderType => $Param{SenderType} );
        if ( !$SenderTypeID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Article SenderType $Param{SenderType} was not found!",
            );
            return;
        }
        @MetaArticleList = grep { $_->{SenderTypeID} == $SenderTypeID } @MetaArticleList;
    }

    if ( defined $Param{IsVisibleForCustomer} ) {
        @MetaArticleList = grep { $_->{IsVisibleForCustomer} == $Param{IsVisibleForCustomer} } @MetaArticleList;
    }

    if ( $Param{OnlyFirst} && @MetaArticleList ) {
        @MetaArticleList = ( $MetaArticleList[0] );
    }
    elsif ( $Param{OnlyLast} && @MetaArticleList ) {
        @MetaArticleList = ( $MetaArticleList[-1] );
    }

    return @MetaArticleList;
}

1;