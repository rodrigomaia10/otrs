# --
# var/packagesetup/ProcessFieldReadOnly.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package var::packagesetup::ProcessFieldReadOnly;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
);

=head1 NAME

ProcessFieldReadOnly.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package ProcessFieldReadOnly

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

	use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $ProcessFieldReadOnlyObject = $Kernel::OM->Get('var::packagesetup::ProcessFieldReadOnly');   

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
		Name => "Loader::Module::AgentTicketProcess###002-ProcessManagement",
	);

	my @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
	my @LoaderJS  = @{$Setting{EffectiveValue}{JavaScript}};

	# add JS if not exists
	if ( 	( ! grep { $_ eq 'Core.Agent.ProcessFieldReadOnly.js' } @LoaderJS ) ) {
		push @LoaderJS, 'Core.Agent.ProcessFieldReadOnly.js';		
	}
	
	my $Success = $SysConfigObject->SettingsSet(
		UserID   => $Self->{UserID},                                    
		Comments => 'Added JS to module ProcessFieldReadOnly',                 
		Settings => [                                     
			{
				Name                   => 'Loader::Module::AgentTicketProcess###002-ProcessManagement',
				EffectiveValue         => { 
                    CSS        => \@LoaderCSS,
                    JavaScript => \@LoaderJS 
                },
				IsValid                => 1,              
				UserModificationActive => 0             
			},
		],
	);

	return $Success;
}

sub _RemoveLoaderFiles{
	my ( $Self, %Param ) = @_;

	my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

	my %Setting = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketProcess###002-ProcessManagement",
	);

	my @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
	my @LoaderJS  = @{$Setting{EffectiveValue}{JavaScript}};

	# remove JS if exists
	for my $IndexJS (0 .. $#LoaderJS) {		
		if( $LoaderJS[$IndexJS] eq 'Core.Agent.ProcessFieldReadOnly.js' ){
			delete $LoaderJS[$IndexJS];
		}	
	}
	
	my $Success = $SysConfigObject->SettingsSet(
		UserID   => $Self->{UserID},                                    
		Comments => 'Removed JS from module ProcessFieldReadOnly',                 
		Settings => [
			{
				Name                   => 'Loader::Module::AgentTicketProcess###002-ProcessManagement',
				EffectiveValue         => { 
                    CSS        => \@LoaderCSS,
                    JavaScript => \@LoaderJS 
                },
				IsValid                => 1,              
				UserModificationActive => 0              
			},
		],
	);

	return $Success;
}

1;