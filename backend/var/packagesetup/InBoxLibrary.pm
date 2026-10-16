# --
# var/packagesetup/InBoxLibrary.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * msantos@serviceup.com.br
# --

package var::packagesetup::InBoxLibrary;

use strict;
use warnings;

use utf8;

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

our @ObjectDependencies = (
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
);

=head1 NAME

InBoxLibrary.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package InBoxLibrary

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

=cut

sub new {
    my ( $Type, %Param ) = @_;
    my $Self = {};
    bless( $Self, $Type );

	$Self->{UserID} = 1;

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $InBoxLibrary->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

1;