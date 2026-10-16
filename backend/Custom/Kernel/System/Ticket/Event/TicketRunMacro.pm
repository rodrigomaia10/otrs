# --
# Kernel/System/Ticket/Event/TicketRunMacro.pm
# Copyright (C)  2019-2022 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::System::Ticket::Event::TicketRunMacro;

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

    if ( $Param{Event} =~ m/TicketDynamicFieldUpdate/ ) {

        $Param{Event} =~ s/TicketDynamicFieldUpdate_(.*?)/$1/g;

        my $FieldUpdate = "DynamicField_$Param{Event}";

        return 1 if !$Data->{TicketID};        

        my %Ticket = $TicketObject->TicketGet(
            TicketID => $Data->{TicketID},
            DynamicFields => 1,
        );

        return 1 if !$Ticket{ServiceID};

        my %ServiceData = $ServiceObject->ServiceGet(
            ServiceID => $Ticket{ServiceID},
            UserID    => 1
        );

        if ($Ticket{DynamicField_CustomerContract}){
            
            if($Ticket{ServiceID}){
                
                my $ContractAndServicesObject = $Kernel::OM->Get('Kernel::System::ContractAndServices');

                my %ServicesPreferences = $ContractAndServicesObject->ContractServicePreferencesGet(
                    ServiceID  => $Ticket{ServiceID},
                    ContractID => $Ticket{DynamicField_CustomerContract},
                );
                
                my $ServiceMacroPreferences = $YAMLObject->Load(
                    Data => $ServicesPreferences{ServiceMacro}
                );

                if ( IsHashRefWithData($ServiceMacroPreferences) ) {
                    $ServiceData{ServiceMacro} = $ServicesPreferences{ServiceMacro};
                }             
            }

        }

        my $ServiceMacro = $YAMLObject->Load(
            Data => $ServiceData{ServiceMacro}
        );

        return 1 if ( !$ServiceMacro );

        FIELD:
        for my $Field ( % { $ServiceMacro } ) {

            next FIELD if ( !( $Field =~ m/$FieldUpdate/ ) );
            next FIELD if ( $ServiceMacro->{$Field}->{Value} ne $Data->{Value} );
            
            $MacroObject->MacroRun(
                MacroName => $ServiceMacro->{$Field}->{Macro},
                TicketID  => $Data->{TicketID},
                UserID    => 1,
            );           

            my $Success = $TicketObject->HistoryAdd(
                Name         => $LayoutObject->{LanguageObject}->Translate( '"%s" macro executed.', $ServiceMacro->{$Field}->{Macro} ),
                HistoryType  => 'Misc',
                TicketID     => $Data->{TicketID},
                CreateUserID => 1,
            );
        }
    }

    return 1;
}

1;