# --
# Custom/Kernel/System/Ticket/TypeAndServices.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::System::TypeAndServices;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::DB',
);

=head1 NAME

Kernel::System::TypeAndServices - group and roles lib

=head1 SYNOPSIS

All locations and customer functions. E. g. to add location or to get a location list of a customer.

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object. Do not use it directly, instead use:

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $TypeAndServicesObject = $Kernel::OM->Get('Kernel::System::TypeAndServices');

=cut

	sub new {
		my ( $Type, %Param ) = @_;

		# allocate new hash for object
		my $Self = {};
		bless( $Self, $Type );

		return $Self;
	}

=item TypeAndServicesAdd()

associate Type Service

    my $Service = $TypeAndServicesObject->TypeAndServicesAdd(
        TypeID    => 1,
        ServiceID => #service_id,
        UserID    => 1,
    );

=cut

sub TypeAndServicesAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TypeID ServiceID UserID)) {
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
		SQL  => 'DELETE FROM type_service WHERE type_id = ? AND service_id = ?',
		Bind => [ \$Param{TypeID}, \$Param{ServiceID} ],
	);  
	
	# insert new relation
	return if !$DBObject->Do(
		SQL => 'INSERT INTO type_service '
			. '(type_id, service_id, create_time, create_by, change_time, change_by) '
			. 'VALUES (?, ?, current_timestamp, ?, current_timestamp, ?)',
		Bind => [ \$Param{TypeID}, \$Param{ServiceID}, \$Param{UserID}, \$Param{UserID} ],
	);

    return 1;
}

=item TypeAndServicesList()

list a List Services

    my @Service = $TypeAndServicesObject->TypeAndServicesList(
        TypeID    => 1 # optional this or TypeID,
		ServiceID => 1 # optional this or ServiceID,,
		UserID    => 1,
    );

=cut

sub TypeAndServicesList {
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
	
	if ( $Param{TypeID} ){
		$SQL = 'SELECT service_id FROM type_service WHERE type_id = ?';
		push @Bind, \$Param{TypeID};
	}
	elsif( $Param{ServiceID} ){
		$SQL = 'SELECT type_id FROM type_service WHERE service_id = ?';
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

    my @Services = $TypeAndServicesObject->CleanUp(
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
	my $SQL = 'DELETE FROM type_service WHERE';
	my @Bind;
	
	if ( $Param{TypeID} ){
		$SQL .= ' type_id = ?';
		push @Bind, \$Param{TypeID};
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
