# --
# Kernel/System/Ticket/Event/TicketSetServicesPreferences.pm
# Copyright (C) 2019-2022 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::System::Ticket::Event::TicketSetServicesPreferences;

use strict;
use warnings;
use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get object
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $MacroObject   = $Kernel::OM->Get('Kernel::System::Macro');
    my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $YAMLObject    = $Kernel::OM->Get('Kernel::System::YAML');
     
    # check needed stuff
    for (qw(Data Event Config)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    for (qw(TicketID)) {
        if ( !$Param{Data}->{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_ in Data!"
            );
            return;
        }
    }

    my $Data = $Param{Data};

    return 1 if !$Data->{TicketID};        

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Data->{TicketID},
        DynamicFields => 1,
    );

    return 1 if !$Ticket{ServiceID};

    my %ServiceData = $ServiceObject->ServiceGet(
        ServiceID => $Ticket{ServiceID},
        UserID    => 1
    );

    if ( $Param{Config}->{ServiceTicketPriority} == 1 && $ServiceData{ServiceTicketPriority} ) {

        my $Success = $TicketObject->TicketPrioritySet(
            TicketID => $Data->{TicketID},
            Priority => $ServiceData{ServiceTicketPriority},
            UserID   => 1,
        );
    }

    if ( $Param{Config}->{ServiceTicketOwner} == 1 && $ServiceData{ServiceTicketOwner} ) {

        my $Success = $TicketObject->TicketOwnerSet(
            TicketID  => $Data->{TicketID},
            NewUserID => $ServiceData{ServiceTicketOwner},
            UserID    => 1,
        );
    }

    if ( $Param{Config}->{ServiceTicketQueue} == 1 && $ServiceData{ServiceTicketQueue} ) {

        my $Success = $TicketObject->TicketQueueSet(
            Queue    => $ServiceData{ServiceTicketQueue},
            TicketID => $Data->{TicketID},
            UserID   => 1,
        );
    }

    if ( $Param{Config}->{ServiceTicketType} == 1 && $ServiceData{ServiceTicketType} ) {

        my $Success = $TicketObject->TicketTypeSet(
            Type     => $ServiceData{ServiceTicketType},
            TicketID => $Data->{TicketID},
            UserID   => 1,
        );
    }
    
    if ( $Param{Config}->{ServiceTicketResponsible} == 1 && $ServiceData{ServiceTicketResponsible} ) {

        my $Success = $TicketObject->TicketResponsibleSet(
            TicketID  => $Data->{TicketID},
            NewUserID => $ServiceData{ServiceTicketResponsible},
            UserID    => 1,
        );
    }

    if ( $Param{Config}->{ServiceTicketSLA} == 1 && $ServiceData{ServiceTicketSLA} ) {

        my $Success = $TicketObject->TicketSLASet(
            SLA      => $ServiceData{ServiceTicketSLA},
            TicketID => $Data->{TicketID},
            UserID   => 1,
        );
    }

    if ( $Param{Config}->{ServiceTicketDynamicFields} == 1 ) {

        my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
        my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
        my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');

        for ( my $i = 1; $i <= 40; $i++ ) {

            my $ConfigNumber = $i;

            if ( $i < 10 ) {
                $ConfigNumber = "0".$i;
            }

            my $ServiceDynamicField = "ServiceDynamicField".$ConfigNumber;
        
            if ( $ServiceData{ $ServiceDynamicField } ) {

                my $PrefConfigDFName = $ConfigObject->Get('ServicePreferences')->{$ServiceDynamicField}{DFName};

                my $SelectedDynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $PrefConfigDFName,
                );

                my $ValueToSet = $ServiceData{ $ServiceDynamicField };
                
                if($SelectedDynamicField->{FieldType} eq 'Multiselect'){

                    my @ValuesMulti = split /;/, $ServiceData{ $ServiceDynamicField };

                    $ValueToSet = \@ValuesMulti;
                }
                elsif($SelectedDynamicField->{FieldType} eq 'Date'){

                    my @ValuesDate = split /;/, $ServiceData{ $ServiceDynamicField };

                    if($ValuesDate[2] < 10){
                        $ValuesDate[2] = "0$ValuesDate[2]";
                    }

                    if($ValuesDate[1] < 10){
                        $ValuesDate[1] = "0$ValuesDate[1]";
                    }

                    $ValueToSet = "$ValuesDate[3]-$ValuesDate[2]-$ValuesDate[1] 00:00:00";
                }
                elsif($SelectedDynamicField->{FieldType} eq 'DateTime'){

                    my @ValuesDateTime = split /;/, $ServiceData{ $ServiceDynamicField };

                    if($ValuesDateTime[2] < 10){
                        $ValuesDateTime[2] = "0$ValuesDateTime[2]";
                    }

                    if($ValuesDateTime[1] < 10){
                        $ValuesDateTime[1] = "0$ValuesDateTime[1]";
                    }

                    if($ValuesDateTime[4] < 10){
                        $ValuesDateTime[4] = "0$ValuesDateTime[4]";
                    }

                    if($ValuesDateTime[5] < 10){
                        $ValuesDateTime[5] = "0$ValuesDateTime[5]";
                    }

                    $ValueToSet = "$ValuesDateTime[3]-$ValuesDateTime[2]-$ValuesDateTime[1] $ValuesDateTime[4]:$ValuesDateTime[5]:00";
                }

                # set the value to service dynamic field
                my $Success = $BackendObject->ValueSet(
                    DynamicFieldConfig => $SelectedDynamicField,
                    ObjectID           => $Data->{TicketID},
                    Value              => $ValueToSet,
                    UserID             => 1,
                );
            }
        }
    }

    return 1;
}

1;