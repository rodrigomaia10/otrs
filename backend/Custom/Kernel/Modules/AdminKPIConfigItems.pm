# --
# Kernel/Modules/AdminKPIConfigItems.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * poliveira@serviceup.com.br
# --

package Kernel::Modules::AdminKPIConfigItems;

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
    if( $Self->{Subaction} eq 'AjaxUpdateToAttribute' ){
        
        return $Self->_AjaxUpdateToAttribute(
            %Param,
        );
    }

    return $LayoutObject->ErrorScreen(
        Message => Translatable('Undefined subaction.'),
    );
}

sub _AjaxUpdateToAttribute {
    my ( $Self, %Param ) = @_;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    my %GetParam;
    my $JSON =  '{}';

    $GetParam{ClassID} = $ParamObject->GetParam( Param => 'ClassID' );

    # get current definition
    my $XMLDefinition = $ConfigItemObject->DefinitionGet(
        ClassID => $GetParam{ClassID},
    );

    # abort, if no definition is defined
    if ( !$XMLDefinition->{DefinitionID} ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'No definition was defined for class %s!', $GetParam{ClassID} ),
            Comment => Translatable('Please contact the administrator.'),
        );
    }

    my @XMLAttributes = (
        {
            Key   => 'Number',
            Value => Translatable('Number'),
        },
        {
            Key   => 'Name',
            Value => Translatable('Name'),
        },
        {
            Key   => 'DeplStateIDs',
            Value => Translatable('Deployment State'),
        },
        {
            Key   => 'InciStateIDs',
            Value => Translatable('Incident State'),
        },
    );

    # get attributes to include in attributes string
    if ( $XMLDefinition->{Definition} ) {
        $Self->_XMLSearchAttributesGet(
            XMLDefinition => $XMLDefinition->{DefinitionRef},
            XMLAttributes => \@XMLAttributes,
        );
    }
   
    my %HashOfXMLDefinition;

    for my $Attribute (@XMLAttributes){
        $HashOfXMLDefinition{$Attribute->{Key}} = $LayoutObject->{LanguageObject}->Translate($Attribute->{Value});
    }

    $Self->_XMLSearchFormOutput(
        XMLDefinition => $XMLDefinition->{DefinitionRef},
        XMLAttributes => \@XMLAttributes,
        GetParam      => \%GetParam,
    );

     # get deployment state list
    my $DeplStateList = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::DeploymentState',
    );

    # generate dropdown for selecting the wanted deployment states
    my $CurDeplStateOptionStrg = $LayoutObject->BuildSelection(
        Data       => $DeplStateList,
        Name       => 'DeplStateIDsValid',
        SelectedID => $GetParam{DeplStateIDs} || [],
        Size       => 5,
        Multiple   => 1,
        Class      => 'Modernize',
    );

    # get incident state list
    my $InciStateList = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::Core::IncidentState',
    );

    # generate dropdown for selecting the wanted incident states
    my $CurInciStateOptionStrg = $LayoutObject->BuildSelection(
        Data       => $InciStateList,
        Name       => 'InciStateIDsValid',
        SelectedID => $GetParam{InciStateIDs} || [],
        Size       => 5,
        Multiple   => 1,
        Class      => 'Modernize',
    );

    # output template to attributes
    my $Output = $LayoutObject->Output(
        TemplateFile => 'ConfigItemAttributes',
        Data => {
            CurDeplStateOptionStrg    => $CurDeplStateOptionStrg,
            CurInciStateOptionStrg    => $CurInciStateOptionStrg,
        }
    );
    
    my $JSONString = $JSONObject->Encode(
        Data     => \%HashOfXMLDefinition,
        SortKeys => 1
    );

    # build JSON output
    $JSON = $LayoutObject->JSONEncode(
        Data => {
            JSONString => $JSONString,
            JSONStringAttribute => $Output,
        },
    );

    return $LayoutObject->Attachment(
        NoCache     => 1,
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
    );

}

sub _XMLSearchFormOutput {
    my ( $Self, %Param ) = @_;

    my %GetParam = %{ $Param{GetParam} };

    # check needed stuff
    return if !$Param{XMLDefinition};
    return if ref $Param{XMLDefinition} ne 'ARRAY';
    return if ref $Param{XMLAttributes} ne 'ARRAY';

    $Param{Level} ||= 0;
    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {
   
        # set prefix
        my $InputKey = $Item->{Key};
        my $Name     = $Item->{Name};
        if ( $Param{Prefix} ) {
            $InputKey = $Param{Prefix} . '::' . $InputKey;
            $Name     = $Param{PrefixName} . '::' . $Name;
        }

        # output attribute, if marked as searchable
        if ( $Item->{Searchable} ) {
            my $Value;

            # date type fields must to get all date parameters
            if ( $Item->{Input}->{Type} eq 'Date' ) {
                $Value =
                    {
                    $InputKey                      => $GetParam{$InputKey},
                    $InputKey . '::TimeStart::Day' => $GetParam{ $InputKey . '::TimeStart::Day' },
                    $InputKey
                        . '::TimeStart::Month' => $GetParam{ $InputKey . '::TimeStart::Month' },
                    $InputKey . '::TimeStart::Year' => $GetParam{ $InputKey . '::TimeStart::Year' },
                    $InputKey . '::TimeStop::Day'   => $GetParam{ $InputKey . '::TimeStop::Day' },
                    $InputKey . '::TimeStop::Month' => $GetParam{ $InputKey . '::TimeStop::Month' },
                    $InputKey . '::TimeStop::Year'  => $GetParam{ $InputKey . '::TimeStop::Year' },
                    } || '';
            }

            # date-time type fields must get all date and time parameters
            elsif ( $Item->{Input}->{Type} eq 'DateTime' ) {
                $Value =
                    {
                    $InputKey => $GetParam{$InputKey},
                    $InputKey
                        . '::TimeStart::Minute' => $GetParam{ $InputKey . '::TimeStart::Minute' },
                    $InputKey . '::TimeStart::Hour' => $GetParam{ $InputKey . '::TimeStart::Hour' },
                    $InputKey . '::TimeStart::Day'  => $GetParam{ $InputKey . '::TimeStart::Day' },
                    $InputKey
                        . '::TimeStart::Month' => $GetParam{ $InputKey . '::TimeStart::Month' },
                    $InputKey . '::TimeStart::Year' => $GetParam{ $InputKey . '::TimeStart::Year' },
                    $InputKey
                        . '::TimeStop::Minute' => $GetParam{ $InputKey . '::TimeStop::Minute' },
                    $InputKey . '::TimeStop::Hour'  => $GetParam{ $InputKey . '::TimeStop::Hour' },
                    $InputKey . '::TimeStop::Day'   => $GetParam{ $InputKey . '::TimeStop::Day' },
                    $InputKey . '::TimeStop::Month' => $GetParam{ $InputKey . '::TimeStop::Month' },
                    $InputKey . '::TimeStop::Year'  => $GetParam{ $InputKey . '::TimeStop::Year' },
                    } || '';
            }

            # other kinds of fields can get its value directly
            else {
                $Value = $GetParam{$InputKey} || '';
            }

            # get layout object
            my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
            my $InputString;
            if($Param{Action} eq 'Edit'){ 
            
                # create search input element
                $InputString = $LayoutObject->ITSMConfigItemSearchInputCreate(
                    Key   => $InputKey.'Valid',
                    Item  => $Item,
                    Value => $Value,
                );             
               
                next ITEM if !$Value || $Value eq '';
                next ITEM if ref $Value eq 'ARRAY' && ! IsArrayRefWithData( $Value );

                if ( $Item->{Input}->{Type} eq 'Date' ) {
                    if($Value->{$InputKey.'Date'}){
                        $LayoutObject->Block(
                            Name => 'AttributeRow',
                            Data => {
                                Key         => $InputKey,
                                Name        => $Name,
                                Description => $Item->{Description} || $Item->{Name},
                                InputString => $InputString,
                            },
                        );        
                    }
                }            
                elsif ( $Item->{Input}->{Type} eq 'DateTime' ) {  
                    if($Value->{$InputKey.'DateTime'}){
                        $LayoutObject->Block(
                            Name => 'AttributeRow',
                            Data => {
                                Key         => $InputKey,
                                Name        => $Name,
                                Description => $Item->{Description} || $Item->{Name},
                                InputString => $InputString,
                            },
                        );        
                    }
                }else{
                    # output attribute row
                    $LayoutObject->Block(
                        Name => 'AttributeRow',
                        Data => {
                            Key         => $InputKey,
                            Name        => $Name,
                            Description => $Item->{Description} || $Item->{Name},
                            InputString => $InputString,
                        },
                    );      
                }
                
            }else{
                $InputString = $LayoutObject->ITSMConfigItemSearchInputCreate(
                    Key   => $InputKey,
                    Item  => $Item,
                    Value => $Value,
                );
        
                # output attribute row
                $LayoutObject->Block(
                    Name => 'AttributeRow',
                    Data => {
                        Key         => $InputKey,
                        Name        => $Name,
                        Description => $Item->{Description} || $Item->{Name},
                        InputString => $InputString,
                    },
                );
            }

            push @{ $Param{XMLAttributes} }, {
                Key   => $InputKey,
                Value => $Name,
            };
        }

        next ITEM if !$Item->{Sub};

        # start recursion, if "Sub" was found
        $Self->_XMLSearchFormOutput(
            XMLDefinition => $Item->{Sub},
            XMLAttributes => $Param{XMLAttributes},
            Level         => $Param{Level} + 1,
            Prefix        => $InputKey,
            PrefixName    => $Name,
            GetParam      => \%GetParam,
            Action        => $Param{Action} || '',
        );
    }

    return 1;
}

sub _XMLSearchAttributesGet {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    return if !$Param{XMLDefinition};
    return if ref $Param{XMLDefinition} ne 'ARRAY';
    return if ref $Param{XMLAttributes} ne 'ARRAY';

    $Param{Level} ||= 0;
    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {

        # set prefix
        my $InputKey = $Item->{Key};
        my $Name     = $Item->{Name};
        if ( $Param{Prefix} ) {
            $InputKey = $Param{Prefix} . '::' . $InputKey;
            $Name     = $Param{PrefixName} . '::' . $Name;
        }

        # store attribute, if marked as searchable
        if ( $Item->{Searchable} ) {
            push @{ $Param{XMLAttributes} }, {
                Key   => $InputKey,
                Value => $Name,
            };
        }

        next ITEM if !$Item->{Sub};

        # start recursion, if "Sub" was found
        $Self->_XMLSearchAttributesGet(
            XMLDefinition => $Item->{Sub},
            XMLAttributes => $Param{XMLAttributes},
            Level         => $Param{Level} + 1,
            Prefix        => $InputKey,
            PrefixName    => $Name,
        );
    }

    return 1;
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

    my $ParamObject      = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $KPIObject        = $Kernel::OM->Get('Kernel::System::KPI');
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

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
    $GetParam{ClassID} = $ParamObject->GetParam( Param => 'SearchClassID' );

    # get current definition
    my $XMLDefinition = $ConfigItemObject->DefinitionGet(
        ClassID => $GetParam{ClassID},
    );

    # abort, if no definition is defined
    if ( !$XMLDefinition->{DefinitionID} ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'No definition was defined for class %s!', $GetParam{ClassID} ),
            Comment => Translatable('Please contact the administrator.'),
        );
    }

    my @XMLAttributes = (
        {
            Key   => 'Number',
            Value => Translatable('Number'),
        },
        {
            Key   => 'Name',
            Value => Translatable('Name'),
        },
        {
            Key   => 'DeplStateIDs',
            Value => Translatable('Deployment State'),
        },
        {
            Key   => 'InciStateIDs',
            Value => Translatable('Incident State'),
        },
    );

    # get attributes to include in attributes string
    if ( $XMLDefinition->{Definition} ) {
        $Self->_XMLSearchAttributesGet(
            XMLDefinition => $XMLDefinition->{DefinitionRef},
            XMLAttributes => \@XMLAttributes,
        );
    }

    my %GetParamAttributes;

    my @ValuesDepl = $ParamObject->GetArray( Param => "DeplStateIDsValidValid" );
    $GetParamAttributes{DeplStateIDs} = \@ValuesDepl;

    my @ValuesInci = $ParamObject->GetArray( Param => "InciStateIDsValidValid" );
    $GetParamAttributes{InciStateIDs} = \@ValuesInci;

    # Get Param to attributes of config item and add on %GetParamAttributes
    $Self->_GetParams(
        %Param,
        XMLDefinition => $XMLDefinition->{DefinitionRef},
        GetParam => \%GetParamAttributes
    );

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
        ObjectType => "Config Items",
        Search   => \%GetParamAttributes,
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

sub _GetParams {
    my ( $Self, %Param) = @_;

    ITEM:
    for my $Item (@{$Param{XMLDefinition}}){

        # get search form data
        my $Values = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->ITSMConfigItemSearchFormDataGet(
            Key   => $Item->{Key}.'Valid',
            Item  => $Item,
            Value => $Param{$Item->{Key}},
        );

        $Param{GetParam}->{$Item->{Key}} = $Values;

        next ITEM if !$Item->{Sub};

        # start recursion, if "Sub" was found
        $Self->_GetParams(
            %Param,
            XMLDefinition => $Item->{Sub}
        );
    }
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
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

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
    $GetParam{ClassID} = $ParamObject->GetParam( Param => 'SearchClassID' );

    # get current definition
    my $XMLDefinition = $ConfigItemObject->DefinitionGet(
        ClassID => $GetParam{ClassID},
    );

    # abort, if no definition is defined
    if ( !$XMLDefinition->{DefinitionID} ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'No definition was defined for class %s!', $GetParam{ClassID} ),
            Comment => Translatable('Please contact the administrator.'),
        );
    }

    my @XMLAttributes = (
        {
            Key   => 'Number',
            Value => Translatable('Number'),
        },
        {
            Key   => 'Name',
            Value => Translatable('Name'),
        },
        {
            Key   => 'DeplStateIDs',
            Value => Translatable('Deployment State'),
        },
        {
            Key   => 'InciStateIDs',
            Value => Translatable('Incident State'),
        },
    );

    # get attributes to include in attributes string
    if ( $XMLDefinition->{Definition} ) {
        $Self->_XMLSearchAttributesGet(
            XMLDefinition => $XMLDefinition->{DefinitionRef},
            XMLAttributes => \@XMLAttributes,
        );
    }

    my %GetParamAttributes;

    my @ValuesDepl = $ParamObject->GetArray( Param => "DeplStateIDsValid" );
    $GetParamAttributes{DeplStateIDs} = \@ValuesDepl;

    my @ValuesInci = $ParamObject->GetArray( Param => "InciStateIDsValid" );
    $GetParamAttributes{InciStateIDs} = \@ValuesInci;

    # Get Param to attributes of config item, and add in %GetParamAttributes
    $Self->_GetParams(
        %Param,
        XMLDefinition => $XMLDefinition->{DefinitionRef},
        GetParam => \%GetParamAttributes
    );

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
        ObjectType => "Config Items",
        Search   => \%GetParamAttributes,

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

    # get general catalog object
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    # get class list
    my $ClassList = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::Class',
    );

    # get config item object
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    my $ClassOptionStrg = $LayoutObject->BuildSelection(
        Data         => $ClassList,
        Name         => 'SearchClassID',
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize',
        SelectedID   => $Param{ClassID} || '',
    );

    my %AttributesList;

    if( $Param{ClassID} ){
        # get current definition
        my $XMLDefinition = $ConfigItemObject->DefinitionGet(
            ClassID => $Param{ClassID},
        );

        # abort, if no definition is defined
        if ( !$XMLDefinition->{DefinitionID} ) {
            return $LayoutObject->ErrorScreen(
                Message =>
                    $LayoutObject->{LanguageObject}->Translate( 'No definition was defined for class %s!', $Param{ClassID} ),
                Comment => Translatable('Please contact the administrator.'),
            );
        }

        my @XMLAttributes = (
            {
                Key   => 'Number',
                Value => Translatable('Number'),
            },
            {
                Key   => 'Name',
                Value => Translatable('Name'),
            },
            {
                Key   => 'DeplStateIDs',
                Value => Translatable('Deployment State'),
            },
            {
                Key   => 'InciStateIDs',
                Value => Translatable('Incident State'),
            },
        );

        # get attributes to include in attributes string
        if ( $XMLDefinition->{Definition} ) {
            $Self->_XMLSearchAttributesGet(
                XMLDefinition => $XMLDefinition->{DefinitionRef},
                XMLAttributes => \@XMLAttributes,
            );
        }

        for my $Attribute (@XMLAttributes){
            $AttributesList{$Attribute->{Key}} = $LayoutObject->{LanguageObject}->Translate($Attribute->{Value});
        }

        $Self->_XMLSearchFormOutput(
            XMLDefinition => $XMLDefinition->{DefinitionRef},
            XMLAttributes => \@XMLAttributes,
            GetParam      => $Param{Search},
            Action      => 'Edit',
        );
    }
    
    my $AttributesStrg = $LayoutObject->BuildSelection(
        Data         => \%AttributesList,
        Name         => 'Attribute',
        SelectedID   => $Param{Attribute} || '',
        PossibleNone => 1,
        Translation  => 1,
        Class        => 'Modernize W50pc',
    );

    if($Param{Search}->{DeplStateIDs}){

        # get deployment state list
        my $DeplStateList = $GeneralCatalogObject->ItemList(
            Class => 'ITSM::ConfigItem::DeploymentState',
        );

        # generate dropdown for selecting the wanted deployment states
        my $CurDeplStateOptionStrg = $LayoutObject->BuildSelection(
            Data       => $DeplStateList,
            Name       => 'DeplStateIDsValid',
            SelectedID => $Param{Search}->{DeplStateIDs} || [],
            Size       => 5,
            Multiple   => 1,
            Class      => 'Modernize',
        );
        
        $LayoutObject->Block(
            Name => 'AttributeRowDeplState',
            Data => {
                CurDeplStateOptionStrg         => $CurDeplStateOptionStrg,
            },
        );
    }

    if($Param{Search}->{InciStateIDs}){

        # get incident state list
        my $InciStateList = $GeneralCatalogObject->ItemList(
            Class => 'ITSM::Core::IncidentState',
        );

        # generate dropdown for selecting the wanted incident states
        my $CurInciStateOptionStrg = $LayoutObject->BuildSelection(
            Data       => $InciStateList,
            Name       => 'InciStateIDsValid',
            SelectedID => $Param{Search}->{InciStateIDs} || [],
            Size       => 5,
            Multiple   => 1,
            Class      => 'Modernize',
        );

        $LayoutObject->Block(
            Name => 'AttributeRowInciState',
            Data => {
                CurInciStateOptionStrg         => $CurInciStateOptionStrg,
            },
        );
    }

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminKPIConfigItems',
        Data         => {
            %Param,
            ReturnFormatStrg => $ReturnFormatStrg,
            ValidityStrg => $ValidityStrg,
            GroupsStrg => $GroupsStrg,
			ClassOptionStrg =>  $ClassOptionStrg,
            AttributesStrg  => $AttributesStrg,
        }
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}


1;