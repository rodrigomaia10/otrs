# --
# Kernel/Language/es_CustomModuleGenericAgent.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jguedes@serviceup.com.br
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::es_CustomModuleGenericAgent;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

	$Self->{Translation}->{'Ticket condition and alteration parameters.'} = 'Estado del billete y parámetros de alteración.';
	$Self->{Translation}->{'Change of state due to change of the ticket parent'} = 'Cambio de estado debido al cambio del llamado padre';
	$Self->{Translation}->{'Priority update from "%s" to "%s" (InBox CustomModuleGenericAgent)'} =  'La prioridad cambió de "%s" a "%s" (InBox CustomModuleGenericAgent).';
    $Self->{Translation}->{'Define the names of the dynamic drop-down fields that will have their keys used for multiplication.'} = 'Defina los nombres de los campos desplegables dinámicos que tendrán sus claves utilizadas para la multiplicación.';
	$Self->{Translation}->{'Set the names of the priorities in the key and in the value the total value of the multiplication to enter this priority.'} = 'Configure los nombres de las prioridades en la clave y en el valor el valor total de la multiplicación para ingresar esta prioridad.';
	$Self->{Translation}->{'In the first key enter the state, then the cities and their SLAs. Used in SetSLAByDFValueConfig Generic Agent.'} = 'En la primera clave ingrese el estado, luego las ciudades y sus SLA. Se utiliza en el agente genérico SetSLAByDFValueConfig.';
	$Self->{Translation}->{'Child ticket status has been changed!'} = '¡El estado del billete infantil ha cambiado!';
	$Self->{Translation}->{'The ticket %s has been updated to status %s.'} = 'El ticket %s se ha actualizado al estado %s.';
	$Self->{Translation}->{'Assign the distance as a key and the SLA that will be assigned as a value.'} = 'Asigne la distancia como clave y el SLA que se asignará como valor.';
}

1;
