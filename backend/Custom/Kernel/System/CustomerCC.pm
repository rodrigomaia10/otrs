# --
# Kernel/System/CustomerCC.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * ccresencio@serviceup.com.br
# --

package Kernel::System::CustomerCC;

use strict;
use warnings;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = ();

=head1 NAME

Kernel::System::CustomerCC - dynamic field customer CC lib

=head1 DESCRIPTION

All dynamic field CustomerCC functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $CustomerCCObject = $Kernel::OM->Get('Kernel::System::CustomerCC');

=cut

sub new {
    my ($Type, %Param) = @_;

    my $Self = {%Param};
    bless ( $Self, $Type );

    return $Self;
}

=head2 ArticleUpdateCC()

updates emails in copy of an article

    my $Success = $CustomerCCObject->ArticleUpdateCC(
        Emails     => ['email1@example.com','email2@example.com'],
        ArticleID  => 123
    );
    
=cut

sub ArticleUpdateCC {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Emails TicketID ArticleID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get objects Perl
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DBObject      = $Kernel::OM->Get('Kernel::System::DB');

    # update with CC
    return if !$DBObject->Do(
        SQL => "UPDATE article_data_mime SET a_cc = ?, change_time = current_timestamp WHERE article_id = ? ",
        Bind => [ \$Param{Emails}, \$Param{ArticleID} ]
    );
    
    return 1;
}

1;