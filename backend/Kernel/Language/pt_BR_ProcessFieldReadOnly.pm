# --
# Kernel/Language/pt_BR_OwnerCustomACL.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::Language::pt_BR_ProcessFieldReadOnly;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Read Only'} = 'Somente leitura';
    $Self->{Translation}->{'Field types that will be set to Read Only.'} = 'Tipos de campos que serão definidos como Somente Leitura.';

}

1;
