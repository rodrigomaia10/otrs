# --
# var/packagesetup/Kanban.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package var::packagesetup::Kanban;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
);

=head1 NAME

Kanban.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package Kanban

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

    my $Result = $Kanban->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;
	
	$Self->_AddInternalDynamicField();
	$Self->_AddInternalDynamicFieldTag();
    $Self->_AddLoaderFiles();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $Kanban->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_; 

	$Self->_DeleteInternalDynamicField();	
    $Self->_RemoveLoaderFiles();

    return 1;
}

sub _AddInternalDynamicField {
	my ( $Self, %Param ) = @_;
	
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $SysConfigObject    = $Kernel::OM->Get('Kernel::System::SysConfig');
	
	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'PositionOnKanbanBoard',
    );
	
	if ( IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField PositionOnKanbanBoard already exists.",
		);
		return 1;
	}

	# set specific config
    my $FieldConfig = {
        DefaultValue  => '',
    };

	
	# create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'PositionOnKanbanBoard',
        Label         => 'Posição no kanban',
        FieldOrder    => 5,
        FieldType     => 'Text',
        ObjectType    => 'Ticket',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field.",
		);
    }
	
	return 1;
}

sub _AddInternalDynamicFieldTag {
	my ( $Self, %Param ) = @_;
	
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $SysConfigObject    = $Kernel::OM->Get('Kernel::System::SysConfig');
	
	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'TagsOfKanban',
    );
	
	if ( IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField TagsOfKanban already exists.",
		);
		return 1;
	}

	# set specific config
    my $FieldConfig = {
        DefaultValue   => '',
		PossibleValues => {},
    };

	
	# create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => 'TagsOfKanban',
        Label         => 'TagsOfKanban',
        FieldOrder    => 5,
        FieldType     => 'Multiselect',
        ObjectType    => 'Ticket',
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
		Config        => $FieldConfig,
    );

    if ( !$FieldID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field.",
		);
    }
	
	return 1;
}

sub _DeleteInternalDynamicField {
	my ( $Self, %Param ) = @_;
	
	my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
	my $SysConfigObject         = $Kernel::OM->Get('Kernel::System::SysConfig');
		
	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'PositionOnKanbanBoard',
    );

	if ( !IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField PositionOnKanbanBoard does not exist.",
		);
		return 0;
	}

	my $AllDelete = $DynamicFieldValueObject->AllValuesDelete(
        FieldID   =>  $DynamicField->{ID},               
        UserID    => $Self->{UserID},
    );
	
	my $Success = $DynamicFieldObject->DynamicFieldDelete(
        ID      => $DynamicField->{ID},
        UserID  => $Self->{UserID},
        Reorder => 1,
    );
	
	if(!$Success){
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not delete $DynamicField->{Name}.",
		);
	}
	
	return 1;
}

sub _AddLoaderFiles {
	my ( $Self, %Param ) = @_;

	my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # To ticket note
	my %Setting = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketNote###002-Ticket",
	);

	my @LoaderJS = @{$Setting{EffectiveValue}{JavaScript}};

	# add JS if not exists
	if (grep $_ ne 'Core.Agent.Admin.PopUpTicketNote.js', @LoaderJS) {
		push @LoaderJS, 'Core.Agent.Admin.PopUpTicketNote.js';		
	}

	my @LoaderCSS;
	my $Success;
	if( IsHashRefWithData($Setting{EffectiveValue}{CSS}) ){
		@LoaderCSS = @{$Setting{EffectiveValue}{CSS}};

		$Success = $SysConfigObject->SettingsSet(
			UserID   => $Self->{UserID},                                    
			Comments => 'Added JS to module InBox Kanban',                 
			Settings => [                                     
				{
					Name                   => 'Loader::Module::AgentTicketNote###002-Ticket',
					EffectiveValue         => { CSS => \@LoaderCSS, JavaScript => \@LoaderJS },
					IsValid                => 1,              
					UserModificationActive => 0,              
				},
			],
		);
	}else{
		$Success = $SysConfigObject->SettingsSet(
			UserID   => $Self->{UserID},                                    
			Comments => 'Added JS to module InBox Kanban',                 
			Settings => [                                     
				{
					Name                   => 'Loader::Module::AgentTicketNote###002-Ticket',
					EffectiveValue         => { CSS => "", JavaScript => \@LoaderJS },
					IsValid                => 1,              
					UserModificationActive => 0,              
				},
			],
		);
	}


    # To ticket free text
    my %SettingFreeText = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketFreeText###002-Ticket",
	);

	my @LoaderJSFreeText = @{$SettingFreeText{EffectiveValue}{JavaScript}};

	# add JS if not exists
	if (grep $_ ne 'Core.Agent.Admin.PopUpFreeText.js', @LoaderJSFreeText) {
		push @LoaderJSFreeText, 'Core.Agent.Admin.PopUpFreeText.js';		
	}

	my @LoaderCSSFreeText;
	my $Success;

	if( IsHashRefWithData($SettingFreeText{EffectiveValue}{CSS}) ){
		@LoaderCSSFreeText =  @{$SettingFreeText{EffectiveValue}{CSS}};

		$Success = $SysConfigObject->SettingsSet(
			UserID   => $Self->{UserID},                                    
			Comments => 'Added JS to module InBox Kanban',                 
			Settings => [                                     
				{
					Name                   => 'Loader::Module::AgentTicketFreeText###002-Ticket',
					EffectiveValue         => { CSS => \@LoaderCSSFreeText, JavaScript => \@LoaderJSFreeText },
					IsValid                => 1,              
					UserModificationActive => 0,              
				},
			],
		);
	}else{
		$Success = $SysConfigObject->SettingsSet(
			UserID   => $Self->{UserID},                                    
			Comments => 'Added JS to module InBox Kanban',                 
			Settings => [                                     
				{
					Name                   => 'Loader::Module::AgentTicketFreeText###002-Ticket',
					EffectiveValue         => { CSS => "", JavaScript => \@LoaderJSFreeText },
					IsValid                => 1,              
					UserModificationActive => 0,              
				},
			],
		);

	}

	# To agent ticket closed
    my %SettingTicketClosed = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketClose###002-Ticket",
	);

	my @LoaderJSTicketClosed = @{$SettingTicketClosed{EffectiveValue}{JavaScript}};

	# add JS if not exists
	if (grep $_ ne 'Core.Agent.Admin.PopUpTicketClosed.js', @LoaderJSTicketClosed) {
		push @LoaderJSTicketClosed, 'Core.Agent.Admin.PopUpTicketClosed.js';		
	}
	
	my @LoaderCSSTicketClosed;
	
	if( IsHashRefWithData($SettingTicketClosed{EffectiveValue}{CSS}) ){
		@LoaderCSSTicketClosed =  @{$SettingTicketClosed{EffectiveValue}{CSS}};

		my $Success = $SysConfigObject->SettingsSet(
			UserID   => $Self->{UserID},                                    
			Comments => 'Added JS to module InBox Kanban',                 
			Settings => [                                     
				{
					Name                   => 'Loader::Module::AgentTicketClose###002-Ticket',
					EffectiveValue         => { CSS => \@LoaderCSSTicketClosed, JavaScript => \@LoaderJSTicketClosed },
					IsValid                => 1,              
					UserModificationActive => 0,              
				},
			],
		);
	}else{
		my $Success = $SysConfigObject->SettingsSet(
			UserID   => $Self->{UserID},                                    
			Comments => 'Added JS to module InBox Kanban',                 
			Settings => [                                     
				{
					Name                   => 'Loader::Module::AgentTicketClose###002-Ticket',
					EffectiveValue         => { CSS => "", JavaScript => \@LoaderJSTicketClosed },
					IsValid                => 1,              
					UserModificationActive => 0,              
				},
			],
		);
	}
	
	return $Success;
}

sub _RemoveLoaderFiles {
	my ( $Self, %Param ) = @_;

	my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # To ticket note
	my %Setting = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketNote###002-Ticket",
	);

	my @LoaderCSS = @{$Setting{EffectiveValue}{CSS}};
	my @LoaderJS = @{$Setting{EffectiveValue}{JavaScript}};

	# remove JS if exists
	for my $IndexJS (0 .. $#LoaderJS) {		
		if( $LoaderJS[$IndexJS] eq 'Core.Agent.Admin.PopUpTicketNote.js' ){
			delete $LoaderJS[$IndexJS];
		}	
	}
	
	my $Success = $SysConfigObject->SettingsSet(
		UserID   => $Self->{UserID},                                    
		Comments => 'Removed JS from module Kanban',                 
		Settings => [
			{
				Name                   => 'Loader::Module::AgentTicketNote###002-Ticket',
				EffectiveValue         => { CSS => \@LoaderCSS, JavaScript => \@LoaderJS },
				IsValid                => 1,              
				UserModificationActive => 0,              
			},
		],
	);

    # To ticket free text
	my %SettingFreeText = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketFreeText###002-Ticket",
	);

	my @LoaderCSSFreeText = @{$SettingFreeText{EffectiveValue}{CSS}};
	my @LoaderJSFreeText = @{$SettingFreeText{EffectiveValue}{JavaScript}};

	# remove JS if exists
	for my $IndexJS (0 .. $#LoaderJSFreeText) {		
		if( $LoaderJSFreeText[$IndexJS] eq 'Core.Agent.Admin.PopUpFreeText.js' ){
			delete $LoaderJSFreeText[$IndexJS];
		}	
	}
	
	my $Success = $SysConfigObject->SettingsSet(
		UserID   => $Self->{UserID},                                    
		Comments => 'Removed JS from module Kanban',                 
		Settings => [
			{
				Name                   => 'Loader::Module::AgentTicketFreeText###002-Ticket',
				EffectiveValue         => { CSS => \@LoaderCSSFreeText, JavaScript => \@LoaderJSFreeText },
				IsValid                => 1,              
				UserModificationActive => 0,              
			},
		],
	);

    # To ticket closed
	my %SettingTicketClosed = $SysConfigObject->SettingGet(
		Name => "Loader::Module::AgentTicketClose###002-Ticket",
	);

	my @LoaderCSSTicketClosed = @{$SettingTicketClosed{EffectiveValue}{CSS}};
	my @LoaderJSTicketClosed = @{$SettingTicketClosed{EffectiveValue}{JavaScript}};

	# remove JS if exists
	for my $IndexJS (0 .. $#LoaderJSTicketClosed) {		
		if( $LoaderJSTicketClosed[$IndexJS] eq 'Core.Agent.Admin.PopUpTicketClosed.js' ){
			delete $LoaderJSTicketClosed[$IndexJS];
		}	
	}
	
	my $Success = $SysConfigObject->SettingsSet(
		UserID   => $Self->{UserID},                                    
		Comments => 'Removed JS from module Kanban',                 
		Settings => [
			{
				Name                   => 'Loader::Module::AgentTicketClose###002-Ticket',
				EffectiveValue         => { CSS => \@LoaderCSSTicketClosed, JavaScript => \@LoaderJSTicketClosed },
				IsValid                => 1,              
				UserModificationActive => 0,              
			},
		],
	);

	return $Success;
}


1;