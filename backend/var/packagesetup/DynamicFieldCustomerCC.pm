# --
# var/packagesetup/DynamicFieldCustomerCC.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package var::packagesetup::DynamicFieldCustomerCC;

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

DynamicFieldCustomerCC.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package DynamicFieldCustomerCC

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

    my $Result = $DynamicFieldCustomerCC->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

	$Self->_AddInternalDynamicField(
        FieldName   => 'CustomerCC',
        FieldType   => 'CustomerCC',
        FieldConfig => {
            DefaultValue => '',
            Link         => '',
            LinkPreview  => '',
            RegExList    => []
        },
        FieldOrder => 110
    );

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $DynamicFieldCustomerCC->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

	$Self->_DeleteInternalDynamicField(
        FieldName => 'CustomerCC'
    );

    return 1;
}

sub _AddInternalDynamicField {
	my ( $Self, %Param ) = @_;

    # get object
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{FieldName},
    );

	if ( IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField $Param{FieldName} already exists.",
		);
		return 1;
	}

	# create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
		InternalField => 1,
        Name          => $Param{FieldName},
        Label         => $Param{FieldName},
        FieldOrder    => $Param{FieldOrder}, 
        FieldType     => $Param{FieldType},
        ObjectType    => 'Ticket',
        Config        => $Param{FieldConfig},
        ValidID       => 1,
		Reorder       => 1,
        UserID        => $Self->{UserID},
    );

    if ( !$FieldID ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'error',
			Message  => "Could not create the new field  $Param{FieldName}.",
		);
    }

    return 1;
}

sub _DeleteWebservice {
	my ( $Self, %Param ) = @_;

    # get object
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{FieldName},
    );

	if ( !IsHashRefWithData($DynamicField) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
			Priority => 'info',
			Message  => "DynamicField does not exist.",
		);
		return 0;
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
			Message  => "Could not delete $DynamicField->{Name}.",
		);
	}

	return 1;
}

1;
