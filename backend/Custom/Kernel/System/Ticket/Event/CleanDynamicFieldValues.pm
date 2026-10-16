# --
# Kernel/System/Ticket/Event/CleanDynamicFieldValues.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@beonup.com.br
# --

package Kernel::System::Ticket::Event::CleanDynamicFieldValues;

use strict;
use warnings;
use utf8;


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
    my $ConfigObject            = $Kernel::OM->Get('Kernel::Config');
    my $CustomFormObject        = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $ParamObject             = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TicketObject            = $Kernel::OM->Get('Kernel::System::Ticket');
    my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $EnableCustomServiceFormEdition = $ConfigObject->Get("CustomServiceForm::Core::ToEnableEdition");

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

    return if (!$EnableCustomServiceFormEdition);


    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );

    my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
        TicketID      => $TicketID,
        UserID        => $Self->{UserID},
        DynamicFields => 1,
    );

    # get params
	my $ServiceID = $ParamObject->GetParam( Param => 'ServiceID' );

    return if (!$ServiceID);

    # Get all forms
    my %List = $CustomFormObject->CustomFormList(
        Valid => 1,
    );

    return if (!%List);

    for my $ServiceFormID (keys %List){

        # Get dynamic fields of service form
        my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
            FormID  => $ServiceFormID,
            UserID  => 1,
        );

        for my $Field (@{$Fields}){

            my @Words = split /DynamicField_/, $Field->{Name};

            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => $Words[1],
            );

            # Clean dynamic fields of service form if service is change
            my $Success = $BackendObject->ValueDelete(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $TicketID,
                UserID             => 1,
            );
        }
    }

}

1;
