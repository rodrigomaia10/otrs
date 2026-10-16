# --
# Kernel/Language/pt_BR_CustomerPortal.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * jsantos@serviceup.com.br
# * dsilva@serviceup.com.br
# * jguedes@serviceup.com.br
# --

package Kernel::Language::pt_BR_CustomerPortal;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'General contract data shown in the additional information on the contract cards on the portal. Possible configurations: 0 = Disabled, 1 = Available.'} = 'Dados gerais do contrato mostrados nas informações adicionais nos cards de contrato no portal. Configurações possíveis: 0 = Desativado, 1 = Disponível.';
    $Self->{Translation}->{'General contract data shown in the additional information for contract cards on the portal. Possible configurations: 0 = Disabled, 1 = Available.'} = 'Dados gerais do contrato mostrados nas informações adicionais dos cards de contrato no portal. Configurações possíveis: 0 = Desativado, 1 = Disponível.';
    $Self->{Translation}->{'General contract data shown in the card views on the portal. Possible configurations: 0 = Disabled, 1 = Available.'} = 'Dados gerais do contrato mostrados nas visões de cards no portal. Configurações possíveis: 0 = Desativado, 1 = Disponível.';
    $Self->{Translation}->{'Dynamic fields that will be displayed on contract cards.'} = 'Campos dinâmicos que serão exibidos nos cards dos contratos.';
    $Self->{Translation}->{'Ticket Search'} = 'Procurar Chamados';
    $Self->{Translation}->{'Macro Management'} = 'Gerenciamento de Macros';
    $Self->{Translation}->{'Edit Macro'} = 'Editar Macro';
    $Self->{Translation}->{'Add Macro'} = 'Adicionar Macro';
    $Self->{Translation}->{'Filter for Macros'} = 'Filtrar por Macros';
    $Self->{Translation}->{'Macro Settings'} = 'Configurações da Macro';
    $Self->{Translation}->{'Macro name'} = 'Nome da Macro';
    $Self->{Translation}->{'This event module runs macros configured for the ticket.'} = 'Este módulo de evento executa macro configuradas para o ticket.';
    $Self->{Translation}->{'"%s" macro executed.'} = 'Macro "%s" executada.';
    $Self->{Translation}->{'By activating this option, the opening of a ticket will be based on the Contract and not on the Service. (InBox ContractManagement module must be installed)'} = 'Ativando esta opção a abertura de chamado, será baseada por Contrato e não pelo Serviço. (Módulo InBox ContractManagement deve estar instalado)';
    $Self->{Translation}->{'This service is not available to the logged in user.'} = 'Este serviço não está disponível para o usuário logado.';
    $Self->{Translation}->{'You are not allowed to access this service. Please contact the responsible team for more information.'} = 'Você não tem permissão para acessar esse serviço. Entre em contato com a equipe responsável para mais informações.';
    $Self->{Translation}->{'This contract is not available to the logged in user.'} = 'Este contrato não está disponível para o usuário logado.';
    $Self->{Translation}->{'This contract is not associated with the service informed in the URL. Please contact the responsible team for more information.'} = 'Este contrato não está associado ao serviço informado na URL. Entre em contato com a equipe responsável para mais informações.';
    $Self->{Translation}->{'This service is not available for that contract.'} = 'Este serviço não está disponível para esse contrato.';
    $Self->{Translation}->{'You are not allowed to access this Contract-Service association. Please contact the responsible team for more information.'} = 'Você não tem permissão para acessar essa associação de Contrato-Serviço. Entre em contato com a equipe responsável para mais informações.';
    $Self->{Translation}->{'Contract not selected.'} = 'Contrato não selecionado.';
    $Self->{Translation}->{'Call opening without a contract is not available. Please contact the responsible team for more information.'} = 'Abertura de chamado sem contrato não está disponível. Entre em contato com a equipe responsável para mais informações.';
    $Self->{Translation}->{"Ops... You don't have any associated contracts."} = 'Ops... Você não possui nenhum contrato associado.';
    $Self->{Translation}->{'Service'} = 'Serviço';
    $Self->{Translation}->{'Enter the Activity ID to hide the answer button from the ticket. The Activity ID must be informed as Key and as Value.'} = 'Informe o ID da Atividade para esconder o botão de responder do chamado.';
    $Self->{Translation}->{'Enter the activity IDs so that the activity button is hidden from view in the ticket. Key: process ID. Value: Activity ID.'} = 'Insira os ID das atividades para que o botão da atividade seja ocultado na visualização no chamado. Chave: ID do processo. Valor: ID da atividade.';
    $Self->{Translation}->{'Statistics'} = 'Estatísticas';
    $Self->{Translation}->{'Possible state mapping for filter on MyTicket screen.'} = 'Possível mapeamento de estado para filtro na tela MyTicket e CompanyTicket.';
    $Self->{Translation}->{'Possible state display name mapping for filter on MyTicket screen.'} = 'Possível mapeamento do nome de exibição do estado para o filtro na tela MyTicket.';
    $Self->{Translation}->{'Tickets'} = 'Chamados';
    $Self->{Translation}->{'Next Steps'} = 'Próximos Passos';
    $Self->{Translation}->{'New Ticket Process'} = 'Novo Chamado Via Processo';
    $Self->{Translation}->{'Enable new tickets process'} = 'Ativar Novo Chamado Via Processo';
    $Self->{Translation}->{'Text'} = 'Texto';
    $Self->{Translation}->{'Customize navbar texts'} = 'Personalizar textos da navbar';
    $Self->{Translation}->{'Define the size of service card'} = 'Definir o tamanho do card de serviço';
    $Self->{Translation}->{'Subject'} = 'Assunto';
    $Self->{Translation}->{'Reply'} = 'Responder';
    $Self->{Translation}->{'Square'} = 'Quadrado';
    $Self->{Translation}->{'Define the format of service card'} = 'Definir o formato do card de serviço';
    $Self->{Translation}->{'Rectangle'} = 'Retângulo';
    $Self->{Translation}->{'Send'} = 'Enviar';
    $Self->{Translation}->{'Subtitle'} = 'Legenda';
    $Self->{Translation}->{'Informations'} = 'Informações';
    $Self->{Translation}->{'Ticket priority'} = 'Prioridade do chamado';
    $Self->{Translation}->{'Created a new ticket!'} = 'Um novo chamado foi criado!';
    $Self->{Translation}->{'Apply CustomServiceForm in CustomerPortal.'} = 'Aplicar o CustomServiceForm no CustomerPortal ';
    $Self->{Translation}->{'With Number:'} = 'Seu número é:';
    $Self->{Translation}->{'Response added via CustomerPortal interface to ticket'} = 'Resposta adicionada via interface CustomerPortal para o chamado';
    $Self->{Translation}->{'Can\'t reopen ticket, not possible in this queue!'} = 'Não é possível reabrir o chamado nesta fila!';
    $Self->{Translation}->{'Create a new ticket!'} = 'Crie um novo chamado!';
    $Self->{Translation}->{'Reply from'} = 'Resposta de';
    $Self->{Translation}->{'File Manager'} = 'Gerenciador de arquivos';
    $Self->{Translation}->{'Last Modified'} = 'última modificação';
    $Self->{Translation}->{'Company Tickets'} = 'Chamados da empresa';
    $Self->{Translation}->{'My Tickets'} = 'Meus chamados';
    $Self->{Translation}->{'Enter an answer to submit'} = 'Informe uma resposta para enviar';
    $Self->{Translation}->{'News'} = 'Notícias';
    $Self->{Translation}->{'New Password'} = 'Nova senha';
    $Self->{Translation}->{'Verify Password'} = 'Verificar senha';
    $Self->{Translation}->{'Interface Language'} = 'Linguagem da interface';
    $Self->{Translation}->{'Change Password'} = 'Alterar senha';
    $Self->{Translation}->{'Password'} = 'Senha';
    $Self->{Translation}->{'Set the transition effect of service cards'} = 'Definir o efeito de transição dos cards de serviço';
    $Self->{Translation}->{'Select the main interface language.'} = 'Selecione o idioma principal da interface.';
    $Self->{Translation}->{'Current  Password'} = 'Senha atual';
    $Self->{Translation}->{'Enable service name as subject in ticket opening screen'} = 'Ativar o nome do serviço como assunto na tela de abertura de chamados';
    $Self->{Translation}->{'Set a new password by filling in your current password and a new one.'} = 'Defina uma nova senha ao preencher sua senha atual e uma nova.';
    $Self->{Translation}->{'Preferences'} = 'Preferências';
    $Self->{Translation}->{'Timezone'} = 'Fuso horário';
    $Self->{Translation}->{'Select your personal time zone. All times will be displayed according to this time zone.'} = 'Selecione seu fuso horário pessoal. Todos os horários serão exibidos conforme este fuso horário.';
    $Self->{Translation}->{'Service Favorite'} = 'Serviços favoritos';
    $Self->{Translation}->{'IconColor'} = 'Cor do ícone';
    $Self->{Translation}->{'ServiceColor'} = 'Cor do serviço';
    $Self->{Translation}->{'Icon Name'} = 'Nome do ícone';
    $Self->{Translation}->{'CustomerPortal ACL to add service parameters to call via attendant opening'} = 'ACL do CustomerPortal para adicionar os parametros do serviço no chamado via abertura do atendente';
    $Self->{Translation}->{'Enable ticket opening service parameters via attendant interface'} = 'Habilitar parâmetros do serviço na abertura de chamado via interface do atendente';
    $Self->{Translation}->{'Add News to the interface of the client. Exemple: NameToShow -> News text'} = 'Adicione notícias para a interface do cliente. Exemplo: Título -> Corpo';
    $Self->{Translation}->{'FrontendModuleRegistration for CustomerPortal module.'} = 'FrontendModuleRegistration para o módulo InBox CustomerPortal ';
    $Self->{Translation}->{'Set preferences to MyTickets Dashboard.'} = 'Definir preferências para dashboard "Meus Chamados"';
    $Self->{Translation}->{'Enables hour consumption on statistics screen.'} = 'Exibir horas de consumo de contrato em "Estatísticas"';
    $Self->{Translation}->{'Loader module registration for the agent interface.'} = 'Loader para registro do módulo';
    $Self->{Translation}->{'Set the queue to new tickets of CustomerPortal interface.'} = 'Adicione o nome da fila que deverá ser criado o chamado da interface CustomerPortal.';
    $Self->{Translation}->{'Set the SLA ID to new tickets of CustomerPortal interface.'} = 'Adicione o ID do SLA que deverá ser criado o chamado da interface CustomerPortal.';
    $Self->{Translation}->{'Set the CustomerLogo to CustomerPortal interface. Example: CustomerID -> path/to/logo.img'} = 'Adicione o logo do cliente para a interface CustomerPortal. Exemplo: CustomerId -> path/to/logo.img';
    $Self->{Translation}->{'Parameters of the example service attribute Color.'} = 'Parâmetros para a cor do card de serviço na interface CustomerPortal';
    $Self->{Translation}->{'Parameters of the service attribute Description.'} = 'Parâmetros para a descrição do card de serviço na interface CustomerPortal';
    $Self->{Translation}->{'Parameters of the service attribute icon color.'} = 'Parâmetros para a cor do ícone do card de serviço na interface CustomerPortal';
    $Self->{Translation}->{'Parameters of the example service attribute Icon.'} = 'Parâmetros para o ícone do card de serviço na interface CustomerPortal';
    $Self->{Translation}->{'Set the CustomerLogo default to CustomerPortal interface. Example: path/to/logo.img'} = 'Adicione o logo padrão do cliente para a interface CustomerPortal. Exemplo: path/to/logo.img';
    $Self->{Translation}->{"Add colors default to the user's navbar. Because it is a gradient, you can add 2 colors. If you want one, repeat it in both fields."} = 'Adicionar cores padrão para a navbar do usuário cliente. Por ser um gradiente, é possível adicionar 2 cores, sendo separados por ;. Caso queira somente uma, repita com ;';
    $Self->{Translation}->{"Add colors to the user's navbar. Because it is a gradient, you can add 2 colors. If you want one, repeat it in both fields."} = 'Adicionar cores para a navbar do usuário cliente. Por ser um gradiente, é possível adicionar 2 cores, sendo separados por ;. Caso queira somente uma, repita com ;';
    $Self->{Translation}->{'Add Customer NavBar Font Colors'} = 'Adicionar cores da fonte da NavBar lateral do cliente na interface CustomerPortal';
    $Self->{Translation}->{'Define the SLA to ticket'} = 'Define o SLA para o serviço';
    $Self->{Translation}->{'Define the type to ticket'} = 'Define o tipo para o serviço';
    $Self->{Translation}->{'Define the queue to ticket'} = 'Define a fila para o serviço';
    $Self->{Translation}->{'TicketType'} = 'Tipo';
    $Self->{Translation}->{'TicketSLA'} = 'SLA';
    $Self->{Translation}->{'TicketQueue'} = 'Fila';
    $Self->{Translation}->{'Outhers'} = 'Outros';
    $Self->{Translation}->{'Back'} = 'Voltar';
    $Self->{Translation}->{'Home'} = 'Início';
    $Self->{Translation}->{'Search'} = 'Procurar';
    $Self->{Translation}->{'Stats'} = 'Estatísticas';
    $Self->{Translation}->{'New Ticket'} = 'Novo Chamado';
    $Self->{Translation}->{'My Tickets - Tickets open by: '} = 'Meus Chamados - Chamados abertos por:';
    $Self->{Translation}->{'My Tickets'} = 'Meus Chamados';
    $Self->{Translation}->{'Select your personal time zone. All times will be displayed relative to this time zone.'} = 'Selecione seu fuso horário pessoal. Todos os horários serão exibidos em relação a esse fuso horário.';
    $Self->{Translation}->{'Main services'} = 'Principais Serviços';
    $Self->{Translation}->{'Set the subaction default to CustomerPortal interface. Example: Stats'} = 'Adicionar a Subaction após login do usuário. Exemplo: Stats';
    $Self->{Translation}->{'Add colors default and icon to service card.'} = 'Adicionar cores e ícone padrões para o card de serviço.';
    $Self->{Translation}->{'Add links to the interface of the client. Exemple: NameToShow -> http://link.com.br'} = 'Adicione links na interface do cliente. Exemplo: Nome para exibição -> http://link.com.br ';
    $Self->{Translation}->{'Ticket Priority'} = 'Prioridade';
    $Self->{Translation}->{'Form Description'} = 'Descrição do Formulário';
    $Self->{Translation}->{'Define the priority to ticket'} = 'Define a priridade para o serviço';
    $Self->{Translation}->{'Add description to card or not'} = 'Adicione ou não descrição no card';
    $Self->{Translation}->{'Without description'} = 'Sem descrição';
    $Self->{Translation}->{'With description'} = 'Com descrição';
    $Self->{Translation}->{'No record found'} = 'Nenhum registro encontrado';
    $Self->{Translation}->{'Showing 0 to 0 of 0 ticket'} = 'Mostrando 0 até 0 de 0 chamados';
    $Self->{Translation}->{'Loading...'} = 'Carregando...';
    $Self->{Translation}->{'Processing...'} = 'Processando...';
    $Self->{Translation}->{'Search records'} = 'Procurar registros';
    $Self->{Translation}->{'Next'} = 'Próximo';
    $Self->{Translation}->{'Previous'} = 'Anterior';
    $Self->{Translation}->{'Search records'} = 'Procurar registros';
    $Self->{Translation}->{'First'} = 'Primeiro';
    $Self->{Translation}->{'Last'} = 'Último';
    $Self->{Translation}->{'Showing'} = 'Mostrando';
    $Self->{Translation}->{'tickets'} = 'chamados';
    $Self->{Translation}->{'Showing from'} = 'Mostrando de';
    $Self->{Translation}->{'up until'} = 'até';
    $Self->{Translation}->{'in'} = 'de';
    $Self->{Translation}->{'Filtered from'} = 'Filtrados de';
    $Self->{Translation}->{'Showing results for'} = 'Exibindo resultados para';
    $Self->{Translation}->{'Search full text'} = 'Procurar por texto completo';
    $Self->{Translation}->{'FAQ(s)'} = 'FAQ(s)';
    $Self->{Translation}->{'Set as favorite'} = 'Definir como favorito';
    $Self->{Translation}->{'View FAQ(s)'} = 'Ver FAQ(s)';
    $Self->{Translation}->{'records'} = 'registros';
    $Self->{Translation}->{'Name/Title'} = 'Nome/Título';
    $Self->{Translation}->{'Type of object'} = 'Tipo do objeto';
    $Self->{Translation}->{'Open ticket'} = 'Abrir chamado';
    $Self->{Translation}->{'Showing 0 to 0 of 0 records'} = 'Mostrando de 0 até 0 registros';
    $Self->{Translation}->{'Customer Portal Cards'} = 'Cards do Customer Portal';
    $Self->{Translation}->{'Create and edit Customer Portal Cards'} = 'Crie e edite os cards do Customer Portal';
    $Self->{Translation}->{'Cards Management of Customer Portal'} = 'Gerenciamento de cards do Customer Portal';
    $Self->{Translation}->{'Add card'} = 'Adicionar Card';
    $Self->{Translation}->{'Mark as read'} = 'Marcar como lido';
    $Self->{Translation}->{'Mark as unread'} = 'Marcar como não lido';
    $Self->{Translation}->{'Enable customized cards by the attendant'} = 'Habilitar cards customizados pelo atendente';
    $Self->{Translation}->{'Enable DashBoard graphics. Being 1 - Enabled and 0 - Disabled'} = 'Habilitar gráficos do DashBoard. Sendo 1 - Habilitado e 0 - Desabilitado';
    $Self->{Translation}->{'Do you really want to delete this message?'} = 'Realmente deseja excluir esta mensagem?';
    $Self->{Translation}->{'You have already gone through all notifications'} = 'Você já percorreu todas as notificações';
    $Self->{Translation}->{'Define the FAQ to service'} = 'Define a FAQ para o serviço';
    $Self->{Translation}->{'Define the Owner to ticket'} = 'Define o propretário para o serviço';
    $Self->{Translation}->{'Define the Responsible to ticket'} = 'Define o responsável para o serviço';
    $Self->{Translation}->{'FAQ solved my problem!'} = 'A FAQ resolveu meu problema!';
    $Self->{Translation}->{"The FAQ did not solve my problem! I want to open a ticket"} = 'A FAQ não resolveu meu problema! Desejo abrir um chamado';
    $Self->{Translation}->{"Apply ServiceTemplate in CustomerPortal."} = 'Aplique o ServiceTemplate no CustomerPortal';
    $Self->{Translation}->{"Apply ShowHide in CustomerPortal."} = 'Aplique o ShowHide no CustomerPortal';
    $Self->{Translation}->{"Open link in a new tab"} = 'Abrir link em uma nova guia';
    $Self->{Translation}->{"Set the notification table size"} = 'Defina o tamanho da exibição de notificações';
    $Self->{Translation}->{"Set preferences to CompanyTickets Dashboard."} = 'Defina as preferências para o painel CompanyTickets.';
    $Self->{Translation}->{'Mapping of ticket types to display SLA on the client interface.'} = 'Mapeamento de tipos de chamado para exibiçào de SLA na interface do cliente.';
    $Self->{Translation}->{'Service Timeout'} = 'Tempo limite de atendimento';
    $Self->{Translation}->{'Service Time Spent'} = 'Tempo de atendimento realizado';
    $Self->{Translation}->{'Solution Timeout'} = 'Tempo limite de solução';
    $Self->{Translation}->{'Solution Time Spent'} = 'Tempo de solução realizado';
    $Self->{Translation}->{'Enter the customer id for viewing the SLA on the customer interface'} = 'Informe o id dos clientes para visualização do SLA na interfcace do cliente';
    $Self->{Translation}->{'Apply CustomerTicketZoomSLA in CustomerPortal.'} = 'Aplique o CustomerTicketZoomSLA no CustomerPortal';
    $Self->{Translation}->{'View the solution time for all customers in CustomerPortal.'} = 'Visualize o tempo de solução para todos os clientes no CustomerPortal.';
    $Self->{Translation}->{'View the first response time for all customers in CustomerPortal.'} = 'Visualize o tempo de primeira resposta de todos os clientes em CustomerPortal.';
    $Self->{Translation}->{'Pick an Icon'} = 'Escolha um ícone';
    $Self->{Translation}->{'Choose an icon'} = 'Escolha um ícone';
    $Self->{Translation}->{'To define'} = 'Definir';
    $Self->{Translation}->{'Consumption of Hours'} = 'Consumo de horas';
    $Self->{Translation}->{'hour(s)'} = 'hora(s)';
    $Self->{Translation}->{'tickets and registered(s)'} = 'chamados e registrada(s)';
    $Self->{Translation}->{'In the current month'} = 'No mês atual foram abertos';
    $Self->{Translation}->{'Apply ConsumptionOfHours in CustomerPortal.'} = 'Habilita o consumo de horas no CustomerPortal';
    $Self->{Translation}->{'Shows the number of hours in the months'} = 'Exibe a quantidade de hora(s) gasta(s) no mês atual';
    $Self->{Translation}->{'Shows the number of hours used in the last months.'} = 'Exibe a quantidade de hora(s) gasta(s) nos últimos meses';
    $Self->{Translation}->{'Vision of the last months'} = 'Visão dos últimos meses';
    $Self->{Translation}->{'Month/Year'} = 'Mês/Ano';
    $Self->{Translation}->{'Hours Used'} = 'Horas Utilizadas';
    $Self->{Translation}->{'Open Tickets'} = 'Chamados Abertos';
    $Self->{Translation}->{'Closed Tickets'} = 'Chamados Fechados';
    $Self->{Translation}->{'Jan'} = 'Jan';
    $Self->{Translation}->{'Feb'} = 'Fev';
    $Self->{Translation}->{'Mar'} = 'Mar';
    $Self->{Translation}->{'Apr'} = 'Abr';
    $Self->{Translation}->{'May'} = 'Mai';
    $Self->{Translation}->{'Jun'} = 'Jun';
    $Self->{Translation}->{'Jul'} = 'Jul';
    $Self->{Translation}->{'Aug'} = 'Ago';
    $Self->{Translation}->{'Sep'} = 'Set';
    $Self->{Translation}->{'Oct'} = 'Out';
    $Self->{Translation}->{'Nov'} = 'Nov';
    $Self->{Translation}->{'Dec'} = 'Dez';
    $Self->{Translation}->{'Hours spent per month'} = 'Horas gastas por mês';

    $Self->{Translation}->{'Enable archived tickets in CustomerPortal.'} = 'Habilitar chamados arquivados no CustomerPortal';
    $Self->{Translation}->{'Queues that should not be filtered in CustomerPortal'} = 'Filas que não devem ser filtradas no CustomerPortal';
    $Self->{Translation}->{'Enable ticket search parameter by date on CustomerPortal'} = 'Habilitar parâmetro de busca de chamados por data no CustomerPortal';
    $Self->{Translation}->{'Default number of days to search'} = 'Quantidade padrão de dias para busca';
    $Self->{Translation}->{'Numbers of days to search by customer. Ex: CustomerName -> 30'} = 'Números de dias para buscas, definido por cliente. Ex: CustomerName -> 30';

    $Self->{Translation}->{'Set the default values ​​for the buttons on the Service screen with FAQ'} = 'Defina os valores padrão para os botões na tela de serviço com FAQ';
    $Self->{Translation}->{'My Data'} = 'Meus Dados';
    $Self->{Translation}->{'Company Data'} = 'Dados da Empresa';
    $Self->{Translation}->{'Data updated successfully!'} = 'Dados atualizados com sucesso!';
    $Self->{Translation}->{'Error while updating data!'} = 'Erro ao atualizar os dados!';
    $Self->{Translation}->{'Download my personal data'} = 'Baixar meus dados pessoais';
    $Self->{Translation}->{'Information cannot be changed through this panel. Contact your administrator for more information.'} = 'As informações não podem ser alteradas através deste painel. Entre em contato com o administrator para maiores informações.';
    $Self->{Translation}->{'Edit Layout'} = 'Editar Layout';
    $Self->{Translation}->{'Logo'} = 'Logotipo';
    $Self->{Translation}->{'Define the image that will appear at the beginning of the sidebar.'} = 'Defina a imagem que irá aparecer no início da barra lateral.';
    $Self->{Translation}->{'Image path'} = 'Caminho da imagem';
    $Self->{Translation}->{'Preview in page'} = 'Visualizar no preview';
    $Self->{Translation}->{'Navigation bar color'} = 'Cor da barra de navegação';
    $Self->{Translation}->{'Background colors of the Customer Portal side menu.'} = 'Cores do fundo do menu lateral do Customer Portal.';
    $Self->{Translation}->{'It is possible to define a gradient of two colors.'} = 'É possível definir um gradiente de duas cores.';
    $Self->{Translation}->{'Top Color'} = 'Cor Superior';
    $Self->{Translation}->{'Bottom Color'} = 'Cor Inferior';
    $Self->{Translation}->{'Menu colors'} = 'Cores do menu';
    $Self->{Translation}->{'Side menu font colors.'} = 'Cores da fonte do menu lateral. ';
    $Self->{Translation}->{'Main menu'} = 'Menu principal';
    $Self->{Translation}->{'Submenu color'} = 'Cor do submenu';
    $Self->{Translation}->{'Username color'} = 'Cor do nome do usuário';
    $Self->{Translation}->{'User Exemple'} = 'Nome do Usuário';
    $Self->{Translation}->{'New ticket'} = 'Novo Chamado';
    $Self->{Translation}->{'Save Change'} = 'Salvar alterações';
    $Self->{Translation}->{'Apply show New Ticket in sidebar in CustomerPortal.'} = 'Exibir Novo Chamado na barra lateral do CustomerPortal.';
    $Self->{Translation}->{'This page is currently unavailable.'} = 'Esta página não está disponível no momento.';
    $Self->{Translation}->{'Please contact the responsible team for more information.'} = 'Entre em contato com a equipe responsável para mais informações.';
    $Self->{Translation}->{'Apply show FAQ in sidebar in CustomerPortal.'} = 'Aplique show FAQ na barra lateral do CustomerPortal.';
    $Self->{Translation}->{'Define my client user data report layout.'} = 'Definir layout do relatório meus dados do usuário cliente.';
    $Self->{Translation}->{'Fields to be displayed on the My Data tab. 0 - Hide, 1 - Display and allow changes, 2 - Display only.'} = 'Campos a serem exibidos na aba Meus Dados. 0 - Esconde, 1 - Exibe e permite alteração, 2 - Apenas exibe.';
    $Self->{Translation}->{'Registration of cards to be displayed on the My Data page.'} = 'Registro de cards a serem exibidos na pagina Meus Dados.';
    $Self->{Translation}->{'Edit the Customer Portal layout'} = 'Edite o layout do Customer Portal';
    $Self->{Translation}->{'Event responsible for setting the service values in the ticket. Set 1 to set the value or 0 to not set.'} = 'Evento responsável em setar os valores do serviço no chamado. Defina 1 para setar o valor ou 0 para não setar.';
    $Self->{Translation}->{'CustomerUser'} = 'Usuário Cliente';
    $Self->{Translation}->{'To view'} = 'Visualizar';
    $Self->{Translation}->{'Add the initial filter to the My Tickets table'} = 'Adicione o filtro inicial da tabela de Meus Chamados';
    $Self->{Translation}->{'Add the initial filter to the Company Tickets table'} = 'Adicione o filtro inicial da tabela de Chamados da Empresa';

    $Self->{Translation}->{'Time Units'} = 'Tempo Contabilizado';
    $Self->{Translation}->{'Order field'} = 'Ordem';
    $Self->{Translation}->{'Customize the title of CustomerPortal actions'} = 'Customiza o título das actions do CustomerPortal';
    $Self->{Translation}->{'Define the service icon.'} = 'Define o ícone do serviço.';
    $Self->{Translation}->{'Add dynamic field:'} = 'Adicione campo dinâmico:';
    $Self->{Translation}->{'Define the service color.'} = 'Define a cor do serviço';
    $Self->{Translation}->{'Define the service Icon Color.'} = 'Define a cor do ícone do serviço.';
    $Self->{Translation}->{'Define the service order. Enter an integer'} = 'Ordem de exibição do serviço. Informe um número inteiro.';
    $Self->{Translation}->{'Enables display of time accounted for in ticket information'} = 'Permite a exibição do tempo contabilizado nas informações do chamado.';
    
    $Self->{Translation}->{'Set the Background Image default to CustomerPortal interface. Example: path/to/logo.img'} = 'Defina o padrão da imagem de fundo para a interface CustomerPortal. Exemplo: caminho/para/logo.img';
    $Self->{Translation}->{'Background image'} = 'Imagem de fundo';
    $Self->{Translation}->{'Choose the field name and value present in the customer user registration so that the CompanyTickets menu can be displayed'} = 'Escolha o nome do campo e o valor presente no cadastro do usuário do cliente para que o menu CompanyTickets possa ser exibido';
    $Self->{Translation}->{'No permissions to view screen.'} = 'Sem permissões para ver a tela.';
    $Self->{Translation}->{'No permissions to view screen. Please contact the responsible team for more information.'} = 'Sem permissões para ver a tela. Entre em contato com a equipe responsável para mais informações.';

    $Self->{Translation}->{'Format of the article time display.'} = 'Formato da exibição do tempo do artigo.';
    $Self->{Translation}->{'Creation date'} = 'Data de criação';
    $Self->{Translation}->{'Minimize'} = 'Minimizar';
    $Self->{Translation}->{'Last Tickets'} = 'Últimos Chamados';
    $Self->{Translation}->{'Dynamic field value %s is invalid!'} = 'Valor do campo dinâmico %s é inválido!';
    $Self->{Translation}->{'Dynamic field %s is required!'} = 'O campo dinâmico %s é obrigatório!';
    $Self->{Translation}->{'Reply and Update'} = 'Responder e Atualizar';
    $Self->{Translation}->{'Update ticket data'} = 'Atualizar dados do chamado';
    $Self->{Translation}->{'Time recorded'} = 'Tempo registrado';
    $Self->{Translation}->{'Hides the next state button according to the service. Enter the service ID.'} = 'Esconde o botão de próximo estado de acordo com o serviço. Insira o ID do serviço.';
    $Self->{Translation}->{'Hides the next state button according to the state. Enter the state name.'} = 'Esconde o botão de próximo estado de acordo com o estado. Insira o nome do estado.';
    $Self->{Translation}->{'Consumption of Contract'} = 'Consumo de contrato';
    $Self->{Translation}->{'Type of Consumption'} = 'Tipo de Consumo';
    $Self->{Translation}->{'Contracted Hours'} = 'Horas Contratadas';
    $Self->{Translation}->{'Hours Consumed'} = 'Horas Consumidas';
    $Self->{Translation}->{'Percentage of Consumption'} = 'Porcentagem de Consumo';
    $Self->{Translation}->{'Consumption of Hours by Contract'} = 'Consumo de Horas por Contrato';
    $Self->{Translation}->{'You do not have permission to view this page.'} = 'Você não tem permissão para visualizar essa página.';
    $Self->{Translation}->{'Current month'} = 'Mês atual';
    $Self->{Translation}->{'Accounted Time'} = 'Tempo Registrado';
    $Self->{Translation}->{'Appointment Date'} = 'Data do Registro';
    $Self->{Translation}->{'Enable the option to download a report with the record of hours of tickets with contract.'} = 'Habilitar a opção de baixar um relatório com o registro de horas dos chamados com contrato.';
    $Self->{Translation}->{'Do not show'} = 'Não exibir';
    $Self->{Translation}->{'View the last 5 tickets'} = 'Exibir os últimos 5 chamados';
    $Self->{Translation}->{'View the last 10 tickets'} = 'Exibir os últimos 10 chamados';
    $Self->{Translation}->{'Do not show'} = 'Não exibir';
    $Self->{Translation}->{'System'} = 'Service Desk';
    $Self->{Translation}->{'Survey Age'} = 'Idade da Pesquisa';
    $Self->{Translation}->{'Defines the number of days that will be considered when searching for unanswered surveys. 0 will bring up all unanswered surveys.'} = 'Define o número de dias que será considerado na busca de pesquisas não respondidas. 0 irá trazer todas as pesquisas não respondidas.';
    $Self->{Translation}->{'Unanswered Surveys'} = 'Pesquisas não respondidas';
    $Self->{Translation}->{'Hides the consumed hours option if the customer has a contract.'} = 'Esconde a opção de horas consumidas se o cliente possuir um contrato.';
    $Self->{Translation}->{'Defines the name of the label that will be displayed on top of the text area when opening a ticket.'} = 'Define o nome da label que será exibida em cima da área de texto na abertura de chamado.';
    $Self->{Translation}->{'Displays the ImpactOperation dynamic field on the ticket opening screen.'} = 'Exibe o campo dinâmico ImpactOperation na tela de abertura de chamado.';
    $Self->{Translation}->{'Display last user tickets.'} = 'Exibir ultimos chamados do usuário.';
    $Self->{Translation}->{'Apply Consumption of Contract in CustomerPortal.'} = 'Aplicar Consumo de Contrato em CustomerPortal.';
    $Self->{Translation}->{'No data found'} = 'Nenhum dado encontrado';
    $Self->{Translation}->{'title'} = 'título';
    $Self->{Translation}->{'Search tickets'} = 'Procurar chamados';




    $Self->{Translation}->{'FAQ Categories'} = 'Categorias de FAQ';
    $Self->{Translation}->{'Define the service Description.'} = 'Defina a descrição do serviço.';
    $Self->{Translation}->{'Defines an image for the service. Accepts internal or external images.'} = 'Define uma imagem para o serviço. Aceita imagens internas ou externas.';
    $Self->{Translation}->{'Service Image'} = 'Imagem do serviço';
    $Self->{Translation}->{'2 - Enabled and in bold'} = '2 - Ativado e em negrito';
    $Self->{Translation}->{'How can we help?'} = 'Como podemos ajudar?';
    $Self->{Translation}->{'Browse the categories or use the search bar'} = 'Navegue pelas categorias ou utilize a barra de pesquisa';
    $Self->{Translation}->{'In the current month %s tickets were counted and %s hours were recorded'} = 'No mês atual %s chamados foram contabilizados e %s horas foram registradas';
    $Self->{Translation}->{'Edit Home Page'} = 'Editar Home Page';
    $Self->{Translation}->{'Quick access'} = 'Acesso rápido';
    $Self->{Translation}->{"Customize the Home Page with HTML and CSS in the 'Source Code' area. Use the examples below if necessary."} = "Personalize a Home Page com HTML e CSS na área 'Código-Fonte'. Utilize os exemplos abaixo caso necessário.";
    $Self->{Translation}->{"Central card with access buttons for internal and external links."} = "Card central com botões de acesso a links internos e externos.";
    $Self->{Translation}->{"Use this example"} = "Utilizar este exemplo";
    $Self->{Translation}->{"Access cards for internal and external links."} = "Cards de acesso a links internos e externos.";
    $Self->{Translation}->{"access cards"} = "Cards de acesso";
    $Self->{Translation}->{"Set portal menu type."} = "Defina o tipo do menu do portal.";
    $Self->{Translation}->{"Service card title color and style."} = "Cor e estilo do título dos cards de serviço.";
    $Self->{Translation}->{"Home page search center card."} = "Card central de busca da home page.";
    $Self->{Translation}->{"Central service search card."} = "Card central de busca de serviços.";
    $Self->{Translation}->{"Screens that will display the background image."} = "Telas que exibirão a imagem de fundo.";

    $Self->{Translation}->{"Displays the back button on the top menu."} = "Exibe o botão Voltar no menu superior.";
    $Self->{Translation}->{"Home page custom card position."} = "Posição do card personalizado da página inicial.";
    $Self->{Translation}->{"Above"} = "Acima";
    $Self->{Translation}->{"Below"} = "Abaixo";
    $Self->{Translation}->{"Side bar"} = "Menu lateral";
    $Self->{Translation}->{"Top bar"} = "Menu superior";
    $Self->{Translation}->{"Enables the queue filter in the hours consumption screen."} = "Habilita o filtro de fila na tela de consumo de horas.";
    $Self->{Translation}->{"Show the ImpactOperation dynamic field according to the service. Enter the service name."} = "Mostre o campo dinâmico ImpactOperation de acordo com o serviço. Digite o nome do serviço.";
    $Self->{Translation}->{"FAQ Only"} = "Somente FAQ";
    $Self->{Translation}->{"Service Only"} = "Somente Serviço";
    $Self->{Translation}->{"Standard Search"} = "Busca Padrão";
    $Self->{Translation}->{"Ticket Only"} = "Somente Chamados";
    $Self->{Translation}->{"Sets a default value in the search."} = "Define um valor padrão na pesquisa.";
    $Self->{Translation}->{"Portal form title style."} = "Estilo do titulo do formulário do portal.";
    $Self->{Translation}->{"Setting to show company calls to specific customers."} = "Configuração para mostrar chamadas da empresa para clientes específicos.";
    $Self->{Translation}->{"Defines the text that will be displayed in the article."} = "Define o texto que será exibido no artigo.";
    $Self->{Translation}->{"View preview of the article"} = "Exibir a prévia do artigo";
    $Self->{Translation}->{"View article subject"} = "Exibir o assunto do artigo";
    $Self->{Translation}->{"Transparent main card."} = "Card principal transparente.";
    $Self->{Translation}->{"Possible mapping for filter on MyTicket screen."} = "Possível mapeamento para filtro na tela MyTicket.";
    $Self->{Translation}->{"Possible mapping for filter on CompanyTickets screen."} = "Possível mapeamento para filtro na tela CompanyTickets.";
    $Self->{Translation}->{'Aware wish to continue'} = 'Estou ciente desejo continuar';
    $Self->{Translation}->{'Go to Surveys'} = 'Ir para pesquisas';
    $Self->{Translation}->{'Date submission of the survey'} = 'Data envio da pesquisa';
    $Self->{Translation}->{'Defines where the BlockTicketSurvey will be displayed.'} = 'Define onde o BlockTicketSurvey será exibido.';
    $Self->{Translation}->{'FrontendModuleRegistration for module.'} = 'Configuração para registrar o módulo.';
    $Self->{Translation}->{'Tell you how many days you want the search to have been sent.'} = 'quantos dias deseja que a Pesquisa tenha sido enviada.';
    $Self->{Translation}->{'Setting to set search IDs'} = 'Configuração para definir IDs de pesquisa';
    $Self->{Translation}->{'Enter message that will be displayed to the user'} = 'Digite mensagem que será exibida para o usuário';
    $Self->{Translation}->{'Please answer the questions below to continue with the opening of the so-called'} = 'Por favor, responda às perguntas abaixo para continuar com a abertura do chamado';
    $Self->{Translation}->{'Enter title message that will be displayed to the user'} = 'Digite mensagem de título que será exibida ao usuário';
    $Self->{Translation}->{'You have pending searches'} = 'Você tem pesquisas pendentes';
    $Self->{Translation}->{'Configuration to enable the module.'} = 'Configuração para habilitar o módulo.';
    $Self->{Translation}->{'Company Name'} = 'Nome da Empresa';
    $Self->{Translation}->{'Home Page'} = 'Página inicial';
    $Self->{Translation}->{'Home Page '} = 'Página inicial';
    $Self->{Translation}->{'New Ticket'} = 'Novo Chamado';
    $Self->{Translation}->{'New Ticket Process'} = 'Novo Chamado Via Processo';
    $Self->{Translation}->{'My Tickets'} = 'Meus Chamados';
    $Self->{Translation}->{'Company Tickets'} = 'Chamados da empresa';
    $Self->{Translation}->{'Other'} = 'Outros';
    $Self->{Translation}->{'Favorites Services'} = 'Serviços Favoritos';
    $Self->{Translation}->{'Notification'} = 'Notificações';
    $Self->{Translation}->{'Hour Consumption'} = 'Consumo de Horas';
    $Self->{Translation}->{'Contract Consumption'} = 'Consumo de Contrato';
    $Self->{Translation}->{'The FAQ did not solve my problem! I want to open a ticket'} = 'A FAQ não resolveu meu problema! Desejo abrir um chamado';
    $Self->{Translation}->{'The FAQ solved my problem!'} = 'A FAQ resolveu meu problema!';
    $Self->{Translation}->{'My Data'} = 'Meus Dados';
    $Self->{Translation}->{'Preferences'} = 'Preferências';
    $Self->{Translation}->{'Research'} = 'Pesquisa';
    $Self->{Translation}->{'Service FAQ'} = 'FAQ Do Serviço';
    $Self->{Translation}->{'File Manager'} = 'Gerenciador De Arquivos';
    $Self->{Translation}->{'Total by state'} = 'Total por estado';
    $Self->{Translation}->{'Ticket by state'} = 'Chamados por estado';
    $Self->{Translation}->{'Ticket Services'} = 'Chamados por serviços';
    $Self->{Translation}->{'Ticket type'} = 'Chamado por tipo';
    $Self->{Translation}->{'Open x Closed Tickets'} = 'Chamados Abertos x Fechados';
    $Self->{Translation}->{'Open Tickets'} = 'Chamados abertos';
    $Self->{Translation}->{'Family/Service'} = 'Familia/Serviço';
    $Self->{Translation}->{'Inform the logins of the customer users who will be able to add another customer user.'} = 'Informe os logins dos usuários clientes que poderão adicionar outro usuário cliente.';
    $Self->{Translation}->{'Add customer user'} = 'Adicionar usuário cliente';
    $Self->{Translation}->{'User %s added successfully!'} = 'Usuário %s adicionado com sucesso!';
    $Self->{Translation}->{'Preferences updated successfully!'} = 'Preferências atualizadas com sucesso!';
    $Self->{Translation}->{'Ticket view configuration, it is possible to create different filters for each view, being possible to include a title in the Model, in the Search the ticket search parameters (if it is an ARRAY, insert data separated by semicolons) and in the VisibleColumns the columns that will be displayed.
The views start from the base of calls that the client user can see, so he already sends the standard filters.
The first key defined will be the parameter that must be sent as a parameter in the URL Action=MyTickets;Subaction=MyTickets;ViewModel=Key'} = 'Configuração de visão de tickets, nela é possível criar filtros diferentes pra cada visão, sendo possível incluir no Model um titúlo, no Search os parâmetros de busca de ticket (caso seja um ARRAY colocar dados separados por ponto e vírgula) e nas VisibleColumns as colunas que serão exibidas.
As visões partem da base de chamados que o usuário cliente podem ver, então ele já envia os filtros padrões.
A primeira chave definida será o parâmetro que deve ser enviado como parâmetro na URL Action=MyTickets;Subaction=MyTickets;ViewModel=Key';
    $Self->{Translation}->{'Configuration of visible columns for each ticket view model defined in the CustomerPortal::Core::ViewTickes###Config configuration.'} = 'Configuração de colunas visiveis para cada modelo de visão de chamados definidos na configuração CustomerPortal::Core::ViewTickes###Config.';
    $Self->{Translation}->{'Card view type.'} = 'Tipo de visualização dos cards.';
    $Self->{Translation}->{'List view'} = 'Visão de Lista';
    $Self->{Translation}->{'Card view'} = 'Visão de Card';
    $Self->{Translation}->{"Display of the first service level. Note: the list option will only work if the config 'CustomerPortal::Core::TypeViewService' is selected as List View."} = "Exibição do primeiro nivel de serviço. Obs: a opção de lista, só irá funcionar se a config 'CustomerPortal::Core::TypeViewService' estiver selecionada como Visão de Lista";

    $Self->{Translation}->{'Manage users'} = 'Gerenciar usuários';
    $Self->{Translation}->{'User edit'} = 'Editar usuário';
    $Self->{Translation}->{'Customer user update!'} = 'Usuário cliente atualizado!';
    $Self->{Translation}->{'Background colors of the Customer Portal top menu.'} = 'Cores do menu superior do Portal do Cliente.';
    $Self->{Translation}->{'NavBar item color'} = 'Cor dos itens';
    $Self->{Translation}->{'Selected item suspended'} = 'Item suspenso selecionado';
    $Self->{Translation}->{'Selected NavBar item color'} = 'Item selecionado';
    $Self->{Translation}->{'Body colors'} = 'Cores do corpo';
    $Self->{Translation}->{'NavBar background color'} = 'Cor de fundo da barra de navegação';
    $Self->{Translation}->{'Border navBar color'} = 'Cor da borda da barra de navegação';
    $Self->{Translation}->{'Main panel color'} = 'Cor do corpo';
    $Self->{Translation}->{'Menu type'} = 'Tipo do menu';
    $Self->{Translation}->{'Top navigation bar border color'} = 'Cor da borda da barra de navegação superior';
    $Self->{Translation}->{'Top navigation bar background color'} = 'Cor da barra de navegação superior';
    $Self->{Translation}->{'Error validating dynamic field.'} = 'Erro ao validar campo dinâmico.';
    $Self->{Translation}->{'Please, check that the queue has been configured correctly.'} = 'Por favor, verifique se a fila foi configurada corretamente.';
    $Self->{Translation}->{'Please, check if current selected QueueID exists in the list of queues.'} = 'Por favor, verifique se o ID da fila selecionado atualmente existe na lista de filas.';
    $Self->{Translation}->{'Please, check the subject provided.'} = 'Por favor, verifique o assunto informado.';
    $Self->{Translation}->{'Please, check the body provided.'} = 'Por favor, verifique o texto informado.';
    $Self->{Translation}->{'Please, report a valid service to continue.'} = 'Por favor, informe um serviço válido para continuar.';
    $Self->{Translation}->{'Clear search'} = 'Limpar pesquisa';
    $Self->{Translation}->{'Inform in each field, the note so that the comment is mandatory.'} = 'Informe em cada campo, a nota para que o comentário seja obrigatório.';
    $Self->{Translation}->{'Apply ticket star avaliation in CustomerPortal.'} = 'Aplicar avaliação com estrelas para o chamado no CustomerPortal.';
    $Self->{Translation}->{'Avaliation'} = 'Avaliação';
    $Self->{Translation}->{'Vote added by "%s"'} = 'Voto adicionado por "%s"';
    $Self->{Translation}->{'Enter your justification...'} = 'Digite sua justificativa...';
    $Self->{Translation}->{'Put the name of the states to show the voting stars.'} = 'Coloque o nome dos estados para mostrar as estrelas de votação.';
    $Self->{Translation}->{'Set the Limit amount of favorite services to be computed.'} = 'Defina a quantidade limite de serviços favoritos a serem computados.';
    $Self->{Translation}->{'Cannot add favorite because favorite limit has been reached!'} = 'Não é possível adicionar o favorito pois o limite de favoritos já foi atingido!';
    $Self->{Translation}->{"Enable company tickets on the ticket list screen. Relationship 'Customer User->Customer Relations'"} = "Habilite a exibição de chamados da empresa na tela de listagem de chamados. Relacionamento 'Usuário Cliente-Cliente'";
    $Self->{Translation}->{"Enable company tickets on the ticket open screen. Relationship 'Customer User->Customer Relations'"} = "Habilite a exibição de empresa na tela de abertura de chamados. Relacionamento 'Usuário Cliente-Cliente'";

    $Self->{Translation}->{"Add additional CSS content to the page."} = "Adicione conteúdo CSS adicional à página.";
    $Self->{Translation}->{"New Ticket"} = "Novo Chamado";
    $Self->{Translation}->{'Setting to disable default fields for a desired service in the portal.'} = 'Configuração para desabilitar campos padrão para um serviço desejado no portal.';
    $Self->{Translation}->{'Disable Fields Default Service'} = 'Desabilitar o serviço padrão de campos';
    $Self->{Translation}->{'Define Fields Default.'} = 'Defina campos padrão.';
    $Self->{Translation}->{'Adds new columns to the portal contract report'} = 'Adiciona novas colunas ao relatório de contrato do portal';
    $Self->{Translation}->{'Set the display format for the contract report. If you select Article, the report will be displayed by article; if you select Ticket, the report will be displayed by ticket accumulating all times recorded on the ticket.'} = 'Defina o formato de exibição do relatório de contrato. Se você selecionar Artigo, o relatório será exibido por artigo; se você selecionar Ticket, o relatório será exibido por ticket acumulando o todos tempos registrados no ticket.';
    $Self->{Translation}->{'Rounded edges'} = 'Bordas arredondadas';
    $Self->{Translation}->{'Set contract at the opening of the call with Acl RelationServiceContract use only if Ticket::Acl::Module###Acl::RelationServiceContract is enabled'} = 'Definir contrato na abertura da chamado com o uso de Acl RelationServiceContract somente se Ticket::Acl::Module###Acl::RelationServiceContract estiver habilitado';
    $Self->{Translation}->{'ACL to relate contracts to services on the portal'} = 'ACL para relacionar contratos a serviços no portal';
    $Self->{Translation}->{'Enables the priority field on my tickets in the customer porta'} = 'Habilita o campo de prioridade em meus chamados no portal do cliente';
    $Self->{Translation}->{'Change default message in new call via process'} = 'Alterar mensagem padrão em nova chamada via processo';
    $Self->{Translation}->{'Enables the priority field on my tickets in the customer portal'} = 'Ativa o campo de prioridade em meus tickets no portal do cliente';
    $Self->{Translation}->{'Enables the priority field on my tickets in the customer portal'} = 'Ativa o campo de prioridade em meus tickets no portal do cliente';
    $Self->{Translation}->{'Enable Scroll bar in screen my tickets'} = 'Ativar barra de rolagem na tela meus tickets';

    $Self->{Translation}->{'Select files'} = 'Selecione os Arquivos';
    $Self->{Translation}->{'Select a file'} = 'Selecione o Arquivo';
    $Self->{Translation}->{'Select files or drop them here'} = 'Selecione os arquivos ou solte-os aqui';
    $Self->{Translation}->{'Disable my tickets menu.'} = 'Desabilita o menu Meus Chamados';

    $Self->{Translation}->{'Displays the article index to the customer on the portal'} = 'Exibe o indice do artigo para o cliente no portal';
    $Self->{Translation}->{'Display the field with the default value.'} = 'Exibir o campo com o valor padrão.';
    $Self->{Translation}->{'Display the field as mandatory and the default option is empty.'} = 'Exibir o campo como mandatório e opção padrão vazia.';
    $Self->{Translation}->{'Error creating ticket! Contact your system administrator.'} = 'Erro ao criar chamado! Entre em contato com o administrador do sistema.';


    $Self->{Translation}->{'Parameters of the service opening wait time attribute.'} = 'Parametros do intervalo mínimo entre novas requisição do serviço';
    $Self->{Translation}->{'Opening wait time (in days)'} = 'Intervalo mínimo de nova abertura (em dias)';
    $Self->{Translation}->{'Define the service opening wait time in days. Enter an integer.'} = 'Define o intervalo mínimo em dias para novos chamados no serviço. Informe um inteiro.';
    $Self->{Translation}->{'You can\'t open a new ticket in this service yet.'} = 'Você não pode abrir um chamado neste serviço ainda.';
    $Self->{Translation}->{'Plase, wait until %s.'} = 'Por favor, espere até %s.';

    $Self->{Translation}->{'User Information'} = 'Informações do usuário';
    $Self->{Translation}->{'Full Name'} = 'Nome Completo';
    $Self->{Translation}->{'First Name'} = 'Primeiro Nome';
    $Self->{Translation}->{'Last Name'} = 'Último Nome';
    $Self->{Translation}->{'User Tickets'} = 'Chamados';
    $Self->{Translation}->{'Created on'} = 'Criado em';

    $Self->{Translation}->{'Enables the display of icons in the top navigation bar with description.'} = 'Habilita a exibição de ícones na barra de navegação superior com descrição.';
    $Self->{Translation}->{'Customize the descriptions of the navbar icons.'} = 'Personalize as descrições dos ícones da barra de navegação. Manter as chaves e alterar os valores.';

    $Self->{Translation}->{'Enables the extra tools in the text inputs.'} = 'Ativa as ferramentas extras nos campos de texto.';
    $Self->{Translation}->{'Config to Change the Title of Services page.'} = 'Configuração que define o título da página de serviços.';
    $Self->{Translation}->{'Displays the button to open a new call via process with the same data as the current call.'} = 'Exibe o botão para abrir um novo chamado via processo com os mesmos dados do chamado atual.';
    $Self->{Translation}->{"Displays the process's upcoming activities widget."} = 'Exibe o widget de próximas atividades do processo.';
    $Self->{Translation}->{"Services ID that will be blocked for non-proprietary customers."} = 'ID de serviços que será bloqueado para usuários clientes não proprietários.';
    $Self->{Translation}->{"Open new ticket for this service"} = 'Abrir novo chamado para este serviço';

    $Self->{Translation}->{'Research FAQ'} = 'Pesquisar';
    $Self->{Translation}->{'FAQ Problem'} = 'Perguntas';
    $Self->{Translation}->{'FAQ Solution'} = 'Respostas';
    $Self->{Translation}->{'How can we help you?'} = 'Como podemos ajudar você?';
    $Self->{Translation}->{'Enter keywords here to find the subject you want...'} = 'Digite aqui as palavras-chaves para achar o assunto desejado...';
    $Self->{Translation}->{'Browse the areas'} = 'Navegue pelas Categorias';
    $Self->{Translation}->{'Search results'} = 'Resultados da pesquisa';
    $Self->{Translation}->{'Define the icon of the FAQ Category, CategoryName -> Icon path.'} = 'Defina o ícone da categoria FAQ, CategoryName -> Caminho do ícone.';
    $Self->{Translation}->{'No data found'} = 'Nenhum dado encontrado';
    $Self->{Translation}->{'Displays the custom screen of FAQ.'} = 'Habilita a exibiçao da tela de FAQ customizada.';
    $Self->{Translation}->{'Please, fill in the field'} = 'Por favor, preencha o campo.';
    $Self->{Translation}->{'Enable the setting so that the list view does not show the full name in the service, but rather the last level. If FirstLevelViewService is List view.'} = 'Habilite a configuração para a visão de lista não mostrar o nome completo no serviço, mas sim o ultimo nível. Se selecionado "List view" em ServiceListViewDisplayName.';
    $Self->{Translation}->{'Set the CustomerLogo to CustomerPortal in center interface'} = 'Deixa o logo do CustomerPortal centralizado na navbar.';
    $Self->{Translation}->{'Configuration to enable Acessibility menu in CustomerPortal view.'} = 'Configuração para habilitar o menu Acessibilidade na visualização do CustomerPortal.';
    $Self->{Translation}->{'Define where the CustomServiceForm fields will appear, inside or outside the form.'} = 'Defina onde os campos do CustomServiceForm aparecerão, dentro ou fora do formulário.';
    $Self->{Translation}->{'Inside Form'} = 'Dentro do Formulário';
    $Self->{Translation}->{'Outside Form'} = 'Fora do Formulário';
    $Self->{Translation}->{'Type defined in each service'} = 'Tipo definido em cada serviço';
    $Self->{Translation}->{'Define the display format of the service in the portal.'} = 'Defina o formato de exibição do serviço no portal.';
    $Self->{Translation}->{'Display as'} = 'Exibir como';

    $Self->{Translation}->{'1 - Display in card (Main)'} = '1 - Exibir em card (Principal)';
    $Self->{Translation}->{'2 - Display in list'} = '2 - Exibir em lista';
    $Self->{Translation}->{'3 - Display on card (Secondary)'} = '3 - Exibir em card (Secundário)';
    $Self->{Translation}->{'Only closed tickets between'} = 'Apenas chamados fechados entre';
    $Self->{Translation}->{'Service L1'} = 'Área';
    $Self->{Translation}->{'Display the service description on the ticket opening screen.'} = 'Exiba a descrição do serviço na tela de abertura de chamado.';
    $Self->{Translation}->{'Set the form direction.'} = 'Defina a direção do formulário.';
    $Self->{Translation}->{'Vertical form (3 fields per line)'} = 'Formulário na vertical (3 campos por linha)';
    $Self->{Translation}->{'Horizontal form (1 field per line)'} = 'Formulário na horizontal (1 campo por linha)';
    $Self->{Translation}->{'LoadProfile'} = 'Procurar Chamados';
    $Self->{Translation}->{'Elapsed SLA'} = 'SLA decorrido';
    $Self->{Translation}->{'Mass action carried out successfully!'} = 'Ação em massa realizada com sucesso!';
    $Self->{Translation}->{'Action Bulk'} = 'Ação em Massa';
    $Self->{Translation}->{'Select this ticket'} = 'Selecionar chamado';
    $Self->{Translation}->{'Define the states in which the bulk action can be selected. If no states are configured, all calls can be selected.'} = 'Defina os estados onde a ação em massa poderá ser  selecionada. Se nenhum estado for configurado, todos os chamados poderão ser selecionados.';
    $Self->{Translation}->{'It is not possible to perform mass action for this ticket'} = 'Não é possível realizar ação em massa para esse chamado';
    $Self->{Translation}->{'Define the states in which the bulk action can be changed.'} = 'Defina os estados nos quais a ação em massa pode ser alterada.';

    $Self->{Translation}->{'Enable tickets in the companys ticket tab that have that user copied (Cc) on the ticket. They may also have permission to interact.'} = 'Habilite para trazer os chamados, na aba de chamados da empresa, que possuem aquele usuário em cópia (Cc) do chamado. Podendo também ter permissão de interagir.';

    $Self->{Translation}->{'Standard service for all users'} = 'Serviço padrão para todos os usuários';
    $Self->{Translation}->{'Set the default service on the service registration screen.'} = 'Defina o serviço padrão na tela de registro de serviço.';
    $Self->{Translation}->{'Default service'} = 'Serviço padrão';
    $Self->{Translation}->{'Define the process to ticket'} = 'Define o processo para chamado que será aberto';
    
    push @{ $Self->{JavaScriptStrings} // [] }, (
        'No record found',
        'Change default message in new call via proces',
        'Showing 0 to 0 of 0 ticket',
        'Loading...',
        'Processing...',
        'Search records',
        'Next',
        'Previous',
        'First',
        'Last',
        'Showing',
        'tickets',
        'Showing from',
        'up until',
        'in',
        'Filtered from',
        'records',
        'Showing 0 to 0 of 0 records',
        'Do you really want to delete this message?',
        'You have already gone through all notifications',
        'Hours spent per month',
        'No data found',
        'Select files or drop them here',
        'Choose an icon',
        'Browse the areas',
        'Search results',
        'No data found',
        'Please, fill in the field'
    );    
}

1;
