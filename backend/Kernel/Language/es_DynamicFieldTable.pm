# --
# Kernel/Language/es_DynamicFieldTable.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * dsilva@serviceup.com.br
# * lcavalheiro@serviceup.com.br
# * ykanegae@serviceup.com.br
# --

package Kernel::Language::es_DynamicFieldTable;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    
    # Template: AdminDynamicFieldTable
    $Self->{Translation}->{'Column'} = 'Columna';
    $Self->{Translation}->{'Mask Settings'} = 'Configuraciones de máscara';
    $Self->{Translation}->{'Sum Settings'} = 'Configuraciones de suma';
    $Self->{Translation}->{'Edition Permissions'} = 'Editar permisos';
    $Self->{Translation}->{'Text Mask Settings'} = 'Configuración de máscara de texto';
    $Self->{Translation}->{'Monetary Mask Settings'} = 'Configuración de máscara monetaria';
    $Self->{Translation}->{'Currency'} = 'Moneda';
    $Self->{Translation}->{'Negative'} = 'Negativo';    
    $Self->{Translation}->{'Sum Columns'} = 'Agregar columnas';
    $Self->{Translation}->{'Sum Rows'} = 'Agregar líneas';
    $Self->{Translation}->{'Columns'} = 'Columnas';
    $Self->{Translation}->{'States to Disable'} = 'Inhabilitar estados';
    $Self->{Translation}->{'Changing the column data its necessary select again the columns to be sum.'} = 'Al cambiar los datos de la columna, es necesario seleccionar las columnas que se agregarán nuevamente.';
    $Self->{Translation}->{'Selecting to add the rows will use the columns selected above in Add Columns.'} = 'Al seleccionar agregar las filas, se utilizarán las columnas seleccionadas anteriormente en Agregar columnas.';
    $Self->{Translation}->{'States which the table will be disabled to edition.'} = 'Estados en los que se deshabilitará la tabla para su edición.';
    $Self->{Translation}->{'Insert a name for the column, a data type and for List insert the possible options (add item list separate by semicolon).'} = 'Ingrese el nombre de la columna, el tipo de datos y para la Lista ingrese las opciones posibles (agregue elementos separados por punto y coma).';
    $Self->{Translation}->{'Column sum settings'} = 'Configuración de suma de columnas';
    $Self->{Translation}->{'Row sum settings'} = 'Configuración de suma de línea';
    $Self->{Translation}->{'Operation Settings'} = 'Configurar operaciones de columna';
    $Self->{Translation}->{'Operation'} = 'Operación';
    $Self->{Translation}->{'Dynamic Field'} = 'Campo dinámico';
    $Self->{Translation}->{'Info DynamicFieldTable'} = 'Información - Campo de tabla dinámica';
    $Self->{Translation}->{'DynamicFieldTable'} = 'Campo de tabla dinámica';
    $Self->{Translation}->{'View DynamicFieldTable'} = 'Vista previa';
    $Self->{Translation}->{'AgentTicketZoom widget that displays the DynamicFieldTable.'} = 'Vista de widget que muestra información del campo de tabla dinámica.';
    $Self->{Translation}->{'Show link to edit dynamic field TimeAccounted.'} = 'Mostrar enlace para editar el campo dinámico TimeAccounted.';
    $Self->{Translation}->{'Change'} = 'Cambio';
    $Self->{Translation}->{'Field'} = 'Campo';
    $Self->{Translation}->{'To view'} = 'Vista previa';


    # Perl Module: AdminDynamicFieldTable    
    $Self->{Translation}->{'Numeric'} = 'Numérico';
    $Self->{Translation}->{'Mask'} = 'Mascaras';
    $Self->{Translation}->{'Text (Mask)'} = 'Texto (Máscara)';
    $Self->{Translation}->{'Monetary'} = 'Monetario';
    $Self->{Translation}->{'Move Up'} = 'Mover hacia arriba';
    $Self->{Translation}->{'Editable by'} = 'Editable por';

    # SysConfig
    $Self->{Translation}->{'ITIN'} = 'CPF';
    $Self->{Translation}->{'CNPJ'} = 'CNPJ';
    $Self->{Translation}->{'Zip Code'} = 'Código postal';
    $Self->{Translation}->{'Table'} = 'Tabla';
    $Self->{Translation}->{'Creates the structure of the dynamic field table to be displayed in the GUI.'} = 'Crea la estructura de los campos de la tabla dinámica que se mostrarán en la GUI.';
    $Self->{Translation}->{'Configuration to store the sum columns on DynamicField. Set the key as the table name and define the content as the columns that will be summed with the following format: {"Column1":"DynamicField_Column1","Column2":"DynamicField_Column2"}.'} = 'Configuración para almacenar las columnas de suma en DynamicField. Defina la clave como el nombre de la tabla y defina el contenido como las columnas que se agregarán con el siguiente formato: {"Coluna1": "DynamicField_Coluna1", "Coluna2": "DynamicField_Coluna2"}.';
    $Self->{Translation}->{'Task to remove temporary data from the database.'} = 'Tarea para eliminar datos temporales de la base de datos.';
    $Self->{Translation}->{'Set the possible masks to be displayed.'} = 'Defina las posibles máscaras que se mostrarán.';
    $Self->{Translation}->{'Defines whether the list type column options will be sorted.'} = 'Define si se ordenarán las opciones de columna de tipo de lista.';
    
    # DynamicFieldTableRender
    $Self->{Translation}->{'Format Export'} = 'Formato de exportación';
    $Self->{Translation}->{'Select the format export.'} = 'Seleccione un formato para exportar.';
    $Self->{Translation}->{'RowTotal'} = 'TOTAL';
    $Self->{Translation}->{'Attention!'} = '¡Atención!';
    $Self->{Translation}->{'RowTotal'} = '¡Todos los campos de la tabla deben completarse!';
    $Self->{Translation}->{'Show table'} = 'Mostrar tabla';



    # Config
    $Self->{Translation}->{'Frontend module registration for the agent interface.'} = 'Registro de módulo para la interfaz del agente.';
    $Self->{Translation}->{'Loader module registration for the agent interface.'} = 'Registro del módulo de carga para la interfaz del agente.';
    $Self->{Translation}->{'DynamicField backend registration.'} = 'Registro de campo dinámico.';
    $Self->{Translation}->{'Creates the structure of the dynamic field table to be displayed in the GUI'} = 'Crea la estructura de la tabla de campo dinámico que se mostrará.';
    $Self->{Translation}->{'Frontend module registration for the customer interface.'} = 'Módulo de registro para la interfaz del cliente.';
    $Self->{Translation}->{'Set the possible masks to be displayed.'} = 'Definir las posibles máscaras que se mostrarán.';
    $Self->{Translation}->{'Frontend module registration for the DynamicFieldTable.'} = 'Registro de módulo para el campo dinámico de tabla.';
    $Self->{Translation}->{'Configuration to store the sum columns on DynamicField. Set the key as the table name and define the content as the columns that will be summed with the following format: {"Column1":"DynamicField_Column1","Column2":"DynamicField_Column2"}.'} = 'Configuración para almacenar las columnas de suma en DynamicField. Defina la clave como el nombre de la tabla y defina el contenido como las columnas que se agregarán con el siguiente formato: {"Columna1": "DynamicField_Column1", "Column2": "DynamicField_Column2"}.';
        $Self->{Translation}->{'Defines whether the column must be or not in sum row. If empty, all columns will be considered. The label must consist of {field_label}_{field_property_name} EX: Quantity Materials_Quantity.'} 
        = 'Define si la columna debe estar o no en la fila de suma. Si está vacía, se tendrán en cuenta todas las columnas. La etiqueta debe constar de {etiqueta_campo}_{nombre_propiedad_campo} EX: Cantidad Materiales_Cantidad';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'Attention!',
        'All fields in the table must be completed!',
    );

    return 1;
}

1;