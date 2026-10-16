# --
# Kernel/Language/pt_BR_ServicesDashboard.pm - frontend module
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * ccresencio@serviceup.com.br
# --

package Kernel::Language::pt_BR_ServicesDashboard;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

	# frontend template overview
	$Self->{Translation}->{'ServicesDashboard'} = 'Chamados por Serviço';
	$Self->{Translation}->{'Services Dashboard'} = 'Chamados por Serviço';
	$Self->{Translation}->{'AgentServicesDashboard'} = 'Chamados por Serviço';
	$Self->{Translation}->{'Chart to Tickets Stats'} = 'Gráfico de chamados por serviço';
	$Self->{Translation}->{'Activates customer search.'} = 'Ativa a busca por cliente.';
	$Self->{Translation}->{'No Service'} = 'Sem Serviço';
}

1;
