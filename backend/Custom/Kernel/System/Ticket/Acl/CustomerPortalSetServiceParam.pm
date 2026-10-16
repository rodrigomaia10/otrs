# --
# Kernel/System/Ticket/Acl/CustomerPortalSetServiceParam.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::System::Ticket::Acl::CustomerPortalSetServiceParam;

use strict;
use warnings;
use utf8;

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

	my $ServiceObject  = $Kernel::OM->Get('Kernel::System::Service');
	my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
    my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');
    my $TypeObject = $Kernel::OM->Get('Kernel::System::Type');

    my $ToEnableServiceParams =  $ConfigObject->Get('CustomerPortal::Core::ToEnableServiceParams');

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

    # config to NOT set services params
    if($ToEnableServiceParams eq '0'){
        return 1;
    }

	# check if child tickets are not closed
	return 1 if !$Param{Checks}->{Service};

    if($Param{Checks}->{Service}->{ServiceTicketQueue}){
       
        my $QueueID = $QueueObject->QueueLookup( Queue => $Param{Checks}->{Service}->{ServiceTicketQueue} );

        if($QueueID){
            $Param{Acl}->{ServiceAndCustomerPortalQueue} = {
                Properties => {
                    # current ticket match properties
                    Frontend => {
                        Action => ['AgentTicketPhone', 'AgentTicketEmail' ],
                    },

                },
                Possible => {
                    Ticket  => {
                        Queue => [$Param{Checks}->{Service}->{ServiceTicketQueue}],
                    },
                },
            };
        }
      
    }

    if($Param{Checks}->{Service}->{ServiceTicketSLA}){

        my $SLAID = $SLAObject->SLALookup(
            Name => $Param{Checks}->{Service}->{ServiceTicketSLA},
        );

        if($SLAID){
            $Param{Acl}->{ServiceAndCustomerPortalSLA} = {
                Properties => {
                    # current ticket match properties
                    Frontend => {
                        Action => ['AgentTicketPhone', 'AgentTicketEmail' ],
                    },
                },
                # return possible options 
                Possible => {
                    # possible ticket options 
                    Ticket => {
                        SLA => [$Param{Checks}->{Service}->{ServiceTicketSLA}],
                    },
                },
            };
        }
        
    }

    if($Param{Checks}->{Service}->{ServiceTicketType}){

        my $TypeID = $TypeObject->TypeLookup( Type => $Param{Checks}->{Service}->{ServiceTicketType} );

        if($TypeID){
            $Param{Acl}->{ServiceAndCustomerPortalType} = {
                Properties => {
                    # current ticket match properties
                    Frontend => {
                        Action => ['AgentTicketPhone', 'AgentTicketEmail' ],
                    },
                },
                # return possible options 
                Possible => {
                    # possible ticket options 
                    Ticket => {
                        Type => [$Param{Checks}->{Service}->{ServiceTicketType}],
                    },
                },
            }; 
        }
       
    }

	

    return 1;
}

1;