# --
# Kernel/Language/pt_BR_CustomServiceForm.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@beonup.com.br
# * jgsantos@beonup.com.br
# --

package Kernel::Language::pt_BR_CustomServiceForm;

use strict;
use warnings;
use utf8;

sub Data {
 	my $Self = shift;

	# frontend template overview
	$Self->{Translation}->{'Service ↔ Custom Form'} = 'Formulário Customizado ↔ Serviço';
	$Self->{Translation}->{'Creation of customized forms for services.'} = 'Criação de Formulário Customizado por Serviço';
	$Self->{Translation}->{'Service Form Management'} = 'Gerenciamento de Formulário de Serviço';
	$Self->{Translation}->{'Add Service Form'} = 'Adicionar Formulário de Serviço';
	$Self->{Translation}->{'Edit Service Form'} = 'Editar Formulário de Serviço';
	$Self->{Translation}->{'Filter for Form'} = 'Filtrar por Formulário';
	$Self->{Translation}->{'Service Form Fields'} = 'Campos do Formulário de Serviço';
	$Self->{Translation}->{'Form content'} = 'Conteúdo do formulário';
	$Self->{Translation}->{'Admin Custom Service Form'} = 'Formulário de Serviço Personalizado';
	$Self->{Translation}->{'Enable editing of service form fields, after the ticket already created.'} = 'Habilitar a edição de campos do formulário de serviço, após o chamado já criado.';
	$Self->{Translation}->{'Close dialog'} = 'Cancelar e fechar';
	$Self->{Translation}->{'Autoload for module AgentTicketEmail.'} = 'Autoload para o módulo AgentTicketEmail.';
	$Self->{Translation}->{'Autoload for module CustomerTicketMessage.'} = 'Autoload para o módulo CustomerTicketMessage.';
	$Self->{Translation}->{'Autoload for module AgentTicketPhone.'} = 'Autoload para o módulo AgentTicketPhone.';
	$Self->{Translation}->{'This event module set dynamic fields values of the custom forms.'} = 'Este módulo de eventos define valores de campos dinâmicos dos formulários personalizados.';
	$Self->{Translation}->{'This event module clean dynamic fields values if service is change.'} = 'Este módulo de eventos limpa os valores dos campos dinâmicos se o serviço for alterado.';
	$Self->{Translation}->{'Download template'} = 'Baixar modelo';
	$Self->{Translation}->{'Import Init'} = 'Iniciar importação';
	$Self->{Translation}->{'Export forms'} = 'Exportar formulários';
	$Self->{Translation}->{'Here you can upload a configuration file to import Service Forms into your system. The file must be in .csv format and following the csv exported by the module.'} = 'Aqui você pode fazer o envio de um arquivo de configuração para importar Formulários de Serviço para o seu sistema. O arquivo precisa estar no formato .yml e seguindo o .yml exportado pelo módulo.';
	$Self->{Translation}->{'Copy this form'} = 'Copiar este formulário';
	$Self->{Translation}->{'Overwrite existing forms?'} = 'Sobrescrever formulários existentes?';
	$Self->{Translation}->{'Edited'} = 'Editado';
	$Self->{Translation}->{'Status Import'} = 'Status da importação';
	$Self->{Translation}->{'Incorrect Service'} = 'Serviços incorretos';
	$Self->{Translation}->{'Incorrect DynamicField'} = 'Campos dinâmicos incorretos';
	$Self->{Translation}->{'Incorrect names'} = 'Nomes incorretos';

	$Self->{Translation}->{'The following Custom Form have been added successfully: %s'} = 'Os seguintes Formulários de Serviço foram adicionadas com sucesso: %s';
   	$Self->{Translation}->{'The following Custom Form have been updated successfully: %s'} = 'Os seguintes Formulários de Serviço foram editados com sucesso: %s';
	$Self->{Translation}->{'Custom Form could not be Imported due to a unknown error, please check OTRS logs for more information'} = 'Os Formulários de Serviço não puderam ser importados devido a um erro desconhecido, verifique os logs do OTRS para obter mais informações';
	$Self->{Translation}->{'There where errors adding/updating the following Custom Forms: %s. Please check the log file for more information.'} = 'Houve erros ao adicionar/atualizar os seguintes Formulários de Serviço: %s. Verifique o arquivo de log para obter mais informações.';
}

1;
