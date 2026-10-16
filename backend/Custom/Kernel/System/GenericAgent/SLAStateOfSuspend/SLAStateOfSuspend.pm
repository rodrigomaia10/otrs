# --
# Kernel/System/GenericAgent/SLAStateOfSuspend.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * nfreitas@serviceup.com.br
# --

package Kernel::System::GenericAgent::SLAStateOfSuspend::SLAStateOfSuspend;

use strict;
use warnings;
use utf8;
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

    # get object
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $UserObject                = $Kernel::OM->Get('Kernel::System::User');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $StateObject               = $Kernel::OM->Get('Kernel::System::State');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
        DynamicFields => 1,
        Extended => 1,
    );
      
    my @SuspendStates      = @{ $Kernel::OM->Get('Kernel::Config')->Get('EscalationSuspendStates') };

    my $FieldName = $Param{New}->{DynamicField};

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => $FieldName,
    );

    # Checks whether the current state is the state of config
    if($Ticket{State} ~~ @SuspendStates){ 
        
        my $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{TicketID},
            Value              => 'SLA pausado',
            UserID             => 1,
        );
    

    }else{
        my $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{TicketID},
            Value              => 'SLA contando',
            UserID             => 1,
        );
    }

    return 1;
}

1;
