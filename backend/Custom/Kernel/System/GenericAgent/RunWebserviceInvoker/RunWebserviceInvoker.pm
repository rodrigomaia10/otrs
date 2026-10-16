# --
# Kernel/System/GenericAgent/RunWebserviceInvoker/RunWebserviceInvoker.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::RunWebserviceInvoker::RunWebserviceInvoker;

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

    my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $TicketInvokerObject = $Kernel::OM->Get('Kernel::System::TicketInvoker');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    
    my %Data;
    $Data{TicketID} = $Param{TicketID};

    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DynamicField},
    );

    my $Value = $BackendObject->ValueGet(
        DynamicFieldConfig => $DynamicField,
        ObjectID           => $Param{TicketID},                                                       
    );

    if ( $Value ) {

        my $Result = $TicketInvokerObject->WebServiceRequest(
           Webservice  => $Param{New}->{Webservice},
           Invoker     => $Param{New}->{Invoker},
           Data        => \%Data,
           UserID      => 1,
        );

    }
}

1;