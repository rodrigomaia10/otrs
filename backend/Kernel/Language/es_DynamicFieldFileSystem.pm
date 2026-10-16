# --
# Kernel/Language/es_DynamicFieldFileSystem.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * dparavani@serviceup.com.br
# --

package Kernel::Language::es_DynamicFieldFileSystem;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Delete File'} = 'Borrar archivo';
    $Self->{Translation}->{'If you activate this option hide the file field of article.'} = 'Si activa esta opción oculta el campo de archivo del artículo.';
    $Self->{Translation}->{'If this option is active, in the field display, it will make it possible to delete existing files.'} = 'Si esta opción está activa, en la pantalla de campo, permitirá eliminar archivos existentes.';
    $Self->{Translation}->{'The file name exceeds the 200 character limit.'} = 'El nombre del archivo supera el límite de 200 caracteres.';
    $Self->{Translation}->{'The file size cannot be larger than '} = 'El tamaño del archivo no puede ser mayor que ';
    $Self->{Translation}->{'Do you really want to delete this file?'} = '¿Realmente desea eliminar este archivo?';
    $Self->{Translation}->{'Attachment deletion'} = 'Eliminación de archivos adjuntos';
    $Self->{Translation}->{'Article File'} = 'Archivo de artículo';
    $Self->{Translation}->{'This option defines whether the files link will be public.'} = 'Esta opción define si el enlace de los archivos será público.';
    $Self->{Translation}->{'Add Field FileSystem'} = 'Agregar campo de sistema de archivos'; 
    $Self->{Translation}->{'Edit Field FileSystem'} = 'Editar campo del sistema de archivos';
    $Self->{Translation}->{'Specifies the directory to store the attachments.'} = 'Especifica el directorio para almacenar archivos adjuntos.';
    $Self->{Translation}->{'Default File'} = 'Archivo predeterminado';
    $Self->{Translation}->{'Specify the path to the file that will be attached by default.'} = 'Especifique la ruta al archivo que se adjuntará de forma predeterminada.';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'The file name exceeds the 200 character limit.',
        'The file size cannot be larger than ',
        'Do you really want to delete this file?',
        'Attachment deletion',
        "Article File"
    );
}

1;