# Kernel/Output/HTML/ServicePreferences/ServiceMacro.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * dsilva@serviceup.com.br
# --

package Kernel::Output::HTML::ServicePreferences::ServiceMacro;

use strict;
use warnings;
use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::Web::Request',
    'Kernel::System::Service',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get env
    for ( sort keys %Param ) {
        $Self->{$_} = $Param{$_};
    }

    # get the dynamic fields
    $Self->{DynamicField} = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid      => 1,
        ObjectType => ['Ticket'],
    );

    return $Self;
}

sub Param {
    my ( $Self, %Param ) = @_;

    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $MacroObject        = $Kernel::OM->Get('Kernel::System::Macro');
    my $YAMLObject         = $Kernel::OM->Get('Kernel::System::YAML');

    my @Params = ();

    my $GetParam = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Self->{ConfigItem}->{PrefKey} );

    if ( !defined($GetParam) ) {
        $GetParam = defined( $Param{ServiceData}->{ $Self->{ConfigItem}->{PrefKey} } )
            ? $Param{ServiceData}->{ $Self->{ConfigItem}->{PrefKey} }
            : $Self->{ConfigItem}->{DataSelected};
    }

    my %DynamicFieldsJS;

    my @AddNewDynamicFields;

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {


        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
        next DYNAMICFIELD if $DynamicFieldConfig->{FieldType} ne "Dropdown";

        # Check if field is Attachment type ( from OTRSDynamicFieldAttachment )
        my $IsAttachement = $BackendObject->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsAttachement',
        );

        next DYNAMICFIELD if $IsAttachement;

        my $Key  = 'DynamicField_' . $DynamicFieldConfig->{Name};

        my $Used = 0;


        my $Value;

        if ( defined $Value ) {
            $Key .= 'Used';
            $Used = 1;
        }

        # Translate dynamic field label.
        my $TranslatedDynamicFieldLabel = $LayoutObject->{LanguageObject}->Translate(
            $DynamicFieldConfig->{Label},
        );

        # Save all new dynamic fields for JS.
        $DynamicFieldsJS{$Key} = {
            ID   => $DynamicFieldConfig->{ID},
            Text => $TranslatedDynamicFieldLabel,
        };

        if ( defined $Value || $DynamicFieldConfig->{Name} eq "ConsumptionNotification" ) {

            # Get field HTML.
            my $DynamicFieldHTML = $BackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                Value                => $Value,
                LayoutObject         => $LayoutObject,
                ParamObject          => $ParamObject,
                UseDefaultValue      => 0,
                OverridePossibleNone => 1,
                ConfirmationNeeded   => 1,
                NoIgnoreField        => 1,
            );

            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldHTML);

            my $BlockName = 'SelectedNewDynamicFields';

            $LayoutObject->Block(
                Name => $BlockName,
                Data => {
                    Label => $DynamicFieldHTML->{Label},
                    Field => $DynamicFieldHTML->{Field},
                    ID    => $Key,
                },
            );
        }
        else {
            push @AddNewDynamicFields, {
                Key   => $Key,
                Value => $TranslatedDynamicFieldLabel,
            };
        }
    }

    my $NewDynamicFieldsStrg = $LayoutObject->BuildSelection(
        PossibleNone => 1,
        Data         => \@AddNewDynamicFields,
        Name         => 'AddNewDynamicFields',
        Multiple     => 0,
        Class        => 'Modernize',
    );

    $LayoutObject->Block(
        Name => 'AddNewDynamicFields',
        Data => {
            NewDynamicFieldsStrg => $NewDynamicFieldsStrg,
        },
    );

    $LayoutObject->AddJSData(
        Key   => 'DynamicFieldsJS',
        Value => \%DynamicFieldsJS,
    );

    if ( $GetParam ne '' && defined $GetParam ) {

        my $Data = $YAMLObject->Load(
            Data => $GetParam,
        );

        my $Count = 1;
        my %Macros = $MacroObject->MacroList();

        my %DataReturn;

        if (IsHashRefWithData($Data)){

            for my $DynamicField ( keys %{ $Data } ) {

                my $DynamicFieldName = $DynamicField, 0, -2;

                my @Split = split('_', $DynamicFieldName);

                my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
                    Name => $Split[1],
                );

                my $DynamicFieldHTML;

                $DynamicFieldHTML->{ID}               = $DynamicFieldConfig->{ID};
                $DynamicFieldHTML->{DynamicFieldName} = $DynamicFieldConfig->{Name};
                $DynamicFieldHTML->{Count}            = $Count;
                $DynamicFieldHTML->{ValueDF}          = $Data->{$DynamicField}{Value};
                $DynamicFieldHTML->{ValueMacro}       = $Data->{$DynamicField}{Macro};

                $DataReturn{$DynamicFieldName} = $DynamicFieldHTML;

                $Count++;
            }
        }

        $LayoutObject->AddJSData(
            Key   => 'DynamicFieldsValueJS',
            Value => \%DataReturn,
        );
    }
    
    my $OptionHTMLNew = $LayoutObject->Output(
        TemplateFile => 'ServiceMacro'
    );
    
    push(
        @Params,
        {
            %Param,
            Name   => $Self->{ConfigItem}->{PrefKey},
            Option => $OptionHTMLNew,
        },
    );

    return @Params;

}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');
    my $YAMLObject   = $Kernel::OM->Get('Kernel::System::YAML');

    my %Data; 

    for my $Key ( sort keys %{ $Param{GetParam} } ) {

        if ( $Param{GetParam}->{$Key}->[0] ne '' ){

            my $Structure = $JSONObject->Decode(
                Data => @{$Param{GetParam}->{$Key}},
            );

            for my $DynamicField ( @{ $Structure } ) {

                my @Split = split('_', $DynamicField);

                my $Count = $Split[2];

                $Data{$DynamicField} = {
                    Value => $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $DynamicField ),
                    Macro => $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => "MacroName_" . $Count )
                }
            }
        }

        # Converts the configuration to YAML
        my $YAMLString = $YAMLObject->Dump(
            Data => \%Data
        );

        if($Param{ContractID} ){       
            my $Services = $Kernel::OM->Get('Kernel::System::ContractAndServices')->ContractServicePreferencesSet(
                ContractID => $Param{ContractID},
                ServiceID  => $Param{ServiceData}->{ServiceID} ,
                Key        => $Key,
                Value      => $YAMLString,
            );

        }else{

            $Kernel::OM->Get('Kernel::System::Service')->ServicePreferencesSet(
                ServiceID => $Param{ServiceData}->{ServiceID},
                Key       => $Key,
                Value     => $YAMLString,
            );
        }
    }

    $Self->{Message} = Translatable('Preferences updated successfully!');
    return 1;
}

sub Error {
    my ( $Self, %Param ) = @_;

    return $Self->{Error} || '';
}

sub Message {
    my ( $Self, %Param ) = @_;

    return $Self->{Message} || '';
}

1;
