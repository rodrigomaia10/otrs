# --
# Kernel/System/InBoxLibrary.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::System::InBoxLibrary;

use strict;
use warnings;

use utf8;

use MIME::Base64;
use MIME::Words qw(:all);

use Kernel::System::VariableCheck (qw(:all));

use parent qw(
    Kernel::System::InBoxLibrary::Ticket
    Kernel::System::InBoxLibrary::PDF
);

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::CheckItem',
    'Kernel::System::Log',
    'Kernel::System::Valid',
);

=head1 NAME

Kernel::System::InBoxLibrary

=head1 SYNOPSIS

All Library module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

   my $InBoxLibraryObject = $Kernel::OM->Get('Kernel::System::InBoxLibrary');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'InBoxLibrary';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}