# --
# Kernel/Modules/AdminKPISQLQuery.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminKPISQLQuery;

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
    if( $Self->{Subaction} eq 'QueryExecute' ){
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_QueryExecuteAction(
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

    $GetParam{Link} = $ParamObject->GetParam( Param => 'Link' );


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
        ObjectType => "SQL Query",
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

    $GetParam{Link} = $ParamObject->GetParam( Param => 'Link' );

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
	$GetParam{SQL} = $ParamObject->GetParam( Param => 'SQL' );

    # check if SQL query is "SELECT" one
    if ( uc( $GetParam{SQL} ) !~ m{ \A \s* (?:SELECT|SHOW|DESC) }smx ) {
        $Errors{SQLInvalid} = 'ServerError';
        $Errors{ErrorType}  = 'SQLIsNotSelect';
        return $LayoutObject->ErrorScreen(
            Message => Translatable("Only queries are released"),
        );
    }

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
        ObjectType => "SQL Query",

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

    # header
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    my %ReturnFormat = (
		'Excel' => 'Excel',
		'Link' => 'Link',
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


	my %ValidParam;

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

  	for my $Index ( 1..4 ){
		$LayoutObject->Block(
			Name => 'Rule',
			Data =>{
				RuleLabel => $Param{Rules}->{"Rule$Index"} || $DefaultLabels{$Index},
				Index => $Index,
			}
		);
	}

     # secure mode message (don't allow this action until secure mode is enabled)
    if ( !$ConfigObject->Get('SecureMode') ) {
        return $LayoutObject->SecureMode();
    }

    my $ResultFormatStrg = $LayoutObject->BuildSelection(
        Name  => 'ResultFormat',
        Data  => [ 'HTML', 'CSV', 'Excel' ],
        Class => 'Modernize',
    );

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminKPISQLQuery',
        Data         => {
            %Param,
			%ValidParam,
            ReturnFormatStrg => $ReturnFormatStrg,
            ValidityStrg => $ValidityStrg,
            GroupsStrg => $GroupsStrg,
			ResultFormatStrg => $ResultFormatStrg,
        }
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _QueryExecuteAction {
    my ( $Self, %Param ) = @_;

	my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my %Errors;

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    # get params
    for my $Parameter (qw(SQL)) {
        $Param{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
    }
    
    $Param{ResultFormat} = 'HTML';
    # check needed data
    if ( !$Param{SQL} ) {
        $Errors{SQLInvalid} = 'ServerError';
        $Errors{ErrorType}  = 'FieldRequired';
    }

    # check if SQL query is "SELECT" one
    if ( uc( $Param{SQL} ) !~ m{ \A \s* (?:SELECT|SHOW|DESC) }smx ) {
        $Errors{SQLInvalid} = 'ServerError';
        $Errors{ErrorType}  = 'SQLIsNotSelect';
    }

    # if no errors occurred
    if ( !%Errors ) {        
        my $DBObject = $Kernel::OM->Get('Kernel::System::DB');

        # fetch database and add row blocks
        if (
            $DBObject->Prepare(
                SQL   => $Param{SQL}
            )
            )
        {

            my @Data;
            my $MatchesFound;

            # add result block
            $LayoutObject->Block(
                Name => 'Result',
                Data => \%Param,
            );

            my @Head = $DBObject->GetColumnNames();
            for my $Column (@Head) {
                $LayoutObject->Block(
                    Name => 'ColumnHead',
                    Data => {
                        ColumnName => $Column,
                    },
                );
            }

            # if there are any matching rows, they are shown
            ROW:
            while ( my @Row = $DBObject->FetchrowArray( RowNames => 1 ) ) {

                $MatchesFound++;

                $LayoutObject->Block(
                    Name => 'Row',
                );

                # get html data
                my $Row = '';
                for my $Item (@Row) {
                    if ( !defined $Item ) {
                        $Item = 'NULL';
                    }

                    $LayoutObject->Block(
                        Name => 'Cell',
                        Data => {
                            Content => $Item,
                        },
                    );
                }
            }

            # add matches found if min. one result item
            if ( $MatchesFound >= 1 ) {
                $Param{MatchesFound} = $MatchesFound;
            }

            # add result filter if more than one result item
            if ( $MatchesFound > 1 ) {
                $LayoutObject->Block(
                    Name => 'ResultFilter',
                );
            }

            # otherwise a no matches found msg is displayed
            if ( !$MatchesFound ) {
                if ( uc( $Param{SQL} ) !~ m{ \A \s* (?:SELECT|SHOW|DESC) }smx ) {
                    $LayoutObject->Block(
                        Name => 'NoSelectResult',
                        Data => {
                            Colspan => scalar @Head,
                        },
                    );
                }
                else {
                    $LayoutObject->Block(
                        Name => 'NoMatches',
                        Data => {
                            Colspan => scalar @Head,
                        },
                    );
                }
            }           
        }
        else {
            $Errors{ErrorMessage} = $Kernel::OM->Get('Kernel::System::Log')->GetLogEntry(
                Type => 'Error',
                What => 'Message',
            );
            $Errors{ErrorType}  = ( $Errors{ErrorMessage} =~ /bind/i ) ? 'BindParam' : 'SQLSyntax';
            $Errors{SQLInvalid} = 'ServerError';
        }

        # add server error message block
        $LayoutObject->Block( Name => $Errors{ErrorType} . 'ServerError' );

        # generate html output
        my $Output = $LayoutObject->Output(
            TemplateFile => 'AdminKPISQLQueryBody',
            Data         => {
                %Param,
                %Errors,
            },
        );

        my $Error = '0';
        if(! %Errors){
            $Error = '1';
        }

        my $JSON = $LayoutObject->JSONEncode(
            Data     =>  {
                Template => $Output,
                Error => $Error
            }
        );   

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON || '',
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # add server error message block
    $LayoutObject->Block( Name => $Errors{ErrorType} . 'ServerError' );

    # generate html output
    my $Output = $LayoutObject->Output(
        TemplateFile => 'AdminKPISQLQueryBody',
        Data         => {
            %Param,
            %Errors,
        },
    );

    my $Error = '0';
    if(! %Errors){
        $Error = '1';
    }

    my $JSON = $LayoutObject->JSONEncode(
        Data     =>  {
            Template => $Output,
            Error => $Error
        }
    );   

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );
      
}

1;