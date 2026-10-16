# --
# Kernel/System/Dashboard/Dashboard.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dparavani@serviceup.com.br

# --

package Kernel::System::Dashboard::Dashboard;

use strict;
use warnings;

use Kernel::System::VariableCheck (qw(:all));
use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::CheckItem',
    'Kernel::System::Log',
    'Kernel::System::Valid',
);

=head1 NAME

Kernel::System::Dashboard::Dashboard

=head1 SYNOPSIS

Dashboard module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $DashboardObject = $Kernel::OM->Get('Kernel::System::Dashboard::Dashboard');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'Dashboard';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=head2 NameExistsCheck()

    return 1 if another dashboard with this name already exits

        $Exist = $DashboardObject->NameExistsCheck(
            Name => 'Some::Template',
            ID => 1, # optional
        );

=cut

sub NameExistsCheck {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    return if !$DBObject->Prepare(
        SQL  => 'SELECT id FROM kpi_dashboard WHERE name = ?',
        Bind => [ \$Param{Name} ],
    );

    # fetch the result
    my $Flag;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        if ( !$Param{ID} || $Param{ID} ne $Row[0] ) {
            $Flag = 1;
        }
    }
    if ($Flag) {
        return 1;
    }
    return 0;
}

=head2 DashboardAdd()

add Dashboard

Return
    $Success = 1 | 0
Name AvailableInterface ValidID
    my $NewDashboard = $DashboardObject->DashboardAdd(
        Name               => 'Dashboard Name',
        AvailableInterface => 'Agent', 'Customer', 'Agent and Customer',
        ValidID            => 1,
        GroupIDs           => ['admin', 'users']
    );

=cut

sub DashboardAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name AvailableInterface ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need $Argument!',
            );
            return;
        }
    }

    # check if a dashboard with this name already exists
    if ( $Self->NameExistsCheck( Name => $Param{Name} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "A dashboard with the name '$Param{Name}' already exists.",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # create new db record
    return if !$DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard (name, available, customer_id, group_ids, valid_id, create_time, change_time) VALUES (?, ?, ?, ?, ?, current_timestamp, current_timestamp)',
        Bind => [
            \$Param{Name}, \$Param{AvailableInterface}, \$Param{CustomerID}, \$Param{GroupIDs}, \$Param{ValidID}
        ],
    );

    # get new type id
    return if !$DBObject->Prepare(
        SQL   => 'SELECT id FROM kpi_dashboard WHERE name = ?',
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    # fetch the result
    my $ID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ID = $Row[0];
    }
    return if !$ID;

    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return $ID;
}

=head2 DashboardList()

Get the List of Dashboards

    my %List = $DashboardObject->DashboardList();

    or

    my %List = $DashboardObject->DashboardList(
        Valid => 0,
    );

=cut

sub DashboardList {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    my $Valid = 1;
    if ( !$Param{Valid} && defined $Param{Valid} ) {
        $Valid = 0;
    }

    # check cache
    my $CacheKey = "DashboardList::Valid::$Valid";
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return %{$Cache} if $Cache;

    # create the valid list
    my $ValidIDs = join ', ', $Kernel::OM->Get('Kernel::System::Valid')->ValidIDsGet();

    # build SQL
    my $SQL = 'SELECT id, name FROM kpi_dashboard';

    # add WHERE statement
    if ($Valid) {
        $SQL .= ' WHERE valid_id IN (' . $ValidIDs . ')';
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # ask database
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my %DashboardList;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $DashboardList{ $Row[0] } = $Row[1];
    }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%DashboardList,
    );

    return %DashboardList;

}

=head2 DashboardGet()

get dashboards attributes

    my %Data = $DashboardObject->DashboardGet(
        ID => 123,
    );

Returns:

    Type = (
        ID          => '123',
        Name        => 'Service Request',
        Available   => 'Agent', 'Customer', 'Agent and Customer',
        customer_id => "customerID"
        Groups      => '1,2',
        ValidID     => '1',
        CreateTime  => '2010-04-07 15:41:15',
        ChangeTime  => '2010-04-07 15:59:45',
    );

=cut

sub DashboardGet {
    my ( $Self, %Param ) = @_;

    # either ID or Name must be passed
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    # check cache
    my $CacheKey = 'DashboardGet::ID::' . $Param{ID};
    my $Cache    = $Kernel::OM->Get('Kernel::System::Cache')->Get(
        Type => $Self->{CacheType},
        Key  => $CacheKey,
    );
    return %{$Cache} if $Cache;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # ask the database
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, available, customer_id, group_ids, valid_id, settings, '
            . 'create_time, change_time '
            . 'FROM kpi_dashboard WHERE id = ?',
        Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Dashboard;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        $Dashboard{ID}                 = $Data[0];
        $Dashboard{Name}               = $Data[1];
        $Dashboard{AvailableInterface} = $Data[2];
        $Dashboard{CustomerID}         = $Data[3];
        @{$Dashboard{Groups}}          = split /,/, $Data[4];
        $Dashboard{ValidID}            = $Data[5];
        $Dashboard{Settings}           = $Data[6];
        $Dashboard{CreateTime}         = $Data[7];
        $Dashboard{ChangeTime}         = $Data[8];
    }

    # no data found
    if ( !%Dashboard ) {
        my $Error = $Param{Name} ? "Dashboard '$Param{Name}'" : "DashboardID '$Param{ID}'";
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $Error . " not found!",
        );
        return;
    }

    # set cache
    $Kernel::OM->Get('Kernel::System::Cache')->Set(
        Type  => $Self->{CacheType},
        TTL   => $Self->{CacheTTL},
        Key   => $CacheKey,
        Value => \%Dashboard,
    );

    return %Dashboard;
}

sub DashboardUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(ID Name AvailableInterface ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need $Argument!',
            );
            return;
        }
    }

    # check if a dashboard with this name already exists
    if ( 
        $Self->NameExistsCheck( 
            Name => $Param{Name},
            ID   => $Param{ID} 
        ) 
        ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "A dashboard with the name '$Param{Name}' already exists.",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # create new db record
    return if !$DBObject->Do(
        SQL => 'UPDATE kpi_dashboard SET name = ?, available = ?, customer_id = ?, group_ids = ?, valid_id = ?, change_time = current_timestamp '
            . 'WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{AvailableInterface}, \$Param{CustomerID}, \$Param{GroupIDs}, \$Param{ValidID}, \$Param{ID}
        ],
    );

    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return 1;
}

=head2 SaveCardSettings()

add card

    my $NewCard = $DashboardObject->SaveCardSettings(
        DashboardID    => 10,
        CardSettingsID => 8,
        SelectCardType => 'HTML | KPI'
        Template       => '<strong> Hi </strong>'
        AssociatedKPIs => 6,
    );

Return:
    $Success = 1 | 0
    
=cut

sub SaveCardSettings {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(DashboardID CardSettingsID SelectCardType)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need $Argument!',
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # create new db record
    return if !$DBObject->Do(
        SQL => 'UPDATE kpi_dashboard_card SET kpi_id = ?, content_template = ?, card_type = ? '
            . 'WHERE card_id = ? AND dashboard_id = ?',
        Bind => [
            \$Param{AssociatedKPIs}, \$Param{Template}, \$Param{SelectCardType}, \$Param{CardSettingsID}, \$Param{DashboardID}
        ],
    );

    return 1;
}

=head2 CardPositionSizeAdd()

# add card position and size

    my $Sucess = $DashboardObject->CardPositionSizeAdd(
        $Card
    );

Return:
    $Success = 1 | 0
    
=cut

sub CardPositionSizeAdd {
    my ( $Self, %Param ) = @_;

    my $IDExists = $Self->CardIDExistsCheck( %Param );

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if ( !$IDExists ) {

        # create new db record
        return if !$DBObject->Do(
            SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, position_x, position_y, width, height) VALUES (?, ?, ?, ?, ?, ?)',
            Bind => [
                \$Param{'CardID'}, \$Param{DashboardID}, \$Param{'PositionX'}, \$Param{'PositionY'}, \$Param{'CardWidth'}, \$Param{'CardHeight'}
            ],
        );
    }
    else {

        # update db record
        return if !$DBObject->Do(
                SQL => 'UPDATE kpi_dashboard_card SET position_x = ?, position_y = ?, width = ?, height = ? '
                    . 'WHERE card_id = ? AND dashboard_id = ?',
            Bind => [
                \$Param{'PositionX'}, \$Param{'PositionY'}, \$Param{'CardWidth'}, \$Param{'CardHeight'}, \$Param{'CardID'}, \$Param{DashboardID}
            ],
        );
    }

    return 1;
}

sub CardPositionSizeGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{DashboardID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need DashboardID!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # ask the database
    return if !$DBObject->Prepare(
        SQL => 'SELECT card_id, kpi_id, content_template, card_type, position_x, position_y, width, height '
            . 'FROM kpi_dashboard_card WHERE dashboard_id = ?',
        Bind => [ \$Param{DashboardID} ],
    );

    # fetch the result
    my @Cards;

    while ( my @Data = $DBObject->FetchrowArray() ) {
        
        push @Cards, {
            CardID          => $Data[0],
            KPIID           => $Data[1],
            ContentTemplate => $Data[2],
            CardType        => $Data[3],
            PositionX       => $Data[4],
            PositionY       => $Data[5],
            Width           => $Data[6],
            Height          => $Data[7],
        };
    }

    return @Cards;
}

sub CardIDExistsCheck {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    return if !$DBObject->Prepare(
        SQL  => 'SELECT card_id FROM kpi_dashboard_card WHERE dashboard_id = ? AND card_id = ?',
        Bind => [ \$Param{DashboardID}, \$Param{'CardID'} ],
        Limit => 1
    );

    # fetch the result
    my $CardID;
    while ( my @Row = $DBObject->FetchrowArray() ) {

        $CardID = $Row[0];        
    }
    
    return $CardID;
}

sub GetChartsData {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{SQL} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need SQL!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    return if !$DBObject->Prepare(
        SQL  => $Param{SQL},
    );

    my @Rows;
	my $MatchesFound;

    my @Head = $DBObject->GetColumnNames();

    ROW:
    while ( my @Row = $DBObject->FetchrowArray( RowNames => 1 ) ) {

        $MatchesFound++;

        push @Rows, \@Row;
    }

    my %DataSQLChart = (
        Rows => \@Rows,
        Head => \@Head
    );

    return \%DataSQLChart;
}

=head2 DeleteCard()

# delete card

    my $Sucess = $DashboardObject->DeleteCard(
        CardID      => 2
        DashboardID => 13
    );

Return:
    $Success = 1 | 0
    
=cut

sub DeleteCard {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(DashboardID CardID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need $Argument!',
            );
            return;
        }
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # create new db record
    return if !$DBObject->Do(
        SQL => 'DELETE FROM kpi_dashboard_card WHERE dashboard_id = ? AND card_id = ?',
        Bind => [
            \$Param{DashboardID}, \$Param{CardID}
        ],
    );

    return 1;
}

=head2 SaveDashboardSettings()

# save dashboard settings

    my $Sucess = $DashboardObject->SaveDashboardSettings(
        %GetParam
    );

Return:
    $Success = 1 | 0
    
=cut

sub SaveDashboardSettings {
    my ( $Self, %Param ) = @_;

     my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    my $Settings = $JSONObject->Encode(
        Data     => {
            DashboardBG => $Param{DashboardBG}, 
            CardBG => $Param{CardBG}
        }
    );

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # save dashboard settings
    return if !$DBObject->Do(
            SQL => 'UPDATE kpi_dashboard SET settings = ? WHERE id = ?',
            Bind => [
                \$Settings, \$Param{DashboardID}
            ],
    );

    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );

    return 1;
}

1;