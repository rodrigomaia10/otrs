# --
# Kernel/Language/pt_BR_ToolBox.pm 
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jguedes@serviceup.com.br
# --

package Kernel::Language::pt_BR_ToolBox;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    
    $Self->{Translation}->{'Advance'}              = 'Avançar';
    $Self->{Translation}->{'Agent Preferences'}    = 'Preferências do Atendente';
    $Self->{Translation}->{'Customer Preferences'} = 'Preferências do Cliente';
    $Self->{Translation}->{'ToolBox Management'}   = 'Gerenciamento de Ferramentas';
    $Self->{Translation}->{'Preference Name'}      = 'Nome da preferência';
    $Self->{Translation}->{'Preference Value'}     = 'Valor';
    $Self->{Translation}->{'ToolBox Management'}   = 'Gerenciamento de Ferramentas';
    $Self->{Translation}->{'Preference Settings'}  = 'Configuração de Preferência'; 
    $Self->{Translation}->{'Preference successfully changed!'}  = 'Preferência alterada com sucesso!';
    $Self->{Translation}->{'Manage'}  = 'Gerenciar';
}

1;