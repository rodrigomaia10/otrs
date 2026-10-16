# --
# /opt/Dev/CustomModuleGenericAgent/src/Custom/Kernel/System/GenericAgent/TicketInitialValueGet/TicketInitialValueGet.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::TicketInitialValueGet::TicketInitialValueGet;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::DateTime',
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

    my $UserObject = $Kernel::OM->Get('Kernel::System::User');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    
    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,  
        UserID        => 1,
    );

    # associate task with a ticket
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{FieldName},
    );

    #Empty field validation
    return 1 if !$DynamicField;

    # Get value defined in generic agent 
    my $Value = $Param{New}->{TicketGetValue};

    my %UserData;
    if ( $Value eq 'CreateBy' ) {

        # search by user data
        %UserData = $UserObject->GetUserData(
            UserID => $Ticket{$Value},
        );
    }

    my $Success = $DynamicFieldValueObject->ValueSet(
        FieldID  => $DynamicField->{ID},                 
        ObjectID => $Param{TicketID},                                                        
        Value    => [
            {
                ValueText => $Value eq 'CreateBy' ? $UserData{$Param{New}->{UserData}} : $Ticket{$Value},
            },
        ],
        UserID   => 1,
    );
   
    if($Success){

        my $HistoryAdd = $TicketObject->HistoryAdd(
            Name         => "Atualização de valor do campo dinâmico '$DynamicField->{Name}' para '$Ticket{$Param{New}->{TicketGetValue}}' (InBox CustomModuleGenericAgent)",
            HistoryType  => 'AddNote', 
            TicketID     => $Param{TicketID},
            CreateUserID => 1,
        );
    }
   
    return $Success;
}

1;