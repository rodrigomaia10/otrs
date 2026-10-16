# --
# Custom/Kernel/System/Console/Command/Maint/Ticket/KPIScheduler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::System::Console::Command::Maint::Ticket::KPIScheduler;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use base qw(Kernel::System::Console::BaseCommand);

our @ObjectDependencies = (
	'Kernel::System::Scheduler',
	'Kernel::System::Daemon::SchedulerDB'
);

sub Run {
	my ( $Self, %Param ) = @_;

	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');
	my $SchedulerDBObject       = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB');
    my $ConfigObject            = $Kernel::OM->Get('Kernel::Config');
	
	$Self->Print("<yellow> Checking the KPIScheduler module tasks</yellow>\n");

    my $TimeZone = $ConfigObject->Get('KPI::Core::TimeZone');

	# date/hour of system
    my $DateTimeObject   = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            TimeZone => $TimeZone
        }
    );

    my $DateTimeSettings = $DateTimeObject->Get();

	# get the list of KPIScheduler jobs
	my %JobList = $KPIObject->JobList();

	# get the list of KPIScheduler jobs to be executed
    my @FutureTaskList = $SchedulerDBObject->FutureTaskList(
        Type => 'KPIScheduler',
    );

    if ( IsHashRefWithData(\%JobList) ) {

		JOB:
        for my $JobKey ( sort keys %JobList ) {

            my %JobData = $KPIObject->JobGet( Name => $JobKey );

			# check if job is valid
			next JOB if $JobData{Valid} != 1;

			# verify is the month is inside of the job
			if (grep { $_ eq $DateTimeSettings->{Month} } @{$JobData{ScheduleMonth}}) {
			# if ( $DateTimeSettings->{Month} ~~ @{$JobData{ScheduleMonth}} ) {

				# verify if the day of the week if inside of the job
				# if ( $DateTimeSettings->{Day} ~~ @{$JobData{ScheduleDays}} || $DateTimeSettings->{DayOfWeek } ~~ @{$JobData{ScheduleDaysOfWeek}} ){
				if (grep { $_ eq $DateTimeSettings->{Day} } @{$JobData{ScheduleDays}} || grep { $_ eq $DateTimeSettings->{DayOfWeek} } @{$JobData{ScheduleDaysOfWeek}}) {

					# get the hours of the job
					foreach my $HourTask ( @{ $JobData{ScheduleHours}}) {

						# verify if the hour is equal of the created hour
						if (int($DateTimeSettings->{Hour}) == $HourTask ) {

							# get the minutes of the job
							foreach my $MinuteTask ( @{ $JobData{ScheduleMinutes} } ){

								if ( int($MinuteTask) > int($DateTimeSettings->{Minute}) && int($MinuteTask) <= (int($DateTimeSettings->{Minute}) + 5) ){

									# create the date/hour of the execution
									my $FormatMinute = $Self->_FormatMinute( Minute => $MinuteTask );
									my $FormatHour   = $Self->_FormatHour( Hour => $HourTask );
									my $FormatDay    = $Self->_FormatDay( Day => $DateTimeSettings->{Day} );
									my $FormatMonth  = $Self->_FormatMonth( Month => $DateTimeSettings->{Month} );

									my $ScheduleTime = "$DateTimeSettings->{Year}-$FormatMonth-$FormatDay $FormatHour:$FormatMinute:00";

									my $OTRSTimeZone = Kernel::System::DateTime->OTRSTimeZoneGet();

									my $DateTimeObject2 = $Kernel::OM->Create(
										'Kernel::System::DateTime',
										ObjectParams => {
											TimeZone => $TimeZone,
											String   => $ScheduleTime,
										}
									);

									my $Success = $DateTimeObject2->ToTimeZone(
										TimeZone => $OTRSTimeZone,
									);

									my $DateFormat = $DateTimeObject2->Format( Format => '%Y-%m-%d %H:%M:%S' );

									# verify all the programed jobs
									my $CheckOK = 1;

									for my $FutureTask ( @FutureTaskList ) {

										# verify if the job of KPIScheduler is already programed
										if  ( $FutureTask->{ExecutionTime} eq $DateFormat && $FutureTask->{Name} eq "$JobData{Name}" ){

											$CheckOK = 0;

											$Self->Print("<yellow> Task $JobData{Name} already created - Execution: $DateFormat </yellow>\n");
										}
									}

									# if the job of KPIScheduler isn't programed, create a new
									if ( $CheckOK ) {
										
										my $TaskID = $SchedulerDBObject->FutureTaskAdd(
											ExecutionTime            => $DateFormat,
											Type                     => 'KPIScheduler',
											Name                     => "$JobData{Name}",
											Attempts                 => 1,
											MaximumParallelInstances => 0,
											Data => {
												%JobData
											},
										);

										if ($TaskID) {

											$Self->Print("<yellow> Task $JobData{Name} created (TaskID: $TaskID) - Execution: $DateFormat </yellow>\n");
										}
									}
								}
							}
						}
					}
				}
			}
        }
    }

	$Self->_DeleteFutureTesk();

   	$Self->Print("<green>Done.</green>\n");

    return $Self->ExitCodeOk();
}

sub _DeleteFutureTesk {

	my ( $Self, %Param ) = @_;

	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');
	my $SchedulerDBObject       = $Kernel::OM->Get('Kernel::System::Daemon::SchedulerDB');
    my $ConfigObject            = $Kernel::OM->Get('Kernel::Config');

    my $TimeZone = $ConfigObject->Get('KPI::Core::TimeZone');

	# get the work lists of KPIScheduler
	my %JobList = $KPIObject->JobList();

	# get the work lists of KPIScheduler to be executes
    my @FutureTaskList = $SchedulerDBObject->FutureTaskList(
        Type => 'KPIScheduler',
    );

	for my $FutureTask ( @FutureTaskList ) {
		
		my $DateTimeObject = $Kernel::OM->Create(
			'Kernel::System::DateTime',
			ObjectParams => {
				String => $FutureTask->{ExecutionTime},
			}
    	);

		my $Success = $DateTimeObject->ToTimeZone(
			TimeZone => $TimeZone,
		);

		my $DateTimeSettings = $DateTimeObject->Get();

		my $Flag = 0;

		for my $JobKey ( %JobList ) {

			my %JobData = $KPIObject->JobGet( Name => $JobKey );

			# verify if the month is inside of the job
			# if ( $DateTimeSettings->{Month} ~~ @{$JobData{ScheduleMonth}} ) {
			if (grep { $_ eq $DateTimeSettings->{Month} } @{$JobData{ScheduleMonth}}) {
	
				# verify if the day is inside of the job
				# if ( $DateTimeSettings->{Day} ~~ @{$JobData{ScheduleDays}} || $DateTimeSettings->{DayOfWeek } ~~ @{$JobData{ScheduleDaysOfWeek}} ){
				if (
					(grep { $_ eq $DateTimeSettings->{Day} } @{$JobData{ScheduleDays}})
					||
					(grep { $_ eq $DateTimeSettings->{DayOfWeek} } @{$JobData{ScheduleDaysOfWeek}})
				) {
					# get the hours of the job
					foreach my $HourTask ( @{ $JobData{ScheduleHours}}) {

						# verify if the hour is equal of the created hour
						if (int($DateTimeSettings->{Hour}) == $HourTask ) {

							# get the minutes of the work
							if (grep { $_ == int($DateTimeSettings->{Minute}) } @{$JobData{ScheduleMinutes}}) {
							# if (int($DateTimeSettings->{Minute}) ~~ @{ $JobData{ScheduleMinutes}} ) {
								$Flag = 1;
							}
						}
					}
				}
			}
		}

		# if Flag equals 0 it means that the work doens't exist anymore
		if ( $Flag == 0 ) {

			my $Success = $SchedulerDBObject->FutureTaskDelete(
				TaskID => $FutureTask->{TaskID},
			);
		}
	}
}

sub _FormatDay {
	my ( $Self, %Param ) = @_;

	my %Days;

    for my $Day ( 1 .. 31 ) {

		my $FormatDay = sprintf( "%02d", $Day );

        $Days{$Day} = $FormatDay;
    }

	return $Days{$Param{Day}};
}

sub _FormatMonth {
	my ( $Self, %Param ) = @_;

	my %Months;

    for my $Month ( 1 .. 12 ) {

		my $FormatMonth = sprintf( "%02d", $Month );

        $Months{$Month} = $FormatMonth;
    }

	return $Months{$Param{Month}};
}

sub _FormatHour {
	my ( $Self, %Param ) = @_;

	my %Hours;

    for my $Hour ( 0 .. 23 ) {

		my $FormatHour = sprintf( "%02d", $Hour );

        $Hours{$Hour} = $FormatHour;
    }

	return $Hours{$Param{Hour}};
}

sub _FormatMinute {
	my ( $Self, %Param ) = @_;

	my %Minutes;

    for ( my $Number = 5; $Number < 56; $Number += 5 ) {

		my $FormatNumber = sprintf( "%02d", $Number );

        $Minutes{$Number} = $FormatNumber;
    }

	return $Minutes{$Param{Minute}};
}

1;