# --
# /opt/Dev/CustomModuleGenericAgent/src/Custom/Kernel/System/GenericAgent/Article/FirstArticleBodyHTMLToDynamicField.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::Article::FirstArticleBodyHTMLToDynamicField;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $ArticleObject           = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $LayoutObject            = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $HTML = '';

    if ( $Param{New}->{AllArticles} ) {

        my @Articles = $ArticleObject->ArticleList(
            TicketID   => $Param{TicketID},
            SenderType => 'customer',
        );

        push @Articles, $ArticleObject->ArticleList(
            TicketID   => $Param{TicketID},
            SenderType => 'agent',
        );

        my @ArticlesID;

        for my $Article ( @Articles ) {
            push @ArticlesID, $Article->{ArticleID};
        }

        for my $ArticleID ( sort { $a <=> $b } @ArticlesID ) {

            my $ArticleBackendObject = $ArticleObject->BackendForArticle( TicketID => $Param{TicketID}, ArticleID => $ArticleID );

            my %Article = $ArticleBackendObject->ArticleGet(
                TicketID  => $Param{TicketID},
                ArticleID => $ArticleID,
            );

            $Article{Body} = $LayoutObject->Ascii2Html(
                NewLine        => 90,
                Text           => $Article{Body},
                VMax           => 6000,
                HTMLResultMode => 1,
                LinkFeature    => 1,
            );

            $HTML .= "$Article{CreateTime} <br> $Article{Body} <br><br>";
        }
    }
    elsif ( $Param{New}->{OnlyFirst} ) {

        my @Articles = $ArticleObject->ArticleList(
            TicketID  => $Param{TicketID},
            OnlyFirst => 1,     
        );

        my $ArticleBackendObject = $ArticleObject->BackendForArticle( TicketID => $Param{TicketID}, ArticleID => $Articles[0]->{ArticleID} );

        my %Article = $ArticleBackendObject->ArticleGet(
            TicketID  => $Param{TicketID},
            ArticleID => $Articles[0]->{ArticleID},
        );

        $HTML = $LayoutObject->Ascii2Html(
            NewLine        => 90,
            Text           => $Article{Body},
            VMax           => 6000,
            HTMLResultMode => 1,
            LinkFeature    => 1,
        );
    }
    elsif ($Param{New}->{OnlyLast}) {

        my @Articles = $ArticleObject->ArticleList(
            TicketID   => $Param{TicketID},
            SenderType => 'customer',
        );

        push @Articles, $ArticleObject->ArticleList(
            TicketID   => $Param{TicketID},
            SenderType => 'agent',
        );

        my @ArticlesID;

        for my $Article ( @Articles ) {
            push @ArticlesID, $Article->{ArticleID};
        }

        my @sortedArticlesID = sort { $a <=> $b } @ArticlesID;
        my $lastArticleID = $sortedArticlesID[-1];

        my $ArticleBackendObject = $ArticleObject->BackendForArticle( 
            TicketID => $Param{TicketID}, 
            ArticleID => $lastArticleID 
        );

        my %Article = $ArticleBackendObject->ArticleGet(
            TicketID  => $Param{TicketID},
            ArticleID => $lastArticleID,
        );

        # $HTML = $LayoutObject->Ascii2Html(
        #     NewLine        => 90,
        #     Text           => $Article{Body},
        #     VMax           => 6000,
        #     HTMLResultMode => 1,
        #     LinkFeature    => 1,
        # );

        $HTML = $LayoutObject->ArticlePreview(
            %Article,
        );

    }

    # Get DynamicFieldID
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DynamicField}
    );

    my $Success = $DynamicFieldValueObject->ValueSet(
        FieldID  => $DynamicField->{ID},
        ObjectID => $Param{TicketID},
        Value    => [
            {
                ValueText => $HTML,
            },
        ],
        UserID => 1,
    );

    return 1;
}

1;