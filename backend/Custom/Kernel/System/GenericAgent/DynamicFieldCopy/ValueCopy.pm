# --
# Kernel/System/GenericAgent/DynamicFieldCopy/ValueCopy.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dsilva@serviceup.com.br
# --

package Kernel::System::GenericAgent::DynamicFieldCopy::ValueCopy;

use strict;
use warnings;
use utf8;
our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # 0=off; 1=on;
    $Self->{Debug} = $Param{Debug} || 0;

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get object
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    return 0 if !$Param{New}->{'CopyFieldTo'};
    return 0 if !$Param{New}->{'CopyFieldFrom'};

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1
    );

    my $ValueCopy = $Ticket{ "DynamicField_$Param{New}->{'CopyFieldFrom'}" };

    return 0 if !$ValueCopy;
   
    if ( $Param{New}->{'CopyFieldTo'} &&  defined $Param{New}->{'CopyFieldTo'} ) {
            
        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $Param{New}->{'CopyFieldTo'},
        );

        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{TicketID},
            Value              => $ValueCopy,
            UserID             => 1,
        );
    }
 
    return 1;
}

1;