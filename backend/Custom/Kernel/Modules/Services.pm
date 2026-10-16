# --
# Kernel/Modules/Services.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * jsantos@serviceup.com.br
# * dsilva@serviceup.com.br
# * jguedes@serviceup.com.br 
# -- 

package Kernel::Modules::Services;

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

use utf8;
use Kernel::System::VariableCheck qw(:all);
use Sort::Naturally;

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

    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $ServiceObject      = $Kernel::OM->Get('Kernel::System::Service');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');

    my %GetParam;

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');    

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "Services",
        %{$Self}
    );

    my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    if ( $ConfigObject->Get('CustomerPortal::Core::ToEnableShowNewTicketSideBar') eq '0' ) {
    
        $GetParam{Message} = $LayoutObject->{LanguageObject}->Translate("This page is currently unavailable.");
        $GetParam{Comment} = $LayoutObject->{LanguageObject}->Translate("Please contact the responsible team for more information.");

        $LayoutObject->Block(
            Name => 'Error',
            Data => \%GetParam,
        );

        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{Services});

        $Output .= $LayoutObject->Output(
            TemplateFile => "Services",
            Data         => \%GetParam,
        );

        $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }
    
    my $CardHomeSearch     = $ConfigObject->Get('CustomerPortal::Core::CardHomeSearch');
    my $CardSearchServices = $ConfigObject->Get('CustomerPortal::Core::CardSearchServices');

    if ( $CardHomeSearch && $CardSearchServices ) {

        my $Style;
        
        if( $CardHomeSearch->{BackgroundGradient} ne ""){
            $Style = "background: $CardHomeSearch->{BackgroundGradient}";
        }
        elsif ( $CardHomeSearch->{CardColor} ne "" ){
            $Style = "background-color: $CardHomeSearch->{CardColor}";

        }else{
            $Style = "background-image: url($CardHomeSearch->{Image})";
        }
        
        if ( $CardSearchServices->{Image} ) {

            $CardSearchServices->{Image} = $Self->_GetPathImage(
                Image => $CardSearchServices->{Image},
            );

            $Style = "background-image: url($CardSearchServices->{Image})";
        }

        $LayoutObject->Block(
            Name => $CardHomeSearch->{FullCard} ? 'SearchFull' : 'Search',
            Data => {
                Title         => $CardSearchServices->{Title},
                TitleColor    => $CardSearchServices->{TitleColor}    || '#FFF',
                Subtitle      => $CardSearchServices->{Subtitle},
                SubtitleColor => $CardSearchServices->{SubtitleColor} || '#FFF',
                Style         => $Style,
            }
        );
    }

    my ($SideBarColor1, $SideBarColor2);

    my $CustomerNavBarColorsDefault = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarColorsDefault');
    my $CustomerNavBarColors        = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarColors');

    # Set customized color to CustomerID of sideBar
    for my $CustomerID (keys %{$CustomerNavBarColors}){

        if($CustomerID eq $Param{CustomerID}){
            ($SideBarColor1, $SideBarColor2) = split /;/, $CustomerNavBarColors->{$CustomerID};
        }
    }

    # Set default color to sideBar
    if(!$SideBarColor1 && !$SideBarColor2){
        ($SideBarColor1, $SideBarColor2) = split /;/, $CustomerNavBarColorsDefault;
    }

    #  Get customized color to font of sideBar
    my $CustomerNavBarFontColors = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarFontColors');

    # To get user preferences and sercive Favorite
    my %UserList = $CustomerUserObject->SearchPreferences(
        Key => 'ServiceFavorite',
    );

    my $ConfigCardTitle = $ConfigObject->Get('CustomerPortal::Core::CardTitle');

    my $StyleCardTitle = '';
    
    for my $Key ( keys  %{ $ConfigCardTitle } ) {

        $StyleCardTitle .= "$Key: $ConfigCardTitle->{$Key};";
    }

    my $ServiceView    = $ConfigObject->Get('CustomerPortal::Core::TypeViewService');
    my $FisrtLevelCard = $ConfigObject->Get('CustomerPortal::Core::FirstLevelViewService');
    
    # ------------------------------------------------------------ #
    # reload service cards
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'ReloadServices' ) {
        
        my $LinkObject = $Kernel::OM->Get('Kernel::System::LinkObject');
        my $FAQObject  = $Kernel::OM->Get('Kernel::System::FAQ');

		$Param{ServiceID} = $ParamObject->GetParam( Param => 'ServiceID' );

		$Param{Title}  = 'Services';
		$Param{Active} = 'Services';

        my $JSON = "{}";
        my $CustomerUser = $Self->{UserID};

        my $ServiceColorsDefault = $ConfigObject->Get('CustomerPortal::Core::ServiceColorsDefault');

        # Get Config of size, format and transition effect of card
        my $CardTransitionEffect =  $ConfigObject->Get('CustomerPortal::Core::CardTransitionEffect');
        my $CardDescription      =  $ConfigObject->Get('CustomerPortal::Core::ToSetDescriptionInCard');
        my $CardFormat           =  $ConfigObject->Get('CustomerPortal::Core::CardFormat');
        my $CardSize             =  $ConfigObject->Get('CustomerPortal::Core::CardSize');

		if ( $Param{ServiceID} ) {

			my %ServiceData = $ServiceObject->ServiceGet(
				ServiceID      => $Param{ServiceID},
                CustomerUserID => $CustomerUser || '',
				UserID         => 1,
			);

            my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
                ServiceID      => $ServiceData{ServiceID},
                CustomerUserID => $CustomerUser || '',
                UserID         => 1,
            );

            push @{$ServiceParentsList}, $Param{ServiceID};

            my $ServiceIcon = '';
            my $ServiceColor = '';
            my $ServiceIconColor = '';
            my $ServiceImage = '';

            SERVICEFATHER:
            for my $ServiceFather (reverse @{$ServiceParentsList}) {

                my %ServiceDataFather = $ServiceObject->ServiceGet(
                    ServiceID      => $ServiceFather,
                    CustomerUserID => $CustomerUser || '',
                    UserID         => 1,
                );

                if ( $ServiceFather ne $Param{ServiceID} ){
                    $LayoutObject->Block(
                        Name => 'LinkOfService',
                        Data => {
                            ServiceParentID  => $ServiceDataFather{ParentID},
                            ServiceNameShort => $ServiceDataFather{NameShort},
                            LastService      => '0',
                        }                
                    );
                }

                if ( !$ServiceIcon ) {
                    if ( $ServiceDataFather{ServiceIcon} ) {
                        $ServiceIcon = $ServiceDataFather{ServiceIcon};
                    }
                }

                if ( !$ServiceColor ) {
                    if( $ServiceDataFather{ServiceColor} ) {
                        $ServiceColor = $ServiceDataFather{ServiceColor};
                    }
                }

                if ( !$ServiceIconColor ) {
                    if ( $ServiceDataFather{ServiceIconColor} ) {
                        $ServiceIconColor = $ServiceDataFather{ServiceIconColor};
                    }
                }
                
                if ( !$ServiceImage ) {
                    if ( $ServiceDataFather{ServiceImage} ) {
                        $ServiceImage = $ServiceDataFather{ServiceImage};
                    }
                }
            }
           
            $LayoutObject->Block(
                Name => 'LinkOfService',
                Data => {
                    ServiceParentID  => $ServiceData{ParentID},
                    ServiceNameShort => $ServiceData{NameShort},
                    LastService      => '1',
                }                
            );
            
            # To set parent service configuration
            $ServiceData{ServiceIcon}      = $ServiceIcon;
            $ServiceData{ServiceColor}     = $ServiceColor;
            $ServiceData{ServiceIconColor} = $ServiceIconColor;
            $ServiceData{ServiceImage}     = $ServiceImage;

			$LayoutObject->Block(
				Name => 'ShowServiceDetailsReload',
				Data => {
                    %ServiceData,
                    CardTransitionEffect => $CardTransitionEffect,
                    TitleStyle           => $StyleCardTitle,
                }
			);

            # Return all Services, filtering by KeepChildren config.
            my %AllServices = $ServiceObject->ServiceList(
                KeepChildren => $ConfigObject->Get('Ticket::Service::KeepChildren'),
                Valid        => 1,
                UserID       => 1,
            );

            # Check ACL
            my $ACL = $TicketObject->TicketAcl(
                Action         => $Self->{Action}, 
                CustomerUserID => $Self->{UserID},
                ReturnType     => 'Ticket',
                ReturnSubType  => 'Service',
                Data           => \%AllServices,
            );

            if($ACL){
                %AllServices = $TicketObject->TicketAclData();
            }

            # Return all Services in relation with CustomerUser.
            my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
                Result            => 'HASH',
                CustomerUserLogin => $Self->{UserID},
                UserID            => 1,
            );

            # Filter Services based on relation with CustomerUser and KeepChildren config.
            my %ServiceList;

            for my $FilterServiceID ( sort keys %AllServices ) {
                if ( $CustomerServices{$FilterServiceID} ) {
                     
                    # get service data
                    my %ServiceDataGet = $ServiceObject->ServiceGet(
                        ServiceID      => $FilterServiceID,
                        CustomerUserID => $CustomerUser || '',
                        UserID         => 1,
                    );
                    if(!$ServiceDataGet{ServiceImage} && !$ServiceDataGet{ServiceIcon} ){
                         $ServiceDataGet{ServiceImage} =  $ServiceData{ServiceImage};
                    }
                   
                    $ServiceDataGet{ServiceOrder} = $ServiceDataGet{ServiceOrder} || $ServiceDataGet{Name};

                    $ServiceList{$FilterServiceID} = \%ServiceDataGet;
                }
            }

            $ServiceParentsList = $ServiceObject->ServiceParentsGet(
                ServiceID => $ServiceData{ServiceID},
                UserID    => 1,
            );

            # To get service back link url
            my $BackURL;
            my $ServiceURLHome = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=Services";

            if ( $ServiceData{ParentID} ) {
                $BackURL = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=Services;Subaction=ServiceDetails;ServiceID=$ServiceData{ParentID}"
            }
            else {
                $BackURL = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=Services";
            }

            $LayoutObject->Block(
                Name => 'BackURLReload',
                Data => {
                    ServiceURLHome  => $ServiceURLHome,
                    BackgroundColor => $SideBarColor2,
                    Color           => $CustomerNavBarFontColors->{Menu},
                    ServiceID       => $ServiceData{ParentID},
                }
            );

            my $OutputReload;
            my $Counter = 0;

            $LayoutObject->Block(
                Name => 'ShowAsCategoryList',
                Data => {  }
            );

            # The for key compares the ServiceOrder attribute value to include services with value first
            #for my $ServiceDataFor ( sort { ncmp($a->{ServiceOrder},$b->{ServiceOrder}) } values %ServiceList ){
            # If the service has • at the beginning, it will be added at the end
            for my $ServiceDataFor (
                    sort {
                        ($a->{ServiceOrder} =~ /^•/ ? 1 : 0) <=> ($b->{ServiceOrder} =~ /^•/ ? 1 : 0)
                            ||
                        ncmp($a->{ServiceOrder}, $b->{ServiceOrder})
                    } values %ServiceList
                ) {

                my $ServiceID =  $ServiceDataFor->{ServiceID};

                $ServiceDataFor->{ParentID} = $ServiceDataFor->{ParentID} || '';

                if ( !$ServiceDataFor->{ServiceColor} ) {
                    # Get parent config of colors
                    if($ServiceData{ServiceColor}){
                        $ServiceDataFor->{ServiceColor} = $ServiceData{ServiceColor};
                    }
                    else{
                        # Set config default to service card
                        $ServiceDataFor->{ServiceColor} = $ServiceColorsDefault->{ServiceColor};
                    }
                }

                if ( !$ServiceDataFor->{ServiceIcon} ) {
                    # Get parent config of colors
                    if ( $ServiceData{ServiceIcon} ) {
                        $ServiceDataFor->{ServiceIcon} = $ServiceData{ServiceIcon};
                    }
                    else {
                        # Set config default to service card
                        $ServiceDataFor->{ServiceIcon} = $ServiceColorsDefault->{ServiceIcon};
                    }
                }

                if ( !$ServiceDataFor->{ServiceIconColor} ) {
                    # Get parent config of colors
                    if ( $ServiceData{ServiceIconColor} ) {
                        $ServiceDataFor->{ServiceIconColor} =  $ServiceData{ServiceIconColor};
                    }
                    else {
                        # Set config default to service card
                        $ServiceDataFor->{ServiceIconColor} = $ServiceColorsDefault->{ServiceIconColor};
                    }
                }

                if ( !$ServiceDataFor->{ServiceIcon} && !$ServiceDataFor->{ServiceImage} ) {
                    # Get parent config of colors
                    if ( $ServiceData{ServiceImage} ) {
                        $ServiceDataFor->{ServiceImage} = $ServiceData{ServiceImage};
                    }
                }

                $ServiceDataFor->{ServiceImage} = $Self->_GetPathImage(
                    Image => $ServiceDataFor->{ServiceImage},
                );

                # Function to break service description text
                my $SubStringDescription = '';
                if ( $ServiceDataFor->{ServiceDescription} ) {
                    # if ( length $ServiceDataFor->{ServiceDescription} > 85 ) {
                    #     $SubStringDescription = substr $ServiceDataFor->{ServiceDescription}, 0, 85;
                    #     $SubStringDescription .= '...';
                    # }
                    # else {
                    #     $SubStringDescription = $ServiceDataFor->{ServiceDescription};
                    # }
                    $SubStringDescription = $ServiceDataFor->{ServiceDescription};
                }

                my $StarFavoriteColor;

                if ( $UserList{$Self->{UserID}} ) {

                    my $ServicesPrefeUser = $JSONObject->Decode(
                       Data => $UserList{$Self->{UserID}},
                    );

                    my %ParamsServices = map { $_ => 1}  @{$ServicesPrefeUser};

                    # Compare to not add services repeated
                    if ( exists( $ParamsServices{$ServiceDataFor->{ServiceID}}) ) {
                        $StarFavoriteColor = 'ffc107';
                    }
                }

                # checking linked items
                my $LinkListWithData = $LinkObject->LinkListWithData(
                    Object => 'Service',
                    Key    => $ServiceDataFor->{ServiceID},
                    State  => 'Valid',
                    UserID => 1,
                );

                if( $ServiceDataFor->{ParentID} eq $Param{ServiceID} ) {

                    $Counter++;

                    my $BlockName;
                    my %ParamCardDescription;

                    if ( $CardFormat eq '1' ) {

                        $BlockName = 'TicketServiceDetailReloadRetangle';

                        if ( $CardDescription eq '1' ) {

                            $ParamCardDescription{DescriptionHeigthClass} = "DescriptionHeigth-$CardSize";
                            $ParamCardDescription{NotDisplayDescription}  = 'HiddenElement';
                        }
                    }
                    else {

                        $BlockName = 'TicketServiceDetailReload';

                        if ( $CardDescription eq '1' ) {

                            $ParamCardDescription{DescriptionHeigthClass} = "DescriptionHeigthSquare-$CardSize";
                            $ParamCardDescription{NotDisplayDescription}  = 'HiddenElement';
                        }
                    }

                    if ( $ServiceView eq 'ShowAsCategory' ) {

                        if ( $ServiceDataFor->{ShowAsCategory} == 2) {

                            $BlockName = 'ServiceListRow';
                        }
                        elsif ( $ServiceDataFor->{ShowAsCategory} == 3 ) {
                            $BlockName = 'ServiceCard';
                            if ( !$Self->{MoreServices} ) {

                                $LayoutObject->Block(
                                    Name => 'MoreServices'
                                );

                                $Self->{MoreServices} = 1;
                            }
                        }

                        $LayoutObject->Block(
                            Name => $BlockName,
                            Data => {
                                %{$ServiceDataFor},
                                SubStringDescription => $SubStringDescription,
                                StarFavoriteColor    => $StarFavoriteColor,
                                CardSize             => $CardSize,
                                CardTransitionEffect => $CardTransitionEffect,
                                TitleStyle           => $StyleCardTitle,
                                CardFormat           => $CardFormat,
                                %ParamCardDescription
                            }
                        );
                        
                    }
                    else {
                        
                        $LayoutObject->Block(
                            Name => $BlockName,
                            Data => {
                                %{$ServiceDataFor},
                                SubStringDescription => $SubStringDescription,
                                StarFavoriteColor    => $StarFavoriteColor,
                                CardSize             => $CardSize,
                                CardTransitionEffect => $CardTransitionEffect,
                                TitleStyle           => $StyleCardTitle,
                                CardFormat           => $CardFormat,
                                %ParamCardDescription
                            }
                        );

                        # if ( $CardFormat eq '1' ) {

                        #     if ( $CardDescription eq '1' ) {
                                
                        #         %ParamCardDescription = (
                        #             DescriptionHeigthClass => "DescriptionHeigth-$CardSize",
                        #             NotDisplayDescription  => 'HiddenElement',
                        #         );
                        #     } 
                        #     $LayoutObject->Block(
                        #         Name => 'TicketServiceDetailReloadRetangle',
                        #         Data => {
                        #             %{$ServiceDataFor},
                        #             SubStringDescription => $SubStringDescription,
                        #             StarFavoriteColor    => $StarFavoriteColor,
                        #             CardSize             => $CardSize,
                        #             CardTransitionEffect => $CardTransitionEffect,
                        #             TitleStyle           => $StyleCardTitle,
                        #             %ParamCardDescription
                        #         }
                        #     );               
                        # }
                        # else {

                        #     %ParamCardDescription = (
                        #         CardFormat => $CardFormat,
                        #     );

                        #     if ( $CardDescription eq '1' ) {

                        #         %ParamCardDescription = (
                        #             DescriptionHeigthClass => "DescriptionHeigthSquare-$CardSize",
                        #             NotDisplayDescription  => 'HiddenElement',
                        #         );
                        #     }

                        #     $LayoutObject->Block(
                        #         Name => 'TicketServiceDetailReload',
                        #         Data => {
                        #             %{$ServiceDataFor},
                        #             SubStringDescription => $SubStringDescription,
                        #             StarFavoriteColor    => $StarFavoriteColor,
                        #             CardSize             => $CardSize,
                        #             CardTransitionEffect => $CardTransitionEffect,
                        #             TitleStyle           => $StyleCardTitle,
                        #             CardFormat           => $CardFormat,
                        #             %ParamCardDescription
                        #         }
                        #     );
                        # }
                    }
                }
			}

            $OutputReload = $LayoutObject->Output(
                TemplateFile => 'CustomerPortalReloadServices',
            );

            my @ServicesLevel;
         
            my %ServiceDataToNavBar = (
                Name     => $ServiceData{NameShort},
                ParentID => $ServiceData{ParentID},
            );

            # Create HTML to NavBar 
            my $HTML;
            my $CounterSeparations = '';

            for my $ServiceParentID(@{$ServiceParentsList}){

                my %ServiceDataParent = $ServiceObject->ServiceGet(
                    ServiceID => $ServiceParentID,
                    UserID    => 1,
                );

                $ServiceDataParent{ParentID}  = $ServiceDataParent{ParentID}  || '';
                $ServiceDataParent{NameShort} = $ServiceDataParent{NameShort} || '';

                $CounterSeparations++;

                $HTML .= "<a href='#' onclick='Core.Customer.CustomerPortalReloadServices.ReloadServiceBackButton($ServiceDataParent{ParentID})'>$ServiceDataParent{NameShort}</a>";

                if(  scalar @{$ServiceParentsList} ne $CounterSeparations) {
                    $HTML .= " → ";
                }
            }

            push @ServicesLevel, \%ServiceDataToNavBar;
                 
            if ( $Counter > 0 ) {              
                $JSON = $JSONObject->Encode(
                    Data => {
                        HTMLString        => $OutputReload,
                        NextView          => '',
                        ServiceParentName => $ServiceData{Name},
                        ServicesLevel     => $HTML,
                        ExternalLink      => ''
                    },
                );
            }
            else{
            
                if ( $ServiceData{ServiceExternalLink} ) {
                    $JSON = $JSONObject->Encode(
                        Data => {
                            HTMLString        => '',
                            NextView          => '',
                            ServiceParentName => $ServiceData{Name},
                            ServicesLevel     => $HTML,
                            ExternalLink      => $ServiceData{ServiceExternalLink},
                        },
                    );
                }
                else {
                    # Verify if exists FAQ in service
                    if( $ServiceData{ServiceFAQID}){

                        my %FAQData = $FAQObject->FAQGet(
                            ItemID     => $ServiceData{ServiceFAQID},
                            ItemFields => 1,
                            UserID     => $Self->{UserID},
                        );

                        if( %FAQData && $FAQData{State} ne 'internal (agent)' ){

                            $JSON = $JSONObject->Encode(
                                    Data => {
                                    HTMLString        => '',
                                    NextView          => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=FAQOfService;FAQID=".$ServiceData{ServiceFAQID}.";ServiceID=".$ServiceData{ServiceID},
                                    ServiceParentName =>  $ServiceData{Name},
                                    ServicesLevel     => $HTML,
                                    ExternalLink      => ''
                                },
                            );
                        }
                        else{
                            $JSON = $JSONObject->Encode(
                                Data => {
                                    HTMLString        => '',
                                    NextView          => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=NewTicketService;ServiceID=".$Param{ServiceID},
                                    ServiceParentName =>  $ServiceData{Name},
                                    ServicesLevel     => $HTML,
                                    ExternalLink      => ''
                                },
                            );
                        }
                    }
                    else{
                        $JSON = $JSONObject->Encode(
                            Data => {
                                HTMLString        => '',
                                NextView          => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=NewTicketService;ServiceID=".$Param{ServiceID},
                                ServiceParentName =>  $ServiceData{Name},
                                ServicesLevel     => $HTML,
                                ExternalLink      => ''
                            },
                        );
                    }                    
                }
            }
		}
		else {
            $JSON = $JSONObject->Encode(
                Data => {
                    HTMLString => '',
                    NextView   => "Action=Services",
                },
            );
		}
        
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
	}
    # ------------------------------------------------------------ #
    # reload contract service cards
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ReloadContractServices' ) {
        
        my $ContractObject = $Kernel::OM->Get('Kernel::System::ContractManagement');
        my $LinkObject     = $Kernel::OM->Get('Kernel::System::LinkObject');
        my $FAQObject      = $Kernel::OM->Get('Kernel::System::FAQ');

		$Param{ContractID} = $ParamObject->GetParam( Param => 'ContractID' );
		$Param{ServiceID}  = $ParamObject->GetParam( Param => 'ServiceID' );

		$Param{Title}  = 'Services';
		$Param{Active} = 'Services';

        my $JSON = "{}";
        my $CustomerUser = $Self->{UserID};

        my $ServiceColorsDefault = $ConfigObject->Get('CustomerPortal::Core::ServiceColorsDefault');

        # Get Config of size, format and transition effect of card
        my $CardTransitionEffect =  $ConfigObject->Get('CustomerPortal::Core::CardTransitionEffect');
        my $CardDescription      =  $ConfigObject->Get('CustomerPortal::Core::ToSetDescriptionInCard');
        my $CardFormat           =  $ConfigObject->Get('CustomerPortal::Core::CardFormat');
        my $CardSize             =  $ConfigObject->Get('CustomerPortal::Core::CardSize');

		if ( $Param{ContractID} ) {

            my $ContractAndServicesObject = $Kernel::OM->Get('Kernel::System::ContractAndServices');

            my $HTML;

            if ( $Param{ServiceID} ) {

                # get ServiceData
                my %ServiceData = $ServiceObject->ServiceGet(
                    ServiceID      => $Param{ServiceID},
                    CustomerUserID => $CustomerUser || '',
                    UserID         => 1,
                );

                # get parentent list
                my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
                    ServiceID      => $ServiceData{ServiceID},
                    CustomerUserID => $CustomerUser || '',
                    UserID         => 1,
                );

                push @{$ServiceParentsList}, $Param{ServiceID};

                my $ServiceIcon = '';
                my $ServiceColor = '';
                my $ServiceIconColor = '';
                my $ServiceImage = '';

                SERVICEFATHER:
                for my $ServiceFather (reverse @{$ServiceParentsList}) {

                    my %ServiceDataFather = $ServiceObject->ServiceGet(
                        ServiceID      => $ServiceFather,
                        CustomerUserID => $CustomerUser || '',
                        UserID         => 1,
                    );

                    if ( !$ServiceIcon ) {
                        if ( $ServiceDataFather{ServiceIcon} ) {
                            $ServiceIcon = $ServiceDataFather{ServiceIcon};
                        }
                    }

                    if ( !$ServiceColor ) {
                        if( $ServiceDataFather{ServiceColor} ) {
                            $ServiceColor = $ServiceDataFather{ServiceColor};
                        }
                    }

                    if ( !$ServiceIconColor ) {
                        if ( $ServiceDataFather{ServiceIconColor} ) {
                            $ServiceIconColor = $ServiceDataFather{ServiceIconColor};
                        }
                    }

                    if ( !$ServiceImage ) {
                        if ( $ServiceDataFather{ServiceImage} ) {
                            $ServiceImage = $ServiceDataFather{ServiceImage};
                        }
                    }
                }

                # To set parent service configuration
                $ServiceData{ServiceIcon}      = $ServiceIcon;
                $ServiceData{ServiceColor}     = $ServiceColor;
                $ServiceData{ServiceIconColor} = $ServiceIconColor;
                $ServiceData{ServiceImage}     = $ServiceImage;
                
                $LayoutObject->Block(
                    Name => 'ShowContractServiceDetailsReload',
                    Data => {
                        %ServiceData,
                        CardTransitionEffect => $CardTransitionEffect,
                        TitleStyle           => $StyleCardTitle,
                    }
                );    

                
                my @ServiceData2 = $ContractAndServicesObject->ContractAndServicesList(
                    ContractID => $Param{ContractID},
                    UserID     => $Self->{UserID}
                );

                # Return all Services in relation with CustomerUser.
                my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
                    Result            => 'HASH',
                    CustomerUserLogin => $Self->{UserID},
                    UserID            => 1,
                );      

                # Check ACL
                my $ACL = $TicketObject->TicketAcl(
                    Action         => $Self->{Action}, 
                    CustomerUserID => $Self->{UserID},
                    ReturnType     => 'Ticket',
                    ReturnSubType  => 'Service',
                    Data           => \%CustomerServices,
                );

                if($ACL){
                    %CustomerServices = $TicketObject->TicketAclData();
                }        

                # Filter Services based on relation with CustomerUser and KeepChildren config.
                my %ServiceList;

                for my $FilterServiceID ( @ServiceData2 ) {
                    if ( $CustomerServices{$FilterServiceID} ) {

                        # get service data
                        my %ServiceDataGet = $ServiceObject->ServiceGet(
                            ServiceID      => $FilterServiceID,
                            CustomerUserID => $CustomerUser || '',
                            UserID         => 1,
                        );

                        if(!$ServiceDataGet{ServiceImage} && !$ServiceDataGet{ServiceIcon} ){
                            $ServiceDataGet{ServiceImage} =  $ServiceData{ServiceImage};
                        }
                    
                        $ServiceDataGet{ServiceOrder} = $ServiceDataGet{ServiceOrder} || $ServiceDataGet{Name};

                        $ServiceList{$FilterServiceID} = $CustomerServices{$FilterServiceID};
                    }
                }

                # To get service back link url
                my $ServiceURLHome = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=Services";

                $LayoutObject->Block(
                    Name => 'BackURLContractReload',
                    Data => {
                        ServiceURLHome  => $ServiceURLHome,
                        BackgroundColor => $SideBarColor2,
                        Color           => $CustomerNavBarFontColors->{Menu},
                        ServiceID       => $ServiceData{ParentID},
                        ContractID      => $Param{ContractID},
                    }
                );

                my $OutputReload;
                my $Counter = 0;            

                for my $ServiceName ( sort values %ServiceList ) {

                    my $ServiceID = $ServiceObject->ServiceLookup( Name => $ServiceName );

                    my %SubServiceData = $ServiceObject->ServiceGet(
                        ServiceID      => $ServiceID,
                        CustomerUserID => $CustomerUser || '',
                        UserID         => 1,
                    );

                    $SubServiceData{ParentID} = $SubServiceData{ParentID} || '';

                    if ( !$SubServiceData{ServiceColor} ) {
                        # Get parent config of colors
                        if($ServiceData{ServiceColor}){
                            $SubServiceData{ServiceColor} = $ServiceData{ServiceColor};
                        }
                        else{
                            # Set config default to service card
                            $SubServiceData{ServiceColor} = $ServiceColorsDefault->{ServiceColor};
                        }
                    }

                    if ( !$SubServiceData{ServiceIcon} && !$SubServiceData{ServiceImage} ) {
                        # Get parent config of colors
                        if ( $ServiceData{ServiceImage} ) {
                            $SubServiceData{ServiceImage} = $ServiceData{ServiceImage};
                        }
                    }

                    $SubServiceData{ServiceImage} = $Self->_GetPathImage(
                        Image => $SubServiceData{ServiceImage},
                    );

                    if ( !$SubServiceData{ServiceIconColor} ) {
                        # Get parent config of colors
                        if ( $ServiceData{ServiceIconColor} ) {
                            $SubServiceData{ServiceIconColor} =  $ServiceData{ServiceIconColor};
                        }
                        else {
                            # Set config default to service card
                            $SubServiceData{ServiceIconColor} = $ServiceColorsDefault->{ServiceIconColor};
                        }
                    }

                    # Function to break service description text
                    my $SubStringDescription = '';
                    if ( $SubServiceData{ServiceDescription} ) {
                        # if ( length $SubServiceData{ServiceDescription} > 85 ) {
                        #     $SubStringDescription = substr $SubServiceData{ServiceDescription}, 0, 85;
                        #     $SubStringDescription .= '...';
                        # }
                        # else {
                        #     $SubStringDescription = $SubServiceData{ServiceDescription}
                        # }
                        $SubStringDescription = $SubServiceData{ServiceDescription}
                    }

                    my $StarFavoriteColor;

                    if ( $UserList{$Self->{UserID}} ) {

                        my $ServicesPrefeUser = $JSONObject->Decode(
                        Data => $UserList{$Self->{UserID}},
                        );

                        my %ParamsServices = map { $_ => 1}  @{$ServicesPrefeUser};

                        # Compare to not add services repeated
                        if ( exists( $ParamsServices{$SubServiceData{ServiceID}}) ) {
                            $StarFavoriteColor = 'ffc107';
                        }
                    }

                    if( $SubServiceData{ParentID} eq $Param{ServiceID} ) {

                        $Counter++;

                        if ( $CardFormat eq '1' ) {
                            if ( $CardDescription eq '1' ) {
                                $LayoutObject->Block(
                                    Name => 'TicketContractServiceDetailReloadRetangle',
                                    Data => {
                                        %SubServiceData,
                                        ContractID             => $Param{ContractID},
                                        SubStringDescription   => $SubStringDescription,
                                        StarFavoriteColor      => $StarFavoriteColor,
                                        CardSize               => $CardSize,
                                        CardTransitionEffect   => $CardTransitionEffect,
                                        DescriptionHeigthClass => "DescriptionHeigth-$CardSize",
                                        NotDisplayDescription  => 'HiddenElement',
                                        TitleStyle           => $StyleCardTitle,
                                    }
                                );
                            }
                            else {
                                $LayoutObject->Block(
                                    Name => 'TicketContractServiceDetailReloadRetangle',
                                    Data => {
                                        %SubServiceData,
                                        ContractID           => $Param{ContractID},
                                        SubStringDescription => $SubStringDescription,
                                        StarFavoriteColor    => $StarFavoriteColor,
                                        CardSize             => $CardSize,
                                        CardTransitionEffect => $CardTransitionEffect,
                                        TitleStyle           => $StyleCardTitle,
                                    }
                                );
                            }                        
                        }
                        else {
                            if ( $CardDescription eq '1' ) {
                                $LayoutObject->Block(
                                    Name => 'TicketContractServiceDetailReload',
                                    Data => {
                                        %SubServiceData,
                                        ContractID              => $Param{ContractID},
                                        SubStringDescription    => $SubStringDescription,
                                        StarFavoriteColor       => $StarFavoriteColor,
                                        CardSize                => $CardSize,
                                        CardTransitionEffect    => $CardTransitionEffect,
                                        DescriptionHeigthClass  => "DescriptionHeigthSquare-$CardSize",
                                        NotDisplayDescription   => 'HiddenElement',
                                        TitleStyle           => $StyleCardTitle,
                                    }
                                );
                            }
                            else {
                                $LayoutObject->Block(
                                    Name => 'TicketContractServiceDetailReload',
                                    Data => {
                                        %SubServiceData,
                                        ContractID           => $Param{ContractID},
                                        SubStringDescription => $SubStringDescription,
                                        StarFavoriteColor    => $StarFavoriteColor,
                                        CardSize             => $CardSize,
                                        CardTransitionEffect => $CardTransitionEffect,
                                        TitleStyle           => $StyleCardTitle,
                                    }
                                );
                            }                      
                        }                  
                    }
                }

                $OutputReload = $LayoutObject->Output(
                    TemplateFile => 'CustomerPortalReloadServices',
                );

                my @ServicesLevel;
            
                my %ServiceDataToNavBar = (
                    Name     => $ServiceData{NameShort},
                    ParentID => $ServiceData{ParentID},
                );

                # Create HTML to NavBar 
                
                my $CounterSeparations = '';

                my %ContractData = $ContractObject->ContractGet(
                    ContractID => $Param{ContractID},
                    UserID     => $Self->{UserID},
                );

                $HTML .= "<a href='#' onclick='Core.Customer.CustomerPortalReloadServices.ReloadContractService($Param{ContractID})'>$ContractData{Name}</a>  → ";

                for my $ServiceParentID ( @{$ServiceParentsList} ) {

                    my %ServiceDataParent = $ServiceObject->ServiceGet(
                        ServiceID => $ServiceParentID,
                        UserID    => 1,
                    );

                    $CounterSeparations++;

                    $HTML .= "<a href='#' onclick='Core.Customer.CustomerPortalReloadServices.ReloadContractService($Param{ContractID}, $ServiceParentID)'>$ServiceDataParent{NameShort}</a>";

                    if( scalar @{$ServiceParentsList} ne $CounterSeparations) {
                        $HTML .= " → ";
                    }
                }                

                push @ServicesLevel, \%ServiceDataToNavBar;
                    
                if ( $Counter > 0 ) {              
                    $JSON = $JSONObject->Encode(
                        Data => {
                            HTMLString        => $OutputReload,
                            NextView          => '',
                            ServiceParentName => $ServiceData{Name},
                            ServicesLevel     => $HTML,
                            ExternalLink      => ''
                        },
                    );
                }
                else{
                
                    if ( $ServiceData{ServiceExternalLink} ) {
                        $JSON = $JSONObject->Encode(
                            Data => {
                                HTMLString        => '',
                                NextView          => '',
                                ServiceParentName => $ServiceData{Name},
                                ServicesLevel     => $HTML,
                                ExternalLink      => $ServiceData{ServiceExternalLink},
                            },
                        );
                    }
                    else {
                        # Verify if exists FAQ in service
                        if( $ServiceData{ServiceFAQID}){

                            my %FAQData = $FAQObject->FAQGet(
                                ItemID     => $ServiceData{ServiceFAQID},
                                ItemFields => 1,
                                UserID     => $Self->{UserID},
                            );

                            if( %FAQData && $FAQData{State} ne 'internal (agent)' ){

                                $JSON = $JSONObject->Encode(
                                        Data => {
                                        HTMLString        => '',
                                        NextView          => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=FAQOfService;FAQID=".$ServiceData{ServiceFAQID}.";ServiceID=".$ServiceData{ServiceID}.";ContractID=".$Param{ContractID},
                                        ServiceParentName =>  $ServiceData{Name},
                                        ServicesLevel     => $HTML,
                                        ExternalLink      => ''
                                    },
                                );
                            }
                            else{
                                $JSON = $JSONObject->Encode(
                                    Data => {
                                        HTMLString        => '',
                                        NextView          => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=NewTicketService;ServiceID=".$Param{ServiceID}.";ContractID=".$Param{ContractID},
                                        ServiceParentName =>  $ServiceData{Name},
                                        ServicesLevel     => $HTML,
                                        ExternalLink      => ''
                                    },
                                );
                            }
                        }
                        else{
                            $JSON = $JSONObject->Encode(
                                Data => {
                                    HTMLString        => '',
                                    NextView          => '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=NewTicketService;ServiceID=".$Param{ServiceID}.";ContractID=".$Param{ContractID},
                                    ServiceParentName =>  $ServiceData{Name},
                                    ServicesLevel     => $HTML,
                                    ExternalLink      => ''
                                },
                            );
                        }                    
                    }
                }
            }
            else {

                $LayoutObject->Block(
                    Name => 'ShowContractServiceDetailsReload',
                    Data => {
                        # %ServiceData,
                        CardTransitionEffect => $CardTransitionEffect,
                        TitleStyle           => $StyleCardTitle,
                    }
                );             
                
                # return all Services in relation with CustomerUser.
                my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
                    Result            => 'HASH',
                    CustomerUserLogin => $Self->{UserID},
                    UserID            => 1,
                );

                # check ACL
                my $ACL = $TicketObject->TicketAcl(
                    Action         => $Self->{Action}, 
                    CustomerUserID => $Self->{UserID},
                    ReturnType     => 'Ticket',
                    ReturnSubType  => 'Service',
                    Data           => \%CustomerServices,
                );

                if ( $ACL ) {
                    %CustomerServices = $TicketObject->TicketAclData();
                }

                # return all Services in relation with CustomerUser.
                # return all Services in relation with services
                my @ServiceData2 = $ContractAndServicesObject->ContractAndServicesList(
                    ContractID => $Param{ContractID},
                    UserID     => $Self->{UserID}
                );

                # filter Services based on relation with CustomerUser and KeepChildren config.
                my %ServiceList;

                # for my $FilterServiceID ( sort keys %AllServices ) {
                for my $FilterServiceID ( @ServiceData2 ) {

                    if($CustomerServices{$FilterServiceID}){
                        $ServiceList{$FilterServiceID} = $CustomerServices{$FilterServiceID};
                    }
                }

                my $LastLoopService = '';

                my $OutputReload;
                my $Counter = 0;

                for my $ServiceName (sort values %ServiceList) {
                    
                    my $ServiceID = $ServiceObject->ServiceLookup(Name => $ServiceName);

                    # get service data
                    my %ServiceData = $ServiceObject->ServiceGet(
                        ServiceID      => $ServiceID,
                        CustomerUserID => $CustomerUser || '',
                        UserID         => 1,
                    );

                    my @SubItens = split /::/, $ServiceData{Name};

                    my $Count = scalar @SubItens;

                    $ServiceData{Name} = $SubItens[0];

                    if( $Count > 1 ){

                        if( $LastLoopService ne $ServiceData{Name} ){

                            $LayoutObject->Block(
                                Name => 'ServiceParent',
                                Data => { Name => $ServiceData{Name} }
                            );
                        }

                        $LastLoopService = $ServiceData{Name};

                        my $LastServiceChild = $SubItens[-1];

                        $LayoutObject->Block(
                            Name => 'ServiceSubItem',
                            Data => {
                                SubItemName => $LastServiceChild,
                                ServiceID   => $ServiceID
                            }
                        );
                    }
                    else {

                        if ( !$ServiceData{ServiceColor} ) {
                            # set default configuration to service card
                            $ServiceData{ServiceColor} =  $ServiceColorsDefault->{ServiceColor};
                        }

                        if (!$ServiceData{ServiceIcon} ) {
                            # set default configuration to service card
                            $ServiceData{ServiceIcon} =  $ServiceColorsDefault->{ServiceIcon};
                        }

                        if ( !$ServiceData{ServiceIconColor} ) {
                            # set default configuration to service card
                            $ServiceData{ServiceIconColor} =  $ServiceColorsDefault->{ServiceIconColor};
                        }

                        # function to break service description text
                        my $SubStringDescription = '';

                        if ( $ServiceData{ServiceDescription} ) {

                            # if ( length $ServiceData{ServiceDescription} > 85 ) {
                            #     $SubStringDescription = substr $ServiceData{ServiceDescription}, 0, 85;
                            #     $SubStringDescription .= '...';
                            # }
                            # else {
                            #     $SubStringDescription = $ServiceData{ServiceDescription}
                            # }
                            $SubStringDescription = $ServiceData{ServiceDescription}
                        }

                        my $StarFavoriteColor;
                        if( $UserList{$Self->{UserID}} ) {

                            my $ServicesPrefeUser = $JSONObject->Decode(
                                Data => $UserList{$Self->{UserID}},
                            );

                            my %ParamsServices = map { $_ => 1}  @{$ServicesPrefeUser};

                            # Compare to not add services repeated
                            if(exists( $ParamsServices{$ServiceData{ServiceID}})) {
                                $StarFavoriteColor = 'ffc107';
                            }
                        }

                        if ( $CardFormat eq '1' ) {

                            if ( $CardDescription eq '1' ) {
                                
                                $LayoutObject->Block(
                                    # Name => 'TicketServiceRectangle',
                                    Name => 'TicketContractServiceDetailReloadRetangle',
                                    Data => {
                                        %ServiceData,
                                        ContractID           => $Param{ContractID},
                                        SubStringDescription => $SubStringDescription,
                                        StarFavoriteColor    => $StarFavoriteColor,
                                        CardSize             => $CardSize,
                                        CardTransitionEffect => $CardTransitionEffect,
                                        DescriptionHeigthClass    => "DescriptionHeigth-$CardSize",
                                        NotDisplayDescription  => 'HiddenElement',
                                        TitleStyle           => $StyleCardTitle,
                                    }
                                );
                            }
                            else {

                                $LayoutObject->Block(
                                    # Name => 'TicketServiceRectangle',
                                    Name => 'TicketContractServiceDetailReloadRetangle',
                                    Data => {
                                        %ServiceData,
                                        ContractID           => $Param{ContractID},
                                        SubStringDescription => $SubStringDescription,
                                        StarFavoriteColor    => $StarFavoriteColor,
                                        CardSize             => $CardSize,
                                        CardTransitionEffect => $CardTransitionEffect,
                                        TitleStyle           => $StyleCardTitle,
                                    }
                                );
                            }
                        }
                        else {

                            if ( $CardDescription eq '1' ) {

                                $LayoutObject->Block(
                                    # Name => 'TicketService',
                                    Name => 'TicketContractServiceDetailReload',
                                    Data => {
                                        %ServiceData,
                                        ContractID             => $Param{ContractID},
                                        SubStringDescription   => $SubStringDescription,
                                        StarFavoriteColor      => $StarFavoriteColor,
                                        CardSize               => $CardSize,
                                        CardTransitionEffect   => $CardTransitionEffect,
                                        DescriptionHeigthClass => "DescriptionHeigthSquare-$CardSize",
                                        NotDisplayDescription  => 'HiddenElement',
                                        TitleStyle           => $StyleCardTitle,
                                    }
                                ); 
                            }
                            else {

                                $LayoutObject->Block(
                                    # Name => 'TicketService',
                                    Name => 'TicketContractServiceDetailReload',
                                    Data => {
                                        %ServiceData,
                                        ContractID           => $Param{ContractID},
                                        SubStringDescription => $SubStringDescription,
                                        StarFavoriteColor    => $StarFavoriteColor,
                                        CardSize             => $CardSize,
                                        CardTransitionEffect => $CardTransitionEffect,
                                        TitleStyle           => $StyleCardTitle,
                                    }
                                );
                            }                 
                        }
                    }
                }

                my $ServiceURLHome = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=Services";

                $LayoutObject->Block(
                    Name => 'BackURLContractReload',
                    Data => {
                        ServiceURLHome  => $ServiceURLHome,
                        BackgroundColor => $SideBarColor2,
                        Color           => $CustomerNavBarFontColors->{Menu},
                        # ServiceID       => $ServiceData{ParentID},
                        # ContractID      => $Param{ContractID},
                        FlagHome        => 1,
                    }
                );

                my %ContractData = $ContractObject->ContractGet(
                    ContractID => $Param{ContractID},
                    UserID     => $Self->{UserID},
                );

                $HTML .= "<a href='#' onclick='Core.Customer.CustomerPortalReloadServices.ReloadServiceBackButton()'>$ContractData{Name}</a>";

                $OutputReload = $LayoutObject->Output(
                    TemplateFile => 'CustomerPortalReloadServices',
                );

                $JSON = $JSONObject->Encode(
                    Data => {
                        HTMLString        => $OutputReload,
                        NextView          => '',
                        # ServiceParentName => $ServiceData{Name},
                        ServiceParentName => '',
                        ServicesLevel     => $HTML,
                        ExternalLink      => ''
                    },
                );
            }
		}
		else {
            $JSON = $JSONObject->Encode(
                Data => {
                    HTMLString => '',
                    NextView   => "Action=Services",
                },
            );
		}

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
	}
    # ------------------------------------------------------------ #
    # add service to favorites
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddSFavoriteService' ) {

        $GetParam{ServiceIDToFavorite} = $ParamObject->GetParam( Param => 'ServiceIDToFavorite' );

        my $ServicesInPref = $JSONObject->Decode(
            Data => $UserList{$Self->{UserID}},
        );

        my %ParamsServices = map { $_ => 1} @{$ServicesInPref};
        my $JSON = "{}";
        my $HTMLString;

       
        # Compare to not add services repeated
        if ( ! exists( $ParamsServices{$GetParam{ServiceIDToFavorite}}) ) {

            my $FavoriteServicesLimit = $ConfigObject->Get('CustomerPortal::Core::FavoriteServicesLimit');

            if ( scalar @{$ServicesInPref} < $FavoriteServicesLimit ){

                push @{$ServicesInPref}, $GetParam{ServiceIDToFavorite};

                my $JSONString = $JSONObject->Encode(
                    Data => $ServicesInPref,
                );
        

                $CustomerUserObject->SetPreferences(
                Key    => 'ServiceFavorite',
                Value  => $JSONString,
                UserID => $Self->{UserID},
                );

                my %ServiceData = $ServiceObject->ServiceGet(
                    ServiceID => $GetParam{ServiceIDToFavorite},
                    UserID    => 1,
                );

                # Return all Services, filtering by KeepChildren config.
                my %AllServices = $ServiceObject->ServiceList(
                    KeepChildren => $ConfigObject->Get('Ticket::Service::KeepChildren'),
                    Valid        => 1,
                    UserID       => 1,
                );

                # Check ACL
                my $ACL = $TicketObject->TicketAcl(
                    Action         => $Self->{Action}, 
                    CustomerUserID => $Self->{UserID},
                    ReturnType     => 'Ticket',
                    ReturnSubType  => 'Service',
                    Data           => \%AllServices,
                );

                if($ACL){
                    %AllServices = $TicketObject->TicketAclData();
                }

                # Return all Services in relation with CustomerUser.
                my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
                    Result            => 'HASH',
                    CustomerUserLogin => $Self->{UserID},
                    UserID            => 1,
                );

                # Filter Services based on relation with CustomerUser and KeepChildren config.
                my %ServiceList;

                for my $FilterServiceID ( sort keys %AllServices ) {
                    if ( $CustomerServices{$FilterServiceID} ) {
                        $ServiceList{$FilterServiceID} = $CustomerServices{$FilterServiceID};
                    }
                }

                my $Counter = 0;
                my $Link ='Action=Services';

                for my $ServiceName ( sort values %ServiceList ) {

                    my $ServiceID = $ServiceObject->ServiceLookup( Name => $ServiceName );

                    my %SubServiceData = $ServiceObject->ServiceGet(
                        ServiceID => $ServiceID,
                        UserID    => 1,
                    );

                    if ( $SubServiceData{ParentID} eq  $GetParam{ServiceIDToFavorite} ) {
                        $Counter++;
                    }

                    if ( $ServiceData{ServiceExternalLink} ) {
                        $Link = $ServiceData{ServiceExternalLink};

                    }
                    else {

                        if ( $Counter > 0 ) {     

                            if ( $ServiceData{ParentID} ) {
                                $Link = "[% Env('Baselink') %]Action=Services;Subaction=ServiceDetails;ServiceID=".$ServiceData{ParentID};
                            }
                            else {
                                $Link = "[% Env('Baselink') %]Action=Services;";
                            }
                        }
                        else {
                            $Link= "[% Env('Baselink') %]Action=NewTicketService;ServiceID=".$GetParam{ServiceIDToFavorite};
                        }
                    }
                }

                $HTMLString = "<li class='ServiceFav-$ServiceData{ServiceID} [% IF Data.Active == 'ServiceFavorite' %] active [% END %]'>".
                    "<a>".
                    "<span class='sidebar-mini-icon' title='Remover'>".
                    "<i style='color: #$ServiceData{SubMenuFontColor}; z-index:1' data-service-favorite-remove='$ServiceData{ServiceID}'  class='fa fa-trash RemoveFavorite' aria-hidden='true'></i>".
                    " </span><span data-serviceNewTicketLink='$Link' title='$ServiceData{ServiceName}' class='sidebar-normal' style='color: #$ServiceData{SubMenuFontColor}; margin-left: 28px;'> $ServiceData{NameShort}</span></a></li>";


                $JSON = $JSONObject->Encode(
                    Data => {
                        HTMLString => $HTMLString,
                        ServiceID  => $ServiceData{ServiceID},
                    },
                );

            }
            else{
                my $TextToLimit = $LayoutObject->{LanguageObject}->Translate('Cannot add favorite because favorite limit has been reached!');

                $HTMLString = "<div id='ModalLimitServiceFavorite' class='ModalLimitService'>".
                    "<div class='modal-content ModalContentStarVote '>".
                        "<span id='ModalCloseServiceFavorite' class='close CloseModalStarVote'>×</span>".
                        "<div id='ModalFormLimitService'>".
                            "<p style='margin: 0px;'>$TextToLimit</p> <br>".                                                       
                        "</div>".
                    "</div>".
                "</div>";
 

                $JSON = $JSONObject->Encode(
                    Data => {
                        ModalHTMLString => $HTMLString,
                    },
                );
            }


        }

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    # ------------------------------------------------------------ #
    # show service details
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ServiceDetails' ) {

        my $LinkObject = $Kernel::OM->Get('Kernel::System::LinkObject');
        my $FAQObject  = $Kernel::OM->Get('Kernel::System::FAQ');
        
		$Param{ServiceID}    = $ParamObject->GetParam( Param => 'ServiceID' );
		$Param{FirstService} = $ParamObject->GetParam( Param => 'FirstService' );

		$Param{Title}  = 'Services';
		$Param{Active} = 'Services';

        my $CustomerUser = $Self->{UserID};

        my $ServiceColorsDefault = $ConfigObject->Get('CustomerPortal::Core::ServiceColorsDefault');

        # Get Config of size, format and transition effect of card
        my $CardTransitionEffect =  $ConfigObject->Get('CustomerPortal::Core::CardTransitionEffect');
        my $CardDescription      =  $ConfigObject->Get('CustomerPortal::Core::ToSetDescriptionInCard');
        my $CardFormat           =  $ConfigObject->Get('CustomerPortal::Core::CardFormat');
        my $CardSize             =  $ConfigObject->Get('CustomerPortal::Core::CardSize');

        
        if( $Param{FirstService} && $ServiceView eq 'TreeView' ) {
            # redirect
			return $LayoutObject->Redirect(
				OP => "Action=Services",
			);
        }
        # elsif( $Param{ServiceID} && $ServiceView eq 'TreeView' ) {
			
        # }
		elsif ( $Param{ServiceID} && ( $ServiceView ne 'TreeView' && $FisrtLevelCard ne 'TreeView' ) ) {

			my %ServiceData = $ServiceObject->ServiceGet(
				ServiceID      => $Param{ServiceID},
                CustomerUserID => $CustomerUser || '',
				UserID         => 1,
			);

            my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
                ServiceID      => $Param{ServiceID},
                CustomerUserID => $CustomerUser || '',
                UserID         => 1,
            );

            push @{$ServiceParentsList}, $Param{ServiceID};

            my $ServiceIcon      = '';
            my $ServiceColor     = '';
            my $ServiceIconColor = '';
            my $ServiceImage = '';

            SERVICEFATHER:
            for my $ServiceFather ( reverse @{$ServiceParentsList} ) {

                my %ServiceDataFather = $ServiceObject->ServiceGet(
                    ServiceID      => $ServiceFather,
                    CustomerUserID => $CustomerUser || '',
                    UserID         => 1,
                );

                if ( !$ServiceIcon ) {
                    if( $ServiceDataFather{ServiceIcon} ) {
                        $ServiceIcon = $ServiceDataFather{ServiceIcon};
                    }
                }

                if ( !$ServiceColor ) {
                    if ( $ServiceDataFather{ServiceColor} ) {
                        $ServiceColor = $ServiceDataFather{ServiceColor};
                    }
                }

                if ( !$ServiceIconColor ) {
                    if ( $ServiceDataFather{ServiceIconColor} ) {
                        $ServiceIconColor = $ServiceDataFather{ServiceIconColor};
                    }
                }

                if ( !$ServiceImage ) {
                    if ( $ServiceDataFather{ServiceImage} ) {
                        $ServiceImage = $ServiceDataFather{ServiceImage};
                    }
                }
            }

            # To set parent service configuration
            $ServiceData{ServiceIcon}      = $ServiceIcon;
            $ServiceData{ServiceColor}     = $ServiceColor;
            $ServiceData{ServiceIconColor} = $ServiceIconColor;
            $ServiceData{ServiceImage}     = $ServiceImage;

			$LayoutObject->Block(
				Name => 'ShowServiceDetails',
				Data => \%ServiceData
			);

            # Return all Services, filtering by KeepChildren config.
            my %AllServices = $ServiceObject->ServiceList(
                KeepChildren => $ConfigObject->Get('Ticket::Service::KeepChildren'),
                Valid        => 1,
                UserID       => 1,
            );

            # Check ACL
            my $ACL = $TicketObject->TicketAcl(
                Action         => $Self->{Action}, 
                CustomerUserID => $Self->{UserID},
                ReturnType     => 'Ticket',
                ReturnSubType  => 'Service',
                Data           => \%AllServices,
            );

            if($ACL){
                %AllServices = $TicketObject->TicketAclData();
            }

            # Return all Services in relation with CustomerUser.
            my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
                Result            => 'HASH',
                CustomerUserLogin => $Self->{UserID},
                UserID            => 1,
            );

            # Filter Services based on relation with CustomerUser and KeepChildren config.
            my %ServiceList;
            for my $FilterServiceID ( sort keys %AllServices ) {
                
                # get service data
                my %ServiceDataGet = $ServiceObject->ServiceGet(
                    ServiceID      => $FilterServiceID,
                    CustomerUserID => $CustomerUser || '',
                    UserID         => 1,
                );

                $ServiceDataGet{ServiceOrder} = $ServiceDataGet{ServiceOrder} || $ServiceDataGet{Name};

                $ServiceList{$FilterServiceID} = \%ServiceDataGet;
            }

            # To get service back link url
            my $BackURL;

            my $ServiceURLHome = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=Services";

            if ( $ServiceData{ParentID} ) {
                $BackURL = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=Services;Subaction=ServiceDetails;ServiceID=$ServiceData{ParentID}"
            }
            else {
                $BackURL = '/' . $ConfigObject->Get('ScriptAlias') . "customer.pl?Action=Services";
            }

            $LayoutObject->Block(
                Name => 'BackURL',
                Data => {
                    BackURL         => $BackURL,
                    ServiceURLHome  => $ServiceURLHome,
                    BackgroundColor => $SideBarColor2,
                    Color           => $CustomerNavBarFontColors->{Menu},
                }
            );

            my $Counter = 0;
			# for my $ServiceName ( sort values %ServiceList ) {
            #for my $ServiceName ( sort { ncmp($a->{ServiceOrder},$b->{ServiceOrder}) } values %ServiceList ){
            # If the service has • at the beginning, it will be added at the end
            for my $ServiceName (
                    sort {
                        ($a->{ServiceOrder} =~ /^•/ ? 1 : 0) <=> ($b->{ServiceOrder} =~ /^•/ ? 1 : 0)
                            ||
                        ncmp($a->{ServiceOrder}, $b->{ServiceOrder})
                    } values %ServiceList
                ) {

                if ( !$ServiceName->{ServiceColor} ) {
                    # Get parent config of colors
                    if ( $ServiceData{ServiceColor} ) {
                        $ServiceName->{ServiceColor} = $ServiceData{ServiceColor};
                    }
                    else {
                        # Set config default to service card
                        $ServiceName->{ServiceColor} = $ServiceColorsDefault->{ServiceColor};
                    }
                }

                if( !$ServiceName->{ServiceIcon} ) {
                    # Get parent config of colors
                    if ( $ServiceData{ServiceIcon} ) {
                        $ServiceName->{ServiceIcon} = $ServiceData{ServiceIcon};
                    }
                    else {
                        # Set config default to service card
                        $ServiceName->{ServiceIcon} = $ServiceColorsDefault->{ServiceIcon};
                    }
                }

                if ( !$ServiceName->{ServiceIconColor} ) {
                    # Get parent config of colors
                    if ( $ServiceData{ServiceIconColor} ) {
                        $ServiceName->{ServiceIconColor} = $ServiceData{ServiceIconColor};
                    }
                    else {
                        # Set config default to service card
                        $ServiceName->{ServiceIconColor} = $ServiceColorsDefault->{ServiceIconColor};
                    }
                }

                if ( !$ServiceName->{ServiceImage} ) {
                    # Get parent config of colors
                    if ( $ServiceData{ServiceImage} ) {
                        $ServiceName->{ServiceImage} =  $ServiceData{ServiceImage};
                    }
                }

                $ServiceName->{ServiceImage} = $Self->_GetPathImage(
                    Image => $ServiceName->{ServiceImage},
                );

                # Function to break service description text
                my $SubStringDescription = '';

                if ( $ServiceName->{ServiceDescription} ) {

                    # if ( length $SubServiceData{ServiceDescription} > 85 ) {
                    #     $SubStringDescription = substr $SubServiceData{ServiceDescription}, 0, 85;
                    #     $SubStringDescription .= '...';
                    # }
                    # else {
                    #     $SubStringDescription = $SubServiceData{ServiceDescription}
                    # }
                    $SubStringDescription = $ServiceName->{ServiceDescription}
                }

                my $StarFavoriteColor;

                if ( $UserList{$Self->{UserID}} ) {

                    my $ServicesPrefeUser = $JSONObject->Decode(
                       Data => $UserList{$Self->{UserID}},
                    );

                    my %ParamsServices = map { $_ => 1}  @{$ServicesPrefeUser};

                    # Compare to not add services repeated
                    if ( exists( $ParamsServices{$ServiceName->{ServiceID}}) ) {
                        $StarFavoriteColor = 'ffc107';
                    }
                }

                my $LinkListWithData = $LinkObject->LinkListWithData(
                    Object => 'Service',
                    Key    => $ServiceName->{ServiceID},
                    State  => 'Valid',
                    UserID => 1,
                );			

                if ( $ServiceName->{ParentID} eq  $Param{ServiceID} ) {

                    $Counter++;

                    if ( $CardFormat eq '1' ) {

                        if ( $CardDescription eq '1' ) {

                            $LayoutObject->Block(
                                Name => 'TicketServiceDetailRectangle',
                                Data => {
                                    %{$ServiceName},
                                    SubStringDescription      => $SubStringDescription,
                                    StarFavoriteColor         => $StarFavoriteColor,
                                    CardSize                  => $CardSize,
                                    CardTransitionEffect      => $CardTransitionEffect, 
                                    DescriptionHeigthClass    => "DescriptionHeigth-$CardSize",
                                    NotDisplayDescription     => 'HiddenElement',
                                    TitleStyle           => $StyleCardTitle,
                                }
                            );
                        }
                        else {
                            $LayoutObject->Block(
                                Name => 'TicketServiceDetailRectangle',
                                Data => {
                                    %{$ServiceName},
                                    SubStringDescription => $SubStringDescription,
                                    StarFavoriteColor    => $StarFavoriteColor,
                                    CardSize             => $CardSize,
                                    CardTransitionEffect => $CardTransitionEffect, 
                                    TitleStyle           => $StyleCardTitle,
                                }
                            );
                        }                       
                    }
                    else {
                        if ( $CardDescription eq '1' ) {

                            $LayoutObject->Block(
                                Name => 'TicketServiceDetail',
                                Data => {
                                    %{$ServiceName},
                                    SubStringDescription   => $SubStringDescription,
                                    StarFavoriteColor      => $StarFavoriteColor,
                                    CardSize               => $CardSize,
                                    CardTransitionEffect   => $CardTransitionEffect,
                                    DescriptionHeigthClass => "DescriptionHeigthSquare-$CardSize",
                                    NotDisplayDescription  => 'HiddenElement',
                                    TitleStyle           => $StyleCardTitle,
                                }
                            );
                        }
                        else {
                            $LayoutObject->Block(
                                Name => 'TicketServiceDetail',
                                Data => {
                                    %{$ServiceName},
                                    SubStringDescription => $SubStringDescription,
                                    StarFavoriteColor    => $StarFavoriteColor,
                                    CardSize             => $CardSize,
                                    CardTransitionEffect => $CardTransitionEffect,
                                    TitleStyle           => $StyleCardTitle,
                                }
                            );
                        }                     
                    }
                }
			}

            if ( $Counter > 0 ) {
                my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{Services});
                $Output   .= $LayoutObject->Output(
                    Data         => \%Param,
                    TemplateFile => 'Services',
                );
                $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

                # build output
                return $Output;
            }
            else {
                # build new ticket
                return $LayoutObject->Redirect(
    				OP => "Action=NewTicketService;ServiceID=".$Param{ServiceID},
    			);
            }
		}
		else {
			# redirect
			return $LayoutObject->Redirect(
				OP => "Action=Services",
			);
		}
	}
    # ------------------------------------------------------------ #
    # remove service from favorites
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'RemoveFavoriteService' ) {

        $GetParam{ServiceIDToRemove} = $ParamObject->GetParam( Param => 'ServiceIDToRemove' );

        my $ServicesInPref = $JSONObject->Decode(
            Data => $UserList{$Self->{UserID}},
        );

        @{$ServicesInPref} = grep { $_ != $GetParam{ServiceIDToRemove} }  @{$ServicesInPref};

        my $JSONString = $JSONObject->Encode(
            Data => $ServicesInPref,
        );

        $CustomerUserObject->SetPreferences(
           Key    => 'ServiceFavorite',
           Value  => $JSONString,
           UserID => $Self->{UserID},
        );

        my $JSONStringToResponse = $JSONObject->Encode(
            Data => $GetParam{ServiceIDToRemove} ,
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSONStringToResponse,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    # ------------------------------------------------------------ #
    # remove service from favorites
    # -
    elsif ( $Self->{Subaction} eq 'SearchAutocompleteService' ) {
       
        my $SearchTerm      = $ParamObject->GetParam( Param => 'SearchTerms' ) || '';
        my $Action          = $ParamObject->GetParam( Param => 'Module' );
        my $ServiceParentID = $ParamObject->GetParam( Param => 'ServiceParentID' );
        
        my $ServiceLevelObject = $Kernel::OM->Get('Kernel::System::ServiceCustomerPortal');

        my $MaxResults = $ConfigObject->Get('ServiceCustomerPortal::MaxResultsSearch') || 100;

       
        my %ServiceList = $ServiceLevelObject->ServiceParentSearchList(
            AllServices => 1,
            SearchTerm  => $SearchTerm
        );

        my $BuildData = $Self->_BuildServiceLevelJS(
            Action          => $Action,
            MaxResults      => $MaxResults,
            ServiceParentID => $ServiceParentID,
            SearchTerm      => $SearchTerm,
            ServiceList     => \%ServiceList,
            BuildData => []
        );

        # build JSON output
        my $JSON = $LayoutObject->JSONEncode(
            Data => $BuildData,
        );        
        
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    # ------------------------------------------------------------ #
    # remove service from favorites
    # -
    elsif ( $Self->{Subaction} eq 'SearchParentService' ) {
        
        my $SearchTerm      = $ParamObject->GetParam( Param => 'SearchTerms' ) || '';
        my $Action          = $ParamObject->GetParam( Param => 'Module' );
        my $ServiceParentID = $ParamObject->GetParam( Param => 'ServiceParentID' );

        my $ServiceLevelObject = $Kernel::OM->Get('Kernel::System::ServiceCustomerPortal');
        my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');

        my $MaxResults = $ConfigObject->Get('ServiceCustomerPortal::MaxResultsSearch') || 100;

        my $Queue = $ConfigObject->Get('Ticket::Frontend::CustomerTicketMessage')->{QueueDefault};            
        my $QueueID = $QueueObject->QueueLookup( Queue => $Queue );

        my $TypeNameDisplay = $ConfigObject->Get('CustomerPortal::Core::ServiceListViewDisplayName');            

        # list of services that the user has permission
        my %UserServices = $TicketObject->TicketServiceList(
            QueueID        => $QueueID,
            Action         => $Action,
            CustomerUserID => $Self->{UserID},
        );       

        my %Services = $ServiceLevelObject->ServiceParentList(
            ServiceParentID => $ServiceParentID,
        );

        my @Data;

        SERVICE:
        for my $ServiceID ( sort { $Services{$a} cmp $Services{$b} }  keys %Services ) {

            # next service if the user does not have permission
            next SERVICE if !$UserServices{$ServiceID};

            my %ServiceData = $ServiceObject->ServiceGet(
                ServiceID => $ServiceID,
                UserID    => 1,
            );

            my $ServiceLabel =  $ServiceData{Name};

            if( $TypeNameDisplay ){
                $ServiceLabel =  $ServiceData{NameShort};
            }

            my %ServiceParents = $ServiceLevelObject->ServiceParentSearchList(
                ServiceParentID => $ServiceID,
            );


            my $Last = 0;
            if ( !IsHashRefWithData(\%ServiceParents) ) {
                $Last = 1;
            }      

            if ( !( grep { $_->{Value} eq $ServiceID } @Data ) ) {

                push @Data, {
                    Label     => $ServiceLabel,
                    Comment   => $ServiceData{Comment},
                    Value     => $ServiceID,
                    LastLevel => \$Last
                };
            }

            last SERVICE if scalar @Data >= $MaxResults;
        }

        my @Others;
        my @Remaining;

        for my $Item (@Data) {
            if ( $Item->{Label} =~ /^(::)?outros?/i ) {
                push @Others, $Item;
            }
            else {
                push @Remaining, $Item;
            }
        }

        @Data = ( @Remaining, @Others );

        # build JSON output
        my $JSON = $LayoutObject->JSONEncode(
            Data => \@Data,
        );        
        
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }
    # ------------------------------------------------------------ #
    # show service cards
    # ------------------------------------------------------------ #
    else {
        

        $Param{Title}  = 'Services';
        $Param{Active} = 'Services';

        my $CustomerUser = $Self->{UserID};

        # get objects
        my $LinkObject         = $Kernel::OM->Get('Kernel::System::LinkObject');
        my $FAQObject          = $Kernel::OM->Get('Kernel::System::FAQ');
        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

        my $ServiceColorsDefault = $ConfigObject->Get('CustomerPortal::Core::ServiceColorsDefault');

        # Get Config of size, format and transition effect of card
        my $OpenTicketByContract = $ConfigObject->Get('CustomerPortal::Core::OpenTicketByContract');
        my $CardTransitionEffect = $ConfigObject->Get('CustomerPortal::Core::CardTransitionEffect');
        my $CardDescription      = $ConfigObject->Get('CustomerPortal::Core::ToSetDescriptionInCard');
        my $CardFormat           = $ConfigObject->Get('CustomerPortal::Core::CardFormat');
        my $CardSize             = $ConfigObject->Get('CustomerPortal::Core::CardSize');

        $LayoutObject->Block(
            Name => 'ShowNewTicket',
            Data => {}
        );

        # get field contract
        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => 'CustomerContract',
        );

        # if the contract configuration is enabled
        if ( $OpenTicketByContract && IsHashRefWithData($DynamicField) ) {

            $Param{Title}  = 'Contracts';
            $Param{Active} = 'Contracts';

            my $ContractAndCustomerUserObject = $Kernel::OM->Get('Kernel::System::ContractAndCustomerUser');
            my $ContractAndServicesObject     = $Kernel::OM->Get('Kernel::System::ContractAndServices');
            my $CustomerCompanyObject         = $Kernel::OM->Get('Kernel::System::CustomerCompany');
            my $CustomerUserObject            = $Kernel::OM->Get('Kernel::System::CustomerUser');
            my $ContractObject                = $Kernel::OM->Get('Kernel::System::ContractManagement');
            my $BackendObject                 = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

            # fetch contracts associated with the customer user
            my @ContractList = $ContractAndCustomerUserObject->ContractAndCustomerUserList(
            	CustomerUser => $Self->{UserID},
            	UserID       => $Self->{UserID},
                Valid        => 1,
            );       

            my %ContractUserList;
            for my $ContractID ( @ContractList ) {
                
                my $ContractName = $ContractObject->ContractLookup(
                    ID => $ContractID,
                );

                $ContractUserList{$ContractID} = $ContractName;
            }

            # check ACL
            my $ACL = $TicketObject->TicketAcl(
                Action         => $Self->{Action}, 
                CustomerUserID => $Self->{UserID},
                ReturnType     => 'Ticket',
                ReturnSubType  => 'Contract',
                Data           => \%ContractUserList,
            );

            if ( $ACL ) {
                %ContractUserList = $TicketObject->TicketAclData();
            }

            @ContractList = keys %ContractUserList;

            # if there are no contracts associated with the customer user, search for a customer company
            if ( !@ContractList && $ConfigObject->Get('ContractManagement::Core::ListingCompanyContracts') ) {

                my %List = $ContractObject->ContractCompany(
                    CustomerID => $Self->{CustomerID},
                    Valid      => 1
                );

                # check ACL
                my $ACL = $TicketObject->TicketAcl(
                    Action         => $Self->{Action}, 
                    CustomerUserID => $Self->{UserID},
                    ReturnType     => 'Ticket',
                    ReturnSubType  => 'Contract',
                    Data           => \%List,
                );

                if ( $ACL ) {
                    %List = $TicketObject->TicketAclData();
                }

                @ContractList = keys %List;
            }

            # Layout fixed
            my $BlockFormatContract       = "ContractRectangle";
            my $BlockFieldHelpDescription = "FieldHelpDescriptionRectangle";
            my $BlockDescriptionContract  = "DescriptionRectangle";
            $CardSize = "Medium";

            my $FlagCustomer;

            my $StandardFields = $ConfigObject->Get('CustomerPortal::CardContract::StandardFields');

            my @CustomerIDs = $CustomerUserObject->CustomerIDs(
                User => $Self->{UserID},
            );

            if ( @ContractList ) {

                CUSTOMERID:
                for my $CustomerID ( @CustomerIDs) {

                    my %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
                        CustomerID => $CustomerID,
                    );

                    $FlagCustomer = 1;

                    CONTRACT:
                    for my $ContractID ( @ContractList ) {

                        my $CountDescription = 0;

                        my %ContractData = $ContractObject->ContractGet(
                            ContractID => $ContractID,
                            UserID     => $Self->{UserID},
                        );

                        next CONTRACT if $CustomerID ne $ContractData{CustomerID};

                        if ( $FlagCustomer ) {

                            $LayoutObject->Block(
                                Name => "AreaCustomer",
                                Data => {
                                    CustomerName => $CustomerCompany{CustomerCompanyName},
                                    SideBarColor1 => $SideBarColor1,
                                    SideBarColor2 => $SideBarColor2,
                                    Color         => $CustomerNavBarFontColors->{Menu},
                                }
                            );

                            $FlagCustomer = 0;

                        }

                        $ContractData{ContractIcon}      = "fa-file-text-o";
                        $ContractData{ContractColor}     = $ServiceColorsDefault->{ServiceColor};
                        $ContractData{ContractIconColor} = $ServiceColorsDefault->{ServiceIconColor};

                        my $BR = "<br>";
                         
                        if ( length $ContractData{Name} > 27 ) {
                            $BR = "";
                        }

                        $LayoutObject->Block(
                            Name => $BlockFormatContract,
                            Data => {
                                %ContractData,
                                SubStringDescription => "",
                                CardSize             => $CardSize,
                                CardTransitionEffect => 'none',
                                Height               => '185',
                                BR                   => $BR,
                                TitleStyle           => $StyleCardTitle,
                            }
                        );

                        # return all Services in relation with CustomerUser.
                        my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
                            Result            => 'HASH',
                            CustomerUserLogin => $Self->{UserID},
                            UserID            => 1,
                        );

                        # return all services in relation with contract
                        my @ServiceData2 = $ContractAndServicesObject->ContractAndServicesList(
                            ContractID => $ContractID,
                            UserID     => $Self->{UserID}
                        );

                        # filter Services based on relation with CustomerUser and KeepChildren config.
                        my %ServiceList;
                        my @ServicesArray;

                        # for my $FilterServiceID ( sort keys %AllServices ) {
                        for my $FilterServiceID ( @ServiceData2 ) {

                            if($CustomerServices{$FilterServiceID}){
                                $ServiceList{$FilterServiceID} = $CustomerServices{$FilterServiceID};
                                push @ServicesArray, $FilterServiceID;
                            }
                        }

                        for my $ServiceID ( keys %ServiceList ) {

                            my %ServiceData = $ServiceObject->ServiceGet(
                                ServiceID      => $ServiceID,
                                CustomerUserID => $Self->{UserID} || '',
                                UserID         => 1,
                            );

                            # get parentent list
                            my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
                                ServiceID      => $ServiceData{ServiceID},
                                CustomerUserID => $Self->{UserID} || '',
                                UserID         => 1,
                            );

                            for my $Key ( @{$ServiceParentsList} ) {

                                @ServicesArray = grep {$_ ne $Key} @ServicesArray;
                            }
                        }

                        my $TotalServices = scalar @ServicesArray;

                        $LayoutObject->Block(
                            Name => $BlockDescriptionContract,
                            Data => {
                                %ContractData,
                                CardSize => $CardSize,
                                Label => $LayoutObject->{LanguageObject}->Translate('Services'),
                                Value => $TotalServices,
                            }
                        );

                        DYNAMICFIELD:
                        for my $DynamicFieldName ( @{$ConfigObject->Get('CustomerPortal::CardContract::DynamicFields')} ) {

                            last DYNAMICFIELD if $CountDescription == 3;

                            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                                Name => $DynamicFieldName,
                            );

                            next DYNAMICFIELD if !$DynamicFieldConfig;

                            my $Value = $BackendObject->ValueGet(
                                DynamicFieldConfig => $DynamicFieldConfig,
                                ObjectID           => $ContractData{ID},
                            );

                            next DYNAMICFIELD if !$Value;

                            $LayoutObject->Block(
                                Name => $BlockDescriptionContract,
                                Data => {
                                    %ContractData,
                                    CardSize => $CardSize,
                                    Label    => $DynamicFieldConfig->{Label},
                                    Value    => $Value,
                                }
                            );

                            $CountDescription++;
                        }

                        my %TranslateFields = (
                            "TotalHours" => $LayoutObject->{LanguageObject}->Translate('Total Hours'),
                            "PriorityID" => $LayoutObject->{LanguageObject}->Translate('Priority'),
                            "DocumentID" => $LayoutObject->{LanguageObject}->Translate('Document Number'),
                            "TypeHours"  => $LayoutObject->{LanguageObject}->Translate('Consumption'),
                            "StartDate"  => $LayoutObject->{LanguageObject}->Translate('Start Contract'),
                            "EndDate"    => $LayoutObject->{LanguageObject}->Translate('End Contract'),
                            "CustomerID" => $LayoutObject->{LanguageObject}->Translate('CustomerID'),
                            "TypeID"     => $LayoutObject->{LanguageObject}->Translate('Type'),
                            "SLAID"      => $LayoutObject->{LanguageObject}->Translate('SLA'),
                            "Name"       => $LayoutObject->{LanguageObject}->Translate('Name'),
                        );
                    
                        FIELDNAME:
                        for my $FieldName ( keys %{$StandardFields} ) {

                            last FIELDNAME if $CountDescription == 3;

                            next FIELDNAME if $StandardFields->{$FieldName} != 1;

                            if ( $FieldName eq "StartDate" || $FieldName eq "EndDate") {

                                my $DateTimeObject = $Kernel::OM->Create(
                                    'Kernel::System::DateTime',
                                    ObjectParams => {
                                        String   => $ContractData{$FieldName},
                                    }
                                );

                                $ContractData{$FieldName} = $DateTimeObject->Format( Format => '%d-%m-%Y' );
                            }

                            $LayoutObject->Block(
                                Name => $BlockDescriptionContract,
                                Data => {
                                    %ContractData,
                                    CardSize => $CardSize,
                                    Label    => $TranslateFields{$FieldName},
                                    Value    => $ContractData{$FieldName},
                                }
                            );

                            $CountDescription++;
                        }

                        my $StandardFieldsTooltip = $ConfigObject->Get('CustomerPortal::CardContract::StandardFieldsTooltip');

                        my $HTML = "";

                        FIELDNAME:
                        for my $FieldName ( keys %{$StandardFieldsTooltip} ) {

                            next FIELDNAME if $StandardFieldsTooltip->{$FieldName} != 1;

                            $HTML .= "$TranslateFields{$FieldName}: $ContractData{$FieldName}<br>";
                        }

                        DYNAMICFIELD:
                        for my $DynamicFieldName ( @{$ConfigObject->Get('CustomerPortal::CardContract::DynamicFieldsTooltip')} ) {

                            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                                Name => $DynamicFieldName,
                            );

                            next DYNAMICFIELD if !$DynamicFieldConfig;

                            my $Value = $BackendObject->ValueGet(
                                DynamicFieldConfig => $DynamicFieldConfig,
                                ObjectID           => $ContractData{ID},
                            );

                            next DYNAMICFIELD if !$Value;

                            $HTML .= "$DynamicFieldConfig->{Label}: $Value<br>";
                        }

                        $LayoutObject->Block(
                            Name => $BlockFieldHelpDescription,
                            Data => {
                                TextHTML => $HTML,
                            }
                        );
                    }
                }
            }
            else {
                $LayoutObject->Block(
                    Name => "NoContract",
                    Data => {
                    }
                );
            }
        }
        elsif ( $ServiceView eq 'TreeView' && $FisrtLevelCard eq 'TreeView' ) {

            my $ServiceLevelObject = $Kernel::OM->Get('Kernel::System::ServiceCustomerPortal');

            my $MaxResults = $ConfigObject->Get('ServiceCustomerPortal::MaxResultsSearch') || 100;

            $LayoutObject->Block(
                Name => "TreeView"
            );

            $LayoutObject->AddJSData(
                Key   => 'DynamicFieldsJS',
                Value => {
                    ServiceView => $ServiceView
                },
            ); 

            my %ServiceList = $ServiceLevelObject->ServiceParentSearchList(
                ServiceParentID => 0
            );           
            
            $Self->_BuildServiceFirstLevelHTML(
                MaxResults      => $MaxResults,
                ServiceParentID => 0,
                ServiceList     => \%ServiceList
            );
        }
        else {

            # return all Services, filtering by KeepChildren config.
            my %AllServices = $ServiceObject->ServiceList(
                UserID => 1,
                Valid  => 1,
                KeepChildren => $ConfigObject->Get('Ticket::Service::KeepChildren'),
            );
 
            # check ACL
            my $ACL = $TicketObject->TicketAcl(
                Action         => $Self->{Action}, 
                CustomerUserID => $Self->{UserID},
                ReturnType     => 'Ticket',
                ReturnSubType  => 'Service',
                Data           => \%AllServices,
            );

            if ( $ACL ) {
                %AllServices = $TicketObject->TicketAclData();
            }

            # return all Services in relation with CustomerUser.
            my %CustomerServices = $ServiceObject->CustomerUserServiceMemberList(
                Result            => 'HASH',
                CustomerUserLogin => $Self->{UserID},
                UserID            => 1,
            );

            # filter Services based on relation with CustomerUser and KeepChildren config.
            my %ServiceList;

            for my $FilterServiceID ( sort keys %AllServices ) {

                if($CustomerServices{$FilterServiceID}){

                    # get service data
                    my %ServiceData = $ServiceObject->ServiceGet(
                        ServiceID      => $FilterServiceID,
                        CustomerUserID => $CustomerUser || '',
                        UserID         => 1,
                    );

                    $ServiceData{ServiceOrder} = $ServiceData{ServiceOrder} || $ServiceData{Name};

                    $ServiceList{$FilterServiceID} = \%ServiceData;
                }
            }

            my $LastLoopService = '';

            $LayoutObject->Block(
                Name => 'ShowAsCategoryList',
                Data => {  }
            );

            # The for key compares the ServiceOrder attribute value to include services with value first 
            #for my $ServiceData ( sort { ncmp($a->{ServiceOrder}, $b->{ServiceOrder}) } values %ServiceList ){
            # If the service has • at the beginning, it will be added at the end
            for my $ServiceData (
                    sort {
                        ($a->{ServiceOrder} =~ /^•/ ? 1 : 0) <=> ($b->{ServiceOrder} =~ /^•/ ? 1 : 0)
                            ||
                        ncmp($a->{ServiceOrder}, $b->{ServiceOrder})
                    } values %ServiceList
                ) {

                my $ServiceID = $ServiceData->{ServiceID};

                my @SubItens = split /::/, $ServiceData->{Name};

                my $Count = scalar @SubItens;

                $ServiceData->{Name} = $SubItens[0];               

                if( $Count > 1 ){

                    if( $LastLoopService ne $ServiceData->{Name} ){

                        $LayoutObject->Block(
                            Name => 'ServiceParent',
                            Data => { Name => $ServiceData->{Name} }
                        );
                    }

                    $LastLoopService = $ServiceData->{Name};

                    my $LastServiceChild = $SubItens[-1];

                    $LayoutObject->Block(
                        Name => 'ServiceSubItem',
                        Data => {
                            SubItemName => $LastServiceChild,
                            ServiceID   => $ServiceID
                        }
                    );
                }
                else {

                    if ( !$ServiceData->{ServiceColor} ) {
                        # set default configuration to service card
                        $ServiceData->{ServiceColor} =  $ServiceColorsDefault->{ServiceColor};
                    }

                    if (!$ServiceData->{ServiceIcon} ) {
                        # set default configuration to service card
                        $ServiceData->{ServiceIcon} =  $ServiceColorsDefault->{ServiceIcon};
                    }

                    if ( !$ServiceData->{ServiceIconColor} ) {
                        # set default configuration to service card
                        $ServiceData->{ServiceIconColor} =  $ServiceColorsDefault->{ServiceIconColor};
                    }

                    $ServiceData->{ServiceImage} = $Self->_GetPathImage(
                        Image => $ServiceData->{ServiceImage},
                    );

                    # function to break service description text
                    my $SubStringDescription = '';

                    if ( $ServiceData->{ServiceDescription} ) {

                        $SubStringDescription = $ServiceData->{ServiceDescription};
                    }

                    my $StarFavoriteColor;

                    if( $UserList{$Self->{UserID}}){

                        my $ServicesPrefeUser = $JSONObject->Decode(
                            Data => $UserList{$Self->{UserID}},
                        );

                        my %ParamsServices = map { $_ => 1}  @{$ServicesPrefeUser};

                        # Compare to not add services repeated
                        if(exists( $ParamsServices{$ServiceData->{ServiceID}})) {
                            $StarFavoriteColor = 'ffc107';
                        }
                    }

                    # checking linked items
                    my $LinkListWithData = $LinkObject->LinkListWithData(
                        Object => 'Service',
                        Key    => $ServiceData->{ServiceID},
                        State  => 'Valid',
                        UserID => 1,
                    );

                    my %ParamCardDescription;

                    my $BlockName;

                    if ( $CardFormat eq '1' ) {

                        $BlockName = 'TicketServiceRectangle';

                        if ( $CardDescription eq '1' ) {

                            $ParamCardDescription{DescriptionHeigthClass} = "DescriptionHeigth-$CardSize";
                            $ParamCardDescription{NotDisplayDescription}  = 'HiddenElement';
                        }
                    }
                    else {

                        $BlockName = 'TicketService';

                        if ( $CardDescription eq '1' ) {

                            $ParamCardDescription{DescriptionHeigthClass} = "DescriptionHeigthSquare-$CardSize";
                            $ParamCardDescription{NotDisplayDescription}  = 'HiddenElement';
                        }
                    }

                    if ($ServiceData->{ServiceDescription}){
                        $ServiceData->{ServiceDescription} = '';
                    }

                    if ( $ServiceView eq 'ShowAsCategory' ) {

                        if ( $ServiceData->{ShowAsCategory} == 2) {
                            
                            $BlockName = 'ServiceListRow';
                        }
                        elsif ( $ServiceData->{ShowAsCategory} == 3 ) {

                            $BlockName = 'ServiceCard';

                            if ( !$Self->{MoreServices} ) {

                                $LayoutObject->Block(
                                    Name => 'MoreServices'
                                );

                                $Self->{MoreServices} = 1;
                            }
                        }

                        $LayoutObject->Block(
                            Name => $BlockName,
                            Data => {
                                %{$ServiceData},
                                SubStringDescription => $SubStringDescription,
                                StarFavoriteColor    => $StarFavoriteColor,
                                CardSize             => $CardSize,
                                CardTransitionEffect => $CardTransitionEffect,
                                TitleStyle           => $StyleCardTitle,
                                CardFormat           => $CardFormat,
                                %ParamCardDescription
                            }
                        );
                    }
                    else {

                        $LayoutObject->Block(
                            Name => $BlockName,
                            Data => {
                                %{$ServiceData},
                                SubStringDescription => $SubStringDescription,
                                StarFavoriteColor    => $StarFavoriteColor,
                                CardSize             => $CardSize,
                                CardTransitionEffect => $CardTransitionEffect,
                                TitleStyle           => $StyleCardTitle,
                                CardFormat           => $CardFormat,
                                %ParamCardDescription
                            }
                        );
                    }
                }
            }
            
            if ( $ServiceView ) {
                $LayoutObject->Block(
                    Name => 'TreeView'
                );

                $LayoutObject->AddJSData(
                    Key   => 'DynamicFieldsJS',
                    Value => {
                        ServiceView    => $ServiceView,
                        FisrtLevelCard => $FisrtLevelCard
                    },
                );
            }
        }       

        # build output
        my $Output = $CustomerPortalLayoutObject->CustomerHeader( Type => 'Small', Title => $ActionTitle->{Services} );        

        $Output   .= $LayoutObject->Output(
            Data         => \%Param,
            TemplateFile => 'Services',
        );
        $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }
}

sub _BuildServiceFirstLevelHTML {
    my ( $Self, %Param ) = @_;
    
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $ServiceLevelObject = $Kernel::OM->Get('Kernel::System::ServiceCustomerPortal');
    my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
    my $ServiceObject      = $Kernel::OM->Get('Kernel::System::Service');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Queue   = $ConfigObject->Get('Ticket::Frontend::CustomerTicketMessage')->{QueueDefault};            
    my $QueueID = $QueueObject->QueueLookup( Queue => $Queue );

    # list of services that the user has permission
    my %UserServices = $TicketObject->TicketServiceList(
        QueueID        => $QueueID,
        Action         => 'Services',
        CustomerUserID => $Self->{UserID},
    );

    my %ServiceList = %{ $Param{ServiceList} };
   
    SERVICE:
    for my $ServiceID ( sort { $ServiceList{$a} cmp $ServiceList{$b} } keys %ServiceList ) {

        # next service if the user does not have permission
        next SERVICE if !$UserServices{$ServiceID};

        my %ServiceData = $ServiceObject->ServiceGet(
            ServiceID => $ServiceID,
            UserID    => 1,
        );

        my %ServiceParents = $ServiceLevelObject->ServiceParentSearchList(
            ServiceParentID => $ServiceID,
        );

        my $Last = "false";
        if ( !IsHashRefWithData(\%ServiceParents) ) {
            $Last = "true";
        }  

        $LayoutObject->Block(
            Name => 'ServiceLevel',
            Data => {
                Label     => $ServiceData{Name},
                Comment   => $ServiceData{Comment},
                Value     => $ServiceID,
                LastLevel => $Last
            }
        );
    }

    return 1;
}

sub _BuildServiceLevelJS {
    my ( $Self, %Param ) = @_;

    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $ServiceLevelObject = $Kernel::OM->Get('Kernel::System::ServiceCustomerPortal');
    my $QueueObject        = $Kernel::OM->Get('Kernel::System::Queue');
    my $ServiceObject      = $Kernel::OM->Get('Kernel::System::Service');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');

    my $TypeNameDisplay = $ConfigObject->Get('CustomerPortal::Core::ServiceListViewDisplayName');            

    my $Queue   = $ConfigObject->Get('Ticket::Frontend::CustomerTicketMessage')->{QueueDefault};
    my $QueueID = $QueueObject->QueueLookup( Queue => $Queue );

    # list of services that the user has permission
    my %UserServices = $TicketObject->TicketServiceList(
        QueueID        => $QueueID,
        Action         => $Param{Action},
        CustomerUserID => $Self->{UserID},
    );       

    my %ServiceList = %{ $Param{ServiceList} };

    my $Data = $Param{BuildData};
 
    SERVICE:
    for my $ServiceID ( sort { $ServiceList{$a} cmp $ServiceList{$b} } keys %ServiceList ) {

        # next service if the user does not have permission
        next SERVICE if !$UserServices{$ServiceID};

        my %ServiceData = $ServiceObject->ServiceGet(
            ServiceID => $ServiceID,
            UserID    => 1,
        );
        
        my $ServiceLabel =  $ServiceData{Name};
        if( $TypeNameDisplay ){
            $ServiceLabel =  $ServiceData{NameShort};
        }
        my %ServiceParents = $ServiceLevelObject->ServiceParentSearchList(
            ServiceParentID => $ServiceID,
        );

        my $Last = 0;
        if ( !IsHashRefWithData(\%ServiceParents) ) {
            $Last = 1;
        }      

        if ( !( grep { $_->{Value} eq $ServiceID } @{ $Data } ) && $Last == 1) {

            push @{ $Data }, {
                Label     => $ServiceLabel,
                Comment   => $ServiceData{Comment},
                Value     => $ServiceID,
                LastLevel => \$Last
            };
        }

        $Self->_BuildServiceLevelJS(
            Action          => $Param{Action},
            MaxResults      => $Param{MaxResults},
            ServiceParentID => $Param{ServiceParentID},
            SearchTerm      => $Param{SearchTerm},
            ServiceList     => \%ServiceParents,
            BuildData       => $Data
        );

        last SERVICE if scalar @{ $Data } >= $Param{MaxResults};
    }

    return $Data;
}

sub _GetPathImage {
    my ( $Self, %Param ) = @_;

    return '' if !$Param{Image};

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    $Param{PathImage} = $ConfigObject->Get('Frontend::WebPath') . $Param{Image};

    if ( index($Param{Image}, 'http') != -1 || index($Param{Image}, 'https') != -1 || index($Param{Image}, 'ftp') != -1 ) {
        $Param{PathImage} = $Param{Image};
    }

    return $Param{PathImage};
}

1;