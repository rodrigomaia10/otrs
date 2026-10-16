# --
# Kernel/System/GenericAgent/UpdateCreateTime/TicketInitialValueGet.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * mbernardo@serviceup.com.br
# --

package Kernel::System::GenericAgent::UpdateCreateTime::UpdateCreateTime;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::DateTime',
    'Kernel::System::Log',
    'Kernel::System::Priority',
    'Kernel::System::Ticket',
    'Kernel::System::DB',
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
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');

    # get ticket data
    my %Ticket = $TicketObject->TicketGet(
        %Param,
        DynamicFields => 1,
    );

    my $FieldName = "DynamicField_$Param{New}->{DynamicField}";
    
    if ( $Ticket{$FieldName} ) {

        my $NewCreateTime = "update ticket set create_time=\"$Ticket{$FieldName}\" where id=$Ticket{TicketID}";
        
        $DBObject->Do( SQL => "$NewCreateTime" );

        my $Success = $TicketObject->TicketEscalationIndexBuild(
            TicketID => $Ticket{TicketID},
            UserID   => 1,
        );

        $TicketObject->HistoryAdd(
            Name => " create time updated $NewCreateTime ",
            HistoryType  => 'Misc',
            TicketID     => $Param{TicketID},
            UserID       => 1,
            CreateUserID => 1,
        );

        return 1;
    }
}

1;
