# --
# Custom/Kernel/System/GenericAgent/DynamicFieldFromFAQ/DynamicFieldFromFAQ.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# --

package Kernel::System::GenericAgent::DynamicFieldFromFAQ::DynamicFieldFromFAQ;

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

    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LinkObject = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $FAQObject = $Kernel::OM->Get('Kernel::System::FAQ');

    #Created link 
    my $LinkList = $LinkObject->LinkList(
        Object    => 'Ticket',
        Key       => $Param{TicketID},
        Object2   => 'FAQ',
        State     => 'Valid',
        UserID    => 1,
    );

    my %FAQ;

    #Acessing the fields in the list
    for my $TypeLink ( keys %{ $LinkList->{FAQ} } ){
        for my $Target ( keys %{ $LinkList->{FAQ}->{$TypeLink} } ){
            for my $FAQID ( keys %{ $LinkList->{FAQ}->{$TypeLink}->{$Target} } ){
                %FAQ = $FAQObject->FAQGet(
                    ItemID     => $FAQID,
                    ItemFields => 1,        
                    UserID     => 1,
                );
            }
        }

    }
    #Taking the fields that will be used
    for my $Field ( keys %{ $Param{New} } ){

        if ( $Field =~ m/FAQField_/ ){

            my @Attribute = split /_/, $Field;

            my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                Name => $Param{New}->{$Field},

            );

            my $Success = $DynamicFieldValueObject->ValueSet(
                FieldID  => $DynamicField->{ID},                 
                ObjectID => $Param{TicketID},  
                Value => [ 
                    {
                    ValueText => $FAQ{ $Attribute[1] },
                    }
                ],                                                      
                UserID   => 1,
            );

            if($Success){

                my $HistoryAdd = $TicketObject->HistoryAdd(
                    Name         => "'$FAQ{ $Attribute[1] }' (InBox CustomModuleGenericAgent)",
                    HistoryType  => 'AddNote', 
                    TicketID     => $Param{TicketID},
                    CreateUserID => 1,
                );
            }
        }
    }

    return 1;
}

1;