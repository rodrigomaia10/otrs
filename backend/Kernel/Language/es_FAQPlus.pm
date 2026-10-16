# --
# Kernel/Language/es_FAQPlus.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * gbolsoni@serviceup.com.br
# --

package Kernel::Language::es_FAQPlus;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Defines the list of email addresses that will receive notifications upon FAQ creation or update.'} = 'Define la lista de direcciones de correo electrónico que recibirán notificaciones sobre la creación o actualización de FAQs.';
    $Self->{Translation}->{'Defines the subject and body templates for notification emails sent when a FAQ is created.'} = 'Define las plantillas de asunto y cuerpo para los correos electrónicos de notificación enviados cuando se crea una FAQ.';
    $Self->{Translation}->{'Defines the subject and body templates for notification emails sent when a FAQ is updated.'} = 'Define las plantillas de asunto y cuerpo para los correos electrónicos de notificación enviados cuando se actualiza una FAQ.';
    $Self->{Translation}->{'waiting for approval (agent)'} = 'aguardando aprovação (agente)';
    $Self->{Translation}->{'Only create approval ticket in new FAQs.'} = 'Crear ticket de aprobación solo en nuevas preguntas frecuentes.';
	$Self->{Translation}->{'Change FAQ Dialog size.'} = 'Aumenta o tamanho do dialog da FAQ.';


}

1;
