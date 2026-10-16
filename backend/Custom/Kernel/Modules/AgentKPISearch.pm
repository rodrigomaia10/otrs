# --
# Kernel/Modules/AgentKPISearch.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * dsilva@serviceup.com.br
# * gtiburtino@beonup.com.br
# * nfreitas@serviceup.com.br
# * ccresencio@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::AgentKPISearch;

use strict;
use warnings;

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
    
    my $Output;

    # get needed objects
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    my $Config = $ConfigObject->Get("Ticket::Frontend::AgentTicketSearch");

    # get config data
    $Self->{StartHit} = int( $ParamObject->GetParam( Param => 'StartHit' ) || 1 );
    $Self->{SearchLimit} = $Config->{SearchLimit} || 500;
    $Self->{SortBy} = $ParamObject->GetParam( Param => 'SortBy' )
        || $Config->{'SortBy::Default'}
        || 'Age';
    $Self->{OrderBy} = $ParamObject->GetParam( Param => 'OrderBy' )
        || $Config->{'Order::Default'}
        || 'Down';
    $Self->{Profile} = $ParamObject->GetParam( Param => 'Profile' ) || '';

    # get list type
    my $TreeView = 0;
    if ( $ConfigObject->Get('Ticket::Frontend::ListType') eq 'tree' ) {
        $TreeView = 1;
    }

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    # get needed objects
    my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $KPI;
    my %GetParam;
    my $DynamicFieldFilter;
    my $DynamicField;

    if( $Self->{Profile} ) {
        
        my $temp;    
        my ( $KPIID, $temp ) = split '_', $Self->{Profile};

        $KPI = $KPIObject->KPIGet(
            ID => $KPIID
        );

        if ( $KPI->{ObjectType} eq 'Ticket' ) {
            %GetParam = %{$KPI->{Search}};
        }

        # get dynamic field config for frontend module
        $DynamicFieldFilter = $Config->{DynamicField};

        # get the dynamic fields for ticket object
        $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
            Valid       => 1,
            ObjectType  => [ 'Ticket', 'Article' ],
            FieldFilter => $DynamicFieldFilter || {},
        );

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

    }
     
    # get needed objects
    my $UserObject  = $Kernel::OM->Get('Kernel::System::User');
    my $StateObject = $Kernel::OM->Get('Kernel::System::State');

    # show result site
    if ( $Self->{Subaction} eq 'Search' ) {

        # # get needed objects
        my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
        my $TimeObject         = $Kernel::OM->Get('Kernel::System::Time');

        my %ResultSearch = $KPIObject->GetSearch(
            KPIData     => $KPI,
            UserID      => $Self->{UserID},
            ExcelExport => 1,
        );

        # CSV and Excel output
        if ( $KPI->{ReturnFormat} eq 'Excel' ){

            # get Separator from language file
            my $UserCSVSeparator = $LayoutObject->{LanguageObject}->{Separator};

            if ( $ConfigObject->Get('PreferencesGroups')->{CSVSeparator}->{Active} ) {
                my %UserData = $UserObject->GetUserData( UserID => $Self->{UserID} );
                $UserCSVSeparator = $UserData{UserCSVSeparator} if $UserData{UserCSVSeparator};
            }

            my %HeaderMap = (
                TicketNumber => Translatable('Ticket Number'),
                CustomerName => Translatable('Customer Realname'),
            );

            my @CSVHeadTranslated = map { $LayoutObject->{LanguageObject}->Translate( $HeaderMap{$_} || $_ ); }
                @{$ResultSearch{CSVHead}};

            my $FileName = 'ticket_search';
            my ( $s, $m, $h, $D, $M, $Y ) = $TimeObject->SystemTime2Date(
                SystemTime => $TimeObject->SystemTime(),
            );
            $M = sprintf( "%02d", $M );
            $D = sprintf( "%02d", $D );
            $h = sprintf( "%02d", $h );
            $m = sprintf( "%02d", $m );

            # get CSV object
            my $CSVObject = $Kernel::OM->Get('Kernel::System::CSV');

			my $Excel = $CSVObject->Array2CSV(
				Head   => $ResultSearch{Head},
                Data   => $ResultSearch{Data},
				Format => 'Excel',
			);

			# return Excel to download
			return $LayoutObject->Attachment(
				Filename => $FileName . "_" . "$Y-$M-$D" . "_" . "$h-$m.xlsx",
				ContentType =>
					"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
				Content => $Excel,
			);

        }
        elsif( $KPI->{ReturnFormat} eq 'Link' ){
            return $LayoutObject->Redirect( ExtURL => "$KPI->{Link}" );
        }
        else {
            
            # redirect to the ticketzoom if result of the search is only one
            if ( scalar @{$ResultSearch{ViewableTicketID}} eq 1 && !$Self->{TakeLastSearch} ) {
                return $LayoutObject->Redirect(
                    # OP => "Action=AgentTicketZoom;TicketID=$ViewableTicketIDs[0]",
                    OP => "Action=AgentTicketZoom;TicketID=$ResultSearch{ViewableTicketID}[0]",
                );
            }

            # store last overview screen
            my $URL = "Action=AgentKPISearch;Subaction=Search;TakeLastSearch=1;Profile=".$LayoutObject->LinkEncode( $Self->{Profile} );

            $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
                SessionID => $Self->{SessionID},
                Key       => 'LastScreenOverview',
                Value     => $URL,
            );

            # start HTML page
            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();

            $Self->{Filter} = $ParamObject->GetParam( Param => 'Filter' ) || '';
            $Self->{View}   = $ParamObject->GetParam( Param => 'View' )   || '';

            # show tickets
            my $LinkPage = 'Filter='
                . $LayoutObject->LinkEncode( $Self->{Filter} )
                . ';View=' . $LayoutObject->LinkEncode( $Self->{View} )
                . ';SortBy=' . $LayoutObject->LinkEncode( $Self->{SortBy} )
                . ';OrderBy=' . $LayoutObject->LinkEncode( $Self->{OrderBy} )
                . ';Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';TakeLastSearch=1;Subaction=Search'
                . ';';
            my $LinkSort = 'Filter='
                . $LayoutObject->LinkEncode( $Self->{Filter} )
                . ';View=' . $LayoutObject->LinkEncode( $Self->{View} )
                . ';Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';TakeLastSearch=1;Subaction=Search'
                . ';';
            my $LinkFilter = 'TakeLastSearch=1;Subaction=Search;Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';';
            my $LinkBack = 'Subaction=LoadProfile;Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';TakeLastSearch=1&';

            my $FilterLink = 'SortBy=' . $LayoutObject->LinkEncode( $Self->{SortBy} )
                . ';OrderBy=' . $LayoutObject->LinkEncode( $Self->{OrderBy} )
                . ';View=' . $LayoutObject->LinkEncode( $Self->{View} )
                . ';Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';TakeLastSearch=1;Subaction=Search'
                . ';';

            $Output .= $LayoutObject->TicketListShow(
                TicketIDs => $ResultSearch{ViewableTicketID},
                Total     => scalar @{$ResultSearch{ViewableTicketID}},

                View => $Self->{View},

                Env        => $Self,
                LinkPage   => $LinkPage,
                LinkSort   => $LinkSort,
                LinkFilter => $LinkFilter,
                LinkBack   => $LinkBack,
                Profile    => $Self->{Profile},

                TitleName => Translatable('Search Results'),
                Bulk      => 1,
                Limit     => $Self->{SearchLimit},

                Filter     => $Self->{Filter},
                FilterLink => $FilterLink,

                OrderBy      => $Self->{OrderBy},
                SortBy       => $Self->{SortBy},
                RequestedURL => 'Action=' . $Self->{Action} . ';' . $LinkPage,

                # do not print the result earlier, but return complete content
                Output => 1,
            );

            # build footer
            $Output .= $LayoutObject->Footer();
            return $Output;
        }
    }
    # show result site
    elsif ( $Self->{Subaction} eq 'SearchSQL' ) {
        
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');
        
        if($KPI->{ReturnFormat} eq 'Link'){
            return $LayoutObject->Redirect( ExtURL => "$KPI->{Link}" );
        }else{
            my %Result = $KPIObject->GetSearchSQL(
                KPIData   => $KPI,
                UserID    => $Self->{UserID},
            );

            # get Separator from language file
            my $UserCSVSeparator = $LayoutObject->{LanguageObject}->{Separator};

            if ( $ConfigObject->Get('PreferencesGroups')->{CSVSeparator}->{Active} ) {
                my %UserData = $Kernel::OM->Get('Kernel::System::User')->GetUserData( UserID => $Self->{UserID} );
                $UserCSVSeparator = $UserData{UserCSVSeparator} if $UserData{UserCSVSeparator};
            }

            my $TimeStamp = $Kernel::OM->Create('Kernel::System::DateTime')->ToString();
            $TimeStamp =~ s/[:-]//g;
            $TimeStamp =~ s/ /-/;
            my $FileName  = $KPI->{Name} . ' - ' . $TimeStamp;
            my $CSVObject = $Kernel::OM->Get('Kernel::System::CSV');

            my $Excel = $CSVObject->Array2CSV(
                Head   => $Result{Head},
                Data   => $Result{Data},
                Format => 'Excel',
            );

            return $LayoutObject->Attachment(
                Filename => "$FileName" . ".xlsx",
                ContentType =>
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                Content => $Excel,
                Type    => 'attachment'
            );

            
        }
        
           
    }
    elsif( $Self->{Subaction} eq 'SearchAllKPIComplex'){
        my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
       
        my $DivIDs = $ParamObject->GetParam( Param => 'DivID');    

        # This part separates what comes from .js being the set and the clicked kpi column
        my @WordsOfdivJS = split /_/, $DivIDs;


        my $KPISeries = $KPIObject->SeriesGet(
            ID => $WordsOfdivJS[1],
        );	

        my $AssociatedKPIsCol = 'AssociatedKPIsCol' .  $WordsOfdivJS[2];

        my @KPIsAssociated = split ",", $KPISeries->{$AssociatedKPIsCol};

        my @ReturnTickets;
        for my $KPIID (@KPIsAssociated) {

            $KPI = $KPIObject->KPIGet(
                ID => $KPIID,
            );	   

            if($KPI->{ObjectType} eq 'Ticket'){
                %GetParam = %{$KPI->{Search}};
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
            for my $Attribute ( @{ $GetParam{ShownAttributes} || [] } ) {
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

                # perform ticket search
                @ViewableTicketIDs = $TicketObject->TicketSearch(
                    Result              => 'ARRAY',
                    SortBy              => $Self->{SortBy},
                    OrderBy             => $Self->{OrderBy},
                    Limit               => $Self->{SearchLimit},
                    UserID              => $Self->{UserID},
                    ConditionInline     => $Config->{ExtendedSearchCondition},
                    ContentSearchPrefix => '*',
                    ContentSearchSuffix => '*',
                    FullTextIndex       => 1,
                    %GetParam,
                    %DynamicFieldSearchParameters,
                );

                if ( $GetParam{SLARange} ){
                    my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');
                    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

                    my @Aux = @ViewableTicketIDs;
                    @ViewableTicketIDs = ();

                    my $TimeTill = $GetParam{SLARange};
                    my $StartTime = $TimeObject->SystemTime();

                    foreach my $TicketID (@Aux){

                        my %Ticket = $TicketObject->TicketGet(
                            TicketID => $TicketID,
                            UserID   => $Self->{UserID},
                            Extended => 1,
                        );

                        if( $Ticket{SLAID} && $Ticket{SolutionTimeDestinationDate} ){

                            my %SLAData = $SLAObject->SLAGet(
                                SLAID  => $Ticket{SLAID},
                                UserID => $Self->{UserID},
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

                                my $Percent = 100 - (($WorkingTimeMinutes/$SLAData{SolutionTime})*100);

                                if ( $Percent <= 25 && $TimeTill eq '25' ){
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
                    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

                    my @Aux = @ViewableTicketIDs;
                    @ViewableTicketIDs = ();

                    my $TimeTill = $GetParam{FirstResponseRange};
                    my $StartTime = $TimeObject->SystemTime();

                    foreach my $TicketID (@Aux){

                        my %Ticket = $TicketObject->TicketGet(
                            TicketID => $TicketID,
                            UserID   => $Self->{UserID},
                            Extended => 1,
                        );

                        if( $Ticket{SLAID} && $Ticket{FirstResponseTimeDestinationDate} ){

                            my %SLAData = $SLAObject->SLAGet(
                                SLAID  => $Ticket{SLAID},
                                UserID => $Self->{UserID},
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

                                my $Percent = ($WorkingTimeMinutes/$SLAData{FirstResponseTime}) * 100;

                                if ( $Percent <= 25 && $TimeTill eq '25' ){
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

                        my $GetSLAInAndOut = $KPIObject->SLAStatusSolutionTime(
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

            push @ReturnTickets,  @ViewableTicketIDs;

        }

        # get needed objects
        my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
        my $TimeObject         = $Kernel::OM->Get('Kernel::System::Time');

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
        for my $TicketID (@ReturnTickets){

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
            my %UserData = $UserObject->GetUserData( UserID => $Self->{UserID} );
            $UserCSVSeparator = $UserData{UserCSVSeparator} if $UserData{UserCSVSeparator};
        }

        my %HeaderMap = (
            TicketNumber => Translatable('Ticket Number'),
            CustomerName => Translatable('Customer Realname'),
        );

        my @CSVHeadTranslated = map { $LayoutObject->{LanguageObject}->Translate( $HeaderMap{$_} || $_ ); }
            @CSVHead;

        my $FileName = 'ticket_search';
        my ( $s, $m, $h, $D, $M, $Y ) = $TimeObject->SystemTime2Date(
            SystemTime => $TimeObject->SystemTime(),
        );
        $M = sprintf( "%02d", $M );
        $D = sprintf( "%02d", $D );
        $h = sprintf( "%02d", $h );
        $m = sprintf( "%02d", $m );

        # get CSV object
        my $CSVObject = $Kernel::OM->Get('Kernel::System::CSV');

        my $Excel = $CSVObject->Array2CSV(
            Head   => \@CSVHeadTranslated,
            Data   => \@CSVData,
            Format => 'Excel',
        );

        # return Excel to download
        return $LayoutObject->Attachment(
            Filename => $FileName . "_" . "$Y-$M-$D" . "_" . "$h-$m.xlsx",
            ContentType =>
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            Content => $Excel,
        );
    }
    # show result of Survey
    elsif ( $Self->{Subaction} eq 'SearchSurvey' ) {
        
        my $TimeObject         = $Kernel::OM->Get('Kernel::System::Time');

        my %ResultSearchSQL = $KPIObject->GetSearchSurvey(
            KPIData   => $KPI,
            UserID    => $Self->{UserID}
        );

         # CSV and Excel output
        if ( $KPI->{ReturnFormat} eq 'Excel' ){

            # get Separator from language file
            my $UserCSVSeparator = $LayoutObject->{LanguageObject}->{Separator};

            if ( $ConfigObject->Get('PreferencesGroups')->{CSVSeparator}->{Active} ) {
                my %UserData = $UserObject->GetUserData( UserID => $Self->{UserID} );
                $UserCSVSeparator = $UserData{UserCSVSeparator} if $UserData{UserCSVSeparator};
            }

            my %HeaderMap = (
                TicketNumber => Translatable('Ticket Number'),
                CustomerName => Translatable('Customer Realname'),
            );

            my @CSVHeadTranslated = map { $LayoutObject->{LanguageObject}->Translate( $HeaderMap{$_} || $_ ); }
                @{$ResultSearchSQL{CSVHead}};

            my $FileName = 'ticket_search';
            my ( $s, $m, $h, $D, $M, $Y ) = $TimeObject->SystemTime2Date(
                SystemTime => $TimeObject->SystemTime(),
            );
            $M = sprintf( "%02d", $M );
            $D = sprintf( "%02d", $D );
            $h = sprintf( "%02d", $h );
            $m = sprintf( "%02d", $m );

            # get CSV object
            my $CSVObject = $Kernel::OM->Get('Kernel::System::CSV');

			my $Excel = $CSVObject->Array2CSV(
				Head   => $ResultSearchSQL{Head},
				Data   => $ResultSearchSQL{Data},
				Format => 'Excel',
			);

			# return Excel to download
			return $LayoutObject->Attachment(
				Filename => $FileName . "_" . "$Y-$M-$D" . "_" . "$h-$m.xlsx",
				ContentType =>
					"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
				Content => $Excel,
			);

        }
        else {

            # redirect to the ticketzoom if result of the search is only one
            if ( scalar @{$ResultSearchSQL{ArrayOfTickets}}  eq 1 && !$Self->{TakeLastSearch} ) {
                return $LayoutObject->Redirect(
                    OP => "Action=AgentTicketZoom;TicketID=$ResultSearchSQL{ArrayOfTickets}[0]",
                );
            }

            # store last overview screen
            my $URL = "Action=AgentKPISearch;Subaction=Search;TakeLastSearch=1;Profile=".$LayoutObject->LinkEncode( $Self->{Profile} );

            $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
                SessionID => $Self->{SessionID},
                Key       => 'LastScreenOverview',
                Value     => $URL,
            );

            # start HTML page
            my $Output = $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();

            $Self->{Filter} = $ParamObject->GetParam( Param => 'Filter' ) || '';
            $Self->{View}   = $ParamObject->GetParam( Param => 'View' )   || '';

            # show tickets
            my $LinkPage = 'Filter='
                . $LayoutObject->LinkEncode( $Self->{Filter} )
                . ';View=' . $LayoutObject->LinkEncode( $Self->{View} )
                . ';SortBy=' . $LayoutObject->LinkEncode( $Self->{SortBy} )
                . ';OrderBy=' . $LayoutObject->LinkEncode( $Self->{OrderBy} )
                . ';Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';TakeLastSearch=1;Subaction=Search'
                . ';';
            my $LinkSort = 'Filter='
                . $LayoutObject->LinkEncode( $Self->{Filter} )
                . ';View=' . $LayoutObject->LinkEncode( $Self->{View} )
                . ';Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';TakeLastSearch=1;Subaction=Search'
                . ';';
            my $LinkFilter = 'TakeLastSearch=1;Subaction=Search;Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';';
            my $LinkBack = 'Subaction=LoadProfile;Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';TakeLastSearch=1&';

            my $FilterLink = 'SortBy=' . $LayoutObject->LinkEncode( $Self->{SortBy} )
                . ';OrderBy=' . $LayoutObject->LinkEncode( $Self->{OrderBy} )
                . ';View=' . $LayoutObject->LinkEncode( $Self->{View} )
                . ';Profile='
                . $LayoutObject->LinkEncode( $Self->{Profile} )
                . ';TakeLastSearch=1;Subaction=Search'
                . ';';

            $Output .= $LayoutObject->TicketListShow(
                TicketIDs => $ResultSearchSQL{ArrayOfTickets},
                Total     => scalar @{$ResultSearchSQL{ArrayOfTickets}},

                View => $Self->{View},

                Env        => $Self,
                LinkPage   => $LinkPage,
                LinkSort   => $LinkSort,
                LinkFilter => $LinkFilter,
                LinkBack   => $LinkBack,
                Profile    => $Self->{Profile},

                TitleName => Translatable('Search Results'),
                Bulk      => 1,
                Limit     => $Self->{SearchLimit},

                Filter     => $Self->{Filter},
                FilterLink => $FilterLink,

                OrderBy      => $Self->{OrderBy},
                SortBy       => $Self->{SortBy},
                RequestedURL => 'Action=' . $Self->{Action} . ';' . $LinkPage,

                # do not print the result earlier, but return complete content
                Output => 1,
            );

            # build footer
            $Output .= $LayoutObject->Footer();
            return $Output;
        }

           
    }

    # show default search screen
    $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();
    $LayoutObject->AddJSData(
        Key   => 'NonAJAXSearch',
        Value => 1,
    );

    if ( $Self->{Profile} ) {
        $LayoutObject->AddJSData(
            Key   => 'Profile',
            Value => $Self->{Profile},
        );
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentTicketSearch',
        Data         => \%Param,
    );
    $Output .= $LayoutObject->Footer();
    return $Output;
}

1;
