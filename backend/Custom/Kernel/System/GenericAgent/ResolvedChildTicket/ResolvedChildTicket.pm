# --
# /opt/Dev/CustomModuleGenericAgent/src/Custom/Kernel/System/GenericAgent/ResolvedChildTicket/ResolvedTicketChild.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * ccresencio@serviceup.com.br
# --

package Kernel::System::GenericAgent::ResolvedChildTicket::ResolvedChildTicket;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {

    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

}

sub Run {

    my ( $Self, %Param ) = @_;

    my $TicketObject            = $Kernel::OM->Get('Kernel::System::Ticket');
    my $StateObject             = $Kernel::OM->Get('Kernel::System::State');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject           = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    if($Param{New}->{DynamicFieldFather}){
        
        my %Ticket = $TicketObject->TicketGet(
            TicketID => $Param{TicketID},
            DynamicFields => 1,
            Extended => 1,
        );

        #Get TicketID from ticket father
        my $TicketIDFather = $TicketObject->TicketIDLookup(
            TicketNumber => $Ticket{"DynamicField_$Param{New}->{DynamicFieldFather}"},
        );

        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $Param{New}->{DynamicField},
        );

        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $TicketIDFather,
            Value              => $Param{New}->{DynamicFieldValue},
            UserID             => 1,
        );
    }
        
    

}

1;