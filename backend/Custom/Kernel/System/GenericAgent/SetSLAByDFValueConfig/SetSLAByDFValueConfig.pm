# --
# Kernel/System/GenericAgent/SetSLAByDFValueConfig/SetSLAByDFValueConfig.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * nfreitas@serviceup.com.br
# --

package Kernel::System::GenericAgent::SetSLAByDFValueConfig::SetSLAByDFValueConfig;

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

    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $SLAObject     = $Kernel::OM->Get('Kernel::System::SLA');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');

    # get config
    my $DFRelationsSLA = $ConfigObject->Get('CustomModuleGenericAgent::SetSLAByDFValueConfig::DFRelations');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        DynamicFields => 1,
    );

    if( $DFRelationsSLA ){

        for my $KeyState ( sort keys %{$DFRelationsSLA} ){

            if( $Ticket{ $Param{New}{Estado} } eq $KeyState ){

                my $Success = $TicketObject->TicketSLASet(
                    SLA      => $DFRelationsSLA->{$KeyState}{$Ticket{ $Param{New}{Cidade} } },
                    TicketID => $Param{TicketID},
                    UserID   => 1,
                );
            }
        }
    }

    return 1;
}
