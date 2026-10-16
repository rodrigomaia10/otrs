# --
# Kernel/Language/pt_BR_InBoxKanban.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# edited/written by:
# * nfreitas@serviceup.com.br
# * poliveira@serviceup.com.br
# --

package Kernel::Language::pt_BR_InBoxKanban;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # FrontEnd
    $Self->{Translation}->{'Kanban Boards'} = 'Quadros Kanban';
    $Self->{Translation}->{'Added dynamic fields name to ordination in column of kanban'} = 'Adicione os nomes dos campos dinâmicos para ordenação dos chamados das colunas';
    $Self->{Translation}->{'BoardColor'} = 'Cor do quadro';
    $Self->{Translation}->{'My Boards'} = 'Meus Quadros';
    $Self->{Translation}->{'Add Kanban Boards'} = 'Adicionar Quadros do Kanban';
    $Self->{Translation}->{'Deleting the field and its data. This may take a while...'} = 'Excluindo o campo e seus dados. Isso pode demorar um pouco...';
    $Self->{Translation}->{'Do you really want to delete this Kanban? ALL associated data will be LOST!'} = 'Deseja realmente REMOVER esta coluna do kanban? Os dados associados serão apagados';
    $Self->{Translation}->{'This is the name to be shown on the screens.'} = 'Este nome será mostrado no título da coluna';
    $Self->{Translation}->{'This will be the order of the column in the table.'} = 'Esta será a ordem da coluna no quadro';
    $Self->{Translation}->{'Kanban Columns'} = 'Colunas do Kanban';
    $Self->{Translation}->{'Add board'} = 'Adicionar quadro';
    $Self->{Translation}->{'Boards'} = 'Quadros';
    $Self->{Translation}->{'Board'} = 'Quadro';
    $Self->{Translation}->{'Columns'} = 'Colunas';
    $Self->{Translation}->{'Filter for Kanban Boards'} = 'Filtros para quadros de Kanban';
    $Self->{Translation}->{'Boards Management'} = 'Gerenciamento de Quadros';
    $Self->{Translation}->{'Create Kanban Boards.'} = 'Criar quadros do kanban';
    $Self->{Translation}->{'Create and configure Kanban columns'} = 'Criação e configuração de colunas do kanban';
    $Self->{Translation}->{'Kanban column management'} = 'Gerenciamento de Colunas do Kanban';
    $Self->{Translation}->{'Delete this Kanban'} = 'Remover este Kanban';
    $Self->{Translation}->{'Copy this Kanban'} = 'Copiar este Kanban';
    $Self->{Translation}->{'Filter for column'} = 'Filtro por coluna';
    $Self->{Translation}->{'Kanban Column List'} = 'Lista de Colunas do Kanban';
    $Self->{Translation}->{'Add new Column for object'} = 'Adicionar uma nova coluna';
    $Self->{Translation}->{'Edit Column'} = 'Editar coluna';
    $Self->{Translation}->{'Column Settings'} = 'Configuração de Coluna';
    $Self->{Translation}->{'Admin Kanban'} = 'Administrar Colunas';
    $Self->{Translation}->{'Add'} = 'Adicionar';
    $Self->{Translation}->{'Add values ​​to display in Details'} = 'Adicione os valores para serem exibidos em Detalhes';
    $Self->{Translation}->{'Manual sorting'} = 'Ordenação manual';
    $Self->{Translation}->{'Ordination'} = 'Ordenação';
    $Self->{Translation}->{'Details'} = 'Detalhes';
    $Self->{Translation}->{'Command'} = 'Ordem';
    $Self->{Translation}->{'Change Responsible'} = 'Trocar Responsável';
    $Self->{Translation}->{'Sorry, you have not permission to do this action'} = 'Desculpe, você não tem permissão para executar esta ação.';
    $Self->{Translation}->{'Kanban Boards'} = 'Quadros de Kanban';
    $Self->{Translation}->{'Added Responsible in ticket card.'} = 'Adicionar mudança e exibição de Responsável no card do chamado';
    $Self->{Translation}->{'New Queue'} = 'Nova fila';
    $Self->{Translation}->{'Define the priorities colors'} = 'Defina as cores das prioridades';
    $Self->{Translation}->{'Board Label Color'} = 'Cor da fonte do quadro';
    $Self->{Translation}->{'Kanban time to reload view in minutes.'} = 'Tempo para o kanban atualizar a sua tela (em minutos)';
    $Self->{Translation}->{'Change Owner'} = 'Trocar Proprietário';
    $Self->{Translation}->{'Edit Kanban Boards'} = 'Editar Quadro do Kanban';
    $Self->{Translation}->{'Coluns fields per page'} = 'Colunas por página';
    $Self->{Translation}->{'Maximum ticket limit in column'} = 'Limite máximo de chamados na coluna';
    $Self->{Translation}->{'Parameters after moving to this column'} = 'Parâmetros após mover para esta coluna';
    $Self->{Translation}->{'You can add a new column, and after that add it to a frame, the object sets the search limit and cannot be changed after the column is created.'} = 'Você pode adicionar uma nova coluna, e após isso adicioná-la em um quadro.';
    $Self->{Translation}->{'To add the queue, select them in the filter.'} = 'Para adicionar a fila, selecione-as no filtro';
    $Self->{Translation}->{'State change by InBox Kanban'} = 'Estado alterado pelo InBox Kanban';
    $Self->{Translation}->{'Queue change by InBox Kanban'} = 'Fila alterada pelo InBox Kanban';
    $Self->{Translation}->{'Change Responsible'} = 'Alterar Responsável';
    $Self->{Translation}->{'Frontend module registration for the agent interface.'} = 'Registro frontend para o módulo na interface do atendente';
    $Self->{Translation}->{'Loader module registration for the agent interface.'} = 'Registro do módulo carregador para a interface do agente.';
    $Self->{Translation}->{'Frontend module AJAX handler for the agent interface.'} = 'Manipulador AJAX do módulo frontend para a interface do agente.';
    $Self->{Translation}->{'This column cannot be sorted manually. The calling card will be reordered.'} = 'Esta coluna não pode ser ordenada manualmente. O card do chamado será reordenado.';
    $Self->{Translation}->{'Parameters for the pages (in which the Kanbans are shown) of the Kanban overview.'} = 'Parâmetros para as páginas (nas quais os Kanbans são mostrados) da visão geral do Kanban.';

	$Self->{Translation}->{'Rules in use'} = 'Regras em uso';
	$Self->{Translation}->{'Severity order'} = 'Ordem de severidade';
	$Self->{Translation}->{'Descending'} = 'Descendente';
	$Self->{Translation}->{'Ascending'} = 'Ascendente';
	$Self->{Translation}->{'FullScreen'} = 'Tela cheia';
    $Self->{Translation}->{'View Settings'} = 'Configuração de Visão';
    $Self->{Translation}->{'To add the state, select them in the filter.'} = 'Para adicionar o estado, selecione-os no filtro';
    $Self->{Translation}->{'Add new board for object'} = 'Adicionar novo quadro';
    $Self->{Translation}->{'Add column'} = 'Adicionar coluna';
    $Self->{Translation}->{'New ticket'} = 'Novo chamado';
    $Self->{Translation}->{'Edit board'} = 'Editar quadro';
    $Self->{Translation}->{'Decrease Priority'} = 'Diminuir prioridade';
    $Self->{Translation}->{'Share'} = 'Dividir';
    $Self->{Translation}->{'Email Ticket'} = 'Chamado E-mail';
    $Self->{Translation}->{'Phone Ticket'} = 'Chamado Fone';
    $Self->{Translation}->{'Which article will be added by splitting.'} = 'Qual artigo será utilizado para dividir o chamado';
    $Self->{Translation}->{'First Article'} = 'Primeiro artigo';
    $Self->{Translation}->{'Last Article'} = 'Último artigo';
    $Self->{Translation}->{'Ticket Email'} = 'Chamado E-mail';
    $Self->{Translation}->{'Ticket Phone'} = 'Chamado Fone';
    $Self->{Translation}->{'Buttons to card'} = 'Botões para o card';
    $Self->{Translation}->{'Close ticket'} = 'Fechar chamado';
    $Self->{Translation}->{'Change Queues'} = 'Alterar fila';
    $Self->{Translation}->{'Add note'} = 'Adicionar nota';
    $Self->{Translation}->{'Classify'} = 'Classificar';
    $Self->{Translation}->{'Increase Priority'} = 'Aumentar prioridade';
    $Self->{Translation}->{'Start collapsed'} = 'Iniciar colapsada';
    $Self->{Translation}->{'By Phone'} = 'Via Fone';
    $Self->{Translation}->{'By Email'} = 'Via E-mail';
    $Self->{Translation}->{'Manage Boards'} = 'Gerenciar quadros';
    $Self->{Translation}->{'Manage Columns'} = 'Gerenciar colunas';
    $Self->{Translation}->{'Preview Only'} = 'Apenas visualização';
    $Self->{Translation}->{'Number of tickets'} = 'Número de chamados';
    $Self->{Translation}->{'Total of tickets'} = 'Total de chamados';
    $Self->{Translation}->{'By Process'} = 'Via Processo';
    $Self->{Translation}->{'Define the means of indexing tickets in Kanban'} = 'Definir o meio de indexação de chamados no Kanban';
    $Self->{Translation}->{'In real time'} = 'Em tempo real';
    $Self->{Translation}->{'By Cron'} = 'Pela cron';
    $Self->{Translation}->{'Process kanban reorder.'} = 'Reordena os chamados no kanban';
    $Self->{Translation}->{'Define how the ticket when be open by kanban'} = 'Defina como o chamado será aberto via kanban';
    $Self->{Translation}->{'Define what data will appear on the task card. Set 0 to disable or 1 to enable'} = 'Defina quais dados vão aparecer no card da tarefa. Defina 0 para desabilitar ou 1 para habilitar';
    $Self->{Translation}->{'SLA In'} = 'SLA Dentro';
    $Self->{Translation}->{'Add SLA icon for tickets that have a solution deadline.'} = 'Adicionar icone de SLA para chamados que possuem prazo de solução.';
    $Self->{Translation}->{'To add the priority, select them in the filter.'} = 'Para adicionar a prioridade, selecione-as no filtro';
    $Self->{Translation}->{'Priority change by InBox Kanban'} = 'Prioridade alterada pelo InBox Kanban';
    $Self->{Translation}->{'Add permission for the attendant to be able to move cards between rows / columns. Ex: ro, move_into, rw, ...'} = 'Adicione a permissão para o atendente poder mover os cards entre filas/colunas. Ex: ro, move_into, rw, ...';
    $Self->{Translation}->{'Define what dinamic field will appear on the task card'} = 'Define os campos dinâmicos que aparecerão no card';
    
    $Self->{Translation}->{'Kanban Tags'} = 'Etiquetas do kanban';
    $Self->{Translation}->{'Create Kanban tags'} = 'Crie etiquetas para o kanban';
    $Self->{Translation}->{'Tags Management'} = 'Gerenciamento de etiquetas';
    $Self->{Translation}->{'Add Tag'} = 'Adicionar etiqueta';
    $Self->{Translation}->{'Filter for Kanban tags'} = 'Filtro para etiquetas do kanban';
    $Self->{Translation}->{'Add Kanban Tag'} = 'Adicionar etiqueta do kanban';
    $Self->{Translation}->{'Tags'} = 'Etiquetas';
    $Self->{Translation}->{'Tag color'} = 'Cor da etiqueta';
    $Self->{Translation}->{'The tag already exists.'} = 'Etiqueta já cadastrada.';

    $Self->{Translation}->{'New Watch'} = 'Novo Monitoramento';
    $Self->{Translation}->{'Users'} = 'Atendentes';

    $Self->{Translation}->{'Error deleting column!'} = 'Erro ao excluir coluna!';
    $Self->{Translation}->{'You must disassociate the column from all boards before removing it.'} = 'Você deve desassociar a coluna de todos os quadros antes de removê-la.';
    $Self->{Translation}->{'Settings'} = 'Configurações';
    $Self->{Translation}->{'Save'} = 'Salve';
    $Self->{Translation}->{'Delete Kanban'} = 'Excluir Kanban';
    $Self->{Translation}->{'Solution SLA'} = 'SLA de solução';




    push @{ $Self->{JavaScriptStrings} // [] }, (
        'Details',
        'New Queue',
        'Change Owner',
        'Change Responsible',
        'Share',
        'Add Tag',
        'New Watch',
        'Error deleting column!',
        'Settings',
        'Save',
        'Do you really want to delete this Kanban? ALL associated data will be LOST!',
        'Delete Kanban',
    );

    return 1;
}

1;
