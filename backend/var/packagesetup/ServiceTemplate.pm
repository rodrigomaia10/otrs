# --
# var/packagesetup/ServiceTemplate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package var::packagesetup::ServiceTemplate;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

our @ObjectDependencies = (
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
);

=head1 NAME

ServiceTemplate.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package ServiceTemplate

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

=cut

sub new {
    my ( $Type, %Param ) = @_;
    my $Self = {};
    bless( $Self, $Type );

	$Self->{UserID} = 1;

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $ServiceTemplate->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

	$Self->_AddJS();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $ContractManagement->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

	$Self->_RemoveJS();

    return 1;
}

sub _AddJS{
	my ( $Self, %Param ) = @_;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # set frontend modules
    my @Frontend = qw(AgentTicketProcess CustomerTicketProcess AgentTicketPhone AgentTicketEmail CustomerTicketMessage);

    # add dynamic field customer contract in the sysconfig of modules
    foreach my $ItemUpdate ( @Frontend ){

        my $ConfigName = "Loader::Module::$ItemUpdate###002-Ticket";

        if ( $ItemUpdate eq 'AgentTicketProcess' || $ItemUpdate eq 'CustomerTicketProcess' ) { 
            $ConfigName = "Loader::Module::$ItemUpdate###002-ProcessManagement";
        }

        my %Setting = $SysConfigObject->SettingGet(
            Name => $ConfigName,
        );

        my @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
        my @LoaderJS = @{$Setting{EffectiveValue}{JavaScript}};

        # add JS if not exists
        if (grep $_ ne 'Core.Agent.ServiceTemplate.js', @LoaderJS) {
            push @LoaderJS, 'Core.Agent.ServiceTemplate.js';		
        }
        
        my $SettingsDeployed = $SysConfigObject->SettingsSet(
            UserID   => $Self->{UserID},                                    
            Comments => 'Added JS to module ServiceTemplate',                 
            Settings => [                                     
                {
                    Name                   => $ConfigName,
                    EffectiveValue         => {
                        CSS        => \@LoaderCSS,
                        JavaScript => \@LoaderJS
                    },
                    IsValid                => 1,              
                    UserModificationActive => 0,              
                },
            ],
        );        

        if ( !$SettingsDeployed ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Message  => "Error while deploying the migrated permissions!",
                Priority => 'error',
            );
        }
    }

	return 1;
}

sub _RemoveJS{
	my ( $Self, %Param ) = @_;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # set frontend modules
    my @Frontend = qw(AgentTicketProcess CustomerTicketProcess AgentTicketPhone AgentTicketEmail CustomerTicketMessage);

    # add dynamic field customer contract in the sysconfig of modules
    foreach my $ItemUpdate ( @Frontend ) {
        
        my $ConfigName = "Loader::Module::$ItemUpdate###002-Ticket";

        if ( $ItemUpdate eq 'AgentTicketProcess' || $ItemUpdate eq 'CustomerTicketProcess' ) { 
            $ConfigName = "Loader::Module::$ItemUpdate###002-ProcessManagement";
        }

        my %Setting = $SysConfigObject->SettingGet(
            Name => $ConfigName,
        );

        my @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
        my @LoaderJS = @{$Setting{EffectiveValue}{JavaScript}};

        my @DeleteJS = reverse(grep { $LoaderJS[$_] eq 'Core.Agent.ServiceTemplate.js' } 0.. $#LoaderJS);

        for (@DeleteJS) {
           splice (@LoaderJS, $_, 1);
        }

       my $SettingsDeployed = $SysConfigObject->SettingsSet(
            UserID   => $Self->{UserID},                                    
            Comments => 'Remove JS to module ServiceTemplate',                 
            Settings => [                                     
                {
                    Name                   => $ConfigName,
                    EffectiveValue         => {
                        CSS        => \@LoaderCSS,
                        JavaScript => \@LoaderJS
                    },
                    IsValid                => 1,              
                    UserModificationActive => 0,              
                },
            ],
        );        

        if ( !$SettingsDeployed ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Message  => "Error while deploying the migrated permissions!",
                Priority => 'error',
            );
        }
    }

	return 1;
}

1;
