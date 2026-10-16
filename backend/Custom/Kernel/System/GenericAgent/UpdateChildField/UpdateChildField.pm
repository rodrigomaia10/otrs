# --
# /opt/Dev/CustomModuleGenericAgent/src/Custom/Kernel/System/GenericAgent/UpdateChildField/UpdateChildField.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# --

package Kernel::System::GenericAgent::UpdateChildField::UpdateChildField;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {

    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

}

sub Run {

    my ( $Self, %Param ) = @_;

    my $LinkObject              = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $ParamObject             = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $BackendObject           = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # Get dynamic field data
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DynamicField}
    );

    # Get dynamic field value
    my $ValueField = $ParamObject->GetParam(
        Param => 'DynamicField_' . $DynamicField->{Name}
    );

    # Validate field empty
    return if ( !$ValueField );

    # Get list of associated tickets
    my $LinkList = $LinkObject->LinkList(
        Object    => 'Ticket',
        Key       => $Param{TicketID},
        State     => 'Valid',
        UserID    => 1,
    );

    return if ( !$LinkList );

    VALIDATE:
    # Take each ticket associated with the ticket to update the dynamic field value
    for my $TicketIDChild ( keys %{ $LinkList->{Ticket}->{ParentChild}->{Target} } ){

        # Get dynamic field id of so-called child
        my $ValueFieldChild = $DynamicFieldValueObject->ValueGet(
            FieldID            => $DynamicField->{ID},
            ObjectID           => $TicketIDChild,
        );

        next VALIDATE if ( $ValueField eq $ValueFieldChild->[0]->{ValueText} );

        # Update child dynamic field
        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicField,      
            ObjectID           => $TicketIDChild,
            Value              => $ValueField,
            UserID             => 1,
        );
    }
}

1;