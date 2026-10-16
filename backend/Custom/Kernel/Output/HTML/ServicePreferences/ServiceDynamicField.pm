# Kernel/Output/HTML/ServicePreferences/ServiceDynamicField.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Output::HTML::ServicePreferences::ServiceDynamicField;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

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

    return $Self;
}

sub Param {
    my ( $Self, %Param ) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');

    my @Params = ();

    my $GetParam
        = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Self->{ConfigItem}->{PrefKey} );

    if ( !defined($GetParam) ) {
        $GetParam = defined( $Param{ServiceData}->{ $Self->{ConfigItem}->{PrefKey} } )
            ? $Param{ServiceData}->{ $Self->{ConfigItem}->{PrefKey} }
            : $Self->{ConfigItem}->{DataSelected};
    }

    my $SelectedDynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $Self->{ConfigItem}->{DFName},
    );

    my %DynamicFieldHTML;

    if($SelectedDynamicField->{ObjectType} eq 'Ticket'){
    
        # get field html
        $DynamicFieldHTML{ $SelectedDynamicField->{Name} }  = $BackendObject->EditFieldRender(
            DynamicFieldConfig   => $SelectedDynamicField,
            PossibleValuesFilter => $SelectedDynamicField->{Config}->{PossibleValues},
            LayoutObject    => $LayoutObject,
            ParamObject     => $ParamObject,
            Value           => $GetParam,       
        );

        if($SelectedDynamicField->{FieldType} eq 'Multiselect'){

            my @ValuesMulti = split /;/, $GetParam;

            $DynamicFieldHTML{ $SelectedDynamicField->{Name} }  = $BackendObject->EditFieldRender(
                DynamicFieldConfig   => $SelectedDynamicField,
                PossibleValuesFilter => $SelectedDynamicField->{Config}->{PossibleValues},
                LayoutObject    => $LayoutObject,
                ParamObject     => $ParamObject,
                Value           => \@ValuesMulti,       
            );

        }
        elsif($SelectedDynamicField->{FieldType} eq 'Date'){

            my @ValuesDate = split /;/, $GetParam;

            if($ValuesDate[2] < 10){
                $ValuesDate[2] = "0$ValuesDate[2]";
            }

            if($ValuesDate[1] < 10){
                $ValuesDate[1] = "0$ValuesDate[1]";
            }

            $DynamicFieldHTML{ $SelectedDynamicField->{Name} }  = $BackendObject->EditFieldRender(
                DynamicFieldConfig   => $SelectedDynamicField,
                PossibleValuesFilter => $SelectedDynamicField->{Config}->{PossibleValues},
                LayoutObject    => $LayoutObject,
                ParamObject     => $ParamObject,
                Value           =>  "$ValuesDate[3]-$ValuesDate[2]-$ValuesDate[1] 00:00:00",       
            );
        }
        elsif($SelectedDynamicField->{FieldType} eq 'DateTime'){
            my @ValuesDateTime = split /;/, $GetParam;

            if($ValuesDateTime[2] < 10){
                $ValuesDateTime[2] = "0$ValuesDateTime[2]";
            }

            if($ValuesDateTime[1] < 10){
                $ValuesDateTime[1] = "0$ValuesDateTime[1]";
            }

            if($ValuesDateTime[4] < 10){
            $ValuesDateTime[4] = "0$ValuesDateTime[4]";
            }

            if($ValuesDateTime[5] < 10){
            $ValuesDateTime[5] = "0$ValuesDateTime[5]";
            }


            $DynamicFieldHTML{ $SelectedDynamicField->{Name} }  = $BackendObject->EditFieldRender(
                DynamicFieldConfig   => $SelectedDynamicField,
                PossibleValuesFilter => $SelectedDynamicField->{Config}->{PossibleValues},
                LayoutObject    => $LayoutObject,
                ParamObject     => $ParamObject,
                Value           =>  "$ValuesDateTime[3]-$ValuesDateTime[2]-$ValuesDateTime[1] $ValuesDateTime[4]:$ValuesDateTime[5]:00",       
            );
        }

        my $str = $DynamicFieldHTML{ $SelectedDynamicField->{Name} }->{Field};
        my $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'"';
        my $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

        if($SelectedDynamicField->{FieldType} eq 'Date'){
            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Used"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;

            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Day"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;

            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Month"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;

            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Year"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;
        }
        elsif($SelectedDynamicField->{FieldType} eq 'DateTime'){
            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Used"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;

            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Day"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;

            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Month"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;

            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Year"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;

            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Hour"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;

            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'Minute"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;
        }
        else{
            $find = 'name="DynamicField_'.$Self->{ConfigItem}->{DFName}.'"';
            $replace = 'name="'.$Self->{ConfigItem}->{PrefKey}.'"';

            $str =~ s/$find/$replace/;
        }

        push(
            @Params,
            {
                %Param,
                Name   => $Self->{ConfigItem}->{PrefKey},
                Option => $str ,
            },
        );
    }

    return @Params;

}

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Key ( sort keys %{ $Param{GetParam} } ) {
        my @Array = @{ $Param{GetParam}->{$Key} };

        # To dynamicfields with more than one value
        if(scalar @Array > 1){           
            my $String = '';

            for (@Array) {
                $String .="$_;";               
            }
            
            if($Param{ContractID} ){       
                my $Services = $Kernel::OM->Get('Kernel::System::ContractAndServices')->ContractServicePreferencesSet(
                    ContractID => $Param{ContractID},
                    ServiceID  => $Param{ServiceData}->{ServiceID} ,
                    Key        => $Key,
                    Value      => $String,
                );

            }else{
                $Kernel::OM->Get('Kernel::System::Service')->ServicePreferencesSet(
                    ServiceID => $Param{ServiceData}->{ServiceID},
                    Key       => $Key,
                    Value     => $String,
                );
            }

        }else{
            
            for (@Array) {

                if($Param{ContractID} ){       
                    my $Services = $Kernel::OM->Get('Kernel::System::ContractAndServices')->ContractServicePreferencesSet(
                        ContractID => $Param{ContractID},
                        ServiceID  => $Param{ServiceData}->{ServiceID} ,
                        Key        => $Key,
                        Value      => $_,
                    );

                }else{
                    # pref update db
                    $Kernel::OM->Get('Kernel::System::Service')->ServicePreferencesSet(
                        ServiceID => $Param{ServiceData}->{ServiceID},
                        Key       => $Key,
                        Value     => $_,
                    );
                }
            }
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
