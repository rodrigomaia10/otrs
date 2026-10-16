# --
# Kernel/Modules/CustomerPortalNotifications.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::CustomerPortalNotifications;

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

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

    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CustomerUserObject   = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $UserObject           = $Kernel::OM->Get('Kernel::System::User');
    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $QueueObject          = $Kernel::OM->Get('Kernel::System::Queue');
    my $Config               = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::CustomerTicketMessage");
    my $TicketObject         = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject        = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my %GetParam;
    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "",
        %{$Self}
    );

    if ( $Self->{Subaction} eq 'DeleteNotification' ) {
        $GetParam{NotificationID} = $ParamObject->GetParam( Param => 'NotificationID' );

        my $JSON = "{}";
        
        my $Notification = $CustomerPortalObject->DeleteNotification(
            NotificationID =>  $GetParam{NotificationID}
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );

    }    
    #------------------------------------------------------- #
    # UnreadNotification
    # ------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'UnreadNotification' ) {
        $GetParam{NotificationID} = $ParamObject->GetParam( Param => 'NotificationID' );

        my $JSON = "{}";
        
        my $Notification = $CustomerPortalObject->NotificationUpdate(
            ID            => $GetParam{NotificationID}, 
            IsRead        => '0'
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );

    }    
    #------------------------------------------------------- #
    # ReadNotification
    # ------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ReadNotification' ) {
        $GetParam{NotificationID} = $ParamObject->GetParam( Param => 'NotificationID' );

        my $JSON = "{}";
        
        my $Notification = $CustomerPortalObject->NotificationUpdate(
            ID            => $GetParam{NotificationID}, 
            IsRead        => '1'
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );

    } 
    # ------------------------------------------------------------ #
    # NotificationShow
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'NotificationShow' ) {
        my $ArticleBackendObject = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal');

        $GetParam{NotificationID} = $ParamObject->GetParam( Param => 'NotificationID' );

        my $TicketID = $ArticleObject->TicketIDLookup(
            ArticleID => $GetParam{NotificationID},   # required
        );

        my %Article = $ArticleBackendObject->ArticleGet(
            TicketID      => $TicketID ,
            ArticleID     => $GetParam{NotificationID},
        );

        # Render article content.
        my $ArticleContent = $LayoutObject->ArticlePreview(
            TicketID  => $TicketID,
            ArticleID => $GetParam{NotificationID},
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
            . ";TicketID=$TicketID;ArticleID=$GetParam{NotificationID};FileID=";

        # replace links to inline images in html content
        my %AtmBox = $ArticleBackendObject->ArticleAttachmentIndex(
            ArticleID => $GetParam{NotificationID},
            ExcludePlainText => 1,
            ExcludeHTMLBody  => 1,
        );

        # reformat rich text document to have correct charset and links to
        # inline documents
        my $LoadExternalImages = $ParamObject->GetParam(
            Param => 'LoadExternalImages'
        ) || 0;

        # safety check only on customer article
        if ( !$LoadExternalImages && $Article{SenderType} ne 'customer' ) {
            $LoadExternalImages = 1;
        }

        %Data = $LayoutObject->RichTextDocumentServe(
            Data               => \%Data,
            URL                => $URL,
            Attachments        => \%AtmBox,
            LoadExternalImages => $LoadExternalImages,
        );

        # To remove the html of OTRS
        $Data{Content} =~ s|style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;| "" |g;

        if($Data{Content} eq ''){
            $Data{Content} = $Article{Body};
        }
        
        my $Notification = $CustomerPortalObject->NotificationUpdate(
            ID            => $GetParam{NotificationID},
            IsRead        => '1'
        );

        $LayoutObject->Block(
            Name => 'DisplayNotification',
            Data => {
                HTMLBody    => $Data{Content},
            },
        );

        my $JSON = $JSONObject->Encode(
            Data => {
                HTMLData =>  $Data{Content},
                CurrentNotificationID    => $GetParam{NotificationID}
            },
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }  
    # ------------------------------------------------------------ #
    # NextNotification
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'NextNotification' ) {
        $GetParam{NotificationID} = $ParamObject->GetParam( Param => 'NotificationID' );
    }
    else{
        $Param{Title} = '';
        $Param{Active} = 'Notifications';

        my $NotificationTableSize =  $ConfigObject->Get('CustomerPortal::Core::NotificationTableSize');

        # send data to JS
        $LayoutObject->AddJSData(
            Key   => 'NotificationTableSize',
            Value => $NotificationTableSize
        );

        my $ArticleBackendObject = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal');

        $LayoutObject->Block( Name => 'ShowNotifications' );

        # Get notification from customer
        my %Notification = $CustomerPortalObject->NotificationNotReadGetByCustomer(
            CustomerUserLogin => $Self->{UserID}
        );
        
        my %JSONReturn;

        for my $ArticleID ( keys %Notification){
            my $TicketID = $ArticleObject->TicketIDLookup(
                ArticleID => $ArticleID,   
            );

            my %Article = $ArticleBackendObject->ArticleGet(
                TicketID      => $TicketID ,
                ArticleID     => $ArticleID,
            );

            # Render article content.
            my $ArticleContent = $LayoutObject->ArticlePreview(
                TicketID  => $TicketID,
                ArticleID => $ArticleID,
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
                . ";TicketID=$TicketID;ArticleID=$ArticleID;FileID=";

            # replace links to inline images in html content
            my %AtmBox = $ArticleBackendObject->ArticleAttachmentIndex(
                ArticleID => $ArticleID,
                ExcludePlainText => 1,
                ExcludeHTMLBody  => 1,
            );

            # reformat rich text document to have correct charset and links to
            # inline documents
            my $LoadExternalImages = $ParamObject->GetParam(
                Param => 'LoadExternalImages'
            ) || 0;

            # safety check only on customer article
            if ( !$LoadExternalImages && $Article{SenderType} ne 'customer' ) {
                $LoadExternalImages = 1;
            }

            %Data = $LayoutObject->RichTextDocumentServe(
                Data               => \%Data,
                URL                => $URL,
                Attachments        => \%AtmBox,
                LoadExternalImages => $LoadExternalImages,
            );

            # To remove the html of OTRS
            $Data{Content} =~ s|style="font-family:Geneva,Helvetica,Arial,sans-serif; font-size: 12px;| "" |g;

            if($Data{Content} eq ''){
                $Data{Content} = $Article{Body};
            }

            $JSONReturn{$ArticleID} = $Data{Content};

            if($Notification{$ArticleID} eq '1'){
                $LayoutObject->Block(
                    Name => 'Record',
                    Data => {
                        Title   => $Article{Subject},
                        Created => $Article{CreateTime},
                        Body    => $Article{Body},
                        ID      => $ArticleID,
                    },
                );
            }else{
                $LayoutObject->Block(
                    Name => 'RecordNotRead',
                    Data => {
                        Title   => $Article{Subject},
                        Created => $Article{CreateTime},
                        Body    => $Article{Body},
                        ID      => $ArticleID,
                    },
                );
            }         
        }

        # send data to JS
        $LayoutObject->AddJSData(
            Key   => 'NotificationBody',
            Value => \%JSONReturn
        );

        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

        # build output
        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalNotifications});
        $Output   .= $LayoutObject->Output(
        Data         => \%Param,
            TemplateFile => 'CustomerPortalNotifications',
        );
        $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }  
}

1;