# --
# Kernel/Modules/AdminKPISeries.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::AdminKPISeries;

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

    # ------------------------------------------------------------ #
    # Series edit
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'SeriesEdit' ) {

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
    elsif ( $Self->{Subaction} eq 'SeriesSave' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

        # get params
        my %GetParam;
        for (qw(ID Name ValidID SerieType QtdColumn ChartTypeCol1 ChartTypeCol2 ChartTypeCol3 TitleCol1 TitleCol2 TitleCol3 TitleChartSQLCol1 TitleChartSQLCol2 TitleChartSQLCol3 TypeLabelCol1 TypeLabelCol2 TypeLabelCol3 DefaultSerie
            ChartScaleTimeCol1 ChartScaleTimeCol2 ChartScaleTimeCol3 ChartScaleUnitCol1 ChartScaleUnitCol2 ChartScaleUnitCol3 TypeLabelChartSQLCol1 TypeLabelChartSQLCol2 TypeLabelChartSQLCol3)) {
            $GetParam{$_} = $ParamObject->GetParam( Param => $_ ) || '';
        }
        
		my @AssociatedKPIs = $ParamObject->GetArray( Param => 'AssociatedKPIs' );
		$GetParam{AssociatedKPIs} = join ",",@AssociatedKPIs;

		my @GroupIDs = $ParamObject->GetArray( Param => 'GroupIDs' );
		$GetParam{GroupIDs} = join ",",@GroupIDs;

        my @AssociatedKPIsCol1 = $ParamObject->GetArray( Param => 'AssociatedKPIsCol1' );
		$GetParam{AssociatedKPIsCol1} = join ",",@AssociatedKPIsCol1;

        my @AssociatedKPIsCol2 = $ParamObject->GetArray( Param => 'AssociatedKPIsCol2' );
		$GetParam{AssociatedKPIsCol2} = join ",",@AssociatedKPIsCol2;

        my @AssociatedKPIsCol3 = $ParamObject->GetArray( Param => 'AssociatedKPIsCol3' );
		$GetParam{AssociatedKPIsCol3} = join ",",@AssociatedKPIsCol3;

        my @AssociatedKPIsChartSQLCol1 = $ParamObject->GetArray( Param => 'AssociatedKPIsChartSQLCol1' );
		$GetParam{AssociatedKPIsChartSQLCol1} = join ",",@AssociatedKPIsChartSQLCol1;

        my @AssociatedKPIsChartSQLCol2 = $ParamObject->GetArray( Param => 'AssociatedKPIsChartSQLCol2' );
		$GetParam{AssociatedKPIsChartSQLCol2} = join ",",@AssociatedKPIsChartSQLCol2;

        my @AssociatedKPIsChartSQLCol3 = $ParamObject->GetArray( Param => 'AssociatedKPIsChartSQLCol3' );
		$GetParam{AssociatedKPIsChartSQLCol3} = join ",",@AssociatedKPIsChartSQLCol3;
        
        my %Error;

        if ( !$GetParam{Name} ) {
            $Error{'NameInvalid'} = 'ServerError';
        }

        if ( $GetParam{DefaultSerie} eq '' ) {
            $GetParam{DefaultSerie} = 0;
        } 

        if ( !%Error ) {
            
            my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
            
            # save to database
            if ( $GetParam{ID} eq 'NEW' ) {
                $GetParam{SeriesID} = $KPIObject->SeriesAdd(
                    %GetParam,
                    UserID => $Self->{UserID},
                );
                if ( !$GetParam{ID} ) {
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }
            else {
                my $Success = $KPIObject->SeriesUpdate(
                    %GetParam,
                    UserID => $Self->{UserID},
                );
                if ( !$Success ) {
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }

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
    elsif ($Self->{Subaction} eq  'AJAXSerieTypeChange'){
        my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

        my $SerieType = $ParamObject->GetParam( Param => 'SerieType' ) || '';

        my %SeriesData;
        if($SerieType eq 'Simple'){          

            my $JSON = $LayoutObject->JSONEncode(
                Data => {}
            );   

            return $LayoutObject->Attachment(
                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                Content     => $JSON || '',
                Type        => 'inline',
                NoCache     => 1,
            );

        }else{

        }
        
    }
    # ------------------------------------------------------------ #
    # Series delete
    # ------------------------------------------------------------ #
    elsif($Self->{Subaction} eq  'KPISeriesDelete'){

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPISeriesDelete(
            %Param,
        );

    }
    # ------------------------------------------------------------ #
    # Series copy
    # ------------------------------------------------------------ #
    elsif( $Self->{Subaction} eq 'KPISeriesCopy'){
       # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPISeriesCopy(
            %Param,
        );
    }
    # ------------------------------------------------------------ #
    # Series Export
    # ------------------------------------------------------------ #
    elsif( $Self->{Subaction} eq 'KPISeriesExport'){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPISeriesExport(
            %Param,
        );
    }
    # ------------------------------------------------------------ #
    # Series Import
    # ------------------------------------------------------------ #
    elsif( $Self->{Subaction} eq 'KPISeriesImport'){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPISeriesImport(
            %Param,
        );

    }
    # ------------------------------------------------------------ #
    # Series overview
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
            TemplateFile => 'AdminKPISeries',
            Data         => \%Param,
        );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
}


sub _KPISeriesImport {
    my ( $Self, %Param ) = @_;

    # Get Objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    my $FormID      = $ParamObject->GetParam( Param => 'FormID' ) || '';
    my %UploadStuff = $ParamObject->GetUploadAll(
        Param  => 'FileUpload',
        Source => 'string',
    );

    my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' ) || '';

    my $KPIImport = $KPIObject->KPISeriesImport(
        Content                   => $UploadStuff{Content},
        OverwriteExistingEntities => $OverwriteExistingEntities,
        UserID                    => $Self->{UserID},
    );

    if ( !$KPIImport->{Success} ) {
        my $Message = $KPIImport->{Message}
            || Translatable(
            'KPI Series could not be Imported due to a unknown error, please check OTRS logs for more information'
            );
        return $LayoutObject->ErrorScreen(
            Message => $Message,
        );
    }

    if ( $KPIImport->{AddedKPIs} ) {
        push @{ $Param{NotifyData} }, {
            Info => $LayoutObject->{LanguageObject}->Translate(
                'The following KPIs series have been added successfully: %s',
                $KPIImport->{AddedKPIs}
            ),
        };
    }
    if ( $KPIImport->{UpdatedKPIs} ) {
        push @{ $Param{NotifyData} }, {
            Info => $LayoutObject->{LanguageObject}->Translate(
                'The following KPIs series have been updated successfully: %s',
                $KPIImport->{UpdatedKPIs}
            ),
        };
    }
    if ( $KPIImport->{KPIErrors} ) {
        push @{ $Param{NotifyData} }, {
            Priority => 'Error',
            Info     => $LayoutObject->{LanguageObject}->Translate(
                'There where errors adding/updating the following KPIs series: %s. Please check the log file for more information.',
                $KPIImport->{KPIErrors}
            ),
        };
    }

    # return $LayoutObject->Redirect( OP => 'Action=PublicFAQZoom;ItemID=' . $ItemID );

     # output header
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # output overview
    $LayoutObject->Block(
        Name => 'Overview',
        Data => { %Param, },
    );

    # show notifications if any
    if ( $Param{NotifyData} ) {
        for my $Notification ( @{ $Param{NotifyData} } ) {
            $Output .= $LayoutObject->Notify(
                %{$Notification},
            );
        }
    }

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionAdd' );

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
        TemplateFile => 'AdminKPISeries',
        Data         => \%Param,
    );
    $Output .= $LayoutObject->Footer();

    return $Output;
}


sub _KPISeriesExport {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    my $KPIID = $ParamObject->GetParam( Param => 'ID' ) || '';
    my $KPIData;
    my $KPISingleData;
    my $Filename = 'Export_KPI_Series.yml';

    if ($KPIID) {

        $KPISingleData = $KPIObject->SeriesGet(
            ID     => $KPIID,
            UserID => 1,
        );

        if ( !$KPISingleData || !IsHashRefWithData($KPISingleData) ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}
                    ->Translate( 'There was an error getting data for KPI serie with ID %s', $KPIID ),
            );
        }

        my $KPIName = $KPISingleData->{Name};
        $KPIName =~ s{[^a-zA-Z0-9-_]}{_}xmsg;    # cleanup name for saving

        $Filename = 'Export_KPI_Series' . $KPIName . '.yml';
        $KPIData  = [$KPISingleData];
    }
    else {

        $KPIData = $KPIObject->KPISeriesListGet(
            UserID   => 1,
        );
    }

    # convert the KPI data hash to string
    my $KPIDataYAML = $Kernel::OM->Get('Kernel::System::YAML')->Dump( Data => $KPIData );

    # send the result to the browser
    return $LayoutObject->Attachment(
        ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
        Content     => $KPIDataYAML,
        Type        => 'attachment',
        Filename    => $Filename,
        NoCache     => 1,
    );
}

sub _KPISeriesCopy {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    my $ID = $ParamObject->GetParam( Param => 'ID' );
 
    # get Kanban data
    my $KPIData = $KPIObject->SeriesGet(
        ID     => $ID,
    );

    if ( !$KPIData ) {
        return $LayoutObject->ErrorScreen(
            Message => "Unknown KPI Series $ID!",
        );
    }
  
    # Create new KPI name.
    my $Count   = 1;
    my $KPIName = "$KPIData->{Name} (" . $LayoutObject->{LanguageObject}->Translate('Copy') . ") $Count";

    while (
        $KPIObject->KPISeriesGetByName(
            Name   => $KPIName,
            Valid => 1
        )
        && $Count < 100
        )
    {
        $KPIName =~ s/\d+$/$Count/;      
        $Count++;
    }

    $KPIData->{Name} = $KPIName;

    my $FieldID =  $KPIObject->SeriesAdd(
        %{$KPIData},
        UserID => $Self->{UserID},
    );

   
    # show KPIID if can't create
    if ( !$KPIData ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('There was an error creating the KPI Series'),
        );
    }

    my $JSON = "{}";
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _KPISeriesDelete {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    my $Confirmed = $ParamObject->GetParam( Param => 'Confirmed' );

    if ( !$Confirmed ) {
        $LogObject->Log(
            'Priority' => 'error',
            'Message'  => "Need 'Confirmed'!",
        );
        return;
    }

    my $ID = $ParamObject->GetParam( Param => 'ID' );

    my $Success = $KPIObject->KPISeriesDelete(
        ID     => $ID,
    );

    return $LayoutObject->Attachment(
        ContentType => 'text/html',
        Content     => $Success,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _MaskNew {
    my ( $Self, %Param ) = @_;

    my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');
    my %SeriesData;

    # get params
    $SeriesData{ID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "ID" );

    if ( $SeriesData{ID} ne 'NEW' ) {
        my $Series = $KPIObject->SeriesGet(
            ID => $SeriesData{ID},
        );
        
		%SeriesData = %{$Series};

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

    # get list type
    my $ListType = $ConfigObject->Get('Ticket::Frontend::ListType');

    # generate ParentOptionStrg
    my %SeriesList = $KPIObject->SeriesList();

    # get valid list
    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $SeriesData{ValidOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $SeriesData{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize',
    );

    # get column
    my %ColumnList = (
        1 => '1',
        2 => '2',
        3 => '3'
    );

    $SeriesData{QtdColumnStrg} = $LayoutObject->BuildSelection(
        Data       => \%ColumnList,
        Name       => 'QtdColumn',
        SelectedID => $SeriesData{QtdColumn},
        Class      => 'Modernize',
        PossibleNone => 1

    );
    
    # serie type
    my %SerieType = (
        Complex => 'Complex',
        Simple => 'Simple',
        ChartSQLQuery => 'Chart with SQL Query',
    );

    $SeriesData{SerieTypeStrg} = $LayoutObject->BuildSelection(
        Data       => \%SerieType,
        Name       => 'SerieType',
        SelectedID => $SeriesData{SerieType} || 'Simple',
        Class      => 'Modernize',
    );

    # serie type
    my %ChartType = (
        Pie =>  Translatable('Pie'),
        Donut => Translatable('Donut'), 
        Bar => Translatable('Bar'),
        Column => Translatable('Column'),
        Line => Translatable('Line'),
    );

    $SeriesData{ChartTypeStringCol1} = $LayoutObject->BuildSelection(
        Data       => \%ChartType,
        Name       => 'ChartTypeCol1',
        SelectedID => $SeriesData{ChartTypeCol1} || 'pie',
        Class      => 'Modernize Validate_Required',
        PossibleNone => 1,
    );

    $SeriesData{ChartTypeStringCol2} = $LayoutObject->BuildSelection(
        Data       => \%ChartType,
        Name       => 'ChartTypeCol2',
        SelectedID => $SeriesData{ChartTypeCol2} || 'pie',
        Class      => 'Modernize Validate_Required',
        PossibleNone => 1
    );

    $SeriesData{ChartTypeStringCol3} = $LayoutObject->BuildSelection(
        Data       => \%ChartType,
        Name       => 'ChartTypeCol3',
        SelectedID => $SeriesData{ChartTypeCol3} || 'pie',
        Class      => 'Modernize Validate_Required',
        PossibleNone => 1
    );

    # serie scala
    my %ChartScaleTime;
    for my $Key ( 1 .. 60 ) {
        $ChartScaleTime{$Key} = $Key;
    }

    $SeriesData{ChartScaleTimeCol1} = $LayoutObject->BuildSelection(
        Data       => \%ChartScaleTime,
        Name       => 'ChartScaleTimeCol1',
        SelectedID => $SeriesData{ChartScaleTimeCol1} || '1',
        Class      => 'Modernize',
        PossibleNone => 0
    );

    $SeriesData{ChartScaleTimeCol2} = $LayoutObject->BuildSelection(
        Data       => \%ChartScaleTime,
        Name       => 'ChartScaleTimeCol2',
        SelectedID => $SeriesData{ChartScaleTimeCol2} || '1',
        Class      => 'Modernize',
        PossibleNone => 0
    );

    $SeriesData{ChartScaleTimeCol3} = $LayoutObject->BuildSelection(
        Data       => \%ChartScaleTime,
        Name       => 'ChartScaleTimeCol3',
        SelectedID => $SeriesData{ChartScaleTimeCol3} || '1',
        Class      => 'Modernize',
        PossibleNone => 0
    );

    # serie scala
    my %ChartScaleUnit = (
        Day  =>  Translatable('Day(s)'),
        Month => Translatable('Month(s)'),
        Quarter => Translatable('Quarter(s)'),
        Semester => Translatable('Semester(s)'),
        Year => Translatable('Years(s)'),
    );

    $SeriesData{ChartScaleUnitCol1} = $LayoutObject->BuildSelection(
        Data       => \%ChartScaleUnit,
        Name       => 'ChartScaleUnitCol1',
        SelectedID => $SeriesData{ChartScaleUnitCol1} || 'Month',
        Class      => 'Modernize',
        PossibleNone => 0
    );

    $SeriesData{ChartScaleUnitCol2} = $LayoutObject->BuildSelection(
        Data       => \%ChartScaleUnit,
        Name       => 'ChartScaleUnitCol2',
        SelectedID => $SeriesData{ChartScaleUnitCol2} || 'Month',
        Class      => 'Modernize',
        PossibleNone => 0
    );

    $SeriesData{ChartScaleUnitCol3} = $LayoutObject->BuildSelection(
        Data       => \%ChartScaleUnit,
        Name       => 'ChartScaleUnitCol3',
        SelectedID => $SeriesData{ChartScaleUnitCol3} || 'Month',
        Class      => 'Modernize',
        PossibleNone => 0
    );

    # serie type of label
    my %TypeOfLabel = (
        Percentage =>  Translatable('Percentage'),
        Number => Translatable('Number'), 
    );

    $SeriesData{TypeLabelCol1Sting} = $LayoutObject->BuildSelection(
        Data       => \%TypeOfLabel,
        Name       => 'TypeLabelCol1',
        SelectedID => $SeriesData{TypeLabelCol1} || 'Number',
        Class      => 'Modernize',
        PossibleNone => 1
    );

    $SeriesData{TypeLabelCol2Sting} = $LayoutObject->BuildSelection(
        Data       => \%TypeOfLabel,
        Name       => 'TypeLabelCol2',
        SelectedID => $SeriesData{TypeLabelCol2} || 'Number',
        Class      => 'Modernize',
        PossibleNone => 1
    );

    $SeriesData{TypeLabelCol3Sting} = $LayoutObject->BuildSelection(
        Data       => \%TypeOfLabel,
        Name       => 'TypeLabelCol3',
        SelectedID => $SeriesData{TypeLabelCol3} || 'Number',
        Class      => 'Modernize',
        PossibleNone => 1
    );

    #Cannot select from percentage or number type.

    # $SeriesData{TypeLabelChartSQLCol1Sting} = $LayoutObject->BuildSelection(
    #     Data       => \%TypeOfLabel,
    #     Name       => 'TypeLabelChartSQLCol1',
    #     SelectedID => $SeriesData{TypeLabelChartSQLCol1} || 'Number',
    #     Class      => 'Modernize',
    #     PossibleNone => 1
    # );

    # $SeriesData{TypeLabelChartSQLCol2Sting} = $LayoutObject->BuildSelection(
    #     Data       => \%TypeOfLabel,
    #     Name       => 'TypeLabelChartSQLCol2',
    #     SelectedID => $SeriesData{TypeLabelChartSQLCol2} || 'Number',
    #     Class      => 'Modernize',
    #     PossibleNone => 1
    # );

    # $SeriesData{TypeLabelChartSQLCol3Sting} = $LayoutObject->BuildSelection(
    #     Data       => \%TypeOfLabel,
    #     Name       => 'TypeLabelChartSQLCol3',
    #     SelectedID => $SeriesData{TypeLabelChartSQLCol3} || 'Number',
    #     Class      => 'Modernize',
    #     PossibleNone => 1
    # );

	my $KPIs = $KPIObject->KPIList();

	my %KPIData;
	my %KPIDataChartSQLQuery;

	KPI:
	foreach my $KPIID ( @{$KPIs} ){

		my $KPI = $KPIObject->KPIGet(
			ID => $KPIID,
		);

		next KPI if $KPI->{ValidID} == 0;
        
        if ( $KPI->{ObjectType} eq 'ChartSQLQuery' ) {
		
            $KPIDataChartSQLQuery{$KPIID} = $KPI->{Name};
        }
        else {
            $KPIData{$KPIID} = $KPI->{Name};
        }
	}

    # KPISimple:
	# foreach my $KPIID ( @{$KPIs} ){

	# 	my $KPI = $KPIObject->KPIGet(
	# 		ID => $KPIID,
	# 	);
        
	# 	# next KPISimple if $KPI->{ObjectType} ne 'Ticket';

	# 	next KPISimple if $KPI->{ValidID} == 0;

	# 	$KPIDataSimple{$KPIID} = $KPI->{Name};
	# }

	my @KPIs = split ",", $SeriesData{AssociatedKPIs};
	my @KPIs1 = split ",", $SeriesData{AssociatedKPIsCol1};
	my @KPIs2 = split ",", $SeriesData{AssociatedKPIsCol2};
	my @KPIs3 = split ",", $SeriesData{AssociatedKPIsCol3};
	my @KPIsChartSQL1 = split ",", $SeriesData{AssociatedKPIsChartSQLCol1};
	my @KPIsChartSQL2 = split ",", $SeriesData{AssociatedKPIsChartSQLCol2};
	my @KPIsChartSQL3 = split ",", $SeriesData{AssociatedKPIsChartSQLCol3};

	$SeriesData{KPIOptionString} = $LayoutObject->BuildSelection(
        Data       => \%KPIData,
        Name       => 'AssociatedKPIs',
        SelectedID => \@KPIs,
        Class      => 'Modernize',
		Multiple => 1,
    );

	$SeriesData{KPIOptionStringCol1} = $LayoutObject->BuildSelection(
        Data       => \%KPIData,
        Name       => 'AssociatedKPIsCol1',
        SelectedID => \@KPIs1,
        Class      => 'Modernize Validate_Required',
		Multiple => 1,
    );

    $SeriesData{KPIOptionStringCol2} = $LayoutObject->BuildSelection(
        Data       => \%KPIData,
        Name       => 'AssociatedKPIsCol2',
        SelectedID => \@KPIs2,
        Class      => 'Modernize Validate_Required',
		Multiple => 1,
    );

    $SeriesData{KPIOptionStringCol3} = $LayoutObject->BuildSelection(
        Data       => \%KPIData,
        Name       => 'AssociatedKPIsCol3',
        SelectedID => \@KPIs3,
        Class      => 'Modernize Validate_Required',
		Multiple => 1,
    );

    $SeriesData{KPIOptionChartSQLStringCol1} = $LayoutObject->BuildSelection(
        Data       => \%KPIDataChartSQLQuery,
        Name       => 'AssociatedKPIsChartSQLCol1',
        SelectedID => \@KPIsChartSQL1,
        Class      => 'Modernize Validate_Required',
		PossibleNone => 1,
    );

    $SeriesData{KPIOptionChartSQLStringCol2} = $LayoutObject->BuildSelection(
        Data       => \%KPIDataChartSQLQuery,
        Name       => 'AssociatedKPIsChartSQLCol2',
        SelectedID => \@KPIsChartSQL2,
        Class      => 'Modernize Validate_Required',
		PossibleNone => 1,
    );

    $SeriesData{KPIOptionChartSQLStringCol3} = $LayoutObject->BuildSelection(
        Data       => \%KPIDataChartSQLQuery,
        Name       => 'AssociatedKPIsChartSQLCol3',
        SelectedID => \@KPIsChartSQL3,
        Class      => 'Modernize Validate_Required',
		PossibleNone => 1,
    );

	my @GroupIDs = split ",", $SeriesData{GroupIDs};

	my %Groups       = $Kernel::OM->Get('Kernel::System::Group')->GroupList( Valid => 1 );
	$SeriesData{GroupsStrg} = $LayoutObject->BuildSelection(
        Data         => \%Groups,
        Name         => 'GroupIDs',
        SelectedID   => \@GroupIDs,
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize W50pc',
		Multiple     => 1,
    );

    $Param{Class} = 'HiddenByKPI';

    $Param{Checked} = '';
    if ( $SeriesData{DefaultSerie} eq '1' ) {
        $Param{Checked} = 'checked="checked"';
    }
    # output Series edit
    $LayoutObject->Block(
        Name => 'SeriesEdit',
        Data => { %Param, %SeriesData, },
    );
    
    # shows header
    if ( $SeriesData{ID} ne 'NEW' ) {
        $LayoutObject->Block(
            Name => 'HeaderEdit',
            Data => {%SeriesData},
        );
    }
    else {
        $LayoutObject->Block( Name => 'HeaderAdd' );
    }
   
    # generate output
    return $LayoutObject->Output(
        TemplateFile => 'AdminKPISeries',
        Data         => \%Param
    );
}

1;