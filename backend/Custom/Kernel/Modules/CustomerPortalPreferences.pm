# --
# Kernel/Modules/CustomerPortalPreferences.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br 
# * dparavani@serviceup.com.br 
# --

package Kernel::Modules::CustomerPortalPreferences;

use strict;
use warnings;

use utf8;

use Digest::MD5 qw(md5_hex);
use Encode qw(decode encode);
use File::Basename;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get form id
    $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FormID' );

    # create form id
    if ( !$Self->{FormID} ) {
        $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::UploadCache')->FormIDCreate();
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CustomerUserObject   = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');
	my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');

    my $Message  = $ParamObject->GetParam( Param => 'Message' )  || '';

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "",
        %{$Self}
    );

    if($Self->{Subaction} eq 'UpdatePreferences' ){
        my $UserObject   = $Kernel::OM->Get('Kernel::System::CustomerUser');

        # check group param
        my $Group = $ParamObject->GetParam( Param => 'Group' ) || '';
        if ( !$Group ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Param Group is required!'),
            );
        }

        # check preferences setting
        my %Preferences = %{ $Kernel::OM->Get('Kernel::Config')->Get('CustomerPreferencesGroups') };
        if ( !$Preferences{$Group} ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}->Translate( 'No such config for %s', $Group ),
            );
        }

        # get user data
        my %UserData = $UserObject->CustomerUserDataGet( User => $Self->{UserLogin} );
        my $Module   = $Preferences{$Group}->{Module};
        if ( !$Kernel::OM->Get('Kernel::System::Main')->Require($Module) ) {
            return $LayoutObject->FatalError();
        }
        my $Object = $Module->new(
            %{$Self},
            UserObject => $UserObject,
            ConfigItem => $Preferences{$Group},
            Debug      => $Self->{Debug},
        );
        # log loaded module
        if ( $Self->{Debug} > 1 ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'debug',
                Message  => "Module: $Module loaded!",
            );
        }
        my @Params = $Object->Param( UserData => \%UserData );
        my %GetParam;
        for my $ParamItem (@Params) {
            my @Array = $ParamObject->GetArray(
                Param => $ParamItem->{Name},
                Raw   => $ParamItem->{Raw} || 0,
            );
            $GetParam{ $ParamItem->{Name} } = \@Array;

        }

        my $Message  = '';
        my $Priority = '';

        if (
            $Object->Run(
                GetParam => \%GetParam,
                UserData => \%UserData
            )
            )
        {
            $Message = $Object->Message();
        }
        else {
            $Priority = 'Error';
            $Message  = $Object->Error();
        }

        # check redirect
        my $RedirectURL = $ParamObject->GetParam( Param => 'RedirectURL' );
        if ($RedirectURL) {
            return $LayoutObject->Redirect(
                OP => $RedirectURL,
            );
        }
    
        # redirect
        return $LayoutObject->Redirect(
            OP => "Action=CustomerPortalPreferences;Message=$Message",
        );

    }
    else{

        if($Message){
            $LayoutObject->Block(
                Name => 'Head',
                Data => {
                    Header => $Message
                },
            );
        }
        
        $LayoutObject->Block(
            Name => 'Body',
            Data => \%Param,
        );

        my %Data;
        my %Preferences = %{ $ConfigObject->Get('CustomerPreferencesGroups') };

        GROUP:
        for my $Group ( sort keys %Preferences ) {

            next GROUP if !$Group;

            my $PreferencesGroup = $Preferences{$Group};

            next GROUP if !$PreferencesGroup;
            next GROUP if ref $PreferencesGroup ne 'HASH';
            next GROUP if ( ($Self->{Config}->{Module} eq 'Kernel::System::CustomerUser::LDAP') && ($Group eq 'Password') );

            $PreferencesGroup->{Prio} ||= 9999;

            if ( $Data{ $PreferencesGroup->{Prio} } ) {

                COUNT:
                for ( 1 .. 151 ) {

                    $PreferencesGroup->{Prio}++;

                    if ( !$Data{ $PreferencesGroup->{Prio} } ) {
                        $Data{ $PreferencesGroup->{Prio} } = $Group;
                        last COUNT;
                    }
                }
            }

            $Data{ $PreferencesGroup->{Prio} } = $Group;
        }

        # sort
        for my $Key ( sort keys %Data ) {
            $Data{ sprintf( "%07d", $Key ) } = $Data{$Key};
            delete $Data{$Key};
        }

        my $TranslateKeys = $ConfigObject->Get('CustomerPortal::CustomerPortalUserPreferences::TranslateKeys');

        # show each preferences setting
        PRIO:
        for my $Prio ( sort keys %Data ) {
            my $Group = $Data{$Prio};
            next PRIO if !$ConfigObject->{CustomerPreferencesGroups}->{$Group};

            my %Preference = %{ $ConfigObject->{CustomerPreferencesGroups}->{$Group} };
            next PRIO if !$Preference{Active};

            # load module
            my $Module = $Preference{Module} || 'Kernel::Output::HTML::CustomerPreferencesGeneric';
            if ( !$Kernel::OM->Get('Kernel::System::Main')->Require($Module) ) {
                return $LayoutObject->FatalError();
            }
            my $Object = $Module->new(
                %{$Self},
                UserObject => $Kernel::OM->Get('Kernel::System::CustomerUser'),
                ConfigItem => $Preferences{$Group},
                Debug      => $Self->{Debug},
            );
            my @Params = $Object->Param( UserData => $Param{UserData} );
            next PRIO if !@Params;

            next PRIO if $Preference{PrefKey} eq 'UserShowTickets';
            next PRIO if $Preference{PrefKey} eq 'UserRefreshTime';

            # show item
            $LayoutObject->Block(
                Name => 'Item',
                Data => {
                    Group => $Group,
                    %Preference,
                },
            );
        
            my %PreferencesUser = $CustomerUserObject->GetPreferences(
                    UserID => $Self->{UserID},
            );
            for my $ParamItem (@Params) {
                if($PreferencesUser{UserTimeZone} && $Preference{PrefKey} eq  'UserTimeZone'){
                    $ParamItem->{SelectedID} = $PreferencesUser{UserTimeZone} ;
                }
                my %BuildSelectionParams = (
                    %Preference,
                    %{$ParamItem},
                );
                $BuildSelectionParams{Class} = join( ' ', $BuildSelectionParams{Class} // '', 'Modernize' );

                if ( ref $ParamItem->{Data} eq 'HASH' || ref $Preference{Data} eq 'HASH' ) {
                    $ParamItem->{Option} = $LayoutObject->BuildSelection(
                        %BuildSelectionParams
                    );
                }

                if( $TranslateKeys->{ $ParamItem->{Key} } ){
                    $ParamItem->{Key} = $TranslateKeys->{ $ParamItem->{Key} };
                }

                $LayoutObject->Block(
                    Name => 'Block',
                    Data => { %Preference, %{$ParamItem}, },
                );

                $LayoutObject->Block(
                    Name => $ParamItem->{Block} || $Preference{Block} || 'Option',
                    Data => { %Preference, %{$ParamItem}, },
                );
            
            }
        }

        my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

        # build output
        my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{CustomerPortalPreferences});

        $Output   .= $LayoutObject->Output(
            Data         => \%Param,
            TemplateFile => 'CustomerPortalPreferences',
        );
        $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

        return $Output;
    }
}

1;