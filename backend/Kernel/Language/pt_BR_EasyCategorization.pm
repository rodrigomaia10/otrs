# --
# Kernel/Language/pt_BR_EasyCategorization.pm
# Copyright (C) 2019 Service Up http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@beonup.com.br
# * pdias@beonup.com.br
# * mbernardo@beonup.com.br
# * ccresencio@serviceup.com.br
# * poliveira@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * dparavani@serviceup.com.br
# * gbolsoni@serviceup.com.br
# --

package Kernel::Language::pt_BR_EasyCategorization;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    $Lang->{'Module to show ticket categorization.'} = 'Módulo para Categorização Fácil';
    $Lang->{'AgentTicketZoom widget that displays the amount of each associated.'} = 'AgentTicketZoom widget display';
    $Lang->{'Easy to classify your tickets.'} = 'Categorização Fácil para chamados';
    $Lang->{'Easy Categorization'} = 'Categorização Fácil';
    $Lang->{'Easy categorization for the service.'} = 'Serviço na categorização fácil.';
    $Lang->{'Easy categorization for the type.'} = 'Tipo na categorização fácil.';
    $Lang->{'Easy categorization for the priority.'} = 'Prioridade na categorização fácil.';
    $Lang->{'Easy categorization for the state.'} = 'Estado na categorização fácil.';
    $Lang->{'Easy Categorization for Suspended Dynamic Fields or Contract.'} = 'Categorização fácil para os Campos Dinâmicos do tipo suspenso ou Contrato';
    $Lang->{'Frontend module registration for the agent interface.'} = 'Registro do módulo frontend para a interface do agente.';
    $Lang->{'Easy Categorization for Suspended Dynamic Fields or Contract.'} = "Categorização fácil para campos dinâmicos suspensos ou contrato.";
    $Lang->{'Enter the status of the ticket in which the EasyCategorization fields are to be blocked'} = "Insira o status do tíquete no qual os campos EasyCategorization devem ser bloqueados";
    $Lang->{'Easy categorization for the owner.'} = 'Categorização fácil para o proprietário.';
    $Lang->{'Easy categorization for the queue.'} = 'Categorização fácil para a fila.';
    $Lang->{'Easy categorization for the responsible.'} = 'Categorização fácil para o responsável.';
    $Lang->{'Add button to manually save changes.'} = 'Adicionar botão para salvar as alterações manualmente.';
    $Lang->{'Create article with easy categorization information when there is update.'} = 'Cria artigo com informações da categorização fácil quando houver atualização.';
    $Lang->{'Define the title of the article that will be created if InBox::EasyCategorization::Config###ArticleCreate is enabled.'} = 'Define o título do artigo que será criado se InBox::EasyCategorization::Config###ArticleCreate estiver habilitada.';
    $Lang->{'Update Easy Categorization'} = 'Atualização via categorização fácil';
    $Lang->{'Lock / Unlock'} = 'Bloquear / Desbloquear';
    $Lang->{'Easy categorization for the lock / unlock.'} = 'Categorização fácil para o bloqueio / desbloqueio.';
    $Lang->{'Locked'} = 'Bloqueado';
    $Lang->{'Unlocked'} = 'Desbloqueado';
    $Lang->{'Determines the possible ticket states in EasyCategorization.'} = 'Determina os possíveis estados do ticket no EasyCategorization.';
    $Lang->{'Easy Categorization for Date, Text, Suspended Dynamic Fields or Contract.'} = 'Categorização fácil para os Campos Dinâmicos do tipo suspenso, data, texto ou Contrato';
    
    return 1;
}

1;
