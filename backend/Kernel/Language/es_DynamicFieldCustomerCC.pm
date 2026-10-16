# --
# Kernel/Language/es_DynamicFieldCustomerCC.pm
# Copyright (C)  2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::Language::es_DynamicFieldCustomerCC;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'This event module adds the copied emails to the ticket.'} = 'Este módulo de eventos agrega los correos electrónicos copiados al ticket.';       
    $Self->{Translation}->{'Invalid email!'} = '¡Email inválido!';  

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'No',
        'Ok',
        'Settings',
        'Submit',
        'Yes',
    );
}

1;