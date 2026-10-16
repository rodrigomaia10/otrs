# --
# Custom/Kernel/System/GenericAgent/GetDateEvent/GetDateEvent.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# --

package Kernel::System::GenericAgent::GetDateEvent::GetDateEvent;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
'Kernel::System::DateTime',
'Kernel::System::Log',
'Kernel::System::Priority',
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

    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    #Get the queue change date
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

    #Convert date to a string
    my $DateTimeString = $DateTimeObject->ToString();
    
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{FieldName},
    );

    #Empty field validation
    return 1 if !$DynamicField;

    #DateTime field validation
    return 1 if $DynamicField->{FieldType} ne "DateTime";

    my $Success = $DynamicFieldValueObject->ValueSet(
        FieldID  => $DynamicField->{ID},                 
        ObjectID => $Param{TicketID},                                                        
        Value    => [
            {
                ValueDateTime => $DateTimeString, 
            },
        ],
        UserID   => 1,
    );
   
    if($Success){

        my $HistoryAdd = $TicketObject->HistoryAdd(
            Name         => "Atualização de valor do campo dinâmico '$DynamicField->{Name}' para '$DateTimeString' (InBox CustomModuleGenericAgent)",
            HistoryType  => 'AddNote', 
            TicketID     => $Param{TicketID},
            CreateUserID => 1,
        );
    }
   
    return $Success;
}

1;