# --
# Kernel/Modules/FAQOfService.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::FAQOfService;

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

use utf8;
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
    my $FAQObject            = $Kernel::OM->Get('Kernel::System::FAQ');

    my %GetParam;

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "",
        %{$Self}
    );

    # ---------------------------------------------------------- #
    # DownloadAttachment Subaction
    # ---------------------------------------------------------- #
    if ( $Self->{Subaction} eq 'DownloadAttachment' ) {
        my $FAQID  = $ParamObject->GetParam( Param => 'FAQID' )  || '';

        # manage parameters
        $GetParam{FileID} = $ParamObject->GetParam( Param => 'FileID' );
        $GetParam{ItemID} = $ParamObject->GetParam( Param => 'ItemID' );
        if ( !defined $GetParam{FileID} ) {
            return $LayoutObject->CustomerFatalError(
                Message => Translatable('Need FileID!'),
            );
        }

        # get attachments
        my %File = $FAQObject->AttachmentGet(
            ItemID => $GetParam{ItemID},
            FileID => $GetParam{FileID},
            UserID => $Self->{UserID},
        );

        if (%File) {
            return $LayoutObject->Attachment(%File);
        }
        else {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Message  => "No such attachment ($GetParam{FileID})! May be an attack!!!",
                Priority => 'error',
            );
            return $LayoutObject->CustomerFatalError();
        }
    }
    else{
  
        my $FAQID      = $ParamObject->GetParam( Param => 'FAQID' )  || '';
        my $ContractID = $ParamObject->GetParam( Param => 'ContractID' )  || '';

        $Param{ServiceID}  = $ParamObject->GetParam( Param => 'ServiceID' )  || '';

        $Param{ContractID} = "";

        if ( $ContractID ) {

            $Param{ContractID} = "ContractID=$ContractID";
        }

        $Param{Active} = 'FAQOFService';

        my %FAQData = $FAQObject->FAQGet(
            ItemID        => $FAQID,
            ItemFields    => 1,
            UserID        => $Self->{UserID},
            DynamicFields => 1,
        );

        my $DefaultFAQFields = $ConfigObject->Get('CustomerPortal::Core::DefaultButtonsOfFAQ');

        $Param{ButtonText1} = $DefaultFAQFields->{ButtonText1};
        $Param{ButtonColor1} = $DefaultFAQFields->{ButtonColor1};
        $Param{ButtonText2} = $DefaultFAQFields->{ButtonText2};
        $Param{ButtonColor2} = $DefaultFAQFields->{ButtonColor2};

        if($FAQData{DynamicField_ButtonText1}){
            $Param{ButtonText1} = $FAQData{DynamicField_ButtonText1};
        }

        if($FAQData{DynamicField_ButtonColor1}){
            $Param{ButtonColor1} = $FAQData{DynamicField_ButtonColor1};
        }

        if($FAQData{DynamicField_ButtonText2}){
            $Param{ButtonText2} = $FAQData{DynamicField_ButtonText2};
        }

        if($FAQData{DynamicField_ButtonColor2}){
            $Param{ButtonColor2} = $FAQData{DynamicField_ButtonColor2};
        }

        $LayoutObject->Block(
            Name => 'FAQData',
            Data => {
                %FAQData,
                %Param,
            },
        );

        # output attachments if any
        my @AttachmentIndex = $FAQObject->AttachmentIndex(
            ItemID     => $FAQID,
            ShowInline => 0,
            UserID     => $Self->{UserID},
        );

        # output attachments
        if (@AttachmentIndex) {
            $LayoutObject->Block(
                Name => 'AttachmentHeader',
            );
            
            for my $Attachment (@AttachmentIndex) {
                $LayoutObject->Block(
                    Name => 'AttachmentRow',
                    Data => {
                        %FAQData,
                        %{$Attachment},
                    },
                );
            }
        }

        # get interface state list
        my $InterfaceStates = $FAQObject->StateTypeList(
            Types  => $ConfigObject->Get('FAQ::Customer::StateTypes'),
            UserID => $Self->{UserID},
        );

        # show FAQ Content
        $LayoutObject->FAQContentShow(
            FAQObject       => $FAQObject,
            InterfaceStates => $InterfaceStates,
            FAQData         => {%FAQData},
            UserID          => $Self->{UserID},
        );

        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

        # build output
        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{FAQOfService});
        $Output   .= $LayoutObject->Output(
            Data         => {
                %FAQData,
                %GetParam,
                %Param,
            },
            TemplateFile => 'FAQOfService',
        );
        $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }  
}

1;