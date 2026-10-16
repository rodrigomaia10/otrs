# --
# Kernel/System/GenericAgent/SavesPath/SavesPath.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * jguedes@serviceup.com.br
# --

package Kernel::System::GenericAgent::SavesPath::SavesPath;

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

    my $CoreFunction = $Self->_CoreFunciton(
        TicketID     => $Param{TicketID},
        DynamicField => $Param{New}->{DynamicField},
        Level        => $Param{New}->{Level},
        Value        => $Param{New}->{Value},
    );

}

sub _CoreFunciton {
    my ( $Self, %Param ) = @_;

    my $TicketObject        = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    
    my $DFName = $Param{DynamicField};
    my $Level  = $Param{Level};

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
    );

    my @Levels = split(/::/, $Ticket{$Param{Value}});

    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $DFName,
    );

    my $StringPath;
    my @StorePath;
    my $Count = 0;

    for my $IndexLevel (@Levels){

        if ($Count >= $Level && $Level != -1){
    
            push(@StorePath, $IndexLevel);
        }
        $Count++;
    }

    $StringPath =  join('::', @StorePath);

    if ($Level eq '-1'){
        
        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicField,
            ObjectID           => $Param{TicketID},
            Value              => $Levels[$Level],
            UserID             => 1,
        );

    }
    else{

        my $Success = $BackendObject->ValueSet(
            DynamicFieldConfig => $DynamicField,
            ObjectID           => $Param{TicketID},
            Value              => $StringPath,
            UserID             => 1,
        );

    }
    
    return 1;
}
1;