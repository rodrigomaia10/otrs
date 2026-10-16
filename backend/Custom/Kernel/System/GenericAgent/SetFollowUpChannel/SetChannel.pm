# --
# Kernel/System/GenericAgent/SetFollowUpChannel/SetChannel.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dsilva@serviceup.com.br
# --

package Kernel::System::GenericAgent::SetFollowUpChannel::SetChannel;

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

    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID}
    );      

    my $History = $Self->_TicketHistoryGet(
        TicketID => $Param{TicketID}
    );    

    my $Channel;

    if ( $History->{Name} eq '%%' ) { 
        $Channel = 'Portal';        
    }
    else {
        $Channel = 'Email';
    }  

    return 0 if !$Channel;  

    if ( $Param{New}->{'FieldChannel'} &&  defined $Param{New}->{'FieldChannel'} ) {
            
        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $Param{New}->{FieldChannel},
        );

        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{TicketID},
            Value              => $Channel,
            UserID             => 1,
        );
    }
 
    return 1;
}

sub _TicketHistoryGet {
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
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');  

    if ( $Param{TicketID} ) {
        return if !$DBObject->Prepare(
            SQL   => 'SELECT 
                            TH.id, TH.name, TH.history_type_id, THT.name, TH.ticket_id, TH.article_id,
                            TH.type_id, TH.queue_id, TH.owner_id, TH.priority_id, TH.state_id, TH.create_time,
                            TH.create_by, TH.change_time, TH.change_by
                        FROM ticket_history TH JOIN ticket_history_type THT
                            ON TH.history_type_id = THT.id
                        WHERE TH.history_type_id IN ( 2 ) 
                        AND TH.ticket_id = ?
                        ORDER BY create_time DESC',
            Bind  => [ \$Param{TicketID} ],
            Limit => 1
        );
    }
   
    my %History;
    while ( my @Row = $DBObject->FetchrowArray() ) {

        %History = (
            ID            => $Row[0],
            Name          => $Row[1],
            HistoryTypeID => $Row[2],
            HistoryType   => $Row[3],
            TicketID      => $Row[4],
            ArticleID     => $Row[5],
            TypeID        => $Row[6],
            QueueID       => $Row[7],
            OwnerID       => $Row[8],
            PriorityID    => $Row[9],
            StateID       => $Row[10],
            CreateTime    => $Row[11],
            CreateBy      => $Row[12],
            ChangeTime    => $Row[13],
            ChangeBy      => $Row[14]
        );
    }

    return \%History;
}

1;