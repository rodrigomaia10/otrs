# --
# Kernel/Modules/AdminDynamicFieldSelectDB.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * gesquetini@beonup.com.br
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * ccresencio@serviceup.com.br
# --

package Kernel::Modules::AdminDynamicFieldSelectDB;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

use Kernel::System::DFSelectDB;
use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    # set possible values handling strings
    $Self->{EmptyString}     = '_DynamicFields_EmptyString_Dont_Use_It_String_Please';
    $Self->{DuplicateString} = '_DynamicFields_DuplicatedString_Dont_Use_It_String_Please';
    $Self->{DeletedString}   = '_DynamicFields_DeletedString_Dont_Use_It_String_Please';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # Store last entity screen.
    $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenEntity',
        Value     => $Self->{RequestedURL},
    );

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

    if ( $Self->{Subaction} eq 'DefaultValueSearch' ) {	
        return $Self->_DefaultValueSearch(
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
    for my $Needed (qw(ObjectType FieldType FieldOrder)) {
        $GetParam{$Needed} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}->Translate( 'Need %s', $Needed ),
            );
        }
    }

    # get the object type and field type display name
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $ObjectTypeName = $ConfigObject->Get('DynamicFields::ObjectType')->{ $GetParam{ObjectType} }->{DisplayName}
        || '';
    my $FieldTypeName = $ConfigObject->Get('DynamicFields::Driver')->{ $GetParam{FieldType} }->{DisplayName} || '';

    return $Self->_ShowScreen(
        %Param,
        %GetParam,
        Mode           => 'Add',
        BreadcrumbText => $LayoutObject->{LanguageObject}
            ->Translate( 'Add %s field', $LayoutObject->{LanguageObject}->Translate($FieldTypeName) ),
        ObjectTypeName => $ObjectTypeName,
        FieldTypeName  => $FieldTypeName,
    );
}

sub _AddAction {
    my ( $Self, %Param ) = @_;
    my %Errors;
    my %GetParam;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    for my $Needed (qw(Name Label FieldOrder MaxArraySize DatabaseDSN DatabaseUser DatabaseTable DatabaseFieldKey 
    MinQueryLength MaxQueryResult)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = Translatable('This field is required.');
        }
    }

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    if ( $GetParam{Name} ) {

        # check if name is alphanumeric
        if ( $GetParam{Name} !~ m{\A (?: [a-zA-Z] | \d )+ \z}xms ) {

            # add server error error class
            $Errors{NameServerError} = 'ServerError';
            $Errors{NameServerErrorMessage} =
                Translatable('The field does not contain only ASCII letters and numbers.');
        }

        # check if name is duplicated
        my %DynamicFieldsList = %{
            $DynamicFieldObject->DynamicFieldList(
                Valid      => 0,
                ResultType => 'HASH',
            )
        };

        %DynamicFieldsList = reverse %DynamicFieldsList;

        if ( $DynamicFieldsList{ $GetParam{Name} } ) {

            # add server error error class
            $Errors{NameServerError}        = 'ServerError';
            $Errors{NameServerErrorMessage} = Translatable('There is another field with the same name.');
        }
    }

    if ( $GetParam{FieldOrder} ) {

        # check if field order is numeric and positive
        if ( $GetParam{FieldOrder} !~ m{\A (?: \d )+ \z}xms ) {

            # add server error error class
            $Errors{FieldOrderServerError}        = 'ServerError';
            $Errors{FieldOrderServerErrorMessage} = Translatable('The field must be numeric.');
        }
    }

    for my $ConfigParam (
        qw(
        ObjectType ObjectTypeName FieldType FieldTypeName ValidID 
        StandardConnection DatabasePw DatabaseType DatabaseFieldValue DatabaseFieldSearch ColumnAnd DynamicFieldAnd DatabaseTableFreeField
        MinQueryLength MaxQueryResult CacheTTL CachePossibleValues
        )
        )
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );
    }

    # get 'array' configuration params
    for my $ConfigParam (
        qw(
            DefaultValues
        )
    ) {
        my @Data = $ParamObject->GetArray( Param => $ConfigParam );
        $GetParam{$ConfigParam} = \@Data;
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # uncorrectable errors
    if ( !$GetParam{ValidID} ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Need ValidID'),
        );
    }

    my $PossibleValues = $Self->_GetPossibleValues();

    # set errors for possible values entries
    KEY:
    for my $Keys ( @{$PossibleValues} ) {

        my ($Key) = keys %{$Keys};

        # check for empty original values
        if ( $Key =~ m{\A $Self->{EmptyString} (?: \d+)}smx ) {

            # set a true entry in KeyEmptyError
            $Errors{'PossibleValueErrors'}->{'KeyEmptyError'}->{$Key} = 1;
        }

        # otherwise check for duplicate original values
        elsif ( $Key =~ m{\A (.+) - $Self->{DuplicateString} (?: \d+)}smx ) {

            # set an entry in OrigValueDuplicateError with the duplicate key as value
            $Errors{'PossibleValueErrors'}->{'KeyDuplicateError'}->{$Key} = $1;
        }

    }

    # return to add screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            PossibleValues => $PossibleValues,
            Mode           => 'Add',
        );
    }

    # set specific config
    my $FieldConfig = {
        StandardConnection     => $GetParam{StandardConnection},
        DatabaseDSN            => $GetParam{DatabaseDSN},
        DatabaseUser           => $GetParam{DatabaseUser},
        DatabasePw             => $GetParam{DatabasePw},
        DatabaseType           => lc $GetParam{DatabaseType}        || '',
        DatabaseTable          => $GetParam{DatabaseTable},
        DatabaseFieldKey       => $GetParam{DatabaseFieldKey},
        DatabaseFieldValue     => $PossibleValues                   || $GetParam{DatabaseFieldKey},
        DatabaseFieldSearch    => $GetParam{DatabaseFieldSearch}    || $GetParam{DatabaseFieldKey}, 
        ColumnAnd              => $GetParam{ColumnAnd}              || '',
        DatabaseTableFreeField => $GetParam{DatabaseTableFreeField} || '',
        DynamicFieldAnd        => $GetParam{DynamicFieldAnd}        || '',
        MaxArraySize           => $GetParam{MaxArraySize}           || 1,
        CacheTTL               => $GetParam{CacheTTL}               || 0,
        QueryDelay             => 300,
        CachePossibleValues    => $GetParam{CachePossibleValues}    || 0,
        MinQueryLength         => $GetParam{MinQueryLength}         || 3,
        MaxQueryResult         => $GetParam{MaxQueryResult}         || 10,
        DefaultValues          => $GetParam{DefaultValues}          || [],
    };

    # create a new field
    my $FieldID = $DynamicFieldObject->DynamicFieldAdd(
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
            Message => Translatable('Could not create the new field'),
        );
    }

    return $LayoutObject->Redirect(
        OP => "Action=AdminDynamicField",
    );
}

sub _Change {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my %GetParam;
    for my $Needed (qw(ObjectType FieldType)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}->Translate( 'Need %s', $Needed ),
            );
        }
    }

    # get the object type and field type display name
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $ObjectTypeName = $ConfigObject->Get('DynamicFields::ObjectType')->{ $GetParam{ObjectType} }->{DisplayName}
        || '';
    my $FieldTypeName = $ConfigObject->Get('DynamicFields::Driver')->{ $GetParam{FieldType} }->{DisplayName} || '';

    my $FieldID = $ParamObject->GetParam( Param => 'ID' );

    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Need ID'),
        );
    }

    # get dynamic field data
    my $DynamicFieldData = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldGet(
        ID => $FieldID,
    );

    # check for valid dynamic field configuration
    if ( !IsHashRefWithData($DynamicFieldData) ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'Could not get data for dynamic field %s', $FieldID ),
        );
    }

    my %Config = ();

    # extract configuration
    if ( IsHashRefWithData( $DynamicFieldData->{Config} ) ) {
       %Config = %{ $DynamicFieldData->{Config} }
    }

    return $Self->_ShowScreen(
        %Param,
        %GetParam,
        %${DynamicFieldData},
        %Config,
        ID             => $FieldID,
        Mode           => 'Change',
        BreadcrumbText => $LayoutObject->{LanguageObject}
            ->Translate( 'Change %s field', $LayoutObject->{LanguageObject}->Translate($FieldTypeName) ),
        ObjectTypeName => $ObjectTypeName,
        FieldTypeName  => $FieldTypeName,
    );
}

sub _ChangeAction {
    my ( $Self, %Param ) = @_;
    my %Errors;
    my %GetParam;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    for my $Needed (qw(Name Label FieldOrder MaxArraySize DatabaseDSN DatabaseUser DatabaseTable DatabaseFieldKey)) {
        $GetParam{$Needed} = $ParamObject->GetParam( Param => $Needed );
        if ( !$GetParam{$Needed} ) {
            $Errors{ $Needed . 'ServerError' }        = 'ServerError';
            $Errors{ $Needed . 'ServerErrorMessage' } = Translatable('This field is required.');
        }
    }

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $FieldID = $ParamObject->GetParam( Param => 'ID' );
    if ( !$FieldID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Need ID'),
        );
    }

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # get dynamic field data
    my $DynamicFieldData = $DynamicFieldObject->DynamicFieldGet(
        ID => $FieldID,
    );

    # check for valid dynamic field configuration
    if ( !IsHashRefWithData($DynamicFieldData) ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'Could not get data for dynamic field %s', $FieldID ),
        );
    }

    if ( $GetParam{Name} ) {

        # check if name is lowercase
        if ( $GetParam{Name} !~ m{\A (?: [a-zA-Z] | \d )+ \z}xms ) {

            # add server error error class
            $Errors{NameServerError} = 'ServerError';
            $Errors{NameServerErrorMessage} =
                Translatable('The field does not contain only ASCII letters and numbers.');
        }

        # check if name is duplicated
        my %DynamicFieldsList = %{
            $DynamicFieldObject->DynamicFieldList(
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
            $Errors{NameServerErrorMessage} = Translatable('There is another field with the same name.');
        }

        # if it's an internal field, it's name should not change
        if (
            $DynamicFieldData->{InternalField} &&
            $DynamicFieldsList{ $GetParam{Name} } ne $FieldID
            )
        {

            # add server error class
            $Errors{NameServerError}        = 'ServerError';
            $Errors{NameServerErrorMessage} = Translatable('The name for this field should not change.');
            $Param{InternalField}           = $DynamicFieldData->{InternalField};
        }
    }

    if ( $GetParam{FieldOrder} ) {

        # check if field order is numeric and positive
        if ( $GetParam{FieldOrder} !~ m{\A (?: \d )+ \z}xms ) {

            # add server error error class
            $Errors{FieldOrderServerError}        = 'ServerError';
            $Errors{FieldOrderServerErrorMessage} = Translatable('The field must be numeric.');
        }
    }

    for my $ConfigParam (
        qw(
        ObjectType ObjectTypeName FieldType FieldTypeName ValidID 
        StandardConnection DatabasePw DatabaseType DatabaseFieldValue DatabaseFieldSearch ColumnAnd DynamicFieldAnd DatabaseTableFreeField 
        MinQueryLength MaxQueryResult CacheTTL CachePossibleValues
        )
        )
    {
        $GetParam{$ConfigParam} = $ParamObject->GetParam( Param => $ConfigParam );
    }

    # get 'array' configuration params
    for my $ConfigParam (
        qw(
            DefaultValues
        )
    ) {
        my @Data = $ParamObject->GetArray( Param => $ConfigParam );
        $GetParam{$ConfigParam} = \@Data;
    }

    # uncorrectable errors
    if ( !$GetParam{ValidID} ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Need ValidID'),
        );
    }

    my $PossibleValues = $Self->_GetPossibleValues();

    # set errors for possible values entries
    KEY:
    for my $Keys ( @{$PossibleValues} ) {

         my ($Key) = keys %{$Keys};

        # check for empty original values
        if ( $Key =~ m{\A $Self->{EmptyString} (?: \d+)}smx ) {

            # set a true entry in KeyEmptyError
            $Errors{'PossibleValueErrors'}->{'KeyEmptyError'}->{$Key} = 1;
        }

        # otherwise check for duplicate original values
        elsif ( $Key =~ m{\A (.+) - $Self->{DuplicateString} (?: \d+)}smx ) {

            # set an entry in OrigValueDuplicateError with the duplicate key as value
            $Errors{'PossibleValueErrors'}->{'KeyDuplicateError'}->{$Key} = $1;
        }

    }

    # Check if dynamic field is present in SysConfig setting
    my $UpdateEntity        = $ParamObject->GetParam( Param => 'UpdateEntity' ) || '';
    my $SysConfigObject     = $Kernel::OM->Get('Kernel::System::SysConfig');
    my %DynamicFieldOldData = %{$DynamicFieldData};
    my @IsDynamicFieldInSysConfig;
    @IsDynamicFieldInSysConfig = $SysConfigObject->ConfigurationEntityCheck(
        EntityType => 'DynamicField',
        EntityName => $DynamicFieldData->{Name},
    );
    if (@IsDynamicFieldInSysConfig) {

        # An entity present in SysConfig couldn't be invalidated.
        if (
            $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup( ValidID => $GetParam{ValidID} )
            ne 'valid'
            )
        {
            $Errors{ValidIDInvalid}         = 'ServerError';
            $Errors{ValidOptionServerError} = 'InSetting';
        }

        # In case changing name an authorization (UpdateEntity) should be send
        elsif ( $DynamicFieldData->{Name} ne $GetParam{Name} && !$UpdateEntity ) {
            $Errors{NameInvalid}              = 'ServerError';
            $Errors{InSettingNameServerError} = 1;
        }
    }

    # return to change screen if errors
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %Errors,
            %GetParam,
            PossibleValues => $PossibleValues,
            ID             => $FieldID,
            Mode           => 'Change',
        );
    }

    # set specific config
    my $FieldConfig = {
        StandardConnection     => $GetParam{StandardConnection},
        DatabaseDSN            => $GetParam{DatabaseDSN},
        DatabaseUser           => $GetParam{DatabaseUser},
        DatabasePw             => $GetParam{DatabasePw},
        DatabaseType           => lc $GetParam{DatabaseType}     || '',
        DatabaseTable          => $GetParam{DatabaseTable},
        DatabaseFieldKey       => $GetParam{DatabaseFieldKey},
        DatabaseFieldValue     => $PossibleValues                || $GetParam{DatabaseFieldKey},
        DatabaseFieldSearch    => $GetParam{DatabaseFieldSearch} || $GetParam{DatabaseFieldKey},
        ColumnAnd              => $GetParam{ColumnAnd}           || '',
        DynamicFieldAnd        => $GetParam{DynamicFieldAnd}     || '',
        DatabaseTableFreeField => $GetParam{DatabaseTableFreeField}     || '',
        MaxArraySize           => $GetParam{MaxArraySize}        || 1,
        CacheTTL               => $GetParam{CacheTTL}            || 0,
        QueryDelay             => 300,
        CachePossibleValues    => $GetParam{CachePossibleValues} || 0,
        MinQueryLength         => $GetParam{MinQueryLength}      || 3,
        MaxQueryResult         => $GetParam{MaxQueryResult}      || 10,
        DefaultValues          => $GetParam{DefaultValues}       || []
    };

    # update dynamic field (FieldType and ObjectType cannot be changed; use old values)
    my $UpdateSuccess = $DynamicFieldObject->DynamicFieldUpdate(
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
            Message => $LayoutObject->{LanguageObject}->Translate( 'Could not update the field %s', $GetParam{Name} ),
        );
    }

    if (
        @IsDynamicFieldInSysConfig
        && $DynamicFieldOldData{Name} ne $GetParam{Name}
        && $UpdateEntity
        )
    {
        SETTING:
        for my $SettingName (@IsDynamicFieldInSysConfig) {

            my %Setting = $SysConfigObject->SettingGet(
                Name => $SettingName,
            );

            next SETTING if !IsHashRefWithData( \%Setting );

            $Setting{EffectiveValue} =~ s/$DynamicFieldOldData{Name}/$GetParam{Name}/g;

            my $ExclusiveLockGUID = $SysConfigObject->SettingLock(
                Name   => $Setting{Name},
                Force  => 1,
                UserID => $Self->{UserID}
            );
            $Setting{ExclusiveLockGUID} = $ExclusiveLockGUID;

            my %UpdateSuccess = $SysConfigObject->SettingUpdate(
                %Setting,
                UserID => $Self->{UserID},
            );
        }

        $SysConfigObject->ConfigurationDeploy(
            Comments      => "DynamicField name change",
            DirtySettings => \@IsDynamicFieldInSysConfig,
            UserID        => $Self->{UserID},
            Force         => 1,
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

    # get objects
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $SelectDBObject     = $Kernel::OM->Get('Kernel::System::DynamicField::Driver::SelectDB');
    my $ValidObject        = $Kernel::OM->Get('Kernel::System::Valid');


    $Param{DatabaseDSN}  = $Param{Config}->{DatabaseDSN}  || $ConfigObject->Get('DatabaseDSN');
    $Param{DatabaseUser} = $Param{Config}->{DatabaseUser} || $ConfigObject->Get('DatabaseUser');
    $Param{DatabasePw}   = $Param{Config}->{DatabasePw}   || $ConfigObject->Get('DatabasePw');

    # get database type (auto detection)
    if ( $Param{DatabaseDSN} =~ /:mysql/i ) {
        $Param{DatabaseType}  = 'mysql';
    }
    elsif ( $Param{DatabaseDSN} =~ /:pg/i ) {
        $Param{DatabaseType}  = 'postgresql';
    }
    elsif ( $Param{DatabaseDSN} =~ /:oracle/i ) {
        $Param{DatabaseType}  = 'oracle';
    }
    elsif ( $Param{DatabaseDSN} =~ /:db2/i ) {
        $Param{DatabaseType}  = 'db2';
    }
    elsif ( $Param{DatabaseDSN} =~ /(mssql|sybase|sql server)/i ) {
        $Param{DatabaseType}  = 'mssql';
    }

    if(defined $Param{Config}->{StandardConnection}){
        $Param{StandardConnection}  = $Param{Config}->{StandardConnection};
    }
    else{
        $Param{StandardConnection} = 1;
    }

    if($Param{Config}->{StandardConnection} eq '0' && $Param{Config}->{DatabasePw} == '' ){
        $Param{DatabasePw}   = $Param{Config}->{DatabasePw};        
    }

    $Param{DatabaseTable}          = $Param{Config}->{DatabaseTable};
    $Param{DatabaseFieldKey}       = $Param{Config}->{DatabaseFieldKey};
    $Param{DatabaseFieldValue}     = $Param{Config}->{DatabaseFieldValue}  || $Param{Config}->{DatabaseFieldKey};
    $Param{DatabaseFieldSearch}    = $Param{Config}->{DatabaseFieldSearch} || $Param{Config}->{DatabaseFieldKey};
    $Param{ColumnAnd}              = $Param{Config}->{ColumnAnd}           || '';
    $Param{DynamicFieldAnd}        = $Param{Config}->{DynamicFieldAnd}     || '';
    $Param{DatabaseTableFreeField} = $Param{Config}->{DatabaseTableFreeField}     || '';
    $Param{MinQueryLength}         = $Param{Config}->{MinQueryLength}      || 3;
    $Param{MaxQueryResult}         = $Param{Config}->{MaxQueryResult}      || 10;
    $Param{MaxArraySize}           = $Param{Config}->{MaxArraySize}        || 1;
    $Param{CacheTTL}               = $Param{Config}->{CacheTTL}            || 0;
    $Param{CachePossibleValues}    = $Param{Config}->{CachePossibleValues} || 0;
    $Param{DefaultValues}          = $Param{Config}->{DefaultValues}       || [];

    my $DBJSONString = $JSONObject->Encode(
        Data => {
            DatabaseDSN        => $ConfigObject->Get('DatabaseDSN'),
            DatabaseUser       => $ConfigObject->Get('DatabaseUser'),
            DatabasePw         => $ConfigObject->Get('DatabasePw'),
            DatabaseType       => $Param{DatabaseType},
            StandardConnection => $Param{StandardConnection}
        },
    );

    # send data to JS
    $LayoutObject->AddJSData(
        Key   => "DataDBJS",
        Value => $DBJSONString
    );

    # header
    my $Output = $LayoutObject->Header();
    $Output   .= $LayoutObject->NavigationBar();

    # get all fields
    my $DynamicFieldList = $DynamicFieldObject->DynamicFieldListGet(
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
        push ( @DynamicfieldOrderList, $LastOrderNumber );
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
        Translation   => 0,
        Sort          => 'NumericKey',
        Class         => 'Modernize W75pc Validate_Number',
    );

    my %ValidList = $ValidObject->ValidList();

    # create the Validity select
    my $ValidityStrg = $LayoutObject->BuildSelection(
        Data         => \%ValidList,
        Name         => 'ValidID',
        SelectedID   => $Param{ValidID} || 1,
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'Modernize W50pc',
    );

    # CachePossibleValues
    my $StandardConnectionStrg = $LayoutObject->BuildSelection(
        Data         => {
            0 => 'No',
            1 => 'Yes',
        },
        Name         => 'StandardConnection',
        SelectedID   => $Param{StandardConnection},
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'Modernize W50pc',
    );

    # define as 0 to get the real value in the HTML
    my $ValueCounter = 0;

    # set PossibleValues
    my @PossibleValues;
    if ( IsArrayRefWithData( $Param{DatabaseFieldValue} ) ) {
        @PossibleValues = @{ $Param{DatabaseFieldValue} };
    }

    # output the possible values and errors within (if any)
    for my $Keys ( @PossibleValues ) {

        my ($Key) = keys %{$Keys};

        if(IsHashRefWithData($Keys)){
     	    ($Key) = keys %{$Keys};
     	}

        $ValueCounter++;

        # needed for server side validation
        my $KeyError;
        my $KeyErrorStrg;
        my $ValueError;

        # to set the correct original value
        my $KeyClone = $Key;

        # check for errors
        if ( $Param{'PossibleValueErrors'} ) {

            # check for errors on original value (empty)
            if ( $Param{'PossibleValueErrors'}->{'KeyEmptyError'}->{$Key} ) {

                # if the original value was empty it has been changed in _GetParams to a predefined
                # string and need to be set to empty again
                $KeyClone = '';

                # set the error class
                $KeyError     = 'ServerError';
                $KeyErrorStrg = Translatable('This field is required.');
            }

            # check for errors on original value (duplicate)
            elsif ( $Param{'PossibleValueErrors'}->{'KeyDuplicateError'}->{$Key} ) {

                # if the original value was empty it has been changed in _GetParams to a predefined
                # string and need to be set to the original value again
                $KeyClone = $Param{'PossibleValueErrors'}->{'KeyDuplicateError'}->{$Key};

                # set the error class
                $KeyError     = 'ServerError';
                $KeyErrorStrg = Translatable('This field value is duplicated.');
            }

            # check for error on value
            if ( $Param{'PossibleValueErrors'}->{'ValueEmptyError'}->{$Key} ) {

                # set the error class
                $ValueError = 'ServerError';
            }
        }

        my $ValueKey = '';
 	
 	    if(IsHashRefWithData($Keys)){
            $ValueKey = $Keys->{$Key};
        }

        # create a value map row
        $LayoutObject->Block(
            Name => 'ValueRow',
            Data => {
                KeyError     => $KeyError,
                KeyErrorStrg => $KeyErrorStrg || Translatable('This field is required.'),
                Key          => $KeyClone,
                ValueCounter => $ValueCounter,
                Value        => $ValueKey,
                ValueError   => $ValueError,
            },
        );
    }

    # create the possible values template
    $LayoutObject->Block(
        Name => 'ValueTemplate',
        Data => {
            %Param,
        },
    );

    # CachePossibleValues
    my $CachePossibleValuesStrg = $LayoutObject->BuildSelection(
        Data         => {
            0 => 'No',
            1 => 'Yes',
        },
        Name         => 'CachePossibleValues',
        SelectedID   => $Param{CachePossibleValues},
        PossibleNone => 0,
        Translation  => 1,
        Class        => 'Modernize W50pc',
    );

    # DefaultValues
    my $DefaultValuesCount = 0;
    for my $Key ( @{ $Param{DefaultValues} } ) {
        next if (!$Key);
        $DefaultValuesCount++;

        my $Label = $SelectDBObject->ValueLookup(
            Key                => $Key,
            DynamicFieldConfig => {
                Name   => $Param{Name},
                Config => {
                    DatabaseDSN        => $Param{DatabaseDSN},
                    DatabaseUser       => $Param{DatabaseUser},
                    DatabasePw         => $Param{DatabasePw},
                    DatabaseType       => $Param{DatabaseType},
                    DatabaseTable      => $Param{DatabaseTable},
                    DatabaseFieldKey   => $Param{DatabaseFieldKey},
                    DatabaseFieldValue => $Param{DatabaseFieldValue},
                    CacheTTL           => $Param{CacheTTL},
                },
            },
        );

        $LayoutObject->Block(
            Name => 'DefaultValue',
            Data => {
                DefaultValue        => $Key,
                Label               => $Label,
                DefaultValueCounter => $DefaultValuesCount
            },
        );
    }

    # Internal fields can not be deleted and name should not change.
    if ( $Param{InternalField} ) {
        $LayoutObject->Block(
            Name => 'InternalField',
            Data => {%Param},
        );
    }
    
    my $JSONString = $JSONObject->Encode(
        Data => {
            DefaultValuesCount  => $DefaultValuesCount,
            DefaultValueCounter => $DefaultValuesCount
        },
    );

    # send data to JS
    $LayoutObject->AddJSData(
        Key   => "DataJS",
        Value => $JSONString
    );

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminDynamicFieldSelectDB',
        Data => {
            %Param,
            ValidityStrg            => $ValidityStrg,
            DynamicFieldOrderStrg   => $DynamicFieldOrderStrg,
            CachePossibleValuesStrg => $CachePossibleValuesStrg,
            StandardConnectionStrg  => $StandardConnectionStrg,
            ValueCounter            => $ValueCounter,
        }
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _DefaultValueSearch {
    my ( $Self, %Param ) = @_;

    # get objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $EncodeObject = $Kernel::OM->Get('Kernel::System::Encode');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    my @PossibleValues;

    # get search
    my $Search = $ParamObject->GetParam( Param => 'Search' ) || '';
    $Search = '*' . $Search . '*';
    $EncodeObject->EncodeInput( \$Search );

    # get DB config
    my $DatabaseDSN         = $ParamObject->GetParam( Param => 'DatabaseDSN' )         || '';
    my $DatabaseUser        = $ParamObject->GetParam( Param => 'DatabaseUser' )        || '';
    my $DatabasePw          = $ParamObject->GetParam( Param => 'DatabasePw' )          || '';
    my $DatabaseType        = lc $ParamObject->GetParam( Param => 'DatabaseType' )     || '';
    my $DatabaseFieldKey    = $ParamObject->GetParam( Param => 'DatabaseFieldKey' )    || '';
    my $DatabaseFieldSearch = $ParamObject->GetParam( Param => 'DatabaseFieldSearch' ) || $DatabaseFieldKey;
    my $DatabaseTable       = $ParamObject->GetParam( Param => 'DatabaseTable' )       || '';

    my $PossibleValues = $Self->_GetPossibleValues();

    my @Values = ();
    for my $Value (@{$PossibleValues}){
        my ($Key) = %{$Value};
        push @Values, $Key;
    }

    my $DatabaseFieldValue = join( ',', @Values ) || $DatabaseFieldKey;

    my $SearchPrefix        = '*';
    my $SearchSuffix        = '*';
    my $CaseSensitive       = 0;

    my $DFSelectDBObject;
    if (
        $DatabaseDSN
        && $DatabaseUser
    ) {
        $DFSelectDBObject = Kernel::System::DFSelectDB->new(
            %{ $Self },
            DatabaseDSN  => $DatabaseDSN,
            DatabaseUser => $DatabaseUser,
            DatabasePw   => $DatabasePw,
            Type         => $DatabaseType,
        );
    }

    if (
        $DFSelectDBObject
        && $DatabaseFieldKey
        && $DatabaseFieldValue
        && $DatabaseFieldSearch
        && $DatabaseTable
    ) {

        # get used entries
        my @Entries = $ParamObject->GetArray( Param => 'DefaultValues' );

        $Search         =~ s/\*/%/gi;
        my $QuotedValue = $DFSelectDBObject->Quote($Search);         

        my @SearchFields = split( ';', $DatabaseFieldSearch );

        my $QueryCondition = $DFSelectDBObject->QueryCondition(
            Key           => \@SearchFields,
            Value         => $Search,
            SearchPrefix  => $SearchPrefix,
            SearchSuffix  => $SearchSuffix,
            CaseSensitive => $CaseSensitive,
        );

        my $SQL = 'SELECT '
            . $DatabaseFieldKey
            . ', '
            . $DatabaseFieldValue
            . ' FROM '
            . $DatabaseTable
            . ' WHERE '
            . $QueryCondition;

        my $Success = $DFSelectDBObject->Prepare(
            SQL   => $SQL,
        );

        if ( !$Success ) {

            # build JSON output
            my $JSON = $LayoutObject->JSONEncode(
                Data => {
                    Error => "Message: Can't connect to Database"
                },
            );

            # send JSON response
            return $LayoutObject->Attachment(
                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                Content     => $JSON,
                Type        => 'inline',
                NoCache     => 1,
            );
        }

        my $MaxCount = 1;
        RESULT:
        while (my @Row = $DFSelectDBObject->FetchrowArray()) {

            my $Key    = $Row[0];
            next RESULT if ( grep { my $Temp eq $Key } @Entries );

            my $Value  = $Row[1];

            if(scalar @Row > 3){

                $Value = '';
                
                my $Size = scalar @Row - 2;

                for(1..$Size){

                    $Value .= ' ' . $Row[$_];
                }
            }
            
            my $Title = $Value;

            push @PossibleValues, {
                Key    => $Key,
                Value  => $Value,
                Title  => $Title,
            };
            last RESULT if ($MaxCount == 25);
            $MaxCount++;
        }
    }

    # build JSON output
    my $JSON = $LayoutObject->JSONEncode(
        Data => \@PossibleValues,
    );

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _GetPossibleValues {
    my ( $Self, %Param ) = @_;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $PossibleValueConfig = [];

    # get parameters from web browser
    # get ValueCounters
    my $ValueCounter          = $ParamObject->GetParam( Param => 'ValueCounter' ) || 0;
    my $EmptyValueCounter     = 0;

    # get possible values
    my $Values;
    VALUEINDEX:
    for my $ValueIndex ( 1 .. $ValueCounter ) {
        my $Key = $ParamObject->GetParam( Param => 'Key' . '_' . $ValueIndex );
        $Key = ( defined $Key ? $Key : '' );

        # check if key was deleted by the user and skip it
        next VALUEINDEX if $Key eq $Self->{DeletedString};

        # check if the original value is empty
        if ( $Key eq '' ) {

            # change the empty value to a predefined string
            $Key = $Self->{EmptyString} . int $EmptyValueCounter;
            $EmptyValueCounter++;
        }

        my $Value = $ParamObject->GetParam( Param => 'Value' . '_' . $ValueIndex );
        $Value = ( defined $Value ? $Value : '' );
        push @{$PossibleValueConfig}, {
            $Key => $Value
        };
    }

    return $PossibleValueConfig;
}

1;