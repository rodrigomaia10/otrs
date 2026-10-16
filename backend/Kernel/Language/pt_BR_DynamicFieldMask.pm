# --
# Kernel/Language/pt_BR_DynamicFieldMask.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * pdias@beonup.com.br
# * mtatangelo@serviceup.com.br
# --

package Kernel::Language::pt_BR_DynamicFieldMask;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminDynamicFieldMask
	$Self->{Translation}->{'Mask'} = 'Máscara';
	$Self->{Translation}->{'Mask Type'} = 'Tipo de Máscara';
    $Self->{Translation}->{'Monetary'} = 'Monetária';
    $Self->{Translation}->{'Default'} = 'Padrão';
    $Self->{Translation}->{'Currency'} = 'Moeda';
    $Self->{Translation}->{'Do Not Allow Negative Values'} = 'Não Permitir Valores Negativos';
    $Self->{Translation}->{'Allow Negative Values'} = 'Permitir Valores Negativos';
    $Self->{Translation}->{'Chose the mask type to be displayed by the field.'} = 'Selectione o tipo de máscara para ser exibida pelo campo.';
    $Self->{Translation}->{'This field is required.'} = 'Este campo é obrigatório.';

    # SysConfig
    $Self->{Translation}->{'ITIN'} = 'CPF';
    $Self->{Translation}->{'CNPJ'} = 'CNPJ';
    $Self->{Translation}->{'Zip Code'} = 'CEP';
    $Self->{Translation}->{'Set the possible masks to be displayed.'} = 'Defina as máscaras possíveis a serem exibidas.';

    return 1;
}

1;
