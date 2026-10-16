# --
# Kernel/Language/pt_BR_VerifyDynamicFieldDate.pm
# Copyright (C) 2019 Service UP, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# --

package Kernel::Language::pt_BR_VerifyDynamicFieldDate;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift; 

    $Self->{Translation}->{'Ticket VerifyDinamicFieldDate Daemon.'} = 'Cron para o módulo VerifyDinamicFieldDate';
    
    $Self->{Translation}->{'Set the Services ID to filter date.'} = 'Adicione os IDs dos serviços para filtrar';
        
    $Self->{Translation}->{'Set the DynamicField Date name to compare'} = 'Adicione o nome do campo dinâmico de data';
   
    $Self->{Translation}->{'Dynamic Field DataAtingida value change to Yes'} = 'Valor do campo dinâmico DataAtingida atualizado para Sim';
}

1;

