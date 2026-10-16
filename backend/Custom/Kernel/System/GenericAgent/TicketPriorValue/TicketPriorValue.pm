# --
# Custom/Kernel/System/GenericAgent/TicketPriorValue/TicketPriorValue.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * mbernardo@serviceup.com.br
# --

package Kernel::System::GenericAgent::TicketPriorValue::TicketPriorValue;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::Ticket'
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

    # get objects
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LibraryObject             = $Kernel::OM->Get('Kernel::System::InBoxLibrary');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # get previous value
    my @PreviousValue = $LibraryObject->PreviousEvent(
        TicketID   => $Param{TicketID},  
        Event      => $Param{New}->{Event}
    );

    my $PreviousEvent = $PreviousValue[ $#PreviousValue ];

    my $UpdateString = $PreviousEvent->{Name};
    my @Position = split('%%', $UpdateString);

    # Get position previous value
    my $ID = $Position[ $#Position ];

    if ( $Param{New}->{Parameter} eq 'Priority' ) {
        $ID = $Position[ 2 ];
    }

    my $Value;
    if( $Param{New}->{Parameter} eq 'Priority' ) {

        my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');
    
        my $Priority = $PriorityObject->PriorityLookup(
            PriorityID => $ID,
        );

        $Value = $Priority;
    }
    elsif( $Param{New}->{Parameter} eq 'Queue' ) {

        my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

        my $Queue = $QueueObject->QueueLookup( 
            QueueID => $ID
        );

        $Value = $Queue;
    }

    # get value dynamic field
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DynamicField}
    );

    if ( $DynamicField->{Name} ) {

        # return previous value - userfullname
        my $Success = $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicField,                
            ObjectID           => $Param{TicketID},  
            Value              => $Value,                                
            UserID             => 1
        );
    }
}

1;