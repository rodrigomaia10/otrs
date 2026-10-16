# --
# Kernel/System/TicketTitleUpdate/TicketTitleUpdate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * jsantos@serviceup.com.br
# --

package Kernel::System::GenericAgent::TicketTitleUpdate::TicketTitleUpdate;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
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
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        DynamicFields => 1,
    );

    my $NewTitle = $Self->_ReplaceTicketAttributes(
        Ticket  => \%Ticket,
        Message => $Param{New}->{NewTitle},
    );

    my $Success = $TicketObject->TicketTitleUpdate(
        Title    => $NewTitle || $Ticket{Title},
        TicketID => $Param{TicketID},
        UserID   => 1,
    );

    return 1;
}

sub _ReplaceTicketAttributes {
    my ( $Self, %Param ) = @_;

    return if !$Param{Message};

    # get needed objects
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');

    # replace ticket attributes such as <OTRS_Ticket_DynamicField_Name1> or
    # <OTRS_TICKET_DynamicField_Name1>
    # <OTRS_Ticket_*> is deprecated and should be removed in further versions of OTRS
    my $Count = 0;
    
    REPLACEMENT:
    while (
        $Param{Message}
        && $Param{Message} =~ m{<OTRS_TICKET_([A-Za-z0-9_]+)>}msxi
        && $Count++ < 1000
        )
    {
        my $TicketAttribute = $1;

        if ( $TicketAttribute =~ m{DynamicField_(\S+?)_Value} ) {

            my $DynamicFieldName = $1;

            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => $DynamicFieldName,
            );

            next REPLACEMENT if !$DynamicFieldConfig;

            # get the display value for each dynamic field
            my $DisplayValue = $DynamicFieldBackendObject->ValueLookup(
                DynamicFieldConfig => $DynamicFieldConfig,
                Key                => $Param{Ticket}->{"DynamicField_$DynamicFieldName"},
            );

            my $DisplayValueStrg = $DynamicFieldBackendObject->ReadableValueRender(
                DynamicFieldConfig => $DynamicFieldConfig,
                Value              => $DisplayValue,
            );

            $Param{Message} =~ s{<OTRS_TICKET_$TicketAttribute>}{$DisplayValueStrg->{Value} // ''}ige;

            next REPLACEMENT;
        }

        # if ticket value is scalar substitute all instances (as strings)
        # this will allow replacements for "<OTRS_TICKET_Title> <OTRS_TICKET_Queue"
        if ( !ref $Param{Ticket}->{$TicketAttribute} ) {
            $Param{Message} =~ s{<OTRS_TICKET_$TicketAttribute>}{$Param{Ticket}->{$TicketAttribute} // ''}ige;
        }
        else {
            # if the value is an array (e.g. a multiselect dynamic field) set the value directly
            # this unfortunately will not let a combination of values to be replaced
            $Param{Message} = $Param{Ticket}->{$TicketAttribute};
        }
    }

    return $Param{Message};
}

1;