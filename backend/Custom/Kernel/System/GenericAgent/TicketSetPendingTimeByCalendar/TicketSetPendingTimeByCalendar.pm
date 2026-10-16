# --
# Kernel/System/TicketSetPendingTimeByCalendar/TicketSetPendingTimeByCalendar.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::TicketSetPendingTimeByCalendar::TicketSetPendingTimeByCalendar;

use utf8;
use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

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

    # check needed stuff
    for my $Argument (qw(Time State Calendar)) {
        if ( !$Param{New}->{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need ' . $Argument,
            );
            return;
        }
    }

    # get object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my $PendingTime = $Param{New}->{Time};
    my $State       = $Param{New}->{State};
    my $Calendar    = $Param{New}->{Calendar};

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

    my $SuccessAdd = $DateTimeObject->Add(
        Minutes       => $PendingTime,
        AsWorkingTime => 1,
        Calendar      => $Calendar,
    );

    my $DateTimeString = $DateTimeObject->ToString();

    my $SuccessStateSet = $TicketObject->TicketStateSet(
        State     => $State,
        TicketID  => $Param{TicketID},
        UserID    => 1,
    );

    my $SuccessPendingTimeSet = $TicketObject->TicketPendingTimeSet(
        String   => $DateTimeString,
        TicketID => $Param{TicketID},
        UserID   => 1,
    );

}

1;