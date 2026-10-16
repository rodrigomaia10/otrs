# --
# Kernel/Language/pt_BR_DynamicFieldFromSurvey.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::pt_BR_DynamicFieldFromSurvey;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{"Define a mapping between variables of the survey data (keys) and dynamic fields of a ticket (values). The purpose is to store survey data in ticket dynamic fields. The dynamic fields must be present in the system and should be enabled for AgentTicketFreeText, so that they can be set/updated manually by the agent. They musn't be enabled for AgentTicketPhone, AgentTicketEmail and AgentTicketCustomer. If they were, they would have precedence over the automatically set values."} = "Definir um mapeamento entre variáveis ​​dos dados da pesquisa (chaves) e campos dinâmicos de um ticket (valores). O objetivo é armazenar dados de pesquisa nos campos dinâmicos do ticket. Os campos dinâmicos devem estar presentes no sistema e devem estar ativados para AgentTicketFreeText, para que possam ser definidos / atualizados manualmente pelo agente.
Eles não podem ser ativados para AgentTicketPhone, AgentTicketEmail e AgentTicketCustomer. Se fossem, teriam precedência sobre os valores definidos automaticamente.";
    $Self->{Translation}->{"Define a mapping between variables of the survey response data (keys) and dynamic fields of a ticket (values). The purpose is to store survey response data in ticket dynamic fields. The dynamic fields must be present in the system and should be enabled for AgentTicketFreeText, so that they can be set/updated manually by the agent. They musn't be enabled for AgentTicketPhone, AgentTicketEmail and AgentTicketCustomer. If they were, they would have precedence over the automatically set values."} = "Defina um mapeamento entre as variáveis ​​dos dados de resposta da pesquisa (chaves) e os campos dinâmicos de um ticket (valores). O objetivo é armazenar os dados de resposta da pesquisa nos campos dinâmicos do ticket. Os campos dinâmicos devem estar presentes no sistema e devem estar ativados para AgentTicketFreeText, para que possam ser definidos / atualizados manualmente pelo agente.
Eles não podem ser ativados para AgentTicketPhone, AgentTicketEmail e AgentTicketCustomer. Se fossem, teriam precedência sobre os valores definidos automaticamente.";
}

1;