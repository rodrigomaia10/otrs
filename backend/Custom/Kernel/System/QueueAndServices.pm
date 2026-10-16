# --
# Custom/Kernel/System/Ticket/QueueAndServices.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::System::QueueAndServices;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::DB',
);

=head1 NAME

Kernel::System::QueueAndServices - group and roles lib

=head1 SYNOPSIS

All locations and customer functions. E. g. to add location or to get a location list of a customer.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $QueueAndServicesObject = $Kernel::OM->Get('Kernel::System::QueueAndServices');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item QueueAndServicesAdd()

associate Queue Service

    my $Service = $QueueAndServicesObject->QueueAndServicesAdd(
        QueueID   => 1,
        ServiceID => #service_id,
        UserID    => 1,
    );

=cut

sub QueueAndServicesAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(QueueID ServiceID UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!",
            );
            return;
        }
    }

    # get needed object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');   
	
	# delete existing relation
	return if !$DBObject->Do(
		SQL  => 'DELETE FROM queue_service WHERE queue_id = ? AND service_id = ?',
		Bind => [ \$Param{QueueID}, \$Param{ServiceID} ],
	);  
	
	# insert new relation
	return if !$DBObject->Do(
		SQL => 'INSERT INTO queue_service '
			. '(queue_id, service_id, create_time, create_by, change_time, change_by) '
			. 'VALUES (?, ?, current_timestamp, ?, current_timestamp, ?)',
		Bind => [ \$Param{QueueID}, \$Param{ServiceID}, \$Param{UserID}, \$Param{UserID} ],
	);

    return 1;
}

=item QueueAndServicesList()

list a List Services

    my @Service = $QueueAndServicesObject->QueueAndServicesList(
        QueueID   => 1 # optional this or QueueID,
		ServiceID => 1 # optional this or ServiceID,,
		UserID    => 1,
    );

=cut

sub QueueAndServicesList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!",
            );
            return;
        }
    }

    # get needed object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');   
	
	my $SQL;
	my @Bind;
	
	if ( $Param{QueueID} ){
		$SQL = 'SELECT service_id FROM queue_service WHERE queue_id = ?';
		push @Bind, \$Param{QueueID};
	}
	elsif( $Param{ServiceID} ){
		$SQL = 'SELECT queue_id FROM queue_service WHERE service_id = ?';
		push @Bind, \$Param{ServiceID};
	}	
	
    # delete existing relation
    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );  
	
	my @Result;
	
    # fetch the result
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @Result, $Row[0];
    }

    return @Result;
}

=item CleanUp()

clear Services

    my @Services = $QueueAndServicesObject->CleanUp(
        CustomerID  => 1 # optional,
		KeyLocation => 1 # optional,
        UserID      => 1,
    );

=cut

sub CleanUp {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw( UserID )) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!",
            );
            return;
        }
    }

    # get needed object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');   
	my $SQL = 'DELETE FROM queue_service WHERE';
	my @Bind;
	
	if ( $Param{QueueID} ){
		$SQL .= ' queue_id = ?';
		push @Bind, \$Param{QueueID};
	}
	elsif( $Param{ServiceID} ){
		$SQL .= ' service_id = ?';
		push @Bind, \$Param{ServiceID};
	}	
	
    # delete existing relation
    return if !$DBObject->Do(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    return 1;
}


1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
