# --
# Kernel/Output/HTML/Dashboard/KPIWidget.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * dsilva@beonup.com.br
# * gtiburtino@beonup.com.br
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Output::HTML::Dashboard::KPIWidget;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

use POSIX;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get needed parameters
    for my $Needed (qw( Config Name UserID )) {
        die "Got no $Needed!" if ( !$Self->{$Needed} );
    }

	my $PrefName = '';

	$PrefName = $Self->{PrefKeyWidgets} = 'UserDashboardPref' . $Self->{Name} . 'Series-Columns';
	
	$Self->{PrefKeyWidgets} = $PrefName;

    $Self->{CacheKey} = $Self->{Name} . '-' . $Self->{UserID};

    return $Self;
}

sub Preferences {
    my ( $Self, %Param ) = @_;

	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');
	my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
	my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');

    # configure columns
    my @ColumnsEnabled;
    my @ColumnsAvailable;
    my @ColumnsAvailableNotEnabled;

	my %Groups = $GroupObject->PermissionUserGet(
        UserID => $Self->{UserID},
        Type   => 'ro',
    );

	my @UserGroups = keys %Groups;
	
	my @SeriesList = $KPIObject->ValidSeriesList();

	SERIES:
	foreach my $SeriesID ( @SeriesList ){

		my $SeriesData = $KPIObject->SeriesGet(
			ID => $SeriesID,
		);

		my @Groups = split /,/, $SeriesData->{GroupIDs};

		if ( IsArrayRefWithData(\@Groups) ){
			my $MatchGroups = 0;

			foreach my $GroupID ( @Groups ){
				if ( grep( $_ == $GroupID, @UserGroups ) ){
					$MatchGroups++;
				}
			}

			next SERIES if ( $MatchGroups <= 0 );
		}

		push @ColumnsAvailable, $SeriesData->{Name};
	}
	

    # check if the user has filter preferences for this widget
    my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
        UserID => $Self->{UserID},
    );

    # get JSON object
    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

	
    # if preference settings are available, take them
    if ( $Preferences{ $Self->{PrefKeyWidgets} } ) {

        my $ColumnsEnabled = $JSONObject->Decode(
            Data => $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{ $Self->{PrefKeyWidgets} },
        );
	
        @ColumnsEnabled = grep { $ColumnsEnabled->{Columns}->{$_} == 1 }
            keys %{ $ColumnsEnabled->{Columns} };

        if ( $ColumnsEnabled->{Order} && @{ $ColumnsEnabled->{Order} } ) {
            @ColumnsEnabled = @{ $ColumnsEnabled->{Order} };
        }

        # remove duplicate columns
        my %UniqueColumns;
        my @ColumnsEnabledAux;

        for my $Column (@ColumnsEnabled) {
            if ( !$UniqueColumns{$Column} && ( grep{$_ eq $Column} @ColumnsAvailable ) ) {
                push @ColumnsEnabledAux, $Column;
            }
            $UniqueColumns{$Column} = 1;
        }

        # set filtered column list
        @ColumnsEnabled = @ColumnsEnabledAux;
		
    }
	else {
		my @KPIsDefault = $KPIObject->SeriesListDefault();

		SERIESDEFAULT:
		foreach my $SeriesID ( @KPIsDefault ){

			my $SeriesData = $KPIObject->SeriesGet(
				ID => $SeriesID,
			);

			my @Groups = split /,/, $SeriesData->{GroupIDs};

			if ( IsArrayRefWithData(\@Groups) ){
				my $MatchGroups = 0;

				foreach my $GroupID ( @Groups ){
					if ( grep( $_ == $GroupID, @UserGroups ) ){
						$MatchGroups++;
					}
				}

				next SERIESDEFAULT if ( $MatchGroups <= 0 );
			}

			my %Data = (
				$SeriesData->{Name} => 1
			);

			push @ColumnsEnabled, $SeriesData->{Name};
		}

	}

	my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    my %Columns;
    for my $ColumnName ( sort { $a cmp $b } @ColumnsAvailable ) {
        $Columns{Columns}->{$ColumnName} = ( grep { $ColumnName eq $_ } @ColumnsEnabled ) ? 1 : 0;
        if ( !grep { $_ eq $ColumnName } @ColumnsEnabled ) {
            push @ColumnsAvailableNotEnabled, $ColumnName;
        }
    }

    my @Params = (
        {
            Desc             => Translatable('Search template'),
            Name             => $Self->{PrefKeyWidgets},
            Block            => 'AllocationList',
            Columns          => $JSONObject->Encode( Data => \%Columns ),
            ColumnsEnabled   => $JSONObject->Encode( Data => \@ColumnsEnabled ),
            ColumnsAvailable => $JSONObject->Encode( Data => \@ColumnsAvailableNotEnabled ),
            Translation      => 1,
        },
    );

	
    return @Params;
}

sub Config {
    my ( $Self, %Param ) = @_;

    return (
        %{ $Self->{Config} },

        # remember, do not allow to use page cache
        # (it's not working because of internal filter)
        CacheKey => undef,
        CacheTTL => undef,
    );
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get config object
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
	my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');
	my $KPIObject          = $Kernel::OM->Get('Kernel::System::KPI');
	my $GroupObject        = $Kernel::OM->Get('Kernel::System::Group');

	my %Groups = $GroupObject->PermissionUserGet(
        UserID => $Self->{UserID},
        Type   => 'ro',
    );

	my @UserGroups = keys %Groups;

	my $Output;

	my @ColumnsEnabled;
	my @ColumnsAUX;

	# check if the user has filter preferences for this widget
	my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
		UserID => $Self->{UserID},
	);

	if ( $Preferences{ $Self->{PrefKeyWidgets} } ){
		my $ColumnsEnabled = $JSONObject->Decode(
           Data => $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{ $Self->{PrefKeyWidgets} },
		);

		@ColumnsEnabled = grep { $ColumnsEnabled->{Columns}->{$_} == 1 }
			keys %{ $ColumnsEnabled->{Columns} };

		foreach my $Order ( @{$ColumnsEnabled->{Order}} ){
			push @ColumnsAUX, $Order;
		}
	}
	else {

		my @KPIsDefault = $KPIObject->SeriesListDefault();

		SERIESDEFAULT:
		foreach my $SeriesID ( @KPIsDefault ){

			my $SeriesData = $KPIObject->SeriesGet(
				ID => $SeriesID,
			);

			my @Groups = split /,/, $SeriesData->{GroupIDs};

			if ( IsArrayRefWithData(\@Groups) ){
				my $MatchGroups = 0;

				foreach my $GroupID ( @Groups ){
					if ( grep( $_ == $GroupID, @UserGroups ) ){
						$MatchGroups++;
					}
				}

				next SERIESDEFAULT if ( $MatchGroups <= 0 );
			}

			push @ColumnsAUX, $SeriesData->{Name} ;
		}

		if(scalar  @ColumnsAUX == 0){
			$Output = $LayoutObject->Output(
				TemplateFile => 'AgentDashboardKPIWidget',
				Data         => {
					JSON => 'null',
				},
				KeepScriptTags => $Param{AJAX},
			);

			# send data to JS
			$LayoutObject->AddJSData(
				Key   => 'DataJSON',
				Value => 'null',
			);

			return $Output;
		}

	}

	if ( @ColumnsAUX ){
		@ColumnsEnabled = ();

		foreach my $Column ( @ColumnsAUX ){
			push @ColumnsEnabled, $Column;
		}
	}

	$LayoutObject->Block(
		Name => "Series",
	);

	my @Data = ();

	my @SeriesList = $KPIObject->SeriesList();
	my $TotalKPI;
	
	SERIES:
	foreach my $SeriesName ( @ColumnsEnabled ){
		
		my @ColumnsEnabledKPI = ();

		my $SeriesID = $KPIObject->SeriesLookup(
			Name => $SeriesName,
		);

		my $SeriesData;

		if($SeriesID){
			$SeriesData = $KPIObject->SeriesGet(
				ID => $SeriesID,
			);
		}

		# my $SeriesData = $KPIObject->SeriesGet(
		# 	ID => $SeriesID,
		# );

		my @SeriesGroups = split /,/, $SeriesData->{GroupIDs};

		if ( IsArrayRefWithData(\@SeriesGroups) ){
			my $MatchGroups = 0;

			foreach my $GroupID ( @SeriesGroups ){
				if ( grep( $_ == $GroupID, @UserGroups ) ){
					$MatchGroups++;
				}
			}

			next SERIES if ( $MatchGroups <= 0 );
		}
		
		my @DataChart;
		if( $SeriesData->{SerieType} eq 'Simple'){
			my @KPIs = split ",", $SeriesData->{AssociatedKPIs};

			next SERIES if(!IsArrayRefWithData(\@KPIs));
			next SERIES if($SeriesData->{ValidID} > 1);

			$TotalKPI += scalar @KPIs;

			$LayoutObject->Block(
				Name => "SeriesRow",
				Data =>{
					Title => $SeriesData->{Name},
					Valid => $SeriesData->{ValidID}
				}
			);

			foreach my $KPIID ( @KPIs ){
				my $KPI = $KPIObject->KPIGet(
					ID => $KPIID,
				);

				push @ColumnsEnabledKPI, $KPI->{Name};
			}

			@ColumnsEnabledKPI =  sort @ColumnsEnabledKPI;

			@DataChart = $Self->_BuildCharts(
				UserGroups => \@UserGroups,
				Type => 'Series',
				ColumnsEnabled => \@ColumnsEnabledKPI,
				SerieID => $SeriesData->{ID}
			);

		}elsif($SeriesData->{SerieType} eq 'Complex'){		
		
			$LayoutObject->Block(
				Name => "SeriesRow",
				Data =>{
					Title => $SeriesData->{Name},
					Valid => $SeriesData->{ValidID}
				}
			);

			@DataChart = $Self->_BuildChartsComplex(
				UserGroups => \@UserGroups,
				Type => 'Series',
				SeriesData => \%{$SeriesData},
			);

		}elsif($SeriesData->{SerieType} eq 'ChartSQLQuery'){		
			
			$LayoutObject->Block(
				Name => "SeriesRow",
				Data =>{
					Title => $SeriesData->{Name},
					Valid => $SeriesData->{ValidID}
				}
			);

			@DataChart = $Self->_BuildChartsChartSQLQuery(
				UserGroups => \@UserGroups,
				Type => 'Series',
				SeriesData => \%{$SeriesData},
			);
		}

		@Data = ( @DataChart, @Data);
	}

	# build JSON output
	my $JSON = $LayoutObject->JSONEncode(
		Data => \@Data,
	);

	# send data to JS
	# $LayoutObject->AddJSData(
	#     Key   => 'DataJSON',
	#     Value => $JSON,
	# );

	$Output = $LayoutObject->Output(
		TemplateFile => 'AgentDashboardKPIWidget',
		Data         => {
			%{ $Self->{Config} },
			Name => $Self->{Name},
			JSON => $JSON,
		},
		KeepScriptTags => $Param{AJAX},
	);
	

	return $Output;
}

sub _BuildCharts {
	my ( $Self, %Param ) = @_;

	# get config object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');

	my @ProfileSearch = $Self->_GetSearchProfiles(
		ColumnsEnabled => $Param{ColumnsEnabled}
	);

	my @Data;
	my @UserGroups = @{$Param{UserGroups}};

	WIDGET:
	foreach my $Profile ( @ProfileSearch ){
	
		my $KPIData = $KPIObject->KPIGet(
			ID => $Profile->{KPIID},
		);

		if ( IsArrayRefWithData($KPIData->{Groups}) ){
			my $MatchGroups = 0;
			my @KPIGroups = @{$KPIData->{Groups}};

			foreach my $GroupID ( @KPIGroups ){
				if ( grep( $_ == $GroupID, @UserGroups ) ){
					$MatchGroups++;
				}
			}

			next WIDGET if ( $MatchGroups <= 0 );
		}

		my $IsValidKPI = $KPIData->{ValidID} || 0;

		if($KPIData->{TypeKPI} eq 'Graphic'){
			my %ColorOrder;
			my %Rules;
			
			if ( $KPIData->{SeverityOrder} eq 'Ascending' ){
				%ColorOrder = (
					First  => $KPIData->{Rules}->{RuleColor1} || "#7fb6ff",
					Second => $KPIData->{Rules}->{RuleColor2} || "#fccd41",
					Third  => $KPIData->{Rules}->{RuleColor3} || "#fc6464",
					Fourth => $KPIData->{Rules}->{RuleColor4} || "#e00b0b",
				);

				%Rules = (
					First  => $KPIData->{Rules}->{Rule1},
					Second => $KPIData->{Rules}->{Rule2},
					Third  => $KPIData->{Rules}->{Rule3},
					Fourth => $KPIData->{Rules}->{Rule4},
				);

			}
			else{
				%ColorOrder = (
					First  => $KPIData->{Rules}->{RuleColor4} || "#e00b0b",
					Second => $KPIData->{Rules}->{RuleColor3} || "#fc6464",
					Third  => $KPIData->{Rules}->{RuleColor2} || "#fccd41",
					Fourth => $KPIData->{Rules}->{RuleColor1} || "#7fb6ff",
				);

				%Rules = (
					Fourth => $KPIData->{Rules}->{Rule1},
					Third  => $KPIData->{Rules}->{Rule2},
					Second => $KPIData->{Rules}->{Rule3},
					First  => $KPIData->{Rules}->{Rule4},
				);
			}


			my $MaxValue = $KPIData->{MaxValue} || 100;
		
			my $First = floor ( $MaxValue/4 );
			my $Second = $First + ( floor ($MaxValue/4) );
			my $Third = $Second + ( floor ($MaxValue/4) );

			my %Values = (
				Min    => $KPIData->{MinValue} || 0,
				First  => $First || 30,
				Second => $Second || 60,
				Third  => $Third || 90,
				Max    => $KPIData->{MaxValue} || 100,
			);


			push @Data, {
				ID    => "GaugeChart_$KPIData->{ID}_$Param{SerieID}",
				Valid => $IsValidKPI,
				Title => $Profile->{Title},
				Values => \%Values,
				ColorOrder => \%ColorOrder,
				Rules => \%Rules,
				TypeKPI  => $KPIData->{TypeKPI} 

			};
		}
		elsif($KPIData->{TypeKPI} eq 'Numeric'){

			push @Data, {
				ID    => "NumericChart_$KPIData->{ID}_$Param{SerieID}",
				Valid => $IsValidKPI,
				Title => $Profile->{Title},
				TypeKPI  => $KPIData->{TypeKPI} 
			};
			
		}
		elsif ($KPIData->{Metric} eq 'Percentage'){
			push @Data, {
				ID    => "SimpleChart_$KPIData->{ID}_$Param{SerieID}",
				Valid => $IsValidKPI,
				Title => $Profile->{Title},
				TypeKPI  => 'Simple' 
			};
		}		
		elsif($KPIData->{ObjectType} eq 'Config Items'){
			push @Data, {
				ID    => "SimpleITSMChart_$KPIData->{ID}_$Param{SerieID}",
				Valid => $IsValidKPI,
				Title => $Profile->{Title},
				TypeKPI  => 'SimpleITSM' 
			};
		}
		else{
			push @Data, {
				ID    => "SQLQueryChart_$KPIData->{ID}_$Param{SerieID}",
				Valid => $IsValidKPI,
				Title => $Profile->{Title},
				TypeKPI  => 'SQLQuery'
			};
		}
		
		
	}

	KPICHARTDATA:
	foreach my $HashData ( @Data ){

		next KPICHARTDATA if( $HashData->{Valid} > 1 );

		$LayoutObject->Block(
			Name => "WidgetTicketRow$Param{Type}",
			Data => $HashData
		);
	}

	return @Data;

}

sub _BuildChartsComplex {
	my ( $Self, %Param ) = @_;

	# get config object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');

	my @UserGroups = @{$Param{UserGroups}};

	my @Data;

	my $ClassName;

	if($Param{SeriesData}->{QtdColumn} eq '1'){
		$ClassName = 'ComplexLiTo1Column';
	}
	elsif($Param{SeriesData}->{QtdColumn} eq '2'){
		$ClassName = 'ComplexLiTo2Column';
	}
	elsif($Param{SeriesData}->{QtdColumn} eq '3'){
		$ClassName = 'ComplexLiTo3Column';
	}

	for (my $i = 1; $i <= $Param{SeriesData}->{QtdColumn}; $i++) {

		my $NameAssociatedKPI = 'AssociatedKPIsCol' . $i ;
		my $ChartTypeColKPI = 'ChartTypeCol' . $i ;
		my $ChartTitle = 'TitleCol' . $i ;
	
		my @KPIs = split ",", $Param{SeriesData}->{$NameAssociatedKPI};

		my @ColumnsEnabledKPI;
		my %ColumnsColor;
		
		my %DataChart;

		WIDGET:
		foreach my $KPIID (@KPIs ){

			my $KPI = $KPIObject->KPIGet(
				ID => $KPIID,
				ValidID => 1
			);

			
			if ( IsArrayRefWithData($KPI->{Groups}) ){
				my $MatchGroups = 0;
				my @KPIGroups = @{$KPI->{Groups}};

				foreach my $GroupID ( @KPIGroups ){
					if ( grep( $_ == $GroupID, @UserGroups ) ){
						$MatchGroups++;
					}
				}

				next WIDGET if ( $MatchGroups <= 0 );
			}

			my $IsValidKPI = $KPI->{ValidID} || 0;

			push @ColumnsEnabledKPI, $KPI->{Name};
		
		}

		push @Data, {
			ID    => "ComplexChart_$Param{SeriesData}->{ID}_$i",
			Title =>  $Param{SeriesData}->{$ChartTitle},
			Values => \@ColumnsEnabledKPI,
			color => \%ColumnsColor,
			TypeKPI  =>  $Param{SeriesData}->{$ChartTypeColKPI},
			Class => $ClassName
		};
	}

	
	KPICHARTDATA:
	foreach my $HashData ( @Data ){

		$HashData->{Valid} = $HashData->{Valid} || 0;
		next KPICHARTDATA if( $HashData->{Valid} > 1 );
		
		$LayoutObject->Block(
			Name => "WidgetTicketRowSeriesComplex",
			Data => $HashData
		);
	}

	return @Data;
}

sub _GetSearchProfiles {
	my ( $Self, %Param ) = @_;

	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

	my %ProfileData;
	my %ProfileUserPermission;
	my @ProfileSearch;

	my @ColumnsEnabled = @{$Param{ColumnsEnabled}};
	
	my $Config = $ConfigObject->Get("Ticket::Frontend::AgentTicketSearch");

	# get dynamic field config for frontend module
    my $DynamicFieldFilter = $Config->{DynamicField};
    my $SearchLimit = $Config->{SearchLimit};

	# get the dynamic fields for ticket object
    my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $DynamicFieldFilter || {},
    );

	PROFILE:
	foreach my $ProfileName ( @ColumnsEnabled ){

		# To not show delete kpi
		next PROFILE if $ProfileName eq undef;

		my $KPIID = $KPIObject->KPILookup(
			Name => $ProfileName,
		);

		my $KPI = $KPIObject->KPIGet(
			ID => $KPIID,
		);

		my %GetParam;

		if($KPI->{ObjectType} ne 'SQL Query'){

			# if ( IsHashRefWithData($KPI->{Search}) ){
			# 	%GetParam = %{$KPI->{Search}};
			# }
			# else{
			# 	next PROFILE;
			# }

			# get article create time option
			if ( !$GetParam{ArticleTimeSearchType} ) {
				$GetParam{'ArticleTimeSearchType::None'} = 1;
			}
			elsif ( $GetParam{ArticleTimeSearchType} eq 'TimePoint' ) {
				$GetParam{'ArticleTimeSearchType::TimePoint'} = 1;
			}
			elsif ( $GetParam{ArticleTimeSearchType} eq 'TimeSlot' ) {
				$GetParam{'ArticleTimeSearchType::TimeSlot'} = 1;
			}

			# get create time option
			if ( !$GetParam{TimeSearchType} ) {
				$GetParam{'TimeSearchType::None'} = 1;
			}
			elsif ( $GetParam{TimeSearchType} eq 'TimePoint' ) {
				$GetParam{'TimeSearchType::TimePoint'} = 1;
			}
			elsif ( $GetParam{TimeSearchType} eq 'TimeSlot' ) {
				$GetParam{'TimeSearchType::TimeSlot'} = 1;
			}

			# get change time option
			if ( !$GetParam{ChangeTimeSearchType} ) {
				$GetParam{'ChangeTimeSearchType::None'} = 1;
			}
			elsif ( $GetParam{ChangeTimeSearchType} eq 'TimePoint' ) {
				$GetParam{'ChangeTimeSearchType::TimePoint'} = 1;
			}
			elsif ( $GetParam{ChangeTimeSearchType} eq 'TimeSlot' ) {
				$GetParam{'ChangeTimeSearchType::TimeSlot'} = 1;
			}

			# get last change time option
			if ( !$GetParam{LastChangeTimeSearchType} ) {
				$GetParam{'LastChangeTimeSearchType::None'} = 1;
			}
			elsif ( $GetParam{LastChangeTimeSearchType} eq 'TimePoint' ) {
				$GetParam{'LastChangeTimeSearchType::TimePoint'} = 1;
			}
			elsif ( $GetParam{LastChangeTimeSearchType} eq 'TimeSlot' ) {
				$GetParam{'LastChangeTimeSearchType::TimeSlot'} = 1;
			}

			# get close time option
			if ( !$GetParam{CloseTimeSearchType} ) {
				$GetParam{'CloseTimeSearchType::None'} = 1;
			}
			elsif ( $GetParam{CloseTimeSearchType} eq 'TimePoint' ) {
				$GetParam{'CloseTimeSearchType::TimePoint'} = 1;
			}
			elsif ( $GetParam{CloseTimeSearchType} eq 'TimeSlot' ) {
				$GetParam{'CloseTimeSearchType::TimeSlot'} = 1;
			}

			# get escalation time option
			if ( !$GetParam{EscalationTimeSearchType} ) {
				$GetParam{'EscalationTimeSearchType::None'} = 1;
			}
			elsif ( $GetParam{EscalationTimeSearchType} eq 'TimePoint' ) {
				$GetParam{'EscalationTimeSearchType::TimePoint'} = 1;
			}
			elsif ( $GetParam{EscalationTimeSearchType} eq 'TimeSlot' ) {
				$GetParam{'EscalationTimeSearchType::TimeSlot'} = 1;
			}

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

			# Special behavior for the fulltext search toolbar module:
			# - Check full text string to see if contents is a ticket number.
			# - If exists and not in print or CSV mode, redirect to the ticket.
			# See http://bugs.otrs.org/show_bug.cgi?id=4238 for details.
			#   The original problem was that tickets with customer reply will be
			#   found by a fulltext search (ticket number is in the subjects), but
			#   'new' tickets will not be found.
			if (
				$GetParam{Fulltext}
				&& $ParamObject->GetParam( Param => 'CheckTicketNumberAndRedirect' )
				&& $GetParam{ResultForm} ne 'Normal'
				&& $GetParam{ResultForm} ne 'Print'
				)
			{
				my $TicketID = $TicketObject->TicketIDLookup(
					TicketNumber => $GetParam{Fulltext},
					UserID       => $Self->{UserID},
				);
				if ($TicketID) {
					return $LayoutObject->Redirect(
						OP => "Action=AgentTicketZoom;TicketID=$TicketID",
					);
				}
			}

			# prepare full text search
			if ( $GetParam{Fulltext} ) {
				$GetParam{ContentSearch} = 'OR';
				for my $Key (qw(From To Cc Subject Body)) {
					$GetParam{$Key} = $GetParam{Fulltext};
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

			#if ( $GetParam{TimeTillSolution} ){
			#	 $GetParam{TimeTillSolution};
			#}

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

			push @ProfileSearch, {
				Title => $ProfileName,
				KPIID => $KPIID,
				ProfileSearch => \%GetParam,
				DynamicFieldSearch => \%DynamicFieldSearchParameters ,
				Limit => $SearchLimit,
				UserPermissionSearch => $ProfileUserPermission{$ProfileName},
			};
		}else{
			push @ProfileSearch, {
				Title => $ProfileName,
				KPIID => $KPIID,
				ProfileSearch => \%GetParam,
				UserPermissionSearch => $ProfileUserPermission{$ProfileName},
			};
		}
    }

	return @ProfileSearch;

}

sub _BuildChartsChartSQLQuery {
	my ( $Self, %Param ) = @_;
	
	# get config object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');

	my @UserGroups = @{$Param{UserGroups}};

	my @Data;

	my $ClassName;

	if($Param{SeriesData}->{QtdColumn} eq '1'){
		$ClassName = 'ChartSQLQueryLiTo1Column';
	}
	elsif($Param{SeriesData}->{QtdColumn} eq '2'){
		$ClassName = 'ChartSQLQueryLiTo2Column';
	}
	elsif($Param{SeriesData}->{QtdColumn} eq '3'){
		$ClassName = 'ChartSQLQueryLiTo3Column';
	}

	for (my $i = 1; $i <= $Param{SeriesData}->{QtdColumn}; $i++) {

		my $NameAssociatedKPI = 'AssociatedKPIsChartSQLCol' . $i ;
		# my $ChartTypeColKPI = 'ChartTypeCol' . $i ;
		my $ChartTitle = 'TitleChartSQLCol' . $i ;
	
		my @KPIs = split ",", $Param{SeriesData}->{$NameAssociatedKPI};

		my @ColumnsEnabledKPI;
		my $KPI;
		my %DataChart;

		WIDGET:
		foreach my $KPIID (@KPIs ){

			$KPI = $KPIObject->KPIGet(
				ID => $KPIID,
				ValidID => 1
			);

			if ( IsArrayRefWithData($KPI->{Groups}) ){
				my $MatchGroups = 0;
				my @KPIGroups = @{$KPI->{Groups}};

				foreach my $GroupID ( @KPIGroups ){
					if ( grep( $_ == $GroupID, @UserGroups ) ){
						$MatchGroups++;
					}
				}

				next WIDGET if ( $MatchGroups <= 0 );
			}

			my $IsValidKPI = $KPI->{ValidID} || 0;

			push @ColumnsEnabledKPI, $KPI->{Name};

		}

		push @Data, {
			ID    => "ChartSQLQueryChart_$Param{SeriesData}->{ID}_$i",
			Title =>  $Param{SeriesData}->{$ChartTitle},
			Values => \@ColumnsEnabledKPI,
			TypeKPI  =>  $KPI->{ReturnChart},
			Class => $ClassName
		};
	}

	
	KPICHARTDATA:
	foreach my $HashData ( @Data ){

		$HashData->{Valid} = $HashData->{Valid} || 0;
		next KPICHARTDATA if( $HashData->{Valid} > 1 );
		
		$LayoutObject->Block(
			Name => "WidgetTicketRowSeriesChartSQLQuery",
			Data => $HashData
		);
	}
	
	return @Data;
}

1;
