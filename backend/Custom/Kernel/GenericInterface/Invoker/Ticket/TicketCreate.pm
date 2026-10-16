# --
# Kernel/GenericInterface/Invoker/Ticket/TicketCreate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::GenericInterface::Invoker::Ticket::TicketCreate;

use strict;
use warnings;

use Kernel::GenericInterface::Invoker::Ticket::Common;

# prevent 'Used once' warning for Kernel::OM
use Kernel::System::ObjectManager;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

Kernel::GenericInterface::Invoker::Ticket::TicketCreate - GenericInterface TicketCreate Invoker backend

=head1 PUBLIC INTERFACE

=head2 new()

usually, you want to create an instance of this
by using Kernel::GenericInterface::Invoker->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (qw( DebuggerObject WebserviceID Invoker )) {
        if ( !$Param{$Needed} ) {
            return {
                Success      => 0,
                ErrorMessage => "Got no $Needed!"
            };
        }

        $Self->{$Needed} = $Param{$Needed};
    }

    $Self->{TicketCommonObject} = Kernel::GenericInterface::Invoker::Ticket::Common->new( %{$Self} );

    return $Self;
}

sub PrepareRequest {
    my ( $Self, %Param ) = @_;

    return $Self->{TicketCommonObject}->PrepareRequest(%Param);
}

sub HandleResponse {
    my ( $Self, %Param ) = @_;

    return $Self->{TicketCommonObject}->HandleResponse(%Param);
}

sub HandleError {
    my ( $Self, %Param ) = @_;

    return $Self->{TicketCommonObject}->HandleResponse(
        %Param,
        ResponseSuccess => 0,
    );
}

1;