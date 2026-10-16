# --
# Kernel/Modules/AdminDashboard.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::AdminDashboard;

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

    # get objects
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $DashboardObject    = $Kernel::OM->Get('Kernel::System::Dashboard::Dashboard');

    # ------------------------------------------------------------ #
    # add
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Add' ) {

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        $Self->_Edit(
            Action => 'Add',
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminDashboard',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # add action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my ( %GetParam, %Errors );
        for my $Parameter (qw(ID Name AvailableInterface CustomerID ValidID)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        @{$GetParam{GroupIDs}} = $ParamObject->GetArray( Param => "GroupIDs" );
	    $GetParam{GroupIDs} = join (',', @{$GetParam{GroupIDs}});

        for my $Needed (qw(Name AvailableInterface ValidID)) {
            if ( !$GetParam{$Needed} ) {
                $Errors{ $Needed . 'Invalid' } = 'ServerError';
            }
        }

        # check needed data
        if ( $GetParam{AvailableInterface} eq 'AgentInterface' ) {
            if ( !$GetParam{GroupIDs} ) {
                $Errors{'GroupIDsInvalid'} = 'ServerError';
            }
        }
        elsif ( $GetParam{AvailableInterface} eq 'CustomerInterface' ) {
            if ( !$GetParam{CustomerID} ) {
                $Errors{'CustomerIDInvalid'} = 'ServerError';
            }
        }
        else {
            for my $Needed (qw(CustomerID GroupIDs)) {
                if ( !$GetParam{$Needed} ) {
                    $Errors{ $Needed . 'Invalid' } = 'ServerError';
                }
            }
        }

        # check if a dashboard exists with this name
        my $NameExists = $DashboardObject->NameExistsCheck( Name => $GetParam{Name} );
        if ($NameExists) {
            $Errors{NameExists}    = 1;
            $Errors{'NameInvalid'} = 'ServerError';
        }

        # if no errors occurred
        if ( !%Errors ) {

            # add dashboard
            my $NewDashboardID = $DashboardObject->DashboardAdd(
                %GetParam,
            );

            if ($NewDashboardID) {
    
                # if the user would like to continue editing the dashboard, just redirect to the edit screen
                if (
                    defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
                    && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
                    )
                {
                    my $ID = $ParamObject->GetParam( Param => 'ID' ) || '';

                    return $LayoutObject->Redirect( OP => "Action=AdminKPIDashboardEdit;DashboardID=$NewDashboardID" );
                }
                else {
                    # otherwise return to overview
                    return $LayoutObject->Redirect( OP => "Action=$Self->{Action}");
                }
            }
        }

        # something has gone wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        $Output .= $LayoutObject->Notify( Priority => 'Error' );
        
        $Self->_Edit(
            Action => 'Add',
            Errors => \%Errors,
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminDashboard',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # change
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Change' ) {

        my $DashboardID = $ParamObject->GetParam( Param => 'ID' ) || '';

        my %Data = $DashboardObject->DashboardGet( ID => $DashboardID );
        if ( !%Data ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Dashboard not found!'),
            );
        }

        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        $Self->_Edit(
            Action => 'Change',
            %Data,
        );

        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminDashboard',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------ #
    # change action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my ( %GetParam, %Errors );
        for my $Parameter (qw(ID Name AvailableInterface CustomerID ValidID)) {
            $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
        }

        @{$GetParam{GroupIDs}} = $ParamObject->GetArray( Param => "GroupIDs" );
	    $GetParam{GroupIDs} = join (',', @{$GetParam{GroupIDs}});

        for my $Needed (qw(Name AvailableInterface ValidID)) {
            if ( !$GetParam{$Needed} ) {
                $Errors{ $Needed . 'Invalid' } = 'ServerError';
            }
        }

        # check needed data
        if ( $GetParam{AvailableInterface} eq 'AgentInterface' ) {
            if ( !$GetParam{GroupIDs} ) {
                $Errors{'GroupIDsInvalid'} = 'ServerError';
            }
        }
        elsif ( $GetParam{AvailableInterface} eq 'CustomerInterface' ) {
            if ( !$GetParam{CustomerID} ) {
                $Errors{'CustomerIDInvalid'} = 'ServerError';
            }
        }
        else {
            for my $Needed (qw(CustomerID GroupIDs)) {
                if ( !$GetParam{$Needed} ) {
                    $Errors{ $Needed . 'Invalid' } = 'ServerError';
                }
            }
        }

        my $DashboardID = $ParamObject->GetParam( Param => 'ID' ) || '';
        my %Data = $DashboardObject->DashboardGet( ID => $DashboardID );
        if ( !%Data ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Dashboard not found!'),
            );
        }

        # check if a dashboard exists with this name
        my $NameExists = $DashboardObject->NameExistsCheck( 
            Name => $GetParam{Name},
            ID   => $GetParam{ID},
        );

        if ($NameExists) {
            $Errors{NameExists}    = 1;
            $Errors{'NameInvalid'} = 'ServerError';
        }

        # if no errors occurred
        if ( !%Errors ) {

            # update dashboard
            my $Update = $DashboardObject->DashboardUpdate(
                %GetParam,
                UserID => $Self->{UserID}
            );

            if ($Update) {

                # if the user would like to continue editing the dashboard, just redirect to the edit screen
                if (
                    defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
                    && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
                    )
                {  
                    my $ID = $ParamObject->GetParam( Param => 'ID' ) || '';
                    return $LayoutObject->Redirect( OP => "Action=AdminKPIDashboardEdit;DashboardID=$ID" );
                }
                else {
                    # otherwise return to overview
                    return $LayoutObject->Redirect( OP => "Action=$Self->{Action}" );
                }
            }
        }

        # something has gone wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        $Output .= $LayoutObject->Notify( Priority => 'Error' );
        $Self->_Edit(
            Action => 'Change',
            Errors => \%Errors,
            %GetParam,
        );
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminDashboard',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # ------------------------------------------------------------
    # overview
    # ------------------------------------------------------------
    else {

        # header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        $Self->_Overview();

        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminDashboard',
            Data         => \%Param,
        );

        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get objects
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $DashboardObject = $Kernel::OM->Get('Kernel::System::Dashboard::Dashboard');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionAdd' );
    $LayoutObject->Block( Name => 'Filter' );

    $LayoutObject->Block(
        Name => 'OverviewResult',
        Data => \%Param,
    );

    my %List = $DashboardObject->DashboardList(Valid => 0);

    # if there are any dashboards, they are shown
    if (%List) {

        # get valid list
        my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

        for my $DashboardID ( sort { $List{$a} cmp $List{$b} } keys %List ) {

            my %Data = $DashboardObject->DashboardGet(
                ID => $DashboardID,
            );

            $LayoutObject->Block(
                Name => 'OverviewResultRow',
                Data => {
                    Valid => $ValidList{ $Data{ValidID} },
                    %Data,
                },
            );
        }
    }

    # otherwise a no data found msg is displayed
    else {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
            Data => {},
        );
    }

    return 1;
}

sub _Edit {
    my ( $Self, %Param ) = @_;

    my $ValidObject           = $Kernel::OM->Get('Kernel::System::Valid');
    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');

    $LayoutObject->Block(
        Name => 'Overview',
        Data => \%Param,
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' );

    # get valid list
    my %ValidList        = $ValidObject->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $Param{ValidOption} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $Param{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize Validate_Required ' . ( $Param{Errors}->{'ValidIDInvalid'} || '' ),
    );

    my %AvailableInterfaceList = (
        'AgentInterface'         => 'Agent Interface',
        'CustomerInterface'      => 'Customer Interface',
        'AgentCustomerInterface' => 'Agent and Customer Interface'
    );

    $Param{AvailableInterfaceOption} = $LayoutObject->BuildSelection(
        Data         => \%AvailableInterfaceList,
        Name         => 'AvailableInterface',
        SelectedID   => $Param{AvailableInterface} || '',
        Class        => 'Modernize Validate_Required',
        PossibleNone => 1,
    );

    my %Groups = $Kernel::OM->Get('Kernel::System::Group')->GroupList( Valid => 1 );
	$Param{GroupsStrg} = $LayoutObject->BuildSelection(
        Data         => \%Groups,
        Name         => 'GroupIDs',
        SelectedID   => $Param{Groups} || '',
        PossibleNone => 1,
        Translation  => 1,
        Class        => $Param{AvailableInterface} ne 'CustomerInterface' && $Param{AvailableInterface}  ? 'Modernize Validate_Required' : 'Modernize',
		Multiple     => 1,
    );

    my %ListCompany = $CustomerCompanyObject->CustomerCompanyList();

    $Param{CustomerIDStrg} = $LayoutObject->BuildSelection(
		Data         =>  \%ListCompany,
		Name         => 'CustomerID',
		Class        => $Param{AvailableInterface} ne 'AgentInterface' && $Param{AvailableInterface} ? 'Modernize Validate_Required' : 'Modernize',
		SelectedID   => $Param{CustomerID} || '',
		PossibleNone => 1,
    );

    if ( !$Param{AvailableInterface} ) {
        $Param{AgentDisplay} = "display: none;";
        $Param{CustomerDisplay} = "display: none;"
    }

    if ( $Param{AvailableInterface} eq 'AgentInterface' ) {
        $Param{CustomerDisplay} = "display: none;"
    }

    if ( $Param{AvailableInterface} eq 'CustomerInterface' ) {
        $Param{AgentDisplay} = "display: none;"
    }

    $LayoutObject->Block(
        Name => 'OverviewUpdate',
        Data => {
            %Param,
            %{ $Param{Errors} },
        },
    );

    # show appropriate messages for ServerError
    if ( defined $Param{Errors}->{NameExists} && $Param{Errors}->{NameExists} == 1 ) {
        $LayoutObject->Block( Name => 'ExistNameServerError' );
    }
    else {
        $LayoutObject->Block( Name => 'NameServerError' );
    }

    # Several error messages can be used for Name.
    $Param{Errors}->{InSettingNameServerError} //= 'Required';
    $LayoutObject->Block(
        Name => $Param{Errors}->{InSettingNameServerError} . 'NameServerError',
    );

    # Several error messages can be used for Valid option.
    $Param{Errors}->{ValidOptionServerError} //= 'Required';
    $LayoutObject->Block(
        Name => $Param{Errors}->{ValidOptionServerError} . 'ValidOptionServerError',
    );

    return 1;
}

1;