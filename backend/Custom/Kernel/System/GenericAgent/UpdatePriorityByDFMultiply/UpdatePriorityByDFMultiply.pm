# --
# Custom/Kernel/System/GenericAgent/UpdatePriorityByDFMultiply/UpdatePriorityByDFMultiply.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::System::GenericAgent::UpdatePriorityByDFMultiply::UpdatePriorityByDFMultiply;

use strict;
use warnings;

use utf8;

our @ObjectDependencies = (
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
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        DynamicFields => 1,    
        UserID        => 1
    );

    my $DynamicFieldsNamesToMult = $ConfigObject->Get('CustomModuleGenericAgent::UpdatePriorityByDFMultiply::DynamicFieldsToMultiply');

    my $TotalValue = 0;

    for my $DynamicFieldName ( @{ $DynamicFieldsNamesToMult } ){

        if ( $Ticket{'DynamicField_' . $DynamicFieldName} ){
            if ( $TotalValue == 0 ){
                $TotalValue = $Ticket{'DynamicField_' . $DynamicFieldName};
            }else{
                $TotalValue = $TotalValue * $Ticket{'DynamicField_' . $DynamicFieldName};
            }

        }

    }

    my $PriorityAnsLimits = $ConfigObject->Get('CustomModuleGenericAgent::UpdatePriorityByDFMultiply::PriorityAndTotalValue');

    my $PriorityToSet = '';

    if( $TotalValue ){
        for my $PriorityName ( sort { $PriorityAnsLimits->{$a} <=> $PriorityAnsLimits->{$b} } keys %{ $PriorityAnsLimits } ) {    

            if ( !$PriorityToSet && $TotalValue <= $PriorityAnsLimits->{$PriorityName} ){
                $PriorityToSet = $PriorityName;
            }

        }

        if ( $PriorityToSet ){
            my $SuccessSetPriority = $TicketObject->TicketPrioritySet(
                TicketID => $Param{TicketID},
                Priority => $PriorityToSet,
                UserID   => 1,
            );

            if( $SuccessSetPriority ){
                my $HistoryAdd = $TicketObject->HistoryAdd(
                    Name => $LayoutObject->{LanguageObject}->Translate(
                                    'Priority update from "%s" to "%s" (InBox CustomModuleGenericAgent)',
                                    $Ticket{Priority}, $PriorityToSet),
                    HistoryType  => 'AddNote', 
                    TicketID     => $Param{TicketID},
                    CreateUserID => 1,
                );
            }
        
        } 
    }

    return 1;
    
}

1;