# --
# Kernel/Modules/KPIWidgetAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * ischutzer@beonup.com.br
# * pdias@beonup.com.br
# * dsilva@serviceup.com.br
# * gtiburtino@beonup.com.br
# * nfreitas@serviceup.com.br
# * msantos@serviceup.com.br
# * ccresencio@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::KPIWidgetAJAXHandler;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use POSIX;
use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # create needed objects
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');
	my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my $JSON = '';

	my $Name     = '0000-KPIWidget';
	my $PrefName = '';
	my $Configs  = $ConfigObject->Get('DashboardBackend')->{'0000-KPIWidget'};
	
	$PrefName = $Self->{PrefKeyWidgets} = 'UserDashboardPref' . $Name . 'Series-Columns';
	
	my @ColumnsEnabled;
	my @ColumnsAUX;

	# check if the user has filter preferences for this widget
	my %Preferences = $Kernel::OM->Get('Kernel::System::User')->GetPreferences(
		UserID => $Self->{UserID},
	);

	if ( $Preferences{ $PrefName } ){
		my $ColumnsEnabled = $JSONObject->Decode(
			Data => $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{ $PrefName },
		);

		@ColumnsEnabled = grep { $ColumnsEnabled->{Columns}->{$_} == 1 }
			keys %{ $ColumnsEnabled->{Columns} };

		foreach my $Order ( @{$ColumnsEnabled->{Order}} ){
			push @ColumnsAUX, $Order;

		}
	}
	else {
		my %Groups = $GroupObject->PermissionUserGet(
			UserID => $Self->{UserID},
			Type   => 'ro',
		);

		my @UserGroups = keys %Groups;

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

		if ( scalar  @ColumnsAUX == 0 ) {
			# build JSON output
			$JSON = $LayoutObject->JSONEncode(
				Data => {
					JSON => "No preferences set",
				},
			);
			# send JSON response
			return $LayoutObject->Attachment(
				ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
				Content     => $JSON,
				Type        => 'inline',
				NoCache     => 1,
			);
		}
	}

	if ( @ColumnsAUX ){
		@ColumnsEnabled = ();

		foreach my $Column ( @ColumnsAUX ){
			push @ColumnsEnabled, $Column;
		}

	}

	# check permissions
	if ( $Configs->{$Name}->{Group} ) {
		my $PermissionOK = 0;
		my @Groups = split /;/, $Configs->{$Name}->{Group};
		GROUP:
		for my $Group (@Groups) {
			my $Permission = 'UserIsGroupRo[' . $Group . ']';
			if ( defined $Self->{$Permission} && $Self->{$Permission} eq 'Yes' ) {
				$PermissionOK = 1;
				last GROUP;
			}
		}
		if ( !$PermissionOK ){
			# build JSON output
			$JSON = $LayoutObject->JSONEncode(
				Data => {
					JSON => "No group permission",
				},
			);

			# send JSON response
			return $LayoutObject->Attachment(
				ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
				Content     => $JSON,
				Type        => 'inline',
				NoCache     => 1,
			);
		}
	}

	if ( $Self->{Subaction} eq 'GetKPIIDByName' ) {

		my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

		my $ClickedKPIName = $ParamObject->GetParam( Param => 'ClickedKPIName');   

		my $KPIID = $KPIObject->KPILookup(
        	Name => $ClickedKPIName
    	);

		my $KPIData = $KPIObject->KPIGet(
			ID      => $KPIID
		);

		my $JSONKPI = $LayoutObject->JSONEncode(
			Data => {
				KPIID      => $KPIID,
				ObjectType => $KPIData->{ObjectType}
			},
		);

		return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSONKPI || '',
			Type        => 'inline',
			NoCache     => 1,
		);

	}

	my %Groups = $GroupObject->PermissionUserGet(
        UserID => $Self->{UserID},
        Type   => 'ro',
    );

	my @Groups = keys %Groups;

	my @Data = ();

	my @SeriesList = $KPIObject->SeriesList();

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

		my @KPIs;

		if( $SeriesData->{SerieType} eq 'Simple' ) {

			@KPIs = split ",", $SeriesData->{AssociatedKPIs};

			next SERIES if(!IsArrayRefWithData(\@KPIs));

			my $TotalKPI = scalar @KPIs;

			KPI:
			foreach my $KPIID ( @KPIs ) {
			
				my $KPI = $KPIObject->KPIGet(
					ID => $KPIID,
					ValidID => 1
				);

				next KPI if ( !IsHashRefWithData( $KPI ) );
				
				push @ColumnsEnabledKPI, $KPI->{Name};
			}

			my @DataChart = $Self->_BuildParameters(
				UserGroups => \@Groups,
				ColumnsEnabled => \@ColumnsEnabledKPI,
				SerieID =>  $SeriesID,
				SerieType => 'Simple'
			);

			@Data = ( @DataChart, @Data);

		}
		elsif( $SeriesData->{SerieType} eq 'Complex' ) {

			my @DataChart = $Self->_BuildParametersToComplex(
				UserGroups => \@Groups,
				SeriesData =>  $SeriesData,
			);

			@Data = ( @DataChart, @Data);
			
		}
		
		elsif( $SeriesData->{SerieType} eq 'ChartSQLQuery' ) {

			my @DataChart = $Self->_BuildParametersToChartSQL(
				UserGroups => \@Groups,
				SeriesData =>  $SeriesData,
			);			

			@Data = ( @DataChart, @Data);

		}
	}

	# build JSON output
	$JSON = $LayoutObject->JSONEncode(
		Data => {
			JSON => \@Data,
		},
	);

	# send JSON response
	return $LayoutObject->Attachment(
		ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
		Content     => $JSON || '',
		Type        => 'inline',
		NoCache     => 1,
	);
}

sub _BuildParameters {
	my ( $Self, %Param ) = @_;
	
	# create needed objects
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

	my @UserGroups = @{$Param{UserGroups}};

	my @ProfileSearch =  $Self->_GetSearchProfiles(
		ColumnsEnabled => $Param{ColumnsEnabled}
	);

	my @Data;	

    WIDGET:
	foreach my $Profile ( @ProfileSearch ){

		my $KPIData = $KPIObject->KPIGet(
			ID      => $Profile->{KPIID},
			ValidID => 1
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
	
		my $Tickets;
		my @TicketSearchIDs;

		if ( $Profile->{ProfileSearch}->{MyQueues} ) {

			my @MyQueues = $Kernel::OM->Get('Kernel::System::Queue')->GetAllCustomQueues( UserID => $Self->{UserID}, );

			if( IsArrayRefWithData( \@MyQueues ) ){
				$Profile->{ProfileSearch}->{QueueIDs} = \@MyQueues;			
			}
			else{
				$Profile->{ProfileSearch}->{QueueIDs} = [];
			}
			
		}

		if ( $Profile->{ProfileSearch}->{MyTickets} ) {
			
		 	@{ $Profile->{ProfileSearch}->{OwnerIDs} } =  $Self->{UserID};	
		}

		if ( $Profile->{ProfileSearch}->{CustomerIDsMultiselect} ) {

			@{ $Profile->{ProfileSearch}->{CustomerID} } =  @{ $Profile->{ProfileSearch}->{CustomerIDsMultiselect} };

		}

		# Tickets closed on the current day (chart)
		if ( $Profile->{ProfileSearch}->{TicketCloseTimeDay} ) {

			my $DateTimeObject = $Kernel::OM->Create(
        		'Kernel::System::DateTime'
    		);

			my $DateTimeString = $DateTimeObject->Format( Format => '%Y-%m-%d' );
			
			my @TicketIDs = $TicketObject->TicketSearch(
				UserID 	   => $Self->{UserID},
				Result 	   => 'ARRAY',
				%{$Profile->{ ProfileSearch }},
				%{$Profile->{ DynamicFieldSearch }},
				ContentSearchPrefix => '*',
				ContentSearchSuffix => '*',
				FullTextIndex       => 1,
				Limit => $Profile->{ Limit },
				StateType => 'Closed',
				TicketCloseTimeNewerDate => $DateTimeString.' 00:00:00',
				TicketCloseTimeOlderDate => $DateTimeString.' 23:59:59',
			);

			@TicketSearchIDs = @TicketIDs;
			$Tickets = scalar @TicketSearchIDs;
		}
		elsif( $Profile->{ProfileSearch}->{TicketLastArticleInteraction} ){

			my @TicketIDs = $TicketObject->TicketSearch(
				UserID 	   => $Self->{UserID},
				Result 	   => 'ARRAY',
				%{$Profile->{ ProfileSearch }},
				%{$Profile->{ DynamicFieldSearch }},
				ContentSearchPrefix => '*',
				ContentSearchSuffix => '*',
				FullTextIndex       => 1,
				Limit => $Profile->{ Limit }
			);
			
			my $PeriodTime   = $Profile->{ProfileSearch}->{TicketLastArticleInteractionTimePoint};
			my $PeriodFormat = $Profile->{ProfileSearch}->{TicketLastArticleInteractionFormat};

		 	my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');

			my $DateTime = $Kernel::OM->Create( 'Kernel::System::DateTime' );

			if( $Profile->{ProfileSearch}->{TicketLastArticleInteractionFormat} eq 'day' ){
				    
				$DateTime->Subtract(
					Days => $Profile->{ProfileSearch}->{TicketLastArticleInteractionTimePoint},
				);

			}
			elsif ( $Profile->{ProfileSearch}->{TicketLastArticleInteractionFormat} eq 'week' ){

				$DateTime->Subtract(
					Weeks => $Profile->{ProfileSearch}->{TicketLastArticleInteractionTimePoint},
				);

			}
			elsif ( $Profile->{ProfileSearch}->{TicketLastArticleInteractionFormat} eq 'month' ){

				$DateTime->Subtract(
					Months => $Profile->{ProfileSearch}->{TicketLastArticleInteractionTimePoint},
				);

			}
			elsif ( $Profile->{ProfileSearch}->{TicketLastArticleInteractionFormat} eq  'year' ){

				$DateTime->Subtract(
					Years => $Profile->{ProfileSearch}->{TicketLastArticleInteractionTimePoint},
				);

			}
			elsif ( $Profile->{ProfileSearch}->{TicketLastArticleInteractionFormat} eq 'minute' ){

				$DateTime->Subtract(
					Minutes => $Profile->{ProfileSearch}->{TicketLastArticleInteractionTimePoint},
				);

			}

			my @FilterTicketsIDs;

			for my $TicketID (@TicketIDs){

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
					
					if( $Profile->{ProfileSearch}->{TicketLastArticleInteraction} eq 'Last' && $Result >= 0 ){
                        push (@FilterTicketsIDs, $TicketID);
                    }
                    elsif( $Profile->{ProfileSearch}->{TicketLastArticleInteraction} eq 'Before' && $Result <= 0 ) {
                        push (@FilterTicketsIDs, $TicketID);
                    }

				}
				elsif( scalar( @Article ) == 0 ){

					my $Operator;

					if( $Profile->{ProfileSearch}->{TicketLastArticleInteraction} eq 'Last' ){
						$Operator = ">";
					}
					elsif(  $Profile->{ProfileSearch}->{TicketLastArticleInteraction} eq 'Before' ){
						$Operator = "<";
					}
					my $Valid = $KPIObject->KPIGetTicketsByDateCreate( 
						TicketID => $TicketID,
						Date     => $DateTime->Format( Format => '%Y-%m-%d %H:%M:%S' ),
						Operator => $Operator,
					);
			
					if($Valid){
				
						if( $Profile->{ProfileSearch}->{TicketLastArticleInteraction} eq 'Last' ){
							push (@FilterTicketsIDs, $TicketID);
						}

						elsif( $Profile->{ProfileSearch}->{TicketLastArticleInteraction} eq 'Before' ) {
							push (@FilterTicketsIDs, $TicketID);
						}
                    
					}
					
				}

			}

			@TicketSearchIDs = @FilterTicketsIDs;
			$Tickets = scalar @TicketSearchIDs;	
		}
		elsif ( !$Profile->{ProfileSearch}->{SLARange} &&  !$Profile->{ProfileSearch}->{FirstResponseRange} && !$Profile->{ProfileSearch}->{SLAStatus} ) {

			my @TicketIDs = $TicketObject->TicketSearch(
				UserID 	   => $Self->{UserID},
				Result 	   => 'ARRAY',
				%{$Profile->{ ProfileSearch }},
				%{$Profile->{ DynamicFieldSearch }},
				ContentSearchPrefix => '*',
				ContentSearchSuffix => '*',
				FullTextIndex       => 1,
				Limit => $Profile->{ Limit }
			);
			
			@TicketSearchIDs = @TicketIDs;
			$Tickets = scalar @TicketSearchIDs;	
	
		}
		elsif ( $Profile->{ProfileSearch}->{SLARange} ) {

			my $TimeTill = $Profile->{ProfileSearch}->{SLARange};

			if ( !IsHashRefWithData($Self->{SLARange}) ) {
	
                my $DateTimeObject  = $Kernel::OM->Create('Kernel::System::DateTime');

				my @TicketIDs = $TicketObject->TicketSearch(
					Result => 'ARRAY',
					UserID => $Self->{UserID},
					%{$Profile->{ ProfileSearch }},
					%{$Profile->{ DynamicFieldSearch }},
					ContentSearchPrefix => '*',
					ContentSearchSuffix => '*',
					FullTextIndex       => 1,
					Limit => $Profile->{ Limit }
				);

				my @TicketsSLARange = $KPIObject->KPIGetDataToSLARange(
					TicketIDs => \@TicketIDs,           
				);



				for my $Ticket (@TicketsSLARange){

					if( $Ticket->{SLAID} && $Ticket->{TicketSolutionTime} ){

                        my $SolutionTimeObject = $Kernel::OM->Create(
                            'Kernel::System::DateTime',
                            ObjectParams => {
                                Epoch    => $Ticket->{TicketSolutionTime},
                            }
                        );

                        my $DeltaObj = $DateTimeObject->Delta(
                            DateTimeObject => $SolutionTimeObject,
                            ForWorkingTime => 1,
                            Calendar       => $Ticket->{CalendarID},
                        );

                        my $WorkingTime = $DeltaObj ? $DeltaObj->{AbsoluteSeconds} : 0;

						my $WorkingTimeMinutes = $WorkingTime/60;

						if($WorkingTime > 0){

							my $Percent = 100 - (($WorkingTimeMinutes/$Ticket->{SLASolutionTime})*100);

							if ( $Percent >= $KPIData->{SLARangeMinValue} && $Percent <= $KPIData->{SLARangeMaxValue} ) {
								$Self->{SLARange}->{'Personalize'}++;
								push @TicketSearchIDs, $Ticket->{TicketID};	
							}
							elsif ( $Percent <= 25 ){
								$Self->{SLARange}->{'25'}++;
								push @TicketSearchIDs, $Ticket->{TicketID};
							}
							elsif( $Percent > 25 && $Percent <= 50 ){
								$Self->{SLARange}->{'50'}++;
								push @TicketSearchIDs, $Ticket->{TicketID};
							}
							elsif( $Percent > 50 && $Percent <= 75 ){
								$Self->{SLARange}->{'75'}++;
								push @TicketSearchIDs, $Ticket->{TicketID};
							}
							elsif ( $Percent > 75 && $Percent <= 100 ){
								$Self->{SLARange}->{'100'}++;
								push @TicketSearchIDs, $Ticket->{TicketID};
							}
						}
						else{
							$Self->{SLARange}->{'101'}++;
							push @TicketSearchIDs, $Ticket->{TicketID};
						}
					}

				}

			}

			$Tickets = $Self->{SLARange}->{$TimeTill} || 0;
			$Self->{SLARange} = undef;
		}
		elsif ( $Profile->{ProfileSearch}->{FirstResponseRange} ){
			my $TimeTill = $Profile->{ProfileSearch}->{FirstResponseRange};

			if ( !IsHashRefWithData($Self->{FirstResponseRange}) ) {
				my $SLAObject    = $Kernel::OM->Get('Kernel::System::SLA');
				my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
				#my $TimeObject   = $Kernel::OM->Get('Kernel::System::Time');
				#my $StartTime = $TimeObject->SystemTime();

                my $DateTimeObject  = $Kernel::OM->Create('Kernel::System::DateTime');

				my @TicketIDs = $TicketObject->TicketSearch(
					Result => 'ARRAY',
					UserID => $Self->{UserID},
					%{$Profile->{ ProfileSearch }},
					%{$Profile->{ DynamicFieldSearch }},
					ContentSearchPrefix => '*',
					ContentSearchSuffix => '*',
					FullTextIndex       => 1,
					Limit => $Profile->{ Limit }
				);

				foreach my $TicketID (@TicketIDs){
					 my %Ticket = $TicketObject->TicketGet(
						TicketID     => $TicketID,
						UserID       => $Self->{UserID},
						Extended     => 1,
						DynamicField => 1,
					);

					if ( $Ticket{SLAID} && $Ticket{FirstResponseTimeDestinationDate} ){
						my %SLAData = $SLAObject->SLAGet(
							SLAID  => $Ticket{SLAID},
							UserID => $Self->{UserID},
						);

						# my $FirsResponseTime = $TimeObject->TimeStamp2SystemTime(
						# 	String => $Ticket{FirstResponseTimeDestinationDate},
						# );

						# my $WorkingTime = $TimeObject->WorkingTime(
						# 	StartTime => $StartTime,
						# 	StopTime  => $FirsResponseTime,
						# 	Calendar  => $SLAData{Calendar},
						# );

                        my $FirsResponseTimeObject = $Kernel::OM->Create(
                            'Kernel::System::DateTime',
                            ObjectParams => {
                                String   => $Ticket{FirstResponseTimeDestinationDate},
                            }
                        );

                        my $DeltaObj = $DateTimeObject->Delta(
                            DateTimeObject => $FirsResponseTimeObject,
                            ForWorkingTime => 1,
                            Calendar       => $SLAData{Calendar},
                        );

                        my $WorkingTime = $DeltaObj ? $DeltaObj->{AbsoluteSeconds} : 0;

						my $WorkingTimeMinutes = $WorkingTime/60;

						if($WorkingTime > 0){

							my $Percent = 100 - (($WorkingTimeMinutes/$SLAData{FirstResponseTime}) * 100);

							if ( $Percent >= $KPIData->{FirstResponseRangeMinValue} && $Percent <= $KPIData->{FirstResponseRangeMaxValue} ) {
								$Self->{FirstResponseRange}->{'Personalize'}++;
								push @TicketSearchIDs, $TicketID;	
							}
							elsif ( $Percent <= 25 ){
								$Self->{FirstResponseRange}->{'25'}++;
								push @TicketSearchIDs, $TicketID;
							}
							elsif( $Percent > 25 && $Percent <= 50 ){
								$Self->{FirstResponseRange}->{'50'}++;
								push @TicketSearchIDs, $TicketID;
							}
							elsif( $Percent > 50 && $Percent <= 75 ){
								$Self->{FirstResponseRange}->{'75'}++;
								push @TicketSearchIDs, $TicketID;
							}

							elsif ( $Percent > 75 && $Percent <= 100 ){
								$Self->{FirstResponseRange}->{'100'}++;
								push @TicketSearchIDs, $TicketID;
							}
						}
						else{
							$Self->{FirstResponseRange}->{'101'}++;
							push @TicketSearchIDs, $TicketID;
						}
					}
				}
			}

			$Tickets = $Self->{FirstResponseRange}->{$TimeTill} || 0;
			$Self->{FirstResponseRange} = undef;
			
		}
		elsif ( $Profile->{ProfileSearch}->{SLAStatus} ){

			if ( !IsHashRefWithData($Self->{SLAStatus}) ) {
	
				my @TicketIDs = $TicketObject->TicketSearch(
					Result => 'ARRAY',
					UserID => $Self->{UserID},
					%{$Profile->{ ProfileSearch }},
					%{$Profile->{ DynamicFieldSearch }},
					ContentSearchPrefix => '*',
					ContentSearchSuffix => '*',
					FullTextIndex       => 1,
					Limit => $Profile->{ Limit }
				);

				# @TicketSearchIDs = @TicketIDs;
				
				my $CountTickets = 0;
				
				for my $TicketID ( @TicketIDs ){
					
					my $GetSLAInAndOut = $KPIObject->SLAStatusSolutionTime(
						TicketID => $TicketID
					);
					
					if( $Profile->{ProfileSearch}->{SLAStatus} eq 'SLAIn' ){
						if($GetSLAInAndOut eq 'SLA IN'){
							$CountTickets++;
							push @TicketSearchIDs, $TicketID;
						}
					}
					elsif( $Profile->{ProfileSearch}->{SLAStatus} eq 'SLAOut' ){
						if($GetSLAInAndOut eq 'SLA OUT'){
							$CountTickets++;
							push @TicketSearchIDs, $TicketID;
						}
					}
				}

				$Tickets = $CountTickets || 0;
			}

		}

		my %Rules = ();
		my %MapScale = (
			Day  => "Days",
			Month => "Months",
			Quarter => "Months",
			Semester => "Months",
			Year => "Years",
		);
	
		if( $Param{ChartType} && $Param{ChartType} eq 'Line'){
			
			my $DateTimeObject = $Kernel::OM->Create(
				'Kernel::System::DateTime'
			);

			my $ScaleTime = $Param{ChartScaleTime};

			my $ToCurrentMonth = 0;

			if($Param{ChartScaleUnit} eq 'Quarter'){
				$ScaleTime = ($Param{ChartScaleTime} * 3) - 1;
			}
			elsif($Param{ChartScaleUnit} eq 'Semester'){
				$ScaleTime = ($Param{ChartScaleTime} * 6) - 1;
			}
			else{
				$ToCurrentMonth++;
			}

			my $Success = $DateTimeObject->Subtract(
				$MapScale{$Param{ChartScaleUnit}} => $ScaleTime,				
			);

			my @ReturnData;
			
			push @ReturnData, $KPIData->{Name};

			my $TicketOfScale = 0;
			
			for my $Key ( 1 .. $Param{ChartScaleTime} + $ToCurrentMonth ) {		
						
				my @TicketsInDate;

				my $DateTimeSettings = $DateTimeObject->Get();

				my $StartTimeObject = $Kernel::OM->Create(
					'Kernel::System::DateTime',
					ObjectParams => {
						String   => $DateTimeObject->ToString(),
					}
				);

				if($Param{ChartScaleUnit} eq 'Day'){
					my $Success = $StartTimeObject->Set(
						Year     => $DateTimeSettings->{Year},
						Month    => $DateTimeSettings->{Month},
						Day      => $DateTimeSettings->{Day},
						Hour     => "00",
						Minute   => "00",
						Second   => "00",
					);

					my $EndTimeObject = $Kernel::OM->Create(
						'Kernel::System::DateTime',
						ObjectParams => {
							String   => $DateTimeObject->ToString(),
						}
					);

					my $SuccessEnd = $EndTimeObject->Set(
						Year     => $DateTimeSettings->{Year},
						Month    => $DateTimeSettings->{Month},
						Day      => $DateTimeSettings->{Day},
						Hour     => "23",
						Minute   => "59",
						Second   => "59",
					);

					my $SuccessAddDay = $DateTimeObject->Add(						
						Days          => 1,
					);

					@TicketsInDate = $KPIObject->KPIGetDataToChartLine(
						TicketIDs  => \@TicketSearchIDs,   
						StartDate  => $StartTimeObject->ToString(),         
						EndDate    => $EndTimeObject->ToString(),        
					);

					$TicketOfScale = $TicketOfScale + scalar @TicketsInDate;
				}
				elsif($Param{ChartScaleUnit} eq 'Month'){
				
					my $Success = $StartTimeObject->Set(
						Year     => $DateTimeSettings->{Year},
						Month    => $DateTimeSettings->{Month},
						Day      => '01',
						Hour     => "00",
						Minute   => "00",
						Second   => "00",
					);

					my $EndTimeObject = $Kernel::OM->Create(
						'Kernel::System::DateTime',
						ObjectParams => {
							String   => $DateTimeObject->ToString(),
						}
					);

					my $LastDayOfMonth = $DateTimeObject->LastDayOfMonthGet();
					my $LastDay = $LastDayOfMonth->{Day};				
				
					my $SuccessEnd = $EndTimeObject->Set(
						Year     => $DateTimeSettings->{Year},
						Month    => $DateTimeSettings->{Month},
						Day      => $LastDay,
						Hour     => "23",
						Minute   => "59",
						Second   => "59",
					);	

					my $SuccessAddMonth = $DateTimeObject->Add(				
						Months  => 1,
					);

					@TicketsInDate = $KPIObject->KPIGetDataToChartLine(
						TicketIDs  => \@TicketSearchIDs,   
						StartDate  => $StartTimeObject->ToString(),         
						EndDate    => $EndTimeObject->ToString(),        
					);

					$TicketOfScale = $TicketOfScale + scalar @TicketsInDate;
				}
				elsif($Param{ChartScaleUnit} eq 'Year'){
				
					my $Success = $StartTimeObject->Set(
						Year     => $DateTimeSettings->{Year},
						Month    => '01',
						Day      => '01',
						Hour     => "00",
						Minute   => "00",
						Second   => "00",
					);

					my $EndTimeObject = $Kernel::OM->Create(
						'Kernel::System::DateTime',
						ObjectParams => {
							String   => $DateTimeObject->ToString(),
						}
					);

					my $LastDayOfMonth = $DateTimeObject->LastDayOfMonthGet();
					my $LastDay = $LastDayOfMonth->{Day};				
				
					my $SuccessEnd = $EndTimeObject->Set(
						Year     => $DateTimeSettings->{Year},
						Month    => '12',
						Day      => '31',
						Hour     => "23",
						Minute   => "59",
						Second   => "59",
					);

					my $SuccessAddYear = $DateTimeObject->Add(				
						Years          => 1,
					);

					@TicketsInDate = $KPIObject->KPIGetDataToChartLine(
						TicketIDs  => \@TicketSearchIDs,   
						StartDate  => $StartTimeObject->ToString(),         
						EndDate    => $EndTimeObject->ToString(),        
					);

					$TicketOfScale = $TicketOfScale + scalar @TicketsInDate;

				}
				elsif($Param{ChartScaleUnit} eq 'Quarter'){
					
					my $Success = $StartTimeObject->Set(
						Year     => $DateTimeSettings->{Year},
						Month    => $DateTimeSettings->{Month},
						Day      => '01',
						Hour     => "00",
						Minute   => "00",
						Second   => "00",
					);

					my $EndTimeObject = $Kernel::OM->Create(
						'Kernel::System::DateTime',
						ObjectParams => {
							String   => $StartTimeObject->ToString(),
						}
					);

					my $SuccessAddQuarterEns = $EndTimeObject->Add(				
						Months  => 2,
					);

					my $LastDayOfMonth = $EndTimeObject->LastDayOfMonthGet();
					my $LastDay = $LastDayOfMonth->{Day};				
				
					my $SuccessEnd = $EndTimeObject->Set(
						Year     => $EndTimeObject->{Year},
						Month    => $EndTimeObject->{Month},
						Day      => $LastDay,
						Hour     => "23",
						Minute   => "59",
						Second   => "59",
					);

					my $SuccessAddQuarter = $DateTimeObject->Add(				
						Months  => 3,
					);

					@TicketsInDate = $KPIObject->KPIGetDataToChartLine(
						TicketIDs  => \@TicketSearchIDs,   
						StartDate  => $StartTimeObject->ToString(),         
						EndDate    => $EndTimeObject->ToString(),        
					);

					$TicketOfScale = $TicketOfScale + scalar @TicketsInDate;
				}
				elsif($Param{ChartScaleUnit} eq 'Semester'){
					my $Success = $StartTimeObject->Set(
						Year     => $DateTimeSettings->{Year},
						Month    => $DateTimeSettings->{Month},
						Day      => '01',
						Hour     => "00",
						Minute   => "00",
						Second   => "00",
					);

					my $EndTimeObject = $Kernel::OM->Create(
						'Kernel::System::DateTime',
						ObjectParams => {
							String   => $StartTimeObject->ToString(),
						}
					);

					my $SuccessAddSemesterEnd = $EndTimeObject->Add(				
						Months  => 5,
					);

					my $LastDayOfMonth = $EndTimeObject->LastDayOfMonthGet();
					my $LastDay = $LastDayOfMonth->{Day};				
				
					my $SuccessEnd = $EndTimeObject->Set(
						Year     => $EndTimeObject->{Year},
						Month    => $EndTimeObject->{Month},
						Day      => $LastDay,
						Hour     => "23",
						Minute   => "59",
						Second   => "59",
					);

				
					my $SuccessAddSemester = $DateTimeObject->Add(				
						Months  => 6,
					);

					@TicketsInDate = $KPIObject->KPIGetDataToChartLine(
						TicketIDs  => \@TicketSearchIDs,   
						StartDate  => $StartTimeObject->ToString(),         
						EndDate    => $EndTimeObject->ToString(),        
					);

					$TicketOfScale = $TicketOfScale + scalar @TicketsInDate;
				}

				push @ReturnData, scalar @TicketsInDate;				
			}
			
			push @Data, {
				ID    => "LineChart_$KPIData->{ID}_$Param{SerieID}",
				Total => \@ReturnData,
				Label => '',
				Min   => '',
				Max   => '',
				TypeKPI => $KPIData->{TypeKPI},
				RealID => $KPIData->{ID},
				TotalTicketSearch => scalar @TicketSearchIDs,
				TotalTicketsOfScale => $TicketOfScale,
			};
			
		}else{

			if($KPIData->{TypeKPI} eq 'Graphic'){
				if ( $KPIData->{SeverityOrder} eq 'Descending' ){
					%Rules = (
						Fourth => $KPIData->{Rules}->{Rule1},
						Third => $KPIData->{Rules}->{Rule2},
						Second => $KPIData->{Rules}->{Rule3},
						First => $KPIData->{Rules}->{Rule4},
					);
				}
				else{

					%Rules = (
						First => $KPIData->{Rules}->{Rule1},
						Second => $KPIData->{Rules}->{Rule2},
						Third => $KPIData->{Rules}->{Rule3},
						Fourth => $KPIData->{Rules}->{Rule4},
					);
				}

				my $MaxValue   = $KPIData->{MaxValue} || 100;
				my $MinValue   = $KPIData->{MinValue} || 0;
				my $TicPercent = (100 * $Tickets)/$MaxValue;
				my $Label = '';

				if ( $TicPercent <= 25 ){
					$Label = $Rules{First};
				}
				elsif ( $TicPercent  > 25 &&  $TicPercent  < 50 ){
					$Label = $Rules{Second};
				}
				elsif ( $TicPercent  >= 50 && $TicPercent < 75 ){
					$Label = $Rules{Third};
				}
				elsif ( $TicPercent  >= 75 ){
					$Label = $Rules{Fourth};
				}

				if($Tickets > 0 && $Tickets < $MinValue){
					$Label = "Abaixo";
				}

				push @Data, {
					ID    => "GaugeChart_$KPIData->{ID}_$Param{SerieID}",
					Total => $Tickets,
					Label => $Label,
					Min   => $MinValue,
					Max   => $MaxValue,
					TypeKPI => $KPIData->{TypeKPI},
					RealID => $KPIData->{ID}
				};

			}
			elsif ($KPIData->{TypeKPI} eq 'Numeric'){
				push @Data, {
					ID    => "NumericChart_$KPIData->{ID}_$Param{SerieID}",
					Total => $Tickets,
					TypeKPI => $KPIData->{TypeKPI},
					RealID => $KPIData->{ID}
				};
			}
			elsif ($KPIData->{Metric} eq 'Percentage'){
				# Survey count
				my $SurveyObject = $Kernel::OM->Get('Kernel::System::Survey');

				# searches for all the answers survey in a period.
				my $Requests = $KPIObject->FilterPublicSurveyKeyGet (
					SurveyID => $KPIData->{SurveyID},
					RequestSendTimeNewerDate    => $KPIData->{StartDateSendTime},  
					RequestSendTimeOlderDate    => $KPIData->{StopDateSendTime},   
					RequestVoteTimeNewerDate    => $KPIData->{StartDateVoteTime},  
					RequestVoteTimeOlderDate    => $KPIData->{StopDateVoteTime},   
					RequestCreateTimeNewerDate  => $KPIData->{StartDateCreateTime},  
					RequestCreateTimeOlderDate  => $KPIData->{StopDateCreateTime}, 
				);

				my @AllVotes;
				for my $RequestData (@{$Requests}){
					
						my @Vote = $SurveyObject->VoteGet(
							RequestID => $RequestData->{RequestID},
							QuestionID => $KPIData->{QuestionID}
						);

						push @AllVotes,  @Vote;				
				}

				my $CountVote = 0;
				for my $Vote (@AllVotes){
					
					if ($Vote->{VoteValue} eq  $KPIData->{AnswerID}){
						$CountVote ++;
					}
				}		

				my $Percent = 0;

				my $RequestComplete = $SurveyObject->RequestCount(
					SurveyID => $KPIData->{SurveyID},
					ValidID  => 0,
				);

				# calculate the percents
				if ($RequestComplete) {
					$Percent = 100 / $RequestComplete * $CountVote;
					$Percent = sprintf( "%.2f", $Percent );
				}
				
				if($Param{SerieType} eq 'Simple'){
					push @Data, {
						ID    => "SimpleChart_$KPIData->{ID}_$Param{SerieID}",
						Total => $Percent,
						TypeKPI => 'Simple',
						RealID => $KPIData->{ID}
					};
				}else{
					push @Data, {
						ID    => "SurveyChart_$KPIData->{ID}_$Param{SerieID}",
						Total => $Percent,
						TypeKPI => 'Graphic',
						RealID => $KPIData->{ID}
					};
				}
			

			}
			elsif($KPIData->{ObjectType} eq 'Config Items'){
				my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

				# get current definition
				my $XMLDefinition = $ConfigItemObject->DefinitionGet(
					ClassID => $KPIData->{ClassID},
				);

				# get xml search form
				my $XMLFormData = [];
				my $XMLGetParam = [];
				$Self->_XMLSearchFormGet(
					XMLDefinition => $XMLDefinition->{DefinitionRef},
					XMLFormData   => $XMLFormData,
					XMLGetParam   => $XMLGetParam,
					%{$KPIData->{Search}},
				);
				
				my %GetParam;
				$GetParam{What} = $XMLFormData;
				

				my $SearchResultList = $ConfigItemObject->ConfigItemSearchExtended(
					%GetParam,
					ClassIDs         => [$KPIData->{ClassID}],
				);

				if($Param{SerieType} eq 'Simple'){
					push @Data, {
						ID    => "SimpleITSMChart_$KPIData->{ID}_$Param{SerieID}",
						Total => scalar @{$SearchResultList},
						TypeKPI => 'SimpleITSM',
						RealID => $KPIData->{ID}
					};
				}
				else{
					push @Data, {
						ID    => "ConfigItemsChart_$KPIData->{ID}_$Param{SerieID}",
						Total => scalar @{$SearchResultList},
						TypeKPI => 'Graphic',
						RealID => $KPIData->{ID}
					};
				}
			}		
			else{
				#To SQL Query
				my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
				my $MatchesFound;

				# fetch database and add row blocks
				if ($DBObject->Prepare(	SQL   => $KPIData->{SQL})){
					ROW:
					while ( my @Row = $DBObject->FetchrowArray( RowNames => 1 ) ) {

						$MatchesFound++;
					}
				}

				push @Data, {
					ID    => "SQLQueryChart_$KPIData->{ID}_$Param{SerieID}",
					Total => $MatchesFound,
					TypeKPI => 'SQLQuery',
					RealID => $KPIData->{ID}
				};

			}	
		}	
	}


	return @Data;

}

sub _XMLSearchFormGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    return if !$Param{XMLDefinition};
    return if !$Param{XMLFormData};
    return if !$Param{XMLGetParam};
    return if ref $Param{XMLDefinition} ne 'ARRAY';
    return if ref $Param{XMLFormData} ne 'ARRAY';
    return if ref $Param{XMLGetParam} ne 'ARRAY';

    $Param{Level} ||= 0;

    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {

        # create inputkey
        my $InputKey = $Item->{Key};
        if ( $Param{Prefix} ) {
            $InputKey = $Param{Prefix} . '::' . $InputKey;
        }

        # Date type fields must to get all date parameters.
        if ( $Item->{Input}->{Type} eq 'Date' && $Param{$InputKey} ) {
            $Param{$InputKey} =
                {
                $InputKey                      => $Param{$InputKey},
                $InputKey . '::TimeStart::Day' => $Param{ $InputKey . '::TimeStart::Day' },
                $InputKey
                    . '::TimeStart::Month' => $Param{ $InputKey . '::TimeStart::Month' },
                $InputKey . '::TimeStart::Year' => $Param{ $InputKey . '::TimeStart::Year' },
                $InputKey . '::TimeStop::Day'   => $Param{ $InputKey . '::TimeStop::Day' },
                $InputKey . '::TimeStop::Month' => $Param{ $InputKey . '::TimeStop::Month' },
                $InputKey . '::TimeStop::Year'  => $Param{ $InputKey . '::TimeStop::Year' },
                } || '';
        }

        # Date-time type fields must get all date and time parameters.
        elsif ( $Item->{Input}->{Type} eq 'DateTime' && $Param{$InputKey} ) {
            $Param{$InputKey} =
                {
                $InputKey => $Param{$InputKey},
                $InputKey
                    . '::TimeStart::Minute' => $Param{ $InputKey . '::TimeStart::Minute' },
                $InputKey . '::TimeStart::Hour' => $Param{ $InputKey . '::TimeStart::Hour' },
                $InputKey . '::TimeStart::Day'  => $Param{ $InputKey . '::TimeStart::Day' },
                $InputKey
                    . '::TimeStart::Month' => $Param{ $InputKey . '::TimeStart::Month' },
                $InputKey . '::TimeStart::Year' => $Param{ $InputKey . '::TimeStart::Year' },
                $InputKey
                    . '::TimeStop::Minute' => $Param{ $InputKey . '::TimeStop::Minute' },
                $InputKey . '::TimeStop::Hour'  => $Param{ $InputKey . '::TimeStop::Hour' },
                $InputKey . '::TimeStop::Day'   => $Param{ $InputKey . '::TimeStop::Day' },
                $InputKey . '::TimeStop::Month' => $Param{ $InputKey . '::TimeStop::Month' },
                $InputKey . '::TimeStop::Year'  => $Param{ $InputKey . '::TimeStop::Year' },
                } || '';
        }

        # get search form data
        my $Values = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->ITSMConfigItemSearchFormDataGet(
            Key   => $InputKey,
            Item  => $Item,
            Value => $Param{$InputKey},
        );

        # create search key
        my $SearchKey = $InputKey;
        $SearchKey =~ s{ :: }{\'\}[%]\{\'}xmsg;
        $SearchKey = "[1]{'Version'}[1]{'$SearchKey'}[%]{'Content'}";

        # ITSMConfigItemSearchFormDataGet() can return string, arrayref or hashref
        if ( ref $Values eq 'ARRAY' ) {

            # filter empty elements
            my @SearchValues = grep {$_} @{$Values};

            if (@SearchValues) {
                push @{ $Param{XMLFormData} }, {
                    $SearchKey => \@SearchValues,
                };

                push @{ $Param{XMLGetParam} }, {
                    $InputKey => \@SearchValues,
                };
            }

        }
        elsif ($Values) {

            # e.g. for Date between searches
            push @{ $Param{XMLFormData} }, {
                $SearchKey => $Values,
            };

            if ( ref $Values eq 'HASH' ) {
                if ( $Item->{Input}->{Type} eq 'Date' ) {
                    if ( $Values->{'-between'} ) {

                        # get time elemet values
                        my ( $StartDate, $StopDate ) = @{ $Values->{'-between'} };
                        my ( $StartYear, $StartMonth, $StartDay ) = split( /-/, $StartDate );
                        my ( $StopYear,  $StopMonth,  $StopDay )  = split( /-/, $StopDate );

                        # store time elment values
                        push @{ $Param{XMLGetParam} }, {
                            $InputKey                        => 1,
                            $InputKey . '::TimeStart::Day'   => $StartDay,
                            $InputKey . '::TimeStart::Month' => $StartMonth,
                            $InputKey . '::TimeStart::Year'  => $StartYear,
                            $InputKey . '::TimeStop::Day'    => $StopDay,
                            $InputKey . '::TimeStop::Month'  => $StopMonth,
                            $InputKey . '::TimeStop::Year'   => $StopYear,
                        };
                    }
                }
                elsif ( $Item->{Input}->{Type} eq 'DateTime' ) {
                    if ( $Values->{'-between'} ) {

                        # get time elemet values
                        my ( $StartDateTime, $StopDateTime ) = @{ $Values->{'-between'} };
                        my ( $StartDate,     $StartTime )    = split( /\s/, $StartDateTime );
                        my ( $StartYear, $StartMonth,  $StartDay )    = split( /-/,  $StartDate );
                        my ( $StartHour, $StartMinute, $StartSecond ) = split( /\:/, $StartTime );

                        my ( $StopDate, $StopTime ) = split( /\s/, $StopDateTime );
                        my ( $StopYear, $StopMonth,  $StopDay )    = split( /-/,  $StopDate );
                        my ( $StopHour, $StopMinute, $StopSecond ) = split( /\:/, $StopTime );

                        # store time elment values
                        push @{ $Param{XMLGetParam} }, {
                            $InputKey                         => 1,
                            $InputKey . '::TimeStart::Minute' => $StartMinute,
                            $InputKey . '::TimeStart::Hour'   => $StartHour,
                            $InputKey . '::TimeStart::Day'    => $StartDay,
                            $InputKey . '::TimeStart::Month'  => $StartMonth,
                            $InputKey . '::TimeStart::Year'   => $StartYear,
                            $InputKey . '::TimeStop::Minute'  => $StopMinute,
                            $InputKey . '::TimeStop::Hour'    => $StopHour,
                            $InputKey . '::TimeStop::Day'     => $StopDay,
                            $InputKey . '::TimeStop::Month'   => $StopMonth,
                            $InputKey . '::TimeStop::Year'    => $StopYear,
                        };
                    }
                }
            }
            else {
                push @{ $Param{XMLGetParam} }, {
                    $InputKey => $Values,
                };
            }

        }

        next ITEM if !$Item->{Sub};

        # start recursion, if "Sub" was found
        $Self->_XMLSearchFormGet(
            %Param,
            XMLDefinition => $Item->{Sub},
            XMLFormData   => $Param{XMLFormData},
            XMLGetParam   => $Param{XMLGetParam},
            Level         => $Param{Level} + 1,
            Prefix        => $InputKey,
        );
    }

    return 1;
}

sub _BuildParametersToComplex {
	my ( $Self, %Param ) = @_;

	# create needed objects
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

	my @UserGroups = @{$Param{UserGroups}};

	my @ReturnTochart;

	for (my $i = 1; $i <= $Param{SeriesData}->{QtdColumn}; $i++) {

		my $NameAssociatedKPI = 'AssociatedKPIsCol' . $i ;
		my $ChartTypeCol      = 'ChartTypeCol' . $i ;
		my $ChartLabelType    = 'TypeLabelCol' . $i ;
		my $ChartScaleUnit    = 'ChartScaleUnitCol' . $i ;
		my $ChartScaleTime    = 'ChartScaleTimeCol' . $i ;
	
		my @KPIs = split ",", $Param{SeriesData}->{$NameAssociatedKPI};

		my @ColumnsEnabledKPI;
		my %ColumnsColor;
		
		my %DataChart;

		foreach my $KPIID (@KPIs ){

			my $KPI = $KPIObject->KPIGet(
				ID => $KPIID,
				ValidID => 1
			);

			push @ColumnsEnabledKPI, $KPI->{Name};
			$ColumnsColor{ $KPI->{Name} } =  $KPI->{Color} ;
		
		}

		my @DataChart = $Self->_BuildParameters(
			UserGroups => \@UserGroups,
			ColumnsEnabled => \@ColumnsEnabledKPI,
			SerieID =>  $Param{SeriesData}->{ID},
			ChartType => $Param{SeriesData}->{$ChartTypeCol},
			ChartScaleUnit => $Param{SeriesData}->{$ChartScaleUnit},
			ChartScaleTime => $Param{SeriesData}->{$ChartScaleTime},
		);

		my $ChartType;

		if( $Param{SeriesData}->{$ChartTypeCol} eq 'Pie'){
			$ChartType = 'pie';
		}
		elsif($Param{SeriesData}->{$ChartTypeCol} eq 'Bar'){
			$ChartType = 'bar';
		}
		elsif($Param{SeriesData}->{$ChartTypeCol} eq 'Donut'){
			$ChartType = 'donut';
		}
		elsif($Param{SeriesData}->{$ChartTypeCol} eq 'Column'){
			$ChartType = 'bar';
		}
		elsif($Param{SeriesData}->{$ChartTypeCol} eq 'Line'){
			$ChartType = 'line';
		}

		my @Return;

		my $TotalTicketSearch = 0;
		my $TotalTicketsOfScale = 0;

		for my $CData (@DataChart){			

			if($Param{SeriesData}->{$ChartTypeCol} eq 'Line'){
				push  @Return, $CData->{Total};
				$TotalTicketSearch = $TotalTicketSearch + $CData->{TotalTicketSearch};
				$TotalTicketsOfScale = $TotalTicketsOfScale + $CData->{TotalTicketsOfScale};
			}else{
				my @ArrayData;

				my %Hash = (
					$CData->{TypeKPI} => $CData->{Total}
				);

				my $KPIName = $KPIObject->KPILookupByName(
					ID => $CData->{RealID} 
				);

				push  @ArrayData, $KPIName;
				push  @ArrayData,  $CData->{Total};
				push  @Return, \@ArrayData;

			}	

		}
		
		my $ReturnPhrase = $LayoutObject->{LanguageObject}->Translate('Showing %s tickets out of %s. According to the scale filter', $TotalTicketsOfScale, $TotalTicketSearch);

		if($Param{SeriesData}->{$ChartTypeCol} eq 'Line'){
			my @LabelLine;
			push @LabelLine, 'x';

			my %MapMonths = (
				"1" =>  $LayoutObject->{LanguageObject}->Translate('Jan'),
				"2" =>  $LayoutObject->{LanguageObject}->Translate('Feb'),
				"3" =>  $LayoutObject->{LanguageObject}->Translate('Mar'),
				"4" =>  $LayoutObject->{LanguageObject}->Translate('Apr'),
				"5" =>  $LayoutObject->{LanguageObject}->Translate('May'),
				"6" =>  $LayoutObject->{LanguageObject}->Translate('Jun'),
				"7" =>  $LayoutObject->{LanguageObject}->Translate('Jul'),
				"8" =>  $LayoutObject->{LanguageObject}->Translate('Aug'),
				"9" =>  $LayoutObject->{LanguageObject}->Translate('Sep'),
				"10" => $LayoutObject->{LanguageObject}->Translate('Oct'),
				"11" => $LayoutObject->{LanguageObject}->Translate('Nov'),
				"12" => $LayoutObject->{LanguageObject}->Translate('Dec')
			);

			my %MapScale = (
				Day  => "Days",
				Month => "Months",
				Quarter => "Months",
				Semester => "Months",
				Year => "Years",
			);

			my $DateTimeObject = $Kernel::OM->Create(
				'Kernel::System::DateTime'
			);

			my $ScaleTime = $Param{SeriesData}->{$ChartScaleTime};
			my $ToCurrentMonth = 0;

			if($Param{SeriesData}->{$ChartScaleUnit} eq 'Quarter'){
				$ScaleTime = ($Param{SeriesData}->{$ChartScaleTime} * 3) - 1;
			}
			elsif($Param{SeriesData}->{$ChartScaleUnit} eq 'Semester'){
				$ScaleTime = ($Param{SeriesData}->{$ChartScaleTime} * 6) - 1;
			}
			else{
				$ToCurrentMonth++;
			}

			my $Success = $DateTimeObject->Subtract(
				$MapScale{$Param{SeriesData}->{$ChartScaleUnit}} => $ScaleTime,				
			);
			
			for my $Key ( 1 .. $Param{SeriesData}->{$ChartScaleTime} + $ToCurrentMonth ) {

				my @TicketsInDate;

				my $DateTimeSettings = $DateTimeObject->Get();

				my $StartTimeObject = $Kernel::OM->Create(
					'Kernel::System::DateTime',
					ObjectParams => {
						String   => $DateTimeObject->ToString(),
					}
				);

				if($Param{SeriesData}->{$ChartScaleUnit} eq 'Day'){							

					my $SuccessAddDay = $DateTimeObject->Add(						
						Days          => 1,
					);

					push @LabelLine, "$DateTimeSettings->{Day}/$DateTimeSettings->{Month}";
										
				}
				elsif($Param{SeriesData}->{$ChartScaleUnit} eq 'Month'){			
					
					my $SuccessAddMonth = $DateTimeObject->Add(				
						Months  => 1,
					);

					push @LabelLine, $MapMonths{"$DateTimeSettings->{Month}"};
				}
				elsif($Param{SeriesData}->{$ChartScaleUnit} eq 'Year'){			
				
					my $SuccessAddYear = $DateTimeObject->Add(				
						Years          => 1,
					);

					push @LabelLine, $DateTimeSettings->{Year};

				}
				elsif($Param{SeriesData}->{$ChartScaleUnit} eq 'Quarter'){
					my $SuccessAddQuarter = $DateTimeObject->Add(				
						Months  => 3,
					);

					my $LabelTrim = $LayoutObject->{LanguageObject}->Translate('Trim');

					push @LabelLine, "$Key $LabelTrim";

				}
				elsif($Param{SeriesData}->{$ChartScaleUnit} eq 'Semester'){
					my $SuccessAddSemester = $DateTimeObject->Add(				
						Months  => 6,
					);

					my $LabelSem = $LayoutObject->{LanguageObject}->Translate('Sem');

					push @LabelLine, "$Key $LabelSem";
				}
			}	
			push  @Return, \@LabelLine;			
		}
		
		my %DataValues = (
			columns => \@Return,
			colors  => \%ColumnsColor,
			type    =>  $ChartType,	
		);

		if($Param{SeriesData}->{$ChartTypeCol} eq 'Line'){
			$DataValues{x} = 'x';
		}

		# Data to send to .js 
		if($Param{SeriesData}->{$ChartTypeCol} eq 'Column'){		
			%DataChart = (
				data => {
					columns => \@Return,
					colors  => \%ColumnsColor,
					type =>  $ChartType,
				},
				typeRotate => 'Column',
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'Complex'

			);
		}else{		

			%DataChart = (
				data => \%DataValues,						
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				chartLabelType => $Param{SeriesData}->{$ChartLabelType},
				TypeKPI => 'Complex',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '75',
						},
					},
				},
				returnPhrase => $ReturnPhrase, 		
			);
		}

		if($Param{SeriesData}->{"TypeLabelCol$i"} eq 'Percentage'){
			%DataChart = (
				data => \%DataValues,	
				typeRotate => 'Column',
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'Complex',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '75',
						},
					},
				},
				returnPhrase => $ReturnPhrase, 						
			);
		}		

		push  @ReturnTochart, \%DataChart;

	}
	
	return @ReturnTochart;
	
}

sub _GetSearchProfiles {
	my ( $Self, %Param ) = @_;

	my $SearchProfileObject = $Kernel::OM->Get('Kernel::System::SearchProfile');
	my $UserObject          = $Kernel::OM->Get('Kernel::System::User');
	my $ConfigObject        = $Kernel::OM->Get('Kernel::Config');
	my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $ParamObject         = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject        = $Kernel::OM->Get('Kernel::System::Ticket');
	my $JSONObject          = $Kernel::OM->Get('Kernel::System::JSON');
	my $KPIObject           = $Kernel::OM->Get('Kernel::System::KPI');

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

		next PROFILE if(!defined $ProfileName);

		my $KPIID = $KPIObject->KPILookup(
			Name => $ProfileName,
		);

		my $KPI = $KPIObject->KPIGet(
			ID => $KPIID,
			ValidID => 1
		);
		
		my %GetParam;
		if($KPI->{ObjectType} eq 'Ticket'){
			
			if ( IsHashRefWithData($KPI->{Search}) ){
				%GetParam = %{$KPI->{Search}};
			}
			else{
				next PROFILE;
			}

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

			push @ProfileSearch, {
				Title => $ProfileName,
				KPIID => $KPIID,
				ProfileSearch => \%GetParam,
				DynamicFieldSearch => \%DynamicFieldSearchParameters ,
				Limit => $SearchLimit,
				UserPermissionSearch => $ProfileUserPermission{$ProfileName},
			};
		}elsif($KPI->{ObjectType} eq 'SQL Query'){
			
			push @ProfileSearch, {
				Title => $ProfileName,
				KPIID => $KPIID,
				ProfileSearch => \%GetParam,
				UserPermissionSearch => $ProfileUserPermission{$ProfileName},
			};


		}elsif($KPI->{ObjectType} eq 'ChartSQLQuery'){
			push @ProfileSearch, {
				Title => $ProfileName,
				KPIID => $KPIID,
				ProfileSearch => \%GetParam,
				UserPermissionSearch => $ProfileUserPermission{$ProfileName},
			};

		}elsif($KPI->{ObjectType} eq 'Survey'){

			push @ProfileSearch, {
				Title => $ProfileName,
				KPIID => $KPIID,
				ProfileSearch => \%GetParam,
				UserPermissionSearch => $ProfileUserPermission{$ProfileName},
			};		
		}elsif($KPI->{ObjectType} eq 'Config Items'){

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

sub _BuildParametersToChartSQL {
	my ( $Self, %Param ) = @_;
	
	# create needed objects
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
	my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

	my @UserGroups = @{$Param{UserGroups}};

	my @ReturnTochart;

	for (my $i = 1; $i <= $Param{SeriesData}->{QtdColumn}; $i++) {

		my $NameAssociatedKPI = 'AssociatedKPIsChartSQLCol' . $i ;
		my $ChartLabelType    = 'TypeLabelChartSQLCol' . $i ;
	
		my @KPIs = split ",", $Param{SeriesData}->{$NameAssociatedKPI};
	
		my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
        my @Rows;
        my @Head;
		my $KPI;
		my $MatchesFound;
		my %DataChart;
		
		foreach my $KPIID ( @KPIs ){

			$KPI = $KPIObject->KPIGet(
				ID => $KPIID,
				ValidID => 1
			);	
		}

		$KPI->{SQL} = $Self->_ReplaceSQLAttributes(
			Message       =>  $KPI->{SQL},
		);  

		$DBObject->Prepare( SQL => $KPI->{SQL} );

        @Head = $DBObject->GetColumnNames();

		ROW:
		while ( my @Row = $DBObject->FetchrowArray( RowNames => 1 ) ) {

			$MatchesFound++;

			push @Rows, \@Row;
		}

		if ( $KPI->{ReturnChart} eq 'Pie' ) {
			
			my %Data = (
				'x'       => '',
				'columns' => \@Rows,
				'type'    => 'pie',
				# 'Labels'  => 'true',
				'groups'  => 0,
				'rotated' => 0,
			);

			%DataChart = (
				data => \%Data,	
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'ChartSQLQuery',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '',
						},
					},
				},
			);
		}

		elsif ( $KPI->{ReturnChart} eq 'Column' ) {
			
			my @AxisY;
			my @Columns;
			my $Count = 0;

			push @AxisY, 'x';
			foreach my $Row ( @Rows ) {

				push @AxisY, $Row->[0];
			}

			push @Columns, \@AxisY;

			HEADER:
			for my $Header ( @Head ) {
				
				next HEADER if $Header eq $Head[0];

				my @Values;
				
				push @Values, $Header;

				ROW:
				for my $Row ( @Rows ) {
					
					next ROW if $Row eq $Rows[$Count]->[0];

					VALUES:
					for my $Value ( @{$Row} ) {
						
						next VALUES if $Value eq $Row->[0];
						
						push @Values, $Row->[$Count+1];
						last VALUES;
					}
				}
				
				push @Columns, \@Values;
				$Count++;
				
			}

			my %Data = (
				'x'       => 'x',
				'columns' => \@Columns,
				'type'    => 'bar',
				'groups'  => 0,
				'rotated' => 0,
			);
				

			%DataChart = (
				data => \%Data,	
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'ChartSQLQuery',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '',
						},
					},
				},
					
			);
		}

		elsif ( $KPI->{ReturnChart} eq 'Stacked Column' ) {

			my @AxisY;
			my @Columns;
			my @Group;
			my @Groups;
			my $Count = 0;

			push @AxisY, 'x';
			foreach my $Row ( @Rows ) {

				push @AxisY, $Row->[0];
			}

			push @Columns, \@AxisY;

			HEADER:
			for my $Header ( @Head ) {
				
				next HEADER if $Header eq $Head[0];
				
				my @Values;
				
				push @Values, $Header;
				push @Group, $Header;

				ROW:
				for my $Row ( @Rows ) {

					next ROW if $Row eq $Rows[$Count]->[0];

					VALUES:
					for my $Value ( @{$Row} ) {
						
						next VALUES if $Value eq $Row->[0];
						
						push @Values, $Row->[$Count+1];
						last VALUES;
					}
				}
				
				push @Columns, \@Values;
				$Count++;
				
			}

			push @Groups, \@Group;

			my %Data = (
				'x'       => 'x',
				'columns' => \@Columns,
				'type'    => 'bar',
				'groups'  => \@Groups,
				'rotated' => 0,
			);
			
			%DataChart = (
				data => \%Data,	
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'ChartSQLQuery',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '',
						},
					},
				},
			
			);		
		}

		elsif ( $KPI->{ReturnChart} eq 'Bar' ) {

			my @AxisY;
			my @Columns;
			my $Count = 0;

			push @AxisY, 'x';
			foreach my $Row ( @Rows ) {

				push @AxisY, $Row->[0];
			}

			push @Columns, \@AxisY;

			HEADER:
			for my $Header ( @Head ) {
				
				next HEADER if $Header eq $Head[0];
				
				my @Values;
				
				push @Values, $Header;

				ROW:
				for my $Row ( @Rows ) {

					next ROW if $Row eq $Rows[$Count]->[0];

					VALUES:
					for my $Value ( @{$Row} ) {
						
						next VALUES if $Value eq $Row->[0];
						
						push @Values, $Row->[$Count+1];
						last VALUES;
					}
				}
				
				push @Columns, \@Values;
				$Count++;
				
			}

			my %Data = (
				'x'       => 'x',
				'columns' => \@Columns,
				'type'    => 'bar',
				'groups'  => 0,
				'rotated' => 'true',
			);

			%DataChart = (
				data => \%Data,	
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'ChartSQLQuery',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '',
						},
					},
				},
			);	
		}

		elsif ( $KPI->{ReturnChart} eq 'Stacked Bar' ) {

			my @AxisY;
			my @Columns;
			my @Group;
			my @Groups;
			my $Count = 0;

			push @AxisY, 'x';
			foreach my $Row ( @Rows ) {

				push @AxisY, $Row->[0];
			}
			
			push @Columns, \@AxisY;

			HEADER:
			for my $Header ( @Head ) {
				
				next HEADER if $Header eq $Head[0];
				
				my @Values;
				
				push @Values, $Header;
				push @Group, $Header;

				ROW:
				for my $Row ( @Rows ) {

					next ROW if $Row eq $Rows[$Count]->[0];

					VALUES:
					for my $Value ( @{$Row} ) {
						
						next VALUES if $Value eq $Row->[0];
						
						push @Values, $Row->[$Count+1];
						last VALUES;
					}
				}
				
				push @Columns, \@Values;
				$Count++;
				
			}

			push @Groups, \@Group;

			my %Data = (
				'x'       => 'x',
				'columns' => \@Columns,
				'type'    => 'bar',
				'groups'  => \@Groups,
				'rotated' => 1,
			);

			%DataChart = (
				data => \%Data,	
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'ChartSQLQuery',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '',
						},
					},
				},
			);
		}

		elsif ( $KPI->{ReturnChart} eq 'Donut' ) {

			my %Data = (
				'x'       => '',
				'columns' => \@Rows,
				'type'    => 'donut',
				'groups'  => 0,
				'rotated' => 0,
			);			

			%DataChart = (
				data => \%Data,	
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'ChartSQLQuery',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '',
						},
					},
				},
					
			);

		}

		elsif ( $KPI->{ReturnChart} eq 'Line' ) {

			my %Data = (
				'x'       => '',
				'columns' => \@Rows,
				'type'    => 'line',
				'groups'  => 0,
				'rotated' => 0,
			);			

			%DataChart = (
				data => \%Data,	
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'ChartSQLQuery',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '',
						},
					},
				},
					
			);

		}

		elsif ( $KPI->{ReturnChart} eq 'Area' ) {

			my %Data = (
				'x'       => '',
				'columns' => \@Rows,
				'type'    => 'area',
				'groups'  => 0,
				'rotated' => 0,
			);			

			%DataChart = (
				data => \%Data,	
				serieID => $Param{SeriesData}->{ID},
				columnID => $i,
				qtdColumn => $Param{SeriesData}->{QtdColumn},
				TypeKPI => 'ChartSQLQuery',
				axis => {
					x => {
						type => 'category',
						tick => {
							rotate => '',
						},
					},
				},
					
			);

		}

		$DataChart{KPIID} = $KPI->{ID};
		$DataChart{DisplayText} = $KPI->{DisplayTextChart};
		push  @ReturnTochart, \%DataChart;

	}

	return @ReturnTochart;
	
}

sub _ReplaceSQLAttributes {
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

        $Param{Message} =~ s{<OTRS_SELF_USERID>}{$Self->{UserID} // ''}ige;
        
    }

    return $Param{Message};
}

1;