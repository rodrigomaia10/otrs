# --
# Kernel/System/GenericAgent/TicketOpenByAgentOrCustomer.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * nfreitas@serviceup.com.br
# --

package Kernel::System::GenericAgent::TicketOpenByAgentOrCustomer::TicketOpenByAgentOrCustomer;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::User',
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
    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get customer user data, so that values can be stored in dynamic fields
    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
        DynamicFields => 1,
        Extended => 1,
    );

    my @HistoryLines = $TicketObject->HistoryGet(
        TicketID => $Param{TicketID},
        UserID   => 123,
    );

    my $OpenBy = 'Atendente';
   
    HISTORY:
    for my $History ( reverse @HistoryLines){

        if($History->{HistoryType} eq 'WebRequestCustomer'){
            $OpenBy = 'Cliente';
        }
    }


    return if !%Ticket;

    # get dynamic field objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $FieldName = $Param{New}->{DynamicField};

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => $FieldName,
    );

    if($OpenBy){
        # update dynamic field value for ticket
        my $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{TicketID},
            Value              => $OpenBy,
            UserID             => 1,
        );
    }

    return 1;
}

1;
