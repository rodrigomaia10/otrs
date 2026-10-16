# --
# Kernel/Modules/AdminCustomServiceForm.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@beonup.com.br
# * jgsantos@beonup.com.br
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Modules::AdminCustomServiceForm;

use strict;
use utf8;
use warnings;
use Encode;
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

    my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $LayoutObject     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject        = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject      = $Kernel::OM->Get('Kernel::System::Web::Request');

    # ------------------------------------------------------------ #
    # custom service form edit
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'ServiceFormEdit' ) {

        # get params
        $Param{ID} = $ParamObject->GetParam( Param => "ID" ) || 'NEW';

        # header
        my $Output = $LayoutObject->Header(Title => 'Service Form Management');
        $Output   .= $LayoutObject->NavigationBar();

        # html output
        $Output .= $Self->_Edit( %Param );
        $Output .= $LayoutObject->Footer();

        return $Output;
    }
    # ------------------------------------------------------------ #
    # custom service form save
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'ServiceFormSave' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $ParamForm = $Self->_GetParams();

        my (%GetParam, %Error);

        # get params
        for my $Param (qw(ID Name Interface Description ValidID)) {
            $GetParam{$Param} = $ParamObject->GetParam( Param => $Param ) || '';
        }

        # check needed data
        for my $Needed (qw(Name Interface ValidID)){
            if ( !$GetParam{$Needed} ) {
                $Error{$Needed. 'Invalid'} = 'ServerError';
            }
        }

        @{$GetParam{ServiceID}} = $ParamObject->GetArray( Param => "ServiceID" );

        if ( !%Error ) {

            # save to database
            if ( $GetParam{ID} eq 'NEW' ) {

                my $FormID = $CustomFormObject->CustomFormAdd(
                    UserID    => $Self->{UserID},
                    %GetParam
        		);

                $GetParam{ID} = $FormID;

                if($FormID){

                    my $Success = $CustomFormObject->CustomFormServiceSave(
                        FormID   => $GetParam{ID},
                        Services => \@{$GetParam{ServiceID}},
                    );

                    my $Fields = $CustomFormObject->CustomFormDynamicFieldSave(
                        FormID       => $FormID,
                        Fields       => $ParamForm->{Fields},
                        FieldDetails => $ParamForm->{FieldDetails},
                        UserID       => $Self->{UserID},
                    );
                }
                else{
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }
            }
            # update to database
            else{

                my $Update = $CustomFormObject->CustomFormUpdate(
                    UserID    => $Self->{UserID},
                    %GetParam
        		);

                if($Update){

                    my $Success = $CustomFormObject->CustomFormServiceSave(
                        FormID   => $GetParam{ID},
                        Services => \@{$GetParam{ServiceID}},
                    );

                    my $Fields = $CustomFormObject->CustomFormDynamicFieldSave(
        				FormID       => $GetParam{ID},
        				Fields       => $ParamForm->{Fields},
        				FieldDetails => $ParamForm->{FieldDetails},
        				UserID       => $Self->{UserID},
        			);
                }
                else{
                    $Error{Message} = $LogObject->GetLogEntry(
                        Type => 'Error',
                        What => 'Message',
                    );
                }

            }

            # if the user would like to continue editing the service, just redirect to the edit screen
            if (
                defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
                && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
                )
            {
                my $ID = $ParamObject->GetParam( Param => 'ID' ) || '';
                return $LayoutObject->Redirect(
                    OP => "Action=$Self->{Action};Subaction=ServiceFormEdit;ID=$ID"
                );
            }
            else {

                # otherwise return to overview
                return $LayoutObject->Redirect( OP => "Action=$Self->{Action}" );
            }
        }

        # something went wrong
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();
        $Output .= $LayoutObject->Notify( Priority => 'Error' );

        # html output
        $Output .= $Self->_Edit(
            %Error,
            %GetParam,
            %Param,
        );
        $Output .= $LayoutObject->Footer();
        return $Output;

    }
    elsif ( $Self->{Subaction} eq 'DownloadTemplate' ) {

        return $Self->_TemplateGenerate();     

    }
    # ------------------------------------------------------------ #
    # custom service form import
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq "FileUpload" ) {
        
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_FileUpload(
            %Param,
        );

    }
    elsif ( $Self->{Subaction} eq "FormCopy" ) {
        
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_FormCopy(
            %Param,
        );
    }
    # ------------------------------------------------------------ #
    # custom service form export
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'TemplateExport' ) {
        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_TemplateExport(
            %Param,
        );     

    }

    # ------------------------------------------------------------
    # Overview
    # ------------------------------------------------------------
   
    return $Self->_Overview(
        %Param,
        Action => 'Overview',
    );
}

sub _FormCopy {
    my ( $Self, %Param ) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject          = $Kernel::OM->Get('Kernel::System::Log');
    my $CustomFormObject   = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    my $ID = $ParamObject->GetParam( Param => 'ID' );

    my %FormData = $CustomFormObject->CustomFormGet(
        FormID => $ID,
        UserID => 1,
    );

    if ( !%FormData ) {
        return $LayoutObject->ErrorScreen(
            Message => "Unknown Form $ID!",
        );
    }

    my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
        FormID => $ID || '',
    );

    # Create new Form name.
    my $Count   = 1;
    my $FormName = "$FormData{Name} (" . $LayoutObject->{LanguageObject}->Translate('Copy') . ") $Count";

    while (
        $CustomFormObject->CustomFormGetByName(
            Name   => $FormName,
            UserID   => 1,
        )
        && $Count < 100
        )
    {
        $FormName =~ s/\d+$/$Count/;      
        $Count++;
    }


    my $FormID = $CustomFormObject->CustomFormAdd(
        UserID      => 1,
        Name        => $FormName, 
        Interface   => $FormData{Interface},             
        Description => $FormData{Description},   
        ValidID     => $FormData{ValidID},   
    );

    if($FormID){
        my %HashOfDFToUpload;
        my @IDs;

        if ( IsArrayRefWithData( $Fields ) ) {
            FIELD:
            for my $Field ( sort @{ $Fields } ) {
               
                my @OnlyName = split /DynamicField_/, $Field->{Name};

                my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
                    Name => $OnlyName[1],
                );
                
                $HashOfDFToUpload{$Field->{Name}} = {
                    ID           => $DynamicField->{ID},
                    Display      => 1,
                    Mask         => '',
                    DefaultValue => '',
                };

                push @IDs, "DynamicField_$DynamicField->{Name}";
                
            }
        }   

        my $Fields = $CustomFormObject->CustomFormDynamicFieldSave(
            FormID       => $FormID,
            Fields       => \@IDs,
            UserID       => 1,
            FieldDetails => \%HashOfDFToUpload,
          
        );

    }
    else{
        return $LayoutObject->ErrorScreen(
            Message => "Unknown FormID!",
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

sub _FileUpload {
    my ( $Self, %Param ) = @_;

    # Get Objects
    my $LayoutObject     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject      = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

    my $FormID      = $ParamObject->GetParam( Param => 'FormID' ) || '';
    my %UploadStuff = $ParamObject->GetUploadAll(
        Param  => 'FileUpload',
        Source => 'string',
    );

    my $OverwriteExistingEntities = $ParamObject->GetParam( Param => 'OverwriteExistingEntities' ) || '';

    my $TemplateImport = $CustomFormObject->CustomFormImport(
        Content                   => $UploadStuff{Content},
        OverwriteExistingEntities => $OverwriteExistingEntities,
        UserID                    => $Self->{UserID},
    );

    if ( !$TemplateImport->{Success} ) {
        my $Message = $TemplateImport->{Message}
            || Translatable(
            'Custom Form could not be Imported due to a unknown error, please check OTRS logs for more information'
            );
        return $LayoutObject->ErrorScreen(
            Message => $Message,
        );
    }

    if ( $TemplateImport->{AddedTemplates} ) {
        push @{ $Param{NotifyData} }, {
            Info => $LayoutObject->{LanguageObject}->Translate(
                'The following Custom Form have been added successfully: %s',
                $TemplateImport->{AddedTemplates}
            ),
        };
    }
    if ( $TemplateImport->{UpdatedTemplates} ) {
        push @{ $Param{NotifyData} }, {
            Info => $LayoutObject->{LanguageObject}->Translate(
                'The following Custom Form have been updated successfully: %s',
                $TemplateImport->{UpdatedTemplates}
            ),
        };
    }
    if ( $TemplateImport->{TemplatesErrors} ) {
        push @{ $Param{NotifyData} }, {
            Priority => 'Error',
            Info     => $LayoutObject->{LanguageObject}->Translate(
                'There where errors adding/updating the following Custom Forms: %s. Please check the log file for more information.',
                $TemplateImport->{TemplatesErrors}
            ),
        };
    }

    return $Self->_Overview(
        %Param,
        Action => 'Overview',
    );
}

sub _TemplateExport {
    my ($Self, %Param) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CustomFormObject   = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $ServiceObject      = $Kernel::OM->Get('Kernel::System::Service');

    my $ServiceFormID = $ParamObject->GetParam( Param => 'ID' ) || '';
    my $TemplateData;
    my %TemplateSingleData;
    my $Filename = 'Export_CustomServiceForm.yml';

    if ($ServiceFormID) {

        %TemplateSingleData = $CustomFormObject->CustomFormGet(
            FormID => $ServiceFormID,
            UserID => 1,
        );

        my @SelectedServices = $CustomFormObject->CustomFormServiceList(
            FormID => $ServiceFormID,
        );
        
        # To export the services by name
        my @NameOfServices;
        for my $ServiceID ( @SelectedServices ){

            my $ServiceName = $ServiceObject->ServiceLookup(
                ServiceID => $ServiceID,
            );

            push @NameOfServices, $ServiceName;
        }

        $TemplateSingleData{Services} = \@NameOfServices;

		my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
			FormID     => $ServiceFormID,
		);

        $TemplateSingleData{DynamicFields} = $Fields;

        if ( !%TemplateSingleData ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}
                    ->Translate( 'There was an error getting data for custom service form with ID %s', $ServiceFormID ),
            );
        }

        my $TemplateName = $TemplateSingleData{Name};
        $TemplateName =~ s{[^a-zA-Z0-9-_]}{_}xmsg;    # cleanup name for saving

        $Filename = 'Export_CustomServiceForm_' . $TemplateName . '.yml';
        $TemplateData  = [\%TemplateSingleData];
    }
    else {

        $TemplateData =  $CustomFormObject->CustomFormListGet(
            UserID   => 1,
        );

    }

    # convert the Service Template data hash to string
    my $TemplateDataYAML = $Kernel::OM->Get('Kernel::System::YAML')->Dump( Data => $TemplateData );

    # send the result to the browser
    return $LayoutObject->Attachment(
        ContentType => 'text/html; charset=' . $LayoutObject->{Charset},
        Content     => $TemplateDataYAML,
        Type        => 'attachment',
        Filename    => $Filename,
        NoCache     => 1,
    );
}

sub _TemplateGenerate {
    my ($Self, %Param) = @_;

    my $CustomFormObject   = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CSVObject          = $Kernel::OM->Get('Kernel::System::CSV');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');
    my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');

    # create title
    my $Title =  'Template CustomServiceForm';

    # generate filename
    my $Filename = $Kernel::OM->Get('Kernel::System::Stats')->StringAndTimestamp2Filename(
        String   => $Title || 'Export',
    );

    my @FieldsRequired;

    @FieldsRequired =  qw( Name Services Interfaces Description Valid DynamicFields );

    my %List = $CustomFormObject->CustomFormList(
        Valid => 2
    );
  
    my @DataArray;

    for my $ID (keys %List){
        my @ArrayOfCS;

        my %FormData = $CustomFormObject->CustomFormGet(
            FormID => $ID,
            UserID => 1,
        );

        push @ArrayOfCS, $FormData{Name};
        
        my @SelectedServices = $CustomFormObject->CustomFormServiceList(
            FormID => $ID,
        );

        my @ServiceNames;

        for my $ServiceID (@SelectedServices){
            my $ServiceName = $ServiceObject->ServiceLookup(
                ServiceID => $ServiceID,
            );

            push @ServiceNames, $ServiceName;
        }

        push @ArrayOfCS, join( '|',  @ServiceNames );
        push @ArrayOfCS, $FormData{Interface};        
        push @ArrayOfCS, $FormData{Description};     
        push @ArrayOfCS, $FormData{ValidID};
        
        if(scalar @ArrayOfCS > 1){
            push @DataArray, \@ArrayOfCS;
        }else{
            @DataArray = ();
        }

        my $Fields = $CustomFormObject->CustomFormDynamicFieldList(
			FormID     => $ID || '',
		);

        my @DFArray;
        if ( IsArrayRefWithData( $Fields ) ) {
            for my $DFField (sort @{ $Fields } ){
                push @DFArray, $DFField->{Name};
            }
        }

        push @ArrayOfCS, join( ', ', @DFArray );

    }
       
    my $Content = $CSVObject->Array2CSV(
        Head   => \@FieldsRequired,
        Data   => \@DataArray,
        Format => 'CSV',
    );

    my $FileExtension = '.csv';

    return $LayoutObject->Attachment(
        ContentType => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        Filename    => encode("iso-8859-1",$Filename) . $FileExtension,
        Content     => encode("iso-8859-1",$Content),
    );
}

sub _Edit {
    my ($Self, %Param) = @_;

    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $CustomFormObject   = $Kernel::OM->Get('Kernel::System::CustomServiceForm');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
	my $ServiceObject      = $Kernel::OM->Get('Kernel::System::Service');

    my %FormData;
    my @SelectedServices = ();
	my $Fields;

    my $Output;

    # get params
    $FormData{ID} = $Param{ID};
    if ( $FormData{ID} ne 'NEW' ) {
        %FormData = $CustomFormObject->CustomFormGet(
            FormID => $FormData{ID},
            UserID => $Self->{UserID},
        );

        @SelectedServices = $CustomFormObject->CustomFormServiceList(
            FormID => $FormData{ID},
        );

		$Fields = $CustomFormObject->CustomFormDynamicFieldList(
			FormID     => $FormData{ID} || '',
		);
    }

    # output overview
    $LayoutObject->Block(
        Name => 'Overview',
        Data => {
            ID          => $FormData{ID},
            Name        => $FormData{Name},
            Description => $FormData{Description},
            %Param,
        },
    );

    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionOverview' );

    my %Services = $CustomFormObject->ValidServiceList(
        FormID => $FormData{ID} || '',
    );

    $FormData{ServiceStrg} = $LayoutObject->BuildSelection(
		Data        => \%Services,
		Name        => 'ServiceID',
		Multiple    => 1,
		Class       => 'Modernize ' . ( $Param{Errors}->{'ValidIDInvalid'} || '' ),
		SelectedID  => [@SelectedServices],
        TreeView    => 1,  
	);

    # create interface selection
	$FormData{InterfaceSelection} = $LayoutObject->BuildSelection(
        Data => {
            AgentInterface    => Translatable('Agent Interface'),
            CustomerInterface => Translatable('Customer Interface'),
            OnBothInterfaces    => Translatable('Agent and Customer Interface'),
        },
        Name         => 'Interface',
        ID           => 'Interface',
        SelectedID   => $FormData{Interface} || '',
        Sort         => 'AlphanumericKey',
        Class        => 'Modernize W10pc',
    );

    # get valid list
    my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ValidListReverse = reverse %ValidList;

    $FormData{ValidOptionStrg} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $FormData{ValidID} || $ValidListReverse{valid},
        Class      => 'Modernize',
    );

    # output service edit
    $LayoutObject->Block(
        Name => 'ServiceFormEdit',
        Data => { %Param, %FormData },
    );

    # show appropriate messages for ServerError
    if ( defined $Param{Errors}->{NameExists} && $Param{Errors}->{NameExists} == 1 ) {
        $LayoutObject->Block( Name => 'ExistNameServerError' );
    }
    else {
        $LayoutObject->Block( Name => 'NameServerError' );
    }

    # create available Fields list
	my $AvailableFieldsList;

	my $DynamicFieldList = $DynamicFieldObject->DynamicFieldList(
		ObjectType => ['Ticket'],
		ResultType => 'HASH',
	);

    DYNAMICFIELD:
	for my $DynamicFieldName ( values %{$DynamicFieldList} ) {

		next DYNAMICFIELD if !$DynamicFieldName;

		# do not show internal fields for process management
		# next DYNAMICFIELD if $DynamicFieldName eq 'ProcessManagementProcessID';
		# next DYNAMICFIELD if $DynamicFieldName eq 'ProcessManagementActivityID';

		$AvailableFieldsList->{"DynamicField_$DynamicFieldName"} = $DynamicFieldName;
	}

    # localize available fields
    if ( !$AvailableFieldsList) {
       return $LayoutObject->Error(
           Message => Translatable('É necessário criar campos dinâmicos antes de associar.'),
       );
    }
	my %AvailableFields = %{$AvailableFieldsList};

    # get used fields by the activity dialog
	my %AssignedFields;

	 if ( IsArrayRefWithData( $Fields ) ) {
		FIELD:
		for my $Field ( sort @{ $Fields } ) {
			next FIELD if !$Field;

			$AssignedFields{$Field->{Name}} = 1;
		}
	}

    # remove used fields from available list
	for my $Field ( sort keys %AssignedFields ) {
		delete $AvailableFields{$Field};
	}

	# sort by translated field names
	my %AvailableFieldsTranslated;
	for my $Field ( sort keys %AvailableFields ) {
		my $Translation = $LayoutObject->{LanguageObject}->Translate($Field);
		$AvailableFieldsTranslated{$Field} = $Translation;
	}

    # display available fields
	for my $Field (
		sort { $AvailableFieldsTranslated{$a} cmp $AvailableFieldsTranslated{$b} }
		keys %AvailableFieldsTranslated
		)
	{
		my ($FieldName , $Name) = split /_/, $Field;

		my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
			Name => $Name,
		);

		$LayoutObject->Block(
			Name => 'AvailableFieldRow',
			Data => {
				Field               => $Field,
				FieldnameTranslated => $AvailableFieldsTranslated{$Field},
				FieldType           => $DynamicField->{FieldType},
			},
		);

	}

	# display used fields
	ASSIGNEDFIELD:
	for my $Field ( @{ $Fields } ) {
		next ASSIGNEDFIELD if !$AssignedFields{$Field->{Name}};

		my $FieldConfigJSON = $Kernel::OM->Get('Kernel::System::JSON')->Encode(
			Data => $Field,
		);

		my ($FieldName , $Name) = split /_/, $Field->{Name};

		my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
			Name => $Name,
		);

		$LayoutObject->Block(
			Name => 'AssignedFieldRow',
			Data => {
				Field       => $Field->{Name},
				FieldConfig => $FieldConfigJSON,
				FieldType   => $DynamicField->{FieldType},
			},
		);
	}

    # create Display selection
    $Param{DisplaySelection} = $LayoutObject->BuildSelection(
        Data => {
            0 => Translatable('Do not show Field'),
            1 => Translatable('Show Field'),
            2 => Translatable('Show Field As Mandatory'),
        },
        Name        => 'Display',
        ID          => 'Display',
        Sort        => 'AlphanumericKey',
        Translation => 1,
        Class       => 'Modernize',
    );

    $LayoutObject->Block(
		Name => 'PopUpDialogs',
		Data => \%Param
	);

	$LayoutObject->Block(
		Name => 'MaskContainer',
		Data => \%Param
	);

    # generate output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminCustomServiceForm',
        Data         => \%Param
    );

    return $Output;

}

sub _Overview {
    my ( $Self, %Param ) = @_;

    # get object
    my $LayoutObject     = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomFormObject = $Kernel::OM->Get('Kernel::System::CustomServiceForm');

    # get valid list
	my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

    my $Output = $LayoutObject->Header(Title => 'Service Form Management');
    $Output .= $LayoutObject->NavigationBar();

    $LayoutObject->Block(
        Name => 'Overview',
        Data => { %Param },
    );

    # show notifications if any
    if ( $Param{NotifyData} ) {
        for my $Notification ( @{ $Param{NotifyData} } ) {
            $Output .= $LayoutObject->Notify(
                %{$Notification},
            );
        }
    }

    # no actions in action list
    $LayoutObject->Block( Name => 'ActionList' );
    $LayoutObject->Block( Name => 'ActionAdd' );
    $LayoutObject->Block( Name => 'Filter' );

    # output overview result
    $LayoutObject->Block(
        Name => 'OverviewList',
        Data => { %Param, },
    );

    #get inteface
	my %InterfaceList = (
		AgentInterface    => Translatable('Agent Interface'),
		CustomerInterface => Translatable('Customer Interface'),
		OnBothInterfaces  => Translatable('Agent and Customer Interface'),
	);

    my %CustomFormList = $CustomFormObject->CustomFormList();

    if(IsHashRefWithData(\%CustomFormList)){

        for my $FormID ( keys %CustomFormList ) {

            my %FormData = $CustomFormObject->CustomFormGet(
                FormID => $FormID,
                UserID => $Self->{UserID}
            );

			$LayoutObject->Block(
				Name => 'OverviewListRow',
				Data => {
					%FormData,
					Interface => $InterfaceList{ $FormData{Interface} },
					Valid     => $ValidList{ $FormData{ValidID} },
				},
			);
		}
    }

    # otherwise a no data found msg is displayed
    else {
        $LayoutObject->Block(
            Name => 'NoDataFoundMsg',
            Data => {},
        );
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => 'AdminCustomServiceForm',
        Data         => \%Param,
    );

    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _GetParams {
    my ( $Self, %Param ) = @_;

    my $GetParam;

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject         = $Kernel::OM->Get('Kernel::System::JSON');

    my $Fields = $ParamObject->GetParam( Param => 'Fields' ) || '';

    if ($Fields) {
        $GetParam->{Fields} = $JSONObject->Decode(
            Data => $Fields,
        );
    }
    else {
        $GetParam->{Fields} = '';
    }

    my $FieldDetails = $ParamObject->GetParam( Param => 'FieldDetails' ) || '';

    if ($FieldDetails) {
        $GetParam->{FieldDetails} = $JSONObject->Decode(
            Data => $FieldDetails,
        );

		my @DynamicFields;
		for my $Field ( @{$GetParam->{Fields}} ) {

			my ($FieldName , $Name) = split /_/, $Field;

			my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
				Name => $Name,
			);

			$GetParam->{FieldDetails}->{$Field}->{ID} = $DynamicField->{ID};
		}
    }
    else {
        $GetParam->{FieldDetails} = '';
    }

    return $GetParam;
}

1;
