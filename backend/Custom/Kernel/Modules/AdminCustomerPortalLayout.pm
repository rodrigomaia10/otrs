# --
# Kernel/Modules/AdminCustomerPortalLayout.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminCustomerPortalLayout;

use strict;
use warnings;

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

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    # ------------------------------------------------------------ #
    # Layout save
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'SaveLayout' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

        # get params
        my %GetParam;

        $GetParam{ImgLogo} = $ParamObject->GetParam( Param => "ImgLogo" );

        $GetParam{ImgBackground}        = $ParamObject->GetParam( Param => "ImgBackground" );
        $GetParam{Opacity}              = $ParamObject->GetParam( Param => "Opacity" );
        $GetParam{MenuType}             = $ParamObject->GetParam( Param => "MenuType" );
        $GetParam{SearchCard}           = $ParamObject->GetParam( Param => "SearchCard" );
        $GetParam{ImgSearchCard}        = $ParamObject->GetParam( Param => "ImgSearchCard" );
        $GetParam{SearchCardColor}      = $ParamObject->GetParam( Param => "SearchCardColor" );
        $GetParam{SearchCardTitleColor} = $ParamObject->GetParam( Param => "SearchCardTitleColor" );
        $GetParam{SearchCardBodyColor}  = $ParamObject->GetParam( Param => "SearchCardBodyColor" );
        $GetParam{BackgroundGradient}   = $ParamObject->GetParam( Param => "BackgroundGradient" );

        $Self->_SettingUpdate(
            Valid => 1,
            Key   => "CustomerPortal::Core::MenuType",
            Value => "$GetParam{MenuType}"
        );

        $Self->_SettingUpdate(
            Valid => 1,
            Key   => "CustomerPortal::Core::CustomerLogoDefault",
            Value => $GetParam{ImgLogo} 
        );

        $Self->_SettingUpdate(
            Valid => 1,
            Key   => "CustomerPortal::Core::BackgroundImageDefault",
            Value => $GetParam{ImgBackground}
        );

        $Self->_SettingUpdate(
            Valid => 1,
            Key   => "CustomerPortal::Core::BackgroundImageOpacity",
            Value => $GetParam{Opacity}
        );

        my %Setting = $SysConfigObject->SettingGet(
            Name            => 'CustomerPortal::Core::CardHomeSearch',  # (required) Setting name
            UserID          => 1,                # Required only if OverriddenInXML is set.
        );
        
        my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

        my %SettingObjectHome = $SysConfigObject->SettingGet(
            Name => "CustomerPortal::Core::CardHomeSearch",
        );

        my $ExclusiveLockGUIDHome = $SysConfigObject->SettingLock(
            Name   => $SettingObjectHome{Name},
            Force  => 1,
            UserID => 1,
        );

        my %SettingObjectServices = $SysConfigObject->SettingGet(
            Name => "CustomerPortal::Core::CardSearchServices",
        );

        my $ExclusiveLockGUIDService = $SysConfigObject->SettingLock(
            Name   => $SettingObjectServices{Name},
            Force  => 1,
            UserID => 1,
        );

        my %SettingsDeployed1 = $SysConfigObject->SettingUpdate(
            Comments          => 'Update CardHomeSearch',
            UserID            => 1,
            Name              => "CustomerPortal::Core::CardHomeSearch",
            IsValid           => 1,
            EffectiveValue    => {    
                Subtitle      => $Setting{EffectiveValue}->{Subtitle},
                TitleColor    => $GetParam{SearchCardTitleColor},
                Image         => $GetParam{ImgSearchCard},
                Title         => $Setting{EffectiveValue}->{Title},
                Search        => $Setting{EffectiveValue}->{Search},
                Transparent   => $Setting{EffectiveValue}->{Transparent},
                CardColor     => $GetParam{SearchCardColor},
                FullCard      => $GetParam{SearchCard} ,
                SubtitleColor => $GetParam{SearchCardBodyColor},
                BackgroundGradient => $GetParam{BackgroundGradient}
            },
            ExclusiveLockGUID => $ExclusiveLockGUIDHome,
        );

        my %SettingsDeployed2 = $SysConfigObject->SettingUpdate(
            Comments          => 'Update CardHomeSearch',
            UserID            => 1,
            Name              => "CustomerPortal::Core::CardSearchServices",
            IsValid           => 1,
            EffectiveValue    => {    
                Subtitle      => $Setting{EffectiveValue}->{Subtitle},
                TitleColor    => $GetParam{SearchCardTitleColor},
                Image         => $GetParam{ImgSearchCard},
                Title         => $Setting{EffectiveValue}->{Title},
                Search        => $Setting{EffectiveValue}->{Search},
                Transparent   => $Setting{EffectiveValue}->{Transparent},
                CardColor     => $GetParam{SearchCardColor},
                FullCard      => $GetParam{SearchCard} ,
                SubtitleColor => $GetParam{SearchCardBodyColor},
                BackgroundGradient => $GetParam{BackgroundGradient}
            },
            ExclusiveLockGUID => $ExclusiveLockGUIDService,
        );

            
        my $Success = $SysConfigObject->ConfigurationDeploy(
            Comments    => "Installer deployment",
            AllSettings => 1,
            Force       => 1,
            UserID      => 1,
        );

        if( $GetParam{MenuType} eq '1' ){
            my %GetParamTopMenu;

            for (qw( NavBarBackgroundColor BorderNavBarColor MainPanelColor NavBarItemColor SelectedItemSuspended SelectedNavBarItemColor )) {
                $GetParamTopMenu{$_} = $ParamObject->GetParam( Param => $_ ) || '';
            }

            $Self->_SettingUpdate(
                Valid => 1,
                Key   => "CustomerPortal::Core::Layout",
                Value => \%GetParamTopMenu
            );

           
        }
        else{

            my %GetParamSideBar;
            for (qw( SideBarColor1 SideBarColor2 Menu SubMenu UserName  )) {
                $GetParamSideBar{$_} = $ParamObject->GetParam( Param => $_ ) || '';
                $GetParamSideBar{$_} =~ s/[#]+//g;
            }

            my %LayoutConfig = (
                NavBarBackgroundColor => $ParamObject->GetParam( Param => "NavBarBackgroundColor" ),
                BorderNavBarColor     => $ParamObject->GetParam( Param => "BorderNavBarColor" ),
                MainPanelColor        => $ParamObject->GetParam( Param => "MainPanelColor" ),
            );

            $Self->_SettingUpdate(
                Valid => 1,
                Key   => "CustomerPortal::Core::Layout",
                Value => \%LayoutConfig
            );

            $Self->_SettingUpdate(
                Valid => 1,
                Key   => "CustomerPortal::Core::CustomerNavBarColorsDefault",
                Value => "$GetParamSideBar{SideBarColor1};$GetParamSideBar{SideBarColor2}"
            );

            $Self->_SettingUpdate(
                Valid => 1,
                Key   => "CustomerPortal::Core::CustomerNavBarFontColors",
                Value => {
                    Menu    => $GetParamSideBar{Menu},
                    SubMenu   => $GetParamSideBar{SubMenu},
                    UserName => $GetParamSideBar{UserName},
                }
            );

        }

        my $HTML = $LayoutObject->Redirect(
            OP => "Action=AdminCustomerPortalLayout",
        );

        return $HTML;
    }
    else {
        
        my $MenuTypeParam = $ParamObject->GetParam( Param => "MenuType" );

        my %MenuTypeSelect = (
            0 => 'Side bar',
            1 => 'Top bar',
        );

        my $MenuType = $ConfigObject->Get('CustomerPortal::Core::MenuType');

        if( $MenuTypeParam ){
            if( $MenuTypeParam eq 'Side bar' ){
                $MenuType = '0';
            }else{
                $MenuType = '1';
            }
        }

        $Param{MenuTypeStrg} = $LayoutObject->BuildSelection(
            Data       => \%MenuTypeSelect,
            Name       => 'MenuType',
            SelectedID =>  $MenuType,
            Class      => 'Modernize',
            Multiple   => 0
        );

        my %SeachCardSelect = (
            0 => 'Card',
            1 => 'Full',
        );

        my $ConfigCardHomeSearch = $ConfigObject->Get('CustomerPortal::Core::CardHomeSearch');

        $Param{SearchCard} = $LayoutObject->BuildSelection(
            Data       => \%SeachCardSelect,
            Name       => 'SearchCard',
            SelectedID =>  $ConfigCardHomeSearch->{FullCard},
            ID         => 'SearchCardOption',
            Class      => 'Modernize',
            Multiple   => 0
        );

        $Param{ImgSearchCard}        = $ConfigCardHomeSearch->{Image};
        $Param{SearchCardColor}      = $ConfigCardHomeSearch->{CardColor};
        $Param{SearchCardTitleColor} = $ConfigCardHomeSearch->{TitleColor};
        $Param{SearchCardBodyColor}  = $ConfigCardHomeSearch->{SubtitleColor};
        $Param{BackgroundGradient}   = $ConfigCardHomeSearch->{BackgroundGradient};

        # output overview
        $LayoutObject->Block(
            Name => 'Overview',
            Data => { %Param, },
        );

        my $CustomerNavBarColorsDefault = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarColorsDefault');
        my $CustomerNavBarFontColors    = $ConfigObject->Get('CustomerPortal::Core::CustomerNavBarFontColors');
        my $CustomerLogoDefault         = $ConfigObject->Get('CustomerPortal::Core::CustomerLogoDefault');
        my $BackgroundImageDefault      = $ConfigObject->Get('CustomerPortal::Core::BackgroundImageDefault');
        my $BackgroundImageOpacity      = $ConfigObject->Get('CustomerPortal::Core::BackgroundImageOpacity');

        my ( $SideBarColor1, $SideBarColor2 ) = split /;/, $CustomerNavBarColorsDefault;

        my $Layout = $ConfigObject->Get('CustomerPortal::Core::Layout');

        if ( $MenuType eq '1' ){
           
            $LayoutObject->Block(
                Name => 'CustomerTopBar',
                Data => {
                    NavBarBackgroundColor   => $Layout->{NavBarBackgroundColor},
                    BorderNavBarColor       => $Layout->{BorderNavBarColor},
                    MainPanelColor          => $Layout->{MainPanelColor},
                    NavBarItemColor         => $Layout->{NavBarItemColor},
                    SelectedItemSuspended   => $Layout->{SelectedItemSuspended},
                    SelectedNavBarItemColor => $Layout->{SelectedNavBarItemColor},                 
                    Logo                    => $CustomerLogoDefault,
                    BackgroundImage         => $BackgroundImageDefault,
                    Opacity                 => $BackgroundImageOpacity,
                    SearchCardTitleColor    => $ConfigCardHomeSearch->{TitleColor},
                    SearchCardBodyColor     => $ConfigCardHomeSearch->{SubtitleColor},
                    BackgroundGradient      => $ConfigCardHomeSearch->{BackgroundGradient},
                }
            );
        }
        else{
            $LayoutObject->Block(
                Name => 'CustomerSideBar',
                Data => {
                    SideBarColor1   => $SideBarColor1,
                    SideBarColor2   => $SideBarColor2,
                    Menu            => $CustomerNavBarFontColors->{Menu},
                    SubMenu         => $CustomerNavBarFontColors->{SubMenu},
                    UserName        => $CustomerNavBarFontColors->{UserName},
                    NavBarBackgroundColor => $Layout->{NavBarBackgroundColor},
                    BorderNavBarColor     => $Layout->{BorderNavBarColor},
                    Logo            => $CustomerLogoDefault,
                    BackgroundImage => $BackgroundImageDefault,
                    Opacity         => $BackgroundImageOpacity,
                    MainPanelColor  => $Layout->{MainPanelColor},
                    SearchCardTitleColor => $ConfigCardHomeSearch->{TitleColor},
                    SearchCardBodyColor  => $ConfigCardHomeSearch->{SubtitleColor},
                    BackgroundGradient   => $ConfigCardHomeSearch->{BackgroundGradient},

                }
            );

        }
       
        # output header
        my $Output = $LayoutObject->Header();

        $Output .= $LayoutObject->NavigationBar();

        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminCustomerPortalLayout',
            Data         => \%Param,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _SettingUpdate {
    my ( $Self, %Param ) = @_;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    my $ExclusiveLockGUID = $SysConfigObject->SettingLock(
        Name   => $Param{Key},
        Force  => 1,
        UserID => 1,
    );

    # Update config item via SysConfig object.
    my $Result = $SysConfigObject->SettingUpdate(
        Name              => $Param{Key},
        IsValid           => $Param{Valid},
        EffectiveValue    => $Param{Value},
        ExclusiveLockGUID => $ExclusiveLockGUID,
        UserID            => 1,
    );

    if ( !$Result ) {
        $Kernel::OM->Get('Kernel::Output::HTML::Layout')->FatalError(
            Message => Translatable('Can\'t write Config file!'),
        );
    }

    # There is no need to unlock the setting as it was already unlocked in the update.

    # 'Rebuild' the configuration.
    my $Success = $SysConfigObject->ConfigurationDeploy(
        Comments    => "Installer deployment",
        AllSettings => 1,
        Force       => 1,
        UserID      => 1,
    );
    

    return 1;
}

1;