# --
# Kernel/System/GenericAgent/SLAToConfigItem.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::SLAToConfigItem::SLAToConfigItem;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

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
    my $ConfigObject     = $Kernel::OM->Get('Kernel::Config');
    my $SLAObject        = $Kernel::OM->Get('Kernel::System::SLA');
    my $TicketObject     = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    my $SLAByDistance    = $ConfigObject->Get('CustomModuleGenericAgent::SLAToConfigItem::SLAByDistance');

    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
        DynamicFields => 1,
    );
      
    my $ItemID = $Ticket{$Param{New}->{DynamicField}}[0];

    if ($ItemID) {

        my $LastVersion = $ConfigItemObject->VersionGet(
            ConfigItemID => $ItemID,
            XMLDataGet   => 1,
        );

        my $CMDBField = $Param{New}->{Key};

        my $CMDBFieldValue = $LastVersion->{XMLData}[1]->{Version}[1]->{$CMDBField}[1]->{Content};

        my @sorted_keys = sort { $a <=> $b } keys %{$SLAByDistance->{Config}};

        my $SLA;

        for my $Key ( @sorted_keys ) {

            if ( $CMDBFieldValue > $Key ) {
                $SLA = $SLAByDistance->{Config}{$Key};
            }
        }

        my %SLAList = $SLAObject->SLAList(
            Valid     => 1,
            UserID    => 1,
        );

        for my $SLAValue (values %SLAList) {

            if ( $SLAValue eq $SLA ) {

                my $Success = $TicketObject->TicketSLASet(
                    SLA      => $SLA,
                    TicketID => $Param{TicketID},
                    UserID   => 1,
                );

                return 1;
            }
        }

        my $HistoryAdd = $TicketObject->HistoryAdd(
            Name         => "SLA configurado não encontrado (Atendente Genérico).",
            HistoryType  => 'AddNote', 
            TicketID     => $Param{TicketID},
            CreateUserID => 1,
        ); 
    }
    
    return 1;
}

1;