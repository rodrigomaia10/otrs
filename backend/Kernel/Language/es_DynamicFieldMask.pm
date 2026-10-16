# --
# Kernel/Language/es_DynamicFieldMask.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * pdias@beonup.com.br
# * mtatangelo@serviceup.com.br
# --

package Kernel::Language::es_DynamicFieldMask;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminDynamicFieldMask
	$Self->{Translation}->{'Mask'} = 'Máscara';
	$Self->{Translation}->{'Mask Type'} = 'Tipo de Máscara';
    $Self->{Translation}->{'Monetary'} = 'Monetario';
    $Self->{Translation}->{'Default'} = 'Patrón';
    $Self->{Translation}->{'Currency'} = 'Divisa';
    $Self->{Translation}->{'Do Not Allow Negative Values'} = 'No permita valores negativos';
    $Self->{Translation}->{'Allow Negative Values'} = 'Permitir Valores Negativos';
    $Self->{Translation}->{'Chose the mask type to be displayed by the field.'} = 'Seleccione el tipo de máscara que se mostrará en el campo.';
    $Self->{Translation}->{'This field is required.'} = 'Este campo es obligatorio.';

    # SysConfig
    $Self->{Translation}->{'ITIN'} = 'CPF';
    $Self->{Translation}->{'CNPJ'} = 'CNPJ';
    $Self->{Translation}->{'Zip Code'} = 'Código postal';
    $Self->{Translation}->{'Set the possible masks to be displayed.'} = 'Configure las posibles máscaras que se mostrarán.';

    return 1;
}

1;
