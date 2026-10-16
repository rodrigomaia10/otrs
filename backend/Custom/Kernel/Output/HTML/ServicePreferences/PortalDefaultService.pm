# Kernel/Output/HTML/ServicePreferences/PortalDefaultService.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Output::HTML::ServicePreferences::PortalDefaultService;

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
    
    my @Params = ();

    my $Checked = '';

    my $ServiceID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam(
        Param => 'ServiceID'
    );

    if( $ServiceID eq 'NEW'){

        $Checked = 'checked' if $Self->{ConfigItem}->{DefaultSelected};
    }
    else {

        my @ServiceIDs = $Kernel::OM->Get('Kernel::System::Service')->CustomerUserServiceMemberList(
            CustomerUserLogin => '<DEFAULT>',
            Result            => 'ARRAY',
            DefaultServices   => 1,
        );

        if ( @ServiceIDs && grep { $_ eq $Param{ServiceData}->{ServiceID} } @ServiceIDs ) {
            $Checked = 'checked';
        }
    }
   
    push(
        @Params,
        {
            %Param,
            Name   => $Self->{ConfigItem}->{PrefKey},
            Option => '<input name='.$Self->{ConfigItem}->{PrefKey}.' type="checkbox" '.$Checked.'/>',
        },
    );

    return @Params;
}

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Key ( sort keys %{ $Param{GetParam} } ) {

        my $Active = 0;

        $Active = 1 if $Param{GetParam}->{$Key}[0];

        $Kernel::OM->Get('Kernel::System::Service')->CustomerUserServiceMemberAdd(
            CustomerUserLogin => '<DEFAULT>',
            ServiceID         => $Param{ServiceData}->{ServiceID},
            Active            => $Active,
            UserID            => $Self->{UserID}
        )
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