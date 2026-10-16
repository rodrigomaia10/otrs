# --
# Kernel/Language/pt_BR_InBoxCore.pm
# Copyright (C) 2019 ServiceUp, http://www.serviceupcom.com.br
#
# written/edited by:
# * ischutzer@serviceup.com.com.br
# * dsilva@serviceup.com.com.br
# * jsantos@serviceup.com.com.br
# --

package Kernel::Language::pt_BR_InBoxCore;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{"Set the socket.io server URL. Note: If you use socket.io on the same server and you have done a reverse proxy, enable the 'SocketIO::Core::Path' setting."} = "Defina a URL do servidor do socket.io. Observação: Caso utilize o socket.io no mesmo servidor e tenha feito um proxy reverso, habilite a configuração 'SocketIO::Core::Path'.";
    $Self->{Translation}->{"Set the socket.io server path if you use socket.io on the same server as the system application and you have done a reverse proxy. Default value: '/otrs/socket/'."} = "Defina o path do servidor do socket.io caso utilize o socket.io no mesmo servidor da aplicação do sistema e tenha feito um proxy reverso. Valor padrão: '/otrs/socket/'.";
    $Self->{Translation}->{'Indicators'} = 'Indicadores';
    $Self->{Translation}->{'Next'} = 'Próximo';
    $Self->{Translation}->{'This feature is part of the %s. Please contact us at %s for an upgrade.'} = 'Esse recurso faz parte da %s. Por favor, entre em contato conosco em %s para uma atualização.';
    $Self->{Translation}->{'Find out more'} = 'Descubra mais';
    $Self->{Translation}->{'The browser version used is no longer supported by the system and the browser developer. Some features may not work correctly.'} = 'A versão do navegador usada não é mais suportada pelo sistema e pelo desenvolvedor do navegador. Algumas funcionalidades podem não funcionar corretamente.';
    $Self->{Translation}->{"Developer's Note."} = 'Nota do desenvolvedor.';
    $Self->{Translation}->{'Enable error message for unsupported browsers.'} = 'Ative a mensagem de erro para navegadores não suportados.';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'Next',
        'The browser version used is no longer supported by the system and the browser developer. Some features may not work correctly.',
        "Developer's Note."
    );
}

1;