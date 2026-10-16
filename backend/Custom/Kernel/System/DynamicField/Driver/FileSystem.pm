# --
# Custom/Kernel/System/DynamicField/Driver/FileSystem.pm - Dynamic field Driver functions
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
# --
# written/edited by:
# * roliveira@beonup.com.br
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::System::DynamicField::Driver::FileSystem;

use strict;
use Kernel::System::VariableCheck qw(:all);
use base qw(Kernel::System::DynamicField::Driver::Base);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::DynamicFieldFileSystemValue',
    'Kernel::System::Log',
    'Kernel::System::Main',
);

=head1 NAME

Kernel::System::DynamicField::Driver::FileSystem

=head1 SYNOPSIS

DynamicFields FileSystem Driver delegate

=head1 PUBLIC INTERFACE

This module implements the public interface of L<Kernel::System::DynamicField::Backend>.
Please look there for a detailed reference of the functions.

=over 4

=item new()

usually, you want to create an instance of this
by using Kernel::System::DynamicField::Backend->new();

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # set field behaviors
    $Self->{Behaviors} = {
        'IsACLReducible'               => 0,
        'IsNotificationEventCondition' => 1,
        'IsSortable'                   => 1,
        'IsFiltrable'                  => 0,
        'IsStatsCondition'             => 1,
        'IsCustomerInterfaceCapable'   => 1,
    };

    # get the Dynamic Field Backend custom extensions
    my $DynamicFieldDriverExtensions
        = $Kernel::OM->Get('Kernel::Config')->Get('DynamicFields::Extension::Driver::FileSystem');

    EXTENSION:
    for my $ExtensionKey ( sort keys %{$DynamicFieldDriverExtensions} ) {

        # skip invalid extensions
        next EXTENSION if !IsHashRefWithData( $DynamicFieldDriverExtensions->{$ExtensionKey} );

        # create a extension config shortcut
        my $Extension = $DynamicFieldDriverExtensions->{$ExtensionKey};

        # check if extension has a new module
        if ( $Extension->{Module} ) {

            # check if module can be loaded
            if (
                !$Kernel::OM->Get('Kernel::System::Main')->RequireBaseClass( $Extension->{Module} )
                )
            {
                die "Can't load dynamic fields backend module"
                    . " $Extension->{Module}! $@";
            }
        }

        # check if extension contains more behaviors
        if ( IsHashRefWithData( $Extension->{Behaviors} ) ) {

            %{ $Self->{Behaviors} } = (
                %{ $Self->{Behaviors} },
                %{ $Extension->{Behaviors} }
            );
        }
    }

    return $Self;
}

sub ValueGet {
    my ( $Self, %Param ) = @_;

    my $DFValue = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueGet(
        FieldID  => $Param{DynamicFieldConfig}->{ID},
        ObjectID => $Param{ObjectID},
    );

    return if !$DFValue;

    my $Value = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue')->ValueGet(
        FieldID  => $Param{DynamicFieldConfig}->{ID},
        ObjectID => $Param{ObjectID},
    );

    return if !IsArrayRefWithData($Value);

    return $Value;
}

sub ValueSet {
    my ( $Self, %Param ) = @_;

	if ( !IsHashRefWithData($Self->{UploadStuff}) ) {
		$Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Value upload is invalid!",
        );
        return 1;
    }

    my $DynamicFieldFileSystem = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue');

	my %FileList = %{$Self->{UploadStuff}};

    # Count how many attachments you have per dynamic field.
    my $DynamicFieldName = "DynamicField_$Param{DynamicFieldConfig}->{Name}";

    my $FileCounter = 0;

    for my $DynamicField ( keys %FileList ) {       
        
        if ( $DynamicField =~ m{^$DynamicFieldName}xms ) {
            
            $FileCounter++;
        }        
    }

    # check if there is a way
    my $DFValue = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueGet(
        FieldID  => $Param{DynamicFieldConfig}->{ID},
        ObjectID => $Param{ObjectID},
    );

    if ( IsHashRefWithData($DFValue) ) {

        my $ExistingFiles = $DynamicFieldFileSystem->ValueFileGet(
            FieldID  => $Param{DynamicFieldConfig}->{ID},
            ObjectID => $Param{ObjectID}
        );

        if ( defined $ExistingFiles ) {
            for my $File ( @{$ExistingFiles} ) {

                if ( $File->{Filename} eq $FileList{"DynamicField_$Param{DynamicFieldConfig}->{Name}_1"}->{Filename}) {
                    return 1;
                }       
            }
        }
    }

    my $Success         = 0;
    my $SuccessValueSet = 0;

	for my $FileID ( 1..$FileCounter){

        # my $DynamicFieldName = "DynamicField_$Param{DynamicFieldConfig}->{Name}";

		$Success = $Kernel::OM->Get('Kernel::System::DynamicFieldFileSystemValue')->ValueSet(
			FieldID  	=> $Param{DynamicFieldConfig}->{ID},
			ObjectID 	=> $Param{ObjectID},
			FileContent => $FileList{$DynamicFieldName.'_'.$FileID},
			UserID 		=> $Param{UserID},
		);

		if( !$Success ) {
			$Kernel::OM->Get('Kernel::System::Log')->Log(
				Priority => 'error',
				Message  => "Upload of FileID $FileID is invalid!",
			);
		}
        elsif( !$SuccessValueSet ) {

            $SuccessValueSet = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueSet(
                FieldID  => $Param{DynamicFieldConfig}->{ID},
                ObjectID => $Param{ObjectID},
                Value    => [
                    {
                        ValueText => "1",
                    },
                ],
                UserID => $Param{UserID},
            );
        }
	}

	return 1;
}

sub ValueValidate {
    my ( $Self, %Param ) = @_;

    return 1;
}

sub EditFieldRender {
    my ( $Self, %Param ) = @_;

    # take config from field config
    my $FieldConfig = $Param{DynamicFieldConfig}->{Config};
    my $FieldName   = 'DynamicField_' . $Param{DynamicFieldConfig}->{Name};
    my $FieldLabel  = $Param{DynamicFieldConfig}->{Label};

    my $Value;

    # set the field value or default
    if ( $Param{UseDefaultValue} ) {
        $Value = ( defined $FieldConfig->{DefaultValue} ? $FieldConfig->{DefaultValue} : '' );
    }

    $Value = $Param{Value} || $Value;

    # extract the dynamic field value form the web request
    my $FieldValue = $Self->EditFieldValueGet(
        %Param,
    );

    # set values from ParamObject if present
    if ( defined $FieldValue ) {
        $Value = $FieldValue;
    }

    # check and set class if necessary
    my $FieldClass = 'W65pc';
    if ( defined $Param{Class} && $Param{Class} ne '' ) {
        $FieldClass .= ' ' . $Param{Class};
    }

    # set error css class
    if ( $Param{ServerError} ) {
        $FieldClass .= ' ServerError';
    }

    my $FieldLabelEscaped = $Param{LayoutObject}->Ascii2Html(
        Text => $FieldLabel,
    );

    my $HTMLString;
    my $FieldID = $Param{DynamicFieldConfig}->{ID};
    my $BaseLink = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->{Baselink};

    my $FlagFile = 0;

    # To get link of attachment in configuration
    if($FieldConfig->{LinkDefault}){

        my $Attachment = $FieldConfig->{LinkDefault};
        # Get url of link insert

        my @Values = split('/', $Attachment);
        my $PositionName =  scalar @Values;
        $HTMLString = "<a download href='/znuny-web/$Attachment'>$Values[$PositionName-1]</a>";
    }
    else {

        my $HTMLValue = '';
      
        if ( IsArrayRefWithData($Value) ) {

            for my $Name( @{$Value} ) {

                if ( $FieldConfig->{DeleteFile} ) {

                    $HTMLValue .= $Name->{Value}."<br>";
                }
                else {
                    
                    $HTMLValue .= $Name->{Link}."<br>";
                }

                $FlagFile = 1;
            }
        }

        # set field as mandatory
        if ( $Param{Mandatory} && $FlagFile == 0 ) {
            $FieldClass .= ' Validate_Required';
        }

        $HTMLString .= <<"EOF";
<input type="file" class="$FieldClass" id="$FieldName" name="$FieldName" title="$FieldLabelEscaped" size='40' multiple="multiple"/><br/>
$HTMLValue
EOF

    }

    if ( $Param{Mandatory} ) {

        my $DivID = $FieldName . 'Error';

        my $FieldRequiredMessage = $Param{LayoutObject}->{LanguageObject}->Translate("This field is required.");

        # for client side validation
        $HTMLString .= <<"EOF";
<div id="$DivID" class="TooltipErrorMessage">
    <p>
        $FieldRequiredMessage
    </p>
</div>
EOF
    }

    if ( $Param{ServerError} ) {

        my $ErrorMessage = $Param{ErrorMessage} || 'This field is required.';
        $ErrorMessage = $Param{LayoutObject}->{LanguageObject}->Translate($ErrorMessage);
        my $DivID = $FieldName . 'ServerError';

        # for server side validation
        $HTMLString .= <<"EOF";
<div id="$DivID" class="TooltipErrorMessage">
    <p>
        $ErrorMessage
    </p>
</div>
EOF
    }

	if( $FieldConfig->{ArticleFile} ){

	# add js to hide FileUpload
    $Param{LayoutObject}->AddJSOnDocumentComplete( Code => <<"EOF");

\$( document ).ready(function() {

	if ( \$("#FileUpload").length ) {
        
		\$("#FileUpload").closest(".Field").addClass('Hidden');
		\$("#FileUpload").closest(".Field").prev('label').css('display', 'none');
	}
});
EOF
	}

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    
    my $MaxSizeFileUpload = $ConfigObject->Get('MaxSizeFileUpload');

	# add js to hide FileUpload
    $Param{LayoutObject}->AddJSOnDocumentComplete( Code => <<"EOF");
\$( document ).ready(function() {

    \$('#$FieldName').on('change', function(){ 

        let SizeMB = Math.round(($MaxSizeFileUpload/1000)/1000);
        
        let Files = this.files;

        \$.each(Files, function( index, value ) {        

            if (value.name.length > 200) {

                if (!\$('#AttachmentError').length) {

                    \$('#$FieldName').after('<p id="AttachmentError" style="color: red; margin-top: 5px;">' + Core.Language.Translate('The file name exceeds the 200 character limit.') + '</p>');
                    
                    if (\$('#AttachmentError').next().is('br')) {
                        \$('#AttachmentError').next().remove();
                    }
                }
            
                \$('#$FieldName').val('');
            }
            else {

                if (\$('#AttachmentError').length) {
                    
                    \$('#$FieldName').after('<br>');
                }

                \$('#AttachmentError').remove();
            }
            
            if (value.size > $MaxSizeFileUpload) {

                if (!\$('#AttachmentErrorSize').length) {

                    \$('#$FieldName').after('<p id="AttachmentErrorSize" style="color: red; margin-top: 5px;">' + Core.Language.Translate('The file size cannot be larger than ') + SizeMB + 'MB.' + '</p>');

                        if (\$('#AttachmentErrorSize').next().is('br')) {
                            \$('#AttachmentErrorSize').next().remove();
                        }
                }

                \$('#$FieldName').val('');
            }
            else {

                if (\$('#AttachmentErrorSize').length) {
                    
                    \$('#$FieldName').after('<br>');
                }

                \$('#AttachmentErrorSize').remove();
            }
        });
    });   
});
EOF

    # call EditLabelRender on the common backend
    my $LabelString = $Self->EditLabelRender(
        %Param,
        Mandatory => $Param{Mandatory} || '0',
        FieldName => $FieldName,
    );

    my $Data = {
        Field => $HTMLString,
        Label => $LabelString,
    };

    return $Data;
}

sub EditFieldValueGet {
    my ( $Self, %Param ) = @_;

    my $FieldName = 'DynamicField_' . $Param{DynamicFieldConfig}->{Name};

	my $Value;
	# check if there is a Template and retrieve the dynamic field value from there
    if ( IsHashRefWithData( $Param{Template} ) ) {
        $Value = $Param{Template}->{$FieldName};

    }

    # otherwise get dynamic field value from the web request
    elsif ( defined $Param{ParamObject} ){

        my $DFValue  = $Param{ParamObject}->GetParam( Param => $FieldName );
        my $TicketID = $Param{ParamObject}->GetParam( Param => "TicketID" );        

		if ( $DFValue ) {

			my %UploadStuff = $Param{ParamObject}->GetMultipleUpload(
                Param  => $FieldName,
				Source => 'file',
            );

            if(IsHashRefWithData($Self->{UploadStuff})){

                if ( IsHashRefWithData(\%UploadStuff) ){
                    $Self->{UploadStuff} = { %{$Self->{UploadStuff}}, %UploadStuff };
                }
            }
            else {

                if ( IsHashRefWithData(\%UploadStuff) ){
                    $Self->{UploadStuff} = \%UploadStuff;
                }
            }

			$Value = $Self->{UploadStuff};
		}

        if ( !$Value && $TicketID ) {

            $Value = $Self->ValueGet(
                DynamicFieldConfig => $Param{DynamicFieldConfig},
                ObjectID           => $TicketID,
            );
        }
    }

    if ( defined $Param{ReturnTemplateStructure} && $Param{ReturnTemplateStructure} eq '1' ) {
		return {
            $FieldName => $Value,
        };
    }

    # for this field the normal return an the ReturnValueStructure are the same
    return $Value;
}

sub EditFieldValueValidate {
    my ( $Self, %Param ) = @_;

	# get the field value from the http request
    my $Value = $Self->EditFieldValueGet(
        DynamicFieldConfig => $Param{DynamicFieldConfig},
        ParamObject        => $Param{ParamObject}
    );

    my $ServerError;
    my $ErrorMessage;

    # perform necessary validations
    if ( $Param{Mandatory} && $Value eq '' ) {
        $ServerError = 1;
		$ErrorMessage = 'Upload file is ivalid!';
    }

    # create resulting structure
    my $Result = {
        ServerError  => $ServerError,
        ErrorMessage => $ErrorMessage,
    };

    return $Result;
}

sub DisplayValueRender {
    my ( $Self, %Param ) = @_;

    # check for Null value
    if ( !defined $Param{Value} ) {
        return {
            Value => '',
            Title => '',
            Link  => '',
        };
    }

    # convert value to user friendly string
    my $Value = defined $Param{Value} ? $Param{Value} : '';

    # in this backend there is no need for HTMLOutput
    # Title is always null
    my $Title = '';

    # set field link form config
    my $Link = $Param{DynamicFieldConfig}->{Config}->{Link} || '';

    my $AllAttachment = '';
	foreach my $FileLink ( @{$Value} ){
		$AllAttachment .= $FileLink->{Value}."</br>";
	}

    $Value = $AllAttachment;
   
    # create return structure
    my $Data = {
        Value => $Value,
        Title => $Title,
        Link  => $Link,
    };
    return $Data;

}

sub SearchFieldRender {
    my ( $Self, %Param ) = @_;

    # take config from field config
    my $FieldName   = 'Search_DynamicField_' . $Param{DynamicFieldConfig}->{Name};
    my $FieldLabel  = $Param{DynamicFieldConfig}->{Label};

    # set the field value
    my $Value = ( defined $Param{DefaultValue} ? $Param{DefaultValue} : '' );

    # get the field value, this function is always called after the profile is loaded
    my $FieldValue = $Self->SearchFieldValueGet(%Param);

    # set values from profile if present
    if ( defined $FieldValue ) {
        $Value = $FieldValue;
    }

    # check if value is an arrayref (GenericAgent Jobs and NotificationEvents)
    if ( IsArrayRefWithData($Value) ) {
        $Value = @{$Value}[0];
    }

    # check and set class if necessary
    my $FieldClass = 'DynamicFieldText';

    my $ValueEscaped = $Param{LayoutObject}->Ascii2Html(
        Text => $Value,
    );

    my $FieldLabelEscaped = $Param{LayoutObject}->Ascii2Html(
        Text => $FieldLabel,
    );

    my $HTMLString = <<"EOF";
<input type="file" class="$FieldClass" id="$FieldName" name="$FieldName" title="$FieldLabelEscaped" value="$ValueEscaped" />
EOF

    my $AdditionalText;
    if ( $Param{UseLabelHints} ) {
        $AdditionalText = 'e.g. Text or Te*t';
    }

    # call EditLabelRender on the common Driver
    my $LabelString = $Self->EditLabelRender(
        %Param,
        FieldName      => $FieldName,
        AdditionalText => $AdditionalText,
    );

    my $Data = {
        Field => $HTMLString,
        Label => $LabelString,
    };

    return $Data;
}

sub SearchFieldValueGet {
    my ( $Self, %Param ) = @_;

    my $Value;

    # get dynamic field value from param object
    if ( defined $Param{ParamObject} ) {
        my @FieldValues = $Param{ParamObject}->GetArray(
            Param => 'Search_DynamicField_' . $Param{DynamicFieldConfig}->{Name}
        );

        $Value = \@FieldValues;
    }

    # otherwise get the value from the profile
    elsif ( defined $Param{Profile} ) {
        $Value = $Param{Profile}->{ 'Search_DynamicField_' . $Param{DynamicFieldConfig}->{Name} };
    }
    else {
        return;
    }

    if ( defined $Param{ReturnProfileStructure} && $Param{ReturnProfileStructure} == 1 ) {
        return {
            'Search_DynamicField_' . $Param{DynamicFieldConfig}->{Name} => $Value,
        };
    }

    return $Value;
}

sub SearchFieldParameterBuild {
    my ( $Self, %Param ) = @_;

    # get field value
    my $Value = $Self->SearchFieldValueGet(%Param);

    # set operator
    my $Operator = 'Equals';

    # search for a wild card in the value
    if ( $Value && $Value =~ m{\*} ) {

        # change oprator
        $Operator = 'Like';
    }

    # return search parameter structure
    return {
        Parameter => {
            $Operator => $Value,
        },
        Display => $Value,
    };
}

sub StatsFieldParameterBuild {
    my ( $Self, %Param ) = @_;

    return {
        Name               => $Param{DynamicFieldConfig}->{Label},
        Element            => 'DynamicField_' . $Param{DynamicFieldConfig}->{Name},
    };
}

sub StatsSearchFieldParameterBuild {
    my ( $Self, %Param ) = @_;

    my $Value = $Param{Value};

    # set operator
    my $Operator = 'Equals';

    # search for a wild card in the value
    if ( $Value && $Value =~ m{\*} ) {

        # change oprator
        $Operator = 'Like';
    }

    return {
        $Operator => $Value,
    };
}

sub ReadableValueRender {
    my ( $Self, %Param ) = @_;

    my $Value = defined $Param{Value} ? $Param{Value} : '';
    my $Link;
    # Title is always equal to Value
    my $Title = $Value;

    if (IsArrayRefWithData($Value)){

        for my $File( @{$Value} ) {
            if( IsHashRefWithData($File) ) {
                $Link .= $File->{Link} ."<br/>";
            }
            else {
                $Link .= $File;
            }
        }

        $Value = $Link;
    }

    # create return structure
    my $Data = {
        Value => $Value,
        Title => $Title,
    };

    return $Data;
}

sub TemplateValueTypeGet {
    my ( $Self, %Param ) = @_;

    my $FieldName = 'DynamicField_' . $Param{DynamicFieldConfig}->{Name};

    # set the field types
    my $EditValueType   = 'SCALAR';
    my $SearchValueType = 'ARRAY';

    # return the correct structure
    if ( $Param{FieldType} eq 'Edit' ) {
        return {
            $FieldName => $EditValueType,
            }
    }
    elsif ( $Param{FieldType} eq 'Search' ) {
        return {
            'Search_' . $FieldName => $SearchValueType,
            }
    }
    else {
        return {
            $FieldName             => $EditValueType,
            'Search_' . $FieldName => $SearchValueType,
            }
    }
}

sub RandomValueSet {
    my ( $Self, %Param ) = @_;

    my $Value = int( rand(500) );

    my $Success = $Self->ValueSet(
        %Param,
        Value => $Value,
    );

    if ( !$Success ) {
        return {
            Success => 0,
        };
    }
    return {
        Success => 1,
        Value   => $Value,
    };
}

sub ObjectMatch {
    my ( $Self, %Param ) = @_;

    my $FieldName = 'DynamicField_' . $Param{DynamicFieldConfig}->{Name};

    # return false if field is not defined
    return 0 if ( !defined $Param{ObjectAttributes}->{$FieldName} );

    # return false if not match
    if ( $Param{ObjectAttributes}->{$FieldName} ne $Param{Value} ) {
        return 0;
    }

    return 1;
}

sub ValueLookup {
    my ( $Self, %Param ) = @_;

    my $Value = defined $Param{Key} ? $Param{Key} : '';

    return $Value;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
