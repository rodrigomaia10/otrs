# --
# Kernel/Language/pt_BR_KPI.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * pdias@beonup.com.br
# * dsilva@serviceup.com.br
# * gtiburtino@beonup.com.br
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::pt_BR_KPI;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminKPI
	$Self->{Translation}->{'This is the name to be shown on the screens where the KPI is active.'} = 'Esse é o nome a ser mostrado nas telas em que o KPI está ativo.';
	$Self->{Translation}->{'This is the return format when click on chart.'} = 'Este é o formato de retorno quando clicar no gráfico.';
	$Self->{Translation}->{'Create and configure KPIs.'} = 'Criar e configurar KPIs.';
	$Self->{Translation}->{'KPI Management'} = 'Gerenciamento de KPI';
	$Self->{Translation}->{'KPI List'} = 'Lista de KPI';
	$Self->{Translation}->{'Add new KPI for object'} = 'Adicionar um novo KPI para o objeto';
	$Self->{Translation}->{"To add a new KPI, select the search return type from one of the object's list, the object defines the boundary of the search and it can't be changed after the KPI creation."} = 'Para adicionar um novo KPI, selecione o tipo de retorno da pesquisa de um dos objetos da lista, o objeto define o domínio da pesquisa e não pode ser alterado após a criação do KPI.';
	$Self->{Translation}->{'SLA Range'} = 'Faixa de consumo';
	$Self->{Translation}->{'First Response Range'} = 'Faixa de consumo de primeira resposta';
	$Self->{Translation}->{'Min/Max values'} = 'Valores mín/máx';
	$Self->{Translation}->{'Rules in use'} = 'Regras em uso';
	$Self->{Translation}->{'Severity order'} = 'Ordem de severidade';
	$Self->{Translation}->{'Severity'} = 'Severidade';
	$Self->{Translation}->{'Severity color'} = 'Cor da severidade';
	$Self->{Translation}->{'Descending'} = 'Descendente';
	$Self->{Translation}->{'Ascending'} = 'Ascendente';
	$Self->{Translation}->{'Till 25%'} = 'Até 25%';
	$Self->{Translation}->{'25% Till 50%'} = '25% até 50%';
	$Self->{Translation}->{'50% Till 75%'} = '50% até 75%';
	$Self->{Translation}->{'75% Till 100%'} = '75% até 100%';
	$Self->{Translation}->{'More than 100%'} = 'Mais de 100%';
	$Self->{Translation}->{'Filter for KPI'} = 'Filtrar por KPI';
	$Self->{Translation}->{'Filter for KPI Series'} = 'Filtrar por Conjuntos de KPI';
	$Self->{Translation}->{'You can add a new KPI, select the search return type from one of the object lists, the object sets the search limit, and can not be changed after KPI is created.'} = 'Você pode adicionar um novo KPI, selecionar o tipo de retorno de pesquisa de uma das listas do objeto, o objeto define o limite da pesquisa e não pode ser alterado após a criação do KPI.';
	$Self->{Translation}->{'SQL query'} = 'Consulta SQL';
	$Self->{Translation}->{'Copy'} = 'Copiar';
	$Self->{Translation}->{'Copy this KPI'} = 'Copiar este KPI';
	$Self->{Translation}->{'There was an error creating the KPI'} = 'Ocorreu um erro ao criar o KPI';
	$Self->{Translation}->{'Fields per page'} = 'Campos por página';
	$Self->{Translation}->{'There is another KPI with the same name.'} = 'Há outro KPI com o mesmo nome.';
	$Self->{Translation}->{'Chart with SQL Query'} = 'Gráfico com Consulta SQL';
	$Self->{Translation}->{'KPI - Chart with SQL Query'} = 'KPI - Gráfico com Consulta SQL';
	$Self->{Translation}->{'Add KPI - Chart with SQL Query'} = 'Adicionar KPI - Gráfico com Consulta SQL';
	$Self->{Translation}->{'Edit KPI - Chart with SQL Query'} = 'Editar KPI - Gráfico com Consulta SQL';
	$Self->{Translation}->{'Chart type to display.'} = 'Tipo de gráfico para exibição.';
	$Self->{Translation}->{'Chart'} = 'Gráfico';
	$Self->{Translation}->{'Graph Preview'} = 'Prévia do Gráfico';

	# Template: AdminSeries
	$Self->{Translation}->{'Create KPI series.'} = 'Criar conjuntos de KPI.';
    $Self->{Translation}->{'KPI Series'} = 'Conjuntos de KPI';
    $Self->{Translation}->{'Series Management'} = 'Gerenciamento de Conjunto';
    $Self->{Translation}->{'Add KPI Series'} = 'Adicionar conjunto';
    $Self->{Translation}->{'Edit KPI Series'} = 'Editar conjunto';
    $Self->{Translation}->{'Series'} = 'Conjunto';
    $Self->{Translation}->{'Add series'} = 'Adicionar conjunto';
    $Self->{Translation}->{'Please activate KPISeries first!'} = 'Por favor, ative KPISeries primeiramente!';
    $Self->{Translation}->{'Chart type'} = 'Tipo de gráfico';
    $Self->{Translation}->{'Bar'} = 'Barra';
    $Self->{Translation}->{'Funnel'} = 'Funil';
    $Self->{Translation}->{'Pie'} = 'Pizza';
    $Self->{Translation}->{'Column'} = 'Coluna';
    $Self->{Translation}->{'Column 1'} = 'Coluna 1';
    $Self->{Translation}->{'Column 2'} = 'Coluna 2';
    $Self->{Translation}->{'Column 3'} = 'Coluna 3';
    $Self->{Translation}->{'Text format'} = 'Formato do texto';
    $Self->{Translation}->{'Display text format'} = 'Formato do texto exibido';
    $Self->{Translation}->{'Percentage'} = 'Porcentagem';
    $Self->{Translation}->{'Default serie'} = 'Conjunto padrão';

    # Template: AdminKPISearch
    $Self->{Translation}->{'Ticket close time (current day)'} = 'Tempo de Fechamento do Chamado (dia atual)';
    $Self->{Translation}->{'Active filter'} = 'Filtro ativo';

    # Template: AdminKPITicket
    $Self->{Translation}->{'KPI - Ticket'} = 'KPI - Chamado';
    $Self->{Translation}->{'Add KPI - Ticket'} = 'Adicionar KPI - Chamado';
    $Self->{Translation}->{'Edit KPI - Ticket'} = 'Editar KPI - Chamado';
    $Self->{Translation}->{'KPI Settings'} = 'Configuração de KPI';
    $Self->{Translation}->{'View Settings'} = 'Configuração de Visão';
    $Self->{Translation}->{'Personalize'} = 'Personalizar';
    $Self->{Translation}->{'Min/Max SLA range values'} = 'Valores mín/máx do intervalo de SLA';
    $Self->{Translation}->{'Min/Max First Reply SLA Interval values'} = 'Valores mín/máx do intervalo de SLA de primeira resposta';
    $Self->{Translation}->{'Sets KPI color in complex sets'} = 'Define a cor do KPI nos conjuntos complexos';

    # Template: AdminKPISQLQuery
    $Self->{Translation}->{'KPI - SQL Query'} = 'KPI - Consulta SQL';
    $Self->{Translation}->{'Add KPI - SQL Query'} = 'Adicionar KPI - Consulta SQL';
    $Self->{Translation}->{'Edit KPI - SQL Query'} = 'Editar KPI - Consulta SQL';
    $Self->{Translation}->{'SQL Query'} = 'Consulta SQL';
    $Self->{Translation}->{'Test Query'} = 'Testar Consulta';
    $Self->{Translation}->{'Only queries are released'} = 'Apenas consultas estão liberadas';
    $Self->{Translation}->{'Ticket search'} = 'Busca de chamado';
    $Self->{Translation}->{'Serie type'} = 'Tipo do conjunto';

    # Template: AdminKPIChartSQLQuery
    $Self->{Translation}->{'KPI - SQL Query'} = 'KPI - Consulta SQL';
    $Self->{Translation}->{'Add KPI - SQL Query'} = 'Adicionar KPI - Consulta SQL';
    $Self->{Translation}->{'Edit KPI - SQL Query'} = 'Editar KPI - Consulta SQL';
    $Self->{Translation}->{'SQL Query'} = 'Consulta SQL';
    $Self->{Translation}->{'Test Query'} = 'Testar Consulta';
    $Self->{Translation}->{'Only queries are released'} = 'Apenas consultas estão liberadas';
    $Self->{Translation}->{'Ticket search'} = 'Busca de chamado';
    $Self->{Translation}->{'Serie type'} = 'Tipo do conjunto';
    $Self->{Translation}->{'Stacked Column'} = 'Coluna Empilhada';
    $Self->{Translation}->{'Stacked Bar'} = 'Barra Empilhada';
    $Self->{Translation}->{'Area'} = 'Área';
    $Self->{Translation}->{'Selected chart type incompatible with the generated table.'} = 'Tipo de gráfico selecionado incompatível com a tabela gerada.';
    $Self->{Translation}->{'Examples of tables by chart type'} = 'Exemplos de tabelas por tipo de gráfico';
    $Self->{Translation}->{'Area Chart'} = 'Gráfico de Área';
    $Self->{Translation}->{'Bar Chart'} = 'Gráfico de Barra';
    $Self->{Translation}->{'Column Chart'} = 'Gráfico de Coluna';
    $Self->{Translation}->{'Donut Chart'} = 'Gráfico de Dunot';
    $Self->{Translation}->{'Line Chart'} = 'Gráfico de Linha';
    $Self->{Translation}->{'Pie Chart'} = 'Gráfico de Pizza';
    $Self->{Translation}->{'Stacked Bar Chart'} = 'Gráfico de Barra Empilhada';
    $Self->{Translation}->{'Stacked Column Chart'} = 'Gráfico de Coluna Empilhada';
    $Self->{Translation}->{'Requirement: table must have at least three columns.'} = 'Requisito: tabela deverá ter no mínimo três colunas.';
    $Self->{Translation}->{'Requirement: table must have at least two columns.'} = 'Requisito: tabela deverá ter no mínimo duas colunas.';
    $Self->{Translation}->{'Requirement: table must have two columns.'} = 'Requisito: tabela deverá ter obrigatoriamente duas colunas.';

    # SysConfig
    $Self->{Translation}->{'ITIN'} = 'CPF';
    $Self->{Translation}->{'CNPJ'} = 'CNPJ';
    $Self->{Translation}->{'Zip Code'} = 'CEP';
    $Self->{Translation}->{'Add series option to KPIs'} = 'Adicionar opção de conjunto aos KPIs';
    $Self->{Translation}->{'Set the possible masks to be displayed.'} = 'Defina as máscaras possíveis a serem exibidas.';
    $Self->{Translation}->{'Frontend module registration for the KPIWidgetAJAXHandler.'} = 'Registro de módulo frontend para KPIWidgetAJAXHandler.';
    $Self->{Translation}->{'Parameters for the pages (in which the KPIs are shown) of the KPI overview.'} = 'Parâmetros para as páginas (nas quais os KPIs são mostrados) da visão geral do KPI.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the ticket widget overview of the agent interface . "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin. Note: Only Ticket attributes and Dynamic Fields (DynamicField_NameX) are allowed for DefaultColumns.'} = 'Parâmetros para o backend do painel da visão geral do widget de ticket da interface do agente. "Grupo" é usado para restringir o acesso ao plug-in (por exemplo, Grupo: admin; grupo1; grupo2;). "Padrão" determina se o plug-in está ativado por padrão ou se o usuário precisa ativá-lo manualmente. "CacheTTLLocal" é o tempo de cache em minutos para o plug-in. Nota: Somente atributos de ticket e campos dinâmicos (DynamicField_NameX) são permitidos para DefaultColumns.';

    $Self->{Translation}->{'Graphic'} = 'Gráfico';
    $Self->{Translation}->{'Numeric'} = 'Numérico';
    $Self->{Translation}->{'Indicators'} = 'Indicadores';
    $Self->{Translation}->{'Sets whether the black background button will appear'} = 'Define se o botão de fundo preto irá aparecer';

    # Survey
    $Self->{Translation}->{'Add KPI - Survey'} = 'Adicionar KPI - Pesquisa';
    $Self->{Translation}->{'Edit KPI - Survey'} = 'Editar KPI - Pesquisa';
    $Self->{Translation}->{'KPI - Survey'} = 'KPI - Pesquisa';
    $Self->{Translation}->{'Answers'} = 'Resposta';
    $Self->{Translation}->{'Metric'} = 'Métrica';
    $Self->{Translation}->{'Vote time'} = 'Hora do voto';
    $Self->{Translation}->{'Vote time between'} = 'Hora do voto entre';
    $Self->{Translation}->{'Create Time between'} = 'Hora de criação entre';
    $Self->{Translation}->{'Send Time between'} = 'Hora de envio entre';
    $Self->{Translation}->{' and '} = ' e ';
    $Self->{Translation}->{'Percentage'} = 'Porcentagem';

    # Config Item
    $Self->{Translation}->{'KPI - Config Items'} = 'KPI - Itens de configuração';
    $Self->{Translation}->{'Add KPI - Config Items'} = 'Adicionar KPI - Itens de configuração';
    $Self->{Translation}->{'Edit KPI - Config Items'} = 'Editar KPI - Itens de configuração';

    # KPI Scheduler 
    $Self->{Translation}->{'KPI Scheduler'} = 'Agendador KPI';
    $Self->{Translation}->{'Create KPI Scheduler.'} = 'Crie o Agendador de KPI.';
    $Self->{Translation}->{'Add scheduler'} = 'Adicionar agendador';
    $Self->{Translation}->{'KPI scheduler management'} = 'Gerenciamento de agendador';
    $Self->{Translation}->{'Add KPI Scheduler'} = 'Adicionar KPI Scheduler';
    $Self->{Translation}->{'Type export'} = 'Tipo de exportação';
    $Self->{Translation}->{'Prefix'} = 'Prefixo';
    $Self->{Translation}->{'Additional emails'} = 'E-mails adicionais';
    $Self->{Translation}->{'Template of email'} = 'Modelo do e-mail';
    $Self->{Translation}->{'Runtime Configuration'} = 'Configuração de tempo de execução';
    $Self->{Translation}->{'Days of Week'} = 'Dias da semana';
    $Self->{Translation}->{'Months'} = 'Meses';
    $Self->{Translation}->{'Consider Time Zone'} = 'Considerar o Fuso Horário';
    $Self->{Translation}->{'Add time zone.'} = 'Adicionar fuso horário.';
    $Self->{Translation}->{'May'} = 'Maio';
    $Self->{Translation}->{'Last execution'} = 'Última execução';
	$Self->{Translation}->{'Next execution'} = 'Próxima execução';
	$Self->{Translation}->{'Execute now'} = 'Executar agora';
	$Self->{Translation}->{'Execute'} = 'Executar';
	$Self->{Translation}->{'Manage KPIs'} = 'Gerenciar KPIs';
	$Self->{Translation}->{'Manage KPI Series'} = 'Gerenciar Conjuntos de KPIs';
	$Self->{Translation}->{'Export KPIs'} = 'Exportar KPIs';
	$Self->{Translation}->{'Overwrite existing KPIs?'} = 'Sobrescrever KPIs existentes?';
	$Self->{Translation}->{'Import KPIs configuration(s)'} = 'Importar configuração(ões) de KPI';
	$Self->{Translation}->{'Import series configuration(s)'} = 'Importar configuração(ões) de conjunto';
	$Self->{Translation}->{'The following KPIs have been added successfully: %s'} = 'Os seguintes KPIs foram adicionadas com sucesso: %s';
	$Self->{Translation}->{'The following KPIs series have been added successfully: %s'} = 'Os seguintes conjuntos foram adicionadas com sucesso: %s';
	$Self->{Translation}->{'The following KPIs have been updated successfully: %s'} = 'Os seguintes KPIs foram editados com sucesso: %s';
	$Self->{Translation}->{'The following KPIs series have been updated successfully: %s'} = 'Os seguintes conjuntos foram editados com sucesso: %s';
	$Self->{Translation}->{'KPIs could not be Imported due to a unknown error, please check OTRS logs for more information'} = 'Os KPIs não puderam ser importados devido a um erro desconhecido, verifique os logs do OTRS para obter mais informações';
	$Self->{Translation}->{'There where errors adding/updating the following KPIs: %s. Please check the log file for more information.'} = 'Houve erros ao adicionar/atualizar os seguintes KPIs: %s. Verifique o arquivo de log para obter mais informações.';
	$Self->{Translation}->{'Here you can upload a configuration file to import KPIs to your system. The file needs to be in .yml format as exported by the KPI editor module.'} = 'Aqui você pode fazer o envio de um arquivo de configuração para importar KPIs para o seu sistema. O arquivo precisa estar no formato .yml como exportado pelo módulo de edição de KPI.';
	$Self->{Translation}->{'Here you can upload a configuration file to import KPIs series to your system. The file needs to be in .yml format as exported by the KPI series editor module.'} = 'Aqui você pode fazer o envio de um arquivo de configuração para importar conjuntos de KPIs para o seu sistema. O arquivo precisa estar no formato .yml como exportado pelo módulo de edição de conjunto de KPI.';
	$Self->{Translation}->{'Attention, the statistics can take a long time to run. Avoid creating multiple chrons that will run at the same time.'} = 'Atenção, as estatísticas podem demorar para executar. Evite de criar múltiplas crons que serão executadas ao mesmo tempo.';
	$Self->{Translation}->{'Delete this Serie'} = 'Deletar este conjunto';
	$Self->{Translation}->{'Copy this Serie'} = 'Copiar este conjunto';
	$Self->{Translation}->{'Export this Serie'} = 'Exportar este conjunto';
	$Self->{Translation}->{'Do you really want to delete this serie? ALL associated data will be LOST!'} = 'Você realmente deseja excluir este conjunto? TODOS os dados associados serão PERDIDOS!';
	$Self->{Translation}->{'Do you really want to delete this KPI? ALL associated data will be LOST!'} = 'Você realmente deseja excluir este kpi? TODOS os dados associados serão PERDIDOS!';
	$Self->{Translation}->{'Delete serie'} = 'Deletar conjunto';
	$Self->{Translation}->{'Export series'} = 'Exportar conjuntos';
	$Self->{Translation}->{'Overwrite existing series?'} = 'Sobrescrever conjuntos existentes?';
	$Self->{Translation}->{'Deleting the field and its data. This may take a while...'} = 'Excluindo o campo e seus dados. Isso pode demorar um pouco...';
    
    $Self->{Translation}->{'Scale'} = 'Escala';
    $Self->{Translation}->{'Line'} = 'Linha';
    $Self->{Translation}->{'SLA Status'} = 'Estado do SLA';
    $Self->{Translation}->{'SLA Out'} = 'SLA Fora';
    $Self->{Translation}->{'SLA In'} = 'SLA Dentro';
    $Self->{Translation}->{'Day(s)'} = 'Dias(s)';
    $Self->{Translation}->{'Week(s)'} = 'Semana(s)';
    $Self->{Translation}->{'Month(s)'} = 'Mês(es)';
    $Self->{Translation}->{'Quarter(s)'} = 'Trimestre(s)';
    $Self->{Translation}->{'Semester(s)'} = 'Semestre(s)';
    $Self->{Translation}->{'Years(s)'} = 'Ano(s)';
    $Self->{Translation}->{'Jan'} = 'Jan';
    $Self->{Translation}->{'Feb'} = 'Fev';
    $Self->{Translation}->{'Mar'} = 'Mar';
    $Self->{Translation}->{'Apr'} = 'Abr';
    $Self->{Translation}->{'May'} = 'Maio';
    $Self->{Translation}->{'Jun'} = 'Jun';
    $Self->{Translation}->{'Jul'} = 'Jul';
    $Self->{Translation}->{'Aug'} = 'Ago';
    $Self->{Translation}->{'Sep'} = 'Set';
    $Self->{Translation}->{'Oct'} = 'Out';
    $Self->{Translation}->{'Nov'} = 'Nov';
    $Self->{Translation}->{'Dec'} = 'Dez';
    $Self->{Translation}->{'Trim'} = 'Trim';
    $Self->{Translation}->{'Sem'} = 'Sem';
    $Self->{Translation}->{'Showing %s tickets out of %s. According to the scale filter'} = 'Mostrando %s de %s chamados. De acordo com o filtro de escala';
    
    $Self->{Translation}->{'Ticket last article interaction'} = 'Interação do último artigo do ticket';
    $Self->{Translation}->{'Defines the columns of tables in HTML | If not filled in, it will have no effect'} = 'Define as colunas das tabelas em HTML | Se não for preenchido, não terá efeito';

    $Self->{Translation}->{'Data used to export the search result in Excel format.'} = 'Dados usados ​​para exportar o resultado da pesquisa em formato Excel.';
    $Self->{Translation}->{'Add the directory to save the files sent by the KPI Scheduler'} = 'Adicione o diretório para salvar os arquivos enviados pelo KPI Scheduler';
    $Self->{Translation}->{'Generate scheduled tickets.'} = 'Gere tickets programados.';

    # Admin Dashboard
    $Self->{Translation}->{'Edit Dashboard'} = 'Editar Dashboard';
    $Self->{Translation}->{'Add Dashboard'} = 'Adicionar Dashboard';
    $Self->{Translation}->{'Access dashboard'} = 'Acessar dashboard';
    $Self->{Translation}->{'Create Dashboard.'} = 'Criar Dashboard.';
    $Self->{Translation}->{'Agent Interface'} = 'Interface do Agente';
    $Self->{Translation}->{'Save and Continue'} = 'Salvar e Continuar';
    $Self->{Translation}->{'Customer Interface'} = 'Interface do Cliente';
    $Self->{Translation}->{'Filter for Dashboard'} = 'Filtrar por Dashboard';
    $Self->{Translation}->{'Dashboard not found!'} = 'Dashboard não encontrado!';
    $Self->{Translation}->{'Dashboard Management'} = 'Gerenciamento de Dashboard';
    $Self->{Translation}->{'Agent and Customer Interface'} = 'Interface do Agente/Cliente';
    $Self->{Translation}->{'A dashboard with this name already exists!'} = 'Já existe um dashboard com este nome!';
    $Self->{Translation}->{'The groups defined for the dashboard will override the groups defined in the KPI'} = 'Os grupos definidos para o dashboard irão sobrepor os grupos definidos no KPI';

    # AdminKPIDashboardEdit
    $Self->{Translation}->{'Save'} = 'Salvar';
    $Self->{Translation}->{'Contents'} = 'Conteúdo';
    $Self->{Translation}->{'Add Card'} = 'Adicionar Card';
    $Self->{Translation}->{'Card background'} = 'Cor do Card';
    $Self->{Translation}->{'Save Dashboard'} = 'Salvar Dashboard';
    $Self->{Translation}->{'Card Settings'} = 'Configurações do Card';
    $Self->{Translation}->{'Dashboard background'} = 'Cor do Dashboard';
    $Self->{Translation}->{'Dashboard Settings'} = 'Configurações do Dashboard';
    $Self->{Translation}->{'Dashboard saved successfully!'} = 'Dashboard salvo com sucesso!';
    $Self->{Translation}->{'Do you really want to delete this card?'} = 'Deseja realmente excluir este card?';

    # AdminKPIDashboardEdit
    $Self->{Translation}->{'Dashboard List'} = 'Lista de Dashboards';

    # AgentKPIDashboard
    $Self->{Translation}->{'Without permission! Contact the administrator.'} = 'Sem permissão! Entre em contato com o administrador.';

    # AgentDashboard
    $Self->{Translation}->{'Overview'} = 'Visão Geral';

    $Self->{Translation}->{'Customer IDs multiselect'} = 'CustomerID Multiclientes';
    $Self->{Translation}->{'Custom Link'} = 'Link Customizado';
    $Self->{Translation}->{'Columns'} = 'Colunas';
    
    
    push @{ $Self->{JavaScriptStrings} // [] }, (
        'Save',
        'Overview',
        'Contents',
        'Delete serie',
        'Card Settings',
        'Card background',
        'Dashboard Settings',
        'Dashboard background',
        'Dashboard saved successfully!',
        'Do you really want to delete this card?',
        'Deleting the field and its data. This may take a while...',
        'Do you really want to delete this KPI? ALL associated data will be LOST!',
        'Do you really want to delete this serie? ALL associated data will be LOST!',
    );    


    return 1;
} 

1;
