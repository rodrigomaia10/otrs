# Kernel/Output/HTML/ServicePreferences/ShowAsCategory.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Output::HTML::ServicePreferences::ShowAsCategory;

use strict;
use warnings;
use utf8;

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

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my @Params = ();

    my $GetParam
        = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Self->{ConfigItem}->{PrefKey} );

    if ( !defined($GetParam) ) {
        $GetParam = defined( $Param{ServiceData}->{ $Self->{ConfigItem}->{PrefKey} } )
            ? $Param{ServiceData}->{ $Self->{ConfigItem}->{PrefKey} }
            : $Self->{ConfigItem}->{DataSelected};
    }

    my %Types = (
        1 => $LayoutObject->{LanguageObject}->Translate('1 - Display in card (Main)'),
        2 => $LayoutObject->{LanguageObject}->Translate('2 - Display in list'),
        3 => $LayoutObject->{LanguageObject}->Translate('3 - Display on card (Secondary)'),
    );

    my %NewHash;
    for my $ID (keys %Types){
        $NewHash{$ID} = $Types{$ID};
    }

    my $OptionHTMLNew   = $LayoutObject->BuildSelection(
        Data         => \%NewHash,
        SelectedID   => $GetParam||'',
        Name         => $Self->{ConfigItem}->{PrefKey},
        Class        => 'Modernize',
        PossibleNone => 1,
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

    for my $Key ( sort keys %{ $Param{GetParam} } ) {
        my @Array = @{ $Param{GetParam}->{$Key} };
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
