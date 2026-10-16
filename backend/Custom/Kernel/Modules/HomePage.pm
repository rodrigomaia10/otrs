# --
# Kernel/Modules/HomePage.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::HomePage;

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

    my $CustomerPortalObject = $Kernel::OM->Get('Kernel::System::CustomerPortal');
	my $ServiceObject        = $Kernel::OM->Get('Kernel::System::Service');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject           = $Kernel::OM->Get('Kernel::System::JSON');

    my $CustomerPortalLayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::CustomerPortal');
    my $CardHomeSearch = $ConfigObject->Get('CustomerPortal::Core::CardHomeSearch');

    $CustomerPortalLayoutObject->CreateNavBar(
        ActionActive => "Stats",
        %{$Self},
        HideSearch => $CardHomeSearch->{Search}
    );

    my $Message  = $ParamObject->GetParam( Param => 'Message' )  || '';
    
    $Param{Title}  = '';
    $Param{Active} = 'HomePage';

    if ( $ConfigObject->Get('CustomerPortal::Core::CardHomeSearch') ) {

        $Param{IsFullSearch} = $CardHomeSearch->{FullCard} ? 1 : 0;
        
        my $Style;
        
        if( $CardHomeSearch->{BackgroundGradient} ne ""){
            $Style = "background: $CardHomeSearch->{BackgroundGradient}";
        }
        elsif ( $CardHomeSearch->{CardColor} ne "" ){
            $Style = "background-color: $CardHomeSearch->{CardColor}";

        }else{
            $Style = "background-image: url($CardHomeSearch->{Image})";
        }

        if ( $CardHomeSearch->{Image} ) {

            $CardHomeSearch->{Image} = $Self->_GetPathImage(
                Image => $CardHomeSearch->{Image},
            );

            $Style = "background-image: url($CardHomeSearch->{Image})";
        }

        my $Transparent;

        if ( $ConfigObject->Get('CustomerPortal::Core::CardHomeSearchTransparent') ) {
            $Transparent = "background-color: transparent; box-shadow: none;";
        }

        $LayoutObject->Block(
            Name => $CardHomeSearch->{FullCard} ? 'SearchFull' : 'Search',
            Data => {
                Title         => $CardHomeSearch->{Title},
                TitleColor    => $CardHomeSearch->{TitleColor}    || '#FFF',
                Subtitle      => $CardHomeSearch->{Subtitle},
                SubtitleColor => $CardHomeSearch->{SubtitleColor} || '#FFF',
                Search        => $CardHomeSearch->{Search},
                Style         => $Style,
                Transparent   => $Transparent,
            }
        );
    }

    my $CentralCard = $CustomerPortalObject->HomePageGet(
        ID => 'Home_Page',
    );

    if ( $CentralCard->{ValidID} == 1 ) {

        my $CardCustomPosition = $ConfigObject->Get('CustomerPortal::Core::CardCustomPosition');

        my $Position = 'Up';

        if ( $CardCustomPosition eq 1 ) {
            $Position = 'Down';
        }

        $LayoutObject->Block(
            Name => "ShowCentralCard$Position",
            Data => {
                BodyCard => $CentralCard->{Body},
            }
        );
    }

    my $EnableCustomizedCards = $ConfigObject->Get('CustomerPortal::Core::EnableCustomizedCards');

    #  if there are any customer card defined, they are shown
    if($EnableCustomizedCards eq '1'){

        my $Cards = $CustomerPortalObject->CardsListValids();

        if ( IsArrayRefWithData(\@{$Cards}) ) {

            $LayoutObject->Block(
                Name => 'ShowCustomerCards',
                Data => {}
            );

            CARD:
            for my $CardID ( @{$Cards} ) {                

                next CARD if $CardID == 3;
                
                my $Data = $CustomerPortalObject->CardsGet(
                    ID => $CardID,
                );

                $LayoutObject->Block(
                    Name => 'CustomerPortalCard',
                    Data => {
                        BodyCard => $Data->{Body},
                    }
                );
            }          
        }
    }
    
    $LayoutObject->Block(
        Name => 'ShowStats',
        Data => {}
    );

    #Building charts
    my @DataCharts;
    my @Customers;
    push @Customers, $Self->{UserCustomerID};

    my $CustomerNews = $ConfigObject->Get('CustomerPortal::Core::CustomerNews');

    if(values %{$CustomerNews}){

        $LayoutObject->Block(
            Name => 'ShowChartJSWithNews',
            Data => {
                ChartTitle => $LayoutObject->{LanguageObject}->Translate( 'Open Tickets' ),
                ChartName  => 'line',
            },
        );

        $LayoutObject->Block(
            Name => 'News',
        );

        for my $Link (keys %{$CustomerNews}){
            $LayoutObject->Block(
                Name => 'NewsBody',
                Data => {
                    Title => $Link,
                    Body  => $CustomerNews->{$Link},
                }
            );
        }
    }
    else{
        $LayoutObject->Block(
            Name => 'ShowChartJS',
            Data => {
                ChartTitle => $LayoutObject->{LanguageObject}->Translate( 'Open Tickets' ),
                ChartName  => 'line',
            },
        );
    }

    my $EnableChartOfDashBoard = $ConfigObject->Get('CustomerPortal::Core::EnableChartOfDashBoard');

    if($EnableChartOfDashBoard->{OpenAndClosed} eq '1'){

        my %SearchTypes = (
            $LayoutObject->{LanguageObject}->Translate( 'Closed' ) => {
                "StateType" => "closed"
            },
            $LayoutObject->{LanguageObject}->Translate( 'Open' ) => {
                "StateType" => ['new','open']
            },
        );

        my %LineChartFormData = (
            Type           => 'line',
            Title          => $LayoutObject->{LanguageObject}->Translate( 'Open x Closed Tickets' ),
            Time           => 7,
            Period         => 'days',
            CustomerUserID => $Self->{UserID},
            Search         => \%SearchTypes
        );

        my $JSONLineChart = $Self->_GenerateLineChart(
            %LineChartFormData
        );

        push @DataCharts, {
            ChartName   => $LayoutObject->{LanguageObject}->Translate( 'Open x Closed Tickets' ),
            DataJSON    => $JSONLineChart,
            Type        => 'Chart'
        };
  
        if(values %{$CustomerNews}){
            $LayoutObject->Block(
                Name => 'ShowChartOpenAndClosedNews',
                Data => {}
            );
        }else{
            $LayoutObject->Block(
                Name => 'ShowChartOpenAndClosed',
                Data => {}
            );
        }
    }

    if($EnableChartOfDashBoard->{State} eq '1'){

        my %SearchTypesForPie = (
            "open"  => {
                "StateType" => ['open']
            },
            "pending reminder" => {
                "StateType" => ['pending reminder']
            },
            "new"   => {
                "StateType" => ['new']
            },
            "closed" => {
                "StateType" => ['closed']
            },
        );

        my %PieChartFormData = (
            Type           => 'pie',
            Title          => $LayoutObject->{LanguageObject}->Translate( 'Total by state' ),
            CustomerUserID => $Self->{UserID},
            Customers      => \@Customers,
            Search         => \%SearchTypesForPie,
        );

        my $JSONPieChart = $Self->_GeneratePieChart(
            %PieChartFormData
        );

        push @DataCharts, {
            ChartName   => $LayoutObject->{LanguageObject}->Translate( 'Ticket by state' ),
            DataJSON    => $JSONPieChart,
            Type        => 'Chart'
        };

        if(values %{$CustomerNews}){
            $LayoutObject->Block(
                Name => 'ShowChartStateNews',
                Data => {}
            );
        }
        else{
            $LayoutObject->Block(
                Name => 'ShowChartState',
                Data => {}
            );
        }
    }
    
    if($EnableChartOfDashBoard->{Service} eq '1'){

        my %BarChartFormData = (
            Type           => 'bar',
            Title          => $LayoutObject->{LanguageObject}->Translate( 'Ticket Services' ),
            CustomerUserID => $Self->{UserID},
            Customers      => \@Customers,
        );

        my $JSONBarChart = $Self->_GenerateBarChart(
            %BarChartFormData
        );

        push @DataCharts, {
            ChartName   => $LayoutObject->{LanguageObject}->Translate( 'Ticket Services' ),
            DataJSON    => $JSONBarChart,
            Type        => 'Chart'
        };

        if(values %{$CustomerNews}){
            $LayoutObject->Block(
                Name => 'ShowChartServiceNews',
                Data => {}
            );
        }
        else{
            $LayoutObject->Block(
                Name => 'ShowChartService',
                Data => {}
            );
        }
    }

    if($EnableChartOfDashBoard->{Type} eq '1'){

        my %DoughnutChartToTicketType = (
            Type           => 'doughnutChartToTicketType',
            Title          => $LayoutObject->{LanguageObject}->Translate( 'Ticket type' ),
            CustomerUserID => $Self->{UserID},
            Customers      => \@Customers,
        );

        my $JSONDoughnutChartToTicketType = $Self->_DoughnutChartToTicketType(
            %DoughnutChartToTicketType
        );

        push @DataCharts, {
            ChartName   => $LayoutObject->{LanguageObject}->Translate( 'Ticket type' ),
            DataJSON    => $JSONDoughnutChartToTicketType,
            Type        => 'Chart'
        };

        if(values %{$CustomerNews}){
            $LayoutObject->Block(
                Name => 'ShowChartTypeNews',
                Data => {}
            );
        }
        else{
            $LayoutObject->Block(
                Name => 'ShowChartType',
                Data => {}
            );
        }       
    }
    
    # send data to JS
    $LayoutObject->AddJSData(
        Key   => 'DataChart',
        Value => \@DataCharts
    );

    my $ActionTitle = $ConfigObject->Get('CustomerPortal::Core::ActionTitle');

    # build output
    my $Output = $CustomerPortalLayoutObject->CustomerHeader(Type => 'Small', Title => $ActionTitle->{HomePage} );

    $Output   .= $LayoutObject->Output(
        Data         => \%Param,
        TemplateFile => 'HomePage',
    );
    $Output   .= $LayoutObject->CustomerFooter(Type => 'Small');

    return $Output;
}

#-----------------------------------------------------------------#
#--- Function to generate chart: 'Chamados abertos x fechados' ---#
#-----------------------------------------------------------------#
sub _GenerateLineChart {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my @Lines;
    my @Days;

    foreach my $SearchParam ( sort keys %{$Param{Search}} ){

        my @Values;

        foreach my $DifTime ( reverse 0 .. $Param{Time} - 1 ){

            my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');

            my $DateTimeSettings = $DateTimeObject->Get();

            my $TimeEndString = $DateTimeObject->ToString();

            my $Success = $DateTimeObject->Subtract(
                Days    => $DifTime,
                Hours   => $DateTimeSettings->{Hour},
                Minutes => $DateTimeSettings->{Minute},
                Seconds => $DateTimeSettings->{Second},
            );

            my $TimeStartString = $DateTimeObject->ToString();

            if($DifTime){

                my $Success = $DateTimeObject->Add(
                    Hours   => 23,
                    Minutes => 59,
                    Seconds => 59,
                );

                $TimeEndString = $DateTimeObject->ToString();
            }

            my %TimeSearch;

            if ( $SearchParam eq $LayoutObject->{LanguageObject}->Translate( 'Open' ) ){

                %TimeSearch = (
                    TicketCreateTimeNewerDate => $TimeStartString,
                    TicketCreateTimeOlderDate => $TimeEndString,
                );
            }
            elsif ( $SearchParam eq $LayoutObject->{LanguageObject}->Translate( 'Closed' ) ){

                %TimeSearch = (
                    TicketCloseTimeNewerDate => $TimeStartString,
                    TicketCloseTimeOlderDate => $TimeEndString,
                );
            }

            my $Tickets = $TicketObject->TicketSearch(
                Result         => 'COUNT',
                CustomerID     => $Param{Customers},
                CustomerUserID => $Param{CustomerUserID},
                %TimeSearch,
            );

            if ( !$Tickets ){
                $Tickets = 0;
            }

            if(scalar @Days < $Param{Time}){

                $DateTimeSettings = $DateTimeObject->Get();

                if($DateTimeSettings->{Day} < 10){
                    $DateTimeSettings->{Day} = "0$DateTimeSettings->{Day}"
                }

                my $TranslateMonth = $LayoutObject->{LanguageObject}->Translate($DateTimeSettings->{MonthAbbr});

                push @Days, "$DateTimeSettings->{Day}/$TranslateMonth";
            }

            push @Values, int($Tickets);
        }

        push @Lines, {
            label => $SearchParam,
            data  => \@Values,
        };
    }

    my %Data = (
        labels   => \@Days,
        datasets => \@Lines
    );

    my %Options = (
        title => {
            display => 'true',
            text    => $Param{Title},
        },
        elements => {
            line => {
                tension => 0
            }
        },
        responsive => 'true'
    );

    my %JSONData = (
        Type    => $Param{Type},
        Data    => \%Data,
        Options => \%Options,
    );

    my $JSONString = $JSONObject->Encode(
        Data => \%JSONData,
    );

    return $JSONString;
}

#-----------------------------------------------------------------------------------#
#--- Function to generate chart: 'Chamados abertos e fechados - últimos 30 dias' ---#
#-----------------------------------------------------------------------------------#
sub _GenerateLineChartOpenMonth {
    my ( $Self, %Param ) = @_;

    # get objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $LastDays = $Param{Time};

    my @StateVersus = ( 'Closed', 'Open' );

    my @Days;
    my @Lines;

    for my $State ( @StateVersus ){

        my @Values;

        for my $DifTime (reverse 0 .. $LastDays - 1){

            my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');

            my $DateTimeSettings = $DateTimeObject->Get();

            my $TimeEndString = $DateTimeObject->ToString();

            my $Success = $DateTimeObject->Subtract(
                Days      => $DifTime,
                Hours     => $DateTimeSettings->{Hour},
                Minutes   => $DateTimeSettings->{Minute},
                Seconds   => $DateTimeSettings->{Second},
            );

            my $TimeStartString = $DateTimeObject->ToString();

            if($DifTime){

                my $Success = $DateTimeObject->Add(
                    Hours     => 23,
                    Minutes   => 59,
                    Seconds   => 59,
                );

                $TimeEndString = $DateTimeObject->ToString();
            }

            my %TimeSearch;

            if ( $State eq 'Open' ){
                %TimeSearch = (
                    TicketCreateTimeNewerDate => $TimeStartString,
                    TicketCreateTimeOlderDate => $TimeEndString,
                );
            }
            elsif ( $State eq 'Closed' ){
                %TimeSearch = (
                    TicketCloseTimeNewerDate => $TimeStartString,
                    TicketCloseTimeOlderDate => $TimeEndString,
                );
            }

            my $Tickets = $TicketObject->TicketSearch(
                Result => 'COUNT',
                CustomerUserID => $Param{CustomerUserID},
                CustomerID => $Param{Customers},
                %TimeSearch,
            );

            if ( !$Tickets ){
                $Tickets = 0;
            }

            if(scalar @Days < $LastDays){
                $DateTimeSettings = $DateTimeObject->Get();
                if($DateTimeSettings->{Day} < 10){
                    $DateTimeSettings->{Day} = "0$DateTimeSettings->{Day}"
                }
                my $TranslateMonth = $LayoutObject->{LanguageObject}->Translate($DateTimeSettings->{MonthAbbr});
                push @Days, "$DateTimeSettings->{Day}/$TranslateMonth";
            }

            push @Values, $Tickets;
        }

        push @Lines, {
            label   => $LayoutObject->{LanguageObject}->Translate($State),
            data => \@Values,
        };

    }

    my %Data = (
        labels   => \@Days,
        datasets => \@Lines
    );

    my %Options = (
        title => {
            display         => 'true',
            text            => $Param{Title},
        },
        elements => {
            line => {
                tension => 0.3
            }
        },
        scales => {
            yAxes => [
                {
                    ticks => {
                        beginAtZero => 'true'
                    }
                },
            ]
        },
        # responsive => 'true'
    );

    my %JSONData = (
        Type    => $Param{Type},
        Data    => \%Data,
        Options => \%Options,
    );

    my $JSONString = $JSONObject->Encode(
        Data => \%JSONData,
    );

    return $JSONString;
}

#------------------------------------------------------#
#--- Function to generate chart: 'Total por estado' ---#
#------------------------------------------------------#
sub _GeneratePieChart {
    my ( $Self, %Param ) = @_;

    # get objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my @Lines;
    my @Values;
    my @Labels;
    my %Data;

    my $ConfigArchives                 = $ConfigObject->Get('CustomerPortal::Core::ToEnableArchivedTickets');
    my $ConfigToEnableSearchByDate     = $ConfigObject->Get('CustomerPortal::Core::ToEnableSearchByDate');
    my $ConfigSearchByDateDefaultDays  = $ConfigObject->Get('CustomerPortal::Core::SearchByDateDefaultDays');
    my $ConfigSearchByDateCustomerDays = $ConfigObject->Get('CustomerPortal::Core::SearchByDateCustomerDays');

    # To convert days of config to minutes
    my $ConvertDaysToMinutes = $ConfigSearchByDateDefaultDays * 1440;

    foreach my $SearchParam ( sort keys %{$Param{Search}} ){

        my %Search = (
            CustomerUserID => $Param{CustomerUserID},
            CustomerID     => $Param{Customers},
            Result         => 'COUNT',
            %{$Param{Search}->{$SearchParam}},
        );

        # To archive ticket set search
        if($ConfigArchives eq '1'){             
            $Search{ArchiveFlags} = ['y', 'n'];
        }
            
        if($ConfigToEnableSearchByDate eq '1'){

            $Search{TicketCreateTimeNewerMinutes} = $ConvertDaysToMinutes;
        
            CUSTOMERDAYS:
            for my $CustomerID (keys %{$ConfigSearchByDateCustomerDays}){

                if($CustomerID eq $Self->{CustomerID}){

                    # Set customized date to CustomerID             
                    $Search{TicketCreateTimeNewerMinutes} = $ConfigSearchByDateCustomerDays->{$CustomerID} * 1440;
                    last CUSTOMERDAYS;
                }
            }
        }

        my $Tickets = $TicketObject->TicketSearch(
            %Search
        );

        if ( !$Tickets ){
            $Tickets = 0;
        }

        if($Param{Type} eq 'pie'){
            push @Labels, $LayoutObject->{LanguageObject}->Translate("$SearchParam");
            push @Values, int($Tickets);
        }
    } 

    %Data = (
        labels   => \@Labels,
        datasets => [
            {
            data => \@Values,
            }
        ]
    );

    my %Options = (
        title => {
            display => 'true',
            text    => $Param{Title},
        },
        elements => {
            line => {
                tension => 0
            }
        },            
    );

    my %JSONData = (
        Type    => $Param{Type},
        Data    => \%Data,
        Options => \%Options,
    );

    my $JSONString = $JSONObject->Encode(
        Data => \%JSONData,
    );

    return $JSONString;
}

#-------------------------------------------------------#
#--- Function to generate chart: 'Chamados por tipo' ---#
#-------------------------------------------------------#
sub _DoughnutChartToTicketType {
    my ( $Self, %Param ) = @_;

    # get objects
    my $StateObject  = $Kernel::OM->Get('Kernel::System::State');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TypeObject   = $Kernel::OM->Get('Kernel::System::Type');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @Lines;
    my @Values;
    my @Labels;
    my %Data;

    my %List = $TypeObject->TypeList(
        Valid => 1,
    );

    my $ConfigArchives                 =  $ConfigObject->Get('CustomerPortal::Core::ToEnableArchivedTickets');
    my $ConfigToEnableSearchByDate     =  $ConfigObject->Get('CustomerPortal::Core::ToEnableSearchByDate');
    my $ConfigSearchByDateDefaultDays  =  $ConfigObject->Get('CustomerPortal::Core::SearchByDateDefaultDays');
    my $ConfigSearchByDateCustomerDays =  $ConfigObject->Get('CustomerPortal::Core::SearchByDateCustomerDays');

    # To convert days of config to minutes
    my $ConvertDaysToMinutes = $ConfigSearchByDateDefaultDays * 1440;

    my %ListType = reverse %List;

    foreach my $SearchParam ( sort keys %ListType ){

        my %Search = (
            CustomerUserID => $Param{CustomerUserID},
            CustomerID => $Param{Customers},
            Result => 'COUNT',
            Types => [$SearchParam],
        );

        # To archive ticket set search
        if($ConfigArchives eq '1'){             
            $Search{ArchiveFlags} = ['y', 'n'];
        }

        if($ConfigToEnableSearchByDate eq '1'){

            $Search{TicketCreateTimeNewerMinutes} = $ConvertDaysToMinutes;
        
            CUSTOMERDAYS:
            for my $CustomerID (keys %{$ConfigSearchByDateCustomerDays}){

                if($CustomerID eq $Self->{CustomerID}){

                    # Set customized date to CustomerID             
                    $Search{TicketCreateTimeNewerMinutes} = $ConfigSearchByDateCustomerDays->{$CustomerID} * 1440;
                    last CUSTOMERDAYS;
                }
            }
        }


        my $Tickets = $TicketObject->TicketSearch(
            %Search
        );

        if ( !$Tickets ){
            $Tickets = 0;
        }

        push @Labels, $LayoutObject->{LanguageObject}->Translate("$SearchParam");
        push @Values, int($Tickets);

    } 

    %Data = (
        labels   => \@Labels,
        datasets => [
        {
            data => \@Values,
        }
        ]
    );

    my %Options = (
        title => {
            display         => 'true',
            text            => $Param{Title},
        },
        elements => {
            line => {
                tension => 0
            }
        },
    );

    my %JSONData = (
        Type    => $Param{Type},
        Data    => \%Data,
        Options => \%Options,
    );

    my $JSONString = $JSONObject->Encode(
        Data => \%JSONData,
    );

    return $JSONString;
}

#----------------------------------------------------------#
#--- Function to generate chart: 'Chamados por serviço' ---#
#----------------------------------------------------------#
sub _GenerateBarChart {
    my ( $Self, %Param ) = @_;

    my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
    my $ServiceObject         = $Kernel::OM->Get('Kernel::System::Service');
    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject          = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject          = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject           = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject            = $Kernel::OM->Get('Kernel::System::JSON');
    my $TimeObject            = $Kernel::OM->Get('Kernel::System::Time');

    my @SelectedCustomer = $ParamObject->GetArray( Param => 'CustomerID' );
    my $TimeStartDay     = $ParamObject->GetParam( Param => 'TimeStartDay' );
    my $TimeStartMonth   = $ParamObject->GetParam( Param => 'TimeStartMonth' );
    my $TimeStartYear    = $ParamObject->GetParam( Param => 'TimeStartYear' );
    my $TimeStopDay      = $ParamObject->GetParam( Param => 'TimeStopDay' );
    my $TimeStopMonth    = $ParamObject->GetParam( Param => 'TimeStopMonth' );
    my $TimeStopYear     = $ParamObject->GetParam( Param => 'TimeStopYear' );

    my $CreateTimeNewerDate;
    my $CreateTimeOlderDate;

    # to the first time that page apears
    if(!$TimeStartDay){

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
        $CreateTimeNewerDate = "$TimeStartYear-$TimeStartMonth-$TimeStartDay";
        $CreateTimeOlderDate = "$TimeStopYear-$TimeStopMonth-$TimeStopDay";
    };

    my %CustomerList = $CustomerCompanyObject->CustomerCompanyList(  Valid => 1 );
    my $Output;

    # build option string
    $Param{CustomerList} = $LayoutObject->BuildSelection(
        Data         => \%CustomerList,
        Name         => 'CustomerID',
        Multiple     => 1,
        Class        => 'Modernize' . ( $Param{Errors}->{'ValidIDInvalid'} || '' ),
        SelectedID   => \@SelectedCustomer,
        PossibleNone => 0,
    );

    $Param{TimeStart} = $LayoutObject->BuildDateSelection(
        %Param,
        Prefix   => 'TimeStart',
        Format   => 'DateInputFormat',
        DiffTime => -( 60 * 60 * 24 ) * 30 * 2,
        Validate => 1,
        ValidateDateNotInFuture => 1,
    );

    $Param{TimeStop} = $LayoutObject->BuildDateSelection(
        %Param,
        Prefix   => 'TimeStop',
        Format   => 'DateInputFormat',
        Validate => 1,
        ValidateDateNotInFuture => 1,
    );

    my %ServiceList = $ServiceObject->ServiceList(
        Valid  => 1,   
        UserID => 1,
    );

    my (@Data,@Label,@CustomerListAux);

    push @CustomerListAux, keys %CustomerList;

    my %ServiceData;

    SERVICE:
    foreach my $ServiceName (sort { $ServiceList{$b} cmp $ServiceList{$a} } keys %ServiceList) {

    my @Values;

    my @ServiceRoot = split( /::/x ,$ServiceList{$ServiceName});
    my $NameService = scalar @ServiceRoot;
    my $TotalTicketsService;

    my @Colors = map {
        "#". join "", map { sprintf "%02x", rand(255) } (0..2)
    } (0..1);

    next SERVICE if($NameService > 1);

    my $ConfigArchives                 = $ConfigObject->Get('CustomerPortal::Core::ToEnableArchivedTickets');
    my $ConfigToEnableSearchByDate     = $ConfigObject->Get('CustomerPortal::Core::ToEnableSearchByDate');
    my $ConfigSearchByDateDefaultDays  = $ConfigObject->Get('CustomerPortal::Core::SearchByDateDefaultDays');
    my $ConfigSearchByDateCustomerDays = $ConfigObject->Get('CustomerPortal::Core::SearchByDateCustomerDays');

    # To convert days of config to minutes
    my $ConvertDaysToMinutes = $ConfigSearchByDateDefaultDays * 1440;

    SERVICECHILDREN:
    foreach my $ChildrenServiceName (sort { $ServiceList{$b} cmp $ServiceList{$a} } keys %ServiceList) {

        my $TotalTickets;
        my @ServiceChildren = split( /::/x ,$ServiceList{$ChildrenServiceName});

        if( $ServiceChildren[0] ne $ServiceRoot[0] ){
            next SERVICECHILDREN;
        }

        my %Search = (
            Result                    => 'COUNT',
            UserID                    => 1,
            CustomerUserID            => $Param{CustomerUserID},
            CustomerID                => $Param{Customers},
            Services                  => [$ServiceList{$ChildrenServiceName}],
            TicketCreateTimeNewerDate => "$CreateTimeNewerDate 00:00:01",
            TicketCreateTimeOlderDate => "$CreateTimeOlderDate 23:59:59",
            StateType                 => ['open','new']
        );

        # To archive ticket set search
        if($ConfigArchives eq '1'){             
            $Search{ArchiveFlags} = ['y', 'n'];
        }

        if($ConfigToEnableSearchByDate eq '1'){

            $Search{TicketCreateTimeNewerMinutes} = $ConvertDaysToMinutes;
        
            CUSTOMERDAYS:
            for my $CustomerID (keys %{$ConfigSearchByDateCustomerDays}){

                if($CustomerID eq $Self->{CustomerID}){

                    # Set customized date to CustomerID             
                    $Search{TicketCreateTimeNewerMinutes} = $ConfigSearchByDateCustomerDays->{$CustomerID} * 1440;
                    last CUSTOMERDAYS;
                }
            }
        }
        
        $TotalTickets = $TicketObject->TicketSearch(
           %Search
        );      

        %ServiceData = $ServiceObject->ServiceGet(
            Name   => $ServiceList{$ChildrenServiceName},
            UserID => 1,
        );

        my $ServiceParentsList = $ServiceObject->ServiceParentsGet(
            ServiceID => $ServiceData{ServiceID},
            UserID    => 1,
        );

        if ( ( (IsArrayRefWithData($ServiceParentsList)) || ( $NameService == 1 ) ) && ( $ServiceChildren[0] eq $ServiceRoot[0] ) ) {
            $TotalTicketsService += $TotalTickets;
        }
        else{
            $TotalTicketsService = $TotalTickets;
        }
    }
    
    push @Values, $TotalTicketsService;

    if($TotalTicketsService != 0 ){
            push @Label, $ServiceData{Name};
            push @Data, {
                data => \@Values,
                backgroundColor => \@Colors,
                borderColor => \@Colors,
                borderWidth => 1,
                datalabels => {
                    align  => 'center',
                    anchor => 'center',
                },
                label => $ServiceData{Name},
            };
        }
    }

    $Param{Datasets} = $JSONObject->Encode(
        Data => \@Data,
    );

    $Param{Labels} = $JSONObject->Encode(
        Data => \@Label,
    );

    my %Data = (
        labels   => [$LayoutObject->{LanguageObject}->Translate( 'Family/Service' )],
        datasets => \@Data
    );

    my %Options = (
        title => {
            display => 'true',
            text    => $LayoutObject->{LanguageObject}->Translate( 'Ticket Services' ),
        },
        scales => {
            yAxes => [{
                ticks => {
                    beginAtZero => 'true',
                    fontStyle   => "bold",
                },
            }],
            xAxes => [{
                ticks => {
                    fontStyle => "bold",
                },

            }],
        },
        responsive => 'true'
    );

    my %JSONData = (
        Type    => 'bar',
        Data    => \%Data,
        Options => \%Options,
    );

    my $JSONString = $JSONObject->Encode(
        Data => \%JSONData,
    );

    return $JSONString;
}

sub _GetPathImage {
    my ( $Self, %Param ) = @_;

    return '' if !$Param{Image};

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    $Param{PathImage} = $ConfigObject->Get('Frontend::WebPath') . $Param{Image};

    if ( index($Param{Image}, 'http') != -1 || index($Param{Image}, 'https') != -1 || index($Param{Image}, 'ftp') != -1 ) {
        $Param{PathImage} = $Param{Image};
    }

    return $Param{PathImage};
}

1;