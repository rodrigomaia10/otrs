# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ServicePreferences::PortalProcess;

use strict;
use warnings;

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
    
    my $ProcessList = $Kernel::OM->Get('Kernel::System::ProcessManagement::Process')->ProcessList(
        ProcessState => ['Active'],
        Silent       => 1
    );

    my $OptionHTMLNew = $LayoutObject->BuildSelection(
        Data         => $ProcessList||[],
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
            }
            else{
                # pref update db
                $Kernel::OM->Get('Kernel::System::Service')->ServicePreferencesSet(
                    ServiceID => $Param{ServiceData}->{ServiceID},
                    Key       => $Key,
                    Value     => $_,
                );
            }
        }
    }
    $Self->{Message} = 'Preferences updated successfully!';
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