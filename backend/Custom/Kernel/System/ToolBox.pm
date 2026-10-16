# --
# Kernel/Modules/ToolBox.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * Jguedes@serviceup.com.br
# --

package Kernel::System::ToolBox;

use strict;
use warnings;
use URI;
use MIME::Base64;
use utf8;
use Encode qw(decode encode);

use LWP::UserAgent;
use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Ticket',
    'Kernel::System::State',
    'Kernel::System::DateTime',
);

=head1 NAME

Kernel::System::ToolBox

=head1 SYNOPSIS

All ToolBox module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object
    my $ToolBoxObject = $Kernel::OM->Get('Kernel::System::ToolBox');
=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 CustomerUsersList()

    my %List = $ToolBoxObject->CustomerUsersList();

=cut

sub CustomerUsersList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get service from db
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, login FROM customer_user WHERE valid_id = 1',
    );

	# fetch the result
	my %Data;
	while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ $Row[0] } = $Row[1];
	}

	return %Data;
}


1;
