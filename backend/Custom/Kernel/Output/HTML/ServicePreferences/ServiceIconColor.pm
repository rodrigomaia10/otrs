# Kernel/Output/HTML/ServicePreferences/ServiceIconColor.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Output::HTML::ServicePreferences::ServiceIconColor;

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

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @Params = ();

    my $GetParam
        = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Self->{ConfigItem}->{PrefKey} );

    if ( !defined($GetParam) ) {
        $GetParam = defined( $Param{ServiceData}->{ $Self->{ConfigItem}->{PrefKey} } )
            ? $Param{ServiceData}->{ $Self->{ConfigItem}->{PrefKey} }
            : $Self->{ConfigItem}->{DataSelected};
    }

    my $ServiceColorsDefault = $ConfigObject->Get('CustomerPortal::Core::ServiceColorsDefault');

    my $Color = $GetParam;
    if( !$GetParam ){
        $Color = $ServiceColorsDefault->{ServiceIconColor};
    }

    my $OptionHTMLNew   = "<input type='color' id='ServiceIconColor' name='ServiceIconColor' value='#$Color'>";

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
            my @Words = split /#/, $_;

            if($Param{ContractID} ){       
                my $Services = $Kernel::OM->Get('Kernel::System::ContractAndServices')->ContractServicePreferencesSet(
                    ContractID => $Param{ContractID},
                    ServiceID  => $Param{ServiceData}->{ServiceID} ,
                    Key        => $Key,
                    Value      => $Words[1],
                );

            }else{
                # pref update db
                $Kernel::OM->Get('Kernel::System::Service')->ServicePreferencesSet(
                    ServiceID => $Param{ServiceData}->{ServiceID},
                    Key       => $Key,
                    Value     => $Words[1],
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
