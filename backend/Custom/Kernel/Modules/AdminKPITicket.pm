# --
# Kernel/Modules/AdminKPITicket.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * dsilva@serviceup.com.br
# * ccresencio@serviceup.com.br
# * mtatangelo@serviceup.com.br
# * dparavani@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminKPITicket;

use strict;
use warnings;

use utf8;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);
use Kernel::Modules::AdminKPISearch;

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    if ( $Self->{Subaction} eq 'Add' ) {
        return $Self->_Add(
            %Param,
        );
    }
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_AddAction(
            %Param,
        );
    }
    if ( $Self->{Subaction} eq 'Change' ) {
      
        return $Self->_Change(
            %Param,
        );
    }
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_ChangeAction(
            %Param,
        );
    }
    return $LayoutObject->ErrorScreen(
        Message => Translatable('Undefined subaction.'),
    );
}

sub _Add {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %GetParam;

    # get the object type and field type display name
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    return $Self->_ShowScreen(
        %Param,
        Mode => 'Add',
    );
}

sub _AddAction {
    my ( $Self, %Param ) = @_;

    my %Errors;
    my %GetParam;
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');

    for my $Needed (qw(Name)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = Translatable('This field is required.');
        }
    }

	if ( $GetParam{Name} ) {

       my $KPIList = $KPIObject->KPIList();

       foreach my $KPIID ( @{$KPIList} ){
			my $KPI = $Kernel::OM->Get('Kernel::System::KPI')->KPIGet(
				ID => $KPIID,
			);

			if ( $GetParam{Name} eq $KPI->{Name} ){
				# add server error error class
				$Errors{NameServerError}        = 'ServerError';
				$Errors{NameServerErrorMessage} = Translatable('There is another KPI with the same name.');
			}
		}
    }

	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    for my $ConfigParam (
        qw(ReturnFormat ObjectTypeName ValidID)
        )
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );

		# uncorrectable errors
		if ( !$GetParam{$ConfigParam} ){
			return $LayoutObject->ErrorScreen(
				Message => Translatable("Need $ConfigParam"),
			);
		}
    }

	@{$GetParam{GroupIDs}} = $ParamObject->GetArray( Param => "GroupIDs" );

	$GetParam{GroupIDs} = join (',', @{$GetParam{GroupIDs}});
	$GetParam{SeverityOrder} = $ParamObject->GetParam( Param => "SeverityOrder" );
	$GetParam{TypeKPI} = $ParamObject->GetParam( Param => "TypeKPI" );

    # return to add screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            Mode => 'Add',
        );
    }

	my %Filters = $Self->_GetFilters();

	$GetParam{MinValue} = $ParamObject->GetParam( Param => 'MinValue' );
	$GetParam{MaxValue} = $ParamObject->GetParam( Param => 'MaxValue' );
    $GetParam{SLARangeMinValue} = $ParamObject->GetParam( Param => 'SLARangeMinValue' );
	$GetParam{SLARangeMaxValue} = $ParamObject->GetParam( Param => 'SLARangeMaxValue' );
    $GetParam{FirstResponseRangeMinValue} = $ParamObject->GetParam( Param => 'FirstResponseRangeMinValue' );
	$GetParam{FirstResponseRangeMaxValue} = $ParamObject->GetParam( Param => 'FirstResponseRangeMaxValue' );
    $GetParam{Color} = $ParamObject->GetParam( Param => 'Color' );
    $GetParam{Link}  = $ParamObject->GetParam( Param => 'Link' );

	my %Rules;

	for my $Index ( 1..4 ){
		my $RuleLabel = $ParamObject->GetParam( Param => "RuleLabel$Index" );
		my $RuleColor = $ParamObject->GetParam( Param => "RuleColor$Index" );

		$Rules{"Rule$Index"} = $RuleLabel;
        $Rules{"RuleColor$Index"} = $RuleColor;
	}

    # create a new KPI
    my $FieldID = $KPIObject->KPIAdd(
		%GetParam,
        ObjectType => "Ticket",
		Search   => \%Filters,
		Rules => \%Rules,
    );

    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Could not create the new KPI'),
        );
    }

    return $LayoutObject->Redirect(
        OP => "Action=AdminKPI",
    );
}

sub _Change {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $KPID = $ParamObject->GetParam( Param => 'ID' );

    if ( !$KPID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Need ID'),
        );
    }

    # get KPI data
    my $KPIData = $Kernel::OM->Get('Kernel::System::KPI')->KPIGet(
        ID => $KPID,
    );

    # check for valid KPI configuration
    if ( !IsHashRefWithData($KPIData) ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'Could not get data for KPI %s', $KPID ),
        );
    }

    return $Self->_ShowScreen(
        %Param,
        %${KPIData},
		KPISearch => $KPIData->{Search},
		KPIRules => $KPIData->{Rules},
        ID             => $KPID,
        Mode           => 'Change',
    );
}

sub _ChangeAction {
    my ( $Self, %Param ) = @_;

    my %Errors;
    my %GetParam;
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KPIObject = $Kernel::OM->Get('Kernel::System::KPI');

    for my $Needed (qw(Name)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = Translatable('This field is required.');
        }
    }

	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $KPIID = $ParamObject->GetParam( Param => "ID" );

	if ( $GetParam{Name} ) {

       my $KPIList = $KPIObject->KPIList();

		KPI:
       foreach my $ListKPIID ( @{$KPIList} ){
			my $KPI = $Kernel::OM->Get('Kernel::System::KPI')->KPIGet(
				ID => $ListKPIID,
			);

			next KPI if $KPI->{ID} == $KPIID;

			if ( $GetParam{Name} eq $KPI->{Name} ){
				# add server error error class
				$Errors{NameServerError}        = 'ServerError';
				$Errors{NameServerErrorMessage} = Translatable('There is another KPI with the same name.');
			}
		}
    }

    for my $ConfigParam (
        qw(ReturnFormat ObjectTypeName ValidID)
        )
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );

		# uncorrectable errors
		if ( !$GetParam{$ConfigParam} ){
			return $LayoutObject->ErrorScreen(
				Message => Translatable("Need $ConfigParam"),
			);
		}
    }

	@{$GetParam{GroupIDs}} = $ParamObject->GetArray( Param => "GroupIDs" );

	$GetParam{GroupIDs} = join (',', @{$GetParam{GroupIDs}});
	$GetParam{SeverityOrder} = $ParamObject->GetParam( Param => "SeverityOrder" );
	$GetParam{TypeKPI} = $ParamObject->GetParam( Param => "TypeKPI" );

	my %Filters = $Self->_GetFilters();

	$GetParam{MinValue}                   = $ParamObject->GetParam( Param => 'MinValue' );
	$GetParam{MaxValue}                   = $ParamObject->GetParam( Param => 'MaxValue' );
    $GetParam{SLARangeMinValue}           = $ParamObject->GetParam( Param => 'SLARangeMinValue' );
	$GetParam{SLARangeMaxValue}           = $ParamObject->GetParam( Param => 'SLARangeMaxValue' );
    $GetParam{FirstResponseRangeMinValue} = $ParamObject->GetParam( Param => 'FirstResponseRangeMinValue' );
	$GetParam{FirstResponseRangeMaxValue} = $ParamObject->GetParam( Param => 'FirstResponseRangeMaxValue' );
    $GetParam{Color}                      = $ParamObject->GetParam( Param => 'Color' );
    $GetParam{Link}                       = $ParamObject->GetParam( Param => 'Link' );

	my %Rules;

	for my $Index ( 1..4 ){
		my $RuleLabel = $ParamObject->GetParam( Param => "RuleLabel$Index" );
		my $RuleColor = $ParamObject->GetParam( Param => "RuleColor$Index" );

		$Rules{"Rule$Index"} = $RuleLabel;
		$Rules{"RuleColor$Index"} = $RuleColor;
	}

    # return to change screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            ID   => $KPIID,
            Mode => 'Change',
			Search => \%Filters,
        );
    }

     # create a new field
    my $UpdateSuccess = $KPIObject->KPIUpdate(
		ID => $KPIID,
		%GetParam,
        ObjectType => "Ticket",
		Search   => \%Filters,
		Rules => \%Rules,

    );

    if ( !$UpdateSuccess ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Could not update the KPI'),
        );
    }

    return $LayoutObject->Redirect(
        OP => "Action=AdminKPI",
    );
}

sub _ShowScreen {
    my ( $Self, %Param ) = @_;

    $Param{DisplayFieldName} = 'New';

    if ( $Param{Mode} eq 'Change' ) {
        $Param{ShowWarning}      = 'ShowWarning';
        $Param{DisplayFieldName} = $Param{Name};
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # header
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    my %ReturnFormat = (
		'Excel'  => 'Excel',
		'Normal' => 'Normal',
		'Link'   => 'Link'
	);

	my $ReturnFormatStrg = $LayoutObject->BuildSelection(
        Data          => \%ReturnFormat,
        Name          => 'ReturnFormat',
        SelectedValue => $Param{ReturnFormat} || 'Normal',
        PossibleNone  => 0,
        Translation   => 0,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc',
    );
    
	# create the Validity select
    my %ValidList    = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my $ValidityStrg = $LayoutObject->BuildSelection(
        Data         => \%ValidList,
        Name         => 'ValidID',
        SelectedID   => $Param{ValidID} || 1,
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'Modernize W50pc',
    );

	my %Groups       = $Kernel::OM->Get('Kernel::System::Group')->GroupList( Valid => 1 );
	my $GroupsStrg = $LayoutObject->BuildSelection(
        Data         => \%Groups,
        Name         => 'GroupIDs',
        SelectedID   => $Param{Groups} || '',
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize W50pc',
		Multiple     => 1,
    );

	my %Search;

	if ( IsHashRefWithData($Param{KPISearch}) ){
		%Search = %{$Param{KPISearch}};
	}

	my $AttributesSelectModule = Kernel::Modules::AdminKPISearch->new(
		ObjectType => 'Ticket',
		%{$Self},
	);

	my %Attributes = $AttributesSelectModule->Run(
		Search => \%Search
	);


	my %ValidParam;

	if ( %Search ){
		foreach my $Key ( keys %Search ){
			if ( $Search{$Key} ){
				$ValidParam{$Key.'ValidClass'} = 'ValidFilter';
			}
		}        
	}

	my %SeverityOrder = (
		'Ascending' => 'Ascending',
		'Descending' => 'Descending'
	);

	my $SeverityOrderStrg = $LayoutObject->BuildSelection(
        Data          => \%SeverityOrder,
        Name          => 'SeverityOrder',
        SelectedValue => $Param{SeverityOrder} || 'Ascending',
        PossibleNone  => 0,
        Translation   => 1,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc',
    );

	my %TypeKPI = (
		'Numeric' => 'Numeric',
		'Graphic' => 'Graphic'
	);

	my $TypeKPIStrg = $LayoutObject->BuildSelection(
        Data          => \%TypeKPI,
        Name          => 'TypeKPI',
        SelectedValue => $Param{TypeKPI} || 'Graphic',
        PossibleNone  => 0,
        Translation   => 1,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc',
    );

	my %DefaultLabels = (
		1 => "Bom",
		2 => "Médio",
		3 => "Ruim",
		4 => "Muito Ruim",
	);

    my %DefaultColors = (
       	1 => "#7fb6ff",
		2 => "#fccd41",
		3 => "#fc6464",
		4 => "#e00b0b",
    );

  	for my $Index ( 1..4 ){
		$LayoutObject->Block(
			Name => 'Rule',
			Data =>{
				RuleLabel => $Param{Rules}->{"Rule$Index"} || $DefaultLabels{$Index},
				RuleColor => $Param{Rules}->{"RuleColor$Index"} || $DefaultColors{$Index},
				Index => $Index,
			}
		);
	}    

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminKPITicket',
        Data         => {
            %Param,
			%Search,
			%Attributes,
			%ValidParam,
            ReturnFormatStrg => $ReturnFormatStrg,
            ValidityStrg => $ValidityStrg,
            GroupsStrg => $GroupsStrg,
			SeverityOrder => $SeverityOrderStrg,
			TypeKPI => $TypeKPIStrg,
			MinValue => $Param{MinValue},
			MaxValue => $Param{MaxValue},
			SLARangeMinValue => $Param{SLARangeMinValue},
			SLARangeMaxValue => $Param{SLARangeMaxValue},
			FirstResponseRangeMinValue => $Param{FirstResponseRangeMinValue},
			FirstResponseRangeMaxValue => $Param{FirstResponseRangeMaxValue},
            Color => $Param{Color},
        }
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _GetFilters {
	my ( $Self, %Param ) = @_;

	my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $DynamicFieldObject  = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject       = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

	my %GetParam;

	for my $Key (
        qw(TicketNumberValid TitleValid FromValid ToValid CcValid SubjectValid BodyValid CustomerIDValid CustomerIDRawValid
        CustomerUserLoginValid CustomerUserLoginRawValid StateTypeValid AgentValid ResultFormValid
        TimeSearchTypeValid ChangeTimeSearchTypeValid CloseTimeSearchTypeValid LastChangeTimeSearchTypeValid
        EscalationTimeSearchTypeValid
        UseSubQueuesValid AttachmentNameValid
        ArticleTimeSearchTypeValid SearchInArchiveValid
        FulltextValid ShownAttributesValid
        ArticleCreateTimePointFormatValid ArticleCreateTimePointValid
        ArticleCreateTimePointStartValid
        ArticleCreateTimeStartValid ArticleCreateTimeStartDayValid ArticleCreateTimeStartMonthValid
        ArticleCreateTimeStartYearValid
        ArticleCreateTimeStopValid ArticleCreateTimeStopDayValid ArticleCreateTimeStopMonthValid
        ArticleCreateTimeStopYearValid
        TicketLastArticleInteractionValid 
        TicketLastArticleInteractionTimePointValid
        TicketLastArticleInteractionFormatValid
        TicketCreateTimePointFormatValid TicketCreateTimePointValid
        TicketCreateTimePointStartValid
        TicketCreateTimeStartValid TicketCreateTimeStartDayValid TicketCreateTimeStartMonthValid
        TicketCreateTimeStartYearValid
        TicketCreateTimeStopValid TicketCreateTimeStopDayValid TicketCreateTimeStopMonthValid
        TicketCreateTimeStopYearValid
        TicketChangeTimePointFormatValid TicketChangeTimePointValid
        TicketChangeTimePointStartValid
        TicketChangeTimeStartValid TicketChangeTimeStartDayValid TicketChangeTimeStartMonthValid
        TicketChangeTimeStartYearValid
        TicketChangeTimeStopValid TicketChangeTimeStopDayValid TicketChangeTimeStopMonthValid
        TicketChangeTimeStopYearValid
        TicketLastChangeTimePointFormatValid TicketLastChangeTimePointValid
        TicketLastChangeTimePointStartValid 
        TicketLastChangeTimeStartValid TicketLastChangeTimeStartDayValid TicketLastChangeTimeStartMonthValid
        TicketLastChangeTimeStartYearValid
        TicketLastChangeTimeStopValid TicketLastChangeTimeStopDayValid TicketLastChangeTimeStopMonthValid
        TicketLastChangeTimeStopYearValid
        TicketCloseTimePointFormatValid TicketCloseTimePointValid
        TicketCloseTimePointStartValid
        TicketCloseTimeStartValid TicketCloseTimeStartDayValid TicketCloseTimeStartMonthValid
        TicketCloseTimeStartYearValid
        TicketCloseTimeStopValid TicketCloseTimeStopDayValid TicketCloseTimeStopMonthValid
        TicketCloseTimeStopYearValid TicketCloseTimeDayValid
        TicketEscalationTimePointFormatValid TicketEscalationTimePointValid
        TicketEscalationTimePointStartValid
        TicketEscalationTimeStartValid TicketEscalationTimeStartDayValid TicketEscalationTimeStartMonthValid
        TicketEscalationTimeStartYearValid
        TicketEscalationTimeStopValid TicketEscalationTimeStopDayValid TicketEscalationTimeStopMonthValid
        TicketEscalationTimeStopYearValid
        TicketCloseTimeNewerDateValid TicketCloseTimeOlderDateValid
		SLARangeValid FirstResponseRangeValid SLAStatusValid MyQueuesValid MyTicketsValid
        )
        )
    {

		# remove the Valid string on the submitted values
		my $Name = $Key;
		$Name =~ s/Valid//;

		# get search string params (get submitted params)
        $GetParam{$Name} = $ParamObject->GetParam( Param => $Key );

        # remove white space on the start and end
        if ( $GetParam{$Name} ) {
            $GetParam{$Name} =~ s/\s+$//g;
            $GetParam{$Name} =~ s/^\s+//g;
        }
    }


	# get array params
    for my $Key (
        qw(StateIDsValid StateTypeIDsValid QueueIDsValid PriorityIDsValid OwnerIDsValid
        CreatedQueueIDsValid CreatedUserIDsValid WatchUserIDsValid ResponsibleIDsValid
        TypeIDsValid ServiceIDsValid SLAIDsValid LockIDsValid CustomerIDsMultiselectValid )
        )
    {
		# remove the Valid string on the submitted values
		my $Name = $Key;
		$Name =~ s/Valid//;

        # get search array params (get submitted params)
        my @Array = $ParamObject->GetArray( Param => $Key );
        if (@Array) {
            $GetParam{$Name} = \@Array;
        }
     }

	my $Config = $ConfigObject->Get("Ticket::Frontend::AgentTicketSearch");
	my $DynamicFieldFilter = $Config->{DynamicField};
		# get the dynamic fields for ticket object
	my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
		Valid       => 1,
		ObjectType  => [ 'Ticket', 'Article' ],
		FieldFilter => $DynamicFieldFilter || {},
	);

	# get Dynamic fields from param object
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
			
            if($DynamicFieldConfig->{FieldType} eq 'Multiselect' || $DynamicFieldConfig->{FieldType} eq 'Dropdown' || $DynamicFieldConfig->{FieldType} eq 'Checkbox' ) {
                @{$GetParam{"Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type}}} = $ParamObject->GetArray( Param => "Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type} . 'Valid' );

                if ( @{ $GetParam{"Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type}} } == 0 ) {
                    undef $GetParam{"Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type}};
                }
                
            }   
            else{
                $GetParam{"Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type}} = $ParamObject->GetParam( Param => "Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type} . 'Valid' );
                
            }

            
			if ( $Preference->{Type} eq 'TimeSlot' ){
				for my $ParentKey ( qw( Start Stop ) ){
					for my $Key ( qw( Year Month Day Hour Minute ) ){
						my $ParamName = "Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type} . $ParentKey . $Key;
						$GetParam{$ParamName} = $ParamObject->GetParam( Param => $ParamName . "Valid" );
					}
				}
			}
			elsif ( $Preference->{Type} eq 'TimePoint' ){
				for my $Key ( qw( Start Value Format ) ){
					my $ParamName = "Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type} . $Key;
					$GetParam{$ParamName} = $ParamObject->GetParam( Param => $ParamName . "Valid" );
				}
			}
		}
	}

	return %GetParam;
}

1;