# -- 
# Kernel/Language/pt_BR_ServiceRelation.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Language::pt_BR_ServiceRelation;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

	# frontend template overview
	$Self->{Translation}->{'Change Service Relations for Queue'} = 'Alterar Relações de Fila para Serviço';
	$Self->{Translation}->{'Change Service Relations for Type'} = 'Alterar Relações de Serviço para Tipo';
	$Self->{Translation}->{'Change Queue Relations for Service'} = 'Alterar Relações de Serviço para Fila';
	$Self->{Translation}->{'Change Type Relations for Service'} = 'Alterar Relações de Tipo para Serviço';
	$Self->{Translation}->{'ACL module that allows the relations between Type-Service and Queue-Service.'} = 'Módulo ACL que permite a relação entre Tipo-Serviço e Fila-Serviço';
	$Self->{Translation}->{'Filter for Types'} = 'Filtrar por Tipo';
	$Self->{Translation}->{'Type  ↔ Services'} = 'Tipo ↔ Serviço';
	$Self->{Translation}->{'Relation Type and Service.'} = 'Associar Tipos a Serviços';
	$Self->{Translation}->{'Queue  ↔ Services'} = 'Fila ↔ Serviço';
	$Self->{Translation}->{'Relation Queue and Service.'} = 'Associar Filas a Serviços';
	$Self->{Translation}->{'Change Services Relations for Queues'} = 'Alterar relações de Serviços para Fila';
	$Self->{Translation}->{'Change Queues Relations for Service'} = 'Alterar relações de Filas para Serviço';
	$Self->{Translation}->{'Change Services Relations for Type'} = 'Alterar relações de Serviços para Tipo';
	$Self->{Translation}->{'Change Types Relations for Service'} = 'Alterar relações de Tipos para Serviço';
	$Self->{Translation}->{'Manage Queue-Service Relations'} = 'Gerenciar Relações Filas-Serviços';
	$Self->{Translation}->{'Manage Type-Service Relations'} = 'Gerenciar Relações Tipos-Serviços';
	$Self->{Translation}->{'Agent and Customer'} = 'Agente e Cliente';
	$Self->{Translation}->{'Type and Service'} = 'Tipo e Serviço';
	$Self->{Translation}->{'Queue and Service'} = 'Fila e Serviço';
	$Self->{Translation}->{'Defines which relationship will be used Queue Service or Type-Service.'} = 'Define qual o relacionamento será utilizado Fila-Serviço ou Tipo-Serviço.';
	$Self->{Translation}->{'Defines which type (s) of user (s) will be applied to PickServiceRelation.'} = 'Define qual(ais) tipo(s) de usúario(s) será aplicado o PickServiceRelation.';
	$Self->{Translation}->{'Frontend module registration for the AdminTicketSettings object in the admin area.'} = 'Registro do módulo de front-end para o objeto AdminTicketSettings na área de administrador.';
}

1;