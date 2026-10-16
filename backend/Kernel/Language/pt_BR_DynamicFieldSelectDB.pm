# --
# Kernel/Language/pt_BR_DynamicFieldSelectDB.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::Language::pt_BR_DynamicFieldSelectDB;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Search with AND clause'} = 'Pesquisa com a cláusula AND';
    $Self->{Translation}->{'Column'} = 'Coluna';
    $Self->{Translation}->{'Dynamic Field'} = 'Campo Dinâmico';
    $Self->{Translation}->{'Specify the table column and the dynamic field to perform an AND search.'} = 'Especifique a coluna da tabela e o campo dinâmico para realizar uma pesquisa com AND.';

    $Self->{Translation}->{'MinQueryLength'} = 'Tamanho mínimo da consulta';
    $Self->{Translation}->{'Specify the MinQueryLength. 0 deactivates the autocomplete.'} = 'Especifique o comprimento mínimo da consulta. 0 desativa o preenchimento automático.';
    $Self->{Translation}->{'MaxQueryResult'} = 'Resultado máximo da consulta.';
    $Self->{Translation}->{'Specify the MaxQueryResult.'} = 'Especifique o resultado máximo da consulta.';
    $Self->{Translation}->{'DatabaseDSN'} = 'DSN do banco';
    $Self->{Translation}->{'Specify the DSN for used database.'} = 'Especifique o DSN para o banco de dados usado.';
    $Self->{Translation}->{'DatabaseUser'} = 'Usuário do banco';
    $Self->{Translation}->{'Specify the user for used database.'} = 'Especifique o usuário para o banco de dados usado.';
    $Self->{Translation}->{'DatabasePW'} = 'Senha do banco';
    $Self->{Translation}->{'Specify the password for used database.'} = 'Especifique a senha do banco de dados usado.';
    $Self->{Translation}->{'DatabaseType'} = 'Tipo do banco.';
    $Self->{Translation}->{'Specify the type of used database. Needed for ODBC connections. Supported are mssql, mysql, oracle and postgresql.'} = 'Especifique o tipo de banco de dados usado. Necessário para conexões ODBC. Suportados são mssql, mysql, oracle e postgresql.';
    $Self->{Translation}->{'DatabaseTable'} = 'Tabela do banco';
    $Self->{Translation}->{'Specify the table for used database.'} = 'Especifique a tabela para o banco de dados usado.';
    $Self->{Translation}->{'DatabaseFieldKey'} = 'Chave de identificação';
    $Self->{Translation}->{'Free field'} = 'Campo livre';
    $Self->{Translation}->{'Field intended for SQL snippets manually. the snippet will be added after "WHERE" and before "ORDER BY". Use <DynamicField_name> to get dynamic field values on screen.'} = 'Campo destinado a trechos SQL manualmente. o trecho será adicionado após o "WHERE" e antes de "ORDER BY". Utilize <DynamicField_name> para pegar valores de campo dinâmico em tela.';
    $Self->{Translation}->{'Specify the key field of the database used.'} = 'Especifique o campo-chave do banco de dados usado.';
    $Self->{Translation}->{'DatabaseFieldValue'} = 'Colunas da tabela';
    $Self->{Translation}->{'Specify the fields of the database used. Set the columns in the key, and in the values ​​the names of the dynamic fields.'} = 'Especifique os campos do banco de dados usados. Defina na chave as colunas, e nos valores os nomes do campos dinâmicos.';
    $Self->{Translation}->{'DatabaseFieldSearch'} = 'Pesquisar por';
    $Self->{Translation}->{'Specify the search argument to find results in the table. To search in one or more columns, place separated by semicolons.'} = 'Especifique o argumento de pesquisa para localizar resultados na tabela. Para buscar em uma ou mais colunas, coloque separadado por ponto e virgula.';
    $Self->{Translation}->{'CacheTTL'} = 'Tempo de permanência em Cache';
    $Self->{Translation}->{'Cache any database queries for time in seconds.'} = 'Armazene em cache as consultas do banco de dados por tempo em segundos.';
    $Self->{Translation}->{'0 deactivates caching.'} = '0 desativa o armazenamento em cache.';
    $Self->{Translation}->{'CachePossibleValues'} = 'Valores Possíveis de Cache';
    $Self->{Translation}->{'Cache all possible values.'} = 'Cache todos os valores possíveis.';
    $Self->{Translation}->{'If active, the usage of values which recently added to the database may cause an error.'} = 'Se estiver ativo, o uso de valores adicionados recentemente ao banco de dados pode causar um erro.';
    $Self->{Translation}->{'MaxArraySize'} = 'Quantidade máxima';
    $Self->{Translation}->{'Specify the maximum number of entries.'} = 'Especifique o número máximo de entradas.';
    $Self->{Translation}->{'Standard Connection'} = 'Conexão Padrão';
    $Self->{Translation}->{'Using the default connection, it will connect to the local database.'} = 'Usando a conexão padrão, ele fará a conexão com o banco de dados local.';

    push @{ $Self->{JavaScriptStrings} // [] }, (
    'No',
    'Ok',
    'Settings',
    'Submit',
    'Yes',
    );

}

1;