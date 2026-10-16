# --
# Kernel/System/TicketParamUpdate/TicketParamUpdate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::TicketParamUpdate::TicketParamUpdate;

use strict;
use warnings;
use utf8;
use Kernel::System::VariableCheck qw(IsHashRefWithData IsArrayRefWithData IsStringWithData);

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
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $SLAObject                 = $Kernel::OM->Get('Kernel::System::SLA');
    my $TypeObject                = $Kernel::OM->Get('Kernel::System::Type');
    my $QueueObject               = $Kernel::OM->Get('Kernel::System::Queue');
    my $StateObject               = $Kernel::OM->Get('Kernel::System::State');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ServiceObject             = $Kernel::OM->Get('Kernel::System::Service');
    my $PriorityObject            = $Kernel::OM->Get('Kernel::System::Priority');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject             = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # get config
    my $ConfigTicketParamUpdate = $ConfigObject->Get('CustomModuleGenericAgent::TicketParamUpdate::TicketParamUpdate');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        DynamicFields => 1,
    );

    if ( $ConfigTicketParamUpdate ) {
       
        KEY:
        # scrolls through the match setting
        for my $KeyConfigTicketParamUpdate ( keys %{$ConfigTicketParamUpdate} ) {
            
            for my $MatchParam ( keys %{$ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Match}} ) {

                if ( IsArrayRefWithData($Ticket{$MatchParam}) ) {
                    $Ticket{$MatchParam} = @{$Ticket{$MatchParam}}[0]
                }

                 # validates whether the ticket parameters match the configuration
                if ( $Ticket{$MatchParam} ne $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Match}->{$MatchParam} ) {

                    next KEY;
                }
            }

            PARAM:
            # scrolls through the change setting
            for my $ChangeParam ( keys %{$ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}} ) {

                # defines the change in the selected parameter.
                if ( $ChangeParam eq 'SLA' ) {

                    my $SLAID = $SLAObject->SLALookup(
                        Name => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{SLA},
                    );

                    next PARAM if !( $SLAID );

                    $TicketObject->TicketSLASet(
                        TicketID => $Param{TicketID},
                        UserID   => 1,
                        SLA      => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{SLA},
                    );
                }
                elsif ( $ChangeParam eq 'Service' ) {

                    my $ServiceID = $ServiceObject->ServiceLookup(
                        Name => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{Service},
                    );

                    next PARAM if !( $ServiceID );

                    $TicketObject->TicketServiceSet(
                        TicketID  => $Param{TicketID},
                        UserID    => 1,
                        Service   => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{Service},
                    );
                }
                elsif ( $ChangeParam eq 'Type' ) {

                    my $TypeID = $TypeObject->TypeLookup( 
                        Type => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{Type}
                    );

                    next PARAM if !( $TypeID );

                    $TicketObject->TicketTypeSet(
                        TicketID  => $Param{TicketID},
                        UserID    => 1,
                        Type      => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{Type},
                    );
                }
                elsif ( $ChangeParam eq 'Priority' ) {

                    my $PriorityID = $PriorityObject->PriorityLookup(
                        Priority => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{Priority},
                    );

                    next PARAM if !( $PriorityID );

                    $TicketObject->TicketPrioritySet(
                        TicketID => $Param{TicketID},
                        UserID   => 1,
                        Priority => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{Priority},
                    );
                }
                elsif ( $ChangeParam eq 'Queue' ) {

                    my $QueueID = $QueueObject->QueueLookup( 
                        Queue => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{Queue} 
                    );

                    next PARAM if !( $QueueID );

                    $TicketObject->TicketQueueSet(
                        TicketID => $Param{TicketID},
                        UserID   => 1,
                        Queue    => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{Queue},
                    );
                }
                elsif ( $ChangeParam eq 'State' ) {

                    my $StateID = $StateObject->StateLookup(
                        State => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{State},
                    );

                    next PARAM if !( $StateID );

                    $TicketObject->TicketStateSet(
                        TicketID => $Param{TicketID},
                        UserID   => 1,
                        State    => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{State},
                    );
                }
                elsif ( $ChangeParam =~ m/DynamicField_/ ) {
                    
                    my ($DF, $Name)= split /DynamicField_/, $ChangeParam;

                    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                        Name => $Name
                    );

                    my $Success = $BackendObject->FieldValueValidate (
                        DynamicFieldConfig => $DynamicField,
                        Value              => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{$ChangeParam},
                        UserID             => 1,
                    );

                    next PARAM if !( $Success );
                    next PARAM if !( $DynamicField );

                    my $Success = $BackendObject->ValueSet(
                        DynamicFieldConfig => $DynamicField,
                        ObjectID           => $Param{TicketID},
                        Value              => $ConfigTicketParamUpdate->{$KeyConfigTicketParamUpdate}->{Change}->{$ChangeParam},
                        UserID             => 1,
                    );
                }
            }
        }
    }

    return 1;
}

1;