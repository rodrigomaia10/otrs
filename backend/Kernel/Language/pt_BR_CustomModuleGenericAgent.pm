# --
# Kernel/Language/pt_BR_CustomModuleGenericAgent.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jguedes@serviceup.com.br
# * nfreitaa@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::pt_BR_CustomModuleGenericAgent;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

	$Self->{Translation}->{'Ticket condition and alteration parameters.'} = 'Condições do ticket e parâmetros de alteração.';
	$Self->{Translation}->{'Change of state due to change of the ticket parent'} = 'Alteração de estado devido à mudança do chamado pai';
	$Self->{Translation}->{'Priority update from "%s" to "%s" (InBox CustomModuleGenericAgent)'} =  'Prioridade alterada de "%s" para "%s" (InBox CustomModuleGenericAgent).';
	$Self->{Translation}->{'Define the names of the dynamic drop-down fields that will have their keys used for multiplication.'} = 'Defina os nomes dos campos dinâmicos suspensos que terão suas chaves utilizadas para a multiplicação.';
	$Self->{Translation}->{'Set the names of the priorities in the key and in the value the total value of the multiplication to enter this priority.'} = 'Defina os nomes das prioridades na chave e no valor o valor total da multiplicação para entrar nesta prioridade.';
	$Self->{Translation}->{'In the first key enter the state, then the cities and their SLAs. Used in SetSLAByDFValueConfig Generic Agent.'} = 'Na primeira chave digite o estado, depois as cidades e seus SLAs. Usado no agente genérico SetSLAByDFValueConfig.';
	$Self->{Translation}->{'Child ticket status has been changed!'} = 'Estado do chamado filho foi alterado!';
	$Self->{Translation}->{'The ticket %s has been updated to status %s.'} = 'O chamado %s foi atualizado para o estado %s.';
	$Self->{Translation}->{'Assign the distance as a key and the SLA that will be assigned as a value.'} = 'Atribuir como chave a distancia e como valor o SLA que será atribuído.';
}

1;
