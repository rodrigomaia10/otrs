# --
# Custom/Kernel/System/GenericAgent/DFValuesCount/ValuesCountApprovedAndDisapproved.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::System::GenericAgent::DFValuesCount::ValuesCountApprovedAndDisapproved;

use strict;
use warnings;
use Encode;
use URI;
use MIME::Base64;
use utf8;
use parent qw(Kernel::System::Ticket::Article::Backend::Base);

use LWP::UserAgent;
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

    # get objects
    my $TicketObject            = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject            = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject            = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $BackendObject           = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        DynamicFields => 1,
    );

    return if( !exists $Param{New}->{FieldNameToCountApproved} || !exists $Param{New}->{FieldNameToCountDisapproved}
        || !exists $Param{New}->{FieldNameApprovedAndDisapproved} || !exists $Param{New}->{ApprovedKey}
        || !exists $Param{New}->{DisapprovedKey});

    # Get field Approved And Disapproved =  $Param{New}->{FieldNameApprovedAndDisapproved}
    my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{FieldNameApprovedAndDisapproved},
    );

    my $Value = $BackendObject->ValueGet(
       DynamicFieldConfig => $DynamicFieldConfig,
       ObjectID           => $Param{TicketID},
    );

    if($Value eq $Param{New}->{ApprovedKey}){

        my $DynamicFieldConfigCountApproved = $DynamicFieldObject->DynamicFieldGet(
            Name => $Param{New}->{FieldNameToCountApproved},
        );

        my $ValueOfApproved = $BackendObject->ValueGet(
           DynamicFieldConfig => $DynamicFieldConfigCountApproved,
           ObjectID           => $Param{TicketID},
        );

        my $CounterApproved = $ValueOfApproved + 1;

        my $Success = $BackendObject->ValueSet(
           DynamicFieldConfig => $DynamicFieldConfigCountApproved,
           ObjectID           => $Param{TicketID},
           Value              => $CounterApproved,
           UserID             => 1,
        );

    }elsif($Value eq $Param{New}->{DisapprovedKey}){

        my $DynamicFieldConfigCountDisapproved = $DynamicFieldObject->DynamicFieldGet(
            Name => $Param{New}->{FieldNameToCountDisapproved},
        );

        my $ValueOfDisapproved = $BackendObject->ValueGet(
           DynamicFieldConfig => $DynamicFieldConfigCountDisapproved,
           ObjectID           => $Param{TicketID},
        );

        my $CounterDisapproved = $ValueOfDisapproved + 1;

        my $Success = $BackendObject->ValueSet(
           DynamicFieldConfig => $DynamicFieldConfigCountDisapproved,
           ObjectID           => $Param{TicketID},
           Value              => $CounterDisapproved,
           UserID             => 1,
        );

    }

    #Clear approval field
    my $Success = $BackendObject->ValueDelete(
        DynamicFieldConfig => $DynamicFieldConfig,
        ObjectID           => $Param{TicketID},
        UserID             => 1,
    );

    my %NewTicketValues = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        DynamicFields => 1,
    );

    if ( $NewTicketValues{'DynamicField_' . $Param{New}->{FieldNameToCountDisapproved}} ) {
        # get activity object
        my $ProcessObject = $Kernel::OM->Get('Kernel::System::ProcessManagement::Process');

        # Set the new ActivityEntityID on the Ticket
        my $Success = $ProcessObject->ProcessTicketActivitySet(
            ProcessEntityID  => $NewTicketValues{'DynamicField_ProcessManagementProcessID'},
            ActivityEntityID => $NewTicketValues{'DynamicField_ReproveActivity'},
            TicketID         => $Ticket{TicketID},
            UserID           => 1,
        );
    }

    if ( $NewTicketValues{'DynamicField_' . $Param{New}->{FieldToCompare}} && $NewTicketValues{'DynamicField_' . $Param{New}->{FieldNameToCountApproved}} && $NewTicketValues{'DynamicField_' . $Param{New}->{FieldToCompare}} eq $NewTicketValues{'DynamicField_' . $Param{New}->{FieldNameToCountApproved}} ) {
        # get activity object
        my $ProcessObject = $Kernel::OM->Get('Kernel::System::ProcessManagement::Process');


        # Set the new ActivityEntityID on the Ticket
        my $Success = $ProcessObject->ProcessTicketActivitySet(
            ProcessEntityID  => $NewTicketValues{'DynamicField_ProcessManagementProcessID'},
            ActivityEntityID => $NewTicketValues{'DynamicField_AproveActivity'},
            TicketID         => $Ticket{TicketID},
            UserID           => 1,
        );
    }

    return 1;
}

1;
