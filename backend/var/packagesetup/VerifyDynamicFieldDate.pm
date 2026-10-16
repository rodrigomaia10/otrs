# --
# var/packagesetup/VerifyDynamicFieldDate.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# -- 

package var::packagesetup::VerifyDynamicFieldDate;

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

VerifyDynamicFieldDate.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package VerifyDynamicFieldDate

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

    my $Result = $VerifyDynamicFieldDate->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

	$Self->_AddInternalDynamicField();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $VerifyDynamicFieldDate->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

	$Self->_DeleteInternalDynamicField();

    return 1;
}

sub _AddInternalDynamicField {
	my ( $Self, %Param ) = @_;
	my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # First Dynamic Field: DataAtingida
	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'DataAtingida',
    );

	if ( IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField DataAtingida already exists.",
		);
	}
	else {
        # set specific config
        my $FieldConfig = {
            DefaultValue  => '',
            PossibleValues => {
                'Sim' => $LayoutObject->{LanguageObject}->Translate('Yes'),
                'Nao' => $LayoutObject->{LanguageObject}->Translate('No'),
            },
            PossibleNone   => '0'
        };

        # create a new field
        my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
            InternalField => 1,
            Name          => 'DataAtingida',
            Label         => 'Data Atingida',
            FieldOrder    => 3,
            FieldType     => 'Dropdown',
            ObjectType    => 'Ticket',
            Config        => $FieldConfig,
            ValidID       => 1,
            Reorder       => 1,
            UserID        => $Self->{UserID},
        );

        if ( !$FieldID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Could not create the new field DataAtingida.",
            );
        }
    }

	return 1;
}

sub _DeleteInternalDynamicField {
	my ( $Self, %Param ) = @_;

	my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
	my $ConfigObject            = $Kernel::OM->Get('Kernel::Config');
	my $SysConfigObject         = $Kernel::OM->Get('Kernel::System::SysConfig');

    # Delete DataAtingida
	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'DataAtingida',
    );

	if ( !IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField DataAtingida does not exist.",
		);
	}

	$DynamicFieldValueObject->AllValuesDelete(
        FieldID => $DynamicField->{ID},
        UserID  => $Self->{UserID},
    );

	my $Success = $DynamicFieldObject->DynamicFieldDelete(
        ID      => $DynamicField->{ID},
        UserID  => $Self->{UserID},
        Reorder => 1,
    );

	if(!$Success){
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not delete DataAtingida.",
		);
	}
    
	return 1;
}

1;