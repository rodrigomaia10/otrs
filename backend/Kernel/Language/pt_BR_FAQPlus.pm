# --
# Kernel/Language/pt_BR_FAQPlus.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * gbolsoni@serviceup.com.br
# --

package Kernel::Language::pt_BR_FAQPlus;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

	$Self->{Translation}->{'Defines the list of email addresses that will receive notifications upon FAQ creation or update.'} = 'Define a lista de endereços de e-mail que receberão notificações sobre a criação ou atualização de FAQs.';
	$Self->{Translation}->{'Defines the subject and body templates for notification emails sent when a FAQ is created.'} = 'Define os modelos de assunto e corpo para e-mails de notificação enviados quando uma FAQ é criada.';
	$Self->{Translation}->{'Defines the subject and body templates for notification emails sent when a FAQ is updated.'} = 'Define os modelos de assunto e corpo para e-mails de notificação enviados quando uma FAQ é atualizada.';
	$Self->{Translation}->{'waiting for approval (agent)'} = 'aguardando aprovação (agente)';
	$Self->{Translation}->{'Only create approval ticket in new FAQs.'} = 'Somente criar chamado de aprovação em FAQs novas.';
	$Self->{Translation}->{'Change FAQ Dialog size.'} = 'Aumenta o tamanho do dialog da FAQ.';
}

1;
