# --
# Custom/Kernel/Modules/AgentServicesDashboard.pm - frontend module
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * nfreitas@serviceup.com.br
# * ccresencio@serviceup.com.br
# --

package Kernel::Modules::AgentServicesDashboard;

use strict;
use warnings;
use DateTime;
use utf8;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless ($Self, $Type);

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

	my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
	my $ServiceObject         = $Kernel::OM->Get('Kernel::System::Service');
    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $TicketObject          = $Kernel::OM->Get('Kernel::System::Ticket');
	my $JSONObject            = $Kernel::OM->Get('Kernel::System::JSON');
	my $ParamObject           = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $TimeObject            = $Kernel::OM->Get('Kernel::System::Time');
	my $QueueObject           = $Kernel::OM->Get('Kernel::System::Queue');
    my $ConfigObject          = $Kernel::OM->Get('Kernel::Config');

	my @SelectedQueueID  = $ParamObject->GetArray( Param => 'QueueID' );

	my %GetParam;

	$GetParam{TimeStartDay}   = $ParamObject->GetParam( Param => 'TimeStartDay' );
	$GetParam{TimeStartMonth} = $ParamObject->GetParam( Param => 'TimeStartMonth' );
	$GetParam{TimeStartYear}  = $ParamObject->GetParam( Param => 'TimeStartYear' );
	$GetParam{TimeStopDay}    = $ParamObject->GetParam( Param => 'TimeStopDay' );
	$GetParam{TimeStopMonth}  = $ParamObject->GetParam( Param => 'TimeStopMonth' );
	$GetParam{TimeStopYear}   = $ParamObject->GetParam( Param => 'TimeStopYear' );
	
	my $CreateTimeNewerDate;
	my $CreateTimeOlderDate;

	# to the first time that page apears
	if(!$GetParam{TimeStartDay}){
	
		my $SystemTime = $TimeObject->SystemTime();
		
		my ($NSec, $NMin, $NHour, $NDay, $NMonth, $NYear, $NWeekDay) = $TimeObject->SystemTime2Date(
			SystemTime => $TimeObject->SystemTime() - 5184000,
		);

		my ($OSec, $OMin, $OHour, $ODay, $OMonth, $OYear, $OWeekDay) = $TimeObject->SystemTime2Date(
			SystemTime => $TimeObject->SystemTime(),
		);

		$CreateTimeNewerDate = "$NYear-$NMonth-$NDay";
		$CreateTimeOlderDate = "$OYear-$OMonth-$ODay";
	}
	else{
		$CreateTimeNewerDate = "$GetParam{TimeStartYear}-$GetParam{TimeStartMonth}-$GetParam{TimeStartDay}";
		$CreateTimeOlderDate = "$GetParam{TimeStopYear}-$GetParam{TimeStopMonth}-$GetParam{TimeStopDay}";
	};
	
	my %QueuesList = $QueueObject->QueueList( Valid => 1 );

	my %Queues = $QueueObject->GetAllQueues( UserID => $Self->{UserID}, Type => 'ro' );

	my $Output;

	# build option string
	$Param{QueueList} = $LayoutObject->BuildSelection(
		Data         => \%Queues,
		Name         => 'QueueID',
		Multiple     => 1,
		Class        => 'Modernize' . ( $Param{Errors}->{'ValidIDInvalid'} || '' ),
        SelectedID   => \@SelectedQueueID,
		PossibleNone => 0,
	);

	$Param{TimeStart} = $LayoutObject->BuildDateSelection(
		%GetParam,
        Prefix                  => 'TimeStart',
        Format                  => 'DateInputFormat',
        DiffTime                => -( 60 * 60 * 24 ) * 30 * 2,
        Validate                => 1,
		ValidateDateNotInFuture => 1,
    );

    $Param{TimeStop} = $LayoutObject->BuildDateSelection(
		%GetParam,
        Prefix                  => 'TimeStop',
        Format                  => 'DateInputFormat',
        Validate                => 1,
		ValidateDateNotInFuture => 1,
    );

	my ( @Data, @Label, @QueueListAux );

	push @QueueListAux, keys %Queues;

	my %SearchParams;

	if ( $ConfigObject->Get('ServicesDashboard::Core::EnableCustomerSearch') ) {

		my @SelectedCustomer = $ParamObject->GetArray( Param => 'CustomerID' );

		my %CustomerList = $CustomerCompanyObject->CustomerCompanyList( Valid => 1 );

		my @CustomerListAux;

		push @CustomerListAux, keys %CustomerList;

		$Param{CustomerList} = $LayoutObject->BuildSelection(
			Data         => \%CustomerList,
			Name         => 'CustomerID',
			Multiple     => 1,
			Class        => 'Modernize' . ( $Param{Errors}->{'ValidIDInvalid'} || '' ),
			SelectedID   => \@SelectedCustomer,
			PossibleNone => 0,
		);

		if ( @SelectedCustomer && $SelectedCustomer[0] ne '' ){
			$SearchParams{CustomerID} = \@SelectedCustomer;
		}
		else {
			$SearchParams{CustomerID} = [];
		}
	}

	if ( @SelectedQueueID ){
		$SearchParams{QueueIDs} = \@SelectedQueueID;
	}
	else {
		$SearchParams{QueueIDs} = \@QueueListAux;
	}

	my %ServiceList = $ServiceObject->ServiceList(
        Valid  => 1,
        UserID => 1,
    );

	my %ServiceData;

	SERVICE:
	foreach my $ServiceName ( sort { $ServiceList{$a} cmp $ServiceList{$b} } keys %ServiceList ) {
		
		my @Values;

		my @ServiceRoot = split( /::/x, $ServiceList{$ServiceName} );

		my $NivelService = scalar @ServiceRoot;

		my $TotalTicketsService;
		
		my @Colors = map { "#" . join "", map { sprintf "%02x", rand(255) } (0..2) } (0..1);
		
		next SERVICE if ( $NivelService > 1 );
		
		SERVICECHILDREN:
		foreach my $ChildrenServiceName ( sort { $ServiceList{$b} cmp $ServiceList{$a} } keys %ServiceList ) {
			
			my $TotalTickets;

			my @ServiceChildren = split( /::/x, $ServiceList{$ChildrenServiceName});
			
			if( $ServiceChildren[0] ne $ServiceRoot[0] ){
				next SERVICECHILDREN;
			}

			$TotalTickets = $TicketObject->TicketSearch(
				Result                    => 'COUNT',
				UserID                    => 1,
				Services                  => [$ServiceList{$ChildrenServiceName}],
				TicketCreateTimeNewerDate => "$CreateTimeNewerDate 00:00:00",
				TicketCreateTimeOlderDate => "$CreateTimeOlderDate 23:59:59",
				%SearchParams
			);

			%ServiceData = $ServiceObject->ServiceGet(
				Name   => $ServiceList{$ChildrenServiceName},
				UserID => 1,
			);

			my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
				ServiceID => $ServiceData{ServiceID},
				UserID    => 1,
			);
				
			if ( ( (IsArrayRefWithData($ServiceParentsList)) || ( $NivelService == 1 ) ) && ( $ServiceChildren[0] eq $ServiceRoot[0] ) ) {
				$TotalTicketsService += $TotalTickets;
			}
			else{
				$TotalTicketsService = $TotalTickets;
			}
		}

		push @Values, $TotalTicketsService;

		if ( $TotalTicketsService != 0 ) {

			push @Label, $ServiceData{Name};

			push @Data, {
				data            => \@Values,
				backgroundColor => \@Colors,
				borderColor     => \@Colors,
				borderWidth     => 1,
				label           => $ServiceData{Name},
				datalabels      => {
					align  => 'center',
					anchor => 'center',
				},
			};
		}
	}

	my $AgentServicesDashboardObject = $Kernel::OM->Get('Kernel::System::AgentServicesDashboard');

	my $CountTicketNoServices = $AgentServicesDashboardObject->SearchTicketsNotHaveServices(
		TicketCreateTimeNewerDate => "$CreateTimeNewerDate 00:00:00",
		TicketCreateTimeOlderDate => "$CreateTimeOlderDate 23:59:59",
		%SearchParams
	);
	
	if ( $CountTicketNoServices ){

		my @Values;

		my @Colors = map { "#" . join "", map { sprintf "%02x", rand(255) } (0..2) } (0..1);

		push @Values, $CountTicketNoServices;

		my $LabelNoService = $LayoutObject->{LanguageObject}->Translate('No Service');
		
		push @Label, $LabelNoService ;

		push @Data, {
			data            => \@Values,
			backgroundColor => \@Colors,
			borderColor     => \@Colors,
			borderWidth     => 1,
			label           => $LabelNoService,
			datalabels      => {
				align  => 'center',
				anchor => 'center',
			},
		};
	
	}
	
	my %DataJS;
	
	$DataJS{Datasets} = $JSONObject->Encode(
        Data => \@Data,
    );

	$DataJS{Labels} = $JSONObject->Encode(
        Data => \@Label,
    );

	my $DateTimeStart = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => "$CreateTimeNewerDate 00:00:00",
        }
    );

	my $DateTimeStop = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => "$CreateTimeOlderDate 23:59:59",
        }
    );

	$DataJS{Period} = $LayoutObject->{LanguageObject}->Translate('Period') 
	. ': ' . $DateTimeStart->Format( Format => '%d/%m/%Y ' ) 
	. $LayoutObject->{LanguageObject}->Translate('until') 
	. $DateTimeStop->Format( Format => ' %d/%m/%Y' );

	# send data to JS
    $LayoutObject->AddJSData(
        Key   => 'DataChart',
        Value => \%DataJS,
    );

	$Output = $LayoutObject->Header(Title => "AgentServicesDashboard");

	$Output .= $LayoutObject->NavigationBar();

	$Output .= $LayoutObject->Output(
		Data => \%Param,
		TemplateFile => 'AgentServicesDashboard',
	);

	$Output .= $LayoutObject->Footer();

	return $Output;

}

1;

