# --
# Kernel/System/Console/Command/Maint/Ticket/VerifyDynamicFieldDate.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# -- 

package Kernel::System::Console::Command::Maint::Ticket::VerifyDynamicFieldDate;
use strict;
use warnings;
use Kernel::Language qw(Translatable);
use parent qw(Kernel::System::Console::BaseCommand);
use utf8;
use Kernel::System::VariableCheck qw(:all);


our @ObjectDependencies = (
    'Kernel::Config',
	'Kernel::System::DB',
    'Kernel::System::Main',
    'Kernel::System::Package',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Check if user session is valid.');

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Checking tickets of VerifyDynamicFieldDate ...</yellow>\n");

    #get objcets
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');
    my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime' );
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

    my $Config = $ConfigObject->Get("VerifyDynamicFieldDate::Core");
    my $ServicesIDs = $Config->{ServicesIDs};
    my $DynamicFieldDateToCompare = $Config->{DynamicFieldDateToCompare};
    my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # To tickets in services and with dynamicField date value 
    my @TicketIDs = $TicketObject->TicketSearch(
        Result                       => 'ARRAY',
        Limit                        => 100000,   
        ServiceIDs                   => $ServicesIDs,
        UserID                       => 1,    
        "DynamicField_$DynamicFieldDateToCompare" => {
            Empty             => 0, 
        },  
    );

    if (@TicketIDs){
        my $SystemTime = $TimeObject->SystemTime();  
        my $TimeStamp = $TimeObject->SystemTime2TimeStamp(
            SystemTime => $SystemTime,
        );

        my $CurrentateObject = $Kernel::OM->Create(
            'Kernel::System::DateTime',
            ObjectParams => {
                String   => $TimeStamp,
            }
        );

        TICKET:
        for my $TicketID (sort @TicketIDs){
            my %TicketToSend = $TicketObject->TicketGet(
                TicketID      => $TicketID,
                UserID        => 1,
                DynamicFields => 1,
                
            );

            my $TicektDFDateObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String   => $TicketToSend{"DynamicField_$DynamicFieldDateToCompare"},
                }
            );
            my $Compare = $CurrentateObject->Compare( DateTimeObject   => $TicektDFDateObject );
          
            if($Compare >= 0 && $TicketToSend{"DynamicField_DataAtingida"} ne 'Sim'){
               
                my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                    Name => 'DataAtingida',
                );

                my $Success = $DynamicFieldValueObject->ValueSet(
                    FieldID  => $DynamicFieldConfig->{ID},
                    ObjectID => $TicketID,
                    Value    =>
                    [
                        {
                            ValueText  => 'Sim',

                        },
                    ],
                    UserID   => 1,
                );

                if($Success){
                    my $SuccessHistory = $TicketObject->HistoryAdd(
                        Name         => $LayoutObject->{LanguageObject}->Translate("Dynamic Field DataAtingida value change to Yes"),
                        HistoryType  => 'TicketDynamicFieldUpdate',
                        TicketID     => $TicketID,
                        CreateUserID => 1,
                    );
                }

            }else{
                next TICKET;
            }

        }

    }else{
        $Self->Print(" No Tickets found!\n");
    }

   

    $Self->Print("<green>Done.</green>\n");
    return $Self->ExitCodeOk();

}

1;