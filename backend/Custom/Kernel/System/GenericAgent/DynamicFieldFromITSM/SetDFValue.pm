# --
# Custom/Kernel/System/GenericAgent/DynamicFieldFromITSM/SetDFValue.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::System::GenericAgent::DynamicFieldFromITSM::SetDFValue;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
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

    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LinkObject         = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');

    #Created link 
    my $LinkList = $LinkObject->LinkList(
        Object    => 'Ticket',
        Key       => $Param{TicketID},
        Object2   => 'ITSMConfigItem',
        State     => 'Valid',
        UserID    => 1,
    );

    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $ConfigItem;
    my $VersionXML;

    #Acessing the fields in the list
    for my $TypeLink ( keys %{ $LinkList->{ITSMConfigItem} } ) {
        for my $Target ( keys %{ $LinkList->{ITSMConfigItem}->{$TypeLink} } ) {
            for my $ConfigItemID ( keys %{ $LinkList->{ITSMConfigItem}->{$TypeLink}->{$Target} } ) {

                $ConfigItem = $ConfigItemObject->ConfigItemGet(
                    ConfigItemID => $ConfigItemID
                );

                $VersionXML = $ConfigItemObject->VersionGet(
                    VersionID  => $ConfigItem->{LastVersionID},
                    XMLDataGet => 1,
                );
            }
        }
    }

    my $XMLData = $VersionXML->{XMLData}->[1]->{Version}->[1];	

    ATTRIBUTE:
    for my $Attribute ( keys %{$XMLData}) {

        if ( $Param{New}->{$Attribute} ) {            

            my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                Name => $Param{New}->{$Attribute},
            );

            if ( $XMLData->{$Attribute}->[1]->{Content} ) {

                my $Success = $BackendObject->ValueSet(
                    DynamicFieldConfig => $DynamicFieldConfig,      
                    ObjectID           => $Param{TicketID},
                    Value              => $XMLData->{$Attribute}->[1]->{Content},
                    UserID             => 1,
                );

                if ( $Success ) {

                    my $HistoryAdd = $TicketObject->HistoryAdd(
                        Name         => "'" . $XMLData->{$Attribute}->[0]->{Content} . "' (InBox CustomModuleGenericAgent)",
                        HistoryType  => 'AddNote', 
                        TicketID     => $Param{TicketID},
                        CreateUserID => 1,
                    );
                }
            }
        }
    }

    return 1;
}

1;