# --
# Kernel/Language/pt_BR_Reports.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jguedes@serviceup.com.br
# * nfreitas@serviceup.com.br
# --
 
package Kernel::Language::pt_BR_Reports;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # SysConfig
    $Self->{Translation}->{'QueueCreate'} = 'Criado na Fila';
    $Self->{Translation}->{'Enter the agent login to delete the reports.'} = 'Informe o login do atendente que pode deletar um relatório.';
    $Self->{Translation}->{'Report that brings back the column that shows the queue in which the call was created'} = 'Relatório que trás a coluna que mostra a fila em que foi criado o chamado';

    $Self->{Translation}->{'Queue1'} = 'Primeira Fila';
    $Self->{Translation}->{'Queue2'} = 'Segunda Fila';
    $Self->{Translation}->{'The ticket states that are considerated as closed, when the ticket exits of these states, the ticket are considered reopened by the module.'} = 'Os estados de ticket que são considerados como fechados, quando o ticket sai de um desses estados, o ticket é considerado como reaberto pelo módulo';
    
    $Self->{Translation}->{'Define whether the order of fields in the report filter options will be in alphabetical order or not.'} = 'Defina se a ordem dos campos nas opções de filtros do relatório estarão ou não em ordem alfabética.';
    return 1;
} 

1;
