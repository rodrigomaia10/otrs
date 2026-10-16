# --
# Custom/Kernel/System/GenericAgent/StateForChild/StateForChild.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jguedes@serviceup.com.br
# --

package Kernel::System::GenericAgent::StateForChild::StateForChild;

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

    my $LinkObject   = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # Get list of associated tickets
    my $LinkList = $LinkObject->LinkList(
        Object    => 'Ticket',
        Key       => $Param{TicketID},
        State     => 'Valid',
        UserID    => 1,
    );

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
    );


    return if ( !$LinkList );

    VALIDATE:
    # Take each ticket associated with the ticket to update the dynamic field value
    for my $TicketIDChild ( keys %{ $LinkList->{Ticket}->{ParentChild}->{Target} } ){

        my $Success = $TicketObject->TicketStateSet(
            State     => $Param{New}->{StateChild},
            TicketID  => $TicketIDChild,
            UserID    => 1,
        );

        my $Success = $TicketObject->HistoryAdd(
            Name         => 'Change of state due to change of the ticket parent',
            HistoryType  => 'Misc', 
            TicketID     => $TicketIDChild,
            CreateUserID => 1,
        );
        
        if ( $Param{New}->{Body} && $Param{New}->{Subject} ) {

                my $ArticleID = $Kernel::OM->Get('Kernel::System::Ticket::Article::Backend::Internal')->ArticleCreate(
                    TicketID       		 => $TicketIDChild,
                    SenderType     		 => 'agent',
                    Subject        		 => $Param{New}->{Subject},
                    Body           		 => $Param{New}->{Body},
                    MimeType       		 => 'text/plain',
                    Charset        		 => $LayoutObject->{UserCharset},
                    IsVisibleForCustomer => 0,
                    UserID               => 1,
                    HistoryType          => 'Misc',
                    HistoryComment       => $Param{New}->{Body},
                );
        }
    } 
}

1;