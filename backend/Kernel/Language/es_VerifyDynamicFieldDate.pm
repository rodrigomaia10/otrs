# --
# Kernel/Language/es_VerifyDynamicFieldDate.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * gbolsoni@serviceup.com.br
# --

package Kernel::Language::es_VerifyDynamicFieldDate;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift; 

    $Self->{Translation}->{'Ticket VerifyDinamicFieldDate Daemon.'} = 'Cron para el módulo VerifyDinamicFieldDate';

    $Self->{Translation}->{'Set the Services ID to filter date.'} = 'Agregue los IDs de los servicios para filtrar por fecha';

    $Self->{Translation}->{'Set the DynamicField Date name to compare'} = 'Agregue el nombre del campo dinámico de fecha a comparar';

    $Self->{Translation}->{'Dynamic Field DataAtingida value change to Yes'} = 'Valor del campo dinámico DataAtingida actualizado a Sí';
}

1;

