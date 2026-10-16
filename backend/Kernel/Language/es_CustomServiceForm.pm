# --
# Kernel/Language/es_CustomServiceForm.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Language::es_CustomServiceForm;

use strict;
use warnings;
use utf8;

sub Data {
 	my $Self = shift;

	# frontend template overview
	$Self->{Translation}->{'Service ↔ Custom Form'} = 'Servicio ↔ Formulario personalizado';
	$Self->{Translation}->{'Creation of customized forms for services.'} = 'Creación de formularios personalizados para servicios.';
	$Self->{Translation}->{'Service Form Management'} = 'Gestión de formularios de servicio';
	$Self->{Translation}->{'Add Service Form'} = 'Agregar formulario de servicio';
	$Self->{Translation}->{'Edit Service Form'} = 'Editar formulario de servicio';
	$Self->{Translation}->{'Filter for Form'} = 'Filtrar por formulario';
	$Self->{Translation}->{'Service Form Fields'} = 'Campos de formulario de servicio';
	$Self->{Translation}->{'Form content'} = 'Contenido del formulario';
	$Self->{Translation}->{'Admin Custom Service Form'} = 'Formulario de servicio personalizado';
	$Self->{Translation}->{'Enable editing of service form fields, after the ticket already created.'} = 'Habilite la edición de campos en el formulario de servicio, después de la llamada ya creada.';
	$Self->{Translation}->{'Close dialog'} = 'Cancelar y cerrar';
	$Self->{Translation}->{'Autoload for module AgentTicketEmail.'} = 'Carga automática para el módulo AgentTicketEmail.';
	$Self->{Translation}->{'Autoload for module CustomerTicketMessage.'} = 'Carga automática para el módulo CustomerTicketMessage.';
	$Self->{Translation}->{'Autoload for module AgentTicketPhone.'} = 'Carga automática para el módulo AgentTicketPhone.';
	$Self->{Translation}->{'This event module set dynamic fields values of the custom forms.'} = 'Este módulo de eventos establece valores de campos dinámicos de los formularios personalizados.';
	$Self->{Translation}->{'This event module clean dynamic fields values if service is change.'} = 'Este módulo de eventos limpia los valores de los campos dinámicos si el servicio cambia.';
	$Self->{Translation}->{'Download template'} = 'Descargar plantilla';
	$Self->{Translation}->{'Import Init'} = 'Iniciar importación';
	$Self->{Translation}->{'Export forms'} = 'Exportar formularios';
	$Self->{Translation}->{'Here you can upload a configuration file to import Service Forms into your system. The file must be in .csv format and following the csv exported by the module.'} = 'Aquí puede cargar un archivo de configuración para importar formularios de servicio a su sistema. El archivo debe estar en formato .csv y seguir el csv exportado por el módulo.';
	$Self->{Translation}->{'Copy this form'} = 'Copiar este formulario';
	$Self->{Translation}->{'Overwrite existing forms?'} = '¿Sobrescribir formularios existentes?';
	$Self->{Translation}->{'Edited'} = 'Editado';
	$Self->{Translation}->{'Status Import'} = 'Estado de importación';
}

1;
