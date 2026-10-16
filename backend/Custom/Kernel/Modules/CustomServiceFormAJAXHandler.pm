# --
# Kernel/Modules/CustomServiceFormAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * gesquetini@beonup.com.br
# * ghidalgo@serviceup.com.br
# * ccresencio@serviceup.com.br
# --

package Kernel::Modules::CustomServiceFormAJAXHandler;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

use base qw(Kernel::System::EventHandler);

use URI::Escape;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # init of event handler
    $Self->EventHandlerInit(
        Config => 'CustomServiceForm::EventModulePost',
    );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # create needed objects
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $ServiceFormHTML = '';

	my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || '';

    # get HTML
    if ( $Self->{Subaction} eq 'DisplayFormAJAX' ) {
  
        # get params
        my $ServiceID = $ParamObject->GetParam( Param => 'ServiceID' ) || '';

        my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

		my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
      
		my $FormSearch = $CustomFormObject->CustomFormSearch(
			ServiceID   => $ServiceID,
		);

        my %DataResponseNoForm = (
            FormHTML    => 'No Form.'
        );

		if (!$FormSearch) {

			# send HTML response
            my $JSON = $JSONObject->Encode(
                Data => \%DataResponseNoForm
            );

            return $LayoutObject->Attachment(
                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                Content     => $JSON,
                Type        => 'inline',
                NoCache     => 1,
            );
		}

		my ($Name, $Interface) = split /OTRS/, $Self->{SessionName};

		my %CustomDynamicForm = $CustomFormObject->CustomFormGet(
			FormID => $FormSearch,
            UserID => $Self->{UserID}
		);

		if($Interface ne $CustomDynamicForm{Interface} && $CustomDynamicForm{Interface} ne 'OnBothInterfaces') {

			# send HTML response
			my $JSON = $JSONObject->Encode(
                Data => \%DataResponseNoForm
            );

            return $LayoutObject->Attachment(
                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                Content     => $JSON,
                Type        => 'inline',
                NoCache     => 1,
            );
		}

		my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
			FormID => $FormSearch,
		);

		my %Error         = ();
		my %ErrorMessages = ();
        my $HideAttachment = 0;

		my $GetParam = $Self->_GetParam(
			ShowFields => $Fields,
		);

		my $AJAXUpdatableFields = $Self->_GetAJAXUpdatableFields(
			UpdateFields => $Fields,
		);

        # Loop through ActivityDialogFields and render their output
		DYNAMICFIELD:
		for my $CurrentField ( @{$Fields} ) {

			if ( !IsHashRefWithData($CurrentField) ) {

				my $Message = $LayoutObject->{LanguageObject}->Translate(
					'Can\'t get data for Field "%s" of ActivityDialog "%s"!',
					$CurrentField->{Name}
				);

				$LayoutObject->FatalError(
					Message => $Message,
				);
			}

			# render DynamicFields
			if ( $CurrentField->{Name} =~ m{^DynamicField_(.*)}xms ) {

				my $DynamicFieldName = $1;

                my $OldAction = $ParamObject->GetParam( Param => 'OldAction' );

				my $Response         = $Self->_RenderDynamicField(
					FieldName           => $DynamicFieldName,
					DescriptionShort    => $CurrentField->{DescriptionShort},
					Error               => \%Error || {},
					ErrorMessages       => \%ErrorMessages || {},
					GetParam            => $GetParam,
					Display             => $CurrentField->{Display},
					Mask                => $CurrentField->{Mask},
					AJAXUpdatableFields => $AJAXUpdatableFields,
					TicketID            => $TicketID,
                    OldAction           => $OldAction,
				);

                my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $DynamicFieldName,
                );

                if ($DynamicField->{FieldType} eq "FileSystem"){
                    $HideAttachment = 1;
                }

				if ( !$Response->{Success} ) {

					# does not show header and footer again
					if ( $Self->{IsMainWindow} ) {
						return $LayoutObject->Error(
							Message => $Response->{Message},
						);
					}

					$LayoutObject->FatalError(
						Message => $Response->{Message},
					);
				}

				$ServiceFormHTML .= $Response->{HTML};
			}
		}

        my %DataResponse = (
            FormHTML        => $ServiceFormHTML,
            Description     => $CustomDynamicForm{Description} || "",
            UserType        => $Self->{UserType},
            HideAttachment  => $HideAttachment
        );

        # my $JSON = $JSONObject->Encode(
        #     Data => \%DataResponse
        # );

        my $JSON = $LayoutObject->JSONEncode(
            Data => \%DataResponse
        );

		return $LayoutObject->Attachment(
			ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
			Content     => $JSON,
			Type        => 'inline',
			NoCache     => 1,
		);
    }
	# get HTML
    elsif ( $Self->{Subaction} eq 'AJAXUpdate' ) {
       
		my $ServiceID = $ParamObject->GetParam( Param => 'ServiceID' ) || '';

		my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

		my $FormSearch = $CustomFormObject->CustomFormSearch(
			ServiceID   => $ServiceID,
		);

		if (!$FormSearch) {

			# send HTML response
			return $LayoutObject->Attachment(
				ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
				Content     => 'No Form.',
				NoCache     => 1,
			);
		}

		my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
			FormID => $FormSearch,
		);

		return $Self->_RenderAjax(
            UpdateFields  => $Fields,
			TicketID      => $TicketID,
        );

	}
}

sub _RenderDynamicField {
    my ( $Self, %Param ) = @_;
   
    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

    for my $Needed (qw(FieldName)) {
        if ( !$Param{$Needed} ) {
            return {
                Success => 0,
                Message => $LayoutObject->{LanguageObject}
                    ->Translate( 'Parameter %s is missing in %s.', $Needed, '_RenderDynamicField' ),
            };
        }
    }

    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => 'Ticket',
    );

    my $DynamicFieldConfig = ( grep { $_->{Name} eq $Param{FieldName} } @{$DynamicField} )[0];

    if ( !IsHashRefWithData($DynamicFieldConfig) ) {

        my $Message = "DynamicFieldConfig missing for field: $Param{FieldName}, or is not a Ticket Dynamic Field!";

        # log error but does not stop the execution as it could be an old Article
        # DynamicField, see bug#11666
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $Message,
        );

        return {
            Success => 1,
            HTML    => '',
        };
    }

    my $PossibleValuesFilter;

    # get dynamic field backend object
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
        DynamicFieldConfig => $DynamicFieldConfig,
        Behavior           => 'IsACLReducible',
    );

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    if ($IsACLReducible) {

        # get PossibleValues
        my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
            DynamicFieldConfig => $DynamicFieldConfig,
        );

        # All Ticket DynamicFields
        # used for ACL checking
        my %DynamicFieldCheckParam = map { $_ => $Param{GetParam}{$_} }
            grep {m{^DynamicField_}xms} ( keys %{ $Param{GetParam} } );

        # check if field has PossibleValues property in its configuration
        if ( IsHashRefWithData($PossibleValues) ) {

            # convert possible values key => value to key => key for ACLs using a Hash slice
            my %AclData = %{$PossibleValues};

            @AclData{ keys %AclData } = keys %AclData;

			my %UserType = ();

			if($Self->{UserType} eq 'User') {
				$UserType{UserID} = $Self->{UserID};
			}
			else{
				$UserType{CustomerUserID} = $Self->{UserID};
			}

            # set possible values filter from ACLs
            my $ACL = $TicketObject->TicketAcl(
                %{ $Param{GetParam} },
                DynamicField  => \%DynamicFieldCheckParam,
                Action        => $Param{OldAction} || $Self->{Action},
                ReturnType    => 'Ticket',
                ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                Data          => \%AclData,
                %UserType,
            );

            if ($ACL) {
                my %Filter = $TicketObject->TicketAclData();

                # convert Filer key => key back to key => value using map
                %{$PossibleValuesFilter} = map { $_ => $PossibleValues->{$_} } keys %Filter;
            }
        }
    }

    my $ServerError;

    if ( IsHashRefWithData( $Param{Error} ) ) {
        if (
            defined $Param{Error}->{ $Param{FieldName} }
            && $Param{Error}->{ $Param{FieldName} } ne ''
            )
        {
            $ServerError = 1;
        }
    }

    my $ErrorMessage = '';

    if ( IsHashRefWithData( $Param{ErrorMessages} ) ) {
        if (
            defined $Param{ErrorMessages}->{ $Param{FieldName} }
            && $Param{ErrorMessages}->{ $Param{FieldName} } ne ''
            )
        {
            $ErrorMessage = $Param{ErrorMessages}->{ $Param{FieldName} };
        }
    }

    my $DefaultValue;

    if( ($Param{GetParam}{ 'DynamicField_' . $Param{FieldName} } eq "" || $Param{GetParam}{ 'DynamicField_' . $Param{FieldName} } =~ /^ *$/) &&
        exists $DynamicFieldConfig->{Config}->{DefaultValue}){
        $DefaultValue = $DynamicFieldConfig->{Config}->{DefaultValue};
    }
    else{
        $DefaultValue = $Param{GetParam}{ 'DynamicField_' . $Param{FieldName} };
    }
   
    my $DynamicFieldHTML = $DynamicFieldBackendObject->EditFieldRender(
        DynamicFieldConfig   => $DynamicFieldConfig,
        PossibleValuesFilter => $PossibleValuesFilter,
        Value                => $DefaultValue,
        LayoutObject         => $LayoutObject,
        ParamObject          => $Kernel::OM->Get('Kernel::System::Web::Request'),
        AJAXUpdate           => 0,
        Mandatory            => $Param{Display} == 2,
        UpdatableFields      => $Param{AJAXUpdatableFields},
        ServerError          => $ServerError,
        ErrorMessage         => $ErrorMessage,
        Calendar             => 1,
    );

    my %Data = (
        Name    => $DynamicFieldConfig->{Name},
        Label   => $DynamicFieldHTML->{Label},
        Content => $DynamicFieldHTML->{Field},
        Display => !$Param{Display} ? 'Hidden' : '',
    );

    $LayoutObject->Block(
        Name => 'rw:DynamicField',
        Data => \%Data,
    );

    if ( $Param{DescriptionShort} ) {
        $LayoutObject->Block(
            Name => 'rw:DynamicField:DescriptionShort',
            Data => {
                DescriptionShort => $Param{DescriptionShort},
            },
        );
    }

	#get code javascript
	$LayoutObject->Block(
		Name => 'FooterJS',
	);

	my $FieldSelector = '#DynamicField_' . $Param{FieldName};
	my $FieldName = 'DynamicField_'.$Param{FieldName};
	my $UpdateFields = '"'.join ('","', @{ $Param{AJAXUpdatableFields} }).'"';

	# add js to call FormUpdate()
	$LayoutObject->AddJSOnDocumentComplete( Code => <<"EOF");

\$('$FieldSelector').bind('change', function (Event) {  
	var ServiceID = \$('#ServiceID').val();
    Core.Agent.CustomServiceForm.ServiceFormUpdate(ServiceID, 'AJAXUpdate', '$FieldName', [ $UpdateFields ]);
});
Core.App.Subscribe('Event.AJAX.FormUpdate.Callback', function(Data) {
    var FieldName = '$FieldName';
    if (Data[FieldName] && \$('#' + FieldName).hasClass('DynamicFieldWithTreeView')) {
        Core.UI.TreeSelection.RestoreDynamicFieldTreeView(\$('#' + FieldName), Data[FieldName], '' , 1);
    }
});
EOF

	if ( $Param{Mask} ) {
        $LayoutObject->AddJSOnDocumentComplete( Code => <<"EOF");
	\$("#DynamicField_$DynamicFieldConfig->{Name}").keydown(function(){
		\$('#DynamicField_$DynamicFieldConfig->{Name}').mask('$Param{Mask}');
	});
EOF
    }

    my $JSONStringRegex;

    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    #To treat as dynamic field regex
    my @ArrayOfRegex = $DynamicFieldConfig->{Config}->{RegExList};

    if($DynamicFieldConfig->{Config}->{RegExList}){

        my @ArrayOfRegexValue;

        for my  $ValueHash ( @ArrayOfRegex){

            for my $Value ( @$ValueHash) {

                if($Value->{Value}){
                    push @ArrayOfRegexValue, {
                        Value        => $Value->{Value},
                        ErrorMessage => $Value->{ErrorMessage}
                    };
                }
            }
        }

        $JSONStringRegex = $JSONObject->Encode(
            Data => \@ArrayOfRegexValue,
        );
    }

    #get code javascript
	$LayoutObject->Block(
		Name => 'FooterJS',
	);

	$FieldSelector = '#DynamicField_' . $Param{FieldName};
	$FieldName = 'DynamicField_'.$Param{FieldName};
	$UpdateFields = '"'.join ('","', @{ $Param{AJAXUpdatableFields} }).'"';

    #To treat as dynamic field regex
   if($DynamicFieldConfig->{Config}->{RegExList}){

    $LayoutObject->AddJSOnDocumentComplete( Code => <<"EOF");
    \$('$FieldSelector').on('blur', function (Event) {
        var ArrayOfRegex = $JSONStringRegex;
        var DynamicField = '$FieldSelector';
        Event.preventDefault();    
        Core.Agent.CustomServiceForm.RegToField(ArrayOfRegex, 'DynamicField_$DynamicFieldConfig->{Name}');
    });
EOF
    }

    return {
        Success => 1,
        HTML    => $LayoutObject->Output( TemplateFile => 'CustomServiceForm/DynamicField' ),
    };
}

sub _RenderAjax {
	my ( $Self, %Param ) = @_;
    
    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

    my @JSONCollector;

    # All submitted DynamicFields
    # get dynamic field values form http request
    my %DynamicFieldValues;

    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => 'Ticket',
    );

    # get needed object
    my $ParamObject               = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # extract the dynamic field value form the web request
        $DynamicFieldValues{ $DynamicFieldConfig->{Name} } = $DynamicFieldBackendObject->EditFieldValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ParamObject        => $ParamObject,
            LayoutObject       => $LayoutObject,
        );
    }

    # convert dynamic field values into a structure for ACLs
    my %DynamicFieldCheckParam;

    DYNAMICFIELD:
    for my $DynamicFieldItem ( sort keys %DynamicFieldValues ) {

        next DYNAMICFIELD if !$DynamicFieldItem;
        next DYNAMICFIELD if !defined $DynamicFieldValues{$DynamicFieldItem};
        next DYNAMICFIELD if !length $DynamicFieldValues{$DynamicFieldItem};

        $DynamicFieldCheckParam{ 'DynamicField_' . $DynamicFieldItem } = $DynamicFieldValues{$DynamicFieldItem};
    }

    $Param{GetParam}->{DynamicField} = \%DynamicFieldCheckParam;

    # Get the activity dialog's Submit Param's or Config Params
    DIALOGFIELD:
    for my $CurrentField ( @{ $Param{UpdateFields} } ) {
       
        if ( $CurrentField->{Name} =~ m{^DynamicField_(.*)}xms ) {

            my $DynamicFieldName = $1;

            my $DynamicFieldConfig = ( grep { $_->{Name} eq $DynamicFieldName } @{$DynamicField} )[0];

            next DIALOGFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );

            next DIALOGFIELD if !$IsACLReducible;

            my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                DynamicFieldConfig => $DynamicFieldConfig,
            );

            # convert possible values key => value to key => key for ACLs using a Hash slice
            my %AclData = %{$PossibleValues};
            @AclData{ keys %AclData } = keys %AclData;

            # get ticket object
            my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

			my %UserType = ();

			if($Self->{UserType} eq 'User') {
				$UserType{UserID} = $Self->{UserID};
			}
			else{
				$UserType{CustomerUserID} = $Self->{UserID};
			}

            # set possible values filter from ACLs
            my $ACL = $TicketObject->TicketAcl(
                %{ $Param{GetParam} },
                ReturnType    => 'Ticket',
                ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                Data          => \%AclData,
                Action        => $Self->{Action},
                %UserType
            );

            if ($ACL) {
                my %Filter = $TicketObject->TicketAclData();

                # convert Filer key => key back to key => value using map
                %{$PossibleValues} = map { $_ => $PossibleValues->{$_} } keys %Filter;
            }

            my $DataValues = $DynamicFieldBackendObject->BuildSelectionDataGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                PossibleValues     => $PossibleValues,
                Value              => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
            ) || $PossibleValues;



            # add dynamic field to the JSONCollector
            push(
                @JSONCollector,
                {
                    Name        => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data        => $DataValues,
                    SelectedID  => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                    Translation => $DynamicFieldConfig->{Config}->{TranslatableValues} || 0,
                    Max         => 100,
                }
            );
        }
    }

    my $JSON = $LayoutObject->BuildSelectionJSON( [@JSONCollector] );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

sub _GetParam {
    my ( $Self, %Param ) = @_;

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    my %GetParam;
    my %Ticket;
    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );
    my $Value;

	# # if there is a ticket then is not an AJAX request
    # if ($TicketID) {
    #     %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
    #         TicketID      => $TicketID,
    #         UserID        => $Self->{UserID},
    #         DynamicFields => 1,
    #     );

    #     %GetParam = %Ticket;
    #     if ( !IsHashRefWithData( \%GetParam ) ) {
    #         $LayoutObject->FatalError(
    #             Message => $LayoutObject->{LanguageObject}->Translate(
    #                 'Couldn\'t get Ticket for TicketID: %s in _GetParam!',
    #                 $TicketID,
    #             ),
    #         );
    #     }
    # }

    # Get the dynamic fields
    DIALOGFIELD:
    for my $Field ( @{ $Param{ShowFields} } ) {

		my $CurrentField = $Field->{Name};

        if ( $CurrentField =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldName = $1;

            my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
                Valid      => 1,
                ObjectType => 'Ticket',
            );

            # Get the Config of the current DynamicField (the first element of the grep result array)
            my $DynamicFieldConfig = ( grep { $_->{Name} eq $DynamicFieldName } @{$DynamicField} )[0];

            if ( !IsHashRefWithData($DynamicFieldConfig) ) {
                my $Message =
                    "DynamicFieldConfig missing for field: $DynamicFieldName, or is not a Ticket Dynamic Field!";

                # log error but does not stop the execution as it could be an old Article
                # DynamicField, see bug#11666
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => $Message,
                );

                next DIALOGFIELD;
            }

            # Get DynamicField Values
            $Value = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->EditFieldValueGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ParamObject        => $ParamObject,
                LayoutObject       => $LayoutObject,
            );

            # If we got a submitted param, take it and next out
            if (
                defined $Value
                && (
                    $Value eq ''
                    || IsStringWithData($Value)
                    || IsArrayRefWithData($Value)
                    || IsHashRefWithData($Value)
                )
                )
            {
                $GetParam{$CurrentField} = $Value;
                next DIALOGFIELD;
            }

            # If we didn't have a Param Value try the ticket Value
            # next out if it was successful
            if (
                defined $Ticket{$CurrentField}
                && (
                    $Ticket{$CurrentField} eq ''
                    || IsStringWithData( $Ticket{$CurrentField} )
                    || IsArrayRefWithData( $Ticket{$CurrentField} )
                    || IsHashRefWithData( $Ticket{$CurrentField} )
                )
                )
            {
                $GetParam{$CurrentField} = $Ticket{$CurrentField};
                next DIALOGFIELD;
            }

            # If we had neighter submitted nor ticket param get the ActivityDialog's default Value
            # next out if it was successful
            $Value = $Field->{DefaultValue};
            if ( defined $Value ) {
                $GetParam{$CurrentField} = $Value;
                next DIALOGFIELD;
            }

            # If we had no submitted or ticket default value
            # use the DynamicField's default value and next out
            $Value = $DynamicFieldConfig->{Config}{DefaultValue};
            if ( defined $Value ) {
                $GetParam{$CurrentField} = $Value;
                next DIALOGFIELD;
            }

            # if all that failed then the field should not have a defined value otherwise
            # if a value (even empty) is sent, fields like Date or DateTime will mark the field as
            # used with the field display value, this could lead to unwanted field sets,
            # see bug#9159
            next DIALOGFIELD;
        }
	}

	return \%GetParam;
}

sub _GetAJAXUpdatableFields {
    my ( $Self, %Param ) = @_;

    my %DefaultUpdatableFields = (
        PriorityID    => 1,
        QueueID       => 1,
        ResponsibleID => 1,
        ServiceID     => 1,
        SLAID         => 1,
        StateID       => 1,
        OwnerID       => 1,
        LockID        => 1,
    );

    my $DynamicField = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => 'Ticket',
    );

    # create a DynamicFieldLookupTable
    my %DynamicFieldLookup = map { 'DynamicField_' . $_->{Name} => $_ } @{$DynamicField};

    my @UpdatableFields;
    FIELD:
    for my $Field ( @{ $Param{UpdateFields} } ) {

        my $FieldName = $Field->{Name};

        # skip hidden fields
        next FIELD if !$Field->{Display};

        # for Dynamic Fields check if is AJAXUpdatable
        if ( $FieldName =~ m{^DynamicField_(.*)}xms ) {
            my $DynamicFieldConfig = $DynamicFieldLookup{$FieldName};

            # skip any field with wrong config
            next FIELD if !IsHashRefWithData($DynamicFieldConfig);

            # skip field if is not IsACLReducible (updatable)
            my $IsACLReducible = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );
            next FIELD if !$IsACLReducible;

            push @UpdatableFields, $FieldName;

        }

        # for all others use %DefaultUpdatableFields table
        else {

            # standarize the field name (e.g. use StateID for State field)
            my $Name = $Self->{NameToID}->{$FieldName};

            # skip if field name could not be converted (this means that field is unknown)
            next FIELD if !$Name;

            # skip if the field is not updatable via ajax
            next FIELD if !$DefaultUpdatableFields{$Name};

            push @UpdatableFields, $Name;
        }
    }
    return \@UpdatableFields;
}

1;
