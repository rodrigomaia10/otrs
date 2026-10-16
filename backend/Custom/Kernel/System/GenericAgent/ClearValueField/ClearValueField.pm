# --
# /opt/Dev/CustomModuleGenericAgent/src/Custom/Kernel/System/GenericAgent/ClearValueField/ClearValueField.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# --

package Kernel::System::GenericAgent::ClearValueField::ClearValueField;

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

    my $DynamicFieldITSMEmailLinkObject = $Kernel::OM->Get('Kernel::System::DynamicFieldITSMEmailLink');
    my $DynamicFieldITSMMatrixObject    = $Kernel::OM->Get('Kernel::System::DynamicFieldITSMMatrix');
    my $DynamicFieldObject              = $Kernel::OM->Get('Kernel::System::DynamicField');

    # Get DynamicFieldID
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{DynamicField}
    );


    # Condition for selecting the ITSMEmailLink or ITSMMatrix Matrix
    if ( $DynamicField->{FieldType} eq "ITSMEmailLink" ){

        #Delete Fiels on ITSMEmailLink
        my $Success = $DynamicFieldITSMEmailLinkObject->_ValueCleanup(
            FieldID => $DynamicField->{ID},
            ObjectID => $Param{TicketID}
        );

    }else{

        # Delete Fiels on ITSMMatrix
        my $Success = $DynamicFieldITSMMatrixObject->_ValueCleanup(
            FieldID => $DynamicField->{ID},
            ObjectID => $Param{TicketID}
        );
        
    }
}

1;