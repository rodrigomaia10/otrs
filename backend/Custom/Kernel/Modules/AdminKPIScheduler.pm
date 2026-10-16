# --
# Kernel/Modules/AdminKPIScheduler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminKPIScheduler;

use strict;
use warnings;
use utf8;
use Kernel::System::VariableCheck qw(:all);
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

    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
	my $KPIObject     = $Kernel::OM->Get('Kernel::System::KPI');
    my $SchedulerDBObject  = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB');

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get config data
    $Self->{OldProfile} = $ParamObject->GetParam( Param => 'OldProfile' ) || '';
    $Self->{Profile}    = $ParamObject->GetParam( Param => 'Profile' )    || '';

    # ------------------------------------------------------------ #
    # Series edit
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'KPISchedulerEdit' ) {

        # header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # html output
        $Output .= $Self->_MaskNew(
            %Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
    # ------------------------------------------------------------ #
    # Series save
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'KPISchedulerSave' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

        # get params
        my %GetParam;
        for (qw( ValidID Prefix AdditionalEmails TemplateKPIID )) {
            $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
        }

        # get array params
        for my $Parameter (
            qw(ScheduleDays ScheduleMinutes ScheduleHours ScheduleMonth ScheduleDaysOfWeek TypeExport GroupIDs AssociatedKPIs AssociatedStats)
            )
        {

            # get search array params (get submitted params)
            if ( $ParamObject->GetArray( Param => $Parameter ) ) {
                @{ $GetParam{$Parameter} } = $ParamObject->GetArray( Param => $Parameter );
            }
        }   

        my %Error;

        # check needed data
        if ( !$Self->{Profile} ) {
            $Error{ProfileInvalid} = 'ServerError';
        }


        if ( !%Error ) {

            if ( $Self->{OldProfile} ) {

                # remove/clean up old profile stuff
                $KPIObject->JobDelete(
                    Name   => $Self->{OldProfile},
                    UserID => $Self->{UserID},
                );
            }

            my $JobAddResult = $KPIObject->JobAdd(
                Name   => $Self->{Profile},
                UserID => $Self->{UserID},
                Data   => {
                    %GetParam,
                },
            );
            
            my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
            

            if ( !%Error ) {
                # redirect to overview
                return $LayoutObject->Redirect( OP => "Action=$Self->{Action}" );
            }
        }

        # something went wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $Error{Message}
            ? $LayoutObject->Notify(
            Priority => 'Error',
            Info     => $Error{Message},
            )
            : '';

        # html output
        $Output .= $Self->_MaskNew(
            %Error,
            %GetParam,
            %Param,
        );
        $Output .= $LayoutObject->Footer();

    }
    # ------------------------------------------------------------ #
    # Delete a KPI Scheduler
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Delete' && $Self->{Profile} ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        if ( $Self->{Profile} ) {

            my @List = $SchedulerDBObject->FutureTaskList(
                Type => 'KPIScheduler',
            );

            for (@List){

                if($_->{Name} eq $Self->{Profile}){

                    my $Success = $SchedulerDBObject->FutureTaskDelete(
                        TaskID => $_->{TaskID},
                    );
                }
            }

            $KPIObject->JobDelete(
                Name   => $Self->{Profile},
                UserID => $Self->{UserID},
            );
        }

        return $LayoutObject->Redirect(
            OP => "Action=$Self->{Action}",
        );
    }
    # ------------------------------------------------------------ #
    # KPI Scheduler Copy
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'KPISchedulerCopy' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPISchedulerCopy(
            Name => $Self->{Profile},
        );

    }
    # ------------------------------------------------------------ #
    # KPI Scheduler overview
    # ------------------------------------------------------------ #
    else {

        # output header
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # output overview
        $LayoutObject->Block(
            Name => 'Overview',
            Data => { %Param, },
        );

        $LayoutObject->Block( Name => 'ActionList' );
        $LayoutObject->Block( Name => 'ActionAdd' );
        $LayoutObject->Block( Name => 'Overview2' );

        my %Jobs = $KPIObject->JobList();

        
        # if there are any data, it is shown
        if (%Jobs) {

            my $LanguageObject = $Kernel::OM->Get('Kernel::Language');

            for my $JobKey ( sort keys %Jobs ) {

                my %JobData  = $KPIObject->JobGet( Name => $JobKey );

                # get daemon modules from SysConfig
                my $DaemonModuleConfig = $Kernel::OM->Get('Kernel::Config')->Get('DaemonModules') || {};

                # getting job daemon infos
                MODULE:
                for my $Module ( sort _DaemonSort keys %{$DaemonModuleConfig} ) {

                    # skip not well configured modules
                    next MODULE if !$Module;
                    next MODULE if !$DaemonModuleConfig->{$Module};
                    next MODULE if ref $DaemonModuleConfig->{$Module} ne 'HASH';
                    next MODULE if !$DaemonModuleConfig->{$Module}->{Module};

                    my $DaemonObject;

                    # create daemon object
                    eval {
                        $DaemonObject = $Kernel::OM->Get( $DaemonModuleConfig->{$Module}->{Module} );
                    };

                    # skip module if object could not be created or does not provide Summary()
                    next MODULE if !$DaemonObject;
                    next MODULE if !$DaemonObject->can("Summary");

                    # execute Summary
                    my @Summary;

                    eval {
                        @Summary = $DaemonObject->Summary();
                    };

                    # skip if the result is empty or in a wrong format;
                    next MODULE if !@Summary;
                    next MODULE if ref $Summary[0] ne 'HASH';

                    for my $SummaryItem (@Summary) {

                        # getting next execution 
                        if( scalar @{ $SummaryItem->{Data} } != 0 ){

                            my $FirstFlag = 0;

                            DAEMONDATA:
                            for my $DaemonData ( @{ $SummaryItem->{Data} } ){
                                
                                next DAEMONDATA if $FirstFlag == 1;

                                if( exists $DaemonData->{ExecutionTime} && $DaemonData->{Name} eq $JobData{Name} ){

                                    $JobData{NextExecution} = $LanguageObject->FormatTimeString(
                                        $DaemonData->{ExecutionTime},  # timestamp
                                        'DateFormat',
                                        1,                             # optional, hides the seconds from the time output
                                    );

                                    $FirstFlag = 1;
                                }
                            }
                        }
                    }              
                }    

                my %LastExecution = $KPIObject->JobGetLastExecution( Name => $JobKey );

                # css setting and text for valid or invalid jobs
                $JobData{ShownValid}    = $JobData{Valid} ? 'valid' : 'invalid';
                $JobData{JobKey}        = $JobKey;
                $JobData{LastExecution} = $LastExecution{ $JobKey };
                
                my @LastExecutionSplit;
                
                if( $LastExecution{ $JobKey }) {
                    @LastExecutionSplit = split(' ', $LastExecution{ $JobKey });
                }

                if(@LastExecutionSplit){

                    $JobData{LastExecution} = $LanguageObject->FormatTimeString(
                        $LastExecutionSplit[0].' '.$LastExecutionSplit[1],  # timestamp
                        'DateFormat',
                        1,                             # optional, hides the seconds from the time output
                    );

                    $JobData{LastExecution} = $JobData{LastExecution} .' '.$LastExecutionSplit[2];
                }

                # separate each search result line by using several css
                $LayoutObject->Block(
                    Name => 'Row',
                    Data => {%JobData},
                );
            }
        }
        # otherwise a no data found message is displayed
        else {
            $LayoutObject->Block(
                Name => 'NoDataFoundMsg',
                Data => {},
            );
        }


        # output overview result
        $LayoutObject->Block(
            Name => 'OverviewList',
            Data => { %Param, },
        );

        # get Series list
        my @SeriesList = $KPIObject->SeriesList();

        # if there are any Series defined, they are shown
        if ( IsArrayRefWithData(\@SeriesList) ) {
            # get valid list
            my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

            for my $SeriesID ( @SeriesList ) {

				my $SeriesData = $KPIObject->SeriesGet(
					ID => $SeriesID,
				);

                # output row
                $LayoutObject->Block(
                    Name => 'OverviewListRow',
                    Data => {
                        %{$SeriesData},
                        Valid => $ValidList{ $SeriesData->{ValidID} },
                    },
                );
            }
        }

        # otherwise a no data found msg is displayed
        else {
            $LayoutObject->Block(
                Name => 'NoDataFoundMsg',
                Data => {},
            );
        }

        # generate output
        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminKPIScheduler',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}

sub _KPISchedulerCopy {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    my %JobData  = $KPIObject->JobGet( Name => $Param{Name} );

    if (! %JobData ) {
        return $LayoutObject->ErrorScreen(
            Message => "Unknown KPI Scheduler $Param{Name}!",
        );
    }
  
    # Create new name.
    my $Count   = 1;
    my $KPISchedulerName = "$Param{Name} (" . $LayoutObject->{LanguageObject}->Translate('Copy') . ") $Count";

    while (
        $KPIObject->JobGet(
            Name   => $KPISchedulerName,
        )
        && 
        $Count < 100
        )
    {
        $KPISchedulerName =~ s/\d+$/$Count/;      
        $Count++;
    }

    my $JobAddResult = $KPIObject->JobAdd(
        Name   => $KPISchedulerName,
        UserID => $Self->{UserID},
        Data   => {
          ValidID => $JobData{ValidID},
          ScheduleHours => $JobData{ScheduleHours} ,
          AdditionalEmails => $JobData{AdditionalEmails},
          ScheduleMinutes => $JobData{ScheduleMinutes},
          ScheduleMonth => $JobData{ScheduleMonth},
          TypeExport => $JobData{TypeExport},
          GroupIDs => $JobData{GroupIDs},
          ScheduleDays => $JobData{ScheduleDays},
          Prefix => $JobData{Prefix},
          TemplateKPIID => $JobData{TemplateKPIID},
          ScheduleDaysOfWeek => $JobData{ScheduleDaysOfWeek},
          AssociatedKPIs => $JobData{AssociatedKPIs},
          AssociatedStats => $JobData{AssociatedStats},
        },
    );
   
    # show if can't create
    if ( !$JobAddResult ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('There was an error creating the copy'),
        );
    }


    return $LayoutObject->Redirect(
        OP => "Action=$Self->{Action}",
    );


}


sub _MaskNew {
    my ( $Self, %Param ) = @_;

    my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');
    my %SeriesData;

    if ( $Self->{Profile} ) {

        # get db job data
        %SeriesData = $KPIObject->JobGet(
            Name => $Self->{Profile},
        );

        $SeriesData{Profile} = $Self->{Profile};
    }
    else{
        $SeriesData{Name} = 'NEW';
    }
    
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # output overview
    $LayoutObject->Block(
        Name => 'Overview',
        Data => { %SeriesData, },
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' );

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get valid list
    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $SeriesData{ValidOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $SeriesData{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize',
    );
    
    my %TypeExport = (
        # PDF => 'PDF',
        Excel => 'Excel',
        HTML  => 'HTML',
    );

    $SeriesData{TypeExportStrg} = $LayoutObject->BuildSelection(
        Data       => \%TypeExport,
        Name       => 'TypeExport',
        SelectedID => $SeriesData{TypeExport} || '',
        Class      => 'Modernize Validate_Required',
        Multiple   => 1
    );

	my $KPIs = $KPIObject->KPIList();

	my %KPIData;

	KPI:
	foreach my $KPIID ( @{$KPIs} ){

		my $KPI = $KPIObject->KPIGet(
			ID => $KPIID,
		);

		next KPI if $KPI->{ValidID} == 0;

		$KPIData{$KPIID} = $KPI->{Name};
	}

	$SeriesData{KPIOptionString} = $LayoutObject->BuildSelection(
        Data       => \%KPIData,
        Name       => 'AssociatedKPIs',
        SelectedID => $SeriesData{AssociatedKPIs},
        Class      => 'Modernize',
		Multiple => 1,
    );

    my %StatsData;

    my $StatsList = $Kernel::OM->Get('Kernel::System::Stats')->StatsListGet(
        UserID => $Self->{UserID},
    );

    STATS:
    for my $StatsID ( keys %{$StatsList} ){
        
		next STATS if $StatsList->{$StatsID}->{Valid} == 0;

		$StatsData{$StatsID} = $StatsList->{$StatsID}->{Title};
    }

    $SeriesData{StatsOptionString} = $LayoutObject->BuildSelection(
        Data       => \%StatsData,
        Name       => 'AssociatedStats',
        SelectedID => $SeriesData{AssociatedStats},
        Class      => 'Modernize',
		Multiple => 1,
    );


	my %Groups       = $Kernel::OM->Get('Kernel::System::Group')->GroupList( Valid => 1 );
	$SeriesData{GroupsStrg} = $LayoutObject->BuildSelection(
        Data         => \%Groups,
        Name         => 'GroupIDs',
        SelectedID   => $SeriesData{GroupIDs},
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize W50pc',
		Multiple     => 1,
    );

    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');

    # get std template list
    my %StandardTemplateData = $StandardTemplateObject->StandardTemplateList(
        Valid => 1,
        Type  => 'KPIScheduler',
    );

    $SeriesData{TemplateKPIStrg} = $LayoutObject->BuildSelection(
        Data       => \%StandardTemplateData,
        Name       => 'TemplateKPIID',
        SelectedID => $SeriesData{TemplateKPIID} || '',
        Class      => 'Modernize',
    );

    $Param{TimeZone} = $ConfigObject->Get('KPI::Core::TimeZone');

    my %Minutes;

    for ( my $Number = 5; $Number < 56; $Number += 5 ) {

		my $FormatNumber = sprintf( "%02d", $Number );

        $Minutes{$Number} = $FormatNumber;
    }

    $SeriesData{ScheduleMinutesList} = $LayoutObject->BuildSelection(
        Data        => \%Minutes,
        Name        => 'ScheduleMinutes',
        Size        => 6,
        Multiple    => 1,
        Translation => 0,
        SelectedID  => $SeriesData{ScheduleMinutes},
        Class       => 'Modernize',
    );

    my %Hours;

    for my $Hour ( 0 .. 23 ) {

		my $FormatHour = sprintf( "%02d", $Hour );

        $Hours{$Hour} = $FormatHour;
    }

    $SeriesData{ScheduleHoursList} = $LayoutObject->BuildSelection(
        Data        => \%Hours,
        Name        => 'ScheduleHours',
        Size        => 6,
        Multiple    => 1,
        Translation => 0,
        SelectedID  => $SeriesData{ScheduleHours},
        Class       => 'Modernize',
    );

    $SeriesData{ScheduleDaysList} = $LayoutObject->BuildSelection(
        Data => {
			'01' => '01',
			'02' => '02',
			'03' => '03',
			'04' => '04',
			'05' => '05',
			'06' => '06',
			'07' => '07',
			'08' => '08',
			'09' => '09',
			'10' => '10',
			'11' => '11',
			'12' => '12',
			'13' => '13',
			'14' => '14',
			'15' => '15',
			'16' => '16',
			'17' => '17',
			'18' => '18',
			'19' => '19',
			'20' => '20',
			'21' => '21',
			'22' => '22',
			'23' => '23',
			'24' => '24',
			'25' => '25',
			'26' => '26',
			'27' => '27',
			'28' => '28',
			'29' => '29',
			'30' => '30',
			'31' => '31',
		},
        Sort       => 'NumericKey',
        Name       => 'ScheduleDays',
        Size       => 7,
        Multiple   => 1,
        SelectedID => $SeriesData{ScheduleDays},
        Class      => 'Modernize',
    );

    $SeriesData{ScheduleDaysOfWeek} = $LayoutObject->BuildSelection(
        Data => {
            0 => 'Sun',
            1 => 'Mon',
            2 => 'Tue',
            3 => 'Wed',
            4 => 'Thu',
            5 => 'Fri',
            6 => 'Sat',
        },
        Sort       => 'NumericKey',
        Name       => 'ScheduleDaysOfWeek',
        Size       => 7,
        Multiple   => 1,
        SelectedID => $SeriesData{ScheduleDaysOfWeek},
        Class      => 'Modernize',
    );

    $SeriesData{ScheduleMonthList} = $LayoutObject->BuildSelection(
        Data => {
            '01' => 'January',
            '02' => 'February',
            '03' => 'March',
            '04' => 'April',
            '05' => 'May',
            '06' => 'June',
            '07' => 'July',
            '08' => 'August',
            '09' => 'September',
            '10' => 'October',
            '11' => 'November',
            '12' => 'December',
        },
        Sort       => 'NumericKey',
        Name       => 'ScheduleMonth',
        Size       => 7,
        Multiple   => 1,
        SelectedID => $SeriesData{ScheduleMonth},
        Class      => 'Modernize',
    );

    # output edit
    $LayoutObject->Block(
        Name => 'KPISchedulerEdit',
        Data => { %Param, %SeriesData, },
    );

    # generate output
    return $LayoutObject->Output(
        TemplateFile => 'AdminKPIScheduler',
        Data         => \%Param
    );
}

sub _DaemonSort {

    my %DefaultDaemons = (
        SchedulerFutureTaskManager       => 100,
        SchedulerCronTaskManager         => 110,
        SchedulerGenericAgentTaskManager => 111,
        SchedulerTaskWorker              => 112,
    );

    # other daemons could not be in the  DefaultDaemons sorting hash
    # when comparing 2 external daemons sorting must be alphabetical
    if ( !$DefaultDaemons{$a} && !$DefaultDaemons{$b} ) {
        return $a cmp $b;
    }

    # when another daemon is compares to a framework one it must be lower
    elsif ( !$DefaultDaemons{$a} ) {
        return -1;
    }

    # when a framework daemon is compared to another one it must be higher
    elsif ( !$DefaultDaemons{$b} ) {
        return 1;
    }

    # otherwise do a numerical comparison with the framework daemons
    return $DefaultDaemons{$a} <=> $DefaultDaemons{$b};
}


1;