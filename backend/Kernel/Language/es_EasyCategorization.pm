# --
# Kernel/Language/es_EasyCategorization.pm
# Copyright (C) 2019 Service Up http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * nfreitas@serviceup.com.br
# * ccresencio@serviceup.com.br
# * poliveira@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * dparavani@serviceup.com.br
# * gbolsoni@serviceup.com.br
# --

package Kernel::Language::es_EasyCategorization;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    $Lang->{'Module to show ticket categorization.'} = 'Módulo de categorización fácil';
    $Lang->{'AgentTicketZoom widget that displays the amount of each associated.'} = 'Visualización del widget AgentTicketZoom ';
    $Lang->{'Easy to classify your tickets.'} = 'Fácil categorización para llamadas';
    $Lang->{'Easy Categorization'} = 'Categorización fácil';
    $Lang->{'Easy categorization for the service.'} = 'Servicio en categorización fácil';
    $Lang->{'Easy categorization for the type.'} = 'Escribe una categorización fácil.';
    $Lang->{'Easy categorization for the priority.'} = 'Prioridad en la categorización fácil.';
    $Lang->{'Easy categorization for the state.'} = 'Estado en fácil categorización.';
    $Lang->{'Easy Categorization for Suspended Dynamic Fields or Contract.'} = 'Fácil categorización para campos dinámicos del tipo suspendido o contrato ';
    $Lang->{'Frontend module registration for the agent interface.'} = 'Registro del módulo frontend para la interfaz del agente.';
    $Lang->{'Easy Categorization for Suspended Dynamic Fields or Contract.'} = 'Categorización sencilla para contratos o campos dinámicos suspendidos.';
    $Lang->{'Enter the status of the ticket in which the EasyCategorization fields are to be blocked'} = "Ingrese el estado del ticket en el que se van a bloquear los campos de EasyCategorization";
    $Lang->{'Easy categorization for the owner.'} = 'Fácil categorización para el propietario.';
    $Lang->{'Easy categorization for the queue.'} = 'Fácil categorización para la cola.';
    $Lang->{'Easy categorization for the responsible.'} = 'Fácil categorización para el responsable.';
    $Lang->{'Add button to manually save changes.'} = 'Agregar botón para guardar cambios manualmente';
    $Lang->{'Create article with easy categorization information when there is update.'} = 'Cree un artículo con información de categorización fácil cuando haya una actualización.';
    $Lang->{'Define the title of the article that will be created if InBox::EasyCategorization::Config###ArticleCreate is enabled.'} = 'Establezca el título del artículo que se creará si InBox::EasyCategorization::Config###ArticleCreate está habilitado.';
    $Lang->{'Update Easy Categorization'} = 'Actualizar categorización fácil';
    $Lang->{'Lock / Unlock'} = 'Bloqueo / Desbloqueo';
    $Lang->{'Easy categorization for the lock / unlock.'} = 'Fácil categorización para el bloqueo / desbloqueo.';
    $Lang->{'Locked'} = 'Bloqueado';
    $Lang->{'Unlocked'} = 'Desbloqueado';
    $Lang->{'Determines the possible ticket states in EasyCategorization.'} = 'Determina los posibles estados del ticket en EasyCategorization.';
    $Lang->{'Easy Categorization for Date, Text, Suspended Dynamic Fields or Contract.'} = 'Fácil categorización para campos dinámicos del tipo suspendido, texto, data o contrato';

    return 1;
}

1;
