# --
# Kernel/System/ServiceCustomerPortal.pm
# Copyright (C) 2019-2021 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * isantos@serviceup.com.br
# --

package Kernel::System::ServiceCustomerPortal;

use strict;
use warnings;

use Kernel::System::VariableCheck (qw(:all));

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::DB',
);

=head1 NAME

Kernel::System::ServiceCustomerPortal - service field level lib

=head1 DESCRIPTION

All service field level functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $ServiceLevelObject = $Kernel::OM->Get('Kernel::System::ServiceCustomerPortal');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'Service';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    $Self->{DBObject} = $Kernel::OM->Get('Kernel::System::DB');

    return $Self;
}

=item ServiceParentList()

Returns services and parent services

    my %Services = $ServiceLevelObject->ServiceParentList(
        ServiceParentID => 0 # Child services of the informed id. (0 to display services without parent server)
    );

=cut

sub ServiceParentList {
    my ( $Self, %Param ) = @_;

    $Param{ServiceParentID} ||= 0;

    # # read cache
    # my $CacheKey = 'ServiceParentList::ServiceParentID' . $Param{ServiceParentID};

    # my $Cache = $Kernel::OM->Get('Kernel::System::Cache')->Get(
    #     Type => $Self->{CacheType},
    #     Key  => $CacheKey,
    # );

    # return %{$Cache} if ref $Cache;

    # get needed object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');   

        my $SQL;
        my @Bind;

    $SQL = 'SELECT service_id, service_name FROM service_field_level WHERE service_parent_id = ?';

    push @Bind, \$Param{ServiceParentID};

    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );  

        my %Result;

    # fetch the result
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Result{$Row[0]} = $Row[1];
    }

    # # set cache
    # $Kernel::OM->Get('Kernel::System::Cache')->Set(
    #     Type  => $Self->{CacheType},
    #     TTL   => $Self->{CacheTTL},
    #     Key   => $CacheKey,
    #     Value => \%Result,
    # );

    return %Result;
}

=item SyncServiceLevel()

Performs service synchronization

    my $Success = $ServiceLevelObject->SyncServiceLevel();

=cut

sub SyncServiceLevel {
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

        if ( !$SuccessInsert && !$SuccessDelete ) {

            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Error when deleting or inserting the ServiceID $ServiceData->{ServiceID} in the synchronization table",
            );
        }
    }

    return 1;
}

=item ServiceParentSearchList()

Returns services and parent services

    my %Services = $ServiceLevelObject->ServiceParentSearchList(
        ServiceParentID => 0 # Child services of the informed id. (0 to display services without parent server),
        SearchTerm      => 'Service Term',
    );

=cut

sub ServiceParentSearchList {
    my ( $Self, %Param ) = @_;

    $Param{ServiceParentID} ||= 0;

    # get needed object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');   

        my $SQL;
        my @Bind;

    # $SQL = 'SELECT service_id, service_name FROM service_field_level WHERE 1=1 ';
    $SQL = 'SELECT 
                s1.id AS service_id,
                s1.name AS service_name,
            CASE 
            WHEN s1.id = s2.id THEN 0
            ELSE
                s2.id 
            END AS parent_service_id
            FROM 
                service s1
            LEFT JOIN 
                service s2 ON s2.name = REPLACE( s1.name, concat( "::", SUBSTRING_INDEX(s1.name, "::", -1) ), "")
            WHERE s1.valid_id = 1';

    
    if ( $Param{SearchTerm} ) {

        # quote
        $Param{SearchTerm} = $DBObject->Quote( $Param{SearchTerm}, 'Like' );

        # replace * with % and clean the string
        $Param{SearchTerm} =~ s{ \*+ }{%}xmsg;
        $Param{SearchTerm} =~ s{ %+ }{%}xmsg;

        my $LikeString = '%' . $Param{SearchTerm} . '%';

        push @Bind, \$LikeString;

        $SQL .= " AND LOWER(s1.name) LIKE LOWER(?)";
    } 

    if ( !$Param{AllServices} ) {
        # $SQL .= 'AND service_parent_id = ? ';
        $SQL .= ' having parent_service_id = ? ';
        push @Bind, \$Param{ServiceParentID};
    }

    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );  

        my %Result;

    # fetch the result
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Result{$Row[0]} = $Row[1];
    }    

    return %Result;
}

=head2 ServiceSearch()

return service ids as an array

    my @ServiceList = $ServiceLevelObject->ServiceSearch(
        Name   => 'Service Name', # (optional)
        UserID => 1,
    );

=cut

sub ServiceSearch {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need UserID!',
        );
        return;
    }

    my $DatabaseType = $Kernel::OM->Get('Kernel::System::DB')->{'DB::Type'};

    if ( $DatabaseType ne 'oracle' ) {

        my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');

        my @ServiceList = $ServiceObject->ServiceSearch(
            Name   => $Param{Name},
            UserID => $Param{UserID},
        );

        return @ServiceList;
    }

    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = "SELECT id FROM service WHERE valid_id IN ( ${\(join ', ', $Kernel::OM->Get('Kernel::System::Valid')->ValidIDsGet())} )";

    my @Bind;

    if ( $Param{Name} ) {

        # quote
        $Param{Name} = $DBObject->Quote( $Param{Name}, 'Like' );

        # replace * with % and clean the string
        $Param{Name} =~ s{ \*+ }{%}xmsg;
        $Param{Name} =~ s{ %+ }{%}xmsg;

        my $LikeString = '%' . $Param{Name} . '%';

        push @Bind, \$LikeString;

        $SQL .= " AND LOWER(s1.name) LIKE LOWER(?)";
    }

    $SQL .= ' ORDER BY name';
 

    $DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );
 
    my @ServiceList;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        push @ServiceList, $Row[0];
    }

    return @ServiceList;
}

1;