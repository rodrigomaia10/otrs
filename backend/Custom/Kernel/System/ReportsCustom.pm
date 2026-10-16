# --
# Kernel/System/ReportsCustom.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jguedes@serviceup.com.br
# -- 

package Kernel::System::ReportsCustom;

use strict; 
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::DB',
    'Kernel::System::Log'
);

=head1 NAME

Kernel::System::ReportsCustom

=head1 SYNOPSIS

All Ticket Invoker module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $ReportsObject = $Kernel::OM->Get('Kernel::System::ReportsCustom');

=cut


sub new {
     my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'ReportsCustom';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}


sub QueueCreateTicket {
    my ( $Self, %Param ) = @_;
    
     # check needed stuff
    for my $Parameter ( qw( TicketID ) ) {
        if ( !$Param{$Parameter} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Parameter!",
            );
            return;
        } 
    }   

    # get objects
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

           return if !$DBObject->Prepare(
            SQL => 'SELECT queue_id FROM ticket_history WHERE ticket_id  = ? LIMIT 1',
            Bind  => [ \$Param{TicketID} ],
        );

        my $Data;
        while ( my @Row = $DBObject->FetchrowArray() ) {
            
            $Data = $Row[0];
        }

    return $Data;
}


1;