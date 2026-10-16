# --
# Kernel/System/Ticket/acl/ServiceRelation.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::System::Ticket::Acl::ServiceRelation;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::LinkObject',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;
	
	my $QueueAndServicesObject = $Kernel::OM->Get('Kernel::System::QueueAndServices');
	my $TypeAndServicesObject  = $Kernel::OM->Get('Kernel::System::TypeAndServices');
	my $ServiceObject          = $Kernel::OM->Get('Kernel::System::Service');
	my $ConfigObject 		   = $Kernel::OM->Get('Kernel::Config');
	
    # check needed stuff
    for (qw(Config Acl)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }
	
	my $PickServiceRelation = $ConfigObject->Get('PickServiceRelation');
	my $PickUserType        = $ConfigObject->Get('PickUserType');

	return if ( $PickUserType eq "Agent" && (
					$Param{Action} eq 'CustomerTicketMessage' ||
					$Param{Action} eq 'Services' ||
					$Param{Action} eq 'NewTicketService'
				)
			  );	
	return if ( $PickUserType eq "Customer" && $Param{Action} ne 'CustomerTicketMessage' ); 
	
	if ($PickServiceRelation eq "QueueAndService"){
	
		# check if child tickets are not closed
		return 1 if !$Param{QueueID};
	
		my @Services = $QueueAndServicesObject->QueueAndServicesList(
			QueueID => $Param{QueueID},
			UserID  => 1,
		);
		
		my @ServiceList;
		
		for my $ServiceID (@Services){
		
			my %ServiceData = $ServiceObject->ServiceGet(
				ServiceID => $ServiceID,
				UserID    => 1,
			);

			push @ServiceList, $ServiceData{Name};
		};
		
		$Param{Acl}->{QueueAndService} = {
	
			# match properties
			Properties => {
	
				# current ticket match properties
				Queue => {
					QueueID => [ $Param{QueueID} ],
				},
			},
	
			# return possible options (black list)
			Possible => {
	
				# possible ticket options (black list)
				Ticket => {
					Service => \@ServiceList,
					
				},
			},
		};
	} 
	else{

		my $TypeObject = $Kernel::OM->Get('Kernel::System::Type');

		if ( $Param{Type} ) {

			my %TypeList = reverse $TypeObject->TypeList();

			# check if type is in the type list
            if ( $TypeList{ $Param{Type} } ) {

                my %Type = $TypeObject->TypeGet(
                    Name   => $Param{Type},
                    UserID => 1,
                );

				$Param{TypeID} = $Type{ID};
			}
			else {
				return 1;
			}
		}
		elsif (!$Param{TypeID}) {
			return 1;
		}

		my @Services = $TypeAndServicesObject->TypeAndServicesList(
			TypeID => $Param{TypeID},
			UserID => 1,
		);
		
		my @ServiceList;
		
		for my $ServiceID (@Services){
		
			my %ServiceData = $ServiceObject->ServiceGet(
				ServiceID => $ServiceID,
				UserID    => 1,
			);

			push @ServiceList, $ServiceData{Name};
		};

		$Param{Acl}->{TypeAndService} = {

			# match properties
			Properties => {

				# current ticket match properties
				Type => {
					ID => [ $Param{TypeID} ],
				},
			},

			# return possible options (black list)
			Possible => {

				# possible ticket options (black list)
				Ticket => {
					Service => \@ServiceList,
					
				},
			},
		};
	}

    return 1;
}

1;
