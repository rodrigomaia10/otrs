# --
# Kernel/System/InBoxLibrary/Ticket.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * msantos@serviceup.com.br
# --

package Kernel::System::InBoxLibrary::Ticket;

use strict;
use warnings;

use utf8;

use MIME::Base64;
use MIME::Words qw(:all);

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::CheckItem',
    'Kernel::System::Log',
    'Kernel::System::Valid',
);

=head1 NAME

Kernel::System::InBoxLibrary::Ticket

=head1 SYNOPSIS

Library gathering functions for tickets

=head2 TicketDateState()

Returns the date a ticket changed status
    
    my $Date = $InBoxLibraryObject->TicketDateState(
        TicketID   => 123,      # required
        State      => 'close'   # required
    );

=cut

sub TicketDateState {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(TicketID State)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL  => 'SELECT TH.create_time 
                FROM ticket_history TH join ticket_state TS 
                ON TH.state_id = TS.id WHERE TH.ticket_id = ? 
                AND (TS.id 
                IN (SELECT id FROM ticket_state WHERE type_id 
                IN (SELECT type_id FROM ticket_state WHERE name = ?))) 
                AND (SELECT id FROM ticket_history_type WHERE name = "StateUpdate") = TH.history_type_id
                ORDER BY TH.create_time DESC LIMIT 1',
        Bind  => [ \$Param{TicketID}, \$Param{State} ],
    );

    my @Row = $DBObject->FetchrowArray();
    my $Date = $Row[0];  

    return $Date;
}

=head2 TimeInState()

Returns the time the ticket remained in the state
    
    my $Time = $InBoxLibraryObject->TimeInState(
        TicketID   => 123,     # required
        State      => 'open'   # or StateID => 2, required
        Calendar   => 9        # optional
        InMinutes  => 1        # Optional, default 0. To bring time in minutes.
    );

=cut

sub TimeInState {
    my ( $Self, %Param ) = @_;

    # check required params
    if ( !$Param{State} && !$Param{StateID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need State or StateID!',
        );
        return;
    }

    # check required params
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID!',
        );
        return;
    }

    if( ! defined $Param{InMinutes} ) {
        $Param{InMinutes} = 0;
    }

    my $StateObject = $Kernel::OM->Get('Kernel::System::State');
    my $DBObject    = $Kernel::OM->Get('Kernel::System::DB');

    my $StateID;
    my %State;

    if($Param{State}){
        %State = $StateObject->StateGet(
            Name => $Param{State},
        );
    }
    else{
        %State = $StateObject->StateGet(
            ID => $Param{StateID},
        );
    }
    
    if($State{ID}){
        $StateID = $State{ID};
    }
    else{
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'State not found!',
        );
        return;
    }

    return if !$DBObject->Prepare(
        SQL  => 'SELECT H.history_type_id, H.state_id, H.create_time 
                FROM ticket_history H join ticket_history_type T 
                ON H.history_type_id = T.id 
                WHERE H.ticket_id = ? 
                AND (T.name = "StateUpdate" OR T.name = "NewTicket") 
                ORDER BY H.id DESC',
        Bind  => [ \$Param{TicketID} ],
    );

    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {

        my %DataRow;

        $DataRow{HistoryTypeID} = $Row[0];
        $DataRow{StateID}       = $Row[1];
        $DataRow{CreateTime}    = $Row[2];

        push @Data, \%DataRow;
    }

    my $TimeAccounted = 0;
    my $StartDate = 0;
    my $EndDate   = 0;

    HISTORY:
    for my $History (@Data){
 
        $StartDate = $History->{CreateTime};

        if(!$EndDate){

            my $DateTimeObject = $Kernel::OM->Create(
                'Kernel::System::DateTime'
            );
            $EndDate = $DateTimeObject->ToString();
        }      
        
        if ($History->{StateID} == $StateID){

            my $StartDateTime = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String   => $StartDate,
                }
            );

            my $EndDateTime = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String   => $EndDate,
                }
            );

            my $WorkingTimeDelta = $StartDateTime->Delta( 
				DateTimeObject => $EndDateTime,
				ForWorkingTime => 1,
				Calendar       => $Param{Calendar}
			);

            $TimeAccounted += $WorkingTimeDelta->{AbsoluteSeconds};       
        }
        
        $EndDate = $StartDate;    
    }

    if( $Param{InMinutes} == 1 ){
        return $TimeAccounted/60;
    }
    else{
        return $TimeAccounted;
    }
}

=head2 StateNumberTimes()

Returns the number of times in a state
    
    my $Count = $InBoxLibraryObject->StateNumberTimes(
        TicketID   => 123,     # required
        State      => 'open'   # or StateID => 2, required
    );

=cut

sub StateNumberTimes {
    my ( $Self, %Param ) = @_;

    # check required params
    if ( !$Param{State} && !$Param{StateID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need State or StateID!',
        );
        return;
    }

    # check required params
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID!',
        );
        return;
    }

    my $StateObject = $Kernel::OM->Get('Kernel::System::State');
    my $DBObject    = $Kernel::OM->Get('Kernel::System::DB');

    my $StateID;
    my %State;

    if($Param{State}){
        %State = $StateObject->StateGet(
            Name => $Param{State},
        );
    }
    else{
        %State = $StateObject->StateGet(
            ID => $Param{StateID},
        );
    }
    
    if($State{ID}){
        $StateID = $State{ID};
    }
    else{
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'State not found!',
        );
        return;
    }

    return if !$DBObject->Prepare(
        SQL  => 'SELECT H.history_type_id, H.state_id, H.create_time 
                FROM ticket_history H join ticket_history_type T 
                ON H.history_type_id = T.id 
                WHERE H.ticket_id = ? 
                AND (T.name = "StateUpdate" OR T.name = "NewTicket") 
                ORDER BY H.id DESC',
        Bind  => [ \$Param{TicketID} ],
    );

    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {

        my %DataRow;

        $DataRow{HistoryTypeID} = $Row[0];
        $DataRow{StateID}       = $Row[1];
        $DataRow{CreateTime}    = $Row[2];

        push @Data, \%DataRow;
    }

    my $Count = 0;

    HISTORY:
    for my $History ( @Data ) {
        
        if ($History->{StateID} == $StateID){
            $Count++;
        }
    }

    return $Count;
}

=head2 PreviousEvent()

Returns the time the ticket remained in the state
    
    my @PreviousValue = $InBoxAPIObject->PreviousEvent(
        TicketID   => $Param{TicketID},     
        Event      => $Param{New}->{Event} 
    );

=cut

sub PreviousEvent {
    my ( $Self, %Param ) = @_;

    # check required params
    if ( !$Param{Event}) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need State or StateID!',
        );
        return;
    }

    # check required params
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketID!',
        );
        return;
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        
    SQL  => 'SELECT * FROM ticket_history H 
        join ticket_history_type T ON H.history_type_id = T.id WHERE H.ticket_id = ? 
        AND (T.name = ?) ORDER BY H.id ASC',
        Bind  => [ \$Param{TicketID}, \$Param{Event}],
    );

    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        
        push @Data, {
            ID            => $Row[0],
            Name          => $Row[1],    
            HistoryTypeID => $Row[2],
            TicketID      => $Row[3],
            ArticleID     => $Row[4],
            TypeID        => $Row[5],
            QueueID       => $Row[6],
            OwnerID       => $Row[7],
            PriorityID    => $Row[8],
            StateID       => $Row[9],
            CreateTime    => $Row[10],
            CreateBy      => $Row[11],
            ChangeTime    => $Row[12],
            ChangeBy      => $Row[12]
        };
    }

    return @Data;
    
}

=head2 SLAStatusSolutionTime()

Returns the status of the ticket to the Solution SLA

    my $GetSLAInAndOut = $InBoxLibraryObject->SLAStatusSolutionTime(
        TicketID => 1
    );

=cut

sub SLAStatusSolutionTime {
    my ( $Self, %Param ) = @_;

     # check needed stuff
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need TicketID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $DBVersion = uc $DBObject->Version();

	my $SLAStatus;

    if ($DBVersion =~ 'MARIADB' || $DBVersion =~ 'MYSQL') {

        return if !$DBObject->Prepare(
            SQL => "SELECT T.tn,
                    IF( 
                        EXISTS(
                            SELECT name
                            FROM ticket_history
                            WHERE ticket_id =  T.id AND name = '%%EscalationSolutionTimeStart%%triggered'
                        ), 'SLA OUT', 'SLA IN'
                    ) SLA_STATUS ,
                    IF( 
                        EXISTS(
                            SELECT create_time
                            FROM ticket_history
                            WHERE ticket_id =  T.id AND name = '%%EscalationSolutionTimeStart%%triggered'
                        ), create_time, '0'
                    ) CREATE_TIME 
                    FROM ticket T WHERE T.id = ?",
            Bind  => [ \$Param{TicketID} ],
        );

        # fetch the result
        while ( my @Row = $DBObject->FetchrowArray() ) {
            $SLAStatus->{SLAStatus}     = $Row[1];
            $SLAStatus->{SLACreateTime} = $Row[2];
        }
    
    }
    else {
       
        return if !$DBObject->Prepare(
            SQL => "SELECT T.tn, 
                        EXISTS ( SELECT name FROM ticket_history WHERE ticket_id =  T.id AND name = '%%EscalationSolutionTimeStart%%triggered' ) AS SLA_STATUS,
                        ( SELECT create_time FROM ticket_history WHERE ticket_id =  T.id AND name = '%%EscalationSolutionTimeStart%%triggered' LIMIT 1 ) AS CREATE_TIME 
                    FROM ticket T WHERE T.id = ? ",
            Bind  => [ \$Param{TicketID} ],
        );

        # fetch the result
        while ( my @Row = $DBObject->FetchrowArray() ) {

            if ( $Row[1] ) {
                $SLAStatus->{SLAStatus} = "SLA OUT";
            }
            else {
                $SLAStatus->{SLAStatus} = "SLA IN";
            }

            if ( $Row[2] ) {
                $SLAStatus->{SLACreateTime} = $Row[2];
            }
            else {
                $SLAStatus->{SLACreateTime} = 0;
            }
        }
    }

    return  $SLAStatus;
}

=head2 SLAStatusResponseTime()

Returns the status of the ticket to the Response SLA

    my $GetSLAInAndOut = $InBoxLibraryObject->SLAStatusResponseTime(
        TicketID => 1
    );

=cut

sub SLAStatusResponseTime {
    my ( $Self, %Param ) = @_;

     # check needed stuff
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need TicketID!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $DBVersion = uc $DBObject->Version();

    my $SLAStatus;

    if ($DBVersion =~ 'MARIADB' || $DBVersion =~ 'MYSQL') {

        return if !$DBObject->Prepare(
            SQL => "SELECT T.tn,
                    IF( 
                        EXISTS(
                            SELECT name
                            FROM ticket_history
                            WHERE ticket_id =  T.id AND name = '%%EscalationResponseTimeStart%%triggered'
                        ), 'SLA OUT', 'SLA IN'
                    ) SLA_STATUS ,
                    IF( 
                        EXISTS(
                            SELECT create_time
                            FROM ticket_history
                            WHERE ticket_id =  T.id AND name = '%%EscalationResponseTimeStart%%triggered'
                        ), create_time, '0'
                    ) CREATE_TIME 
                    FROM ticket T WHERE T.id = ?",
            Bind  => [ \$Param{TicketID} ],
        );

        # fetch the result
        while ( my @Row = $DBObject->FetchrowArray() ) {
            $SLAStatus->{SLAStatus}     = $Row[1];
            $SLAStatus->{SLACreateTime} = $Row[2];
        }
    }
    else {
       
        return if !$DBObject->Prepare(
            SQL => "SELECT T.tn, 
                        EXISTS ( SELECT name FROM ticket_history WHERE ticket_id =  T.id AND name = '%%EscalationResponseTimeStart%%triggered' ) AS SLA_STATUS,
                        ( SELECT create_time FROM ticket_history WHERE ticket_id =  T.id AND name = '%%EscalationResponseTimeStart%%triggered' LIMIT 1 ) AS CREATE_TIME 
                    FROM ticket T WHERE T.id = ? ",
            Bind  => [ \$Param{TicketID} ],
        );

        # fetch the result
        while ( my @Row = $DBObject->FetchrowArray() ) {

            if ( $Row[1] ) {
                $SLAStatus->{SLAStatus} = "SLA OUT";
            }
            else {
                $SLAStatus->{SLAStatus} = "SLA IN";
            }

            if ( $Row[2] ) {
                $SLAStatus->{SLACreateTime} = $Row[2];
            }
            else {
                $SLAStatus->{SLACreateTime} = 0;
            }
        }
    }

    return  $SLAStatus;
}

=head2 SLASolutionTimeInPercentage()

Returns the Percentage SLA Solution

    my $GetSLAInAndOut = $InBoxLibraryObject->SLASolutionTimeInPercentage(
        TicketID => 1
    );

=cut
sub SLASolutionTimeInPercentage {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need TicketID!",
        );
        return;
    }
     
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');

    
    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
        UserID   => 1,
    );

    my %Escalation = $TicketObject->TicketEscalationDateCalculation(
        Ticket => \%Ticket,
        UserID => 1,
    );

    return if !$Ticket{SLAID};

    my %SLAData = $SLAObject->SLAGet(
        SLAID  => $Ticket{SLAID},
        UserID => 1,
    );

    my $vb = $SLAData{SolutionTime} * 60; # Total SLA value in sec
    my $va = $Escalation{SolutionTime};   # Current solution time in sec

    my $aux = $vb - $va;

    my $pc = 0;

    if ( $vb != 0 ) {
        $pc = ( ( $aux * 100 ) / $vb );
    }

    return $pc;
}

1;