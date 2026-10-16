# --
# var/packagesetup/EasyCategorization.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
# --
# written/edited by:
# * pdias@beonup.com.br
# * gesquetini@beonup.com.br
# * ccresencio@serviceup.com.br
# * poliveira@serviceup.com.br
# --

package var::packagesetup::EasyCategorization;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
);

=head1 NAME

EasyCategorization.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package CustomerContract

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

	use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CodeObject = $Kernel::OM->Get('var::packagesetup::EasyCategorization');

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

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

	# add JS and CSS
	$Self->_AddLoaderFiles();

    return 1;
}

=item CodeUninstall()

run the code install part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

	# add JS and CSS
	$Self->_RemoveLoaderFiles();

    return 1;
}

sub _AddLoaderFiles{
	my ( $Self, %Param ) = @_;

	my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

	my %Setting = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketZoom###002-Ticket",
	);

	my %EffectiveValue;
	my @LoaderCSS;
    my @LoaderJS;

  if ( $Setting{EffectiveValue}{CSS} ) {
        @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
    }

    if ( $Setting{EffectiveValue}{JavaScript} ) {
        @LoaderJS = @{$Setting{EffectiveValue}{JavaScript}};
    }

	# add CSS if not exists
	if ( !grep { $_ eq 'Core.Agent.EasyCategorization.css' } @LoaderCSS ) {
		push @LoaderCSS, 'Core.Agent.EasyCategorization.css';
	}

	# add JS if not exists
	if ( !grep { $_ eq 'Core.Agent.EasyCategorization.js' } @LoaderJS ) {
		push @LoaderJS, 'Core.Agent.EasyCategorization.js';
	}

	my $Success = $SysConfigObject->SettingsSet(
		UserID   => 1,
		Name     => 'Loader::Module::AgentTicketZoom###002-Ticket',
		Comments => 'Added CSS and JS to module EasyCategorization',
		Settings => [
			{
				Name     			   => 'Loader::Module::AgentTicketZoom###002-Ticket',
				EffectiveValue         => {
                    CSS        => \@LoaderCSS,
                    JavaScript => \@LoaderJS
                },
				IsValid                => 1,
				UserModificationActive => 0,
			},
		],
	);

	return $Success;
}

sub _RemoveLoaderFiles{
	my ( $Self, %Param ) = @_;

	my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

	my %Setting = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketZoom###002-Ticket",
	);

	my @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
	my @LoaderJS = @{$Setting{EffectiveValue}{JavaScript}};

	# remove CSS if exists
	for my $IndexCSS (0 .. $#LoaderCSS) {
		if( $LoaderCSS[$IndexCSS] eq 'Core.Agent.EasyCategorization.css' ){
			delete $LoaderCSS[$IndexCSS];
		}
	}

	# remove JS if exists
	for my $IndexJS (0 .. $#LoaderJS) {
		if( $LoaderJS[$IndexJS] eq 'Core.Agent.EasyCategorization.js' ){
			delete $LoaderJS[$IndexJS];
		}
	}

	my $Success = $SysConfigObject->SettingsSet(
		UserID   => $Self->{UserID},
		Comments => 'Removed CSS and JS from module TicketTimer',
		Settings => [
			{
				Name                   => 'Loader::Module::AgentTicketZoom###002-Ticket',
				EffectiveValue         => { CSS => \@LoaderCSS, JavaScript => \@LoaderJS },
				IsValid                => 1,
				UserModificationActive => 0,
			},
		],
	);

	return $Success;
}

1;
