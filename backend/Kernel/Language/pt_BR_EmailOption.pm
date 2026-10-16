# --
# Kernel/Language/pt_BR_EmailOption.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# * dsilva@serviceup.com.br
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::pt_BR_EmailOption;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Change ticket state when answered.'} = 'Alterar o estado do chamado ao ser respondido.';
    $Self->{Translation}->{'Define the default sender value to article create by response.'} = 'Defina o valor do remetente padrão para o artigo criado pela resposta.';
    $Self->{Translation}->{'Defines the text that will appear in the article.'} = 'Define o texto que irá aparecer no artigo.';
    $Self->{Translation}->{'Dynamic field updated successfully.'} = 'Campo dinâmico atualizado com sucesso.';
    $Self->{Translation}->{'Write here...'} = 'Escreva aqui...';
    $Self->{Translation}->{'Defines the subject that will appear in the article.'} = 'Define o assunto que aparecerá no artigo.';
    $Self->{Translation}->{'Defines whether the EmailOption response will be visible to the customer.'} = 'Define se a resposta do EmailOption irá ficar visível para o customer.';

    $Self->{Translation}->{'Email of user who responded to EmailOption.'} = 'Email do usuário que respondeu ao EmailOption.';
    $Self->{Translation}->{'Subject and body of article created in EmailOption response.'} = 'Assunto e corpo de artigo criado na resposta do EmailOption.';
    $Self->{Translation}->{'Settings for the text to be displayed in the title, header and button color.'} = 'Configurações do texto a ser exibido no título, cor do cabeçalho e do botão.';
    $Self->{Translation}->{'The created article will not be visible to the agent.'} = 'O artigo criado não ficará visível para o agente.';
    $Self->{Translation}->{'Email from who responded to Email Option.'} = 'E-mail de quem respondeu à Opção de e-mail.';

    $Self->{Translation}->{'Information'} = 'Informações';
    $Self->{Translation}->{'You have already answer!'} = 'Você já respondeu!';
    $Self->{Translation}->{'Ticket data'} = 'Dados do Chamado';
    $Self->{Translation}->{'TicketNumber : '} = 'Número do Chamado: ';
    $Self->{Translation}->{'Title : '} = 'Título do Chamado : ';
    $Self->{Translation}->{'Customer : '} = 'Cliente : ';
    $Self->{Translation}->{'Agent : '} = 'Atendente : ';
    $Self->{Translation}->{'Email Option'} = 'Opções de Email';
    $Self->{Translation}->{'For more details, access the ticket clicking '} = 'Para mais informações, acesse o chamado clicando ';
    $Self->{Translation}->{'here'} = 'aqui';
    $Self->{Translation}->{'Enter the information to complete the vote.'} = 'Insira mais informações para a conclusão do voto.';
    $Self->{Translation}->{'The dynamic field '} = 'O campo dinâmico ';
    $Self->{Translation}->{' has been successfully updated, with the value: '} = ' foi atualizado com sucesso. Valor: ';
    $Self->{Translation}->{'An error has occurred.'} = 'Ocorreu um erro.';
    $Self->{Translation}->{'An error has occurred, please contact support.'} = 'Ocorreu um erro, por favor entre em contato com a equipe de suporte.';
    $Self->{Translation}->{'Approval'} = 'Aprovação';
    $Self->{Translation}->{'DynamicField update'} = 'Atualização de campo dinâmico via e-mail';
    $Self->{Translation}->{'You answered: '} = 'Você respondeu: ';
    $Self->{Translation}->{'Click here'} = 'Clique aqui';
    $Self->{Translation}->{'or'} = 'ou';
    $Self->{Translation}->{'Configuration of texts. First key: Dynamic Field. Second Key: ValueField1 - Text displayed when registering the value. ValueField2 - Text displayed if the answer has the text field enabled.'} = 'Configuração dos textos. Primeira chave: Campo Dinâmico. Segunda Chave: Valor1 - Texto exibido ao registrar o valor. Valor2 - Texto exibido se a resposta tiver o campo de texto habilitado.';
    $Self->{Translation}->{'to be redirected to the tool.'} = 'para ser redirecionado para ferramenta.';
    $Self->{Translation}->{'Article creation obligatory'} = 'Criação de artigo obrigatório';
    $Self->{Translation}->{'Dynamic Field not enabled'} = 'Campo dinâmico não ativado';
    $Self->{Translation}->{'Updated dynamic field via email'} = 'Campo dinâmico atualizado via e-mail';
    $Self->{Translation}->{'Dynamic Fields enabled to be set via e-mail. Possible settings: 0 = Disabled, 1 = Available.'} = 'Campos dinâmicos habilitados para serem definidos via e-mail. Configurações possíveis: 0 = Desativado, 1 = Disponível.';
    $Self->{Translation}->{'Text show when a justification is needed.'} = "Texto que será exibido quando uma justificativa for necessária";
    $Self->{Translation}->{'Hidden notification for agent'} = "Notificação oculta para atendente";
    $Self->{Translation}->{'Autoload for module EmailOptionNotificationHidden'} = "Autoload para o módulo EmailOptionNotificationHidden";
    $Self->{Translation}->{'Frontend module registration for the NotificationHidden in the admin area'} = "Registro do módulo de front-end para o NotificationHidden na área de administração";
    $Self->{Translation}->{'NotificationHidden'} = "Ocultar notificações";
    $Self->{Translation}->{'Article not visible for agent'} = "Artigo não visível para o atendente";

    $Self->{Translation}->{'Define the default template for responses.'} = "Define o modelo padrão para respostas.";
    $Self->{Translation}->{'This option enables the possibility of attaching files when sending a justification via EmailOption.'} = "Esta opção permite anexar arquivos ao enviar uma justificativa via EmailOption.";
    $Self->{Translation}->{'Dynamic field to save the justification for an approve / disapprove.'} = "Campo dinâmico para salvar a justificativa de uma aprovação/reprovação.";
    $Self->{Translation}->{'Defines dynamic fields to display when a ticket is disapproved.'} = "Define quais campos dinâmicos serào exibidos quando o ticket for reprovado";
    $Self->{Translation}->{'Message configuration for notifications already responded to. First key: Dynamic Field used in EmailOption. Second Key: Message to be displayed, this message may contain TAGs referencing ticket information. Ex: <OTRS_TICKET_DynamicField_Field1>'} = "Configuração mensagem para notificações já respondidas. Primeira chave: Campo Dinâmico usado no EmailOption. Segunda Chave: Mensagem à ser exibida, essa mensagem pode conter TAGs referenciado informações do ticket. Ex: <OTRS_TICKET_DynamicField_Field1>";
    $Self->{Translation}->{'This configuration makes it possible to create the article when a notification is responded to. By disabling this config, the InBox::EmailOption::DynamicFieldsTexts, InBox::EmailOption::DefaultTextOfAnsweredArticle and InBox::EmailOption::DefaultSubjectOfAnsweredArticle configs will not work.'} = "Essa configuração possibilita a criação do artigo ao ter uma notificação respondida. Ao desabilitar esta configuração, as configurações InBox::EmailOption::DynamicFieldsTexts, InBox::EmailOption::DefaultTextOfAnsweredArticle e InBox::EmailOption::DefaultSubjectOfAnsweredArticle não funcionarão.";
    
}

1;
