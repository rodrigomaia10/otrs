# --
# Kernel/Modules/AdminKPISurvey.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminKPISurvey;

use strict;
use warnings;

use utf8;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

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
    if( $Self->{Subaction} eq 'AjaxToUpdateQuestion' ){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_AjaxToUpdateQuestion(
            %Param,
        );
    }
    if( $Self->{Subaction} eq 'AjaxToUpdateAnswer' ){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_AjaxToUpdateAnswer(
            %Param,
        );
    }


    return $LayoutObject->ErrorScreen(
        Message => Translatable('Undefined subaction.'),
    );
}

sub _AjaxToUpdateAnswer {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');
    my $SurveyObject = $Kernel::OM->Get('Kernel::System::Survey');

    my $JSON =  '{}';
    my %GetParam;

    $GetParam{QuestionID} = $ParamObject->GetParam( Param => 'QuestionID' );

    my %AnswerList;
    my @ListAnswer;

    if($GetParam{QuestionID}){
        # get all questions of the survey
        @ListAnswer = $SurveyObject->AnswerList(
            QuestionID => $GetParam{QuestionID}
        );
    }

    for my $Answer (@ListAnswer) {
        $AnswerList{$Answer->{AnswerID}} = $Answer->{Answer};
    }

    my $JSONString = $JSONObject->Encode(
        Data     => \%AnswerList,
        SortKeys => 1
    );

    $JSON = $LayoutObject->JSONEncode(
        Data => {
            JSONString => $JSONString,
        },
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );

}

sub _AjaxToUpdateQuestion {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');
    my $SurveyObject = $Kernel::OM->Get('Kernel::System::Survey');

    my $JSON =  '{}';
    my %GetParam;

    $GetParam{SurveyID} = $ParamObject->GetParam( Param => 'SurveyID' ); 

    my %QuestionList;
    my @QuestionList;

    if($GetParam{SurveyID}){
        # get all questions of the survey
        @QuestionList = $SurveyObject->QuestionList(
            SurveyID => $GetParam{SurveyID},
        );
    }   

    for my $Question (@QuestionList) {

        if($Question->{Type} eq 'Radio'){
            $QuestionList{$Question->{QuestionID}} = $Question->{Question};
        }
    }

    my $JSONString = $JSONObject->Encode(
        Data     => \%QuestionList,
        SortKeys => 1
    );

    $JSON = $LayoutObject->JSONEncode(
        Data => {
            JSONString => $JSONString,
        },
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
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

    $GetParam{SurveyID}   = $ParamObject->GetParam( Param => 'SurveyID' );
    $GetParam{QuestionID} = $ParamObject->GetParam( Param => 'QuestionID' );
    $GetParam{AnswerID}   = $ParamObject->GetParam( Param => 'AnswerID' );
    $GetParam{Metric}     = $ParamObject->GetParam( Param => 'Metric' );

    # get VoteTime params
    for my $Attribute (
        qw(
            VoteTimeSearchType VoteTimeStartDay VoteTimeStartMonth VoteTimeStartYear
            VoteTimeStopDay VoteTimeStopYear VoteTimeStopMonth 
        )
    ){
        $GetParam{$Attribute} = $ParamObject->GetParam( Param => $Attribute );
    }

    my $VoteTimeStartMonth = sprintf("%02d", $GetParam{VoteTimeStartMonth});
    my $VoteTimeStopMonth  = sprintf("%02d", $GetParam{VoteTimeStopMonth});
    my $VoteTimeStartDay   = sprintf("%02d", $GetParam{VoteTimeStartDay});
    my $VoteTimeStopDay    = sprintf("%02d", $GetParam{VoteTimeStopDay});

    if($GetParam{VoteTimeSearchType}){
        $GetParam{StartDateVoteTime} = "$GetParam{VoteTimeStartYear}-$VoteTimeStartMonth-$VoteTimeStartDay 00:00:00";
        $GetParam{StopDateVoteTime} = "$GetParam{VoteTimeStopYear}-$VoteTimeStopMonth-$VoteTimeStopDay 23:59:59";
    }


    # get CreateTime params
    for my $Attribute (
        qw(
            CreateTimeSearchType CreateTimeStartDay CreateTimeStartMonth CreateTimeStartYear
            CreateTimeStopDay CreateTimeStopYear CreateTimeStopMonth 
        )
    ){
        $GetParam{$Attribute} = $ParamObject->GetParam( Param => $Attribute );
    }

    my $CreateTimeStartMonth = sprintf("%02d", $GetParam{CreateTimeStartMonth});
    my $CreateTimeStopMonth  = sprintf("%02d", $GetParam{CreateTimeStopMonth});
    my $CreateTimeStartDay   = sprintf("%02d", $GetParam{CreateTimeStartDay});
    my $CreateTimeStopDay    = sprintf("%02d", $GetParam{CreateTimeStopDay});

    if($GetParam{CreateTimeSearchType}){
        $GetParam{StartDateCreateTime} = "$GetParam{CreateTimeStartYear}-$CreateTimeStartMonth-$CreateTimeStartDay 00:00:00";
        $GetParam{StopDateCreateTime} = "$GetParam{CreateTimeStopYear}-$CreateTimeStopMonth-$CreateTimeStopDay 23:59:59";
    }

    # get SendTime params
    for my $Attribute (
        qw(
            SendTimeSearchType SendTimeStartDay SendTimeStartMonth SendTimeStartYear
            SendTimeStopDay SendTimeStopYear SendTimeStopMonth 
        )
    ){
        $GetParam{$Attribute} = $ParamObject->GetParam( Param => $Attribute );
    }

    my $SendTimeStartMonth = sprintf("%02d", $GetParam{SendTimeStartMonth});
    my $SendTimeStopMonth  = sprintf("%02d", $GetParam{SendTimeStopMonth});
    my $SendTimeStartDay   = sprintf("%02d", $GetParam{SendTimeStartDay});
    my $SendTimeStopDay    = sprintf("%02d", $GetParam{SendTimeStopDay});

    if($GetParam{SendTimeSearchType}){
        $GetParam{StartDateSendTime} = "$GetParam{SendTimeStartYear}-$SendTimeStartMonth-$SendTimeStartDay 00:00:00";
        $GetParam{StopDateSendTime} = "$GetParam{SendTimeStopYear}-$SendTimeStopMonth-$SendTimeStopDay 23:59:59";
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
    $GetParam{SQL} = $ParamObject->GetParam( Param => 'SQL' );
    # return to add screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            Mode => 'Add',
        );
    }

    # create a new KPI
    my $FieldID = $KPIObject->KPIAdd(
		%GetParam,
        ObjectType => "Survey",
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

    $GetParam{SurveyID}   = $ParamObject->GetParam( Param => 'SurveyID' );
    $GetParam{QuestionID} = $ParamObject->GetParam( Param => 'QuestionID' );
    $GetParam{AnswerID}   = $ParamObject->GetParam( Param => 'AnswerID' );
    $GetParam{Metric}     = $ParamObject->GetParam( Param => 'Metric' );

    # get VoteTime params
    for my $Attribute (
        qw(
            VoteTimeSearchType VoteTimeStartDay VoteTimeStartMonth VoteTimeStartYear
            VoteTimeStopDay VoteTimeStopYear VoteTimeStopMonth 
        )
    ){
        $GetParam{$Attribute} = $ParamObject->GetParam( Param => $Attribute );
    }

    my $VoteTimeStartMonth = sprintf("%02d", $GetParam{VoteTimeStartMonth});
    my $VoteTimeStopMonth  = sprintf("%02d", $GetParam{VoteTimeStopMonth});
    my $VoteTimeStartDay   = sprintf("%02d", $GetParam{VoteTimeStartDay});
    my $VoteTimeStopDay    = sprintf("%02d", $GetParam{VoteTimeStopDay});

    if($GetParam{VoteTimeSearchType}){
        $GetParam{StartDateVoteTime} = "$GetParam{VoteTimeStartYear}-$VoteTimeStartMonth-$VoteTimeStartDay 00:00:00";
        $GetParam{StopDateVoteTime} = "$GetParam{VoteTimeStopYear}-$VoteTimeStopMonth-$VoteTimeStopDay 23:59:59";
    }

    # get CreateTime params
    for my $Attribute (
        qw(
            CreateTimeSearchType CreateTimeStartDay CreateTimeStartMonth CreateTimeStartYear
            CreateTimeStopDay CreateTimeStopYear CreateTimeStopMonth 
        )
    ){
        $GetParam{$Attribute} = $ParamObject->GetParam( Param => $Attribute );
    }

    my $CreateTimeStartMonth = sprintf("%02d", $GetParam{CreateTimeStartMonth});
    my $CreateTimeStopMonth  = sprintf("%02d", $GetParam{CreateTimeStopMonth});
    my $CreateTimeStartDay   = sprintf("%02d", $GetParam{CreateTimeStartDay});
    my $CreateTimeStopDay    = sprintf("%02d", $GetParam{CreateTimeStopDay});

    if($GetParam{CreateTimeSearchType}){
        $GetParam{StartDateCreateTime} = "$GetParam{CreateTimeStartYear}-$CreateTimeStartMonth-$CreateTimeStartDay 00:00:00";
        $GetParam{StopDateCreateTime} = "$GetParam{CreateTimeStopYear}-$CreateTimeStopMonth-$CreateTimeStopDay 23:59:59";
    }

    # get SendTime params
    for my $Attribute (
        qw(
            SendTimeSearchType SendTimeStartDay SendTimeStartMonth SendTimeStartYear
            SendTimeStopDay SendTimeStopYear SendTimeStopMonth 
        )
    ){
        $GetParam{$Attribute} = $ParamObject->GetParam( Param => $Attribute );
    }

    my $SendTimeStartMonth = sprintf("%02d", $GetParam{SendTimeStartMonth});
    my $SendTimeStopMonth  = sprintf("%02d", $GetParam{SendTimeStopMonth});
    my $SendTimeStartDay   = sprintf("%02d", $GetParam{SendTimeStartDay});
    my $SendTimeStopDay    = sprintf("%02d", $GetParam{SendTimeStopDay});

    if($GetParam{SendTimeSearchType}){
        $GetParam{StartDateSendTime} = "$GetParam{SendTimeStartYear}-$SendTimeStartMonth-$SendTimeStartDay 00:00:00";
        $GetParam{StopDateSendTime} = "$GetParam{SendTimeStopYear}-$SendTimeStopMonth-$SendTimeStopDay 23:59:59";
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

    # return to change screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            ID   => $KPIID,
            Mode => 'Change',
        );
    }

     # create a new field
    my $UpdateSuccess = $KPIObject->KPIUpdate(
		ID => $KPIID,
		%GetParam,
        ObjectType => "Survey",

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
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    $Param{DisplayFieldName} = 'New';

    if ( $Param{Mode} eq 'Change' ) {
        $Param{ShowWarning}      = 'ShowWarning';
        $Param{DisplayFieldName} = $Param{Name};
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $SurveyObject = $Kernel::OM->Get('Kernel::System::Survey');

    # header
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    my %ReturnFormat = (
		'Excel' => 'Excel',
		'Normal' => 'Normal',
	);

	my $ReturnFormatStrg = $LayoutObject->BuildSelection(
        Data          => \%ReturnFormat,
        Name          => 'ReturnFormat',
        SelectedValue => $Param{ReturnFormat} || 'Excel',
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

    # secure mode message (don't allow this action until secure mode is enabled)
    if ( !$ConfigObject->Get('SecureMode') ) {
        return $LayoutObject->SecureMode();
    }

    my %SurveyList = $SurveyObject->SurveyList();

    my $SurveyStrg = $LayoutObject->BuildSelection(
        Data         => \%SurveyList,
        Name         => 'SurveyID',
        SelectedID   => $Param{SurveyID} || '',
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize W50pc',
    );

    my %QuestionList;
    my @QuestionList;

    if($Param{SurveyID}){
        # get all questions of the survey
        @QuestionList = $SurveyObject->QuestionList(
            SurveyID => $Param{SurveyID},
        );
    }   

    for my $Question (@QuestionList) {
        if($Question->{Type} eq 'Radio'){
            $QuestionList{$Question->{QuestionID}} = $Question->{Question};
        }
    }
    
    my $QuestionStrg = $LayoutObject->BuildSelection(
        Data         => \%QuestionList,
        Name         => 'QuestionID',
        SelectedID   => $Param{QuestionID} || '',
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize W50pc',
    );

    my %AnswerList;
    my @ListAnswer;

    if($Param{QuestionID}){
        # get all questions of the survey
        @ListAnswer = $SurveyObject->AnswerList(
            QuestionID => $Param{QuestionID}
        );
    }

    for my $Answer (@ListAnswer) {
        $AnswerList{$Answer->{AnswerID}} = $Answer->{Answer};
    }
    
    my $AnswerStrg = $LayoutObject->BuildSelection(
        Data         => \%AnswerList,
        Name         => 'AnswerID',
        SelectedID   => $Param{AnswerID} || '',
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize W50pc',
        Multiple     => 0,
    );


    my %Metric = (
		'Percentage' => 'Percentage',
	);

	my $MetricStrg = $LayoutObject->BuildSelection(
        Data          => \%Metric,
        Name          => 'Metric',
        SelectedValue => $Param{Metric} || 'Percentage',
        PossibleNone  => 0,
        Translation   => 1,
        Sort          => 'AlphaNumericKey',
        Class         => 'Modernize W50pc',
    );

    # start data string
    my ($StartDateYear, $StartDateMonth, $StartDay) = split /-/, $Param{StartDateVoteTime};
    my ($StartDateDay) = split / /, $StartDay;

    $Param{'VoteTimeStart'} = $LayoutObject->BuildDateSelection(  
        Prefix   => 'VoteTimeStart',
        Format   => 'DateInputFormat',
        Validate => 1,
		ValidateDateNotInFuture => 0,
        VoteTimeStartYear   => $StartDateYear,
        VoteTimeStartMonth  => $StartDateMonth,
        VoteTimeStartDay    => $StartDateDay
    );

    # stop data string
    my ($EndDateYear, $EndDateMonth, $EndDay) = split /-/, $Param{StopDateVoteTime};
    my ($EndDateDay) = split / /, $EndDay;

    $Param{'VoteTimeStop'} = $LayoutObject->BuildDateSelection(        
        Prefix   => 'VoteTimeStop',
        Format   => 'DateInputFormat',
        Validate => 1,
		ValidateDateNotInFuture => 0,
        VoteTimeStopYear      => $EndDateYear,
        VoteTimeStopMonth     => $EndDateMonth,
        VoteTimeStopDay       => $EndDateDay,
    );

    # start data string
    my ($StartDateYear, $StartDateMonth, $StartDay) = split /-/, $Param{StartDateCreateTime};
    my ($StartDateDay) = split / /, $StartDay;

    $Param{'CreateTimeStart'} = $LayoutObject->BuildDateSelection(    
        Prefix   => 'CreateTimeStart',
        Format   => 'DateInputFormat',
        Validate => 1,
		ValidateDateNotInFuture => 0,
        CreateTimeStartYear   => $StartDateYear,
        CreateTimeStartMonth  => $StartDateMonth,
        CreateTimeStartDay    => $StartDateDay
    );

    # stop data string
    my ($EndDateYear, $EndDateMonth, $EndDay) = split /-/, $Param{StopDateCreateTime};
    my ($EndDateDay) = split / /, $EndDay;

    $Param{'CreateTimeStop'} = $LayoutObject->BuildDateSelection(        
        Prefix   => 'CreateTimeStop',
        Format   => 'DateInputFormat',
        Validate => 1,
		ValidateDateNotInFuture => 0,
        CreateTimeStopYear      => $EndDateYear,
        CreateTimeStopMonth     => $EndDateMonth,
        CreateTimeStopDay       => $EndDateDay,
    );

    # start data string
    my ($StartDateYear, $StartDateMonth, $StartDay) = split /-/, $Param{StartDateSendTime};
    my ($StartDateDay) = split / /, $StartDay;

    $Param{'SendTimeStart'} = $LayoutObject->BuildDateSelection(    
        Prefix   => 'SendTimeStart',
        Format   => 'DateInputFormat',
        Validate => 1,
		ValidateDateNotInFuture => 0,
        SendTimeStartYear   => $StartDateYear,
        SendTimeStartMonth  => $StartDateMonth,
        SendTimeStartDay    => $StartDateDay
    );

    # stop data string
    my ($EndDateYear, $EndDateMonth, $EndDay) = split /-/, $Param{StopDateSendTime};
    my ($EndDateDay) = split / /, $EndDay;


    $Param{'SendTimeStop'} = $LayoutObject->BuildDateSelection(        
        Prefix   => 'SendTimeStop',
        Format   => 'DateInputFormat',
        Validate => 1,
		ValidateDateNotInFuture => 0,
        SendTimeStopYear      => $EndDateYear,
        SendTimeStopMonth     => $EndDateMonth,
        SendTimeStopDay       => $EndDateDay,
    );

    my $VoteTimeSearchType = '';

    # To check the checkBox of VoteTime Date
    if($Param{VoteTimeSearchType}){
        $VoteTimeSearchType = 'checked';
    }

    my $CreateTimeSearchType = '';

    # To check the checkBox of CreateTime Date
    if($Param{CreateTimeSearchType}){
        $CreateTimeSearchType = 'checked';
    }

    my $SendTimeSearchType = '';

    # To check the checkBox of SendTime Date
    if($Param{SendTimeSearchType}){
        $SendTimeSearchType = 'checked';
    }

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminKPISurvey',
        Data         => {
            %Param,
            ReturnFormatStrg => $ReturnFormatStrg,
            ValidityStrg => $ValidityStrg,
            GroupsStrg => $GroupsStrg,
            SurveyStrg => $SurveyStrg,
            QuestionStrg => $QuestionStrg,
            MetricStrg => $MetricStrg,
            AnswerStrg => $AnswerStrg,
            VoteTimeSearchType => $VoteTimeSearchType,
            CreateTimeSearchType => $CreateTimeSearchType,
            SendTimeSearchType => $SendTimeSearchType,
        }
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}

1;