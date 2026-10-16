# --
# Kernel/Modules/AgentTicketServiceFormFields.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jgsantos@serviceup.com.br
# * nfreitas@serviceup.com.br
# * jguedes@serviceup.com.br
# --

package Kernel::Modules::AgentTicketServiceFormFields;

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

    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
	my $LanguageObject            = $Kernel::OM->Get('Kernel::Language');
    my $JSONObject                = $Kernel::OM->Get('Kernel::System::JSON');
	my $TicketObject              = $Kernel::OM->Get('Kernel::System::Ticket');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $ParamObject               = $Kernel::OM->Get('Kernel::System::Web::Request');
	my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UploadCacheObject         = $Kernel::OM->Get('Kernel::System::Web::UploadCache');
    my $CustomFormObject          = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $DynamicFieldValueObject   = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    #  Get config to edition of dynamic fields
    my $EnableCustomServiceFormEdition = $ConfigObject->Get("CustomServiceForm::Core::ToEnableEdition");

    # get or generate form id
    $Self->{FormID} = $ParamObject->GetParam( Param => 'FormID' );
    if ( !$Self->{FormID} ) {
       $Self->{FormID} = $UploadCacheObject->FormIDCreate();
    }

    my %Ticket = $TicketObject->TicketGet(
		TicketID => $Self->{TicketID},
		DynamicFields => 1
	);

	my $FormID = $CustomFormObject->CustomFormSearch(
		ServiceID => $Ticket{ServiceID}
	);

	my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
		FormID       => $FormID,
    );

	my @FieldNames;

	foreach my $Field ( @{$Fields} ){
		my $Name = $Field->{Name};

		$Name =~ s/DynamicField_//;

		push @FieldNames, $Name;
	}

    # build page
    my $Output = $LayoutObject->Header(
        Value     => $Ticket{TicketNumber},
        Type      => 'Small',
        BodyClass => 'Popup',
    );

    $LayoutObject->Block(
        Name => 'ConfigEdition',
        Data =>{
            ConfigEdition => $EnableCustomServiceFormEdition,
        }
    );

    # ACL compatibility translation
    my %ACLCompatGetParam;

    my %GetParam;

    my %DynamicFieldValues;

    if( $EnableCustomServiceFormEdition ) {

        if ( $Self->{Subaction} eq 'Store' ) {

            DYNAMICFIELD:
            for my $Name (@FieldNames ) {

                my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        			Name => $Name,
        		);

                $DynamicFieldValues{ $DynamicField->{Name} } = $DynamicFieldBackendObject->EditFieldValueGet(
                    DynamicFieldConfig => $DynamicField,
                    ParamObject        => $ParamObject,
                    LayoutObject       => $LayoutObject,
                );

                next DYNAMICFIELD if !IsHashRefWithData($DynamicField);

        		my $DynamicFieldValue = $DynamicFieldValues{ $DynamicField->{Name} };

        		next DYNAMICFIELD if (!defined $DynamicFieldValue);

                my $Success = $DynamicFieldBackendObject->ValueSet(
                    DynamicFieldConfig => $DynamicField,
                    ObjectID           => $Self->{TicketID},
                    Value              => $DynamicFieldValue,
                    UserID             => $Self->{UserID},
                );

        		if ($Success){
        			my $Value = $DynamicFieldValue;

        			if($Value){

        				my $TextValue = 'Formulário de Serviço Editado ( '. $DynamicField->{Label};
        				#Create a history
        				if($DynamicField->{FieldType} eq "Multiselect"){
        					my $FinalItem = scalar @$DynamicFieldValue;
        					my $Flag = 1;
        					for my $Val (@{$DynamicFieldValue}){
        						if($Flag == 1){
        							$TextValue .= " = { ".$Val. " , ";
        						}elsif($Flag == $FinalItem){
        							$TextValue .= " ".$Val. " } ";

        						}else{
        							$TextValue .= " ".$Val. " , ";
        						}
        						$Flag++;

        					}
        					$TextValue .= ")";
        				}else{
        					$TextValue .=  ' = ' . $Value . ' )';
        				}

        				my $HistoryAdd = $TicketObject->HistoryAdd(
        					Name         => $TextValue,
        					HistoryType  => 'Misc',
        					TicketID     => $Self->{TicketID},
        					CreateUserID => $Self->{UserID},
        				);
        			}
        		}

            }
            # redirect
            return $LayoutObject->PopupClose(
                URL => "Action=AgentTicketZoom&TicketID=$Ticket{TicketID}"
            );

        }
        elsif ( $Self->{Subaction} eq 'AJAXUpdate' ) {
            # update Dynamic Fields Possible Values via AJAX
            my @DynamicFieldAJAX;

            # cycle trough the activated Dynamic Fields for this screen
            DYNAMICFIELD:
            for my $Name ( @FieldNames ) {

                my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $Name,
                );

                next DYNAMICFIELD if !IsHashRefWithData($DynamicField);
                next DYNAMICFIELD if $DynamicField->{ObjectType} ne 'Article';

                my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                    DynamicFieldConfig => $DynamicField,
                );

                my $ACL;
                if(defined $PossibleValues){
                    # set possible values filter from ACLs
                    $ACL = $TicketObject->TicketAcl(
                        %GetParam,
                        %ACLCompatGetParam,
                        Action        => $Self->{Action},
                        QueueID       => 0,
                        ReturnType    => 'Ticket',
                        ReturnSubType => 'DynamicField_' . $DynamicField->{Name},
                        Data          => $PossibleValues,
                        UserID        => $Self->{UserID},
                    );

                    if ($ACL) {
                        my %Filter = $TicketObject->TicketAclData();
                        $PossibleValues = \%Filter;
                    }

                    # add dynamic field to the list of fields to update
                    push(
                        @DynamicFieldAJAX,
                        {
                            Name        => 'DynamicField_' . $DynamicField->{Name},
                            Data        => $PossibleValues,
                            SelectedID  => $DynamicFieldValues{ $DynamicField->{Name} },
                            Translation => $DynamicField->{Config}->{TranslatableValues} || 0,
                            Max         => 100,
                        }
                    );
                }
            }

            my $JSON = $LayoutObject->BuildSelectionJSON(
            [
            @DynamicFieldAJAX,
            ],
            );

            return $LayoutObject->Attachment(
                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                Content     => $JSON,
                Type        => 'inline',
                NoCache     => 1,
            );
        }
        else {

            DYNAMICFIELD:
            foreach my $Name ( @FieldNames ) {

                my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $Name,
                );

                my $Label = $LayoutObject->{LanguageObject}->Translate( $DynamicField->{Label} );

                my %DynamicFieldValues;

                my $PossibleValuesFilter;

                my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
                    DynamicFieldConfig => $DynamicField,
                    Behavior           => 'IsACLReducible',
                );

                if ($IsACLReducible) {

                    # get PossibleValues
                    my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                        DynamicFieldConfig => $DynamicField,
                    );

                    # check if field has PossibleValues property in its configuration
                    if ( IsHashRefWithData($PossibleValues) ) {

                        # convert possible values key => value to key => key for ACLs using a Hash slice
                        my %AclData = %{$PossibleValues};
                        @AclData{ keys %AclData } = keys %AclData;

                        # set possible values filter from ACLs
                        my $ACL = $TicketObject->TicketAcl(
                            Action        => $Self->{Action},
                            TicketID      => $Self->{TicketID},
                            ReturnType    => 'Ticket',
                            ReturnSubType => 'DynamicField_' . $DynamicField->{Name},
                            Data          => \%AclData,
                            UserID        => $Self->{UserID},
                        );

                        if ($ACL) {
                            my %Filter = $TicketObject->TicketAclData();

                            # convert Filer key => key back to key => value using map
                            %{$PossibleValuesFilter} = map { $_ => $PossibleValues->{$_} }
                            keys %Filter;
                        }
                    }
                }

                my $Value = $DynamicFieldBackendObject->ValueGet(
                    DynamicFieldConfig => $DynamicField,     
                    ObjectID           => $Self->{TicketID}
                );

                # Get details of dynamic field in service form
                my %FieldDetails = $CustomFormObject->CustomFormDynamicFieldGet(
                    FormID    => $FormID,
                    FieldID  => $DynamicField->{ID},
                );

                # To added .js mask
                if ( $FieldDetails{Mask} ) {
                    $LayoutObject->AddJSOnDocumentComplete( Code => <<"EOF");
                        \$("#DynamicField_$DynamicField->{Name}").keydown(function(){
                            \$('#DynamicField_$DynamicField->{Name}').mask('$FieldDetails{Mask}');
                        });
EOF
                }
                my $DynamicFieldHTML;
                if( $DynamicField->{FieldType} eq 'FileSystem' ) {
                    
                    my $DynamicFieldFileValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue');

                    $Value = $DynamicFieldFileValueObject->ValueGet(
                        FieldID      => $DynamicField->{ID},
                        ObjectID     => $Self->{TicketID},
                    );

                    my $DynamicFieldHTMLFileSystem = $DynamicFieldBackendObject->EditFieldRender(
                        DynamicFieldConfig   => $DynamicField,
                        PossibleValuesFilter => $PossibleValuesFilter,
                        Mandatory            => $FieldDetails{Display} == 2,
                        LayoutObject         => $LayoutObject,
                        ParamObject          => $ParamObject,
                        AJAXUpdate           => 1,
                        UpdatableFields      => $Self->_GetFieldsToUpdate(),
                    );

                    $LayoutObject->Block(
                        Name => 'DynamicFieldEdition',
                        Data =>{
                            Name  => $DynamicField->{Name},
                            Field => $DynamicFieldHTMLFileSystem->{Field},
                            Label => $DynamicFieldHTMLFileSystem->{Label},
                        }
                    );

                    # if (IsArrayRefWithData ( $Value )){
                    #     foreach my $ValueHash ( @{$Value} ){

                    #         $Value = $ValueHash;

                    #         $LayoutObject->Block(
                    #             Name => 'DynamicFieldEdition',
                    #             Data =>{
                    #                 Field => $Value->{Value},
                    #             }
                    #         );
                    #     }
                    # }

                    if($FieldDetails{DescriptionShort}){
                        $LayoutObject->Block(
                            Name => 'rw:DynamicField:DescriptionShort',
                            Data => {
                                DescriptionShort  => $FieldDetails{DescriptionShort},
                            },
                        );
                    }

                    next DYNAMICFIELD;
                }
                else {

                    $DynamicFieldHTML = $DynamicFieldBackendObject->EditFieldRender(
                        DynamicFieldConfig   => $DynamicField,
                        PossibleValuesFilter => $PossibleValuesFilter,
                        Mandatory            => $FieldDetails{Display} == 2,
                        LayoutObject         => $LayoutObject,
                        ParamObject          => $ParamObject,
                        AJAXUpdate           => 1,
                        Value                => $Value,
                        UpdatableFields      => $Self->_GetFieldsToUpdate(),
                    );
                }


                my $DynamicFieldNames = $Self->_GetFieldsToUpdate(
                    OnlyDynamicFields => 1,
                );

                # send data to JS
                $LayoutObject->AddJSData(
                    Key   => 'DynamicFieldNames',
                    Value => $DynamicFieldNames,
                );

                $LayoutObject->Block(
                    Name => 'DynamicFieldEdition',
                    Data => {
                        Name  => $DynamicField->{Name},
                        Label => $DynamicFieldHTML->{Label},
                        Field => $DynamicFieldHTML->{Field},
                    },
                );

                if($FieldDetails{DescriptionShort}){
                    $LayoutObject->Block(
                        Name => 'rw:DynamicField:DescriptionShort',
                        Data => {
                            DescriptionShort  => $FieldDetails{DescriptionShort},
                        },
                    );
                }
            }

            my %CustomDynamicForm = $CustomFormObject->CustomFormGet(
                FormID => $FormID,
                UserID => $Self->{UserID}
            );

            $Output .= $LayoutObject->Output(
                TemplateFile => 'AgentTicketServiceFormFields',
                Data => {
                    TicketNumber => $Ticket{TicketNumber},
                    Name => $CustomDynamicForm{Name},
                    FormID => $Self->{FormID},
                    TicketID => $Self->{TicketID}
                },
            );

            $Output .= $LayoutObject->Footer(
                Type => 'Small',
            );
        }

    }
    else {

        DYNAMICFIELD:
	    foreach my $Name ( @FieldNames ){

    		my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
    			Name => $Name,
    		);

            my $Label = $LayoutObject->{LanguageObject}->Translate( $DynamicField->{Label} );

		    my $Value;

    		if ( $DynamicField->{FieldType} eq 'FileSystem' ) {
                
    			my $DynamicFieldFileValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue');

    			$Value = $DynamicFieldFileValueObject->ValueGet(
    				FieldID  => $DynamicField->{ID},
    				ObjectID => $Self->{TicketID},
    			);

    			$LayoutObject->Block(
    				Name => 'DynamicField',
    				Data =>{
    					Label => $Label,
    				}
    			);

    			if (IsArrayRefWithData ( $Value )){
    				foreach my $ValueHash ( @{$Value} ){

    					$Value = $ValueHash;

    					$LayoutObject->Block(
    						Name => 'DynamicField',
    						Data =>{
    							Value => $Value->{Link}
    						}
    					);
    				}
    			}

    			next DYNAMICFIELD;
    		}
            elsif ( $DynamicField->{FieldType} eq 'Table' ) {
                
                # get object
                my $DynamicFieldTableObject   = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');

                my $JSONData = $DynamicFieldTableObject->ValueGetTag(
                    ObjectID => $Self->{TicketID},
                    FieldID => $DynamicField->{ID},
                );	
                
                my $PerlStructureScalar = $JSONObject->Decode(
                    Data => $JSONData,
                );


                my %SortColumn;
                my %ColumnType;

                my $Count = 1;
                for (@{$DynamicField->{Config}->{PossibleColumns}}){
                    $SortColumn{$Count} = $_->{display};
                    $ColumnType{$Count} = $_->{type};
                    $Count++;
                }        

                my $Flag = 0;
                my (@TableSort, @Header);
                for (@{$PerlStructureScalar}){


                    my %RowSort;
                    for my $Key (sort keys %SortColumn){
                        
                        $RowSort{$Key} = $_->{$SortColumn{$Key}};

                        if(!$Flag){
                            push @Header, $SortColumn{$Key};
                        }
                    }

                    my $SizeColumn = scalar keys %{$_};
                    my $SizeSortColumn = scalar keys %SortColumn;

                    if($SizeColumn > $SizeSortColumn){
                        $RowSort{$SizeColumn} = $_->{'RowTotal'};
                        if(!$Flag){
                            push @Header, 'RowTotal';
                        }
                    }              

                    $Flag = 1;
                    push @TableSort, sort \%RowSort;
                }

                for my $Header (@Header){
                    $LayoutObject->Block(
                        Name => 'HeaderRow',
                        Data => {
                            Column => $Header,
                        },
                    );
                }

                for my $Row (@TableSort){
                    my @Values;

                    $LayoutObject->Block(
                        Name => 'Row',
                        Data => {},
                    );

                    for (sort keys %{$Row}) {
                        push @Values, $Row->{$_};
                    }
                                
                    my $Temp = 1;
                    for my $Value ( @Values ){

                        my $TypeDate = 0;

                        if ( $ColumnType{$Temp} eq 'date' && $Value ) {

                            $TypeDate = 1;

                            $Value = $Value . ' 00:00:00'
                        }

                        $LayoutObject->Block(
                            Name => 'ValuesRow',
                            Data => {
                                Values   => $Value,
                                TypeDate => $TypeDate
                            },
                        );

                        $Temp++;
                    }				
                }

                # generate HTML
                $Value = $LayoutObject->Output(
                    TemplateFile => "DynamicFieldTable/AgentDynamicFieldTable"				
                );	

            }
            elsif( $DynamicField->{FieldType} eq 'CheckList'){
                my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

                $Value = $DynamicFieldBackendObject->ValueGet(
                    DynamicFieldConfig => $DynamicField,     
                    ObjectID           => $Self->{TicketID}
                );

                my $DynamicFieldCheck = $DynamicFieldObject->DynamicFieldGet(
                    Name => $Name,
                );

                my $PerlStructureScalar = $JSONObject->Decode(
                    Data => $Value
                );

                my $CountLines = 0;
                my %ConvertedJson;
                my $ValueConvert;
                my %ValueUnformatted;
                my @FormatedData;

                for my $PossibleLines (@{$DynamicFieldCheck->{Config}{PossibleLines}}){

                    my $CountColumns = 0;
                    my $Comma = '';

                    for my $PossibleColumns( @{$DynamicFieldCheck->{Config}{PossibleColumns}} ){

                        $ConvertedJson{$PossibleLines}->{$PossibleColumns} = $PerlStructureScalar->[$CountLines]{Coluns}[$CountColumns] ?'true':'false'  ;

                        if( $ConvertedJson{$PossibleLines}{$PossibleColumns} eq 'true' ){

                            $ValueUnformatted{$PossibleLines}->{$PossibleColumns} = $PossibleColumns;
                        }

                        $CountColumns++;
                    }

                    $CountLines++;
                }

                for my $UnformattedKey (keys %ValueUnformatted){

                    my $Comma = '';
                    $ValueConvert = "$UnformattedKey: ";

                    for my $UnformattedValue ( values %{$ValueUnformatted{$UnformattedKey}}) {

                        $ValueConvert .= "$Comma$UnformattedValue";
                        $Comma = ','; 

                        push @FormatedData,  $ValueConvert;
                    }
                }

                # removes duplicate values

                my $DuplicatesCount = 0;

                while ($DuplicatesCount < $#FormatedData) {
                    if (index($FormatedData[$DuplicatesCount+1], $FormatedData[$DuplicatesCount]) != -1) {
                        splice(@FormatedData, $DuplicatesCount, 1);
                    } else {
                        $DuplicatesCount++;
                    }
                }
                
                my $FormattedFinalText;

                for my $Split (@FormatedData){
                
                    $FormattedFinalText .= "$Split<br>";
                }        
                
                $Value = $FormattedFinalText;
                
            }
            else {

                $Value = $DynamicFieldBackendObject->ValueGet(
                    DynamicFieldConfig => $DynamicField,     
                    ObjectID           => $Self->{TicketID}
                );

    			if ( $DynamicField->{FieldType} eq 'Checkbox' ) {
    				if ( $Value == 1 ){
    					$Value = 'Marcado';
    				}
    				else{
    					$Value = '';
    				}
    			}
    			elsif ( $DynamicField->{FieldType} eq 'Date' ) {
    				$Value = $LanguageObject->FormatTimeString(
    					$Value,
    					'DateFormat',
    					1,
    				);
                }
    			elsif ( $DynamicField->{FieldType} eq 'DateTime' ) {
    				$Value =  $LanguageObject->FormatTimeString(
    					$Value,
    					'DateFormat',
    					1,
    				);
    			}
                elsif ( $DynamicField->{FieldType} eq 'Multiselect' ) {
                 
                    my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                        DynamicFieldConfig => $DynamicField,       
                    );

                    my @ValuesOfKey;
                    if ( ref $Value eq 'ARRAY' ){
                        for my $HashValue (@{$Value}) {
                            push @ValuesOfKey, $PossibleValues->{$HashValue};
                        }
                        $Value = join ', ', @ValuesOfKey;
                    }
                }
                elsif ( $DynamicField->{FieldType} eq 'Dropdown' ) {
                  
                    my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                        DynamicFieldConfig => $DynamicField,      
                    );
                        
                    $Value = $PossibleValues->{$Value};
                    
                }
    		}

    		$LayoutObject->Block(
    			Name => 'DynamicField',
    			Data =>{
    				Label => $Label,
    				Value => $Value || ' '
    			}
    		);
	    }

        my %CustomDynamicForm = $CustomFormObject->CustomFormGet(
            FormID => $FormID,
            UserID => $Self->{UserID}
        );

    	$Output .= $LayoutObject->Output(
    		TemplateFile => 'AgentTicketServiceFormFields',
    		Data => {
    			TicketNumber => $Ticket{TicketNumber},
    			Name => $CustomDynamicForm{Name}
    		},
    	);

        $Output .= $LayoutObject->Footer(
            Type => 'Small',
        );
    }

    return $Output;
}

sub _GetFieldsToUpdate {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my @UpdatableFields;

    # set the fields that can be updateable via AJAXUpdate
    if ( !$Param{OnlyDynamicFields} ) {
        @UpdatableFields = qw(
            TypeID ServiceID SLAID NewOwnerID NewResponsibleID NewStateID
            NewPriorityID
        );
    }

    # define the dynamic fields to show based on the object type
    my $ObjectType = ['Ticket'];

    # get config of frontend module
    my $Config = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Self->{Action}");

    # only screens that add notes can modify Article dynamic fields
    if ( $Config->{Note} ) {
        $ObjectType = [ 'Ticket', 'Article' ];
    }

    # get the dynamic fields for this screen
    my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => $ObjectType,
        FieldFilter => $Config->{DynamicField} || {},
    );

    # cycle through the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsACLReducible',
        );
        next DYNAMICFIELD if !$IsACLReducible;

        push @UpdatableFields, 'DynamicField_' . $DynamicFieldConfig->{Name};
    }

    return \@UpdatableFields;
}
1;
