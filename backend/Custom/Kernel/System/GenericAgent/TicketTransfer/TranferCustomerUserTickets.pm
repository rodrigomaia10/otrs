# --
# Kernel/System/GenericAgent/TicketTransfer/TranferCustomerUserTickets.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dsilva@serviceup.com.br
# --

package Kernel::System::GenericAgent::TicketTransfer::TranferCustomerUserTickets;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::Ticket',
    'Kernel::System::CustomerUser'
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
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');

    # get customer user data, so that values can be stored in dynamic fields
    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
        DynamicFields => 1,
    );

    return if !$Param{New}->{NewCustomerEmail} || !$Param{New}->{NewCustomerLogin};
    return if !$Param{New}->{Queues};
    return if !%Ticket;
    return if !$Ticket{$Param{New}->{NewCustomerEmail}} || !$Ticket{$Param{New}->{NewCustomerLogin}};;

    # get dynamic field objects
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    
    my $CustomerLogin;

    if ( $Param{New}->{NewCustomerEmail} ) {

        my $NewCustomerEmail = $Ticket{$Param{New}->{NewCustomerEmail}};

        my %List = $CustomerUserObject->CustomerSearch(
            PostMasterSearch => $NewCustomerEmail,
            Valid            => 1
        );

        for my $Login ( keys %List ) {
            $CustomerLogin = $Login;
        }
    }
    elsif ( $Param{New}->{NewCustomerLogin} ) {

        my $NewCustomerLogin = $Ticket{$Param{New}->{NewCustomerLogin}};

        my %List = $CustomerUserObject->CustomerSearch(
            UserLogin => $NewCustomerLogin,
            Valid     => 1,
        );

        for my $Login ( keys %List ) {
            $CustomerLogin = $Login;
        }
    }

    my %Filter;

    if ( $Param{New}->{States} ) {

        my @States = split /;/, $Param{New}->{States};

        $Filter{States} = \@States;
    }
    elsif ( $Param{New}->{StateType} ) {
        $Filter{StateType} = $Param{New}->{StateType};
    }

    if ( $Param{New}->{Queues} ) {

        my @Queues = split /;/, $Param{New}->{Queues};

        $Filter{Queues} = \@Queues;
    }

    my @TicketIDs = $TicketObject->TicketSearch(
        %Filter,
        Result            => 'ARRAY',
        CustomerUserLogin => $Ticket{CustomerUserID},
        UserID            => 1
    );

    for my $TicketID ( @TicketIDs ) {

        $TicketObject->TicketCustomerSet(
            User     => $CustomerLogin,
            TicketID => $TicketID,
            UserID   => 1,
        );
    }

    return 1;
}

1;