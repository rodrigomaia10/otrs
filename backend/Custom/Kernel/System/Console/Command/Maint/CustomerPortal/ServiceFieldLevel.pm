# --
# Kernel/System/Console/Command/Maint/ServiceFieldLevel/ServiceFieldLevel.pm
# Copyright (C) 2019-2021 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::System::Console::Command::Maint::CustomerPortal::ServiceFieldLevel;

use strict;
use warnings;
use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck (qw(:all));
use utf8;
use Encode;

use parent qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
    'Kernel::System::DB',
);

sub Configure {
    my ( $Self, %Param ) = @_;

    $Self->Description('Synchronizing services');

    return;
}

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->Print("<yellow>Synchronizing parent and child services in the ServiceFieldLevel module...</yellow>\n");

    $Self->_SyncService();
    
    $Self->Print("<green>Done.</green>\n");

    return $Self->ExitCodeOk();
}

sub _SyncService {
	my ( $Self, %Param ) = @_;

    # get object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # create SQL query
    my $SQL = 'SELECT id, name FROM service WHERE valid_id = 1 ORDER BY name';

    # ask database
    $DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @ServiceList;
    my %ServiceName2ID;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        my %ServiceData;

        $ServiceData{ServiceID} = $Row[0];
        $ServiceData{Name}      = $Row[1];

        # add service data to service list
        push @ServiceList, \%ServiceData;

        # build service id lookup hash
        $ServiceName2ID{ $ServiceData{Name} } = $ServiceData{ServiceID};
    }

    for my $ServiceData (@ServiceList) {

        # create short name and parentid
        $ServiceData->{NameShort} = $ServiceData->{Name};

        if ( $ServiceData->{Name} =~ m{ \A (.*) :: (.+?) \z }xms ) {

            my $ParentName = $1;

            $ServiceData->{NameShort} = $2;
            $ServiceData->{ParentID}  = $ServiceName2ID{$ParentName};
        }

        my $SuccessDelete = $DBObject->Do(
            SQL  => 'DELETE FROM service_field_level WHERE service_id = ? ',
            Bind => [ \$ServiceData->{ServiceID} ],
        );

        $ServiceData->{ParentID} ||= 0;

        my $SuccessInsert = $DBObject->Do(
            SQL => 'INSERT INTO service_field_level '
                . '( service_id, service_name, service_parent_id, change_time) '
                . 'VALUES (?, ?, ?, current_timestamp)',
            Bind => [ \$ServiceData->{ServiceID}, \$ServiceData->{Name}, \$ServiceData->{ParentID} ],
        );

        if ( $SuccessInsert && $SuccessDelete ) {
            $Self->Print("<yellow>ServiceID $ServiceData->{ServiceID} successfully synchronized.</yellow>\n");
        }
        else {
            $Self->Print("<red>Error when deleting or inserting the ServiceID $ServiceData->{ServiceID} in the synchronization table</red>\n");
        }
    }
}

1;