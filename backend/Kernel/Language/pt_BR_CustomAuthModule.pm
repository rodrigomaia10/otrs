# --
# Kernel/Language/pt_BR_CustomAuthModule.pm
# Copyright (C) 2019-2021 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::Language::pt_BR_CustomAuthModule;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # SysConfig  
    $Self->{Translation}->{'Authentication Webservice Name.'} = 'Nome do Webservice de autenticação.';
    $Self->{Translation}->{'Authentication Invoker name.'} = 'Nome do Invoker de autenticação.';

    return 1;
} 

1;
