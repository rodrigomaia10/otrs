# --
# Kernel/Language/pt_BR_ServiceTemplate.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# --

package Kernel::Language::pt_BR_ServiceTemplate;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AgentFAQAdd
    $Self->{Translation}->{'Service <-> Template'} = 'Serviço <-> Modelo';
    $Self->{Translation}->{'Preference field mapping to screen.'} = 'Mapeamento de campo de preferência para tela.';
    $Self->{Translation}->{'Service Template Management'} = 'Gerenciamento de Modelos de Serviço';
    $Self->{Translation}->{'Add Service Template'} = 'Adicionar Modelo de Serviço';
    $Self->{Translation}->{'Edit Service Template'} = 'Alterar Modelo de Serviço';
    $Self->{Translation}->{'There is no available %s!'} = 'Não existe %s disponivel!';
    $Self->{Translation}->{'Setting up a new service will overwrite any text. Do you really want to continue?'} = 'Configurar um novo serviço irá sobrescrever qualquer texto. Você realmente quer continuar?';
    $Self->{Translation}->{'Link service to template.'} = 'Associe o serviço ao template.';

    $Self->{Translation}->{'Here you can upload a configuration file to import service templates to your system. The file needs to be in .yml format as exported by the service template editor module.'} = 'Aqui você pode fazer o envio de um arquivo de configuração para importar Modelos de Serviço para o seu sistema. O arquivo precisa estar no formato .yml como exportado pelo módulo de edição de Modelos de Serviço.';
    $Self->{Translation}->{'Export templates'} = 'Exportar modelos';
    $Self->{Translation}->{'Export this Service Template'} = 'Exportar este Modelo de Serviço';
    $Self->{Translation}->{'Overwrite existing templates?'} = 'Sobrescrever modelos existentes?';
    $Self->{Translation}->{'Import templates configuration(s)'} = 'Importar configuração(ões) de modelos';
    $Self->{Translation}->{'The following Service Templates have been added successfully: %s'} = 'Os seguintes Modelos de Serviço foram adicionadas com sucesso: %s';
   	$Self->{Translation}->{'The following Service Templates have been updated successfully: %s'} = 'Os seguintes Modelos de Serviço foram editados com sucesso: %s';
	$Self->{Translation}->{'Service Templates could not be Imported due to a unknown error, please check Znuny logs for more information'} = 'Os Modelos de Serviço não puderam ser importados devido a um erro desconhecido, verifique os logs do Znuny para obter mais informações';
	$Self->{Translation}->{'There where errors adding/updating the following Service Templates: %s. Please check the log file for more information.'} = 'Houve erros ao adicionar/atualizar os seguintes Modelos de Serviço: %s. Verifique o arquivo de log para obter mais informações.';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'No',
        'Ok',
        'Settings',
        'Submit',
        'Yes',
        'Setting up a new service will overwrite any text. Do you really want to continue?'
    );
}

1;
