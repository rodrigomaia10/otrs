# --
# Kernel/Language/es_Reports.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jguedes@serviceup.com.br
# --
 
package Kernel::Language::es_Reports;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # SysConfig
    $Self->{Translation}->{'QueueCreate'} = 'Creado en cola';
    $Self->{Translation}->{'Enter the agent login to delete the reports.'} = 'Informe o login do atendente que pode deletar um relatório.';
    $Self->{Translation}->{'Report that brings the column that shows the queue in which the call was created'} = 'Informe que trae la columna que muestra la cola en la que se creó la llamada';

    $Self->{Translation}->{'Define whether the order of fields in the report filter options will be in alphabetical order or not.'} = 'Defina si el orden de los campos en las opciones de filtro del informe será alfabético o no.';
    return 1;
} 

1;
