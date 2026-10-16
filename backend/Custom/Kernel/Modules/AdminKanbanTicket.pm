# --
# Kernel/Modules/AdminKanbanTicket.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminKanbanTicket;

use strict;
use warnings;
use utf8;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);
use Kernel::Modules::AdminKanbanSearch;

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
    elsif ( $Self->{Subaction} eq 'Change' ) {
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
    elsif ($Self->{Subaction} eq 'QueuesLoader'){

        return $Self->_QueuesLoader(
            %Param,
        );
    }
    elsif ($Self->{Subaction} eq 'StatesLoader'){

        return $Self->_StatesLoader(
            %Param,
        );
    }
    elsif ($Self->{Subaction} eq 'PriorityLoader'){

        return $Self->_PriorityLoader(
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
	my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');

    for my $Needed (qw(Name)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = Translatable('This field is required.');
        }
    }

	if ( $GetParam{Name} ) {

       my $KanbanList = $KanbanObject->KanbanList();

       foreach my $KanbanID ( @{$KanbanList} ){
			my $Kanban = $Kernel::OM->Get('Kernel::System::Kanban')->KanbanGet(
				ID => $KanbanID,
			);

			if ( $GetParam{Name} eq $Kanban->{Name} ){
				# add server error error class
				$Errors{NameServerError}        = 'ServerError';
				$Errors{NameServerErrorMessage} = Translatable('There is another Kanban with the same name.');
			}
		}
    }

	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    for my $ConfigParam (
        qw(ValidID)
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

    @{$GetParam{ButtonsIDs}} = $ParamObject->GetArray( Param => "ButtonsIDs" );

	$GetParam{GroupIDs} = join (',', @{$GetParam{GroupIDs}});
	$GetParam{ButtonsIDs} = join (',', @{$GetParam{ButtonsIDs}});
	$GetParam{SeverityOrder} = $ParamObject->GetParam( Param => "SeverityOrder" );
	$GetParam{Ordination} = $ParamObject->GetParam( Param => "Ordination" );
	$GetParam{Limit} = $ParamObject->GetParam( Param => "LimitValue" );
	$GetParam{ManualSorting} = $ParamObject->GetParam( Param => "ManualSorting" );
	$GetParam{StartCollapsed} = $ParamObject->GetParam( Param => "StartCollapsed" );
	$GetParam{PreviewOnly} = $ParamObject->GetParam( Param => "PreviewOnly" );
	$GetParam{QueueToMove} = $ParamObject->GetParam( Param => "QueueToMove" );
	$GetParam{StateToMove} = $ParamObject->GetParam( Param => "StateToMove" );
	$GetParam{PriorityToMove} = $ParamObject->GetParam( Param => "PriorityToMove" );

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

    # create a new Kanban
    my $FieldID = $KanbanObject->KanbanAdd(
		%GetParam,
		Search   => \%Filters,
        UserID   => $Self->{UserID},	
    );

    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Could not create the new Column'),
        );
    }

    return $LayoutObject->Redirect(
        OP => "Action=AdminKanban",
    );
}

sub _Change {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $KanbanD = $ParamObject->GetParam( Param => 'ID' );

    if ( !$KanbanD ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Need ID'),
        );
    }

    # get Kanban data
    my $KanbanData = $Kernel::OM->Get('Kernel::System::Kanban')->KanbanGet(
        ID => $KanbanD,
    );


    # check for valid Kanban configuration
    if ( !IsHashRefWithData($KanbanData) ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'Could not get data for Kanban %s', $KanbanD ),
        );
    }

    my $Checked = '';
    if ( $KanbanData->{ManualSorting} eq '1' ) {
        $Checked = 'checked="checked"';
    }

    my $CheckedStartCollapsed = '';
    if ( $KanbanData->{StartCollapsed} eq '1' ) {
        $CheckedStartCollapsed = 'checked="checked"';
    }
    
    my $CheckedPreviewOnly = '';
    if ( $KanbanData->{PreviewOnly} eq '1' ) {
        $CheckedPreviewOnly = 'checked="checked"';
    }

    my $OpenBy = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "OpenBy" );

    return $Self->_ShowScreen(
        %Param,
        %${KanbanData},
		KanbanSearch   => $KanbanData->{Search},
        ID             => $KanbanD,
        Mode           => 'Change',
        Checked        => $Checked,
        CheckedStartCollapsed => $CheckedStartCollapsed,
        CheckedPreviewOnly => $CheckedPreviewOnly,
        OpenBy => $OpenBy
    );
}

sub _ChangeAction {
    my ( $Self, %Param ) = @_;

    my %Errors;
    my %GetParam;
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');

    for my $Needed (qw(Name)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = Translatable('This field is required.');
        }
    }

	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $KanbanID = $ParamObject->GetParam( Param => "ID" );

	if ( $GetParam{Name} ) {

       my $KanbanList = $KanbanObject->KanbanList();

		Kanban:
        foreach my $ListKanbanID ( @{$KanbanList} ){
			my $Kanban = $Kernel::OM->Get('Kernel::System::Kanban')->KanbanGet(
				ID => $ListKanbanID,
			);

			next Kanban if $Kanban->{ID} == $KanbanID;

			if ( $GetParam{Name} eq $Kanban->{Name} ){
				# add server error error class
				$Errors{NameServerError}        = 'ServerError';
				$Errors{NameServerErrorMessage} = Translatable('There is another Kanban with the same name.');
			}
		}
    }

    for my $ConfigParam (
        qw(ValidID)
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

	@{$GetParam{GroupIDs}}   = $ParamObject->GetArray( Param => "GroupIDs" );
	@{$GetParam{ButtonsIDs}} = $ParamObject->GetArray( Param => "ButtonsIDs" );

    $GetParam{GroupIDs}      = join (',', @{$GetParam{GroupIDs}});
    $GetParam{ButtonsIDs}    = join (',', @{$GetParam{ButtonsIDs}});
	$GetParam{SeverityOrder} = $ParamObject->GetParam( Param => "SeverityOrder" );
	$GetParam{Ordination}    = $ParamObject->GetParam( Param => "Ordination" );
	$GetParam{Limit}         = $ParamObject->GetParam( Param => "LimitValue" );
	$GetParam{ManualSorting} = $ParamObject->GetParam( Param => "ManualSorting" );
	$GetParam{StartCollapsed} = $ParamObject->GetParam( Param => "StartCollapsed" );
	$GetParam{PreviewOnly}    = $ParamObject->GetParam( Param => "PreviewOnly" );
	$GetParam{QueueToMove}    = $ParamObject->GetParam( Param => "QueueToMove" );
	$GetParam{StateToMove}    = $ParamObject->GetParam( Param => "StateToMove" );
	$GetParam{PriorityToMove} = $ParamObject->GetParam( Param => "PriorityToMove" );
	$GetParam{OpenBy}         = $ParamObject->GetParam( Param => "OpenBy" );

	my %Filters = $Self->_GetFilters();

    if ( scalar $Filters{QueueIDs} == 0 ){
        $GetParam{QueueToMove} = '';
    }

    # return to change screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            ID   => $KanbanID,
            Mode => 'Change',
			Search => \%Filters,
        );
    }

     # create a new field
    my $UpdateSuccess = $KanbanObject->KanbanUpdate(
		ID => $KanbanID,
		%GetParam,
		Search   => \%Filters,

    );

    if ( !$UpdateSuccess ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Could not update the Kanban'),
        );
    }

    if($GetParam{OpenBy}){
        my @OpenParams = split /Kanban_/, $GetParam{OpenBy};

        return $LayoutObject->Redirect(
            OP => "Action=AgentKanban;Subaction=KanbanBoard;BoardID=$OpenParams[1]",
        );
    }else{
        return $LayoutObject->Redirect(
            OP => "Action=AdminKanban",
        );
    }

   
}

sub _ShowScreen {
    my ( $Self, %Param ) = @_;

    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    $Param{DisplayFieldName} = 'New';
    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');

    if ( $Param{Mode} eq 'Change' ) {
        $Param{ShowWarning}      = 'ShowWarning';
        $Param{DisplayFieldName} = $Param{Name};
    }

    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KanbanObject   = $Kernel::OM->Get('Kernel::System::Kanban');
	my $KanbanID       = $ParamObject->GetParam( Param => "ID" );
    my $StateObject    = $Kernel::OM->Get('Kernel::System::State');
    my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');

    # header
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

	# create the Validity select
    my %ValidList    = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my $ValidityStrg = $LayoutObject->BuildSelection(
        Data         => \%ValidList,
        Name         => 'ValidID',
        SelectedID   => $Param{ValidID} || 1,
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'Modernize W50pc Validate_Required',
    );

	my %Groups       = $Kernel::OM->Get('Kernel::System::Group')->GroupList( Valid => 1 );
	my $GroupsStrg = $LayoutObject->BuildSelection(
        Data         => \%Groups,
        Name         => 'GroupIDs',
        SelectedID   => $Param{Groups} || '',
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'Modernize W50pc Validate_Required',
		Multiple     => 1,
    );

    my %ButtonsCard = (
        Share               => $LayoutObject->{LanguageObject}->Translate('Share'),
        Lock                => $LayoutObject->{LanguageObject}->Translate('Lock'),
        IncreasePriority    => $LayoutObject->{LanguageObject}->Translate('Increase Priority'),
        Details             => $LayoutObject->{LanguageObject}->Translate('Details'),
        DecreasePriority    => $LayoutObject->{LanguageObject}->Translate('Decrease Priority'),
        ChangeQueues        => $LayoutObject->{LanguageObject}->Translate('Change Queues'),
        AgentTicketNote     => $LayoutObject->{LanguageObject}->Translate('Add note'),
        AgentTicketFreeText => $LayoutObject->{LanguageObject}->Translate('Classify'),
        AgentTicketClosed   => $LayoutObject->{LanguageObject}->Translate('Close ticket'),
        ReplyAll            => $LayoutObject->{LanguageObject}->Translate('Reply'),
        AddTag              => $LayoutObject->{LanguageObject}->Translate('Add Tag'),
        Watch               => $LayoutObject->{LanguageObject}->Translate('Watch'),
    );

    my $ButtonsStrg = $LayoutObject->BuildSelection(
        Data         => \%ButtonsCard,
        Name         => 'ButtonsIDs',
        SelectedID   => $Param{ButtonsIDs} || ['Share','Lock', 'IncreasePriority', 'Details', 'DecreasePriority', 'ChangeQueues', 'AgentTicketNote', 'AgentTicketFreeText', 'AgentTicketClosed'],
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'Modernize W50pc',
		Multiple     => 1,
    );

	my %Search;

	if ( IsHashRefWithData($Param{KanbanSearch}) ){
		%Search = %{$Param{KanbanSearch}};
	}

	my $AttributesSelectModule = Kernel::Modules::AdminKanbanSearch->new(
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
		'Ascending'  => 'Ascending',
		'Descending' => 'Descending'
	);

	my $SeverityOrderStrg = $LayoutObject->BuildSelection(
        Data          => \%SeverityOrder,
        Name          => 'SeverityOrder',
        SelectedValue => $Param{SeverityOrder} || 'Ascending',
        PossibleNone  => 0,
        Translation   => 1,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc Validate_Required',
    );

    my $DynamicFieldToOrdination = $ConfigObject->Get('Kanban::Core::DynmaicFieldsToOrdination');

    my %Ordination = (
		'Priority'     => 'Priority',
		'Age'          => 'Age',
        'Owner'        => 'Owner',
        'Solution SLA' => 'Solution SLA' 
	);

    for my $DFName (@{$DynamicFieldToOrdination}){
        $Ordination{$DFName} = "$DFName";
    }

	my $OrdinationStrg = $LayoutObject->BuildSelection(
        Data          => \%Ordination,
        Name          => 'Ordination',
        SelectedValue => $Param{Ordination} || 'Priority',
        PossibleNone  => 0,
        Translation   => 1,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc Validate_Required',
    );

    my %QueueToMove = ();
    if($KanbanID){
        if($Param{KanbanSearch}->{QueueIDs}){
            for my $QueueID (@{$Param{KanbanSearch}->{QueueIDs}}){
             
                my $QueueName = $QueueObject->QueueLookup( QueueID => $QueueID );
                $QueueToMove{$QueueID} = $QueueName;

            }
        }
    }

    my $QueueToMoveStrg = $LayoutObject->BuildSelection(
        Data          => \%QueueToMove,
        Name          => 'QueueToMove',
        SelectedID => $Param{QueueToMove} || '',
        PossibleNone  => 0,
        Multiple      => 0,
        Translation   => 1,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc',
    );

    my %StateToMove = ();
    if($KanbanID){
        if($Param{KanbanSearch}->{StateIDs}){
            for my $StateID (@{$Param{KanbanSearch}->{StateIDs}}){
                my $StateName = $StateObject->StateLookup( StateID => $StateID );
                $StateToMove{$StateID} = $StateName;
            }
        }
    }

    my $StateToMoveStrg = $LayoutObject->BuildSelection(
        Data          => \%StateToMove,
        Name          => 'StateToMove',
        SelectedID    => $Param{StateToMove} || '',
        PossibleNone  => 0,
        Multiple      => 0,
        Translation   => 1,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc',
    );

    my %PriorityToMove = ();
    if($KanbanID){
        if($Param{KanbanSearch}->{PriorityIDs}){
            for my $PriorityID (@{$Param{KanbanSearch}->{PriorityIDs}}){
             
                my $PriorityName = $PriorityObject->PriorityLookup( PriorityID => $PriorityID );
                $PriorityToMove{$PriorityID} = $PriorityName;

            }
        }
    }

    my $PriorityToMoveStrg = $LayoutObject->BuildSelection(
        Data          => \%PriorityToMove,
        Name          => 'PriorityToMove',
        SelectedID    => $Param{PriorityToMove} || '',
        PossibleNone  => 0,
        Multiple      => 0,
        Translation   => 1,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc',
    );

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminKanbanTicket',
        Data         => {
            %Param,
			%Search,
			%Attributes,
			%ValidParam,
            ValidityStrg   => $ValidityStrg,
            GroupsStrg     => $GroupsStrg,
			Ordination     => $OrdinationStrg,
			SeverityOrder  => $SeverityOrderStrg,
			Limit          => $Param{Limit},
			ManualSorting  => $Param{ManualSorting},
			StartCollapsed => $Param{StartCollapsed},
			PreviewOnly    => $Param{PreviewOnly},
			QueueToMove    => $QueueToMoveStrg,
			StateToMove    => $StateToMoveStrg,
			PriorityToMove => $PriorityToMoveStrg,
			ButtonsStrg    => $ButtonsStrg,
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
        TicketCloseTimeStopYearValid
        TicketEscalationTimePointFormatValid TicketEscalationTimePointValid
        TicketEscalationTimePointStartValid
        TicketEscalationTimeStartValid TicketEscalationTimeStartDayValid TicketEscalationTimeStartMonthValid
        TicketEscalationTimeStartYearValid
        TicketEscalationTimeStopValid TicketEscalationTimeStopDayValid TicketEscalationTimeStopMonthValid
        TicketEscalationTimeStopYearValid
        TicketCloseTimeNewerDateValid TicketCloseTimeOlderDateValid
		SLARangeValid FirstResponseRangeValid
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
        TypeIDsValid ServiceIDsValid SLAIDsValid LockIDsValid)
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
			# $GetParam{"Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type}} = $ParamObject->GetParam( Param => "Search_DynamicField_$DynamicFieldConfig->{Name}" . $Preference->{Type} . 'Valid' );

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

sub _QueuesLoader {
    my ( $Self, %Param ) = @_;

    my %GetParam;
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');
	my $QueuesIDs    = $ParamObject->GetParam( Param => "QueuesIDs" );
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $QueueObject  = $Kernel::OM->Get('Kernel::System::Queue');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $QueuesChange = $JSONObject->Decode(
        Data => $QueuesIDs,
    );

    my %QueueToMove = ();
	my $SelectedValue;
    for my $QueueID (@{$QueuesChange}){
       	$SelectedValue = $QueueID;
        my $QueueName = $QueueObject->QueueLookup( QueueID => $QueueID );
        $QueueToMove{$QueueID} = $QueueName;

    }

    my $JSONString = $JSONObject->Encode(
        Data     => \%QueueToMove,
        SortKeys => 1
    );

    # build JSON output
   my $JSON = $LayoutObject->JSONEncode(
        Data => {
            JSONString => $JSONString,
            SelectedValue => $SelectedValue || '',
        },
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
   
}

sub _StatesLoader {
    my ( $Self, %Param ) = @_;

    my %GetParam;
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KanbanObject = $Kernel::OM->Get('Kernel::System::Kanban');
	my $StatesIDs    = $ParamObject->GetParam( Param => "StateIDs" );
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $StateObject  = $Kernel::OM->Get('Kernel::System::State');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $StatesChange = $JSONObject->Decode(
        Data => $StatesIDs,
    );

    my %StateToMove = ();
   	my $SelectedValue;
    for my $StateID (@{$StatesChange}){
        $SelectedValue = $StateID;
        my $StateName = $StateObject->StateLookup( StateID => $StateID );
        $StateToMove{$StateID} =  $LayoutObject->{LanguageObject}->Translate($StateName);
    }
   
    my $JSONString = $JSONObject->Encode(
        Data     => {
            %StateToMove,
        },
        SortKeys => 1
    );

    # build JSON output
    my $JSON = $LayoutObject->JSONEncode(
        Data => {
            JSONString => $JSONString,
            SelectedValue => $SelectedValue || '',
        },
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
   
}

sub _PriorityLoader {
    my ( $Self, %Param ) = @_;

    my %GetParam;
    my $ParamObject    = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KanbanObject   = $Kernel::OM->Get('Kernel::System::Kanban');
	my $PriorityIDs    = $ParamObject->GetParam( Param => "PriorityIDs" );
    my $JSONObject     = $Kernel::OM->Get('Kernel::System::JSON');
    my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $PrioritysChange = $JSONObject->Decode(
        Data => $PriorityIDs,
    );

    my %PriorityToMove = ();
   	my $SelectedValue;
    for my $PriorityID (@{$PrioritysChange}){
        $SelectedValue = $PriorityID;
        my $PriorityName = $PriorityObject->PriorityLookup( PriorityID => $PriorityID );
        $PriorityToMove{$PriorityID} =  $LayoutObject->{LanguageObject}->Translate($PriorityName);
    }
   
    my $JSONString = $JSONObject->Encode(
        Data     => {
            %PriorityToMove,
        },
        SortKeys => 1
    );

    # build JSON output
    my $JSON = $LayoutObject->JSONEncode(
        Data => {
            JSONString => $JSONString,
            SelectedValue => $SelectedValue || '',
        },
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
   
}

1;
