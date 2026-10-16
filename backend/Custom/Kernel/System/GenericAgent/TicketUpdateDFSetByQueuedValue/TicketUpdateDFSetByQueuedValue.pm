# --
# Kernel/System/GenericAgent/TicketUpdateDFSetByQueuedValue/TicketUpdateDFSetByQueuedValue.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * nfreitas@serviceup.com.br
# --

package Kernel::System::GenericAgent::TicketUpdateDFSetByQueuedValue::TicketUpdateDFSetByQueuedValue;

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

    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $QueueObject               = $Kernel::OM->Get('Kernel::System::Queue');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $CheckType = $Param{New}->{CheckType};

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        DynamicFields => 1,
    );

    my @ArrayQueueNames = split /,/, $Ticket{"DynamicField_$Param{New}->{DFToQueueName}"};
    my @ArrayQueueIDs   = split /,/, $Ticket{"DynamicField_$Param{New}->{DFToQueueID}"};

    if ( $CheckType eq 'SaveQueue' ) {

        if (! grep { $_ eq $Ticket{Queue} } @ArrayQueueNames ) {
            push @ArrayQueueNames, $Ticket{Queue};

            my $FieldName = $Param{New}->{DFToQueueName};

            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => $FieldName,
            );
            
            my $Success = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $Param{TicketID},
                Value              => join(',', @ArrayQueueNames),
                UserID             => 1,
            );
        } 

        if (! grep { $_ eq $Ticket{QueueID} } @ArrayQueueIDs ) {

            push @ArrayQueueIDs, $Ticket{QueueID};

            my $FieldNameID = $Param{New}->{DFToQueueID};

            my $DynamicFieldConfigIDs = $DynamicFieldObject->DynamicFieldGet(
                Name => $FieldNameID,
            );

            my $SuccessIDs = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfigIDs,
                ObjectID           => $Param{TicketID},
                Value              => join(',', @ArrayQueueIDs),
                UserID             => 1,
            );
        }
    }
    elsif ( $CheckType eq 'CheckQueue' ) {

        my $FieldNameIdentify = $Param{New}->{DFToIdentify};

        my $DynamicFieldConfigIdentify = $DynamicFieldObject->DynamicFieldGet(
            Name => $FieldNameIdentify,
        );

        if (! grep { $_ eq $Ticket{QueueID} } @ArrayQueueIDs ) {

            my $SuccessIdentify = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfigIdentify,
                ObjectID           => $Param{TicketID},
                Value              => $Param{New}->{ValueIdentifyNewQueue},
                UserID             => 1,
            );
        }
        elsif ( grep { $_ eq $Ticket{QueueID} } @ArrayQueueIDs ) {
            my $SuccessNotIdentify = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfigIdentify,
                ObjectID           => $Param{TicketID},
                Value              => $Param{New}->{ValueIdentifyRepeatedQueue},
                UserID             => 1,
            );
        }
    }
    
    return 1;
}
