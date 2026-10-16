# --
# Kernel/Modules/AdminToolBox.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * Jguedes@serviceup.com.br
# --

package Kernel::Modules::AdminToolBox;

use strict;
use warnings;
use utf8;

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

    my $LayoutObject     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject        = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject      = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ToolBoxObject    = $Kernel::OM->Get('Kernel::System::ToolBox');

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
   
    # ------------------------------------------------------------ #
    # Select Agent Preferences
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'AgentPreferences' ) {
        my $UserObject       = $Kernel::OM->Get('Kernel::System::User');

        my %UsersList = $UserObject->UserList();

        $Param{Method} = 'AgentPreferences';

        $Output .= $Self->_Change(
            Data     => \%UsersList,
            %Param,
        );
		$Output .= $LayoutObject->Footer();

        return $Output;
    }
    # ------------------------------------------------------------ #
    # Select Customer Preferences
    # ------------------------------------------------------------ #
    elsif(  $Self->{Subaction} eq 'CustomerPreferences' ){
    
        my %List = $ToolBoxObject->CustomerUsersList();

        $Param{Method} = 'CustomerPreferences';

        $Output .= $Self->_Change(
            Data     => \%List,
            %Param,
        );
		$Output .= $LayoutObject->Footer();

        return $Output;

    }
    # ------------------------------------------------------------ #
    # Change Agent Preferences
    # ------------------------------------------------------------ #
    elsif( $Self->{Subaction} eq 'ChangeAgentPreferences'){

        # to be set members of the role
       @{ $Param{IDs} }  = $ParamObject->GetArray( Param => 'Type' );
       $Param{ConfigGet} = 'PreferencesGroups';

        $Output .= $Self->_EditChanges(
            %Param, 
        );
		$Output .= $LayoutObject->Footer();

        return $Output;
        
    }
    # ------------------------------------------------------------ #
    # Change Customer Preferences
    # ------------------------------------------------------------ #
    elsif( $Self->{Subaction} eq 'ChangeCustomerPreferences'){

        # to be set members of the role
        @{ $Param{IDs} } = $ParamObject->GetArray( Param => 'Type' );
        $Param{ConfigGet} = 'CustomerPreferencesGroups';

        $Output .= $Self->_EditChanges(
            %Param, 
        );
        $Output .= $LayoutObject->Footer();

        return $Output;

    }
    # ------------------------------------------------------------ #
    # Save Changes
    # ------------------------------------------------------------ #
    elsif( $Self->{Subaction} eq 'SaveChanges' ){

        # get params
       $Param{IDs}              = $ParamObject->GetParam( Param => 'IDs' );
       $Param{PreferenceKey}    = $ParamObject->GetParam( Param => 'Preferences' );
       $Param{PreferenceValue}  = $ParamObject->GetParam( Param => 'PreferenceValue' );
       $Param{Type}             = $ParamObject->GetParam( Param => 'Type' );

        $Output .= $Self->_SaveChanges(
            %Param, 
        );

        $Output .= $LayoutObject->Notify(
            Priority => 'Warning',
            Data     => $LayoutObject->{LanguageObject}->Translate("Preference successfully changed!"),
        );
    }

    # ------------------------------------------------------------
    # Overview
    # ------------------------------------------------------------
  
    $Output .= $Self->_Overview();
    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get object
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject    = $Kernel::OM->Get('Kernel::System::User');
     
    $LayoutObject->Block(
        Name => 'Overview',
        Data => { %Param },
    );

    # no actions in action list
    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionAdd' );
    $LayoutObject->Block( Name => 'ActionTicketTemplate');
    # $LayoutObject->Block( Name => 'Filter' );

    # output overview result
    $LayoutObject->Block(
        Name => 'OverviewList',
        Data => { %Param },
    );

    # return output
    return $LayoutObject->Output(
        TemplateFile => 'AdminToolBox',
        Data         => \%Param,
    );

}

sub _Change {
	my ( $Self, %Param ) = @_;
	
	my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	
    my %Data       = %{ $Param{Data} }; 
	my $Type       = $Param{Type} || 'Type';
	my $User       = $Param{Users} || 'Type';
	my $LinkHeader = "";

    if( $Param{Method} eq 'AgentPreferences' ){
        $Type = 'Agent';
    }elsif( $Param{Method} eq 'CustomerPreferences' ){
        $Type = 'Customer';
    }
	
	my %VisibleType = (
        Agent    => 'Agent',
        Customer  => 'Customer',
    );
        
    $LayoutObject->Block(
        Name => 'Overview',
        Data => { %Param },
    );
	
	$LayoutObject->Block(
        Name => 'ActionList',
    );

    $LayoutObject->Block(
        Name => 'ActionOverview',
    );
		
    $LayoutObject->Block(
        Name => 'Change',
        Data => {
            %Param,
            LinkHeader    => $LinkHeader,
            NeType        => $VisibleType{$Type},
            Type          => $Param{Method},
            VisibleType   => $VisibleType{$Type},
            VisibleNeType => $VisibleType{$Type},
        },
    );

	
	# check if there are groups
    if ( $Type eq 'Agent' ||  $Type eq 'Customer') {
        if ( !$User ) {
            $LayoutObject->Block(
                Name => 'NoDataFoundMsgList',
                Data => {
                    ColSpan => 8,
                },
            );
        }
    }	
	
    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
   
    $LayoutObject->Block(
        Name => 'ChangeHeader',
        Data => {
            %Param,
            Type   => 'Type',
            NeType => $Type,
        },
    );
	
	$LayoutObject->AddJSData(
        Key   => 'RelationItems',
        Value => ['Type'],
    );
	
	for my $ID ( sort { uc( $Data{$a} ) cmp uc( $Data{$b} ) } keys %Data ) {
	
		my $Selected;
		my $Link = "";
		
		if($Type eq 'Type'){
			# set output class
			if ( grep( $_ eq $ID, @{$Param{Selected}} ) ){
				$Selected = ' checked="checked"'
			}
			else{
				$Selected = '';
			}
			$Link = "Action=AdminService;Subaction=ServiceEdit;ServiceID=$ID";
		}
		else{
			# set output class
			if ( grep( $_ == $ID, @{$Param{Selected}} ) ){
				$Selected = ' checked="checked"'
			}
			else{
				$Selected = '';
			}		
			$Link = "Action=AdminType;Subaction=Change;ID=$ID";
		}
		
        # set output class
        $LayoutObject->Block(
            Name => 'ChangeRow',
            Data => {
                # %Param,
				Link     => $Link,
				Name     => $Param{Data}->{$ID},
				ID       => $ID,
				NeType   => $Type,
				Type     => 'Type',
				Selected => $Selected,
            },
        );
	}

	return $LayoutObject->Output(
        TemplateFile => 'AdminToolBox',
        Data         => \%Param,
    );
}

sub _EditChanges {

    my ( $Self, %Param ) = @_;
    
    # get objects
	my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');

    # get config
    my $ConfigPreferences = $ConfigObject->Get($Param{ConfigGet});

    my %Data  = (); 

    PREFERENCE:
    for my $Preferences( keys %{$ConfigPreferences} ){

        next PREFERENCE if($ConfigPreferences->{$Preferences}->{PrefKey} eq 'UserGoogleAuthenticatorSecretKey');
        next PREFERENCE if($ConfigPreferences->{$Preferences}->{PrefKey} eq 'UserSMIMEKey');
        next PREFERENCE if($ConfigPreferences->{$Preferences}->{PrefKey} eq 'UserPGPKey');
        next PREFERENCE if($ConfigPreferences->{$Preferences}->{PrefKey} eq 'UserOutOfOffice');
        next PREFERENCE if($ConfigPreferences->{$Preferences}->{PrefKey} eq 'UserTheme');
        next PREFERENCE if($Param{ConfigGet} eq 'PreferencesGroups' && $ConfigPreferences->{$Preferences}->{PrefKey} eq 'AdminNotifcationEventTransport');
        next PREFERENCE if($Param{ConfigGet} eq 'PreferencesGroups' && $ConfigPreferences->{$Preferences}->{PrefKey} eq 'AdminAppointmentNotifcationEventTransport');

        $Data{ $ConfigPreferences->{$Preferences}->{PrefKey} } =  $LayoutObject->{LanguageObject}->Translate($ConfigPreferences->{$Preferences}->{Label});
    }

    $Param{PreferenceStrg} = $LayoutObject->BuildSelection(
        Data         => \%Data,
        Name         => 'Preferences',
        Multiple     => 0,
        Translation  => 0,
        Class        => 'Modernize Validate_Required',
	    PossibleNone => 1,
    );

    $LayoutObject->Block(
        Name => 'SaveConfig',
        Data => { %Param },
    );
	
	$LayoutObject->Block(
        Name => 'ActionList',
    );

    $LayoutObject->Block(
        Name => 'ActionOverview',
    );

	my $JSON = $LayoutObject->JSONEncode(
        Data => $Param{IDs}
    );

    $LayoutObject->Block(
        Name => 'EditChanges',
        Data => {
            %Param,
            IDs => $JSON,
        },
    );

	return $LayoutObject->Output(
        TemplateFile => 'AdminToolBox',
        Data         => \%Param,
    );

}

sub _SaveChanges {
    my ( $Self, %Param ) = @_;
	
	my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $ToolBoxObject      = $Kernel::OM->Get('Kernel::System::ToolBox');
    my $SessionObject      =  $Kernel::OM->Get('Kernel::System::AuthSession');

    my $JSON = $JSONObject->Decode(
        Data =>  $Param{IDs},
    );

    # save new preferences
    USER:
    for my $UserID ( @{$JSON} ){

        next USER if($UserID eq '');

        my $ID = $UserID;

        if($Param{Type} eq 'PreferencesGroups'){
            $UserObject->SetPreferences(
                Key    => $Param{PreferenceKey},
                Value  => $Param{PreferenceValue},
                UserID => $UserID,
            );
        }
        else{

            my %List = $ToolBoxObject->CustomerUsersList();

            $CustomerUserObject->SetPreferences(
                Key    => $Param{PreferenceKey},
                Value  => $Param{PreferenceValue},
                UserID => $List{$UserID},
            );

            $ID = $List{$UserID};
        }

        my $SessionID = $Self->_GetSessionID(
            User    => $Param{Type},
            UserID  => $ID
        );

        if( defined $SessionID ){
            $SessionObject->UpdateSessionID(
                SessionID => $SessionID,
                Key       => $Param{PreferenceKey},
                Value     => $Param{PreferenceValue},
            );
        }
    }
}


sub _GetSessionID {
    my ( $Self, %Param ) = @_;
	
    my $SessionObject  =  $Kernel::OM->Get('Kernel::System::AuthSession');

    my @Sessions  = $SessionObject->GetAllSessionIDs();

    my $Session;
    for my $SessionID (@Sessions){
        
        my %UserData = $SessionObject->GetSessionIDData(
            SessionID => $SessionID
        );

        # get session id of user
        if( ($Param{User} eq 'CustomerPreferencesGroups' && $UserData{UserLogin} eq $Param{UserID} ) ||
            ( $Param{User} eq 'PreferencesGroups' && $UserData{UserID} eq $Param{UserID} ) ){
            $Session = $SessionID;
        }
    
    }

    return $Session;
}



1;