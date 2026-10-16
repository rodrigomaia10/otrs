# -- 
# Kernel/Language/es_ServiceRelation.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jsantos@serviceup.com.br
# --

package Kernel::Language::es_ServiceRelation;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

	# frontend template overview
	$Self->{Translation}->{'Change Service Relations for Queue'} = 'Cambiar las relaciones de servicio para la cola';
	$Self->{Translation}->{'Change Service Relations for Type'} = 'Cambiar relaciones de servicio por tipo';
	$Self->{Translation}->{'Change Queue Relations for Service'} = 'Cambiar las relaciones de cola para el servicio';
	$Self->{Translation}->{'Change Type Relations for Service'} = 'Cambiar las relaciones de tipo para el servicio';
	$Self->{Translation}->{'ACL module that allows the relations between Type-Service and Queue-Service.'} = 'Módulo ACL que permite las relaciones entre Type-Service y Queue-Service.';
	$Self->{Translation}->{'Filter for Types'} = 'Filtrar por tipos';
	$Self->{Translation}->{'Type  ↔ Services'} = 'Tipo ↔ Servicios';
	$Self->{Translation}->{'Relation Type and Service.'} = 'Tipo de relación y servicio.';
	$Self->{Translation}->{'Queue  ↔ Services'} = 'Cola ↔ Servicios';
	$Self->{Translation}->{'Relation Queue and Service.'} = 'Relación de cola y servicio.';
	$Self->{Translation}->{'Change Services Relations for Queues'} = 'Cambiar relaciones de servicios para colas';
	$Self->{Translation}->{'Change Queues Relations for Service'} = 'Cambiar las relaciones de colas para el servicio';
	$Self->{Translation}->{'Change Services Relations for Type'} = 'Cambiar relaciones de servicios por tipo';
	$Self->{Translation}->{'Change Types Relations for Service'} = 'Cambiar tipos de relaciones para el servicio';
	$Self->{Translation}->{'Manage Queue-Service Relations'} = 'Gestionar relaciones de servicio en cola';
	$Self->{Translation}->{'Manage Type-Service Relations'} = 'Gestionar relaciones de servicio tipo';
	$Self->{Translation}->{'Agent and Customer'} = 'Agente y cliente';
	$Self->{Translation}->{'Type and Service'} = 'Tipo y servicio';
	$Self->{Translation}->{'Queue and Service'} = 'Cola y servicio';
	$Self->{Translation}->{'Defines which relationship will be used Queue Service or Type-Service.'} = 'Define qué relación se utilizará Servicio de cola o Servicio tipo.';
	$Self->{Translation}->{'Defines which type (s) of user (s) will be applied to PickServiceRelation.'} = 'Define qué tipo (s) de usuario (s) se aplicarán a PickServiceRelation.';
	$Self->{Translation}->{'Frontend module registration for the AdminTicketSettings object in the admin area.'} = 'Registro de módulo de interfaz para el objeto AdminTicketSettings en el área de administración.';
}

1;