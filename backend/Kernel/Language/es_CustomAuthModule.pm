# --
# Kernel/Language/es_CustomAuthModule.pm
# Copyright (C) 2019-2021 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::Language::es_CustomAuthModule;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # SysConfig  
    $Self->{Translation}->{'Authentication Webservice Name.'}  = 'Nombre del servicio web de autenticación.';
    $Self->{Translation}->{'Authentication Invoker name.'} = 'Nombre del invocador de autenticación.';

    return 1;
}

1;
