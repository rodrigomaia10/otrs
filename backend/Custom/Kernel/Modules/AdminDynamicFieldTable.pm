# --
# Custom/Kernel/Modules/AdminDynamicFieldTable.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * dparavani@serviceup.com.br
# * ykanegae@serviceup.com.br
# * nfreitas@serviceup.com.br
# --

package Kernel::Modules::AdminDynamicFieldTable;

use strict;
use warnings;

use utf8;
use Encode;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    # create possible fields in the table
    $Self->{PossibleData} = {
        text      => 'Text',
        date      => 'Date',
        maskMoney => 'Monetary',
        select    => 'List',
        mask      => 'Text (Mask)',
        number    => 'Numeric',
        textarea  => 'Textarea',
        'datetime-local' => 'Date Time',
        hidden    => 'Hidden',
        computed  => 'Computed',
    };

    $Self->{EditableBy} = {
        everyone    => 'All',
        agent       => 'Agent',
        customer    => 'Customer'
    };

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

    if ( $Self->{Subaction} eq 'NewColumnAJAX' ) {
        return $Self->_AjaxNewColumn(
            %Param,
        );
    }

    elsif ( $Self->{Subaction} eq 'NewMaskAjax' ) {
        return $Self->_NewMaskAjax(
            %Param,
        );
    }

    elsif ( $Self->{Subaction} eq 'OperationColumns' ) {
        return $Self->_OperationColumn(
            %Param,
        );
    }

    return $LayoutObject->ErrorScreen(
        Message => "Undefined subaction.",
    );
}

sub _Add {
    my ( $Self, %Param ) = @_;

    my %GetParam;
    for my $Needed (qw(ObjectType FieldType FieldOrder)) {
        $GetParam{$Needed} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Needed );
        if ( !$Needed ) {
            return $Kernel::OM->Get('Kernel::Output::HTML::Layout')->ErrorScreen(
                Message => "Need $Needed",
            );
        }
    }

    # get the object type and field type display name
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $ObjectTypeName = $ConfigObject->Get('DynamicFields::ObjectType')->{ $GetParam{ObjectType} }->{DisplayName} || '';
    my $FieldTypeName  = $ConfigObject->Get('DynamicFields::Driver')->{ $GetParam{FieldType} }->{DisplayName} || '';

    return $Self->_ShowScreen(
        %Param,
        %GetParam,
        Mode           => 'Add',
        ObjectTypeName => $ObjectTypeName,
        FieldTypeName  => $FieldTypeName,
    );
}

sub _AddAction {
    my ( $Self, %Param ) = @_;

    my %Errors;
    my %GetParam;
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    for my $Needed (qw(Name Label FieldOrder)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = 'This field is required.';
        }
    }

    if ( $GetParam{Name} ) {

        # check if name is alphanumeric
        if ( $GetParam{Name} !~ m{\A (?: [a-zA-Z] | \d )+ \z}xms ) {

            # add server error error class
            $Errors{NameServerError} = 'ServerError';
            $Errors{NameServerErrorMessage} =
                'The field does not contain only ASCII letters and numbers.';
        }

        # check if name is duplicated
        my %DynamicFieldsList = %{
            $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldList(
                Valid      => 0,
                ResultType => 'HASH',
                )
        };

        %DynamicFieldsList = reverse %DynamicFieldsList;

        if ( $DynamicFieldsList{ $GetParam{Name} } ) {

            # add server error error class
            $Errors{NameServerError}        = 'ServerError';
            $Errors{NameServerErrorMessage} = 'There is another field with the same name.';
        }
    }

    if ( $GetParam{FieldOrder} ) {

        # check if field order is numeric and positive
        if ( $GetParam{FieldOrder} !~ m{\A (?: \d )+ \z}xms ) {

            # add server error error class
            $Errors{FieldOrderServerError}        = 'ServerError';
            $Errors{FieldOrderServerErrorMessage} = 'The field must be numeric.';
        }
    }

    for my $ConfigParam (qw(ObjectType ObjectTypeName FieldType FieldTypeName ValidID OperationColumn SelectedOperationColumn OperationFormula Operation ExtractOperation PossibleRowSum ))
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );
    }

    $GetParam{PossibleColumns} = $Self->_GetPossibleColumns();
    $GetParam{PossibleMasks}   = $Self->_GetPossibleMasks();

    my %OperationColumn;
    $OperationColumn{Operation} = $GetParam{OperationColumn};
    $OperationColumn{Formula}   = $GetParam{OperationFormula};

    if ( $GetParam{OperationColumn} ) {
        my @SelectedOperationColumn = $ParamObject->GetArray( Param => 'SelectedOperationColumn' );

        $OperationColumn{Columns} = \@SelectedOperationColumn;
    }

    my @PossibleStates = $ParamObject->GetArray( Param => 'PossibleStates' );

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # uncorrectable errors
    if ( !$GetParam{ValidID} ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ValidID",
        );
    }

    # return to add screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            Mode => 'Add',
        );
    }

    # set specific config
    my $FieldConfig = {
        PossibleColumns => $GetParam{PossibleColumns},
        PossibleMasks   => $GetParam{PossibleMasks},
        OperationColumn => \%OperationColumn,
        ColumnsSum      => { 
			Operation => $GetParam{Operation},
			ExtractOperation => $GetParam{ExtractOperation}
		},
        RowsSum         => $GetParam{PossibleRowSum},
        PossibleStates  => \@PossibleStates,
        DependencyTable => $ParamObject->GetParam( Param => 'DependencyTable' )
    };

    # create a new field
    my $FieldID = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldAdd(
        Name       => $GetParam{Name},
        Label      => $GetParam{Label},
        FieldOrder => $GetParam{FieldOrder},
        FieldType  => $GetParam{FieldType},
        ObjectType => $GetParam{ObjectType},
        Config     => $FieldConfig,
        ValidID    => $GetParam{ValidID},
        UserID     => $Self->{UserID},
    );

    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => "Could not create the new field",
        );
    }

    return $LayoutObject->Redirect(
        OP => "Action=AdminDynamicField",
    );
}

sub _Change {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my %GetParam;

    for my $Needed (qw(ObjectType FieldType)) {
        $GetParam{$Needed} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Needed );
        if ( !$Needed ) {
            return $LayoutObject->ErrorScreen(
                Message => "Need $Needed",
            );
        }
    }

    # get the object type and field type display name
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $ObjectTypeName = $ConfigObject->Get('DynamicFields::ObjectType')->{ $GetParam{ObjectType} }->{DisplayName} || '';
    my $FieldTypeName  = $ConfigObject->Get('DynamicFields::Driver')->{ $GetParam{FieldType} }->{DisplayName} || '';

    my $FieldID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'ID' );

    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ID",
        );
    }

    # get dynamic field data
    my $DynamicFieldData = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
        ID => $FieldID,
    );

    # check for valid dynamic field configuration
    if ( !IsHashRefWithData($DynamicFieldData) ) {
        return $LayoutObject->ErrorScreen(
            Message => "Could not get data for dynamic field $FieldID",
        );
    }

    my %Config = ();

    # extract configuration
    if ( IsHashRefWithData( $DynamicFieldData->{Config} ) ) {
        %Config = %{ $DynamicFieldData->{Config} };
    }

    return $Self->_ShowScreen(
        %Param,
        %GetParam,
        %${DynamicFieldData},
        %Config,
        ID             => $FieldID,
        Mode           => 'Change',
        ObjectTypeName => $ObjectTypeName,
        FieldTypeName  => $FieldTypeName,
    );
}

sub _ChangeAction {
    my ( $Self, %Param ) = @_;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    my %Errors;
    my %GetParam;

    for my $Needed (qw(Name Label FieldOrder)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = 'This field is required.';
        }
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $FieldID = $ParamObject->GetParam( Param => 'ID' );
    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ID",
        );
    }

    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField');

    # get dynamic field data
    my $DynamicFieldData = $DynamicField->DynamicFieldGet(
        ID => $FieldID,
    );

    # check for valid dynamic field configuration
    if ( !IsHashRefWithData($DynamicFieldData) ) {
        return $LayoutObject->ErrorScreen(
            Message => "Could not get data for dynamic field $FieldID",
        );
    }

    if ( $GetParam{Name} ) {

        # check if name is lowercase
        if ( $GetParam{Name} !~ m{\A (?: [a-zA-Z] | \d )+ \z}xms ) {

            # add server error error class
            $Errors{NameServerError} = 'ServerError';
            $Errors{NameServerErrorMessage} =
                'The field does not contain only ASCII letters and numbers.';
        }

        # check if name is duplicated
        my %DynamicFieldsList = %{
            $DynamicField->DynamicFieldList(
                Valid      => 0,
                ResultType => 'HASH',
                )
        };

        %DynamicFieldsList = reverse %DynamicFieldsList;

        if (
            $DynamicFieldsList{ $GetParam{Name} } &&
            $DynamicFieldsList{ $GetParam{Name} } ne $FieldID
            )
        {

            # add server error class
            $Errors{NameServerError}        = 'ServerError';
            $Errors{NameServerErrorMessage} = 'There is another field with the same name.';
        }

        # if it's an internal field, it's name should not change
        if (
            $DynamicFieldData->{InternalField} &&
            $DynamicFieldsList{ $GetParam{Name} } ne $FieldID
            )
        {

            # add server error class
            $Errors{NameServerError}        = 'ServerError';
            $Errors{NameServerErrorMessage} = 'The name for this field should not change.';
            $Param{InternalField}           = $DynamicFieldData->{InternalField};
        }
    }

    if ( $GetParam{FieldOrder} ) {

        # check if field order is numeric and positive
        if ( $GetParam{FieldOrder} !~ m{\A (?: \d )+ \z}xms ) {

            # add server error error class
            $Errors{FieldOrderServerError}        = 'ServerError';
            $Errors{FieldOrderServerErrorMessage} = 'The field must be numeric.';
        }
    }

    for my $ConfigParam (qw(ObjectType ObjectTypeName FieldType FieldTypeName ValidID OperationColumn SelectedOperationColumn OperationFormula Operation ExtractOperation PossibleRowSum ))
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );
    }

    $GetParam{PossibleColumns} = $Self->_GetPossibleColumns();
    $GetParam{PossibleMasks}   = $Self->_GetPossibleMasks();

    my %OperationColumn;
    $OperationColumn{Operation} = $GetParam{OperationColumn};
    $OperationColumn{Formula}   = $GetParam{OperationFormula};

    if ( $GetParam{OperationColumn} ) {
        my @SelectedOperationColumn = $ParamObject->GetArray( Param => 'SelectedOperationColumn' );

        $OperationColumn{Columns} = \@SelectedOperationColumn;
    }

    my @PossibleStates = $ParamObject->GetArray( Param => 'PossibleStates' );

    # uncorrectable errors
    if ( !$GetParam{ValidID} ) {
        return $LayoutObject->ErrorScreen(
            Message => "Need ValidID",
        );
    }

    # return to change screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            ID   => $FieldID,
            Mode => 'Change',
        );
    }

    # set specific config
    my $FieldConfig = {
        PossibleColumns => $GetParam{PossibleColumns},
        PossibleMasks   => $GetParam{PossibleMasks},
        OperationColumn => \%OperationColumn,
        ColumnsSum      => { 
			Operation => $GetParam{Operation},
			ExtractOperation => $GetParam{ExtractOperation}
		},
        RowsSum         => $GetParam{PossibleRowSum},
        PossibleStates  => \@PossibleStates,
        DependencyTable => $ParamObject->GetParam( Param => 'DependencyTable' )
    };
	
    # update dynamic field (FieldType and ObjectType cannot be changed; use old values)
    my $UpdateSuccess = $DynamicField->DynamicFieldUpdate(
        ID         => $FieldID,
        Name       => $GetParam{Name},
        Label      => $GetParam{Label},
        FieldOrder => $GetParam{FieldOrder},
        FieldType  => $DynamicFieldData->{FieldType},
        ObjectType => $DynamicFieldData->{ObjectType},
        Config     => $FieldConfig,
        ValidID    => $GetParam{ValidID},
        UserID     => $Self->{UserID},
    );

    if ( !$UpdateSuccess ) {
        return $LayoutObject->ErrorScreen(
            Message => "Could not update the field $GetParam{Name}",
        );
    }

    # if the user would like to continue editing the dynamic field, just redirect to the change screen
    if (
        defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
        && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
        )
    {
        return $LayoutObject->Redirect(
            OP =>
                "Action=$Self->{Action};Subaction=Change;ObjectType=$DynamicFieldData->{ObjectType};FieldType=$DynamicFieldData->{FieldType};ID=$FieldID"
        );
    }
    else {

        # otherwise return to overview
        return $LayoutObject->Redirect( OP => "Action=AdminDynamicField" );
    }
}

sub _ShowScreen {
    my ( $Self, %Param ) = @_;

    $Param{DisplayFieldName} = 'New';

    if ( $Param{Mode} eq 'Change' ) {
        $Param{ShowWarning}      = 'ShowWarning';
        $Param{DisplayFieldName} = $Param{Name};
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $StateObject  = $Kernel::OM->Get('Kernel::System::State');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # header
    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # get all fields
    my $DynamicFieldList = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid => 0,
    );

    # get the list of order numbers (is already sorted).
    my @DynamicfieldOrderList;
    my %DynamicfieldNamesList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {
        push @DynamicfieldOrderList, $Dynamicfield->{FieldOrder};
        $DynamicfieldNamesList{ $Dynamicfield->{FieldOrder} } = $Dynamicfield->{Label};
    }

    # when adding we need to create an extra order number for the new field
    if ( $Param{Mode} eq 'Add' ) {

        # get the last element form the order list and add 1
        my $LastOrderNumber = $DynamicfieldOrderList[-1];
        $LastOrderNumber++;

        # add this new order number to the end of the list
        push @DynamicfieldOrderList, $LastOrderNumber;
    }

    # show the names of the other fields to ease ordering
    my %OrderNamesList;
    my $CurrentlyText = $LayoutObject->{LanguageObject}->Translate('Currently') . ': ';
    for my $OrderNumber ( sort @DynamicfieldOrderList ) {
        $OrderNamesList{$OrderNumber} = $OrderNumber;
        if ( $DynamicfieldNamesList{$OrderNumber} && $OrderNumber ne $Param{FieldOrder} ) {
            $OrderNamesList{$OrderNumber} = $OrderNumber . ' - '
                . $CurrentlyText
                . $DynamicfieldNamesList{$OrderNumber}
        }
    }

    my $DynamicFieldOrderStrg = $LayoutObject->BuildSelection(
        Data          => \%OrderNamesList,
        Name          => 'FieldOrder',
        SelectedValue => $Param{FieldOrder} || 1,
        PossibleNone  => 0,
        Translation   => 1,
        Sort          => 'NumericKey',
        Class         => 'Modernize W75pc Validate_Number',
    );

    # Create a selection with all dynamic field number to set dependency
    my %DynamicfieldActualNamesList;
    for my $Dynamicfield ( @{$DynamicFieldList} ) {

        if($Dynamicfield->{FieldType} eq 'Table' && $Dynamicfield->{Name} ne $Param{Name}) {

            $DynamicfieldActualNamesList{$Dynamicfield->{ID}} = $Dynamicfield->{Name};
        }
    }

    my $DependencyTable = $LayoutObject->BuildSelection(
        Data          => \%DynamicfieldActualNamesList,
        Name          => 'DependencyTable',
        SelectedID    => $Param{DependencyTable},
        PossibleNone  => 1,
        Class         => 'W10pc Modernize',
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

    my $ValueCounter = 0;

    my %PossibleMask;

    my $FlagSize = 0;

    if ($Param{PossibleColumns}) {
        $FlagSize = scalar @{$Param{PossibleColumns}};
    }

    my $AutoCompleteColumn = '';
    my $AutoCompleteDelay = '';
    my $AutoCompleteModule = '';
    my $AutoCompleteWebService = '';
    my $AutoCompleteInvoker = '';

    if ( $Param{PossibleColumns} && $FlagSize != 0) {

        # output the possible columns and errors within (if any)
        for my $Column ( @{ $Param{PossibleColumns} } ) {

            $ValueCounter++;

            my $ContentClass;
            my $ContainerClass;
            my $OptionsStr;

            if ( $ValueCounter > 1 ) {
                $ContainerClass = "ValueRow";
            }
            else {
                $ContainerClass = "ValueTemplate";
            }

            if ( $Column->{ctrlOptions} ) {
                
                $ContentClass = "";
                my @Options;
                for my $Key ( sort keys %{ $Column->{ctrlOptions} } ) {
                    push @Options, $Key;
                }

                # get options of field type list
                $OptionsStr = join( ';', @Options );
            }
            else {
                $ContentClass = "Hidden";
            }

            my $PossibleDataTypes = $LayoutObject->BuildSelection(
                Data         => $Self->{PossibleData},
                Name         => "TypeColumn_$ValueCounter",
                PossibleNone => 1,
                Translation  => 1,
                SelectedID   => $Column->{type},
                Class        => "W10pc Modernize DataTypeColumn_$ValueCounter",
            );

            # default to everyone
            my $EditableByValue = $Column->{editable};
            if( $EditableByValue eq '' ) {
                $EditableByValue = "everyone"
            }

            my $EditableByList = $LayoutObject->BuildSelection(
                Data         => $Self->{EditableBy},
                Name         => "EditableColumn_$ValueCounter",
                PossibleNone => 1,
                Translation  => 1,
                SelectedID   => $EditableByValue,
                Class        => "W10pc Modernize EditableColumn_$ValueCounter NewColumn",
            );

            my $EncodeObject = $Kernel::OM->Get('Kernel::System::Encode');
            
            if ( $Column->{type} eq 'mask' || $Column->{type} eq 'maskMoney' ) {

                my $Name = $EncodeObject->Convert(
                    Text => $Column->{name},
                    From => 'iso-8859-1',
                    To   => 'utf-8',
                );
                
                # my $Name = encode( 'UTF-8', $Column->{name} );

                $PossibleMask{$Name} = $Column->{type};
            }

            
            my $DefaultLabel = "Default";
            if( $Column->{type} eq "computed" ) {
                $DefaultLabel = "Formula";
            }

            # create a value map row
            $LayoutObject->Block(
                Name => 'ValueRow',
                Data => {
                    ValueCounter      => $ValueCounter,
                    Column            => $Column->{name},
                    PossibleDataTypes => $PossibleDataTypes,
                    ContentClass      => $ContentClass,
                    ColumnContent     => $OptionsStr,
                    ContainerClass    => $ContainerClass,
                    EditableByList    => $EditableByList,
                    Default           => $Column->{value},
                    DefaultLabel      => $DefaultLabel,
                },
            );

            if( defined $Column->{autocomplete_delay} ) {
                $AutoCompleteColumn = $Column->{name};
                $AutoCompleteDelay  = $Column->{autocomplete_delay};
                $AutoCompleteModule = $Column->{autocomplete_module};
                $AutoCompleteWebService = $Column->{auto_complete_webservice};
                $AutoCompleteInvoker    = $Column->{auto_complete_invoker};
            }
        }
    }
    else {
        # $ValueCounter++;

        $Param{PossibleDataTypes} = $LayoutObject->BuildSelection(
            Data         => $Self->{PossibleData},
            Name         => "TypeColumn_$ValueCounter",
            PossibleNone => 1,
            Translation  => 1,
            Class        => 'W10pc Modernize DataTypeColumn_1',
        );

        $Param{EditableByList} = $LayoutObject->BuildSelection(
            Data         => $Self->{EditableBy},
            Name         => "EditableColumn_$ValueCounter",
            PossibleNone => 1,
            Translation  => 1,
            Class        => 'W10pc Modernize EditableColumn_1',
        );

        # create the possible values template
        $LayoutObject->Block(
            Name => 'ValueTemplate',
            Data => {
                %Param,
                ValueCounter => $ValueCounter,
            },
        );
    }

    for my $ColumnMask ( sort keys %PossibleMask ) {
        
        my $ColumnName = decode( 'UTF-8', $ColumnMask );
        
        if ( $PossibleMask{$ColumnMask} eq 'mask' ) {

            my $Name = $ColumnName;
            
            # clean up white spaces
            $ColumnName =~ s/ //g;
       
            my $PossibleMasks = $ConfigObject->Get('DynamicFieldTable::Core')->{'PossibleMasks'};

            my $PossibleMasksStr = $LayoutObject->BuildSelection(
                Data         => $PossibleMasks,
                Name         => "PossibleMasks_$Name",
                Class        => 'W10pc Modernize',
                PossibleNone => 1,
                Translation  => 1,
                SelectedID   => $Param{PossibleMasks}->{$Name}->{Mask},
            );

            $LayoutObject->Block(
                Name => 'MaskText',
                Data => {
                    Name          => $Name,
                    ColumnMask    => $ColumnName,
                    PossibleMasks => $PossibleMasksStr
                },
            );
        }
        
        elsif ( $PossibleMask{$ColumnMask} eq 'maskMoney' ) {

            my $Name = $ColumnMask;

            # clean up white spaces
            $ColumnMask =~ s/ //g;

            my %PossibleNegative = (
                true  => 'Yes',
                false => 'No',
            );

            my $PossibleNegativeStr = $LayoutObject->BuildSelection(
                Data        => \%PossibleNegative,
                Name        => "PossibleNegative_$Name",
                Class       => 'W10pc Modernize',
                SelectedID  => $Param{PossibleMasks}->{$Name}->{Negative},
                Translation => 1,
            );

            $LayoutObject->Block(
                Name => 'MaskMoney',
                Data => {
                    ColumnMask       => $ColumnMask,
                    Name             => $Name,
                    PossibleNegative => $PossibleNegativeStr,
                    MoneyPrefix      => $Param{PossibleMasks}->{$Name}->{Prefix}
                },
            );
        }
    }
   
    my $OperationColumn = $LayoutObject->BuildSelection(
        Data => {
            'Sum'            => 'Sum',
            'Subtraction'    => 'Subtraction',
            'Multiplication' => 'Multiplication',
            'Division'       => 'Division',
            'Formula'        => 'Formula'
        },
        Name         => "OperationColumn",
        Class        => 'W10pc Modernize',
        PossibleNone => 1,
        SelectedID   => $Param{OperationColumn}->{Operation} || '',
        Translation  => 1,
    );

    my $PossibleRowSum = $LayoutObject->BuildSelection(
        Data => {
            true  => 'Yes',
            false => 'No',
        },
        Name        => "PossibleRowSum",
        Class       => 'W10pc Modernize',
        SelectedID  => $Param{RowsSum} || '',
        Translation => 1,
    );

    my $PossibleStates = $LayoutObject->BuildSelection(
        Data => {
            $StateObject->StateList( UserID => 1 )
        },
        Name        => "PossibleStates",
        Class       => 'W10pc Modernize',
        SelectedID  => $Param{PossibleStates} || '',
        Multiple    => 1,
        Translation => 1,
    );
	
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	 
	my $List = $DynamicFieldObject->DynamicFieldListGet();
	
	my @DynamicFields = ();
	
	foreach my $Field ( @{$List} ){
		if ( $Field->{FieldType} eq 'Text' && 
			( $Field->{Name} ne 'ProcessManagementProcessID' && $Field->{Name} ne 'ProcessManagementActivityID' ) 
			){
			push @DynamicFields, $Field->{Name};
		}
	}
	
	my $ExtractOperation = $LayoutObject->BuildSelection(
        Data => \@DynamicFields,
        Name        => "ExtractOperation",
        Class       => 'W10pc Modernize',
        SelectedID  => $Param{ColumnsSum}{ExtractOperation} || '',
		PossibleNone => 1,
    );	


    my $WebserviceList = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceList();
    my %WebserviceList;
    if ( IsHashRefWithData($WebserviceList) ) {
        %WebserviceList = map { $_ => $_ } values %{$WebserviceList};
    }

    my $AutoCompleteWebServiceStrg = $LayoutObject->BuildSelection(
        Data         => \%WebserviceList,
        Name         => 'AutoCompleteWebService',
        ID           => 'AutoCompleteWebService',
        SelectedID   => $AutoCompleteWebService,
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize',
    );
    	

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminDynamicFieldTable',
        Data         => {
            %Param,
            ValidityStrg            => $ValidityStrg,
            DynamicFieldOrderStrg   => $DynamicFieldOrderStrg,
            ValueCounter            => $ValueCounter,
            OperationColumn         => $OperationColumn,
            OperationFormula        => $Param{OperationColumn}->{Formula},
            PossibleRowSum          => $PossibleRowSum,
            PossibleStates          => $PossibleStates,
            ExtractOperation        => $ExtractOperation,
            Operation               => $Param{ColumnsSum}{Operation},

            AutoCompleteColumn      => $AutoCompleteColumn,
            AutoCompleteDelay       => $AutoCompleteDelay,
            AutoCompleteModule      => $AutoCompleteModule,

            AutoCompleteWebService  => $AutoCompleteWebServiceStrg,
            AutoCompleteInvoker     => $AutoCompleteInvoker,

            DependencyTable         => $DependencyTable
		}
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _GetPossibleColumns {
    my ( $Self, %Param ) = @_;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $AutoCompleteColumn = $ParamObject->GetParam( Param => 'AutoCompleteColumn' );

    my @PossibleColumnConfig;

    # get ValueCounters from web browser
    my $ValueCounter = $ParamObject->GetParam( Param => 'ValueCounter' ) || 1;

    # get possible values
    my $Values;

    VALUEINDEX:
    for my $ValueIndex ( 1 .. $ValueCounter ) {

        my %GetParam = ();

        $GetParam{name} = $ParamObject->GetParam( Param => 'Column' . '_' . $ValueIndex );
        $GetParam{display} = $GetParam{name};

        # check if key was deleted by the user and skip it
        next VALUEINDEX if ( !$GetParam{name} );

        $GetParam{type} = $ParamObject->GetParam( Param => 'TypeColumn' . '_' . $ValueIndex );

        if ( $GetParam{type} eq 'select' ) {

            my @Options = split /;/, $ParamObject->GetParam( Param => 'ContentColumn' . '_' . $ValueIndex );
            my %Select;

            for my $Op (@Options) {
                $Select{$Op} = $Op;
            }

            $GetParam{ctrlOptions} = \%Select;
        }
        elsif ( $GetParam{type} eq 'maskMoney' ) {
            $GetParam{ctrlClass} = 'maskMoney';
        }

        $GetParam{name} = ( defined $GetParam{name} ? $GetParam{name} : '' );

        $GetParam{value} = $ParamObject->GetParam( Param => 'Default' . '_' . $ValueIndex );
        $GetParam{value} ||= '';

        $GetParam{editable} = $ParamObject->GetParam( Param => 'EditableColumn' . '_' . $ValueIndex );

        # check if column is autocomplete
        if($GetParam{name} eq $AutoCompleteColumn) {

            $GetParam{autocomplete_delay} = $ParamObject->GetParam( Param => 'AutoCompleteDelay' );
            $GetParam{autocomplete_module} = $ParamObject->GetParam( Param => 'AutoCompleteModule' );
            $GetParam{auto_complete_webservice} = $ParamObject->GetParam( Param => 'AutoCompleteWebService' );
            $GetParam{auto_complete_invoker}    = $ParamObject->GetParam( Param => 'AutoCompleteInvoker' );
        }

        # check if columns was autocomplete
        if($GetParam{name} ne $AutoCompleteColumn && defined $GetParam{autocomplete_delay}) {

            $GetParam{autocomplete_delay} = 0;
            $GetParam{autocomplete_module} = '';
        }

        push @PossibleColumnConfig, \%GetParam;
    }

    return \@PossibleColumnConfig;
}

sub _GetPossibleMasks {
    my ( $Self, %Param ) = @_;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get parameters from web browser
    # get ValueCounters
    my $ValueCounter = $ParamObject->GetParam( Param => 'ValueCounter' ) || 1;

    # get possible values
    my $Values;
    my %GetParam = ();

    VALUEINDEX:
    for my $ValueIndex ( 1 .. $ValueCounter ) {

        my $Name = $ParamObject->GetParam( Param => 'Column' . '_' . $ValueIndex );
        my $NameEncode = encode( 'UTF-8', $Name );

        # check if key was deleted by the user and skip it
        next VALUEINDEX if ( !$Name );

        my $Type = $ParamObject->GetParam( Param => 'TypeColumn' . '_' . $ValueIndex );

        if ( $Type eq 'mask' ) {
            my $Mask = $ParamObject->GetParam( Param => 'PossibleMasks_' . $NameEncode );

            my %MaskHash = (
                Mask => $Mask
            );

            $GetParam{$Name} = \%MaskHash;
        }
        elsif ( $Type eq 'maskMoney' ) {
            my $Prefix           = $ParamObject->GetParam( Param => 'MoneyMaskPrefix_' . $NameEncode );
            my $PossibleNegative = $ParamObject->GetParam( Param => 'PossibleNegative_' . $NameEncode );

            my %MaskHash = (
                Prefix   => $Prefix,
                Negative => $PossibleNegative
            );

            $GetParam{$Name} = \%MaskHash;
        }

        $Name = ( defined $Name ? $Name : '' );
    }

    return \%GetParam;
}

sub _AjaxNewColumn {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %GetParam;

    for my $Needed (qw(ValueCounter)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
    }

    $Param{PossibleDataTypes} = $LayoutObject->BuildSelection(
        Data         => $Self->{PossibleData},
        Name         => "TypeColumn_$GetParam{ValueCounter}",
        PossibleNone => 1,
        Translation  => 1,
        Class        => "W10pc Modernize DataTypeColumn_$GetParam{ValueCounter} NewColumn",
    );

    $Param{EditableByList} = $LayoutObject->BuildSelection(
        Data         => $Self->{EditableBy},
        Name         => "EditableColumn_$GetParam{ValueCounter}",
        PossibleNone => 1,
        Translation  => 1,
        SelectedID   => "everyone",
        Class        => "W10pc Modernize EditableColumn_$GetParam{ValueCounter} NewColumn",
        # TODO: Colocar valor default como 'everyone'
    );

    # build field
    $Param{ValueCounter} = $GetParam{ValueCounter};

    # displays Survey in the template
    $LayoutObject->Block(
        Name => 'ValueTemplate',
        Data => \%Param,
    );

    # displays Survey in the template
    $LayoutObject->Block(
        Name => 'FooterJS',
    );

    # import the content of the template SurveyList
    my $TableColumnHTML = $LayoutObject->Output( TemplateFile => 'DynamicFieldTableColumn' );

    # return to screen
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $TableColumnHTML,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _NewMaskAjax {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my %GetParam;

    for my $Needed (qw(Name Type)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
    }

    if ( $GetParam{Type} eq 'mask' ) {

        my $PossibleMasks = $ConfigObject->Get('DynamicFieldTable::Core')->{'PossibleMasks'};

        my $PossibleMasksStr = $LayoutObject->BuildSelection(
            Data         => $PossibleMasks,
            Name         => "PossibleMasks_$GetParam{Name}",
            Class        => 'W10pc Modernize',
            PossibleNone => 1,
            Translation  => 1,
        );

        $LayoutObject->Block(
            Name => 'MaskText',
            Data => {
                ColumnMask    => $GetParam{Name},
                PossibleMasks => $PossibleMasksStr
            },
        );
    }
    elsif ( $GetParam{Type} eq 'maskMoney' ) {

        my %PossibleNegative = (
            true  => 'Yes',
            false => 'No',
        );

        my $PossibleNegativeStr = $LayoutObject->BuildSelection(
            Data         => \%PossibleNegative,
            Name         => "PossibleNegative_$GetParam{Name}",
            Class        => 'W10pc Modernize',
            PossibleNone => 1,
            Translation  => 1,
        );

        $LayoutObject->Block(
            Name => 'MaskMoney',
            Data => {
                ColumnMask       => $GetParam{Name},
                PossibleNegative => $PossibleNegativeStr
            },
        );
    }

    # import the content of the template SurveyList
    my $DFTableMaskHTML = $LayoutObject->Output( TemplateFile => 'DynamicFieldTableMask' );

    # return to screen
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $DFTableMaskHTML,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _OperationColumn {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $FieldID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'ID' );

    # get dynamic field data
    my $DynamicFieldData = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
        ID => $FieldID,
    );

    # convert string structure to array Dumper
    my @GetColumns = split /;/, $ParamObject->GetParam( Param => 'PossibleColumns' );

    my $Columns = $LayoutObject->BuildSelection(
        Data        => \@GetColumns,
        Name        => "SelectedOperationColumn",
        Class       => 'W10pc Modernize',
        Multiple    => 1,
        Translation => 1,
        SelectedID  => $DynamicFieldData->{Config}->{OperationColumn}->{Columns}
    );

    # return to screen
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $Columns,
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;