# --
# Kernel/Language/es_ProcessFieldReadOnly.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::Language::es_ProcessFieldReadOnly;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Read Only'} = 'Solo lectura';
    $Self->{Translation}->{'Field types that will be set to Read Only.'} = 'Tipos de campo que se establecerán en Solo lectura.';

}

1;
