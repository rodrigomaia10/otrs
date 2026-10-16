# --
# Kernel/Language/es_ServiceTemplate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::Language::es_ServiceTemplate;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AgentFAQAdd
    $Self->{Translation}->{'Service <-> Template'} = 'Servicio <-> Plantilla';
    $Self->{Translation}->{'Preference field mapping to screen.'} = 'Asignación de campos de preferencia a la pantalla.';
    $Self->{Translation}->{'Service Template Management'} = 'Gestión de plantillas de servicio';
    $Self->{Translation}->{'Add Service Template'} = 'Agregar plantilla de servicio';
    $Self->{Translation}->{'Edit Service Template'} = 'Agregar plantilla de servicio';
    $Self->{Translation}->{'There is no available %s!'} = '¡No hay %s disponible!';
    $Self->{Translation}->{'Setting up a new service will overwrite any text. Do you really want to continue?'} = 'La configuración de un nuevo servicio sobrescribirá cualquier texto. ¿De verdad quieres continuar?';
    $Self->{Translation}->{'Link service to template.'} = 'Vincular el servicio a la plantilla.';

    $Self->{Translation}->{'Here you can upload a configuration file to import service templates to your system. The file needs to be in .yml format as exported by the service template editor module.'} = 'Aquí puede cargar un archivo de configuración para importar Plantillas de servicio a su sistema. El archivo debe estar en formato .yml exportado por el módulo de edición de Plantillas de servicio.';
    $Self->{Translation}->{'Export templates'} = 'Modelos de exportación';
    $Self->{Translation}->{'Export this Service Template'} = 'Exportar esta plantilla de servicio';
    $Self->{Translation}->{'Overwrite existing templates?'} = '¿Sobrescribir plantillas existentes?';
    $Self->{Translation}->{'Import templates configuration(s)'} = 'Importar configuración(es) de plantilla';
    $Self->{Translation}->{'The following Service Templates have been added successfully: %s'} = 'Se han agregado correctamente las siguientes plantillas de servicio: %​​s';
   	$Self->{Translation}->{'The following Service Templates have been updated successfully: %s'} = 'Las siguientes plantillas de servicio se han editado correctamente: %s';
	$Self->{Translation}->{'Service Templates could not be Imported due to a unknown error, please check Znuny logs for more information'} = 'Las plantillas de servicio no se pudieron importar debido a un error desconocido, consulte los registros de Znuny para obtener más información.';
	$Self->{Translation}->{'There where errors adding/updating the following Service Templates: %s. Please check the log file for more information.'} = 'Hubo errores al agregar/actualizar las siguientes plantillas de servicio: %​​s. Consulte el archivo de registro para obtener más información.';


    push @{ $Self->{JavaScriptStrings} // [] }, (
        'No',
        'Ok',
        'Settings',
        'Submit',
        'Yes',
        'Setting up a new service will overwrite any text. Do you really want to continue?'
    );
}

1;
