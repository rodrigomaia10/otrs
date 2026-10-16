# --
# Kernel/System/Ticket/Acl/RelationContractService.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * jguedes@serviceup.com.br
# --

package Kernel::System::Ticket::Acl::RelationServiceContract;

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

	my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');
	my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $QueueObject   = $Kernel::OM->Get('Kernel::System::Queue');
    my $SLAObject     = $Kernel::OM->Get('Kernel::System::SLA');
    my $TypeObject    = $Kernel::OM->Get('Kernel::System::Type');
    my $ContractObject     = $Kernel::OM->Get('Kernel::System::ContractManagement');
    my $ContractAndServicesObject  = $Kernel::OM->Get('Kernel::System::ContractAndServices');

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

    my %List = $ContractObject->ContractCompany(
        CustomerID => $Param{Checks}->{CustomerUser}->{CustomerID}, # required
        Valid      => 1,
    );
    
    my @Service;
    my @ServiceList;
    
    for my $Contracts (keys %List ){
        
        my @ServiceTemp = $ContractAndServicesObject->ContractAndServicesList(
            ContractID   => $Contracts,
            UserID    => 1,
        );

        push @Service, @ServiceTemp;
    }

    for my $IDs (@Service){

        my %ServiceData = $ServiceObject->ServiceGet(
            ServiceID => $IDs,
            UserID    => 1,
        );  

        push @ServiceList, $ServiceData{Name};
    }

    if (@ServiceList){
        $Param{Acl}->{'000RelationServiceContract'} = {
            Properties => {
                # current ticket match properties
                Frontend => {
                    Action => ['Services'],
                },
            },
            Possible => {
                Ticket  => {
                    Service => \@ServiceList,
                },
            },
        };

    }

    return 1;
}

1;