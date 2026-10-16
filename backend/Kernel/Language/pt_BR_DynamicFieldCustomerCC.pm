# --
# Kernel/Language/pt_BR_DynamicFieldCustomerCC.pm
# Copyright (C)  2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@beonup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::Language::pt_BR_DynamicFieldCustomerCC;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'This event module adds the copied emails to the ticket.'} = 'Este módulo de evento adiciona os emails em copia no chamado.';       
    $Self->{Translation}->{'Invalid email!'} = 'E-mail inválido!';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'No',
        'Ok',
        'Settings',
        'Submit',
        'Yes',
    );
}

1;