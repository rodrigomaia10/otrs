# --
# Kernel/System/Ticket/Event/CustomerCC/AddCopyEmails.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by: 
# * ccresencio@serviceup.com.br
# --

package Kernel::System::Ticket::Event::CustomerCC::AddCopyEmails;

use strict;
use warnings;

use utf8;

use Kernel::System::WebUserAgent;
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

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get ticket object
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $CustomerCCObject          = $Kernel::OM->Get('Kernel::System::CustomerCC');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ArticleObject             = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    
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
        
    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => 'CustomerCC',
    );
    
    my $Value = $DynamicFieldBackendObject->ValueGet(
        DynamicFieldConfig => $DynamicField,  
        ObjectID           => $Data->{TicketID}
    );
    
    if ( ( $Param{Event} =~ m/ArticleCreate/ ) || $Param{Event} =~ m/TicketDynamicFieldUpdate_CustomerCC/ ) {

        my @Articles;

        my $Emails = $Data->{OldTicketData}{DynamicField_CustomerCC} || $Data->{Value};

        if( $Param{Event} =~ m/TicketDynamicFieldUpdate_CustomerCC/ ) {
            @Articles = $ArticleObject->ArticleList(
                TicketID => $Data->{TicketID},
                OnlyLast => 1,
            );
        }

        # search the details of the article used to obtain the SenderTypeID
        my @Article = $ArticleObject->ArticleList(
            TicketID   => $Data->{TicketID},
            ArticleID  => $Articles[0]{ArticleID} || $Data->{ArticleID}
        );  

        return if (!$Emails);

        $Article[0]{SenderTypeID} = $Article[0]{SenderTypeID} || 0;

        # check if the SenderTypeID represents the sending of Emails by CustomerPortal
        # if the email is being sent by the agent, it is only necessary to update the table on the first interaction
        return if ( 
            $Article[0]{SenderTypeID} != 3 &&
            $Self->_CountArticles(TicketID => $Data->{TicketID}) > 1
        );     

        if ( $Articles[0]{ArticleID} || $Data->{ArticleID} ) {

            # updates the article_data_mime table with emails in copy  
            my $Success = $CustomerCCObject->ArticleUpdateCC(
                Emails     => $Emails,
                TicketID   => $Data->{TicketID},
                ArticleID  => $Articles[0]{ArticleID} || $Data->{ArticleID}
            );
            
            # add log history with emails in CC
            if ( $Success ) {
                
                $TicketObject->HistoryAdd(
                    Name         => "Add copy emails $Emails",
                    HistoryType  => 'Misc',
                    TicketID     => $Data->{TicketID},
                    ArticleID    => $Articles[0]{ArticleID} || $Data->{ArticleID},
                    QueueID      => $Data->{OldTicketData}{QueueID},
                    CreateUserID => 1,
                );    
            }
        }
    }

    return 1;
}

sub _CountArticles {
    my ( $Self, %Param ) = @_;
    
    # get object
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my @Articles = $ArticleObject->ArticleList(
        TicketID => $Param{TicketID},
    );

    return scalar @Articles;
}

1;