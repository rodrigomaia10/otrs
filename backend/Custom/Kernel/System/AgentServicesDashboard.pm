# --
# Kernel/System/AgentServicesDashboard.pm
# Copyright (C) 2019 Service Up http://www.serviceup.com.br
#
# written/edited by:
# * ccresencio@serviceup.com.br
# --

package Kernel::System::AgentServicesDashboard;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 SearchTicketsNotHaveServices()
   
    my $Count = $AgentServicesDashboard->SearchTicketsNotHaveServices(
        CustomerID                => [ 1, 2, 3 ] ,
        QueueIDs                  => [ 1, 2, 3 ],
        TicketCreateTimeNewerDate => "2022-01-01 00:00:00", #required
        TicketCreateTimeOlderDate => "2022-01-01 23:59:59", #required
    );

=cut

sub SearchTicketsNotHaveServices {

    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Needed (qw(TicketCreateTimeNewerDate TicketCreateTimeOlderDate)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!"
            );
            return;
        }
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL;

    $SQL = "SELECT COUNT(*) FROM ticket WHERE service_id IS NULL AND create_time > ? AND create_time < ? ";

    if ( $Param{QueueIDs} ) {

        my $SQLQueryInCondition = $DBObject->QueryInCondition(
            Key       => 'queue_id',
            Values    => $Param{QueueIDs},
            QuoteType => 'Integer',
            BindMode  => 0,
        );

        $SQL .= ' AND ( ' . $SQLQueryInCondition . ' ) ';
    }

    if ( IsArrayRefWithData($Param{CustomerID}) ) {
 
        my $SQLQueryInCondition = $DBObject->QueryInCondition(
            Key       => 'customer_id',
            Values    => $Param{CustomerID},
            BindMode  => 0,
        );
        
        $SQL .= ' AND ( ' . $SQLQueryInCondition . ' ) ';
    }

    return if !$DBObject->Prepare(
        SQL   => $SQL,
        Bind  => [ \$Param{TicketCreateTimeNewerDate}, \$Param{TicketCreateTimeOlderDate}, ],
        Limit => 1,
    );
    
    my $Count;

    while (my @Row = $DBObject->FetchrowArray() ){
        $Count = $Row[0];
    }
   
    return $Count;
}