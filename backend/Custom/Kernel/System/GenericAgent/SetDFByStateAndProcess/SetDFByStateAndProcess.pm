# --
# Kernel/System/GenericAgent/SetDFByStateAndProcess.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * nfreitas@serviceup.com.br
# --

package Kernel::System::GenericAgent::SetDFByStateAndProcess::SetDFByStateAndProcess;

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
      
    my $StateID = $StateObject->StateLookup(
        State => $Param{New}->{StateCurrent},
    );
    
    # Checks whether the current state is the current state of the generic attendant
    if($Ticket{StateID} eq $StateID){ 

        my @HistoryLines = $TicketObject->HistoryGet(
            TicketID => $Param{TicketID},
            UserID   => 1,
        );
        
        my @NamesStates;
        my $CreateTime;

        HISTORY:
        for my $History ( reverse @HistoryLines){

            next HISTORY if(
                $History->{HistoryType} ne 'StateUpdate' 
            );

            @NamesStates = split('%%', $History->{Name}); 
            $CreateTime = $History->{CreateTime};

            last;
        }

        # Checks whether the previous state of the call is the same as the previous one of the generic attendant
        if($NamesStates[1] eq $Param{New}->{StateOld}){
            my $FieldName = $Param{New}->{DynamicField};

            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => $FieldName,
            );

            my $Success = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $Param{TicketID},
                Value              => $CreateTime,
                UserID             => 1,
            );
        }

    }

    return 1;
}

1;