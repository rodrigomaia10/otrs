# --
# Kernel/Language/pt_BR_DynamicFieldTable.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@beonup.com.br
# * lcavalheiro@serviceup.com.br
# * ykanegae@serviceup.com.br
# --

package Kernel::Language::pt_BR_DynamicFieldTable;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    
    # Template: AdminDynamicFieldTable
    $Self->{Translation}->{'Column'} = 'Coluna';
    $Self->{Translation}->{'Mask Settings'} = 'Configurações de Máscara';
    $Self->{Translation}->{'Sum Settings'} = 'Configurações de Somatória';
    $Self->{Translation}->{'Edition Permissions'} = 'Permissões de Edição';
    $Self->{Translation}->{'Text Mask Settings'} = 'Configurações de Máscaras de Texto';
    $Self->{Translation}->{'Monetary Mask Settings'} = 'Configurações de Máscaras Monetárias';
    $Self->{Translation}->{'Currency'} = 'Moeda';
    $Self->{Translation}->{'Negative'} = 'Negativo';    
    $Self->{Translation}->{'Sum Columns'} = 'Somar Colunas';
    $Self->{Translation}->{'Sum Rows'} = 'Somar Linhas';
    $Self->{Translation}->{'Columns'} = 'Colunas';
    $Self->{Translation}->{'States to Disable'} = 'Estados a Desabilitar';
    $Self->{Translation}->{'Changing the column data its necessary select again the columns to be sum.'} = 'Ao alterar os dados das colunas é necessário selecionar novamente as colunas a serem somadas.';
    $Self->{Translation}->{'Selecting to add the rows will use the columns selected above in Add Columns.'} = 'Ao selecionar para somar as linhas será utilizado as colunas selecionadas acima em Somar Colunas.';
    $Self->{Translation}->{'States which the table will be disabled to edition.'} = 'Estados em que a tabela será desabilitada para edição.';
    $Self->{Translation}->{'Insert a name for the column, a data type and for List insert the possible options (add item list separate by semicolon).'} = 'Insira o nome para a coluna, o tipo de dado e para Lista insira as opções possíveis (adiconar itens separados por ponto e virgula).';
    $Self->{Translation}->{'Column sum settings'} = 'Configuração de soma de colunas';
    $Self->{Translation}->{'Row sum settings'} = 'Configuração de soma de linhas';
    $Self->{Translation}->{'Operation Settings'} = 'Configuração de operações de colunas';
    $Self->{Translation}->{'Operation'} = 'Operação';
    $Self->{Translation}->{'Dynamic Field'} = 'Campo Dinâmico';
    $Self->{Translation}->{'Info DynamicFieldTable'} = 'Informações - Campo Dinâmico de Tabela';
    $Self->{Translation}->{'DynamicFieldTable'} = 'Campo Dinâmico de Tabela';
    $Self->{Translation}->{'View DynamicFieldTable'} = 'Visualização';
    $Self->{Translation}->{'AgentTicketZoom widget that displays the DynamicFieldTable.'} = 'Visualização de Widget que exibe as informações do campo dinâmico de tabela.';
    $Self->{Translation}->{'Show link to edit dynamic field TimeAccounted.'} = 'Mostrar link para editar o campo dinâmico TimeAccounted.';
    $Self->{Translation}->{'Change'} = 'Alterar';
    $Self->{Translation}->{'Field'} = 'Campo';
    $Self->{Translation}->{'To view'} = 'Visualizar';

    # Perl Module: AdminDynamicFieldTable    
    $Self->{Translation}->{'Numeric'} = 'Numérico';
    $Self->{Translation}->{'Mask'} = 'Máscara';
    $Self->{Translation}->{'Text (Mask)'} = 'Texto (Máscara)';
    $Self->{Translation}->{'Monetary'} = 'Monetária';
    $Self->{Translation}->{'Move Up'} = 'Mover Acima';
    $Self->{Translation}->{'Editable by'} = 'Editável por';
    
    # SysConfig
    $Self->{Translation}->{'ITIN'} = 'CPF';
    $Self->{Translation}->{'CNPJ'} = 'CNPJ';
    $Self->{Translation}->{'Zip Code'} = 'CEP';
    $Self->{Translation}->{'Table'} = 'Tabela';
    $Self->{Translation}->{'Creates the structure of the dynamic field table to be displayed in the GUI.'} = 'Cria a estrutura dos campos dinâmicos tabela a serem exibidos na GUI.';
    $Self->{Translation}->{'Configuration to store the sum columns on DynamicField. Set the key as the table name and define the content as the columns that will be summed with the following format: {"Column1":"DynamicField_Column1","Column2":"DynamicField_Column2"}.'} = 'Configuração para armazenar as colunas de soma no DynamicField. Defina a chave como o nome da tabela e defina o conteúdo como as colunas que serão somadas com o seguinte formato: {"Coluna1": "DynamicField_Coluna1", "Coluna2": "DynamicField_Coluna2"}.';
    $Self->{Translation}->{'Task to remove temporary data from the database.'} = 'Tarefa para remover dados tempoários do banco de dados.';
    $Self->{Translation}->{'Set the possible masks to be displayed.'} = 'Defina as máscaras possíveis a serem exibidas.';
    $Self->{Translation}->{'Defines whether the list type column options will be sorted.'} = 'Define se as opções da coluna do tipo lista serão ordenadas.';

    # DynamicFieldTableRender
    $Self->{Translation}->{'Format Export'} = 'Formato de Exportação';
    $Self->{Translation}->{'Select the format export.'} = 'Selecione um formato para exportação.';
    $Self->{Translation}->{'RowTotal'} = 'TOTAL';
    $Self->{Translation}->{'Attention!'} = 'Atenção!';
    $Self->{Translation}->{'All fields in the table must be completed!'} = 'Todos os campos da tabela devem ser preenchidos!';
    $Self->{Translation}->{'Show table'} = 'Mostrar tabela';

    # Config
    $Self->{Translation}->{'Frontend module registration for the agent interface.'} = 'Registro do módulo para a interface do agente.';
    $Self->{Translation}->{'Loader module registration for the agent interface.'} = 'Registro do módulo de carregamento para a interface do agente.';
    $Self->{Translation}->{'DynamicField backend registration.'} = 'Registro do Campo dinâmico.';
    $Self->{Translation}->{'Creates the structure of the dynamic field table to be displayed in the GUI'} = 'Cria a estrutura da tabela de campos dinâmicos a ser exibida';
    $Self->{Translation}->{'Frontend module registration for the customer interface.'} = 'Registro do módulo para a interface do cliente.';
    $Self->{Translation}->{'Set the possible masks to be displayed.'} = 'Defina as possíveis máscaras a serem exibidas.';
    $Self->{Translation}->{'Frontend module registration for the DynamicFieldTable.'} = 'Registro de módulo para o campo dinâmico de Tabela.';
    $Self->{Translation}->{'Configuration to store the sum columns on DynamicField. Set the key as the table name and define the content as the columns that will be summed with the following format: {"Column1":"DynamicField_Column1","Column2":"DynamicField_Column2"}.'} = 'Configuração para armazenar as colunas de soma no DynamicField. Defina a chave como o nome da tabela e defina o conteúdo como as colunas que serão somadas com o seguinte formato: {"Column1": "DynamicField_Column1", "Column2": "DynamicField_Column2"}.';
    $Self->{Translation}->{'Defines whether the column must be or not in sum row. If empty, all columns will be considered. The label must consist of {field_label}_{field_property_name} EX: Quantity Materials_Quantity.'} 
        = 'Define se a coluna deve estar ou não na linha de soma. Se estiver vazia, todas as colunas serão consideradas. O rótulo deve consistir em {rotulo_campo_dinamico}_{propriedade_campo_dinamico} EX: Quantidade Materiais_Quantidade';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'Attention!',
        'All fields in the table must be completed!',
    );

    return 1;
}

1;