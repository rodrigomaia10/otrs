# --
# Custom/Kernel/System/GenericAgent/QueuePreference/QueuePreferenceToDynamicField.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::System::GenericAgent::QueuePreference::QueuePreferenceToDynamicField;

use strict;
use warnings;

use utf8;

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::Queue',
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
    
    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1
    );

    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

    my %Preferences = $QueueObject->QueuePreferencesGet(
        QueueID => $Ticket{QueueID},
        UserID  => 1,
    );
    
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name =>  $Param{New}->{TicketField},
    );

    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $Success = $DynamicFieldValueObject->ValueSet(
        FieldID  => $DynamicField->{ID},
        ObjectID => $Param{TicketID},

        Value    => [
            {
                ValueText => $Preferences{$Param{New}->{QueueField}},
            },
        ],
        UserID   => 1,
    );
}

1;