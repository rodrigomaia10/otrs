# --
# Kernel/Language/es_ServicesDashboard.pm - frontend module
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# * ccresencio@serviceup.com.br
# --

package Kernel::Language::es_ServicesDashboard;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

	# frontend template overview
	$Self->{Translation}->{'ServicesDashboard'} = 'tickets por servicio';
	$Self->{Translation}->{'Services Dashboard'} = 'tickets por servicio';
	$Self->{Translation}->{'AgentServicesDashboard'} = 'tickets por servicio';
	$Self->{Translation}->{'Chart to Tickets Stats'} = 'Gráfico de tickets por servicio';
	$Self->{Translation}->{'Activates customer search.'} = 'Activar la búsqueda de clientes.';
	$Self->{Translation}->{'No Service'} = 'Sin servicio';
}

1;
