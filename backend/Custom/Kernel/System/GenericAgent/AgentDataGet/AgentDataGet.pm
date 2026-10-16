# --
# Kernel/System/GenericAgent/AgentDataGet.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * mbernardo@serviceup.com.br
# --

package Kernel::System::GenericAgent::AgentDataGet::AgentDataGet;

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

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    # get customer user data, so that values can be stored in dynamic fields
    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
        DynamicFields => 1,
    );

    return if !%Ticket;
    return if defined $Ticket{$Param{New}->{DynamicFieldFlag}};

    # get dynamic field objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $FieldName = $Param{New}->{DynamicField};
    my $UserVariableName = $Param{New}->{UserVariableName};

    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => $FieldName,
    );

    my %UserData = $UserObject->GetUserData(
        UserID => $Ticket{OwnerID},
    );

    # update dynamic field value for ticket
    my $Success = $DynamicFieldBackendObject->ValueSet(
        DynamicFieldConfig => $DynamicFieldConfig,
        ObjectID           => $Param{TicketID},
        Value              => $UserData{$UserVariableName} || '',
        UserID             => 1,
    );

    if( $Success ) {

        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $Param{New}->{DynamicFieldFlag},
        );

        $DynamicFieldBackendObject->ValueSet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $Param{TicketID},
            Value              => 1,
            UserID             => 1,
        );

    }

    return 1;
}

1;
