# --
# Kernel/Output/HTML/CustomerPortal.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * jguedes@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * dparavani@serviceup.com.br
# * dsilva@serviceup.com.br
# --


package Kernel::Output::HTML::CustomerPortal;

use strict;
use warnings;

use URI::Escape qw();
use Digest::MD5 qw(md5_hex);

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::JSON',
    'Kernel::System::User',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless $Self, $Type;

    return $Self;
}

sub CreateNavBar {
    my ( $Self, %Param ) = @_;

    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $CustomerUserObject   = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $UserObject           = $Kernel::OM->Get('Kernel::System::User');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');

    # ------------------------------------------------------------ #
    #  Getting Customer Configuration To SideBar
    # ------------------------------------------------------------ #
    my ($SideBarColor1, $SideBarColor2);

    my $CustomerNavBarColorsDefault = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarColorsDefault');
    my $CustomerNavBarColors        = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarColors');

    my $CustomerNavBarText = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarText');

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

    my $Layout = $ConfigObject->Get('CustomerPortal::Core::Layout');

    $LayoutObject->Block(
        Name => 'LayoutCSS',
        Data => {
            BodyColor                => $Layout->{BodyColor},
            MainPanelColor           => $Layout->{MainPanelColor},
            NavBarBackgroundColor    => $Layout->{NavBarBackgroundColor},
            NavBarItemColor          => $Layout->{NavBarItemColor},
            SelectedNavBarItemColor  => $Layout->{SelectedNavBarItemColor},
            TextPageLateralMenu      => $Layout->{TextPageLateralMenu},
            BorderNavBarColor        => $Layout->{BorderNavBarColor},
            SelectedItemSuspended    => $Layout->{SelectedItemSuspended},
            NavBarNotificationsIcons => $Layout->{NavBarNotificationsIcons},
            ButtonResponse           => $Layout->{ButtonResponse} || '#35ad6a',
            ButtonResponseFocus      => $Layout->{ButtonResponseFocus} || '#2d8856',
        }
    );


    my $MenuType = $ConfigObject->Get('CustomerPortal::Core::MenuType');

    my $SideBar;
    my $TopBar;

    if ( $MenuType == 0 ) {
        $SideBar = 1;
        $TopBar  = 0;
    }
    elsif ( $MenuType == 1 ) {
        $TopBar  = 1;
        $SideBar = 0;
    }

    if ( !$TopBar && !$SideBar ) {
        $SideBar = 1;
    }

    if ( $SideBar ) {

        $LayoutObject->Block(
            Name => 'CustomerSideBar',
            Data => {
                SideBarColor1     => $SideBarColor1,
                SideBarColor2     => $SideBarColor2,
                UserNameFontColor => $CustomerNavBarFontColors->{UserName},
                Active            => $Param{ActionActive},
            }
        );
    }

    if ( $TopBar ) {

        $LayoutObject->Block(
            Name => 'NavBarTop',
            Data => {
                Active => $Param{ActionActive}
            },
        );
    }

    $Param{HideSearch} = 0;
    if ( $Param{Action} eq 'MyTickets' || $Param{Action} eq 'CompanyTickets' ) {
        $Param{HideSearch} = 1;
    }
    
    if ( $Param{HideSearch} == 0 ) {

        $LayoutObject->Block(
            Name => 'NavBarSearch',
            Data => {
                Active => $Param{ActionActive},
                
            },
        );
    }

    $LayoutObject->Block(
        Name => 'NavBarIcons',
        Data => {
            Active => $Param{ActionActive},
            TopBar => $TopBar
        },
    );

    $LayoutObject->Block(
        Name => 'MainPanel',
        Data => {
            SideBar => $SideBar
        }
    );

    $LayoutObject->Block(
        Name => 'CustomerSideBar1',
        Data =>{
            SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
            MenuFontColor    => $CustomerNavBarFontColors->{Menu},
            Active           => $Param{ActionActive},
        }
    );

    # To FAQ
    if($ConfigObject->Get('CustomerPortal::Core::ToEnableShowFAQSideBar') eq '1'){

        $LayoutObject->Block(
            Name => 'CustomerSideBarFAQ',
            Data =>{
                SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                MenuFontColor    => $CustomerNavBarFontColors->{Menu},
                Active           => $Param{ActionActive},
            }
        );

        # top menu
        $LayoutObject->Block(
            Name => 'NavBarFAQ',
            Data => {
                Active => $Param{ActionActive},
            }
        );
    }
    

     # top menu
    $LayoutObject->Block(
        Name => 'NavBarTickets',
        Data => {
            Active => $Param{ActionActive}
        },
    );

    # To New Ticket
    if ( $ConfigObject->Get('CustomerPortal::Core::ToEnableShowNewTicketSideBar') eq '1' ) {

        $LayoutObject->Block(
            Name => 'CustomerSideBarNewTicket',
            Data => {
                Active => $Param{ActionActive}
            },
        );

        $LayoutObject->Block(
            Name => 'CustomerSideBar2',
            Data =>{
                SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                MenuFontColor    => $CustomerNavBarFontColors->{Menu},
                Active           => $Param{ActionActive},
            }
        );
    
        $LayoutObject->Block(
            Name => 'NavBarNewTicket',
            Data => {
                Active => $Param{ActionActive},
            }
        );
    }

    my $Controller = 0;

    # To ConsumptionHours
    if ( $ConfigObject->Get('CustomerPortal::Core::ToEnableConsumptionOfContract') eq '1' ) {

        my $ContractObject = $Kernel::OM->Get('Kernel::System::ContractManagement');

        my %List = $ContractObject->ContractCompany(
            CustomerID => $Param{CustomerID},
            Valid      => 1
        );

        if ( %List ) {

            $Controller = 1;

            $LayoutObject->Block(
                Name => 'ConsumptionOfContract',
                Data => {
                    SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                    MenuFontColor    => $CustomerNavBarFontColors->{Menu},
                    Active           => $Param{ActionActive},
                    NameAction       => $CustomerNavBarText->{ConsumptionOfContract} || 'Consumption of Contract',
                }
            );
            
            # top menu
            $LayoutObject->Block(
                Name => 'NavBarConsumptionOfContract',
                Data => {
                    Active => $Param{ActionActive},
                }
            );
        }
    }


    # To ConsumptionHours
    if ( $ConfigObject->Get('CustomerPortal::Core::ToEnableConsumptionOfHours') eq '1' ) {

        if ( $ConfigObject->Get('CustomerPortal::Core::HiddeConsuptionOfHoursIFContract') eq '1' ) {
            
            unless ($Controller) {
                $LayoutObject->Block(
                    Name => 'ConsumptionOfHoursNav',
                    Data =>{
                        SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                        MenuFontColor    => $CustomerNavBarFontColors->{Menu},
                        Active           => $Param{ActionActive},
                    }
                );

                # top menu
                $LayoutObject->Block(
                    Name => 'NavBarConsumptionOfHours',
                    Data => {
                        Active => $Param{ActionActive},
                    }
                );
            }
        }
        else {
            $LayoutObject->Block(
                Name => 'ConsumptionOfHoursNav',
                Data =>{
                    SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                    MenuFontColor    => $CustomerNavBarFontColors->{Menu},
                    Active           => $Param{ActionActive},
                }
            );

            # top menu
            $LayoutObject->Block(
                Name => 'NavBarConsumptionOfHours',
                Data => {
                    Active => $Param{ActionActive},
                }
            );
        }
    }

    # To notifications
    my $TotalOfNotifications = $CustomerPortalObject->CounterNotifications(
        CustomerUserLogin => $Param{UserID}, 
    );

    my $NotifyColor = '#66615b';

    if($TotalOfNotifications > 0 ){
        $NotifyColor = '#fa623f';
    }
    

    $LayoutObject->Block(
        Name => 'TotalOfNotifications',
        Data => {
            TotalOfNotifications => $TotalOfNotifications,
            NotifyColor          => $NotifyColor,
            Length               => length($TotalOfNotifications),
        }
    );

    if ( $ConfigObject->Get('CustomerPortal::Core::EnableUnansweredSurveys') ) {

        my %DataSurvey;

        if ( $Param{Action} ne 'CustomerPortalSurvey' ) {

            %DataSurvey = $CustomerPortalObject->GetSurveyCustomerUser(
                UserID => $Param{UserID}
            );
        }
        else {
            $DataSurvey{Counter} = '';
        }

        my $NotifyColorSurvey = '#66615b';

        if ( $DataSurvey{Counter} > 0 ) {
            $NotifyColorSurvey = '#fa623f';
        }

        $LayoutObject->Block(
            Name => 'TotalSurvey',
            Data => {
                TotalOfSurvey => $DataSurvey{Counter},
                NotifyColor   => $NotifyColorSurvey,
                Length        => length($DataSurvey{Counter}),
            }
        );
    }

    $LayoutObject->Block(
        Name => 'CustomerSideBar3',
        Data =>{
            SubMenuFontColor     => $CustomerNavBarFontColors->{SubMenu},
            MenuFontColor        => $CustomerNavBarFontColors->{Menu},
            Active               => $Param{ActionActive},
        }
    );
    
    if( $ConfigObject->Get('CustomerPortal::MyTickets::DisableMyTicketsMenu') eq 'No' ){
        # top menu
        $LayoutObject->Block(
            Name => 'NavBarMyTickets',
        );
    }

    # disable output of customer company tickets
    my $DisableCompanyTickets = $ConfigObject->Get('Ticket::Frontend::CustomerDisableCompanyTicketAccess');

    my $ConfigEnableCompanyTickets = $ConfigObject->Get('CustomerPortal::Core::ShowMenuCompanyTickets');

    my %User = $CustomerUserObject->CustomerUserDataGet(
        User => $Param{UserLogin},
    );

    if( $ConfigEnableCompanyTickets ){

        if( $User{$ConfigEnableCompanyTickets->{FieldName}} eq $ConfigEnableCompanyTickets->{FieldValue} ){

            if( !$DisableCompanyTickets ) {

                $LayoutObject->Block(
                    Name => 'EnableCompanyTickets',
                    Data =>{
                        SubMenuFontColor     => $CustomerNavBarFontColors->{SubMenu},
                        MenuFontColor        => $CustomerNavBarFontColors->{Menu},
                        Active               => $Param{ActionActive},
                    }
                );

                # top menu
                $LayoutObject->Block(
                    Name => 'NavBarCompanyTickets',
                );
            }
        }
    }
    else {

        if( !$DisableCompanyTickets ) {

            my $GetViewCompany = $ConfigObject->Get('CustomerPortal::ViewCompanyTicketsByCustomer');
         

            if ($GetViewCompany){

                # $value can be any regex. be safe
                if ( grep( /^$Param{CustomerID}$/, @{$GetViewCompany} ) ) {

                    $LayoutObject->Block(
                    Name => 'EnableCompanyTickets',
                        Data =>{
                            SubMenuFontColor     => $CustomerNavBarFontColors->{SubMenu},
                            MenuFontColor        => $CustomerNavBarFontColors->{Menu},
                            Active               => $Param{ActionActive},
                        }   
                    );

                     # top menu
                    $LayoutObject->Block(
                        Name => 'NavBarCompanyTickets',
                    );
                    
                }

            }
            else{

                $LayoutObject->Block(
                    Name => 'EnableCompanyTickets',
                    Data =>{
                        SubMenuFontColor     => $CustomerNavBarFontColors->{SubMenu},
                        MenuFontColor        => $CustomerNavBarFontColors->{Menu},
                        Active               => $Param{ActionActive},
                    }
                );

                # top menu
                $LayoutObject->Block(
                    Name => 'NavBarCompanyTickets',
                );
            }
        }
    }

    # CustomerLinks
    # To configuration of links in side bar
    my $CustomerLinksTab = $ConfigObject->Get('CustomerPortal::Core::ToOpenLinkInANewTab');
    my $CustomerLinks    = $ConfigObject->Get('CustomerPortal::Core::CustomerLinks');

    my $NewTab = '';

    if( $CustomerLinksTab eq '1'){
        $NewTab = '_blanck';
    }

    if ( values %{$CustomerLinks} ) {

        $LayoutObject->Block(
            Name => 'OuthersLinksShow',
        );

        # top menu
        $LayoutObject->Block(
            Name => 'NavBarOuthers',
        );

        for my $Link (keys %{$CustomerLinks}){

            $LayoutObject->Block(
                Name => 'CustomerLinks',
                Data => {
                    ExternalLink     => $CustomerLinks->{$Link},
                    DisplayName      => $Link,
                    MenuFontColor    => $CustomerNavBarFontColors->{Menu},
                    SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                    NewTab           => $NewTab,
                }
            );

            # top menu
            $LayoutObject->Block(
                Name => 'NavBarLinks',
                Data => {
                    ExternalLink => $CustomerLinks->{$Link},
                    DisplayName  => $Link,
                    NewTab       => $NewTab,
                }
            );
        }

        $LayoutObject->Block(
            Name => 'CustomerSideBar4',
            Data =>{
                SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                MenuFontColor    => $CustomerNavBarFontColors->{Menu},
            }
        );
    }

    my $CustomMenu = $ConfigObject->Get('CustomerPortal::Core::CustomMenu');

    if ( $CustomMenu ) {

        MENU:
        for my $Menu (sort { $a->{Prio} <=> $b->{Prio} } keys %{$CustomMenu}) {

            if ( $CustomMenu->{$Menu}->{PermissionField} ) {
                my ($PermissionField, $PermissionValue) = split /:/, $CustomMenu->{$Menu}->{PermissionField};
                my $Permission = $User{$PermissionField} // '';
                if ( $Permission ne $PermissionValue ) {
                    next MENU;
                }
            }

            if ( $SideBar ) {
                $LayoutObject->Block(
                    Name => 'CustomerSideBarCustomMenu',
                    Data => {
                        MenuLink      => $CustomMenu->{$Menu}->{MenuLink},
                        MenuLabel     => $CustomMenu->{$Menu}->{MenuLabel},
                        Active        => $Param{ActionActive} eq $CustomMenu->{$Menu}->{MenuLink} ? 'active' : '',
                        Icon          => $CustomMenu->{$Menu}->{Icon},
                        MenuFontColor => $CustomerNavBarFontColors->{Menu}
                    }
                );
            }
            else {
                $LayoutObject->Block(
                    Name => 'NavBarCustomMenu',
                    Data => {
                        MenuLink      => $CustomMenu->{$Menu}->{MenuLink},
                        MenuLabel     => $CustomMenu->{$Menu}->{MenuLabel},
                        Active        => $Param{ActionActive} eq $CustomMenu->{$Menu}->{MenuLink} ? 'active' : '',
                        Icon          => $CustomMenu->{$Menu}->{Icon},
                        MenuFontColor => $CustomerNavBarFontColors->{Menu}
                    }
                );
            }
        }
    }

    # disable output of customer company tickets
    my $EnableTicketProcess = $ConfigObject->Get('CustomerPortal::Core::EnableTicketProcess');

    my $HiddenTicketProcess = '';

    if( $ConfigObject->Get('CustomerPortal::Core::EnableTicketProcess') ) {

        $LayoutObject->Block(
            Name => 'CustomerSideBar5',
            Data => {
                SubMenuFontColor    => $CustomerNavBarFontColors->{SubMenu},
                MenuFontColor       => $CustomerNavBarFontColors->{Menu},
                HiddenTicketProcess => $HiddenTicketProcess,
                Active              => $Param{ActionActive},
            }
        );

        # top menu
        $LayoutObject->Block(
            Name => 'NavBarNewTicketProcess',
        );
    }

    # To get user preferences and sercive Favorite
    my %UserList = $CustomerUserObject->SearchPreferences(
        Key => 'ServiceFavorite',
    );

    # Show name of action

    my %NameAction = (
        MyTickets                   => $CustomerNavBarText->{MyTickets} || 'My Tickets',
        Services                    => 'Main services',
        HomePage                    => $CustomerNavBarText->{Stats} || 'Home Page',
        NewTicketService            => $CustomerNavBarText->{NewTicket} || 'New Ticket',
        NewTicketProcess            => $CustomerNavBarText->{NewTicketProcess} || 'New Ticket Process',
        ServiceDetails              => 'Services',
        CustomerPortalTicketZoom    => '',
        CompanyTickets              => $CustomerNavBarText->{CompanyTickets} || 'Company Tickets',
        CustomerFileManager         => 'File Manager',
        CustomerPortalSearch        => 'Search',
        CustomerPortalNotifications => 'Notifications',
        CustomerPortalPreferences   => 'Preferences',
        CustomerPortalMyData        => 'My Data',
        FAQOfService                => 'FAQ Explorer',
        CustomerPortalFAQs          => 'FAQ Explorer',
        ConsumptionOfHours          => 'Consumption of Hours',
        ConsumptionOfContract       => 'Consumption of Contract',
        CustomerPortalSurvey        => 'Unanswered Surveys',
        CustomerPortalAddCustomerUser => 'Add Customer User',
        CustomCustomerPortalFAQs      => $CustomerNavBarText->{CustomCustomerPortalFAQs} || 'FAQs',
    );

    if ( $ConfigObject->Get('CustomerPortal::Core::OpenTicketByContract')  ) {
        $NameAction{Services} = 'Contracts';
    }

    if ( $SideBar ) {
        my $NameAction = $LayoutObject->{LanguageObject}->Translate($NameAction{$Param{Action}});
        my @CustomTitle = @{ $ConfigObject->Get('CustomerPortal::Core::ServicesPageTitle') };
 
        if($NameAction{$Param{Action}} eq 'Main services' && $CustomTitle[0]){
            $NameAction = $CustomTitle[0];
        }

        $LayoutObject->Block(
            Name => 'ActiveAction',
            Data => {
                NameAction => $NameAction,
                MinimizeColor => "#$SideBarColor1 !important"
            }
        );
    }
    

    if( $UserList{$Param{UserID}} ){

        my $ServicesPrefeUser = $JSONObject->Decode(
            Data => $UserList{$Param{UserID}},
        );


        if ( IsArrayRefWithData($ServicesPrefeUser) ){
            $LayoutObject->Block(
                Name => 'ServiceFavorite',
                Data =>{
                    SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                    MenuFontColor    => $CustomerNavBarFontColors->{Menu},
                }
            );

            $LayoutObject->Block(
                Name => 'NavBarTopServiceFavorite',
                Data =>{
                    SubMenuFontColor => $CustomerNavBarFontColors->{SubMenu},
                    MenuFontColor    => $CustomerNavBarFontColors->{Menu},
                    TopBar           => $TopBar
                }
            );

            my $FavoriteServicesLimit = $ConfigObject->Get('CustomerPortal::Core::FavoriteServicesLimit');

            my $CounterLimitFavorite = 0;

            for my $ServiceIDPref ( @{ $ServicesPrefeUser } ){

                last if $CounterLimitFavorite == $FavoriteServicesLimit;

                $CounterLimitFavorite++;

                my %ServiceData = $ServiceObject->ServiceGet(
                    ServiceID => $ServiceIDPref,
                    UserID    => 1,
                );

                my @ServiceList = $ServiceObject->ServiceSearch(
                    Name   => $ServiceData{Name},
                    UserID => 1,
                );

                my $Link = '';

                if( scalar @ServiceList == 1 ){

                    if( $ServiceData{ServiceExternalLink} ) {          

                        $Link = $ServiceData{ServiceExternalLink};
                    
                    }
                    else {
                        $Link= $LayoutObject->{Baselink} . "Action=NewTicketService;ServiceID=".$ServiceIDPref ;
                        
                    }
                }
                else {

                    if( $ServiceData{ParentID} ) {
                        $Link = $LayoutObject->{Baselink} . "Action=Services;Subaction=ServiceDetails;ServiceID=".$ServiceData{ParentID};
                    }
                    else {
                        $Link = $LayoutObject->{Baselink} . "Action=Services";
                    }
                    
                } 

                if ( $TopBar ){
                    # Top menu
                    $LayoutObject->Block(
                        Name => 'NavBarFavorites',
                        Data => {
                            SubMenuFontColor     => $CustomerNavBarFontColors->{SubMenu},
                            MenuFontColor        => $CustomerNavBarFontColors->{Menu},
                            ServiceNameShort     => $ServiceData{NameShort},
                            ServiceName          => $ServiceData{Name},
                            ServiceID            => $ServiceIDPref,
                            ServiceNewTicketLink => $Link

                        }
                    );
                }
                else{
                    $LayoutObject->Block(
                        Name => 'Favorites',
                        Data => {
                            SubMenuFontColor     => $CustomerNavBarFontColors->{SubMenu},
                            MenuFontColor        => $CustomerNavBarFontColors->{Menu},
                            ServiceNameShort     => $ServiceData{NameShort},
                            ServiceName          => $ServiceData{Name},
                            ServiceID            => $ServiceIDPref,
                            ServiceNewTicketLink => $Link
                        }
                    );
                }
            
            }
        }

    }

    my $LayoutInfos = $Self->_GetLayoutInfos(
        CustomerID => $Param{CustomerID},
    );

    $LayoutObject->Block(
        Name => 'CustomerLogo',
        Data => $LayoutInfos
    );

    if ( $TopBar ) {

        if ( $ConfigObject->Get('CustomerPortal::Core::ShowButtonBack') eq '1' ) {

            $LayoutObject->Block(
                Name => 'PreviousScreen',
                Data => {
                    MinimizeColor => "#$SideBarColor1 !important"
                }
            );
        }

        $LayoutObject->Block(
            Name => 'NavbarTopLogo',
            Data => $LayoutInfos
        );
    }

    my $LayoutUser = $Self->_GetUserAvatar(
        %Param
    );

    $LayoutObject->Block(
        Name => 'GetUserAvatar',
        Data => $LayoutUser
    );

    $LayoutObject->Block(
        Name => 'GetUserAvatar2',
        Data => $LayoutUser
    );

     # To show item to Add CustomerUser
    my $LoginsToAddedCustomerUser = $ConfigObject->Get('CustomerPortal::Core::LoginsToAddedCustomerUser');

    my %HashOfUserConfig = map { $_ => $Param{UserID} } @{$LoginsToAddedCustomerUser};

    if ( defined $HashOfUserConfig{ $Param{UserID} } ) {
        $LayoutObject->Block(
            Name => 'NavBarAddCustomerUser',
            Data =>  {
                UserNameFontColor => $CustomerNavBarFontColors->{UserName},
            }
        );

        $LayoutObject->Block(
            Name => 'NavBarAddCustomerUser2',
            Data =>  {
                UserNameFontColor => $CustomerNavBarFontColors->{UserName},
            }
        );
    }

    my $ShowBackgroundImage = $ConfigObject->Get('CustomerPortal::Core::ShowBackgroundImage');

    if ( $ShowBackgroundImage->{$Param{Action}} ) {
        $LayoutObject->Block(
            Name => 'BackgroundPortal',
            Data => {
                URL     => $ConfigObject->Get('CustomerPortal::Core::BackgroundImageDefault'),
                Opacity => $ConfigObject->Get('CustomerPortal::Core::BackgroundImageOpacity'),
            }
        );
    }
    
}

sub _GetLayoutInfos {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Output = '';
    my %Data;

    my $CustomerNavBarFontColors = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarFontColors');
    my $CustomerLogoDefault      = $ConfigObject->Get('CustomerPortal::Core::CustomerLogoDefault');
    my $CustomerLogos            = $ConfigObject->Get('CustomerPortal::Core::CustomerLogo');
    my $CustomerLogoHostBased    = $ConfigObject->Get('CustomerPortal::Core::CustomerLogo::HostBased');
    my $CentralizeLogo           = $ConfigObject->Get('CustomerPortal::Core::CentralizeLogo');

    # get configured logo to customerID
    my $Logo;   

    if ( IsHashRefWithData($CustomerLogoHostBased) ) {

        THEME:
        for my $RegExp ( sort keys %{$CustomerLogoHostBased} ) {

            # do not use empty regexp or theme directories
            next THEME if !$RegExp;
            next THEME if $RegExp eq '';
            next THEME if !$CustomerLogoHostBased->{$RegExp};

            # check if regexp is matching
            if ( $ENV{HTTP_HOST} =~ /$RegExp/i ) {
                $Logo = $CustomerLogoHostBased->{$RegExp};
            }
        }
    }

    for my $LogoCustomerID (keys %{$CustomerLogos}){

        if($LogoCustomerID eq $Param{CustomerID}){
            my $WebPath = '';

            $Logo = $CustomerLogos->{$LogoCustomerID};
        }
    }

    my %CustomerLogo;
    if( IsHashRefWithData($ConfigObject->Get('CustomerLogo'))){
        %CustomerLogo = %{ $ConfigObject->Get('CustomerLogo') };
    }
   
    # Add header logo, if configured
    if ( $Logo ) {

        for my $CSSStatement ( sort keys %CustomerLogo ) {

            if ( $CSSStatement eq 'URL' ) {

                my $WebPath = '';

                if ( $Logo !~ /(http|ftp|https):\//i ) {
                    $WebPath = $ConfigObject->Get('Frontend::WebPath');
                }

                # if ( $CustomerLogo{$CSSStatement} !~ /(http|ftp|https):\//i ) {
                #     $WebPath = $ConfigObject->Get('Frontend::WebPath');
                # }

                $Data{'URL'} = '' . $WebPath . $Logo . '';
            }
            else {
                $Data{$CSSStatement} = $CustomerLogo{$CSSStatement};
            }
        }
    }
    elsif ($CustomerLogoDefault){

        my $WebPath = '';

        if ( $CustomerLogoDefault !~ /(http|ftp|https):\//i ) {
            $WebPath = $ConfigObject->Get('Frontend::WebPath');
        }

        # To set default Logo
        for my $CSSStatement ( sort keys %CustomerLogo ) {

            if ( $CSSStatement eq 'URL' ) {

                $Data{'URL'} = '' . $WebPath . $CustomerLogoDefault . '';
            }
            else {
                $Data{$CSSStatement} = $CustomerLogo{$CSSStatement};
            }
        }

        if (!$Data{URL} ) {
            $Data{'URL'} = '' . $WebPath . $CustomerLogoDefault . '';
        }
    }

    $Data{UserNameFontColor} = $CustomerNavBarFontColors->{UserName};

    if( $CentralizeLogo ){
        $Data{CentralizeLogo}         = 'CentralizeLogo';
        $Data{CentralizeLogoToNavbar} = 'CentralizeLogoToNavbar';
        $Data{CentralizeLogoSide}     = 'CentralizeLogoSide';
    }

    return \%Data;
}

sub _GetUserAvatar {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Output = '';

    if ( $ConfigObject->Get('Frontend::AvatarEngine') eq 'Gravatar' && $Param{UserEmail} ) {

        my $DefaultIcon = $ConfigObject->Get('Frontend::Gravatar::DefaultImage') || 'mm';

        $Param{Avatar} = '//www.gravatar.com/avatar/' . md5_hex( lc $Param{UserEmail} ) . '?s=100&d=' . $DefaultIcon;
    }
    else {

        my %User = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
            User=> $Param{UserLogin},
        );

        $Param{UserInitials} = $LayoutObject->UserInitialsGet( Fullname => $User{UserFullname} );
    }

    return \%Param;
}

sub CustomerHeader {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $SidebarMini = $ParamObject->GetCookie(
        Key => 'SidebarMini',
    ) || '';

    my $BodyClass = '';

    if ( $SidebarMini eq 'true' ) {
        $BodyClass = 'sidebar-mini';
    }

    # build output
    my $Output = $LayoutObject->CustomerHeader( %Param, BodyClass => $BodyClass );

    return $Output;
}

sub CustomerNoPermission {
    my ( $Self, %Param ) = @_;
    
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $WithHeader = $Param{WithHeader} || 'yes';
    $Param{Message} ||= Translatable('No Permission!');

    # create output
    my $Output = $Self->CustomerHeader( 
        Title => Translatable('No Permission'),
        Refresh => 0,
        Type    => 'Small' 
    ) if ( $WithHeader eq 'yes' );
        
    $Output .= $LayoutObject->Output(
        TemplateFile => 'NoPermission',
        Data         => \%Param
    );
    $Output .= $LayoutObject->CustomerFooter() if ( $WithHeader eq 'yes' );

    # return output
    return $Output;
}

1;