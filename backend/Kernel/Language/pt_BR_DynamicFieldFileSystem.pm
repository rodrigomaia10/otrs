# --
# Kernel/Language/pt_BR_DynamicFieldFileSystem.pm
# Copyright (C) 2019 Service Up, http://serviceup.com.br/
#
# written/edited by:
# * dsilva@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::pt_BR_DynamicFieldFileSystem;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    
    $Self->{Translation}->{'Delete File'} = 'Excluir Arquivo';
    $Self->{Translation}->{'If you activate this option hide the file field of article.'} = 'Se você ativar esta opção, oculte o campo de arquivo do artigo.';
    $Self->{Translation}->{'If this option is active, in the field display, it will make it possible to delete existing files.'} = 'Se esta opção estiver ativa, na exibição do campo, ela possibilitará deletar os arquivos já existentes.';
    $Self->{Translation}->{'The file name exceeds the 200 character limit.'} = 'Nome do arquivo excede o limite de 200 caracteres.';
    $Self->{Translation}->{'The file size cannot be larger than '} = 'O tamanho do arquivo não pode ser maior que ';
    $Self->{Translation}->{'Do you really want to delete this file?'} = 'Deseja realmente excluir esse arquivo?';
    $Self->{Translation}->{'Attachment deletion'} = 'Exclusão de anexo';
    $Self->{Translation}->{'Article File'} = 'Arquivo de artigo';
    $Self->{Translation}->{'This option defines whether the files link will be public.'} = 'Esta opção define se o link dos arquivos será público.';
    $Self->{Translation}->{'Add Field FileSystem'} = 'Adicionar Campo FileSystem';
    $Self->{Translation}->{'Edit Field FileSystem'} = 'Editar Campo FileSystem';
    $Self->{Translation}->{'Specifies the directory to store the attachments.'} = 'Especifica o diretório para armazenar os anexos.';
    $Self->{Translation}->{'Default File'} = 'Arquivo padrão';
    $Self->{Translation}->{'Specify the path to the file that will be attached by default.'} = 'Especifique o caminho para o arquivo que será anexado como padrão.';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'The file name exceeds the 200 character limit.',
        'The file size cannot be larger than ',
        'Do you really want to delete this file?',
        'Attachment deletion',
        "Article File"
    );    
}

1;