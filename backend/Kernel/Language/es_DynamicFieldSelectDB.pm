# --
# Kernel/Language/es_DynamicFieldSelectDB.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * jsantos@serviceup.com.br
# --

package Kernel::Language::es_DynamicFieldSelectDB;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Search with AND clause'} = 'Investigación con la cláusula AND';
    $Self->{Translation}->{'Column'} = 'Columna';
    $Self->{Translation}->{'Dynamic Field'} = 'Campo dinámico';
    $Self->{Translation}->{'Specify the table column and the dynamic field to perform an AND search.'} = 'Especifique la columna de la tabla y el campo dinámico para realizar una búsqueda Y.';

    $Self->{Translation}->{'MinQueryLength'} = 'Tamaño mínimo de consulta';
    $Self->{Translation}->{'Specify the MinQueryLength. 0 deactivates the autocomplete.'} = 'Especifique la longitud mínima de la consulta. 0 desactiva la función de autocompletar.';
    $Self->{Translation}->{'MaxQueryResult'} = 'Resultado de consulta máximo.';
    $Self->{Translation}->{'Specify the MaxQueryResult.'} = 'Especifique el resultado máximo de la consulta.';
    $Self->{Translation}->{'DatabaseDSN'} = 'Banco DSN';
    $Self->{Translation}->{'Specify the DSN for used database.'} = 'Especifique el DSN de la base de datos utilizada.';
    $Self->{Translation}->{'DatabaseUser'} = 'Usuario de la base';
    $Self->{Translation}->{'Specify the user for used database.'} = 'Especifique el usuario de la base de datos utilizada.';
    $Self->{Translation}->{'DatabasePW'} = 'Contraseña de la base';
    $Self->{Translation}->{'Specify the password for used database.'} = 'Especifique la contraseña de la base de datos utilizada.';
    $Self->{Translation}->{'DatabaseType'} = 'Tipo de la base.';
    $Self->{Translation}->{'Specify the type of used database. Needed for ODBC connections. Supported are mssql, mysql, oracle and postgresql.'} = 'Especifique el tipo de base de datos utilizada. Requerido para conexiones ODBC. Se admiten mssql, mysql, oracle y postgresql.';
    $Self->{Translation}->{'DatabaseTable'} = 'Tabla de base de datos';
    $Self->{Translation}->{'Specify the table for used database.'} = 'Especifique la tabla para la base de datos utilizada.';
    $Self->{Translation}->{'DatabaseFieldKey'} = 'Clave de identificación';
    $Self->{Translation}->{'Free field'} = 'Campo libre';
    $Self->{Translation}->{'Field intended for SQL snippets manually. the snippet will be added after "WHERE" and before "ORDER BY". Use <DynamicField_name> to get dynamic field values on screen.'} = 'Campo destinado a los fragmentos de código SQL manualmente. el fragmento se agregará después de "WHERE" y antes de "ORDER BY". Utilice <DynamicField_name> para obtener valores de campo dinámicos en la pantalla.';
    $Self->{Translation}->{'Specify the key field of the database used.'} = 'Especifique el campo clave de la base de datos utilizada.';
    $Self->{Translation}->{'DatabaseFieldValue'} = 'Columnas de la tabla';
    $Self->{Translation}->{'Specify the fields of the database used. Set the columns in the key, and in the values ​​the names of the dynamic fields.'} = 'Especifique los campos de la base de datos utilizados. Defina en la clave las columnas y en los valores los nombres de los campos dinámicos.';
    $Self->{Translation}->{'DatabaseFieldSearch'} = 'Buscar';
    $Self->{Translation}->{'Specify the search argument to find results in the table. To search in one or more columns, place separated by semicolons.'} = 'Especifique el argumento de búsqueda para buscar resultados en la tabla. Para buscar en una o más columnas, coloque separado por punto y coma.';
    $Self->{Translation}->{'CacheTTL'} = 'Tiempo de permanencia en caché';
    $Self->{Translation}->{'Cache any database queries for time in seconds.'} = 'Almacene las consultas de la base de datos por tiempo en segundos.';
    $Self->{Translation}->{'0 deactivates caching.'} = '0 deshabilita el almacenamiento en caché.';
    $Self->{Translation}->{'CachePossibleValues'} = 'Posibles valores de caché';
    $Self->{Translation}->{'Cache all possible values.'} = 'Almacene en caché todos los valores posibles.';
    $Self->{Translation}->{'If active, the usage of values which recently added to the database may cause an error.'} = 'Si está habilitado, el uso de valores agregados recientemente a la base de datos puede causar un error.';
    $Self->{Translation}->{'MaxArraySize'} = 'Cantidad maxima';
    $Self->{Translation}->{'Specify the maximum number of entries.'} = 'Especifique el número máximo de entradas.';
    $Self->{Translation}->{'Standard Connection'} = 'Conexión estándar';
    $Self->{Translation}->{'Using the default connection, it will connect to the local database.'} = 'Usando la conexión predeterminada, se conectará a la base de datos local.';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'No',
        'Ok',
        'Settings',
        'Submit',
        'Yes',
    );
}

1;