# --
# Kernel/Modules/ConfigGetAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::Modules::ConfigGetAJAXHandler;

use strict;
use warnings;

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

    # get objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $JSONObject   = $Kernel::OM->Get('Kernel::System::JSON');

    my $JSON = '';

    # ------------------------------------------------------------ #
    # ajax get config JSON
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Get' ) {

        # get params
        my $Config = $ParamObject->GetParam( Param => 'Config' );

        if( !$Config ){

            $JSON = $LayoutObject->JSONEncode(
                Data => {
                    Data => {}
                }
            );
        }
        else {

            my $Value = $ConfigObject->Get($Config);

            my $JSONString = $Value;

            if ( ref $Value eq 'ARRAY' || ref $Value eq 'HASH' ) {

                $JSONString = $JSONObject->Encode(
                    Data     => $Value,
                    SortKeys => 1
                );
            }

            # build JSON output
            $JSON = $LayoutObject->JSONEncode(
                Data => {
                    Data => $JSONString
                }
            );
        }
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;