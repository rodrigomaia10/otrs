# --
# var/packagesetup/KPI.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package var::packagesetup::KPI;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use List::Util qw(min);

our @ObjectDependencies = (
    'Kernel::System::SysConfig',
	'Kernel::System::Log',
	'Kernel::Config',
    'Kernel::System::Dashboard::Dashboard',
    'Kernel::System::KPI',
);

=head1 NAME

KPI.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions of package KPI

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
    my $Result = $CodeObject->CodeInstall();
=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

	$Self->_AddDefaultTemplate();
	$Self->_AddDashboardDefault();

    return 1;
}

sub _AddDefaultTemplate {
	my ( $Self, %Param ) = @_;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');

	my %Setting = $SysConfigObject->SettingGet(
		Name => "StandardTemplate::Types",
	);

    $Setting{EffectiveValue}{KPIScheduler} = 'KPI Scheduler';

    my $Success = $SysConfigObject->SettingsSet(
        UserID   => 1,
        Name     => 'StandardTemplate::Types',
        Comments => 'Added template type to KPI Scheduler',
        Settings => [
            {
                Name     			   => 'StandardTemplate::Types',
                EffectiveValue         => $Setting{EffectiveValue},
                IsValid                => 1,
                UserModificationActive => 0,
            },
        ],
    );

    my $ID = $StandardTemplateObject->StandardTemplateAdd(
        Name         => 'New KPI Scheduler',
        Template     => 'Example of email body to KPIScheduler',
        ContentType  => 'text/plain; charset=utf-8',
        TemplateType => 'KPIScheduler',                     
        ValidID      => 1,
        UserID       => 1,
    );

    return $Success;
}

sub _AddDashboardDefault {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # create KPIs
    my $Pie = '{"ReturnChart":"Pie","SQL":"select Q.name, count(*) from ticket T join queue Q on T.queue_id = Q.id group by T.queue_id LIMIT 4","Link":""}';
    $Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO kpi (name, object_type, group_ids, search, valid_id, return_format)
            VALUES ("KPI Dashboard 1", "ChartSQLQuery", "2,1", ?, "1", "Excel")',
        Bind => [\$Pie],
    );

    my $Donut = '{"ReturnChart":"Donut","SQL":"select Q.name, count(*) from ticket T join queue Q on T.queue_id = Q.id group by T.queue_id LIMIT 4","Link":""}';
    $Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO kpi (name, object_type, group_ids, search, valid_id, return_format)
            VALUES ("KPI Dashboard 2", "ChartSQLQuery", "2,1", ?, "1", "Excel")',
        Bind => [\$Donut],
    );

    my $Column = '{"ReturnChart":"Column","SQL":"select Q.name, count(*) from ticket T join queue Q on T.queue_id = Q.id group by T.queue_id LIMIT 4","Link":""}';
    $Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO kpi (name, object_type, group_ids, search, valid_id, return_format)
            VALUES ("KPI Dashboard 3", "ChartSQLQuery", "2,1", ?, "1", "Excel")',
        Bind => [\$Column],
    );

    my $Bar = '{"ReturnChart":"Bar","SQL":"select Q.name, count(*) from ticket T join queue Q on T.queue_id = Q.id group by T.queue_id LIMIT 4","Link":""}';
    $Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO kpi (name, object_type, group_ids, search, valid_id, return_format)
            VALUES ("KPI Dashboard 4", "ChartSQLQuery", "2,1", ?, "1", "Excel")',
        Bind => [\$Column],
    );

    # get new kpi pie id
    $DBObject->Prepare(
        SQL   => 'SELECT id FROM kpi WHERE name = "KPI Dashboard 1"',
        Limit => 1,
    );

    # fetch the result
    my $PieID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $PieID = $Row[0];
    }

    # get new kpi donut id
    $DBObject->Prepare(
        SQL   => 'SELECT id FROM kpi WHERE name = "KPI Dashboard 2"',
        Limit => 1,
    );

    # fetch the result
    my $DonutID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $DonutID = $Row[0];
    }

    # get new kpi Column id
    $DBObject->Prepare(
        SQL   => 'SELECT id FROM kpi WHERE name = "KPI Dashboard 3"',
        Limit => 1,
    );

    # fetch the result
    my $ColumnID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ColumnID = $Row[0];
    }

    # get new kpi Bar id
    $DBObject->Prepare(
        SQL   => 'SELECT id FROM kpi WHERE name = "KPI Dashboard 4"',
        Limit => 1,
    );

    # fetch the result
    my $BarID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $BarID = $Row[0];
    }

    # create dashboard
    my $SETTINGS = '{"DashboardBG":"#dce1e4","CardBG":"#ffffff"}';
    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard (name, available, customer_id, group_ids, valid_id, settings, create_time, change_time) VALUES ("Dashboard Default", "AgentInterface", "", "2,1", "1", ?, current_timestamp, current_timestamp)',
        Bind => [\$SETTINGS],
    );

    # get new dashboard id
    $DBObject->Prepare(
        SQL   => 'SELECT id FROM kpi_dashboard WHERE name = "Dashboard Default"',
        Limit => 1,
    );

    # fetch the result
    my $ID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $ID = $Row[0];
    }

    #create cards
    my $HTML = '<div style="display:flex; height:100%; width:100%; align-items:center"><img src="https://serviceup.com.br/wp-content/uploads/2021/06/logo-serviceup.png" /><span style="font-size:50px; margin: auto">Dashboard de visão geral</span></div>';
    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, kpi_id, content_template, card_type, position_x, position_y, width, height) VALUES ("1", ?, "", ?, "HTML", "0", "0", "12", "4")',
        Bind => [\$ID, \$HTML],
    );

    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, kpi_id, content_template, card_type, position_x, position_y, width, height) VALUES ("2", ?, ?, "", "KPI", "4", "4", "8", "16")',
        Bind => [\$ID, \$ColumnID],
    );

    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, kpi_id, content_template, card_type, position_x, position_y, width, height) VALUES ("3", ?, ?, "", "KPI", "8", "20", "2", "16")',
        Bind => [\$ID, \$DonutID],
    );

    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, kpi_id, content_template, card_type, position_x, position_y, width, height) VALUES ("4", ?, ?, "", "KPI", "2", "4", "2", "16")',
        Bind => [\$ID, \$DonutID],
    );

    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, kpi_id, content_template, card_type, position_x, position_y, width, height) VALUES ("5", ?, ?, "", "KPI", "10", "20", "2", "16")',
        Bind => [\$ID, \$PieID],
    );

    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, kpi_id, content_template, card_type, position_x, position_y, width, height) VALUES ("6", ?, ?, "", "KPI", "0", "20", "5", "16")',
        Bind => [\$ID, \$BarID],
    );

    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, kpi_id, content_template, card_type, position_x, position_y, width, height) VALUES ("7", ?, ?, "", "KPI", "5", "20", "3", "16")',
        Bind => [\$ID, \$ColumnID],
    );

    $DBObject->Do(
        SQL => 'INSERT INTO kpi_dashboard_card (card_id, dashboard_ID, kpi_id, content_template, card_type, position_x, position_y, width, height) VALUES ("8", ?, ?, "", "KPI", "0", "4", "2", "16")',
        Bind => [\$ID, \$PieID],
    );

    # reset cache
    $Kernel::OM->Get('Kernel::System::Cache')->CleanUp(
        Type => $Self->{CacheType},
    );
}

=item CodeUpgrade_6_2_10()

run the code code upgrade on version 6_2_10

    my $Result = $KPI->CodeUpgrade_6_2_10();

=cut

sub CodeUpgrade_6_2_10 {
    my ( $Self, %Param ) = @_;

    # get object
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');

    # get kpi
    return if !$DBObject->Prepare(
        SQL => 'SELECT id FROM kpi',
    );

     # fetch the result
    my @KPIs;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @KPIs, $Row[0];
    }

    # To upgrade old KPIs
    for my $KPIID ( @KPIs ) {

        # get kpi
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, object_type, group_ids, search, valid_id, return_format, min, max, rules, severity_order FROM kpi WHERE id = ?',
            Bind => [ \$KPIID ],
        );

        # fetch the result
        my %KPIGet;
        while ( my @Row = $DBObject->FetchrowArray() ) {
            $KPIGet{ID}            = $Row[0];
            $KPIGet{Name}          = $Row[1];
            $KPIGet{ObjectType}    = $Row[2];
            $KPIGet{Groups}        = $Row[3];
            $KPIGet{Search}        = $JSONObject->Decode( Data => $Row[4] );
            $KPIGet{ValidID}       = $Row[5];
            $KPIGet{ReturnFormat}  = $Row[6];
            $KPIGet{MinValue}      = $Row[7];
            $KPIGet{MaxValue}      = $Row[8];
            $KPIGet{Rules}         = $JSONObject->Decode( Data => $Row[9] );
            $KPIGet{SeverityOrder} = $Row[10];
        }

        my %SearchHash = (
            Search        => $KPIGet{Search},
            Rules         => $KPIGet{Rules},
            SeverityOrder => $KPIGet{SeverityOrder},
            TypeKPI       => 'Graphic',
            MinValue      => $KPIGet{MinValue},
            MaxValue      => $KPIGet{MaxValue}
        );

        my $JSONSearch = $JSONObject->Encode(
            Data =>  \%SearchHash,
        );

        # sql
        return if !$DBObject->Do(
            SQL => 'UPDATE kpi SET name = ?, group_ids = ?, search = ?, valid_id = ?, return_format = ? WHERE id = ?',
            Bind => [
                \$KPIGet{Name}, \$KPIGet{Groups}, \$JSONSearch, \$KPIGet{ValidID}, \$KPIGet{ReturnFormat}, \$KPIID
            ],
        );
    }

    # get kpi indexes
    return if !$DBObject->Prepare(
        SQL => 'SELECT id FROM kpi_series',
    );

    # fetch the result
    my @Series;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Series, $Row[0];
    }
    
    for my $SerieID ( @Series ) {

        return if !$DBObject->Prepare(
            SQL  => 'SELECT id, name, valid_id, associated_kpi, groupids FROM kpi_series WHERE id = ?',
            Bind => [ \$SerieID ],
        );

       # fetch the result
        my %SerieGet;
        while ( my @Row = $DBObject->FetchrowArray() ) {
            $SerieGet{ID}             = $Row[0];
            $SerieGet{Name}           = $Row[1];
            $SerieGet{ValidID}        = $Row[2];
            $SerieGet{AssociatedKPIs} = $Row[3];
            $SerieGet{GroupIDs}       = split /,/, $Row[4];
        }

        my  %SearchHash = (
            AssociatedKPIs => $SerieGet{AssociatedKPIs},            
        );

        my $JSONAssociatedKPIs = $JSONObject->Encode(
            Data =>  \%SearchHash,
        );

        my $SerieType = 'Simple';
        my $DefaultSerie = '0';

        # sql
        return if !$DBObject->Do(
            SQL => "UPDATE kpi_series SET name = ?, valid_id = ? , associated_kpi = ?, groupids = ?, serie_type = ?, default_serie = ?  WHERE id = ?",
            Bind => [
                \$SerieGet{Name}, \$SerieGet{ValidID}, \$JSONAssociatedKPIs, \$SerieGet{GroupIDs}, \$SerieType, \$DefaultSerie, \$SerieID, 
            ],
        );
    }

    return 1;
}

=item CodeUpgrade_6_5_16()

run the code code upgrade on version CodeUpgrade_6_5_16

    my $Result = $KPI->CodeUpgrade_6_5_16();

=cut

sub CodeUpgrade_6_5_16 {
    my ( $Self, %Param ) = @_;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');

	my %Setting = $SysConfigObject->SettingGet(
		Name => "StandardTemplate::Types",
	);

    $Setting{EffectiveValue}{KPIScheduler} = 'KPI Scheduler';

    my $Success = $SysConfigObject->SettingsSet(
        UserID   => 1,
        Name     => 'StandardTemplate::Types',
        Comments => 'Added template type to KPI Scheduler',
        Settings => [
            {
                Name     			   => 'StandardTemplate::Types',
                EffectiveValue         => $Setting{EffectiveValue},
                IsValid                => 1,
                UserModificationActive => 0,
            },
        ],
    );

    my $ID = $StandardTemplateObject->StandardTemplateAdd(
        Name         => 'New KPI Scheduler',
        Template     => 'Example of email body to KPIScheduler',
        ContentType  => 'text/plain; charset=utf-8',
        TemplateType => 'KPIScheduler',                     
        ValidID      => 1,
        UserID       => 1,
    );

    return $Success;
}

sub CodeUpgrade_6_8_27 {
    my ( $Self, %Param ) = @_;

    $Self->_AddDashboardDefault();

    return 1;
}

1;