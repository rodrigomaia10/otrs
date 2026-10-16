# --
# Kernel/Language/es_ToolBox.pm 
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * jguedes@serviceup.com.br
# --

package Kernel::Language::es_ToolBox;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    
    $Self->{Translation}->{'Advance'}              = 'Avanzar';
    $Self->{Translation}->{'Agent Preferences'}    = 'Preferencias del agente';
    $Self->{Translation}->{'Customer Preferences'} = 'Preferencias del cliente';
    $Self->{Translation}->{'ToolBox Management'}   = 'Administración de ToolBox';
    $Self->{Translation}->{'Preference Name'}      = 'Nombre de preferencia';
    $Self->{Translation}->{'Preference Value'}     = 'Valor de preferencia';
    $Self->{Translation}->{'ToolBox Management'}   = 'Administración de ToolBox';
    $Self->{Translation}->{'Preference Settings'}  = 'Configuración de preferencias'; 
    $Self->{Translation}->{'Preference successfully changed!'}  = '¡La preferencia cambió con éxito!';
    $Self->{Translation}->{'Manage'}  = 'Gestionar';
}

1;