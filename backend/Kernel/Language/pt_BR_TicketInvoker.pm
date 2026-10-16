# --
# Kernel/Language/pt_BR_TicketInvoker.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * ccresencio@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::pt_BR_TicketInvoker;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # SysConfig
    $Self->{Translation}->{'Ticket attributes that should be available in ticket invoker configuration frontend (0 = visible/selectable, 1 = default/preselected).'} = 'Atributos de chamados que devem estar disponíveis na interface de configuração do invocador de chamados (0 = visível / selecionável, 1 = padrão / pré-selecionado).';
    $Self->{Translation}->{'Article attributes that should be available in ticket invoker configuration frontend (0 = visible/selectable, 1 = default/preselected).'} = 'Atributos de artigo que devem estar disponíveis no frontend de configuração do invocador de chamados (0 = visível / selecionável, 1 = padrão / pré-selecionado).';
    $Self->{Translation}->{'Define a result field for the TicketID of the invoker response per web service (WebserviceID => DynamicFieldName).'} = 'Defina um campo de resultado para o TicketID da resposta do invocador por serviço da web (WebserviceID => DynamicFieldName).';

    $Self->{Translation}->{'General invoker data'} = 'Dados gerais do invocador';
    $Self->{Translation}->{'Settings for outgoing request data'} = 'Configurações para dados de solicitação de saída';
    $Self->{Translation}->{'Only the selected ticket fields will be considered for the request data.'} = 'Apenas os campos do ticket selecionados serão considerados para os dados da solicitação.';
    $Self->{Translation}->{'Only the selected article fields will be considered for the request data.'} = 'Apenas os campos do artigo selecionado serão considerados para os dados da solicitação.';
    $Self->{Translation}->{'Article fields'} = 'Campos do artigo';
    $Self->{Translation}->{'Only the selected ticket dynamic fields will be considered for the request data.'} = 'Apenas os campos dinâmicos do ticket selecionados serão considerados para os dados da solicitação.';
    $Self->{Translation}->{'Ticket dynamic fields'} = 'Campos dinâmicos de chamados';
    $Self->{Translation}->{'Only the selected article dynamic fields will be considered for the request data.'} = 'Apenas os campos dinâmicos do artigo selecionado serão considerados para os dados da solicitação.';
    $Self->{Translation}->{'Article dynamic fields'} = 'Campos dinâmicos de artigos';
    $Self->{Translation}->{'Number of articles'} = 'Número de artigos';
    $Self->{Translation}->{'The outgoing request data will only contain the configured number of articles. If left empty, only 1 article will be sent.'} = 'Os dados da solicitação de saída conterão apenas o número configurado de artigos. Se deixado em branco, apenas 1 artigo será enviado.';
    $Self->{Translation}->{'The outgoing request data will only consider articles of the selected communication channels. If left empty, articles created by all communication channels will be used.'} = 'Os dados da solicitação de saída considerarão apenas artigos dos canais de comunicação selecionados. Se deixado em branco, serão utilizados artigos criados por todos os canais de comunicação.';
    $Self->{Translation}->{'Communication channels'} = 'Canais de comunicação';
    $Self->{Translation}->{'The outgoing request data will only consider articles created with the selected customer visibility.'} = 'Os dados da solicitação de saída considerarão apenas os artigos criados com a visibilidade do cliente selecionado.';
    $Self->{Translation}->{'Sender Types'} = 'Tipos de Remetente';
    $Self->{Translation}->{'The outgoing request data will only consider articles created by the selected sender types. If left empty, articles created by all sender types will be used.'} = 'Os dados da solicitação de saída considerarão apenas os artigos criados pelos tipos de remetentes selecionados. Se deixado em branco, os artigos criados por todos os tipos de remetentes serão usados.';
    $Self->{Translation}->{'Additional request headers'} = 'Cabeçalhos de solicitação adicionais';
    $Self->{Translation}->{'Endpoint'} = 'Endpoint';
    $Self->{Translation}->{'Disable SSL hostname certificate verification:'} = 'Desative a verificação de certificado de nome de host SSL:';
    $Self->{Translation}->{'Disables hostname certificate verification. This is not recommended and should only be used in test environments.'} = 'Desativa a verificação do certificado do nome do host. Isso não é recomendado e só deve ser usado em ambientes de teste.';
    $Self->{Translation}->{'Content type'} = 'Tipo de conteúdo';
    $Self->{Translation}->{'The default content type added to HTTP header to use for POST and PUT requests.'} = 'O tipo de conteúdo padrão adicionado ao cabeçalho HTTP a ser usado para solicitações POST e PUT.';
    $Self->{Translation}->{'Add request header'} = 'Adicionar cabeçalho de solicitação';
    

    $Self->{Translation}->{'Mapping'} = 'Mapeamento';
    $Self->{Translation}->{'Enter tags separated by space for which empty string representation should be forced.'} = 'Insira tags separadas por espaço para as quais a representação de string vazia deve ser forçada.';

    $Self->{Translation}->{'Settings for incoming response data'} = 'Configurações para dados de resposta recebidos';
    $Self->{Translation}->{'Remote TicketID dynamic field'} = 'Campo dinâmico TicketID remoto';

    $Self->{Translation}->{'The selected ticket dynamic field is being used to store the remote TicketID.'} = 'O campo dinâmico do tíquete selecionado está sendo usado para armazenar o TicketID remoto.';
    $Self->{Translation}->{'If left empty, the remote TicketID will not be stored, unless you define a system configuration value for this web service.'} = 'Se deixado em branco, o TicketID remoto não será armazenado, a menos que você defina um valor de configuração do sistema para este serviço da web.';
    $Self->{Translation}->{'The selected field is already in use by the Ticket dynamic fields option.'} = 'O campo selecionado já está em uso pela opção Campos dinâmicos do chamado.';
    
    $Self->{Translation}->{'Only the selected ticket dynamic fields are being considered for processing the incoming response data. If left empty, no dynamic field will be processed.'} = 'Apenas os campos dinâmicos do chamado selecionados estão sendo considerados para processar os dados de resposta recebidos. Se deixado em branco, nenhum campo dinâmico será processado.';
    $Self->{Translation}->{'Ticket and Article dynamic fields'} = "Campos dinâmicos de Chamado e Artigo";

    $Self->{Translation}->{'Authentication webservice.'} = "WebService de autenticação.";
    $Self->{Translation}->{'Authentication Invoker.'} = "Invoker de autenticação.";
    $Self->{Translation}->{'Validity time (in minutes) of authentication key.'} = "Tempo de validade (em minutos) da chave de autenticação.";

    $Self->{Translation}->{'Select the FAQ association type it will fetch to insert into the request data.'} = "Selecione o tipo de associação de FAQ ele ira buscar para inserir nos dados da requisição.";
    $Self->{Translation}->{'The exit request data will only contain the last article.'} = "Os dados da solicitação de saída conterão apenas o ultimo artigo.";
    $Self->{Translation}->{'Select this option if you want the attachments to be returned in the request data.'} = "Selecione essa opção caso queira que os anexos sejam retornados nos dados da requisição.";
    $Self->{Translation}->{'FAQ membership type'} = "Tipo de associação ás FAQs";
    $Self->{Translation}->{'Link by Service'} = "Link por Serviço";
    $Self->{Translation}->{'Test mapping'} = "Testar mapeamento";
    $Self->{Translation}->{'Ticket number (Field 1)'} = "Número do chamado (Campo 1)";
    $Self->{Translation}->{'JSON (Field 2)'} = "JSON (Campo 2)";
    $Self->{Translation}->{'Result (Field 3)'} = "Resultado (Campo 3)";
    $Self->{Translation}->{'Use this area to check whether the mapping is being carried out correctly. Enter the ticket number in field 1 if you want to test the mapping with ticket data. Enter the JSON in field 2 if you want to test the mapping based on the received JSON. The result will be displayed in field 3. Save the XSLT before testing.'} = "Utilize essa área para verificar se o mapeamento está sendo realizado corretamente. Informe o número do chamado no campo 1 se desejar testar o mapeamento com dados do chamado. Informe o JSON no campo 2 se desejar testar o mapeamento em cima de um JSON recebido. O resultado será exibido no campo 3. Salve o XSLT antes de testar.";
    $Self->{Translation}->{'Link per Ticket'} = "Link por Ticket";
    $Self->{Translation}->{'Minimum confidence score'} = "Pontuação minimá de confiaça";
    $Self->{Translation}->{'Satisfactory Answer'} = "Resposta Satisfatória";
    $Self->{Translation}->{'Insufficient answer'} = "Resposta Insuficiente";
    $Self->{Translation}->{'Your ticket will be closed, thanks for contacting us.'} = "Seu ticket será encerrado, obrigado por nos contatar.";
    $Self->{Translation}->{'Your ticket will be forwarded to an agent who will contact you.'} = "Seu ticket será encaminhado para um agente que entrará em contato com você.";

    $Self->{Translation}->{'Enter tags separated by space so that their value is passed in DecodeJSON before mapping. (Provider: Enter the tag value received. Requester: Use in dynamic field with a value in JSON).'} = "Insira as tags separadas por espaço para que seu valor seja passado no DecodeJSON antes do mapeamento. (Provedor: Informar o valor da tag recebida. Solicitante: Utilizar em campo dinâmico com valor em JSON).";
    $Self->{Translation}->{'Force array for tags'} = "Forçar array para tags";
    $Self->{Translation}->{'Owner, customer and company data'} = "Dados do proprietário, cliente e empresa";
    $Self->{Translation}->{'Include Owner, Customer and Customer User Data in the ticket.'} = "Inclua Dados do Proprietário, Cliente e Usuário do Cliente no ticket.";
    $Self->{Translation}->{'Keep XML attributes'} = "Manter atributos XML";
    $Self->{Translation}->{'Only needed for content type XML.'} = "Necessário apenas para o tipo de conteúdo XML.";
    $Self->{Translation}->{'Enter tags separated by space for which array representation should be forced.'} = "Digite as tags separadas por espaço para as quais a representação do array deve ser forçada.";
    $Self->{Translation}->{'Force number for tags'} = "Forçar number para tags";
    $Self->{Translation}->{'Enter tags separated by space for which number representation should be forced.'} = "Digite as tags separadas por espaço para as quais a representação de number deve ser forçada.";
    $Self->{Translation}->{'Force boolean for tags'} = "Forçar boolean para tags";
    $Self->{Translation}->{'Force empty string for tags'} = "Forçar string vazia para tags";
    $Self->{Translation}->{'Enter tags separated by space for which boolean representation should be forced.'} = "Digite as tags separadas por espaço para as quais a representação de boolean deve ser forçada.";
    $Self->{Translation}->{'Only first article'} = "Apenas o primeiro artigo";

    return 1;
} 

1;
