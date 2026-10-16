# --
# Kernel/Modules/CustomerPortalArticleContent.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalArticleContent;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

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

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $TicketID  = $ParamObject->GetParam( Param => 'TicketID' );
    my $ArticleID = $ParamObject->GetParam( Param => 'ArticleID' );

    my $UserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $EnableCopyTickets = $ConfigObject->Get('CustomerPortal::CompanyTickets::ToEnableTicketsWithUserInCopy');

    # check params
    if ( !$ArticleID ) {

        my $Output = $LayoutObject->CustomerHeader(
            Title => Translatable('Error'),
        );

        $Output .= $LayoutObject->CustomerError(
            Message => Translatable('ArticleID is needed!'),
            Comment => Translatable('Please contact the administrator.'),
        );

        $LogObject->Log(
            Message  => 'ArticleID is needed!',
            Priority => 'error',
        );

        $Output .= $LayoutObject->CustomerFooter();

        return $Output;
    }

    if ( !$TicketID ) {

        my $Output = $LayoutObject->CustomerHeader(
            Title => Translatable('Error'),
        );

        $Output .= $LayoutObject->CustomerError(
            Message => $LayoutObject->{LanguageObject}->Translate( 'No TicketID for ArticleID (%s)!', $ArticleID ),
            Comment => Translatable('Please contact the administrator.'),
        );

        $LogObject->Log(
            Message  => "No TicketID for ArticleID ($ArticleID)!",
            Priority => 'error',
        );

        $Output .= $LayoutObject->CustomerFooter();

        return $Output;
    }

    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my @ArticleList = $ArticleObject->ArticleList(
        TicketID             => $TicketID,
        ArticleID            => $ArticleID,
        IsVisibleForCustomer => 1,
    );

    my $ArticleBackendObject;
    my %Article;

    ARTICLEMETADATA:
    for my $ArticleMetaData (@ArticleList) {

        next ARTICLEMETADATA if !$ArticleMetaData;
        next ARTICLEMETADATA if !IsHashRefWithData($ArticleMetaData);

        $ArticleBackendObject = $ArticleObject->BackendForArticle( %{$ArticleMetaData} );

        %Article = $ArticleBackendObject->ArticleGet(
            TicketID      => $TicketID,
            ArticleID     => $ArticleMetaData->{ArticleID},
            DynamicFields => 0,
        );
    }

    # check permission
    my $Access = $TicketObject->TicketCustomerPermission(
        Type     => 'ro',
        TicketID => $TicketID,
        UserID   => $Self->{UserID}
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
            TicketID            => $Self->{TicketID},  
            Result              => 'ARRAY',
            DynamicField_CustomerCC => {
                Like => '%' . $UserEmail . '%'
            },
            UserID              => 1,
        );

        if ( grep { $_ == $Self->{TicketID} } @CcTickets, @DynamicFieldCcTickets ) {
            $Access = 1;
        }
    }

    if ( !$Access ) {
        return $LayoutObject->CustomerNoPermission( WithHeader => 'yes' );
    }

    # Render article content.
    my $ArticleContent = $LayoutObject->ArticlePreview(
        TicketID   => $TicketID,
        ArticleID  => $ArticleID
    );

    if ( !$ArticleContent ) {

        $ArticleContent = $LayoutObject->ArticlePreview(
            TicketID   => $TicketID,
            ArticleID  => $ArticleID,
            ResultType => 'plain',
        );

        if ( !$ArticleContent ) {

            my $Output = $LayoutObject->CustomerHeader(
                Title => Translatable('Error'),
            );

            $Output .= $LayoutObject->CustomerError(
                Message => $LayoutObject->{LanguageObject}->Translate('HTML body attachment is missing!'),
                Comment => Translatable('Please contact the administrator.'),
            );

            $LogObject->Log(
                Priority => 'error',
                Message  => 'HTML body attachment is missing!',
            );

            $Output .= $LayoutObject->CustomerFooter();

            return $Output;
        }

        $ArticleContent = '<!DOCTYPE html><html>' 
            . '<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></head>' 
            . '<body style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;">' 
            . $ArticleContent 
            . '</body></html>';
    }

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

    # set download type to inline
    $Kernel::OM->Get('Kernel::Config')->Set(
        Key   => 'AttachmentDownloadType',
        Value => 'inline'
    );

    my $TicketNumber = $TicketObject->TicketNumberLookup(
        TicketID => $TicketID,
    );

    # unset filename for inline viewing
    $Data{Filename} = "Ticket-$TicketNumber-ArticleID-$Article{ArticleID}.html";

    # generate base url
    my $URL = 'Action=CustomerTicketAttachment;Subaction=HTMLView'
        . ";TicketID=$TicketID;ArticleID=$ArticleID;FileID=";

    # replace links to inline images in html content
    my %AtmBox = $ArticleBackendObject->ArticleAttachmentIndex(
        ArticleID => $ArticleID,
    );

    # Do not load external images if 'BlockLoadingRemoteContent' is enabled.
    my $LoadExternalImages;
    
    if ( $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Frontend::BlockLoadingRemoteContent') ) {
        $LoadExternalImages = 0;
    }
    else {
        $LoadExternalImages = $ParamObject->GetParam(
            Param => 'LoadExternalImages'
        ) || 0;

        # Safety check only on customer article.
        if ( !$LoadExternalImages && $Article{SenderType} ne 'customer' ) {
            $LoadExternalImages = 1;
        }
    }

    # reformat rich text document to have correct charset and links to
    # inline documents
    %Data = $LayoutObject->RichTextDocumentServe(
        Data               => \%Data,
        URL                => $URL,
        Attachments        => \%AtmBox,
        LoadExternalImages => $LoadExternalImages,
    );

    $Data{Content} =~ s|style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;| style="font-family:'Montserrat', 'Helvetica Neue', Arial, sans-serif; color: #393939;; |g;

    # return html attachment
    return $LayoutObject->Attachment(
        %Data,
        Sandbox => 1,
    );
}

1;