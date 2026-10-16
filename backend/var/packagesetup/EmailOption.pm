# --
# var/packagesetup/EmailOption.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * msantos@serviceup.com.br
# --

package var::packagesetup::EmailOption;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

our @ObjectDependencies = (
    'Kernel::System::DynamicField',
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
);

=head1 NAME

ContractManagement.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package ContractManagement

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

    my $Result = $ContractManagement->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

	$Self->_UpgradeDatabase();

    return 1;
}

sub CodeUpgrade_6_3_7 {
    my ( $Self, %Param ) = @_;

    $Self->_UpgradeDatabase();

    return 1;
}

sub _UpgradeDatabase {
	my ( $Self, %Param ) = @_;

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Do(
        SQL => "INSERT INTO article_sender_type (name, comments, valid_id, create_time, create_by, change_time, change_by) "
            . "VALUES ('hidden_agent', 'NULL', 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 1)",
    );

	return 1;
}

1;