# --
# Kernel/System/EasyCategorization.pm
# Copyright (C) 2019 Service Up http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * gesquetini@beonup.com.br
# * mbernardo@beonup.com.br
# * ccresencio@serviceup.com.br
# * poliveira@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * gbolsoni@serviceup.com.br
# --

package Kernel::System::EasyCategorization;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Ticket',
	'Ticket::Service::Default::UnknownCustomer'
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 GetServiceList()
   
    my $ServiceList = $EasyCategorizationObject->GetServiceList(
        %GetParam,
        TicketID       => $Self->{TicketID},
        CustomerUserID => $Ticket{CustomerUserID},
        QueueID        => $Ticket{QueueID},
        Action		   => 'AgentTicketZoom'
    );
=cut

sub GetServiceList {
    my ( $Self, %Param ) = @_;

    # get options for default services for unknown customers
    my $DefaultServiceUnknownCustomer
        = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Service::Default::UnknownCustomer');
        
    # check if no CustomerUserID is selected
    # if $DefaultServiceUnknownCustomer = 0 leave CustomerUserID empty, it will not get any services
    # if $DefaultServiceUnknownCustomer = 1 set CustomerUserID to get default services
    if ( !$Param{CustomerUserID} && $DefaultServiceUnknownCustomer ) {
        $Param{CustomerUserID} = '<DEFAULT>';
    }

    # get service list
    my %Service;
    if ( $Param{CustomerUserID} && $Param{Action} ) {
        %Service = $Kernel::OM->Get('Kernel::System::Ticket')->TicketServiceList(
            %Param,
			Action => $Param{Action} || 'AgentTicketZoom',
        );
    }

    return \%Service;
}


=head2 GetSLAList()
   
    my $SLAs = $EasyCategorizationObject->GetSLAList(
        %GetParam,
        QueueID      	=> $Ticket{QueueID},
        ServiceID      	=> $GetParam{ServiceID},
        CustomerUserID 	=> $Ticket{CustomerUserID},
    );

=cut

sub GetSLAList {
    my ( $Self, %Param ) = @_;

    # if non set customers can get default services then they should also be able to get the SLAs
    #  for those services (this works during ticket creation).
    # if no CustomerUserID is set, TicketSLAList will complain during AJAX updates as UserID is not
    #  passed. See bug 11147.

    # get options for default services for unknown customers
    my $DefaultServiceUnknownCustomer
        = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Service::Default::UnknownCustomer');

    # check if no CustomerUserID is selected
    # if $DefaultServiceUnknownCustomer = 0 leave CustomerUserID empty, it will not get any services
    # if $DefaultServiceUnknownCustomer = 1 set CustomerUserID to get default services
    if ( !$Param{CustomerUserID} && $DefaultServiceUnknownCustomer ) {
        $Param{CustomerUserID} = '<DEFAULT>';
    }

    my %SLA;
    if ( $Param{ServiceID} ) {
        %SLA = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSLAList(
            %Param,
        );
    }
    return \%SLA;
}

=head2 GetTypeList()
   
    my $Types = $EasyCategorizationObject->GetTypeList(
        %GetParam,
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID}
    );
    
=cut


sub GetTypeList {
    my ( $Self, %Param ) = @_;

    # get type
    my %Type;
    if ( $Param{QueueID} || $Param{TicketID} ) {
        %Type = $Kernel::OM->Get('Kernel::System::Ticket')->TicketTypeList(
            %Param,
        );
    }
    return \%Type;
}

=head2 GetPriorityList()
   
    my $Priorities = $EasyCategorizationObject->GetPriorityList(
        %GetParam,
        TicketID => $Self->{TicketID},
        Action	 => $Self->{Action},
        UserID   => $Self->{UserID},
    );

=cut

sub GetPriorityList {
    my ( $Self, %Param ) = @_;

	my %Priorities;
	if ( $Param{Action} || $Param{TicketID} ) {
        %Priorities = $Kernel::OM->Get('Kernel::System::Ticket')->TicketPriorityList(
			%Param,
			Action   => $Param{Action},
			TicketID => $Param{TicketID},
		);
    }

    # get config of frontend module
    my $Config = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Param{Action}");

    if ( !$Config->{PriorityDefault} ) {
        $Priorities{''} = '-';
    }
    return \%Priorities;
}

=head2 GetStateList()
   
    my $States = $EasyCategorizationObject->GetStateList(
        %GetParam,
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
    );

    
=cut

sub GetStateList {
    my ( $Self, %Param ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    
	my %States;
	if ( $Param{StateID} || $Param{TicketID} || $Param{QueueID}  ) {
        %States = $Kernel::OM->Get('Kernel::System::Ticket')->TicketStateList(
			%Param,
		);
    }

    return \%States;
}

=head2 GetSatateTicket()
   
    my $States = $EasyCategorizationObject->GetSatateTicket(
        %GetParam,
        TicketID => $Self->{TicketID},
    );

    
=cut
sub GetSatateTicket {
    my ( $Self, %Param ) = @_;
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my $NameState = "";
    
    if( $Param{TicketID} ){
        return if !$DBObject->Prepare(
            SQL   => 'SELECT ticket_state.name FROM ticket JOIN ticket_state ON ticket.ticket_state_id = ticket_state.id WHERE ticket.id = ?',
            Bind  => [ \$Param{TicketID} ],
            Limit => 1,
        );

      
        my @Row = $DBObject->FetchrowArray();
        $NameState = $Row[0];
        
    }

    return $NameState;
}

=head2 GetOwnerList()
   
    my $Owner = $EasyCategorizationObject->GetOwnerList(
        %GetParam,
        %Ticket,
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
    );

=cut

sub GetOwnerList {
    my ( $Self, %Param ) = @_;

    # get list of agents with ticket permission
    my %PermissionList;

    if( $Param{TicketID} ){  
        my %List = $Kernel::OM->Get('Kernel::System::User')->UserList(
            %Param
        );         

        foreach my $UserID (keys %List){
            # check permissions        
            my $Access = $Kernel::OM->Get('Kernel::System::Ticket')->TicketPermission(
                Type     => 'owner',
                TicketID => $Param{TicketID},
                UserID   => $UserID,
            );
            
            if ( $Access ) {
                $PermissionList{$UserID} = $List{$UserID};
            }
        }
    }

    return \%PermissionList;
}

=head2 GetOwnerListByQueue()
   
    my $Owner = $EasyCategorizationObject->GetOwnerListByQueue(
        %GetParam,
        UserID   => $Self->{UserID},
    );

=cut

sub GetOwnerListByQueue {
    my ( $Self, %Param ) = @_;

    # get list of agents with queue permission
    my %PermissionList;
    my %ShownUsers;

    my %AllGroupsMembers = $Kernel::OM->Get('Kernel::System::User')->UserList(
        Type  => 'Long',
        Valid => 1,
    );

    my $GID        = $Kernel::OM->Get('Kernel::System::Queue')->GetQueueGroupID( QueueID => $Param{QueueID} );
    my %MemberList = $Kernel::OM->Get('Kernel::System::Group')->PermissionGroupGet(
        GroupID => $GID,
        Type    => 'owner',
    );

    for my $KeyMember ( sort keys %MemberList ) {
        if ( $AllGroupsMembers{$KeyMember} ) {
            $PermissionList{$KeyMember} = $AllGroupsMembers{$KeyMember};
        }
    }

    return \%PermissionList;

}

=head2 GetQueueList()
   
    my $QueuesList = $EasyCategorizationObject->GetQueueList(
        %GetParam,
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
    );
    
=cut

sub GetQueueList {
    my ( $Self, %Param ) = @_; 

    # get the list of queues that the ticket can be moved
    my %QueueList;       
	if (  $Param{TicketID} ) {
        %QueueList = $Kernel::OM->Get('Kernel::System::Ticket')->TicketMoveList(
            TicketID => $Param{TicketID},
            UserID   => $Param{UserID},
            Action   => 'AgentTicketZoom',
            Type     => 'move_into',
        );    
    }
    return \%QueueList;
}

sub GetQueueList2 {
    my ( $Self, %Param ) = @_; 

    # get the list of queues that the ticket can be moved
    my %QueueList;     

    %QueueList = $Kernel::OM->Get('Kernel::System::Ticket')->TicketMoveList(
        %Param
    );    

    return \%QueueList;
}

=head2 GetResponsibleList()
   
    my $Responsibles = $EasyCategorizationObject->GetResponsibleList(
        %GetParam,
        TicketID => $Self->{TicketID},
        UserID   => $Self->{UserID},
    );

=cut

sub GetResponsibleList {
    my ( $Self, %Param ) = @_;

    my %PermissionList;

    if ( $Param{TicketID} ) {
        my %UserList = $Kernel::OM->Get('Kernel::System::User')->UserList(
            Type  => 'Agent',
            Valid => 1,
        );

        foreach my $UserID ( keys %UserList ) {
            my $Access = $Kernel::OM->Get('Kernel::System::Ticket')->TicketPermission(
                Type     => 'responsible',
                TicketID => $Param{TicketID},
                UserID   => $UserID,
            );

            if ($Access) {
                $PermissionList{$UserID} = $UserList{$UserID};
            }
        }
    }

    return \%PermissionList;
}

1;
