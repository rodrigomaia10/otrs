# --
# Custom/Kernel/Modules/ServiceTemplateAJAXHandler.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::Modules::ServiceTemplateAJAXHandler;

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
    my $LayoutObject          = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject           = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ServiceTemplateObject = $Kernel::OM->Get('Kernel::System::ServiceTemplate');
    my $JSONObject            = $Kernel::OM->Get('Kernel::System::JSON');
    my $ServiceObject         = $Kernel::OM->Get('Kernel::System::Service');
    my $ConfigObject          = $Kernel::OM->Get('Kernel::Config');

    my $JSON = '';

    # ------------------------------------------------------------ #
    # ajax service update
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'ServiceUpdate' ) {

        my $ServiceID = $ParamObject->GetParam( Param => 'ServiceID' ) || '';

        my %JSONStructure;

        if($ServiceID){

            my %TemplateData = $ServiceTemplateObject->TemplateGetByService(
                ServiceID => $ServiceID,
                UserID    => $Self->{UserID},
            );

            my %MappingFields;

            if ( $ConfigObject->Get('ServiceTemplate::PreferenceFieldMappingToScreen') ) {

                my %Preferences = $ServiceObject->ServicePreferencesGet(
                    ServiceID => $ServiceID,
                    UserID    => $Self->{UserID},
                );

                my $Mapping = $ConfigObject->Get('ServiceTemplate::PreferenceFieldMappingToScreen');

                for my $Field ( keys %{ $Mapping } ) {

                    $MappingFields{ $Mapping->{$Field} } = $Preferences{$Field}
                }
            }

            $JSON = $JSONObject->Encode(
                Data => {
                    Text    => $TemplateData{Response},
					Subject => $TemplateData{Subject},
                    Fields  => \%MappingFields,
                }
            );
        }
        else{
            $JSON = $JSONObject->Encode(
                Data => {
                    Text    => '',
					Subject => ''
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

};

1;
