# --
# Kernel/Modules/AdminKPI.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * dsilva@serviceup.com.br
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::AdminKPI;

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

    # get object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( $Self->{Subaction} eq 'KPIDelete' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPIDelete(
            %Param,
        );
    }
    elsif( $Self->{Subaction} eq 'KPICopy'){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPICopy(
            %Param,
        );
    }
    elsif( $Self->{Subaction} eq 'KPIExport'){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPIExport(
            %Param,
        );
    }
    elsif( $Self->{Subaction} eq 'KPIImport'){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_KPIImport(
            %Param,
        );

    }

    return $Self->_ShowOverview(
        %Param,
        Action => 'Overview',
    );
}

sub _KPIImport {
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

    my $KPIImport = $KPIObject->KPIImport(
        Content                   => $UploadStuff{Content},
        OverwriteExistingEntities => $OverwriteExistingEntities,
        UserID                    => $Self->{UserID},
    );

    if ( !$KPIImport->{Success} ) {
        my $Message = $KPIImport->{Message}
            || Translatable(
            'KPIs could not be Imported due to a unknown error, please check OTRS logs for more information'
            );
        return $LayoutObject->ErrorScreen(
            Message => $Message,
        );
    }

    if ( $KPIImport->{AddedKPIs} ) {
        push @{ $Param{NotifyData} }, {
            Info => $LayoutObject->{LanguageObject}->Translate(
                'The following KPIs have been added successfully: %s',
                $KPIImport->{AddedKPIs}
            ),
        };
    }
    if ( $KPIImport->{UpdatedKPIs} ) {
        push @{ $Param{NotifyData} }, {
            Info => $LayoutObject->{LanguageObject}->Translate(
                'The following KPIs have been updated successfully: %s',
                $KPIImport->{UpdatedKPIs}
            ),
        };
    }
    if ( $KPIImport->{KPIErrors} ) {
        push @{ $Param{NotifyData} }, {
            Priority => 'Error',
            Info     => $LayoutObject->{LanguageObject}->Translate(
                'There where errors adding/updating the following KPIs: %s. Please check the log file for more information.',
                $KPIImport->{KPIErrors}
            ),
        };
    }

    return $Self->_ShowOverview(
        %Param,
    );
}

sub _KPIExport {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    my $KPIID = $ParamObject->GetParam( Param => 'ID' ) || '';
    my $KPIData;
    my $KPISingleData;
    my $Filename = 'Export_KPI.yml';

    if ($KPIID) {

        $KPISingleData = $KPIObject->KPIGet(
            ID     => $KPIID,
            UserID => 1,
        );

        if ( !$KPISingleData || !IsHashRefWithData($KPISingleData) ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}
                    ->Translate( 'There was an error getting data for KPI with ID %s', $KPIID ),
            );
        }

        my $KPIName = $KPISingleData->{Name};
        $KPIName =~ s{[^a-zA-Z0-9-_]}{_}xmsg;    # cleanup name for saving

        $Filename = 'Export_KPI_' . $KPIName . '.yml';
        $KPIData  = [$KPISingleData];
    }
    else {

        $KPIData = $KPIObject->KPIListGet(
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

sub _KPICopy {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    my $ID = $ParamObject->GetParam( Param => 'ID' );
 
    # get Kanban data
    my $KPIData = $KPIObject->KPIGet(
        ID     => $ID,
    );

    if ( !$KPIData ) {
        return $LayoutObject->ErrorScreen(
            Message => "Unknown KPI $ID!",
        );
    }
  
    # Create new KPI name.
    my $Count   = 1;
    my $KPIName = "$KPIData->{Name} (" . $LayoutObject->{LanguageObject}->Translate('Copy') . ") $Count";

    $KPIData->{GroupIDs} = join (',', @{$KPIData->{Groups}});

    while (
        $KPIObject->KPIGetByName(
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

    my $FieldID = $KPIObject->KPIAdd(
        %{$KPIData},
        ObjectType => $KPIData->{ObjectType},
    );
    
   
    # show KPIID if can't create
    if ( !$KPIData ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('There was an error creating the KPI'),
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

# AJAX sub-action
sub _KPIDelete {
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

    my $Success = $KPIObject->KPIDelete(
        ID     => $ID,
    );

    return $LayoutObject->Attachment(
        ContentType => 'text/html',
        Content     => $Success,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _ShowOverview {
    my ( $Self, %Param ) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $KPIObject         = $Kernel::OM->Get('Kernel::System::KPI');

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # call all needed template blocks
    $LayoutObject->Block(
        Name => 'Main',
        Data => \%Param,
    );

    # show notifications if any
    if ( $Param{NotifyData} ) {
        for my $Notification ( @{ $Param{NotifyData} } ) {
            $Output .= $LayoutObject->Notify(
                %{$Notification},
            );
        }
    }

    # get the KPI types (backends) and its config dialogs
    my %ObjectType = (
		'Ticket'        =>  Translatable('Ticket search'),
        'SQLQuery'      =>  Translatable('SQL query'),
        'ConfigItems'   =>  Translatable('Config Items'),
        'Survey'        =>  Translatable('Survey'),
        'ChartSQLQuery' =>  Translatable('Chart with SQL Query'),
	);

    # create the Add KPI select
    $Param{AddKPIStrg} = $LayoutObject->BuildSelection(
        Data          => \%ObjectType,
        Name          => 'KPISelect',
        PossibleNone  => 1,
        Translation   => 1,
        Sort          => 'AlphanumericValue',
        SelectedValue => '-',
        Class         => 'Modernize W75pc',
    );

    # call ActionAddKPI block
    $LayoutObject->Block(
        Name => 'ActionAddKPI',
        Data => {
            %Param,
        },
    );

    # call hint block
    $LayoutObject->Block( Name => 'Hint' );

    # get kpi list
    my $KPIList = $KPIObject->KPIList();

    # print the list of dynamic fields
    $Self->_KPIListShow(
        KPIs  => $KPIList,
        Total => scalar @{$KPIList},
    );

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminKPI',
        Data         => {
            %Param,
        },
    );

    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _KPIListShow {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
	my $ValidObject  = $Kernel::OM->Get('Kernel::System::Valid');
	my $KPIObject    = $Kernel::OM->Get('Kernel::System::KPI');

    # check start option, if higher than kpis available, set
    # it to the last field page
    my $StartHit = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'StartHit' ) || 1;

    # get personal page shown count
    my $PageShownPreferencesKey = 'AdminKPIOverviewPageShown';
    my $PageShown               = $Self->{$PageShownPreferencesKey} || 35;
    my $Group                   = 'KPIOverviewPageShown';

    # get data selection
    my %Data;
    my $Config = $Kernel::OM->Get('Kernel::Config')->Get('PreferencesGroups');
    if ( $Config && $Config->{$Group} && $Config->{$Group}->{Data} ) {
        %Data = %{ $Config->{$Group}->{Data} };
    }

    # calculate max. shown per page
    if ( $StartHit > $Param{Total} ) {
        my $Pages = int( ( $Param{Total} / $PageShown ) + 0.99999 );
        $StartHit = ( ( $Pages - 1 ) * $PageShown ) + 1;
    }

    # build nav bar
    my $Limit = $Param{Limit} || 20_000;
    my %PageNav = $LayoutObject->PageNavBar(
        Limit     => $Limit,
        StartHit  => $StartHit,
        PageShown => $PageShown,
        AllHits   => $Param{Total} || 0,
        Action    => 'Action=' . $LayoutObject->{Action},
        Link      => $Param{LinkPage},
        IDPrefix  => $LayoutObject->{Action},
    );

    # build shown dynamic fields per page
    $Param{RequestedURL}    = "Action=$Self->{Action}";
    $Param{Group}           = $Group;
    $Param{PreferencesKey}  = $PageShownPreferencesKey;
    $Param{PageShownString} = $LayoutObject->BuildSelection(
        Name        => $PageShownPreferencesKey,
        SelectedID  => $PageShown,
        Translation => 0,
        Data        => \%Data,
    );

    if (%PageNav) {
        $LayoutObject->Block(
            Name => 'OverviewNavBarPageNavBar',
            Data => \%PageNav,
        );

        $LayoutObject->Block(
            Name => 'ContextSettings',
            Data => { %PageNav, %Param, },
        );
    }

    # check if at least 1 dynamic field is registered in the system
    if ( $Param{Total} ) {

        # get KPIs details
        my $Counter = 0;

        my %ObjectType = (
            'Ticket' => 'Ticket',
            'SQL Query'     => 'SQLQuery',
            'Config Items'  => 'ConfigItems',
            'Survey'        => 'Survey',
            'ChartSQLQuery' => 'ChartSQLQuery',
        );
        
        KPIID:
        for my $KPIID ( @{ $Param{KPIs} } ) {
            $Counter++;
            if ( $Counter >= $StartHit && $Counter < ( $PageShown + $StartHit ) ) {
                my $KPI = $KPIObject->KPIGet(
                    ID => $KPIID,                    
                );
                next KPIID if !IsHashRefWithData($KPI);

                # get the object type display name
                my $ObjectTypeName = $KPI->{ObjectType};

				my @Names;
                
				foreach my $GroupID ( @{$KPI->{Groups}} ){
					push @Names, $GroupObject->GroupLookup( GroupID => $GroupID );
				}

				my $GroupNames = join (', ', @Names);

                # print each dynamic field row
                $LayoutObject->Block(
                    Name => 'DynamicFieldsRow',
                    Data => {
                        %{$KPI},
                        ActionObjectType => $ObjectType{$KPI->{ObjectType}},
                        ObjectTypeName => $ObjectTypeName,
                        GroupNames => $GroupNames,
						Validity => $ValidObject->ValidLookup( ValidID => $KPI->{ValidID} )
                    },
                );
            }
        }
    }

    # otherwise show a no data found message
    else {
        $LayoutObject->Block(
            Name => 'NoDataFound',
            Data => \%Param,
        );
    }

    return;
}

1;
