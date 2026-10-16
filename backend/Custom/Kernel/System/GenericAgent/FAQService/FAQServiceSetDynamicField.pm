# --
# Custom/Kernel/System/GenericAgent/FAQService/FAQServiceSetDynamicField.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * mbernardo@serviceup.com.br
# --

package Kernel::System::GenericAgent::FAQService::FAQServiceSetDynamicField;

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
    my $LinkObject              = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $FAQObject               = $Kernel::OM->Get('Kernel::System::FAQ');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
        DynamicFields => 1,         
    );

    return if( !exists $Param{New}->{FieldName} || !exists $Param{New}->{Categories} || !exists $Param{New}->{FieldValue} ); 
    return if( $Ticket{ServiceID} eq '' ); 

    # checking linked items
    my $LinkListWithData = $LinkObject->LinkListWithData(
        Object => 'Service',
        Key    => $Ticket{ServiceID},
        State  => 'Valid',
        UserID => 1,
    );

    my @Categories = split(';', $Param{New}->{Categories});

    my $Flag = 0;

    # verify categories
    for my $AssociationType ( keys %{ $LinkListWithData->{FAQ} } ){
        for my $KeyLink ( keys %{ $LinkListWithData->{FAQ}->{$AssociationType} } ){
            for my $ConfigItemsLinked ( values %{ $LinkListWithData->{FAQ}->{$AssociationType}->{$KeyLink} } ){
                if ( $ConfigItemsLinked->{CategoryName} ~~ @Categories ) {
                    $Flag = 1;  
                }
            }
        }
    }

    return if (!$Flag);

    # associate task with a ticket
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Param{New}->{FieldName},
    );

    my $Success;

    if( $DynamicField->{FieldType} eq 'Checkbox' ){
       
        $Success = $DynamicFieldValueObject->ValueSet(
            FieldID  => $DynamicField->{ID},               
            ObjectID => $Param{TicketID},                
                                                
            Value    => [
                {
                    ValueInt  => $Param{New}->{FieldValue},          
            
                },
            ],
            UserID   => 1,
        );
    }else{

        $Success = $DynamicFieldValueObject->ValueSet(
            FieldID  => $DynamicField->{ID},               
            ObjectID => $Param{TicketID},                
                                                
            Value    => [
                {
                    ValueText  => $Param{New}->{FieldValue},          
            
                },
            ],
            UserID   => 1,
        );
    }
    
    return if(!$Success);

    my $HistoryAdd = $TicketObject->HistoryAdd(
        Name         => "Atualização de valor do campo dinâmico '$DynamicField->{Name}' para '$Param{New}->{FieldValue}' (InBox CustomModuleGenericAgent)",
        HistoryType  => 'AddNote', 
        TicketID     => $Param{TicketID},
        CreateUserID => 1,
    );
  
}

1;