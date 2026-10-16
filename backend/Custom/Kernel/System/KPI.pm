# --
# Kernel/System/KPI.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * dsilva@serviceup.com.br
# * gtiburtino@beonup.com.br
# * nfreitas@serviceup.com.br
# * poliveira@serviceup.com.br
# * ccresencio@serviceup.com.br
# * mtatangelo@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::KPI;

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

Kernel::System::KPI

=head1 SYNOPSIS

All KPI module functions.

=head1 PUBLIC INTERFACE

=head2 new()

create an object

    my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    my %Map = (

        AdditionalEmails        => 'SCALAR',
        Prefix                  => 'SCALAR',
        TemplateKPIID           => 'SCALAR',
        ScheduleLastRun         => 'SCALAR',
        ScheduleLastRunUnixTime => 'SCALAR',
        ValidID                 => 'SCALAR',
        ScheduleDays            => 'ARRAY',
        ScheduleMinutes         => 'ARRAY',
        ScheduleHours           => 'ARRAY',
		ScheduleDaysOfWeek		=> 'ARRAY',
		ScheduleMonth			=> 'ARRAY',
		AssociatedKPIs			=> 'ARRAY',
		AssociatedStats			=> 'ARRAY',
		GroupIDs			    => 'ARRAY',
		TypeExport			    => 'ARRAY',
    );

    $Self->{Map} = \%Map;

    # set lower if database is case sensitive
    $Self->{Lower} = '';
    if ( $Kernel::OM->Get('Kernel::System::DB')->GetDatabaseFunction('CaseSensitive') ) {
        $Self->{Lower} = 'LOWER';
    }

    return $Self;
}

=head2 KPIList()

return a KPIID list as ref array

Return
    @KPIs = [ 1, 2, 3 ]

    my $KPIs = $KPIObject->KPIList();

=cut

sub KPIList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kpi ';

    # get kpi
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return \@Data;
}

=head2 ValidKPIList()

return a KPIID list as ref array

Return
    @KPIs = [ 1, 2, 3 ]

    my $KPIs = $KPIObject->ValidKPIList();

=cut

sub ValidKPIList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kpi WHERE valid_id = 1';

    # get kpi
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return \@Data;
}

=head2 KPILookup()

return a KPIID

Return
    $KPIID = 1

    my $KPIs = $KPIObject->KPILookup(
        Name => 'KPI Name'
    );

=cut

sub KPILookup {
    my ( $Self, %Param ) = @_;

    if ( !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Name!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kpi WHERE name = ?';

    # get kpi
    return if !$DBObject->Prepare(
        SQL => $SQL,
		Bind =>[
			\$Param{Name},
		]
    );

    # fetch the result
    my $Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data = $Row[0];
    }

    return $Data;
}

=head2 KPILookupByName()

return a KPI Name

Return
    $KPIID = 1

    my $KPI = $KPIObject->KPILookupByName(
        ID => '1'
    );

=cut

sub KPILookupByName {
    my ( $Self, %Param ) = @_;

    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT name FROM kpi WHERE id = ?';

    # get kpi
    return if !$DBObject->Prepare(
        SQL => $SQL,
		Bind =>[
			\$Param{ID},
		]
    );

    # fetch the result
    my $Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data = $Row[0];
    }

    return $Data;
}

=head2 KPIDelete()

delete KPI

Return
    $Success = 1 | 0

    my $KPIs = $KPIObject->KPIDelete(
        ID => 1 # KPI ID
    );

=cut

sub KPIDelete {
    my ( $Self, %Param ) = @_;

    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM kpi WHERE id = ?',
        Bind => [
            \$Param{ID},
        ],
    );

    return 1;
}

=head2 KPISeriesDelete()

delete KPI serie

Return
    $Success = 1 | 0

    my $KPIs = $KPIObject->KPISeriesDelete(
        ID => 1 
    );

=cut

sub KPISeriesDelete {
    my ( $Self, %Param ) = @_;

    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            DELETE FROM kpi_series WHERE id = ?',
        Bind => [
            \$Param{ID},
        ],
    );

    return 1;
}

=head2 KPIGetByName()

get KPI by name

    my $KPIs = $KPIObject->KPIGetByName(
        Name => 'name',
        ValidID => 1 
    );

=cut

sub KPIGetByName {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Name!',
        );
        return;
    }

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    if($Param{ValidID}){
        # get kpi
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, object_type, group_ids, search, valid_id, return_format FROM kpi WHERE name = ? AND valid_id = ?',
            Bind => [ \$Param{Name}, \$Param{ValidID}],
        );

    }else{
        # get kpi
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, object_type, group_ids, search, valid_id, return_format FROM kpi WHERE name = ?',
            Bind => [ \$Param{Name}],
        );
    }

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        my $Values = $JSONObject->Decode( Data => $Row[4] );
    
        if($Row[2] eq 'Ticket'){

            $Data{ID}                         = $Row[0];
            $Data{Name}                       = $Row[1];
            $Data{ObjectType}                 = $Row[2];
            @{$Data{Groups}}                  = split /,/, $Row[3];
            $Data{Search}                     = $Values->{Search};
            $Data{ValidID}                    = $Row[5];
            $Data{ReturnFormat}               = $Row[6];
            $Data{MinValue}                   = $Values->{MinValue};
            $Data{MaxValue}                   = $Values->{MaxValue};
            $Data{SLARangeMinValue}           = $Values->{SLARangeMinValue};
            $Data{SLARangeMaxValue}           = $Values->{SLARangeMaxValue};
            $Data{FirstResponseRangeMinValue} = $Values->{FirstResponseRangeMinValue};
            $Data{FirstResponseRangeMaxValue} = $Values->{FirstResponseRangeMaxValue};
            $Data{Rules}                      = $Values->{Rules};
            $Data{SeverityOrder}              = $Values->{SeverityOrder};
            $Data{TypeKPI}                    = $Values->{TypeKPI};
        }else{
            $Data{SQL}        = $Values->{SQL};
            $Data{ID}            = $Row[0];
            $Data{Name}          = $Row[1];
            $Data{ObjectType}    = $Row[2];
            $Data{ValidID}       = $Row[5];
            $Data{ReturnFormat}  = $Row[6];
            @{$Data{Groups}}     = split /,/, $Row[3];
        }
	
    }
    
    return if !$Data{ID};
    return \%Data;
}

=head2 KPISeriesGetByName()

get KPI series by name

    my $KPIs = $KPIObject->KPISeriesGetByName(
        Name => 'name',
        ValidID => 1 
    );

=cut

sub KPISeriesGetByName {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Name!',
        );
        return;
    }

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    if($Param{ValidID}){

        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, valid_id, associated_kpi, groupids, serie_type, default_serie FROM kpi_series WHERE name = ? AND valid_id = ?',
            Bind => [ \$Param{Name}, \$Param{ValidID}],
        );

    }else{
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, valid_id, associated_kpi, groupids, serie_type, default_serie FROM kpi_series WHERE name = ?',
            Bind => [ \$Param{Name}],
        );
    }

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        my $Values = $JSONObject->Decode( Data => $Row[3] );

        if($Row[5] eq 'Simple'){
            $Data{ID}             = $Row[0];
            $Data{Name}           = $Row[1];
            $Data{ValidID}        = $Row[2];
            $Data{GroupIDs}       = $Row[4];
            $Data{AssociatedKPIs}  = $Values->{AssociatedKPIs};
            $Data{SerieType}  = $Row[5];
            $Data{DefaultSerie}  = $Row[6];

        }else{
            $Data{ID}             = $Row[0];
            $Data{Name}           = $Row[1];
            $Data{ValidID}        = $Row[2];
            $Data{GroupIDs}       = $Row[4];
            $Data{SerieType}      = $Row[5];
            $Data{DefaultSerie}  = $Row[6];

            $Data{QtdColumn} = $Values->{QtdColumn};
            $Data{AssociatedKPIsCol1} = $Values->{AssociatedKPIsCol1};
            $Data{AssociatedKPIsCol2}= $Values->{AssociatedKPIsCol2};
            $Data{AssociatedKPIsCol3} = $Values->{AssociatedKPIsCol3};
            $Data{AssociatedKPIsChartSQLCol1} = $Values->{AssociatedKPIsChartSQLCol1};    
            $Data{AssociatedKPIsChartSQLCol2} = $Values->{AssociatedKPIsChartSQLCol2};    
            $Data{AssociatedKPIsChartSQLCol3} = $Values->{AssociatedKPIsChartSQLCol3};
            $Data{ChartTypeCol1} = $Values->{ChartTypeCol1};
            $Data{ChartTypeCol2} = $Values->{ChartTypeCol2};
            $Data{ChartTypeCol3} = $Values->{ChartTypeCol3};
            $Data{TitleCol1} = $Values->{TitleCol1};
            $Data{TitleCol2} = $Values->{TitleCol2};
            $Data{TitleCol3} = $Values->{TitleCol3};
            $Data{TitleChartSQLCol1} = $Values->{TitleChartSQLCol1};   
            $Data{TitleChartSQLCol2} = $Values->{TitleChartSQLCol2};   
            $Data{TitleChartSQLCol3} = $Values->{TitleChartSQLCol3};
            $Data{TypeLabelCol1} = $Values->{TypeLabelCol1};
            $Data{TypeLabelCol2} = $Values->{TypeLabelCol2};
            $Data{TypeLabelCol3} = $Values->{TypeLabelCol3};
            $Data{TypeLabelChartSQLCol1} = $Values->{TypeLabelChartSQLCol1};    
            $Data{TypeLabelChartSQLCol2} = $Values->{TypeLabelChartSQLCol2};    
            $Data{TypeLabelChartSQLCol3} = $Values->{TypeLabelChartSQLCol3};
            $Data{ChartScaleTimeCol1} = $Values->{ChartScaleTimeCol1};
            $Data{ChartScaleTimeCol2} = $Values->{ChartScaleTimeCol2};
            $Data{ChartScaleTimeCol3} = $Values->{ChartScaleTimeCol3};
            $Data{ChartScaleUnitCol1} = $Values->{ChartScaleUnitCol1};
            $Data{ChartScaleUnitCol2} = $Values->{ChartScaleUnitCol2};
            $Data{ChartScaleUnitCol3} = $Values->{ChartScaleUnitCol3};

        }
	
    }


    return if !$Data{ID};
    return \%Data;
}

=head2 KPIGet()

get KPI

Return
    %KPI = {
        ID                         => 1,
        Name                       => 'KPI Name',
        ObjectType                 => 'Ticket',
        Groups                     => ['admin', 'users'],
        Search                     => JSON string for search
        ValidID                    => 1
        ReturnFormat               => 'normal' # options ('normal' | 'excel')
        MinValue                   => '0'
        MaxValue                   => '50'
        SLARangeMinValue           => '0'
        SLARangeMaxValue           => '50'
        FirstResponseRangeMinValue => '0'
        FirstResponseRangeMaxValue => '50'
        Rules                      => JSON string for rules
        SeverityOrder              => 'Ascending' # options ('Ascending' | 'Descendant')
    }

    my $KPIs = $KPIObject->KPIGet(
        ID => 1, # KPI ID
        ValidID => 1 
    );

=cut

sub KPIGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    if($Param{ValidID}){
        # get kpi
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, object_type, group_ids, search, valid_id, return_format FROM kpi WHERE id = ? AND valid_id = ?',
            Bind => [ \$Param{ID}, \$Param{ValidID}],
        );

    }else{
        # get kpi
        return if !$DBObject->Prepare(
            SQL => 'SELECT id, name, object_type, group_ids, search, valid_id, return_format FROM kpi WHERE id = ? ',
            Bind => [ \$Param{ID} ],
        );
    }

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        my $Values = $JSONObject->Decode( Data => $Row[4] );
    
        if($Row[2] eq 'Ticket'){

            $Data{ID}                         = $Row[0];
            $Data{Name}                       = $Row[1];
            $Data{ObjectType}                 = $Row[2];
            @{$Data{Groups}}                  = split /,/, $Row[3];
            $Data{Search}                     = $Values->{Search};
            $Data{ValidID}                    = $Row[5];
            $Data{ReturnFormat}               = $Row[6];
            $Data{MinValue}                   = $Values->{MinValue};
            $Data{MaxValue}                   = $Values->{MaxValue};
            $Data{SLARangeMinValue}           = $Values->{SLARangeMinValue};
            $Data{SLARangeMaxValue}           = $Values->{SLARangeMaxValue};
            $Data{FirstResponseRangeMinValue} = $Values->{FirstResponseRangeMinValue};
            $Data{FirstResponseRangeMaxValue} = $Values->{FirstResponseRangeMaxValue};
            $Data{Rules}                      = $Values->{Rules};
            $Data{SeverityOrder}              = $Values->{SeverityOrder};
            $Data{TypeKPI}                    = $Values->{TypeKPI};
            $Data{Color}                      = $Values->{Color};
            $Data{Link}                       = $Values->{Link};
        }
        elsif ($Row[2] eq  'SQL Query'){
            $Data{SQL}        = $Values->{SQL};
            $Data{Link}        = $Values->{Link};
            $Data{ID}            = $Row[0];
            $Data{Name}          = $Row[1];
            $Data{ObjectType}    = $Row[2];
            $Data{ValidID}       = $Row[5];
            $Data{ReturnFormat}  = $Row[6];
            @{$Data{Groups}}     = split /,/, $Row[3];
        }
        elsif ($Row[2] eq  'Survey'){
            $Data{SurveyID}      = $Values->{SurveyID};
            $Data{QuestionID}    = $Values->{QuestionID};
            $Data{AnswerID}      = $Values->{AnswerID};
            $Data{Metric}        = $Values->{Metric};
            $Data{StartDateVoteTime}    = $Values->{StartDateVoteTime};
            $Data{StopDateVoteTime}     = $Values->{StopDateVoteTime};
            $Data{VoteTimeSearchType}   = $Values->{VoteTimeSearchType};
            $Data{StartDateCreateTime}    = $Values->{StartDateCreateTime};
            $Data{StopDateCreateTime}     = $Values->{StopDateCreateTime};
            $Data{CreateTimeSearchType}   = $Values->{CreateTimeSearchType};
            $Data{StartDateSendTime}    = $Values->{StartDateSendTime};
            $Data{StopDateSendTime}     = $Values->{StopDateSendTime};
            $Data{SendTimeSearchType}   = $Values->{SendTimeSearchType};
            $Data{ID}            = $Row[0];
            $Data{Name}          = $Row[1];
            $Data{ObjectType}    = $Row[2];
            $Data{ValidID}       = $Row[5];
            $Data{ReturnFormat}  = $Row[6];
            @{$Data{Groups}}     = split /,/, $Row[3];
        }
        elsif ($Row[2] eq  'Config Items'){
            $Data{ID}            = $Row[0];
            #$Data{NameKPI}       = $Row[1];
            $Data{Name}          = $Row[1];
            $Data{ObjectType}    = $Row[2];
            @{$Data{Groups}}     = split /,/, $Row[3];
            $Data{Search}        = $Values->{Search};
            $Data{ClassID}       = $Values->{ClassID};
            $Data{ValidID}       = $Row[5];
            $Data{ReturnFormat}  = $Row[6];     
        }
        elsif ($Row[2] eq  'ChartSQLQuery'){
            $Data{SQL}              = $Values->{SQL};
            $Data{Link}             = $Values->{Link};
            $Data{ReturnChart}      = $Values->{ReturnChart};
            $Data{DisplayTextChart} = $Values->{DisplayTextChart};
            $Data{ID}               = $Row[0];
            $Data{Name}             = $Row[1];
            $Data{ObjectType}       = $Row[2];
            $Data{ValidID}          = $Row[5];
            $Data{ReturnFormat}     = $Row[6];
            @{$Data{Groups}}        = split /,/, $Row[3];
        }
    }
    
    return \%Data;
}

=head2 KPIUpdate()

update KPI

Return
    $Success = 1 | 0

    my $KPIs = $KPIObject->KPIUpdate(
        ID                         => 1, # KPI iD
        Name                       => 'KPI Name',
        ObjectType                 => 'Ticket',
        Groups                     => ['admin', 'users'],
        Search                     => JSON string for search
        ValidID                    => 1
        ReturnFormat               => 'normal' # options ('normal' | 'excel')
        MinValue                   => '0'
        MaxValue                   => '50'
        SLARangeMinValue           => '0'
        SLARangeMaxValue           => '50'
        FirstResponseRangeMinValue => '0'
        FirstResponseRangeMaxValue => '50'
        Rules                      => JSON string for rules
        SeverityOrder              => 'Ascending' # options ('Ascending' | 'Descendant')
    );

=cut

sub KPIUpdate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(ID)) {
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

    my %SearchHash;

    if($Param{ObjectType} eq 'Ticket'){

        %SearchHash = (
            Search                     => $Param{Search},
            Rules                      => $Param{Rules},
            SeverityOrder              => $Param{SeverityOrder},
            TypeKPI                    => $Param{TypeKPI},
            MinValue                   => $Param{MinValue},
            MaxValue                   => $Param{MaxValue},
            SLARangeMinValue           => $Param{SLARangeMinValue},   
            SLARangeMaxValue           => $Param{SLARangeMaxValue},     
            FirstResponseRangeMinValue => $Param{FirstResponseRangeMinValue},
            FirstResponseRangeMaxValue => $Param{FirstResponseRangeMaxValue},
            Color                      => $Param{Color},
            Link                       => $Param{Link}
        );

    }
    elsif ($Param{ObjectType} eq 'SQL Query'){

        %SearchHash = (
            SQL => $Param{SQL},
            Link => $Param{Link},
        );
    }
    elsif ($Param{ObjectType} eq 'Survey'){

        %SearchHash = (
            SurveyID   => $Param{SurveyID},
            QuestionID => $Param{QuestionID},
            AnswerID   => $Param{AnswerID},
            Metric     => $Param{Metric},
            StartDateVoteTime    => $Param{StartDateVoteTime},
            StopDateVoteTime     => $Param{StopDateVoteTime},
            VoteTimeSearchType   => $Param{VoteTimeSearchType},
            StartDateCreateTime    => $Param{StartDateCreateTime},
            StopDateCreateTime     => $Param{StopDateCreateTime},
            CreateTimeSearchType   => $Param{CreateTimeSearchType},
            StartDateSendTime    => $Param{StartDateSendTime},
            StopDateSendTime     => $Param{StopDateSendTime},
            SendTimeSearchType   => $Param{SendTimeSearchType},
        );
    }
    elsif ($Param{ObjectType} eq 'Config Items'){
        %SearchHash = (
            Search => $Param{Search},
            ClassID => $Param{ClassID}
        );

        # if($Param{NameKPI}){
        #     $Param{Name} = $Param{NameKPI};
        # }
    }
    elsif ($Param{ObjectType} eq 'ChartSQLQuery'){

        %SearchHash = (
            SQL              => $Param{SQL},
            Link             => $Param{Link},
            ReturnChart      => $Param{ReturnChart},
            DisplayTextChart => $Param{DisplayTextChart},
        );
    }

	my $JSONSearch = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->JSONEncode(
        Data        =>  \%SearchHash,
    );

    # check if Name already exists
    return if !$DBObject->Prepare(
        SQL => "
            SELECT id FROM kpi
            WHERE $Self->{Lower}(name) = $Self->{Lower}(?)
            AND id != ?",
        Bind  => [ \$Param{Name}, \$Param{ID} ],
        LIMIT => 1,
    );

    my $KPIExists;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        $KPIExists = 1;
    }

    if ($KPIExists) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "An KPI with the name '$Param{Name}' already exists.",
        );
        return;
    }

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE kpi SET name = ?, group_ids = ?, search = ?, valid_id = ?, return_format = ? WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{GroupIDs}, \$JSONSearch, \$Param{ValidID}, \$Param{ReturnFormat}, \$Param{ID}
        ],
    );

    return 1;
}

=head2 KPIAdd()

add KPI

Return
    $Success = 1 | 0

    my $KPIs = $KPIObject->KPIAdd(
        Name                       => 'KPI Name',
        ObjectType                 => 'Ticket',
        Groups                     => ['admin', 'users'],
        Search                     => JSON string for search
        ValidID                    => 1
        ReturnFormat               => 'normal' # options ('normal' | 'excel')
        MinValue                   => '0'
        MaxValue                   => '50'
        SLARangeMinValue           => '0'
        SLARangeMaxValue           => '50'
        FirstResponseRangeMinValue => '0'
        FirstResponseRangeMaxValue => '50'
        Rules                      => JSON string for rules
        SeverityOrder              => 'Ascending' # options ('Ascending' | 'Descendant')
    );

=cut

sub KPIAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    # for my $Argument (qw(Name)) {
    #     if ( !$Param{$Argument} ) {
    #         $Kernel::OM->Get('Kernel::System::Log')->Log(
    #             Priority => 'error',
    #             Message  => 'Need $Argument!',
    #         );
    #         return;
    #     }
    # }

    my %SearchHash;

    if($Param{ObjectType} eq 'Ticket'){

        %SearchHash = (
            Search                     => $Param{Search},
            Rules                      => $Param{Rules},
            SeverityOrder              => $Param{SeverityOrder},
            TypeKPI                    => $Param{TypeKPI},
            MinValue                   => $Param{MinValue},
            MaxValue                   => $Param{MaxValue},
            SLARangeMinValue           => $Param{SLARangeMinValue},   
            SLARangeMaxValue           => $Param{SLARangeMaxValue},     
            FirstResponseRangeMinValue => $Param{FirstResponseRangeMinValue},
            FirstResponseRangeMaxValue => $Param{FirstResponseRangeMaxValue},
            Color                      => $Param{Color},
            Link                       => $Param{Link},
        );

    }
    elsif ($Param{ObjectType} eq 'SQL Query'){

        %SearchHash = (
            SQL => $Param{SQL},
            Link => $Param{Link},
        );
    }
    elsif ($Param{ObjectType} eq 'Survey'){

        %SearchHash = (
            SurveyID   => $Param{SurveyID},
            QuestionID => $Param{QuestionID},
            AnswerID   => $Param{AnswerID},
            Metric     => $Param{Metric},
            StartDateVoteTime      => $Param{StartDateVoteTime},
            StopDateVoteTime       => $Param{StopDateVoteTime},
            VoteTimeSearchType     => $Param{VoteTimeSearchType},            
            StartDateCreateTime    => $Param{StartDateCreateTime},
            StopDateCreateTime     => $Param{StopDateCreateTime},
            CreateTimeSearchType   => $Param{CreateTimeSearchType},
            StartDateSendTime      => $Param{StartDateSendTime},
            StopDateSendTime       => $Param{StopDateSendTime},
            SendTimeSearchType     => $Param{SendTimeSearchType},
        );
    }
    elsif ($Param{ObjectType} eq 'Config Items'){
        %SearchHash = (
            Search => $Param{Search},
            ClassID => $Param{ClassID}
        );

        # if($Param{NameKPI}){
        #     $Param{Name} = $Param{NameKPI};
        # }
    }
    elsif ($Param{ObjectType} eq 'ChartSQLQuery'){

        %SearchHash = (
            SQL              => $Param{SQL},
            Link             => $Param{Link},
            ReturnChart      => $Param{ReturnChart},
            DisplayTextChart => $Param{DisplayTextChart}
        );
    }    

	my $JSONSearch = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->JSONEncode(
        Data        =>  \%SearchHash,
    );

    # check if KPI with this name already exists
    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL => "
            SELECT id
            FROM kpi
            WHERE $Self->{Lower}(name) = $Self->{Lower}(?)",
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    my $KPIExists;
    while ( my @Data = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $KPIExists = 1;
    }

    if ($KPIExists) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "An KPI with the name '$Param{Name}' already exists.",
        );
        return;
    }


    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => '
            INSERT INTO kpi (name, object_type, group_ids, search, valid_id, return_format)
            VALUES (?, ?, ?, ?, ?, ?)',
        Bind => [
            \$Param{Name}, \$Param{ObjectType}, \$Param{GroupIDs}, \$JSONSearch, \$Param{ValidID}, \$Param{ReturnFormat}
        ],
    );

    return 1;
}

=head2 SeriesList()

return a series list as array

Return
    @KPIs = ( 1, 2, 3 )

    my $KPIs = $KPIObject->SeriesList();

=cut

sub SeriesList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kpi_series ';

    # get kpi indexes
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return @Data;
}

=head2 SeriesListDefault()

return a series default list as array 

Return
    @KPIs = ( 1, 2, 3 )

    my $KPIs = $KPIObject->SeriesListDefault();

=cut

sub SeriesListDefault {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = "SELECT id FROM kpi_series WHERE default_serie = 1 AND valid_id = 1 ";

    # get kpi indexes
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return @Data;
}


=head2 ValidSeriesList()

return a series list as array

Return
    @KPIs = ( 1, 2, 3 )

    my $KPIs = $KPIObject->ValidSeriesList();

=cut

sub ValidSeriesList {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

	my $SQL = 'SELECT id FROM kpi_series WHERE valid_id = 1';

    # get kpi indexes
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		push @Data, $Row[0];
    }

    return @Data;
}

=head2 SeriesLookup()

return a SeriesID

Return
    $SeriesID = 1

    my $KPIs = $KPIObject->SeriesLookup(
        Name => 'Series'
    );

=cut

sub SeriesLookup {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{Name} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need Name!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get kpi
    return if !$DBObject->Prepare(
        SQL => 'SELECT id FROM kpi_series WHERE name = ?',
		Bind =>[ \$Param{Name} ]
    );

    # fetch the result
    my $Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data = $Row[0];
    }

    return $Data;
}

=head2 SeriesGet()

get Series

Return
    %Series = {
        ID             => 1,
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedKPIs => '1,2,3,4', # KPIIDs associated
        GroupIDs       => '1,2,3,4', # GroupIDs associated
    }

    my $Series = $KPIObject->SeriesGet(
        ID => 1 # SeriesID
    );

=cut

sub SeriesGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    # get kpi
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, valid_id, associated_kpi, groupids, serie_type, default_serie FROM kpi_series WHERE id = ?',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        my $Values = $JSONObject->Decode( Data => $Row[3] );


        if($Row[5] eq 'Simple'){
            $Data{ID}             = $Row[0];
            $Data{Name}           = $Row[1];
            $Data{ValidID}        = $Row[2];
            $Data{GroupIDs}       = $Row[4];
            $Data{AssociatedKPIs}  = $Values->{AssociatedKPIs};
            $Data{SerieType}  = $Row[5];
            $Data{DefaultSerie}  = $Row[6];

        }else{
            $Data{ID}             = $Row[0];
            $Data{Name}           = $Row[1];
            $Data{ValidID}        = $Row[2];
            $Data{GroupIDs}       = $Row[4];
            $Data{SerieType}      = $Row[5];
            $Data{DefaultSerie}  = $Row[6];

            $Data{QtdColumn} = $Values->{QtdColumn};
            $Data{AssociatedKPIsCol1} = $Values->{AssociatedKPIsCol1};
            $Data{AssociatedKPIsCol2}= $Values->{AssociatedKPIsCol2};
            $Data{AssociatedKPIsCol3} = $Values->{AssociatedKPIsCol3};
            $Data{AssociatedKPIsChartSQLCol1} = $Values->{AssociatedKPIsChartSQLCol1};    
            $Data{AssociatedKPIsChartSQLCol2} = $Values->{AssociatedKPIsChartSQLCol2};    
            $Data{AssociatedKPIsChartSQLCol3} = $Values->{AssociatedKPIsChartSQLCol3}; 
            $Data{ChartTypeCol1} = $Values->{ChartTypeCol1};
            $Data{ChartTypeCol2} = $Values->{ChartTypeCol2};
            $Data{ChartTypeCol3} = $Values->{ChartTypeCol3};
            $Data{TitleCol1} = $Values->{TitleCol1};
            $Data{TitleCol2} = $Values->{TitleCol2};
            $Data{TitleCol3} = $Values->{TitleCol3};
            $Data{TitleChartSQLCol1} = $Values->{TitleChartSQLCol1};   
            $Data{TitleChartSQLCol2} = $Values->{TitleChartSQLCol2};   
            $Data{TitleChartSQLCol3} = $Values->{TitleChartSQLCol3};
            $Data{TypeLabelCol1} = $Values->{TypeLabelCol1};
            $Data{TypeLabelCol2} = $Values->{TypeLabelCol2};
            $Data{TypeLabelCol3} = $Values->{TypeLabelCol3};
            $Data{TypeLabelChartSQLCol1} = $Values->{TypeLabelChartSQLCol1};    
            $Data{TypeLabelChartSQLCol2} = $Values->{TypeLabelChartSQLCol2};    
            $Data{TypeLabelChartSQLCol3} = $Values->{TypeLabelChartSQLCol3}; 
            $Data{ChartScaleTimeCol1} = $Values->{ChartScaleTimeCol1};
            $Data{ChartScaleTimeCol2} = $Values->{ChartScaleTimeCol2};
            $Data{ChartScaleTimeCol3} = $Values->{ChartScaleTimeCol3};
            $Data{ChartScaleUnitCol1} = $Values->{ChartScaleUnitCol1};
            $Data{ChartScaleUnitCol2} = $Values->{ChartScaleUnitCol2};
            $Data{ChartScaleUnitCol3} = $Values->{ChartScaleUnitCol3};

        }
	
    }

    return \%Data;
}

=head2 SeriesAdd()

add series

Return
    $Success = 1 | 0

    my $KPIs = $KPIObject->SeriesAdd(
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedKPIs => '1,2,3,4', # KPIIDs associated
        GroupIDs       => '1,2,3,4', # GroupIDs associated
        SerieType       => 'Simple', 
        QtdColumn => '1',
        AssociatedKPIsCol1 => '1,2,3,4',           
        AssociatedKPIsCol2 => '1,2,3,4',            
        AssociatedKPIsCol3 => '1,2,3,4',
        ChartTypeCol1 => 'bar' , 
        ChartTypeCol2 => 'bar', 
        ChartTypeCol3 => 'bar' 
        TitleCol1  => 'Teste'
        TitleCol2  => 'Teste'
        TitleCol3  => 'Teste'
        TypeLabelCol1  => 'Teste'
        TypeLabelCol2  => 'Teste'
        TypeLabelCol3  => 'Teste'
        DefaultSerie => '1' | '0'
    );

=cut

sub SeriesAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    my %SearchHash;

    if($Param{SerieType} eq 'Simple'){

        %SearchHash = (
            AssociatedKPIs => $Param{AssociatedKPIs},            
        );

    }else{

        %SearchHash = (
            QtdColumn => $Param{QtdColumn},
            AssociatedKPIsCol1 => $Param{AssociatedKPIsCol1},            
            AssociatedKPIsCol2 => $Param{AssociatedKPIsCol2},            
            AssociatedKPIsCol3 => $Param{AssociatedKPIsCol3},    
            AssociatedKPIsChartSQLCol1 => $Param{AssociatedKPIsChartSQLCol1},    
            AssociatedKPIsChartSQLCol2 => $Param{AssociatedKPIsChartSQLCol2},    
            AssociatedKPIsChartSQLCol3 => $Param{AssociatedKPIsChartSQLCol3},    
            ChartTypeCol1 => $Param{ChartTypeCol1},    
            ChartTypeCol2 => $Param{ChartTypeCol2},    
            ChartTypeCol3 => $Param{ChartTypeCol3},  
            TitleCol1 => $Param{TitleCol1},    
            TitleCol2 => $Param{TitleCol2},    
            TitleCol3 => $Param{TitleCol3},    
            TitleChartSQLCol1 => $Param{TitleChartSQLCol1},   
            TitleChartSQLCol2 => $Param{TitleChartSQLCol2},   
            TitleChartSQLCol3 => $Param{TitleChartSQLCol3},   
            TypeLabelCol1 => $Param{TypeLabelCol1},    
            TypeLabelCol2 => $Param{TypeLabelCol2},    
            TypeLabelCol3 => $Param{TypeLabelCol3},    
            TypeLabelChartSQLCol1 => $Param{TypeLabelChartSQLCol1},    
            TypeLabelChartSQLCol2 => $Param{TypeLabelChartSQLCol2},    
            TypeLabelChartSQLCol3 => $Param{TypeLabelChartSQLCol3},    
            ChartScaleTimeCol1 => $Param{ChartScaleTimeCol1},    
            ChartScaleTimeCol2 => $Param{ChartScaleTimeCol2},    
            ChartScaleTimeCol3 => $Param{ChartScaleTimeCol3},    
            ChartScaleUnitCol1 => $Param{ChartScaleUnitCol1},    
            ChartScaleUnitCol2 => $Param{ChartScaleUnitCol2},    
            ChartScaleUnitCol3 => $Param{ChartScaleUnitCol3},    
            
        );
    }

	my $JSONAssociatedKPIs = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->JSONEncode(
        Data        =>  \%SearchHash,
    );

    # for postgreSQL
    if( $Param{DefaultSerie} eq '' ){
        $Param{DefaultSerie} = 0;
    }

    # check if KPI with this name already exists
    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL => "
            SELECT id
            FROM kpi_series
            WHERE $Self->{Lower}(name) = $Self->{Lower}(?)",
        Bind  => [ \$Param{Name} ],
        Limit => 1,
    );

    my $KPIExists;
    while ( my @Data = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $KPIExists = 1;
    }

    if ($KPIExists) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "An KPI serie with the name '$Param{Name}' already exists.",
        );
        return;
    }

    # create new db record
    return if !$Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL => 'INSERT INTO kpi_series (name, valid_id, associated_kpi, groupids, serie_type, default_serie) VALUES (?, ?, ?, ?, ?, ?)',
        Bind => [
            \$Param{Name}, \$Param{ValidID}, \$JSONAssociatedKPIs, \$Param{GroupIDs}, \$Param{SerieType}, \$Param{DefaultSerie}
        ],
    );

    return 1;
}

=head2 SeriesUpdate()

update series

Return
    $Success = 1 | 0

    my $KPIs = $KPIObject->SeriesUpdate(
        ID             => 1, # SeriesID
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedKPIs => '1,2,3,4', # KPIIDs associated
        GroupIDs       => '1,2,3,4', # GroupIDs associated
        QtdColumn => '1',
        AssociatedKPIsCol1 => '1,2,3,4',           
        AssociatedKPIsCol2 => '1,2,3,4',            
        AssociatedKPIsCol3 => '1,2,3,4',
        ChartTypeCol1 => 'bar' , 
        ChartTypeCol2 => 'bar', 
        ChartTypeCol3 => 'bar',
        TitleCol1 => 'Title',
        TitleCol2 => 'Title',
        TitleCol3 => 'Title',
        TypeLabelCol1 => 'Title',
        TypeLabelCol2 => 'Title',
        TypeLabelCol3 => 'Title',
        SerieType =>  'Simple',
        DefaultSerie => '1' | '0'
    );

=cut

sub SeriesUpdate {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # check needed stuff
    for my $Argument (qw(ID Name ValidID)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    my %SearchHash;

    if($Param{SerieType} eq 'Simple'){

        %SearchHash = (
            AssociatedKPIs => $Param{AssociatedKPIs},            
        );

    }else{

        %SearchHash = (
            QtdColumn => $Param{QtdColumn},
            AssociatedKPIsCol1 => $Param{AssociatedKPIsCol1},            
            AssociatedKPIsCol2 => $Param{AssociatedKPIsCol2},            
            AssociatedKPIsCol3 => $Param{AssociatedKPIsCol3},
            AssociatedKPIsChartSQLCol1 => $Param{AssociatedKPIsChartSQLCol1},    
            AssociatedKPIsChartSQLCol2 => $Param{AssociatedKPIsChartSQLCol2},    
            AssociatedKPIsChartSQLCol3 => $Param{AssociatedKPIsChartSQLCol3},    
            ChartTypeCol1 => $Param{ChartTypeCol1},    
            ChartTypeCol2 => $Param{ChartTypeCol2},    
            ChartTypeCol3 => $Param{ChartTypeCol3},  
            TitleCol1 => $Param{TitleCol1},
            TitleCol2 => $Param{TitleCol2},
            TitleCol3 => $Param{TitleCol3},
            TitleChartSQLCol1 => $Param{TitleChartSQLCol1},   
            TitleChartSQLCol2 => $Param{TitleChartSQLCol2},   
            TitleChartSQLCol3 => $Param{TitleChartSQLCol3},
            TypeLabelCol1 => $Param{TypeLabelCol1},
            TypeLabelCol2 => $Param{TypeLabelCol2},
            TypeLabelCol3 => $Param{TypeLabelCol3},
            TypeLabelChartSQLCol1 => $Param{TypeLabelChartSQLCol1},    
            TypeLabelChartSQLCol2 => $Param{TypeLabelChartSQLCol2},    
            TypeLabelChartSQLCol3 => $Param{TypeLabelChartSQLCol3},
            ChartScaleTimeCol1 => $Param{ChartScaleTimeCol1},    
            ChartScaleTimeCol2 => $Param{ChartScaleTimeCol2},    
            ChartScaleTimeCol3 => $Param{ChartScaleTimeCol3},    
            ChartScaleUnitCol1 => $Param{ChartScaleUnitCol1},    
            ChartScaleUnitCol2 => $Param{ChartScaleUnitCol2},    
            ChartScaleUnitCol3 => $Param{ChartScaleUnitCol3},    
        );
    }

	my $JSONAssociatedKPIs = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->JSONEncode(
        Data        =>  \%SearchHash,
    );

    # check if Name already exists
    return if !$DBObject->Prepare(
        SQL => "
            SELECT id FROM kpi_series
            WHERE $Self->{Lower}(name) = $Self->{Lower}(?)
            AND id != ?",
        Bind  => [ \$Param{Name}, \$Param{ID} ],
        LIMIT => 1,
    );

    my $KPIExists;
    while ( my @Data = $DBObject->FetchrowArray() ) {
        $KPIExists = 1;
    }

    if ($KPIExists) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "An KPI serie with the name '$Param{Name}' already exists.",
        );
        return;
    }

    # sql
    return if !$DBObject->Do(
        SQL => 'UPDATE kpi_series SET name = ?, valid_id = ? , associated_kpi = ?, groupids = ?, serie_type = ?, default_serie = ?  WHERE id = ?',
        Bind => [
            \$Param{Name}, \$Param{ValidID}, \$JSONAssociatedKPIs, \$Param{GroupIDs}, \$Param{SerieType}, \$Param{DefaultSerie}, \$Param{ID}
        ],
    );

    return 1;
}

=head2 KPIGetOlder()

get KPI - OLD!

Return
    %KPI = {
        ID            => 1,
        Name          => 'KPI Name',
        ObjectType    => 'Ticket',
        Groups        => ['admin', 'users'],
        Search        => JSON string for search
        ValidID       => 1
        ReturnFormat  => 'normal' # options ('normal' | 'excel')
        MinValue      => '0'
        MaxValue      => '50'
        Rules         => JSON string for rules
        SeverityOrder => 'Ascending' # options ('Ascending' | 'Descendant')
    }

    my $KPIs = $KPIObject->KPIGetOlder(
        ID => 1 # KPI ID
    );

=cut

sub KPIGetOlder {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    # get kpi
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, object_type, group_ids, search, valid_id, return_format, min, max, rules, severity_order FROM kpi WHERE id = ?',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ID}            = $Row[0];
		$Data{Name}          = $Row[1];
		$Data{ObjectType}    = $Row[2];
		$Data{Groups}        = $Row[3];
		$Data{Search}        = $JSONObject->Decode( Data => $Row[4] );
		$Data{ValidID}       = $Row[5];
		$Data{ReturnFormat}  = $Row[6];
		$Data{MinValue}      = $Row[7];
		$Data{MaxValue}      = $Row[8];
		$Data{Rules}         = $JSONObject->Decode( Data => $Row[9] );
		$Data{SeverityOrder} = $Row[10];
    }

    return \%Data;
}

=head2 SeriesGetOlder()

get Series - OLD!

Return
    %Series = {
        ID             => 1,
        Name           => 'Series Name',
        ValidID        => 1
        AssociatedKPIs => '1,2,3,4', # KPIIDs associated
        GroupIDs       => '1,2,3,4', # GroupIDs associated
    }

    my $Series = $KPIObject->SeriesGetOlder(
        ID => 1 # SeriesID
    );

=cut

sub SeriesGetOlder {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ID!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # get kpi
    return if !$DBObject->Prepare(
        SQL => 'SELECT id, name, valid_id, associated_kpi, groupids FROM kpi_series WHERE id = ?',
		Bind => [ \$Param{ID} ],
    );

    # fetch the result
    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ID}             = $Row[0];
		$Data{Name}           = $Row[1];
		$Data{ValidID}        = $Row[2];
		$Data{AssociatedKPIs} = $Row[3];
		$Data{GroupIDs}       = $Row[4];
    }

    return \%Data;
}

=head2 JobAdd()

Add KPI Scheduler informations

    my $JobAddResult = $KPIObject->JobAdd(
        Name   => $Self->{Profile},
        UserID => $Self->{UserID},
        Data   => {
            %GetParam,
        },
    );

=cut
sub JobAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Name Data UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # check if job name already exists
    my %Check = $Self->JobGet( Name => $Param{Name} );
    if (%Check) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Can't add kKPI Scheduler '$Param{Name}', job already exists!",
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # insert data into db
    for my $Key ( sort keys %{ $Param{Data} } ) {
        if ( ref $Param{Data}->{$Key} eq 'ARRAY' ) {
            for my $Item ( @{ $Param{Data}->{$Key} } ) {
                if ( defined $Item ) {
                    $DBObject->Do(
                        SQL => 'INSERT INTO kpi_scheduler (job_name, job_key, job_value) VALUES (?, ?, ?)',
                        Bind => [ \$Param{Name}, \$Key, \$Item ],
                    );
                }
            }
        }
        else {
            if ( defined $Param{Data}->{$Key} ) {
                $DBObject->Do(
                    SQL => 'INSERT INTO kpi_scheduler (job_name, job_key, job_value) VALUES (?, ?, ?)',
                    Bind => [ \$Param{Name}, \$Key, \$Param{Data}->{$Key} ],
                );
            }
        }
    }

    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'notice',
        Message  => "New KPI Scheduler job '$Param{Name}' added (UserID=$Param{UserID}).",
    );

    return 1;
}

=head2 JobDelete()

Delete KPI Scheduler informations

    my $JobAddResult = $KPIObject->JobDelete(
        Name   => $Self->{OldProfile},
        UserID => $Self->{UserID},
    );

=cut
sub JobDelete {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Name UserID)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # delete job
    $Kernel::OM->Get('Kernel::System::DB')->Do(
        SQL  => 'DELETE FROM kpi_scheduler WHERE job_name = ?',
        Bind => [ \$Param{Name} ],
    );

    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'notice',
        Message  => "KPI Scheduler job '$Param{Name}' deleted (UserID=$Param{UserID}).",
    );

    return 1;
}

=item JobGet()
returns a hash of the job data
    my %Job = $KPIObject->JobGet(Name => 'JobName');
=cut

sub JobGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Name)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => '
            SELECT job_key, job_value
            FROM kpi_scheduler
            WHERE job_name = ?',
        Bind => [ \$Param{Name} ],
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        if ( $Self->{Map}->{ $Row[0] } && $Self->{Map}->{ $Row[0] } eq 'ARRAY' ) {
            push @{ $Data{ $Row[0] } }, $Row[1];
        }
        else {
            $Data{ $Row[0] } = $Row[1];
        }
    }

    # check valid
    if ( %Data && !defined $Data{Valid} ) {
        $Data{Valid} = 1;
    }
    if (%Data) {
        $Data{Name} = $Param{Name};
    }

    return %Data;
}

=item JobList()
returns a hash of the job data
    my %Job = $KPIObject->JobList();
=cut

sub JobList {
    my ( $Self, %Param ) = @_;

    # get cache object
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');

    # check cache
    # my $CacheKey = "JobList";
    # my $Cache    = $CacheObject->Get(
    #     Type => 'KPI',
    #     Key  => $CacheKey,
    # );
    # return %{$Cache} if ref $Cache;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => 'SELECT DISTINCT(job_name) FROM kpi_scheduler',
    );

    my %Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Data{ $Row[0] } = $Row[0];
    }

    # $CacheObject->Set(
    #     Type  => 'KPI',
    #     Key   => $CacheKey,
    #     Value => \%Data,
    #     TTL   => 24 * 60 * 60,
    # );

    return %Data;
}

sub JobGetLastExecution {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    
    # get service from db
    return if !$DBObject->Prepare(
        SQL  => 'SELECT * FROM kpi_scheduler_execution WHERE job_name LIKE ?',
        Bind => [ \$Param{Name} ]
    );

	# fetch the result
	my %Data;
	while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ $Row[0] } = $Row[1] . '  ' . $Row[2];
	}

	return %Data
}

sub JobLastExecution {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime'
    );

    my $DateTimeString = $DateTimeObject->Format( Format => '%Y-%m-%d %H:%M:00' );

    my $Observation = '';
    if( $Param{Obs} ){
        $Observation = $Param{Obs};
    }else{
        $Observation = '(TC)';
    }

    # get service from db
    return if !$DBObject->Prepare(
        SQL  => 'SELECT * FROM kpi_scheduler_execution WHERE job_name LIKE ?',
        Bind => [ \$Param{Name} ]
    );

	# fetch the result
	my %Data;
	while ( my @Row = $DBObject->FetchrowArray() ) {
		$Data{ $Row[0] } = $Row[1];
	}

    if( !%Data ){

        $DBObject->Do(
                        SQL => 'INSERT INTO kpi_scheduler_execution (job_name, last_execution, obs) VALUES (?, ?, ?)',
                        Bind => [ \$Param{Name}, \$DateTimeString, \$Observation ],
                    );

    }else{

        $DBObject->Do(
                        SQL => 'UPDATE kpi_scheduler_execution SET last_execution = ? WHERE job_name LIKE ?',
                        Bind => [ \$DateTimeString, \$Param{Name} ],
                    );

        $DBObject->Do(
                        SQL => 'UPDATE kpi_scheduler_execution SET obs = ? WHERE job_name LIKE ?',
                        Bind => [ \$Observation, \$Param{Name} ],
                    );

    }

	return %Data
}

=head2 GetSearchSQL()

Return the data to SearchSQL subaction, to export

    my %Result = $KPIObject->GetSearchSQL(
        KPIData   => $KPIData,
    );

Return:
    %Result = (
        Head   => \@Head,
        Data   => \@Data,
    );

=cut

sub GetSearchSQL {
    my ( $Self, %Param ) = @_;

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my @Head;
    my @Data;

    $Param{KPIData}{SQL} = $Self->ReplaceSQLAttributes(
		Message       =>  $Param{KPIData}{SQL},
		UserID        =>  $Param{UserID},
	);  

    if (
            $DBObject->Prepare(
                SQL   => $Param{KPIData}{SQL}
            )
        )
    {

        my $MatchesFound;

        @Head = $DBObject->GetColumnNames();

        # if there are any matching rows, they are shown
        ROW:
        while ( my @Row = $DBObject->FetchrowArray( RowNames => 1 ) ) {

            $MatchesFound++;
        
            push @Data, \@Row;
            next ROW;                

            $LayoutObject->Block(
                Name => 'Row',
            );

            # get html data
            my $Row = '';
            for my $Item (@Row) {
                if ( !defined $Item ) {
                    $Item = 'NULL';
                }

                $LayoutObject->Block(
                    Name => 'Cell',
                    Data => {
                        Content => $Item,
                    },
                );
            }
        }                  

    }

    my %Return = (
        Head   => \@Head,
        Data   => \@Data,
    );

    return %Return;
    
}

sub ReplaceSQLAttributes {
    my ( $Self, %Param ) = @_;

    return if !$Param{Message};

	my $LayoutObject     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # replace config item attributes such as <OTRS_SELF_USERID>
    my $Count = 0;

    REPLACEMENT:
    while (
        $Param{Message}
        && $Param{Message} =~ m{<OTRS_SELF_([A-Za-z0-9_::]+)>}msxi
        && $Count++ < 1000
        )
    {

        $Param{Message} =~ s{<OTRS_SELF_USERID>}{$Param{UserID} // ''}ige;
        
    }

    return $Param{Message};
}


=head2 GetSearch()

Return the data to Search subaction, to export

    my %Result = $KPIObject->GetSearch(
        KPIData   => $KPIData,
        UserID    => $Self->{UserID}
        ExcelExport => 1 #optional
    );

Return:
    %Result = (
        Head   => \@Head,
        Data   => \@Data,
    );

=cut

sub GetSearch {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $UserObject          = $Kernel::OM->Get('Kernel::System::User');
    my $ConfigObject        = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject        = $Kernel::OM->Get('Kernel::System::Ticket');
    my $TimeObject          = $Kernel::OM->Get('Kernel::System::Time');

    my $DynamicField;
    
    my $Config = $ConfigObject->Get("Ticket::Frontend::AgentTicketSearch");

    # get dynamic field config for frontend module
    my $DynamicFieldFilter = $Config->{DynamicField};

    # get the dynamic fields for ticket object
    $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $DynamicFieldFilter || {},
    );


    my %GetParam = %{$Param{KPIData}{Search}};

    $Self->{SearchLimit} = $Config->{SearchLimit} || 500;
 
    my %TimeMap = (
        ArticleCreate    => 'ArticleTime',
        TicketCreate     => 'Time',
        TicketChange     => 'ChangeTime',
        TicketLastChange => 'LastChangeTime',
        TicketClose      => 'CloseTime',
        TicketEscalation => 'EscalationTime',
    );        

    for my $TimeType ( sort keys %TimeMap ) {

        # get create time settings
        if ( !$GetParam{ $TimeMap{$TimeType} . 'SearchType' } ) {

            # do nothing with time stuff
        }
        elsif ( $GetParam{ $TimeMap{$TimeType} . 'SearchType' } eq 'TimeSlot' ) {
            for my $Key (qw(Month Day)) {
                $GetParam{ $TimeType . 'TimeStart' . $Key }
                    = sprintf( "%02d", $GetParam{ $TimeType . 'TimeStart' . $Key } );
                $GetParam{ $TimeType . 'TimeStop' . $Key }
                    = sprintf( "%02d", $GetParam{ $TimeType . 'TimeStop' . $Key } );
            }
            if (
                $GetParam{ $TimeType . 'TimeStartDay' }
                && $GetParam{ $TimeType . 'TimeStartMonth' }
                && $GetParam{ $TimeType . 'TimeStartYear' }
                )
            {
                $GetParam{ $TimeType . 'TimeNewerDate' } = $GetParam{ $TimeType . 'TimeStartYear' } . '-'
                    . $GetParam{ $TimeType . 'TimeStartMonth' } . '-'
                    . $GetParam{ $TimeType . 'TimeStartDay' }
                    . ' 00:00:00';
            }
            if (
                $GetParam{ $TimeType . 'TimeStopDay' }
                && $GetParam{ $TimeType . 'TimeStopMonth' }
                && $GetParam{ $TimeType . 'TimeStopYear' }
                )
            {
                $GetParam{ $TimeType . 'TimeOlderDate' } = $GetParam{ $TimeType . 'TimeStopYear' } . '-'
                    . $GetParam{ $TimeType . 'TimeStopMonth' } . '-'
                    . $GetParam{ $TimeType . 'TimeStopDay' }
                    . ' 23:59:59';
            }
        }
        elsif ( $GetParam{ $TimeMap{$TimeType} . 'SearchType' } eq 'TimePoint' ) {
            if (
                $GetParam{ $TimeType . 'TimePoint' }
                && $GetParam{ $TimeType . 'TimePointStart' }
                && $GetParam{ $TimeType . 'TimePointFormat' }
                )
            {
                my $Time = 0;
                if ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'minute' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' };
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'hour' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'day' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60 * 24;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'week' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60 * 24 * 7;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'month' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60 * 24 * 30;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointFormat' } eq 'year' ) {
                    $Time = $GetParam{ $TimeType . 'TimePoint' } * 60 * 24 * 365;
                }
                if ( $GetParam{ $TimeType . 'TimePointStart' } eq 'Before' ) {

                    # more than ... ago
                    $GetParam{ $TimeType . 'TimeOlderMinutes' } = $Time;
                }
                elsif ( $GetParam{ $TimeType . 'TimePointStart' } eq 'Next' ) {

                    # within next
                    $GetParam{ $TimeType . 'TimeNewerMinutes' } = 0;
                    $GetParam{ $TimeType . 'TimeOlderMinutes' } = -$Time;
                }
                else {

                    # within last ...
                    $GetParam{ $TimeType . 'TimeOlderMinutes' } = 0;
                    $GetParam{ $TimeType . 'TimeNewerMinutes' } = $Time;
                }
            }
        }
    }

    # prepare archive flag
    if ( $ConfigObject->Get('Ticket::ArchiveSystem') ) {

        $GetParam{SearchInArchive} ||= '';
        if ( $GetParam{SearchInArchive} eq 'AllTickets' ) {
            $GetParam{ArchiveFlags} = [ 'y', 'n' ];
        }
        elsif ( $GetParam{SearchInArchive} eq 'ArchivedTickets' ) {
            $GetParam{ArchiveFlags} = ['y'];
        }
        else {
            $GetParam{ArchiveFlags} = ['n'];
        }
    }

    # my %AttributeLookup;

    # # create attribute lookup table
    # for my $Attribute ( @{ $GetParam{ShownAttributes} || [] } ) {
    #     $AttributeLookup{$Attribute} = 1;
    # }

    my %AttributeLookup;

    # create attribute lookup table
    for my $Attribute ( keys %GetParam ) {
        $AttributeLookup{$Attribute} = 1;
    }

    # dynamic fields search parameters for ticket search
    my %DynamicFieldSearchParameters;

    # cycle trough the activated Dynamic Fields for this screen

    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # get search field preferences
        my $SearchFieldPreferences = $BackendObject->SearchFieldPreferences(
            DynamicFieldConfig => $DynamicFieldConfig,
        );

        next DYNAMICFIELD if !IsArrayRefWithData($SearchFieldPreferences);

        PREFERENCE:
        for my $Preference ( @{$SearchFieldPreferences} ) {

            if ( $DynamicFieldConfig->{FieldType} eq 'DateTime' || $DynamicFieldConfig->{FieldType} eq 'Date' ){
                if (
                    !$AttributeLookup{
                        'Search_DynamicField_'
                            . $DynamicFieldConfig->{Name}
                            . $Preference->{Type} . 'Value'
                    }
                )
                {
                    next PREFERENCE;
                }

			}

            # extract the dynamic field value from the profile
            my $SearchParameter = $BackendObject->SearchFieldParameterBuild(
                DynamicFieldConfig => $DynamicFieldConfig,
                Profile            => \%GetParam,
                LayoutObject       => $LayoutObject,
                Type               => $Preference->{Type},
            );

            # set search parameter
            if ( defined $SearchParameter ) {
                $DynamicFieldSearchParameters{ 'DynamicField_' . $DynamicFieldConfig->{Name} }
                    = $SearchParameter->{Parameter};
            }
        }
    }


    my @ViewableTicketIDs;
  
    {
        local $Kernel::System::DB::UseSlaveDB = 1;

        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

        # Tickets closed for the current day
        if ( $GetParam{TicketCloseTimeDay} ) {

            my $DateTimeObject = $Kernel::OM->Create(
                'Kernel::System::DateTime'
            );

            my $DateTimeString = $DateTimeObject->Format( Format => '%Y-%m-%d' );

            $GetParam{StateType} = 'Closed';
            $GetParam{TicketCloseTimeNewerDate} = $DateTimeString.' 00:00:00';
            $GetParam{TicketCloseTimeOlderDate} = $DateTimeString.' 23:59:59';
        };

        if ( $GetParam{MyQueues} ) {

			my @MyQueues = $Kernel::OM->Get('Kernel::System::Queue')->GetAllCustomQueues( UserID => $Param{UserID}, );

            if( IsArrayRefWithData( \@MyQueues ) ){
		 	    $GetParam{QueueIDs} = \@MyQueues;	
            }
            else{
                $GetParam{QueueIDs} = [];	
            }
					
		}

        if ( $GetParam{CustomerIDsMultiselect} ) {

            $GetParam{CustomerID} = \@{ $GetParam{CustomerIDsMultiselect} };
            
        }

        if ( $GetParam{MyTickets} ) {
			
		 	@{ $GetParam{OwnerIDs} } = $Param{UserID};	
		}

        # perform ticket search
        @ViewableTicketIDs = $TicketObject->TicketSearch(
            Result              => 'ARRAY',
            SortBy              => $ParamObject->GetParam(Param =>'SortBy'),
            OrderBy             => $ParamObject->GetParam(Param =>'OrderBy'),
            Limit               => $Self->{SearchLimit},
            UserID              => $Param{UserID},
            ConditionInline     => $Config->{ExtendedSearchCondition},
            ContentSearchPrefix => '*',
            ContentSearchSuffix => '*',
            FullTextIndex       => 1,
            %GetParam,
            %DynamicFieldSearchParameters,
        );
       
        if( $GetParam{TicketLastArticleInteraction} ){
            
            my $PeriodTime   = $GetParam{TicketLastArticleInteractionTimePoint};
            my $PeriodFormat = $GetParam{TicketLastArticleInteractionFormat};

            my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

            my $DateTime = $Kernel::OM->Create( 'Kernel::System::DateTime' );

            if( $GetParam{TicketLastArticleInteractionFormat} eq 'day' ){  
                $DateTime->Subtract(
                    Days => $GetParam{TicketLastArticleInteractionTimePoint},
                );
            }
            elsif ( $GetParam{TicketLastArticleInteractionFormat} eq 'week' ){
                $DateTime->Subtract(
                    Weeks => $GetParam{TicketLastArticleInteractionTimePoint},
                );
            }
            elsif ( $GetParam{TicketLastArticleInteractionFormat} eq 'month' ){
                $DateTime->Subtract(
                    Months => $GetParam{TicketLastArticleInteractionTimePoint},
                );
            }
            elsif ( $GetParam{TicketLastArticleInteractionFormat} eq  'year' ){
                $DateTime->Subtract(
                    Years => $GetParam{TicketLastArticleInteractionTimePoint},
                );
            }
            elsif ( $GetParam{TicketLastArticleInteractionFormat} eq 'minute' ){
                $DateTime->Subtract(
                    Minutes => $GetParam{TicketLastArticleInteractionTimePoint},
                );
            }

            my @FilterTicketsIDs;
     
            for my $TicketID (@ViewableTicketIDs){

                my @Article = $ArticleObject->ArticleList(
                    TicketID               => $TicketID,
                    SenderType             => 'agent', 
                    SenderTypeID           => 1,                
                    OnlyLast               => 1, 
                );
                
                if( $Article[0] ){

                    my $DateTimeCreateArtice = $Kernel::OM->Create(
                        'Kernel::System::DateTime',
                        ObjectParams => {
                            String   => $Article[0]{CreateTime},
                        }
                    );
                    
                    my $Result = $DateTimeCreateArtice->Compare( DateTimeObject => $DateTime );

                    if( $GetParam{TicketLastArticleInteraction} eq 'Last' && $Result >= 0 ){
                        push (@FilterTicketsIDs, $TicketID);
                    }
                    elsif( $GetParam{TicketLastArticleInteraction} eq 'Before' && $Result <= 0 ) {
                        push (@FilterTicketsIDs, $TicketID);
                    }
            
                }
                elsif( scalar( @Article ) == 0 ){

					my $Operator;

					if( $GetParam{TicketLastArticleInteraction} eq 'Last' ){
						$Operator = ">";
					}
					elsif(  $GetParam{TicketLastArticleInteraction} eq'Before' ){
						$Operator = "<";
					}

					my $Valid = $Self->KPIGetTicketsByDateCreate( 
						TicketID => $TicketID,
						Date     => $DateTime->Format( Format => '%Y-%m-%d %H:%M:%S' ),
						Operator => $Operator,
					);

					if($Valid){
				
						if( $GetParam{TicketLastArticleInteraction} eq 'Last' ){
							push (@FilterTicketsIDs, $TicketID);
						}

						elsif( $GetParam{TicketLastArticleInteraction} eq 'Before' ) {
							push (@FilterTicketsIDs, $TicketID);
						}
                    
					}
				
					
				}
            }

            @ViewableTicketIDs = @FilterTicketsIDs;

        }

        if ( $GetParam{SLARange} ){
            my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');

            my @Aux = @ViewableTicketIDs;
            @ViewableTicketIDs = ();

            my $TimeTill = $GetParam{SLARange};
            my $StartTime = $TimeObject->SystemTime();

            foreach my $TicketID (@Aux){

                my %Ticket = $TicketObject->TicketGet(
                    TicketID => $TicketID,
                    UserID   => $Param{UserID},
                    Extended => 1,
                );

                if( $Ticket{SLAID} && $Ticket{SolutionTimeDestinationDate} ){

                    my %SLAData = $SLAObject->SLAGet(
                        SLAID  => $Ticket{SLAID},
                        UserID => $Param{UserID},
                    );

                    my $SolutionTime = $TimeObject->TimeStamp2SystemTime(
                        String => $Ticket{SolutionTimeDestinationDate},
                    );

                    my $WorkingTime = $TimeObject->WorkingTime(
                        StartTime => $StartTime,
                        StopTime  => $SolutionTime,
                        Calendar  => $SLAData{Calendar},
                    );

                    my $WorkingTimeMinutes = $WorkingTime/60;

                    if($WorkingTime > 0){

                        my $Percent = 0;

                        if( $SLAData{SolutionTime} && $SLAData{SolutionTime} != 0 ){

                            $Percent = 100 - (($WorkingTimeMinutes/$SLAData{SolutionTime})*100);
                            
                        }

						if ( $Percent >= $Param{KPIData}->{SLARangeMinValue} && $Percent <= $Param{KPIData}->{SLARangeMaxValue} && $TimeTill eq 'Personalize' ) {
							push @ViewableTicketIDs, $TicketID;	
						}
						elsif ( $Percent <= 25 && $TimeTill eq '25' ){
                            push @ViewableTicketIDs, $TicketID;
                        }
                        elsif( $Percent > 25 && $Percent <= 50 && $TimeTill eq '50' ){
                            push @ViewableTicketIDs, $TicketID;
                        }
                        elsif( $Percent > 50 && $Percent <= 75 && $TimeTill eq '75' ){
                            push @ViewableTicketIDs, $TicketID;
                        }
                        elsif( $Percent > 75 && $Percent <= 100 && $TimeTill eq '100' ){
                            push @ViewableTicketIDs, $TicketID;
                        }

                    }
                    else{
                        if ( $TimeTill == 101 ){
                            push @ViewableTicketIDs, $TicketID;
                        }
                    }
                }
            }
        }
        elsif ( $GetParam{FirstResponseRange} ){
            my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');

            my @Aux = @ViewableTicketIDs;
            @ViewableTicketIDs = ();

            my $TimeTill = $GetParam{FirstResponseRange};
            my $StartTime = $TimeObject->SystemTime();

            foreach my $TicketID (@Aux){

                my %Ticket = $TicketObject->TicketGet(
                    TicketID => $TicketID,
                    UserID   => $Param{UserID},
                    Extended => 1,
                );

                if( $Ticket{SLAID} && $Ticket{FirstResponseTimeDestinationDate} ){

                    my %SLAData = $SLAObject->SLAGet(
                        SLAID  => $Ticket{SLAID},
                        UserID => $Param{UserID},
                    );

                    my $FirstResponseTime = $TimeObject->TimeStamp2SystemTime(
                        String => $Ticket{FirstResponseTimeDestinationDate},
                    );

                    my $WorkingTime = $TimeObject->WorkingTime(
                        StartTime => $StartTime,
                        StopTime  => $FirstResponseTime,
                        Calendar  => $SLAData{Calendar},
                    );

                    my $WorkingTimeMinutes = $WorkingTime/60;

                    if($WorkingTime > 0){

                        my $Percent = 0;
                       
                        if( $SLAData{FirstResponseTime} != 0 ){
                            $Percent = 100 - (($WorkingTimeMinutes/$SLAData{FirstResponseTime}) * 100);
                        }

						if ( $Percent >= $Param{KPIData}->{FirstResponseRangeMinValue} && $Percent <= $Param{KPIData}->{FirstResponseRangeMaxValue} && $TimeTill eq 'Personalize' ) {
							push @ViewableTicketIDs, $TicketID;	
						}
						elsif( $Percent <= 25 && $TimeTill eq '25' ){
                            push @ViewableTicketIDs, $TicketID;
                        }
                        elsif( $Percent > 25 && $Percent <= 50 && $TimeTill eq '50' ){
                            push @ViewableTicketIDs, $TicketID;
                        }
                        elsif( $Percent > 50 && $Percent <= 75 && $TimeTill eq '75' ){
                            push @ViewableTicketIDs, $TicketID;
                        }
                        elsif( $Percent > 75 && $Percent <= 100 && $TimeTill eq '100' ){
                            push @ViewableTicketIDs, $TicketID;
                        }

                    }
                    else{
                        if ( $TimeTill == 101 ){
                            push @ViewableTicketIDs, $TicketID;
                        }
                    }
                }
            }
        }
        elsif( $GetParam{SLAStatus} ){                  
            my @Aux = @ViewableTicketIDs;
            @ViewableTicketIDs = ();

            foreach my $TicketID (@Aux){

                my $GetSLAInAndOut = $Self->SLAStatusSolutionTime(
                    TicketID => $TicketID
                );
                                        
                if( $GetParam{SLAStatus} eq 'SLAIn' ){
                    if($GetSLAInAndOut eq 'SLA IN'){
                        push @ViewableTicketIDs, $TicketID;
                    }
                }
                elsif( $GetParam{SLAStatus} eq 'SLAOut' ){
                    if($GetSLAInAndOut eq 'SLA OUT'){
                        push @ViewableTicketIDs, $TicketID;
                    }
                }

            }
        }
    }

    # get needed objects
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    # get the ticket dynamic fields for CSV display
    my $CSVDynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldFilter => $Config->{SearchCSVDynamicField} || {},
    );

    my @TmpCSVHead;
    my @CSVHead;

    if( defined $Param{ExcelExport} && $Param{ExcelExport} == 1 ){

        my $ConfigExport = $ConfigObject->Get("KPI::Core::ExcelExport");

        @TmpCSVHead = @{ $ConfigExport };
        @CSVHead    = @{ $ConfigExport };
    }
    else{
        # create head (actual head and head for data fill)
        @TmpCSVHead = @{ $Config->{SearchCSVData} };
        @CSVHead    = @{ $Config->{SearchCSVData} };
    }
    
    # include the selected dynamic fields in CVS results
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$CSVDynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
        next DYNAMICFIELD if !$DynamicFieldConfig->{Name};
        next DYNAMICFIELD if $DynamicFieldConfig->{Name} eq '';

        push @TmpCSVHead, 'DynamicField_' . $DynamicFieldConfig->{Name};
        push @CSVHead,    $DynamicFieldConfig->{Label};
    }

    my @CSVData;
    for my $TicketID (@ViewableTicketIDs){

        my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

        my @ArticleList = $ArticleObject->ArticleList(
            TicketID               => $TicketID,
            OnlyFirst              => 1
        );

        my $ArticleBackendObject = $ArticleObject->BackendForArticle(
            TicketID => $TicketID,
            ArticleID => $ArticleList[0]->{ArticleID}
        );

        my %Data = $ArticleBackendObject->ArticleGet(
            TicketID      => $TicketID,
            ArticleID     => $ArticleList[0]->{ArticleID},
            DynamicFields => 1,
        );

        # get ticket data instead
        my %TicketData = $TicketObject->TicketGet(
            TicketID      => $TicketID,
            Extended      => 1,
            DynamicFields => 1
        );

        # set missing information
        $TicketData{Subject} = $TicketData{Title} || Translatable('Untitled');
        $TicketData{Body} = $LayoutObject->{LanguageObject}->Translate(
            'This item has no articles yet.'
        );
        $TicketData{From} = '--';

        for my $Key (qw(State Lock)) {
            $Data{$Key} = $LayoutObject->{LanguageObject}->Translate( $Data{$Key} );
        }

        $TicketData{Age} = $LayoutObject->CustomerAge(
            Age   => $TicketData{Age},
            Space => ' '
        );

        # get whole article (if configured!)
        if ( $Config->{SearchArticleCSVTree} ) {
            my @Article = $TicketObject->ArticleGet(
                TicketID      => $TicketID,
                DynamicFields => 0,
            );

            if ( $#Article == -1 ) {
                $Data{ArticleTree} .= $LayoutObject->{LanguageObject}->Translate(
                    'This item has no articles yet.'
                );
            }
            else
            {
                for my $Articles (@Article) {
                    if ( $Articles->{Body} ) {
                        $Data{ArticleTree}
                            .= "\n-->||$Articles->{ArticleType}||$Articles->{From}||"
                            . $Articles->{Created}
                            . "||<--------------\n"
                            . $Articles->{Body};
                    }
                }
            }
        }

        # customer info (customer name)
        if ( $TicketData{CustomerUserID} ) {

            $Data{CustomerName} = $CustomerUserObject->CustomerName(
                UserLogin => $TicketData{CustomerUserID},
            );

        }

        # user info
        my %UserInfo = $UserObject->GetUserData(
            UserID => $TicketData{OwnerID},
        );

        # merge row data
        my %Info = (
            %Data,
            %UserInfo,
            %TicketData,
            AccountedTime =>
                $TicketObject->TicketAccountedTimeGet( TicketID => $TicketID ),
        );

        my @Data;
        for my $Header (@TmpCSVHead) {

            # check if header is a dynamic field and get the value from dynamic field
            # backend
            if ( $Header =~ m{\A DynamicField_ ( [a-zA-Z\d]+ ) \z}xms ) {

                # loop over the dynamic fields configured for CSV output
                DYNAMICFIELD:
                for my $DynamicFieldConfig ( @{$CSVDynamicField} ) {
                    next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
                    next DYNAMICFIELD if !$DynamicFieldConfig->{Name};

                    # skip all fields that does not match with current field name ($1)
                    # with out the 'DynamicField_' prefix
                    next DYNAMICFIELD if $DynamicFieldConfig->{Name} ne $1;

                    # get the value as for print (to correctly display)
                    my $ValueStrg = $BackendObject->DisplayValueRender(
                        DynamicFieldConfig => $DynamicFieldConfig,
                        Value              => $Info{$Header},
                        HTMLOutput         => 0,
                        LayoutObject       => $LayoutObject,
                    );
                    push @Data, $ValueStrg->{Value};

                    # terminate the DYNAMICFIELD loop
                    last DYNAMICFIELD;
                }
            }

            # otherwise retrieve data from article
            else {
                push @Data, $Info{$Header};
            }
        }
        push @CSVData, \@Data;
    }

    my @CSVHeadTranslated;
    my %HeaderMap = (
        TicketNumber => Translatable('Ticket Number'),
        CustomerName => Translatable('Customer Realname'),
    );
    
    @CSVHeadTranslated = map { $LayoutObject->{LanguageObject}->Translate( $HeaderMap{$_} || $_ ); }
        @CSVHead;

    my %Return = (
        Head   => \@CSVHeadTranslated,
        Data   => \@CSVData,
        ViewableTicketID => \@ViewableTicketIDs,
        CSVHead => \@CSVHead
    );

    return %Return;
    
}

=head2 GetSearchSurvey()

Return the data to SearchSurvey subaction, to export

    my %Result = $KPIObject->GetSearchSurvey(
        KPIData   => $KPIData,
        UserID    => $Self->{UserID}
    );

Return:
    %Result = (
        Head   => \@Head,
        Data   => \@Data,
    );

=cut

sub GetSearchSurvey {
    my ( $Self, %Param ) = @_;

    my $SurveyObject = $Kernel::OM->Get('Kernel::System::Survey');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $Config = $ConfigObject->Get("Ticket::Frontend::AgentTicketSearch");
    my $UserObject  = $Kernel::OM->Get('Kernel::System::User');
    my $TimeObject         = $Kernel::OM->Get('Kernel::System::Time');
    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # Get the surveys
    my $PublicSurveyKeys = $SurveyObject->PublicSurveyKeyGet(
        SurveyID => $Param{KPIData}{SurveyID},
    );
    
    my @ArrayOfTickets;

    # Get request.
    PUBLICKEY:
    for my $PublicKey ( @{$PublicSurveyKeys} ) {
        
        my %RequestData = $SurveyObject->RequestGet(
            PublicSurveyKey => $PublicKey,
            RequestSendTimeNewerDate    => $Param{KPIData}{StartDateSendTime},  
            RequestSendTimeOlderDate    => $Param{KPIData}{StopDateSendTime},   
            RequestVoteTimeNewerDate    => $Param{KPIData}{StartDateVoteTime},  
            RequestVoteTimeOlderDate    => $Param{KPIData}{StopDateVoteTime},   
            RequestCreateTimeNewerDate  => $Param{KPIData}{StartDateCreateTime},  
            RequestCreateTimeOlderDate  => $Param{KPIData}{StopDateCreateTime},   
        );


        my @Vote = $SurveyObject->VoteGet(  
            RequestID => $RequestData{RequestID},
            QuestionID => $Param{KPIData}{QuestionID}
        );

        # Get to vote the is equals of answer of kpi
        for my $Vote (@Vote){
            if($Vote->{VoteValue} eq  $Param{KPIData}{AnswerID}){
                push  @ArrayOfTickets, $RequestData{TicketID};
            }
        }
        
    }

    # get needed objects
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    # get the ticket dynamic fields for CSV display
    my $CSVDynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldFilter => $Config->{SearchCSVDynamicField} || {},
    );

    # create head (actual head and head for data fill)
    my @TmpCSVHead = @{ $Config->{SearchCSVData} };
    my @CSVHead    = @{ $Config->{SearchCSVData} };

    # include the selected dynamic fields in CVS results
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$CSVDynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
        next DYNAMICFIELD if !$DynamicFieldConfig->{Name};
        next DYNAMICFIELD if $DynamicFieldConfig->{Name} eq '';

        push @TmpCSVHead, 'DynamicField_' . $DynamicFieldConfig->{Name};
        push @CSVHead,    $DynamicFieldConfig->{Label};
    }

    my @CSVData;
    for my $TicketID (@ArrayOfTickets){

    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

    my @ArticleList = $ArticleObject->ArticleList(
        TicketID               => $TicketID,
        OnlyFirst              => 1
    );


    my $ArticleBackendObject = $ArticleObject->BackendForArticle(
        TicketID => $TicketID,
        ArticleID => $ArticleList[0]->{ArticleID}
    );

    my %Data = $ArticleBackendObject->ArticleGet(
        TicketID      => $TicketID,
        ArticleID     => $ArticleList[0]->{ArticleID},
    );

    # get ticket data instead
    my %TicketData = $TicketObject->TicketGet(
        TicketID      => $TicketID,
        DynamicFields => 1,
        Extended      => 1,
    );

    # set missing information
    $TicketData{Subject} = $TicketData{Title} || Translatable('Untitled');
    $TicketData{Body} = $LayoutObject->{LanguageObject}->Translate(
        'This item has no articles yet.'
    );
    $TicketData{From} = '--';

    for my $Key (qw(State Lock)) {
        $Data{$Key} = $LayoutObject->{LanguageObject}->Translate( $Data{$Key} );
    }

    $TicketData{Age} = $LayoutObject->CustomerAge(
        Age   => $TicketData{Age},
        Space => ' '
    );

    # get whole article (if configured!)
    if ( $Config->{SearchArticleCSVTree} ) {
        my @Article = $TicketObject->ArticleGet(
            TicketID      => $TicketID,
            DynamicFields => 0,
        );

        if ( $#Article == -1 ) {
            $Data{ArticleTree} .= $LayoutObject->{LanguageObject}->Translate(
                'This item has no articles yet.'
            );
        }
        else
        {
            for my $Articles (@Article) {
                if ( $Articles->{Body} ) {
                    $Data{ArticleTree}
                        .= "\n-->||$Articles->{ArticleType}||$Articles->{From}||"
                        . $Articles->{Created}
                        . "||<--------------\n"
                        . $Articles->{Body};
                }
            }
        }
    }

    # customer info (customer name)
    if ( $Data{CustomerUserID} ) {
        $Data{CustomerName} = $CustomerUserObject->CustomerName(
            UserLogin => $Data{CustomerUserID},
        );
    }

    # user info
    my %UserInfo = $UserObject->GetUserData(
        UserID => $TicketData{OwnerID},
    );

    # merge row data
    my %Info = (
        %Data,
        %UserInfo,
        %TicketData,
        AccountedTime =>
            $TicketObject->TicketAccountedTimeGet( TicketID => $TicketID ),
    );

    my @Data;
    for my $Header (@TmpCSVHead) {

        # check if header is a dynamic field and get the value from dynamic field
        # backend
        if ( $Header =~ m{\A DynamicField_ ( [a-zA-Z\d]+ ) \z}xms ) {

            # loop over the dynamic fields configured for CSV output
            DYNAMICFIELD:
            for my $DynamicFieldConfig ( @{$CSVDynamicField} ) {
                next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
                next DYNAMICFIELD if !$DynamicFieldConfig->{Name};

                # skip all fields that does not match with current field name ($1)
                # with out the 'DynamicField_' prefix
                next DYNAMICFIELD if $DynamicFieldConfig->{Name} ne $1;

                # get the value as for print (to correctly display)
                my $ValueStrg = $BackendObject->DisplayValueRender(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Value              => $Info{$Header},
                    HTMLOutput         => 0,
                    LayoutObject       => $LayoutObject,
                );
                push @Data, $ValueStrg->{Value};

                # terminate the DYNAMICFIELD loop
                last DYNAMICFIELD;
            }
        }

        # otherwise retrieve data from article
        else {
            push @Data, $Info{$Header};
        }
    }
        push @CSVData, \@Data;
    }

    # get Separator from language file
    my $UserCSVSeparator = $LayoutObject->{LanguageObject}->{Separator};

    if ( $ConfigObject->Get('PreferencesGroups')->{CSVSeparator}->{Active} ) {
        my %UserData = $UserObject->GetUserData( UserID => $Param{UserID} );
        $UserCSVSeparator = $UserData{UserCSVSeparator} if $UserData{UserCSVSeparator};
    }

    my %HeaderMap = (
        TicketNumber => Translatable('Ticket Number'),
        CustomerName => Translatable('Customer Realname'),
    );

    my @CSVHeadTranslated = map { $LayoutObject->{LanguageObject}->Translate( $HeaderMap{$_} || $_ ); }
        @CSVHead;

    my %Return = (
        Head   => \@CSVHeadTranslated,
        Data   => \@CSVData,
        ArrayOfTickets => \@ArrayOfTickets,
        CSVHead => \@CSVHead
    );

    return %Return;

}

=head2 KPIListGet()

get an KPI list with all KPI details

    my $List = $KPIObject->KPIListGet(
        UserID   => 1,
    );


=cut

sub KPIListGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need UserID!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = 'SELECT id FROM kpi ORDER BY id';

    # SQL
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    my @KPIIDs;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @KPIIDs, $Row[0];
    }

    my @Data;
    for my $ItemID (@KPIIDs) {

        my $KPIData = $Self->KPIGet(
            ID     => $ItemID,
            UserID => 1,
        );
        push @Data, $KPIData;
    }

    return \@Data;
}

=head2 KPISeriesListGet()

get an KPI series list with all KPI details

    my $List = $KPIObject->KPISeriesListGet(
        UserID   => 1,
    );


=cut

sub KPISeriesListGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need UserID!',
        );
        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    my $SQL = 'SELECT id FROM kpi_series ORDER BY id';

    # SQL
    return if !$DBObject->Prepare(
        SQL => $SQL,
    );

    my @KPIIDs;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        push @KPIIDs, $Row[0];
    }

    my @Data;
    for my $ItemID (@KPIIDs) {

        my $KPIData = $Self->SeriesGet(
            ID     => $ItemID,
            UserID => 1,
        );
        push @Data, $KPIData;
    }

    return \@Data;
}

=head2 KPIImport()

import an KPI YAML file/content

    my $KPIImport = $KPIObject->KPIImport(
        Content                   => $YAMLContent, # mandatory, YAML format
        OverwriteExistingEntities => 0,            # 0 || 1
        UserID                    => 1,            # mandatory
    );

=cut

sub KPIImport {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Content UserID)) {

        # check needed stuff
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return {
                Success => 0,
                Message => "$Needed is missing can not continue.",
            };
        }
    }

    my $KPIData = $Kernel::OM->Get('Kernel::System::YAML')->Load( Data => $Param{Content} );

    if ( ref $KPIData ne 'ARRAY' ) {
        return {
            Success => 0,
            Message => Translatable("Couldn't read KPI configuration file. Please make sure the file is valid."),
        };
    }

    my @UpdatedKPIs;
    my @AddedKPIs;
    my @KPIErrors;

    KPI:
    for my $KPI ( @{$KPIData} ) {

        next KPI if !$KPI;
        next KPI if ref $KPI ne 'HASH';

        $KPI = $Self->_KPIMigrateFrom33(
            KPI    => $KPI,
            UserID => $Param{UserID},
        );

        my @ExistingKPIs = @{ $Self->KPIListGet( UserID => $Param{UserID} ) || [] };
        @ExistingKPIs = grep { $_->{Name} eq $KPI->{Name} } @ExistingKPIs;

        if ( $Param{OverwriteExistingEntities} && $ExistingKPIs[0] ) {
            
            my $Success = $Self->KPIUpdate(
                %{ $ExistingKPIs[0] },
                %{$KPI},
                ObjectType => $KPI->{ObjectType},
                UserID    => $Param{UserID},
            );

            if ($Success) {
                push @UpdatedKPIs, $KPI->{Name};
            }
            else {
                push @KPIErrors, $KPI->{Name};
            }

        }
        else {

            # now add the KPI
            my $Success = $Self->KPIAdd(
                %{$KPI},
                ObjectType => $KPI->{ObjectType},
                UserID    => $Param{UserID},
            );

            if ($Success) {
                push @AddedKPIs, $KPI->{Name};
            }
            else {
                push @KPIErrors, $KPI->{Name};
            }
        }
    }

    return {
        Success     => 1,
        AddedKPIs   => join( ', ', @AddedKPIs ) || '',
        UpdatedKPIs => join( ', ', @UpdatedKPIs ) || '',
        KPIErrors   => join( ', ', @KPIErrors ) || '',
    };
}

=head2 KPISeriesImport()

import an KPI YAML file/content

    my $KPIImport = $KPIObject->KPISeriesImport(
        Content                   => $YAMLContent, # mandatory, YAML format
        OverwriteExistingEntities => 0,            # 0 || 1
        UserID                    => 1,            # mandatory
    );

=cut

sub KPISeriesImport {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(Content UserID)) {

        # check needed stuff
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return {
                Success => 0,
                Message => "$Needed is missing can not continue.",
            };
        }
    }

    my $KPIData = $Kernel::OM->Get('Kernel::System::YAML')->Load( Data => $Param{Content} );

    if ( ref $KPIData ne 'ARRAY' ) {
        return {
            Success => 0,
            Message => Translatable("Couldn't read KPI series configuration file. Please make sure the file is valid."),
        };
    }

    my @UpdatedKPIs;
    my @AddedKPIs;
    my @KPIErrors;

    KPI:
    for my $KPI ( @{$KPIData} ) {

        next KPI if !$KPI;
        next KPI if ref $KPI ne 'HASH';

        $KPI = $Self->_KPIMigrateFrom33(
            KPI    => $KPI,
            UserID => $Param{UserID},
        );

        my @ExistingKPIs = @{ $Self->KPISeriesListGet( UserID => $Param{UserID} ) || [] };
        @ExistingKPIs = grep { $_->{Name} eq $KPI->{Name} } @ExistingKPIs;

        if ( $Param{OverwriteExistingEntities} && $ExistingKPIs[0] ) {
            
            my $Success = $Self->SeriesUpdate(
                %{ $ExistingKPIs[0] },
                %{$KPI},
                UserID    => $Param{UserID},
            );

            if ($Success) {
                push @UpdatedKPIs, $KPI->{Name};
            }
            else {
                push @KPIErrors, $KPI->{Name};
            }

        }
        else {

            # now add the KPI
            my $Success = $Self->SeriesAdd(
                %{$KPI},
                UserID    => $Param{UserID},
            );

            if ($Success) {
                push @AddedKPIs, $KPI->{Name};
            }
            else {
                push @KPIErrors, $KPI->{Name};
            }
        }
    }

    return {
        Success     => 1,
        AddedKPIs   => join( ', ', @AddedKPIs ) || '',
        UpdatedKPIs => join( ', ', @UpdatedKPIs ) || '',
        KPIErrors   => join( ', ', @KPIErrors ) || '',
    };
}

=head2 _KPIMigrateFrom33()

Updates KPIs structure my changing the Possible->Action hash ref to a PossibleNot->Action array ref
with just the elements that where set to 0 in the original KPI:
    $KPI = $Self->_KPIMigrateFrom33(
        KPI    => $KPI,
        UserID => $Param{UserID},
    );

=cut

sub _KPIMigrateFrom33 {
    my ( $Self, %Param ) = @_;

    my $KPI = $Param{KPI};

    return $KPI if !ref $KPI->{ConfigChange};
    return $KPI if !$KPI->{ConfigChange}->{Possible}->{Action};
    return $KPI if ref $KPI->{ConfigChange}->{Possible}->{Action} ne 'HASH';

    # convert old hash into an array using only the keys set to 0, and skip those that are set
    # to 1, set them as PossibleNot and delete the Possible->Action section from the KPI.
    my @NewAction = grep { $KPI->{ConfigChange}->{Possible}->{Action}->{$_} == 0 }
        sort keys %{ $KPI->{ConfigChange}->{Possible}->{Action} };

    delete $KPI->{ConfigChange}->{Possible}->{Action};
    $KPI->{ConfigChange}->{PossibleNot}->{Action} = \@NewAction;

    return $KPI;
}

=head2 KPIGetDataToSLARange()

Get the data to SLA range filter

    my @Tickets = $KPIObject->KPIGetDataToSLARange(
        TicketIDs  => [1, 2],            
    );

=cut

sub KPIGetDataToSLARange {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{TicketIDs} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketIDs!',
        );
        return;
    }

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => 'SELECT T.id, T.sla_id, S.CALENDAR_NAME, S.solution_time, T.escalation_solution_time FROM ticket T JOIN sla S ON T.sla_id = S.id WHERE T.id IN ('. join (', ', @{$Param{TicketIDs}} ).' )',
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        my %SelectData;

        $SelectData{TicketID}           = $Row[0];
        $SelectData{SLAID}              = $Row[1];
        $SelectData{CalendarID}         = $Row[2];
        $SelectData{SLASolutionTime}    = $Row[3];
        $SelectData{TicketSolutionTime} = $Row[4];

        push @Data, \%SelectData;

    }

    return @Data;

}

=head2 KPIGetTicketsByDateCreate()

Get tickets based on their creation date

    my TicketID = $KPIObject->KPIGetDataToSLARange(
        TicketID  => 123,
        Operator  => > # > or <,
        Date      => 2021-08-31 00:00:00       
    );

=cut
sub KPIGetTicketsByDateCreate {

    my ( $Self, %Param ) = @_;

  # check needed stuff
    for my $Argument (qw(TicketID Operator Date)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Need $Argument!',
            );
            return;
        }
    }

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');

    my $sql = "SELECT id FROM ticket WHERE id = ? and";

    if( $Param{Operator} eq '>' ){
        $sql .= " create_time > ?";
    }
    else{
        $sql .= " create_time < ?";
    }

    return if !$DBObject->Prepare(
        SQL => $sql,
        Bind => [\$Param{TicketID}, \$Param{Date}]
    );

    # fetch the result
    my $TicketID;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $TicketID = $Row[0];
    }

    return $TicketID;

}

=head2 SLAStatusSolutionTime()
Returns the status of the ticket to the Solution SLA
    my $GetSLAInAndOut = $KPIdObject->SLAStatusSolutionTime(
        TicketID => 1
    );
=cut

sub SLAStatusSolutionTime {
    my ( $Self, %Param ) = @_;

     # check needed stuff
    if ( !$Param{TicketID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Need TicketID!",
        );
        return;
    }

    # get database object 
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    if ($DBObject->{Backend}{'DB::Type'} eq 'oracle'){
        return if !$DBObject->Prepare(
            SQL => "SELECT tn, CASE WHEN  EXISTS(
                SELECT name
                FROM ticket_history
                WHERE ticket_id =  t.id and name='%%EscalationSolutionTimeStart%%triggered') THEN  'SLA OUT' ELSE  'SLA IN' END 
                ESTADO_DO_SLA from ticket t where t.id = ?",
            Bind  => [ \$Param{TicketID} ],
        );
    }else
    {
        return if !$DBObject->Prepare(
            SQL => "SELECT tn, IF( EXISTS(
                SELECT name
                FROM ticket_history
                WHERE ticket_id =  t.id and name='%%EscalationSolutionTimeStart%%triggered'), 'SLA OUT', 'SLA IN') 
                ESTADO_DO_SLA from ticket t where t.id = ?",
            Bind  => [ \$Param{TicketID} ],
        );
    }

    # fetch the result
	my $SLAStatus;
	while ( my @Row = $DBObject->FetchrowArray() ) {
		$SLAStatus = $Row[1];
	}

    return  $SLAStatus;

}

=head2 KPIGetDataToChartLine()

Get the data to SLA range filter

    my @Tickets = $KPIObject->KPIGetDataToChartLine(
        TicketIDs  => [1, 2],   
        StartDate => '2021-05-11 00:00:00'         
        EndDate => '2021-05-11 23:59:59'         
    );

=cut

sub KPIGetDataToChartLine {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{TicketIDs} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need TicketIDs!',
        );
        return;
    }

    # get database object
    my $DBObject   = $Kernel::OM->Get('Kernel::System::DB');

    return if !$DBObject->Prepare(
        SQL => 'SELECT id FROM ticket WHERE create_time BETWEEN ? AND ? AND id IN ('. join (', ', @{$Param{TicketIDs}} ).' )',
        Bind => [\$Param{StartDate}, \$Param{EndDate}]
    );

    # fetch the result
    my @Data;
    while ( my @Row = $DBObject->FetchrowArray() ) {
     
        push @Data, $Row[0];

    }

    return @Data;

}

=head2 FilterPublicSurveyKeyGet()

to get an array list of request elements

    my $Requests = $KPIObject->FilterPublicSurveyKeyGet (
        SurveyID => '2',
        RequestSendTimeNewerDate    => '2012-01-01 12:00:00',   # (optional)
        RequestSendTimeOlderDate    => '2012-01-31 12:00:00',   # (optional)
        RequestVoteTimeNewerDate    => '2012-01-01 12:00:00',   # (optional)
        RequestVoteTimeOlderDate    => '2012-12-31 12:00:00',   # (optional)
        RequestCreateTimeNewerDate  => '2012-01-01 12:00:00',   # (optional)
        RequestCreateTimeOlderDate  => '2012-12-31 12:00:00',   # (optional)
    );

returns:

    $Requests = [
                    {
                        RequestID       => 123,
                        TicketID        => 123,
                        SurveyID        => 123,
                        ValidID         => 1,
                        PublicSurveyKey => 'b4c14552919018b51ec792c9b812b691',
                        SendTo          => 'mail@localhost.com',
                        SendTime        => '2017-01-01 12:00:00',
                        VoteTime        => '2017-01-02 12:00:00',
                    }
                ];

=cut

sub FilterPublicSurveyKeyGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{SurveyID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need SurveyID!',
        );

        return;
    }

    # get database object
    my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

    # prepare sql
    my $SQLSelect = 'SELECT id, ticket_id, survey_id, valid_id, public_survey_key, send_to, send_time, vote_time';
    my $SQLFrom   = ' FROM survey_request';
    my $SQLWhere  = " WHERE survey_id = '$Param{SurveyID}'";

    # set time params
    my %TimeParams = (

        RequestSendTimeNewerDate   => 'send_time >=',
        RequestSendTimeOlderDate   => 'send_time <=',
        RequestVoteTimeNewerDate   => 'vote_time >=',
        RequestVoteTimeOlderDate   => 'vote_time <=',
        RequestCreateTimeNewerDate => 'create_time >=',
        RequestCreateTimeOlderDate => 'create_time <=',
    );

    # check and add time params to WHERE
    TIMEPARAM:
    for my $TimeParam ( sort keys %TimeParams ) {

        next TIMEPARAM if !$Param{$TimeParam};

        # check format
        if ( $Param{$TimeParam} !~ m{ \A \d\d\d\d-\d\d-\d\d \s \d\d:\d\d:\d\d \z }xms ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "The parameter $TimeParam has an invalid date format!",
            );

            return;
        }

        $Param{$TimeParam} = $DBObject->Quote( $Param{$TimeParam} );

        # add time parameter to WHERE
        $SQLWhere .= " AND $TimeParams{$TimeParam} '$Param{$TimeParam}'";
    }

    my $SQL = $SQLSelect .= $SQLFrom;
    $SQL .= $SQLWhere;

    # get request list
    return if !$DBObject->Prepare(
        SQL   => $SQL,
    );

    # fetch the result
    my @Requests;

    while ( my @Row = $DBObject->FetchrowArray() ) {

        push @Requests, {
            RequestID       => $Row[0],
            TicketID        => $Row[1],
            SurveyID        => $Row[2],
            ValidID         => $Row[3],
            PublicSurveyKey => $Row[4],
            SendTo          => $Row[5],
            SendTime        => $Row[6],
            VoteTime        => $Row[7],
        };

    }    

    return \@Requests;
}

=head1 TERMS AND CONDITIONS

This software is part of the Service Up plugin (L<http://www.serviceup.com.br>).

=cut

1;