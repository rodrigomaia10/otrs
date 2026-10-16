# --
# Kernel/Modulos/AgentDashboardCore.pm
# Copyright (C) 2019 ServiceUp, http://www.serviceupcom.br
#
# written/edited by:
# * ischutzer@serviceupcom.com.br
# * dsilva@serviceupcom.com.br
# --

package Kernel::Modules::AgentDashboardCore;

use strict;
use warnings;
use utf8;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

1;
