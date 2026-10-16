# --
# Custom/Kernel/System/DynamicField/Driver/Table.pm
# Copyright (C) 2019-2023 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * mbernardo@serviceup.com.br
# * jsantos@serviceup.com.br
# * dparavani@serviceup.com.br
# --


package Kernel::System::DynamicField::Driver::Table;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

use base qw(Kernel::System::DynamicField::Driver::BaseText);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DynamicFieldValue',
    'Kernel::System::Main',
    'Kernel::System::DynamicFieldTable',
    'Kernel::System::JSON',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::System::DynamicField::Driver::Table

=head1 SYNOPSIS

DynamicFields Table Driver delegate

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
        'IsSortable'                   => 0,
        'IsFiltrable'                  => 0,
        'IsStatsCondition'             => 1,
        'IsCustomerInterfaceCapable'   => 1,
    };

    # get the Dynamic Field Backend custom extensions
    my $DynamicFieldDriverExtensions = $Kernel::OM->Get('Kernel::Config')->Get('DynamicFields::Extension::Driver::Table');

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

sub EditFieldRender {
    my ( $Self, %Param ) = @_;

    my $JSONObject = $Kernel::OM->Get('Kernel::System::JSON');

    # take config from field config
    my $FieldConfig = $Param{DynamicFieldConfig}->{Config};
    my $FieldName   = 'DynamicField_' . $Param{DynamicFieldConfig}->{Name};
    my $FieldLabel  = $Param{DynamicFieldConfig}->{Label};

    my $TicketID = $Param{ParamObject}->GetParam( Param => 'TicketID' );
    my $FormID   = $Param{ParamObject}->GetParam( Param => 'FormID' );
    my $Link;

    # if admin contract 
    my $ContractID = $Param{ParamObject}->GetParam( Param => 'ID' );

    if ($TicketID) {
       
        $Link = <<"EOF";
TicketID=$TicketID;" + "FormID=" + \$(this).closest('form').find('input[name="FormID"]').val();
EOF
    }
    elsif ( $ContractID ) {
        $Link = <<"EOF";
ContractID=$ContractID;" + "FormID=" + \$(this).closest('form').find('input[name="FormID"]').val();
EOF
    }
    else {
        $Link = <<"EOF";
FormID=" + \$(this).closest('form').find('input[name="FormID"]').val();
EOF
    }

    my $ValueFlag = "";

    if ($TicketID) {

        my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

        my $Value = $DynamicFieldValueObject->ValueGet(
            FieldID  => $Param{DynamicFieldConfig}->{ID},
            ObjectID => $TicketID,
        );

        $ValueFlag = $Value->[0]{ValueText} || "";
    }

    if ( defined $Param{ParamObject} ) {

    	my $ValueTable = $Param{ParamObject}->GetParam( Param => $FieldName );

    	if ( defined $ValueTable && $ValueTable eq '1') {
    		$ValueFlag = $ValueTable;
    	}
    }

    my $HTMLString;

    my $ShowTable = $Param{LayoutObject}->{LanguageObject}->Translate('Show table');

    my $Class="";

    # set the field value or default
    if( $Param{Mandatory} ) {
        $Class = "Validate_Required";
    } 

    $HTMLString = <<"EOF";
    <input type='hidden' name='$FieldName' id='$FieldName' value='$ValueFlag' class='$Class AddDFS' />
    <a href="#" class="Primary CallForAction" id="ShowTable_$Param{DynamicFieldConfig}->{ID}" title="Table">
       <span class="fa fa-table" style="display: inline; line-height: 0px; vertical-align: baseline; border: 0px"></span>
       <span style="font-weight: bold; display: inline; line-height: 0px; vertical-align: baseline; border: 0px">$ShowTable</span>
    </a>

EOF

# Condition for customer interface with Forms 
if( $Param{LayoutObject}->{Action} eq 'DynamicFieldByService' ){
    $HTMLString .= <<"EOF";
    <script>
        \$('#ShowTable_$Param{DynamicFieldConfig}->{ID}').unbind('click');
	\$('#ShowTable_$Param{DynamicFieldConfig}->{ID}').bind('click', function (Event) {
	    URL = "$Param{LayoutObject}->{Baselink}" + "Action=DynamicFieldTableRender;FieldID=$Param{DynamicFieldConfig}->{ID};Mandatory=$Param{Mandatory};" + "$Link
            localStorage.setItem("DesktopMode", 0);
            Core.UI.Popup.OpenPopup(URL);
	    
	    return false;
        });
    </script>
EOF
}
else{
    # add javascript basead column config
    $Param{LayoutObject}->AddJSOnDocumentComplete( Code => <<"EOF");
        \$('#ShowTable_$Param{DynamicFieldConfig}->{ID}').bind('click', function (Event) {
            URL = "$Param{LayoutObject}->{Baselink}" + "Action=DynamicFieldTableRender;FieldID=$Param{DynamicFieldConfig}->{ID};Mandatory=$Param{Mandatory};" + "$Link
            localStorage.setItem("DesktopMode", 0);
            Core.UI.Popup.OpenPopup(URL);
	    
	    return false;
        });

EOF
}
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

sub EditFieldValueValidate {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldTableObject = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');

    my $TicketID = $Param{ParamObject}->GetParam( Param => 'TicketID' );
    my $FormID   = $Param{ParamObject}->GetParam( Param => 'FormID' );

    my $Value = '';

    if ( $TicketID ) {

        # get the field value from the http request
        $Value = $DynamicFieldTableObject->ValueGet(
            FieldID  => $Param{DynamicFieldConfig}->{ID},
            ObjectID => $TicketID
        );
    }
    else {

        # get the field value from the http request
        $Value = $DynamicFieldTableObject->ValueGet(
            FieldID => $Param{DynamicFieldConfig}->{ID},
            FormID  => $FormID,
        );
    }

    my $ServerError;
    my $ErrorMessage;

    #perform necessary validations
    if ( $Param{Mandatory} && $Value eq '' ) {
        $ServerError = 1;
        $ErrorMessage = 'This field is required';
    }

    # create resulting structure
    my $Result = {
        ServerError  => $ServerError,
        ErrorMessage => $ErrorMessage,
    };

    return $Result;
}

sub EditFieldValueGet {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldTableObject = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');
    my $Value;

    if ( !$Param{ObjectID} ) {
        if ( $Param{ParamObject} ) {
            my $FormID = $Param{ParamObject}->GetParam( Param => 'FormID' );

            # get the field value from the http request
            if ( $FormID && $Param{DynamicFieldConfig}->{ID} ) {
                $Value = $DynamicFieldTableObject->ValueGet(
                    FieldID => $Param{DynamicFieldConfig}->{ID},
                    FormID  => $FormID,
                );
            }
        }
    }

    return $Value;
}

sub ValueSet {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldTableObject = $Kernel::OM->Get('Kernel::System::DynamicFieldTable');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my $FormID = $ParamObject->GetParam( Param => 'FormID' );

    if ( $Param{ObjectID} && $FormID && $Param{Value} && $Param{DynamicFieldConfig}->{ID} ) {

        my $Success = $DynamicFieldTableObject->ValueSet(
            FieldID  => $Param{DynamicFieldConfig}->{ID},
            ObjectID => $Param{ObjectID},
            FormID   => $FormID,
            JSON     => $Param{Value}
        );
    }

    my $JSONDecode = $JSONObject->Decode(
        Data => $Param{Value},
    );

    my $SuccessValueSet = $Kernel::OM->Get('Kernel::System::DynamicFieldValue')->ValueSet(
        FieldID  => $Param{DynamicFieldConfig}->{ID},
        ObjectID => $Param{ObjectID},
        Value    => [
            {
                ValueText => "1",
            },
        ],
        UserID => $Param{UserID}
    );

    
}

sub DisplayValueRender {
    my ( $Self, %Param ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # set HTMLOutput as default if not specified
    if ( !defined $Param{HTMLOutput} ) {
        $Param{HTMLOutput} = 1;
    }

    # get raw Value strings from field value
    my $Value = defined $Param{Value} ? $Param{Value} : '';

    # get real value
    if ( $Param{DynamicFieldConfig}->{Config}->{PossibleValues}->{$Value} ) {

        # get readable value
        $Value = $Param{DynamicFieldConfig}->{Config}->{PossibleValues}->{$Value};
    }

    # check is needed to translate values
    if ( $Param{DynamicFieldConfig}->{Config}->{TranslatableValues} ) {

        # translate value
        $Value = $Param{LayoutObject}->{LanguageObject}->Translate($Value);
    }

    # set title as value after update and before limit
    my $Title = $Value;

    # HTMLOutput transformations
    if ( $Param{HTMLOutput} ) {
        $Value = $Param{LayoutObject}->Ascii2Html(
            Text => $Value,
            Max  => $Param{ValueMaxChars} || '',
        );

        $Title = $Param{LayoutObject}->Ascii2Html(
            Text => $Title,
            Max  => $Param{TitleMaxChars} || '',
        );
    }
    else {
        if ( $Param{ValueMaxChars} && length($Value) > $Param{ValueMaxChars} ) {
            $Value = substr( $Value, 0, $Param{ValueMaxChars} ) . '...';
        }
        if ( $Param{TitleMaxChars} && length($Title) > $Param{TitleMaxChars} ) {
            $Title = substr( $Title, 0, $Param{TitleMaxChars} ) . '...';
        }
    }

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $TicketNumber = $ParamObject->GetParam( Param => 'TicketNumber');
    my $TicketID     = $ParamObject->GetParam( Param => 'TicketID');
    my $Action       = $ParamObject->GetParam( Param => 'Action');

    my $Link;
    my $HTML;

    if (!$TicketID) {
        $TicketID = $TicketObject->TicketCheckNumber(
            Tn => $TicketNumber,
        );
    }

    $Value = $Param{LayoutObject}->{LanguageObject}->Translate('To view');
    
    if( $TicketID && $Action =~ m/Agent/ ){
        $Link = "index.pl?Action=DynamicFieldTableRender;Subaction=ViewMore;FieldID=$Param{DynamicFieldConfig}->{ID};TicketID=$TicketID";
        $HTML = $Value;
    }
    elsif( $TicketNumber && $Action =~ m/Customer/ ){
        # return;
        $Link = "customer.pl?Action=DynamicFieldTableRender;Subaction=ViewMore;FieldID=$Param{DynamicFieldConfig}->{ID};TicketID=$TicketID";
        $HTML = '<a href="'.$Link.'" class="DynamicFieldLink FloaterOpen" data-trigger="floater" data-floater-url="'.$Link.'" target="_blank">'.$Value.'</a>';
    }

    my $Data = {
        Value       => $HTML,
        Title       => $Value,
        Link        => $Link,
        LinkPreview => $Link,
    };

    return $Data;
}

sub SearchFieldRender {
    my ( $Self, %Param ) = @_;

    # take config from field config
    my $FieldConfig = $Param{DynamicFieldConfig}->{Config};
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

    # check if value is an array reference (GenericAgent Jobs and NotificationEvents)
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
<input type="text" class="$FieldClass" id="$FieldName" name="$FieldName" title="$FieldLabelEscaped" value="$ValueEscaped" />
EOF

    # call EditLabelRender on the common Driver
    my $LabelString = $Self->EditLabelRender(
        %Param,
        FieldName => $FieldName,
    );

    my $Data = {
        Field => $HTMLString,
        Label => $LabelString,
    };

    return $Data;
}

sub SearchFieldParameterBuild {
    my ( $Self, %Param ) = @_;

    # get field value
    my $Value = $Self->SearchFieldValueGet(%Param);

    if ( !$Value ) {
        return {
            Parameter => {
                'Like' => '',
            },
            Display => '',
        }
    }

    # return search parameter structure
    return {
        Parameter => {
            'Like' => '*' . $Value . '*',
        },
        Display => $Value,
    };
}

sub StatsSearchFieldParameterBuild {
    my ( $Self, %Param ) = @_;

    my $Operator = 'Equals';
    my $Value    = $Param{Value};

    return {
        $Operator => $Value,
    };
}

1;
