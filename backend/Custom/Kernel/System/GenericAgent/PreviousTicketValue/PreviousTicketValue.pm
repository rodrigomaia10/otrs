# --
# Custom/Kernel/System/GenericAgent/PreviousTicketValue/PreviousTicketValue.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# * dsilva@serviceup.com.br
# --

package Kernel::System::GenericAgent::PreviousTicketValue::PreviousTicketValue;

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

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1
    );
    
    # get list owners
    my @PreviousValue = $LibraryObject->PreviousEvent(
        TicketID => $Param{TicketID},  
        Event    => $Param{New}->{Event} 
    );

    # Return if you are the first owner of the ticket
    return if (scalar @PreviousValue == 1);

    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    my $PreviousEvent = $PreviousValue[ $#PreviousValue - 1 ];

    if ( $Param{New}->{Change} eq 'Queue' ) {

        # get value dynamic field
        my $DynamicFieldChange = $DynamicFieldObject->DynamicFieldGet(
            Name => $Param{New}->{ChangeField}
        );

        my $ValueQueue = $DynamicFieldBackendObject->ValueGet(
            DynamicFieldConfig => $DynamicFieldChange,
            ObjectID           => $Param{TicketID}
        );

        my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

        my $QueueID = $QueueObject->QueueLookup( 
            Queue => $ValueQueue
        );

        if ( $QueueID ne $PreviousEvent->{QueueID}  ) {

            my $NewQueue = $QueueObject->QueueLookup( 
                QueueID => $PreviousEvent->{QueueID}
            );

            my $OK = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldChange,                
                ObjectID           => $Param{TicketID},  
                Value              => $NewQueue,                                
                UserID             => 1
            );
        }
    }

    my $UpdateString = $PreviousEvent->{Name};
    my @Position = split('%%', $UpdateString);

    # Get position previous owner
    my $UserID = $Position[ $#Position ];

    my %User = $UserObject->GetUserData(
        UserID => $UserID,
    );

    # Get value dynamic field
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DynamicField}
    );

    # Get value dynamic field
    my $DynamicField2 = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DynamicField2}
    );

    # return previous value - userfullname
    my $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DynamicField,                
        ObjectID           => $Param{TicketID},  
        Value              => $User{UserFullname},                                
        UserID             => 1
    );

    # return previous value - useremail
    my $Success1 = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DynamicField2,                
        ObjectID           => $Param{TicketID},  
        Value              => $User{UserEmail},                                
        UserID             => 1
    ); 
}

1;