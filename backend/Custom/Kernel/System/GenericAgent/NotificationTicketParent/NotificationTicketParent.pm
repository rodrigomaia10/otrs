# --
# Kernel/System/GenericAgent/NotificationTicketParent/NotificationTicketParent.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * dparavani@serviceup.com.br
# --

package Kernel::System::GenericAgent::NotificationTicketParent::NotificationTicketParent;

use utf8;
use strict;
use warnings;
use LWP::Simple;
use MIME::Base64;
use LWP::UserAgent;
use HTTP::Request::Common;
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
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
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject         = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LinkObject           = $Kernel::OM->Get('Kernel::System::LinkObject');

    my $ChildStateConfig  = $Param{New}->{ChildState};
    my $ParentStateConfig = $Param{New}->{ParentState};

    my $LinkList = $LinkObject->LinkList(
        Object    => 'Ticket',
        Key       => $Param{TicketID},
        State     => 'Valid',
        UserID    => 1,
    );

    return 1 if !$LinkList->{Ticket}->{ParentChild}->{Source};

    my @TicketIDsParent = $Self->_GetTicketIDs(
        $LinkList, 
        'Source'
    );

    my %TicketChild = $TicketObject->TicketGet(
        TicketID      => $Param{TicketID},
        UserID        => 1,
    );
    
    for my $TicketIDParent ( @TicketIDsParent ) {     

        if ( $TicketChild{State} eq $ChildStateConfig ) {

            $Self->_SendParentNotification(
                TicketIDParent    => $TicketIDParent,
                TicketNumberChild => $TicketChild{TicketNumber},
                ChildStateConfig  => $ChildStateConfig
            );

            if ( $ParentStateConfig ) {

                my $ParentLinkList = $LinkObject->LinkList(
                    Object    => 'Ticket',
                    Key       => $TicketIDParent,
                    State     => 'Valid',
                    UserID    => 1,
                );

                if ( $ParentLinkList->{Ticket}->{ParentChild}->{Target} ) {
                        
                    my @TicketIDsChild = $Self->_GetTicketIDs(
                        $ParentLinkList, 
                        'Target'
                    );

                    my $ValidationTicketChild = $Self->_ValidationTicketChild(
                        TicketIDsChild   => \@TicketIDsChild,
                        ChildStateConfig => $ChildStateConfig
                    );

                    if ( $ValidationTicketChild ) {

                        my $Success = $TicketObject->TicketStateSet(
                            State    => $ParentStateConfig,
                            TicketID => $TicketIDParent,
                            UserID   => 1,
                        );
                    }
                }                
            }
        }
    }

    return 1;
}

sub _GetTicketIDs {
    my ($Self, $Data, $Type) = @_;

    my @TicketIDs;
    for my $TicketID (keys %{$Data->{Ticket}->{ParentChild}->{$Type}}) {
        push @TicketIDs, $TicketID;
    }
    return @TicketIDs;
}

sub _SendParentNotification {
    my ( $Self, %Param ) = @_;

    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');
            
    my $ArticleBackendObject = $ArticleObject->BackendForChannel( ChannelName => 'Email' );    
    my $ArticleID = $ArticleBackendObject->ArticleCreate(
        TicketID             => $Param{TicketIDParent},
        SenderType           => 'system',
        IsVisibleForCustomer => 0,
        UserID               => 1,
        From                 => "Admin",
        Subject              => $LayoutObject->{LanguageObject}->Translate("Child ticket status has been changed!"),
        Body                 => $LayoutObject->{LanguageObject}->Translate("The ticket %s has been updated to status %s.", $Param{TicketNumberChild}, $Param{ChildStateConfig}),
        ContentType          => 'text/plain; charset=ISO-8859-15',
        HistoryType          => 'Misc',
        HistoryComment       => $LayoutObject->{LanguageObject}->Translate('Child ticket status has been changed!'),
    );
}

sub _ValidationTicketChild {
    my ( $Self, %Param ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my $ValidationTicketChild = 1;

    for my $TicketIDChild ( @{$Param{TicketIDsChild}} ) {

        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $TicketIDChild,
            UserID        => 1,
        );
                        
        if ( $Ticket{State} ne $Param{ChildStateConfig} ) {
            $ValidationTicketChild = 0;
        }
    }
    
    return $ValidationTicketChild;
}

1;