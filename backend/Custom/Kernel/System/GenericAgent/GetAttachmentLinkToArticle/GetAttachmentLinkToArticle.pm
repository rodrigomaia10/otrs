# --
# Kernel/System/GetAttachmentLinkToArticle/GetAttachmentLinkToArticle.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::GetAttachmentLinkToArticle::GetAttachmentLinkToArticle;

use utf8;
use strict;
use warnings;
use LWP::Simple;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Request::Common;
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # 0=off; 1=on;
    $Self->{Debug} = $Param{Debug} || 0;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get object
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');
    my $TicketObject         = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject        = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        DynamicFields => 1,
    );

    my $ContentAttachment = $JSONObject->Decode(
        Data => $Ticket{$Param{New}->{DynamicField}}
    );

    return 1 if !IsArrayRefWithData($ContentAttachment);

    my @Articles = $ArticleObject->ArticleList(
        TicketID => $Param{TicketID},
    );

    my @ArticlesWhithoutSystemSenderType;
    my @LastArticle;
    ARTICLE:
    for my $Article ( @Articles ) {

        next ARTICLE if ( $Article->{SenderTypeID} != 3  );

        push @ArticlesWhithoutSystemSenderType, $Article;
    }

    my $LastArticle = pop @ArticlesWhithoutSystemSenderType;

    my $ArticleBackendObject = $ArticleObject->BackendForArticle( %{$LastArticle} );

    for my $AttachmentPath ( @{$ContentAttachment} ) {

        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);

        my $URL = $Param{New}->{URL} . $AttachmentPath->{path};

        if ( $Param{New}->{Header} ) {

            my @Header = split('=', $Param{New}->{Header});

            $ua->default_header($Header[0] => $Header[1]);
        }

        my $response = $ua->get($URL);

        if ($response->is_success) {
            my $Content = $response->decoded_content;
        
            my $Success = $ArticleBackendObject->ArticleWriteAttachment(
                Content     => $Content,
                ContentType => 'text/html; charset="iso-8859-15"',
                Filename    => $AttachmentPath->{fileName},
                Disposition => 'attachment',
                ArticleID   => $LastArticle->{ArticleID},
                UserID      => 1,
            );
        } 
        else {
            die "Falha na requisição: " . $response->status_line;
        }

    }

    return 1;
}

1;