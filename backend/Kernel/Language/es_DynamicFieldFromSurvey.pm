# --
# Kernel/Language/es_DynamicFieldFromSurvey.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dparavani@serviceup.com.br
# --

package Kernel::Language::es_DynamicFieldFromSurvey;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{"Define a mapping between variables of the survey data (keys) and dynamic fields of a ticket (values). The purpose is to store survey data in ticket dynamic fields. The dynamic fields must be present in the system and should be enabled for AgentTicketFreeText, so that they can be set/updated manually by the agent. They musn't be enabled for AgentTicketPhone, AgentTicketEmail and AgentTicketCustomer. If they were, they would have precedence over the automatically set values."} = 
        "Defina una asignación entre las variables de datos de búsqueda (claves) y los campos dinámicos (valores) de un ticket. El objetivo es almacenar datos de búsqueda en los campos dinámicos del ticket. Los campos dinámicos deben estar presentes en el sistema y deben estar habilitados para AgentTicketFreeText para que el agente pueda configurarlos/actualizarlos manualmente.";
    $Self->{Translation}->{"Define a mapping between variables of the survey response data (keys) and dynamic fields of a ticket (values). The purpose is to store survey response data in ticket dynamic fields. The dynamic fields must be present in the system and should be enabled for AgentTicketFreeText, so that they can be set/updated manually by the agent. They musn't be enabled for AgentTicketPhone, AgentTicketEmail and AgentTicketCustomer. If they were, they would have precedence over the automatically set values."} = 
        "Defina una asignación entre las variables de datos de respuesta de la encuesta (claves) y los campos dinámicos (valores) de un ticket. El objetivo es almacenar datos de respuesta a la encuesta en los campos dinámicos del ticket. Los campos dinámicos deben estar presentes en el sistema y deben estar habilitados para AgentTicketFreeText para que el agente pueda configurarlos/actualizarlos manualmente.";
}

1;