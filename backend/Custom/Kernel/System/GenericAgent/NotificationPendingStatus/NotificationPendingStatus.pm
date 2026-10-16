# --
# Custom/Kernel/System/GenericAgent/NotiificationPendingStatus/NotiificationPendingStatus.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * jguedes@serviceup.com.br
# --

package Kernel::System::GenericAgent::NotificationPendingStatus::NotificationPendingStatus;

use strict;
use warnings;

use utf8;

our @ObjectDependencies = (
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
    
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        Extended      => 1,
    );

    if ($Ticket{RealTillTimeNotUsed}){

        my $DateTimeObject = $Kernel::OM->Create(
            'Kernel::System::DateTime',
            ObjectParams => {
                Epoch => $Ticket{RealTillTimeNotUsed},
            }
        );

        my $DateTimeString = $DateTimeObject->Format( Format => '%Y-%m-%d %H:%M' );

        my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            Name => $Param{New}->{NameDF},
        );

        my $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicField,
            ObjectID           => $Param{TicketID},
            Value              => $DateTimeString,
            UserID             => 1,
        );

    }

    return 1;
    
}

1;