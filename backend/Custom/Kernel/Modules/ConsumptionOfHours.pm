# --
# Kernel/Modules/ConsumptionOfHours.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
# 
# written/edited by:
# * nfreitas@serviceup.com.br
# * ghidalgo@serviceup.com.br
# --

package Kernel::Modules::ConsumptionOfHours;

use strict;
use warnings;

use utf8;

use Encode qw(decode encode);
use File::Basename;
use Digest::MD5 qw(md5_hex);

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # get form id
    $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FormID' );

    # create form id
    if ( !$Self->{FormID} ) {
        $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::UploadCache')->FormIDCreate();
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "ConsumptionOfHours",
        %{$Self}
    );

    my $Message  = $ParamObject->GetParam( Param => 'Message' )  || '';
    
    $Param{Title}  = '';
    $Param{Active} = 'ConsumptionOfHours';

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
	my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');
    
    # ------------------------------------------------------------ #
    # overview
    # ------------------------------------------------------------ #
    my $Output =  $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{ConsumptionOfHours});
    $Output .= $Self->_Overview();
    $Output .= $LayoutObject->CustomerFooter(Type => 'Small');

    return $Output;
}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get layout object
	my $JSONObject     = $Kernel::OM->Get('Kernel::System::JSON');
	my $TicketObject   = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
	my $ArticleObject  = $Kernel::OM->Get('Kernel::System::Ticket::Article');
	my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $QueueObject    = $Kernel::OM->Get('Kernel::System::Queue');
    my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');

    $Param{EnableFilterQueue} = $ConfigObject->Get('CustomerPortal::Core::ConsuptionOfHoursFilterQueue');

	my %FilterQueue;

	if ( $Param{EnableFilterQueue} ) {

		# ------------------------------------------------------------ #
		#  Queues
		# ------------------------------------------------------------ #
		my @SelectedQueues = $ParamObject->GetArray( Param => 'Queues' );

		my %Queues = $QueueObject->QueueList( Valid => 1 );

		my @QueueToNotFilter = $ConfigObject->Get('CustomerPortal::Core::QueueToNotFilter');

		my %NewQueues;
		for my $QueueID (%Queues){
			if(! ($Queues{$QueueID} ~~  @QueueToNotFilter)){
				if($Queues{$QueueID}){
					$NewQueues{$QueueID} = $Queues{$QueueID};
				}
			}
		}

		if ( !@SelectedQueues ) {
			for my $QueueID (%Queues){
				if(! ($Queues{$QueueID} ~~  @QueueToNotFilter)){
					if($Queues{$QueueID}){
						push @SelectedQueues,  $QueueID;
					}
				}
			}
		}     

		# build option string to groups
		$Param{Queues} = $LayoutObject->BuildSelection(
			Data        => \%NewQueues,
			Name        => 'Queues',
			Multiple    => 1,
			Class       => 'FilterCP Modernize' . ( $Param{Errors}->{'ValidIDInvalid'} || '' ),
			SelectedID  => \@SelectedQueues,
			PossibleNone => 0,
		);

		$FilterQueue{SelectedQueues} = \@SelectedQueues;
		$FilterQueue{QueueIDs}       = \@SelectedQueues;
	}

	my %MonthsName = (
        1 => 'Jan',
        2 => 'Feb',
        3 => 'Mar',
        4 => 'Apr',
        5 => 'May',
        6 => 'Jun',
        7 => 'Jul', 
        8 => 'Aug',
        9 => 'Sep',
        10 => 'Oct',
        11 => 'Nov',
        12 => 'Dec',
    );
	
	my $LastDayOfMonth = $DateTimeObject->LastDayOfMonthGet();
	my $DateTimeSettings = $DateTimeObject->Get();
		
	my $Day = $LastDayOfMonth->{Day};
	my $Year = $DateTimeSettings->{Year};
	my $Month = $DateTimeSettings->{Month};
	my $TotalTime;
	
	# ------------------------------------------------------------ #
    # Current month
    # ------------------------------------------------------------ #
		
	my $TicketTotalMonth = $TicketObject->TicketSearch(
        Result                       => 'COUNT',
        CustomerUserID 				 => $Self->{UserID},
		CustomerIDRaw                => [$Self->{CustomerID}],
        TicketChangeTimeNewerDate    => "$Year-$Month-01 00:00:01",
        TicketChangeTimeOlderDate 	 => "$Year-$Month-$Day 23:59:59",
        # QueueIDs => \@SelectedQueues,
		%FilterQueue
	);
	
	my $ContractAccountedTime = $Self->_TicketAccountedTimeGet( 
		CustomerID 				  => $Self->{CustomerID},		
		TicketChangeTimeNewerDate => "$Year-$Month-01 00:00:01",
		TicketChangeTimeOlderDate => "$Year-$Month-$Day 23:59:59",
        # SelectedQueues            => \@SelectedQueues
		%FilterQueue

	);
	
	$TotalTime = ($ContractAccountedTime->{TicketAccountedTime} * 60);
	
	my $ConvertedTime = convert_seconds_to_hhmmss($TotalTime);
	$Param{AccountedTime} = $ConvertedTime;
	$Param{TicketTotalMonth} = $TicketTotalMonth;

    $LayoutObject->Block(
        Name => 'ActualMonth',
		Data => \%Param,
    );
	
	# ------------------------------------------------------------ #
    # Last 6 months
    # ------------------------------------------------------------ #
		
	my @Label;
	my @DataSet;
	my @Values;
	for my $Count ( 1 .. 6 ){
		my %MonthHours = ();
		my %LabelsName = ();
		my %LinesnName = ();
		my $SubtractObject = $Kernel::OM->Create('Kernel::System::DateTime');		
		$SubtractObject->Subtract(
			Months    => $Count,
		);		
		my $DateTimeSubtract = $SubtractObject->Get();
		my $LastDayOfMonth = $SubtractObject->LastDayOfMonthGet();
			
		my @MonthTickets = $TicketObject->TicketSearch(
			Result                       => 'ARRAY',
			CustomerIDRaw                => [$Self->{CustomerID}],
			CustomerUserID 				 => $Self->{UserID},
			TicketChangeTimeNewerDate    => "$DateTimeSubtract->{Year}-$DateTimeSubtract->{Month}-01 00:00:01",
			TicketChangeTimeOlderDate 	 => "$DateTimeSubtract->{Year}-$DateTimeSubtract->{Month}-$LastDayOfMonth->{Day} 23:59:59",	
	        # QueueIDs                     => \@SelectedQueues,	
			%FilterQueue
    	);
		
		my $MonthTicketsOpen = $TicketObject->TicketSearch(
			Result                       => 'COUNT',
			CustomerIDRaw                => [$Self->{CustomerID}],
			StateType					 => 'Open',
			CustomerUserID 				 => $Self->{UserID},
			TicketCreateTimeNewerDate    => "$DateTimeSubtract->{Year}-$DateTimeSubtract->{Month}-01 00:00:01",
			TicketCreateTimeOlderDate 	 => "$DateTimeSubtract->{Year}-$DateTimeSubtract->{Month}-$LastDayOfMonth->{Day} 23:59:59",	
            # QueueIDs                     => \@SelectedQueues,	
			%FilterQueue
        );
		
		my $MonthTicketsClosed = $TicketObject->TicketSearch(
			Result                       => 'COUNT',
			CustomerIDRaw                => [$Self->{CustomerID}],
			StateType					 => 'Closed',
			CustomerUserID 				 => $Self->{UserID},
			TicketCreateTimeNewerDate    => "$DateTimeSubtract->{Year}-$DateTimeSubtract->{Month}-01 00:00:01",
			TicketCreateTimeOlderDate 	 => "$DateTimeSubtract->{Year}-$DateTimeSubtract->{Month}-$LastDayOfMonth->{Day} 23:59:59",	
		    # QueueIDs                     => \@SelectedQueues,
			%FilterQueue
        );
		
		my $TotalTimeMonths = 0;
		my $TotalTimeChart = 0;
		my $ConvertedTimeMonths;

		# for my $TicketID ( @MonthTickets ){
		# 	my $AccountedTime = $TicketObject->TicketAccountedTimeGet(TicketID => $TicketID);
		# 	$TotalTimeMonths += ($AccountedTime * 60);
		# 	$TotalTimeChart += ($AccountedTime / 60);
			
		# }

		my $TicketAccountedTimeGet = $Self->_TicketAccountedTimeGet( 
			CustomerID 				  => $Self->{CustomerID},		
			TicketChangeTimeNewerDate => "$DateTimeSubtract->{Year}-$DateTimeSubtract->{Month}-01 00:00:01",
			TicketChangeTimeOlderDate => "$DateTimeSubtract->{Year}-$DateTimeSubtract->{Month}-$LastDayOfMonth->{Day} 23:59:59",	
		);

		$TotalTimeMonths = ($TicketAccountedTimeGet->{TicketAccountedTime} * 60);
		$TotalTimeChart = ($TicketAccountedTimeGet->{TicketAccountedTime} / 60);
		
		my $ContracAccounted = convert_seconds_to_hhmmss($TotalTimeMonths);
		
		my $MonthsNamePT = $MonthsName{$DateTimeSubtract->{Month}};
		my $MonthTranslate =  $LayoutObject->{LanguageObject}->Translate($MonthsNamePT);
		$LayoutObject->Block(
			Name => 'MonthsHours',
			Data => {
				MonthName 			=> $MonthTranslate,
				Year				=> $DateTimeSubtract->{Year},
				MonthHours 			=> $ContracAccounted." h",
				MonthTicketsOpen 	=> $MonthTicketsOpen,
				MonthTicketsClosed	=> $MonthTicketsClosed,
			},
		);
		
		push @Label, "$MonthTranslate/ $DateTimeSubtract->{Year}";
		
		$TotalTimeChart = sprintf("%0.2f", $TotalTimeChart);
		
		push @Values, $TotalTimeChart;
	}
	
	push @DataSet, {
		values => \@Values,
	};
	
	
	my %Data = (
		labels   => \@Label,
        datasets => \@DataSet
	);
	
	my $JSONString = $JSONObject->Encode(
        Data => \%Data,
    );
	
	$LayoutObject->AddJSData(
		Key   => 'Chart',
		Value => $JSONString,
	);
	
    return $LayoutObject->Output(
        TemplateFile => 'ConsumptionOfHours',
        Data         => \%Param,
    );
}

sub convert_seconds_to_hhmmss {

	  my $hourz=int($_[0]/3600);

	  my $leftover=$_[0] % 3600;

	  my $minz=int($leftover/60);

	  my $secz=int($leftover % 60);

	  return sprintf ("%02d:%02d", $hourz,$minz)

}

sub _TicketAccountedTimeGet {
	my ( $Self, %Param ) = @_;	
	my %Data = ();
	
	# check needed stuff
    if ( ! defined $Param{CustomerID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need CustomerID!',
        );
        return;
    }
	
	my $TicketObject   = $Kernel::OM->Get('Kernel::System::Ticket');
    my $TimeObject     = $Kernel::OM->Get('Kernel::System::Time');
	my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');
	my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
	my $ArticleObject  = $Kernel::OM->Get('Kernel::System::Ticket::Article');
	
	$Data{TotalTickets} = 0;
	
	# search in archive
	my %SearchInArchive;	
    if (
        $ConfigObject->Get('Ticket::ArchiveSystem')
        && !$ConfigObject->Get('Ticket::CustomerArchiveSystem')
    )
    { 	
        $SearchInArchive{ArchiveFlags} = [ 'y', 'n' ];
    }	

	$Data{TicketAccountedTime} = 0;	
	
 	my @TicketIDs = $TicketObject->TicketSearch(
 	    Result => 'ARRAY',	
		CustomerIDRaw => [$Param{CustomerID}],
		TicketChangeTimeNewerDate => $Param{TicketChangeTimeNewerDate},
		TicketChangeTimeOlderDate => $Param{TicketChangeTimeOlderDate},
		%SearchInArchive,
		CustomerUserID => $Self->{UserID},
 	);	
	
	$Data{AccountedTicket} = scalar @TicketIDs;
	
	$Data{TotalAccountedTime} = 0;	
		
	# get accounted time by article
 	foreach my $TicketID (@TicketIDs){
	
 		my @ArticleIDs = $ArticleObject->ArticleList(
 			TicketID => $TicketID,
 		);

		 foreach my $Article (@ArticleIDs){
		 
			my $TimeNewerDate = $Kernel::OM->Create(
				'Kernel::System::DateTime',
				ObjectParams => {
					String   => $Param{TicketChangeTimeNewerDate},
				}
			);
			
			my $TimeOlderDate = $Kernel::OM->Create(
				'Kernel::System::DateTime',
				ObjectParams => {
					String   => $Param{TicketChangeTimeOlderDate},
				}
			);
			
			my $ArticleCreateDate = $Kernel::OM->Create(
				'Kernel::System::DateTime',
				ObjectParams => {
					String   => $Article->{CreateTime},
				}
			);
			
			my $ArticleNewer = $ArticleCreateDate->Compare( DateTimeObject => $TimeNewerDate );
			my $ArticleOlder = $ArticleCreateDate->Compare( DateTimeObject => $TimeOlderDate );

			if ( ( $ArticleNewer >= 0 ) && ( $ArticleOlder <= 0 ) ) {
				$Data{TicketAccountedTime} += $ArticleObject->ArticleAccountedTimeGet(ArticleID => $Article->{ArticleID});
			}
		 }
		
		$Data{TotalTickets} += 1;
	}
	
	return \%Data;
}

1;