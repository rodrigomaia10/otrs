# --
# Kernel/Language/es_InBoxCore.pm
# Copyright (C) 2019 ServiceUp, http://www.serviceupcom.com.br
#
# written/edited by:
# * ischutzer@serviceup.com.com.br
# * dsilva@serviceup.com.com.br
# * jsantos@serviceup.com.com.br
# --

package Kernel::Language::es_InBoxCore;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{"Set the socket.io server URL. Note: If you use socket.io on the same server and you have done a reverse proxy, enable the 'SocketIO::Core::Path' setting."} = "Establezca la URL del servidor socket.io. Nota: Si usa socket.io en el mismo servidor y ha realizado un proxy inverso, habilite la configuración 'SocketIO::Core::Path'.";
    $Self->{Translation}->{"Set the socket.io server path if you use socket.io on the same server as the system application and you have done a reverse proxy. Default value: '/otrs/socket/'."} = "Establezca la ruta del servidor socket.io si usa socket.io en el mismo servidor que la aplicación del sistema y ha realizado un proxy inverso. Valor predeterminado: '/otrs/socket/'.";
    $Self->{Translation}->{'Indicators'} = 'Indicadores';
    $Self->{Translation}->{'Next'} = 'Próximo';
    $Self->{Translation}->{'This feature is part of the %s. Please contact us at %s for an upgrade.'} = 'Esta característica es parte de %s. Comuníquese con nosotros al %s para recibir una actualización.';
    $Self->{Translation}->{'Find out more'} = 'Saber más';
    $Self->{Translation}->{'The browser version used is no longer supported by the system and the browser developer. Some features may not work correctly.'} = 'La versión del navegador utilizada ya no es compatible con el sistema y el desarrollador del navegador. Algunas características pueden no funcionar correctamente.';
    $Self->{Translation}->{"Developer's Note."} = 'Nota del desarrollador.';
    $Self->{Translation}->{'Enable error message for unsupported browsers.'} = 'Habilitar mensaje de error para navegadores no compatibles.';

    push @{ $Self->{JavaScriptStrings} // [] }, (
    'Next',
    );
}

1;