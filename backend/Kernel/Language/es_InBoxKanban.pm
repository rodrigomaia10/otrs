# --
# Kernel/Language/es_InBoxKanban.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@beonup.com.br
# * poliveira@serviceup.com.br
# --

package Kernel::Language::es_InBoxKanban;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Kanban Boards'} = 'Kanban Boards';
    $Self->{Translation}->{'Added dynamic fields name to ordination in column of kanban'} = 'Agregue nombres de campo dinámico para ordenar las llamadas de columna';
    $Self->{Translation}->{'BoardColor'} = 'Color del marco';
    $Self->{Translation}->{'My Boards'} = 'Mis marco';
    $Self->{Translation}->{'Add Kanban Boards'} = 'Agregar marcos Kanban';
    $Self->{Translation}->{'Deleting the field and its data. This may take a while...'} = 'Eliminar el campo y sus datos. Esto puede tomar un tiempo ...';
    $Self->{Translation}->{'Do you really want to delete this Kanban? ALL associated data will be LOST!'} = '¿Realmente quieres ELIMINAR esta columna kanban? Los datos asociados serán eliminados.';
    $Self->{Translation}->{'This is the name to be shown on the screens.'} = 'Este nombre se mostrará en el encabezado de la columna.';
    $Self->{Translation}->{'This will be the order of the column in the table.'} = 'Este será el orden de la columna en la tabla.';
    $Self->{Translation}->{'Kanban Columns'} = 'Columnas Kanban';
    $Self->{Translation}->{'Add board'} = 'Agregar marco';
    $Self->{Translation}->{'Boards'} = 'Marcos';
    $Self->{Translation}->{'Board'} = 'Marco';
    $Self->{Translation}->{'Columns'} = 'Columnas';
    $Self->{Translation}->{'Filter for Kanban Boards'} = 'Filtros para marcos de Kanban';
    $Self->{Translation}->{'Boards Management'} = 'Gestión de marco';
    $Self->{Translation}->{'Create Kanban Boards.'} = 'Crear marcos kanban';
    $Self->{Translation}->{'Create and configure Kanban columns'} = 'Creación y configuración de columnas Kanban';
    $Self->{Translation}->{'Kanban column management'} = 'Kanban Column Management';
    $Self->{Translation}->{'Delete this Kanban'} = 'Eliminar este Kanban';
    $Self->{Translation}->{'Copy this Kanban'} = 'Copia este Kanban';
    $Self->{Translation}->{'Filter for column'} = 'Filtro de columna';
    $Self->{Translation}->{'Kanban Column List'} = 'Lista de columnas Kanban';
    $Self->{Translation}->{'Add new Column for object'} = 'Agregar una nueva columna';
    $Self->{Translation}->{'Edit Column'} = 'Editar columna';
    $Self->{Translation}->{'Column Settings'} = 'Ajuste de columna';
    $Self->{Translation}->{'Admin Kanban'} = 'Administrar columnas';
    $Self->{Translation}->{'Add'} = 'Agregar';
    $Self->{Translation}->{'Add values ​​to display in Details'} = 'Agregar valores para mostrar en Detalles';
    $Self->{Translation}->{'Manual sorting'} = 'Clasificación manual';
    $Self->{Translation}->{'Ordination'} = 'Clasificación';
    $Self->{Translation}->{'Details'} = 'Detalles';
    $Self->{Translation}->{'Command'} = 'Orden';
    $Self->{Translation}->{'Change Responsible'} = 'Cambiar responsable';
    $Self->{Translation}->{'Sorry, you have not permission to do this action'} = 'Lo sentimos, no tienes permiso para realizar esta acción.';
    $Self->{Translation}->{'Kanban Boards'} = 'Kanban Boards';
    $Self->{Translation}->{'Added Responsible in ticket card.'} = 'Agregar cambio y visualización de Responsable a la tarjeta de boleto';
    $Self->{Translation}->{'New Queue'} = 'Nueva cola';
    $Self->{Translation}->{'Define the priorities colors'} = 'Establecer colores prioritarios';
    $Self->{Translation}->{'Board Label Color'} = 'Color de fuente del marco';
    $Self->{Translation}->{'Kanban time to reload view in minutes.'} = 'Tiempo para que kanban actualice su pantalla (en minutos)';
    $Self->{Translation}->{'Change Owner'} = 'Cambiar propietario';
    $Self->{Translation}->{'Edit Kanban Boards'} = 'Editar marco Kanban';
    $Self->{Translation}->{'Coluns fields per page'} = 'Columnas por página';
    $Self->{Translation}->{'Maximum ticket limit in column'} = 'Límite máximo de llamadas de columna';
    $Self->{Translation}->{'Parameters after moving to this column'} = 'Parámetros después de pasar a esta columna';
    $Self->{Translation}->{'You can add a new column, and after that add it to a frame, the object sets the search limit and cannot be changed after the column is created.'} = 'Puede agregar una nueva columna y luego agregarla a un marco..';
    $Self->{Translation}->{'To add the queue, select them in the filter.'} = 'Para adicionar a fila, selecione-as no filtro';
    $Self->{Translation}->{'State change by InBox Kanban'} = 'Estado cambiado por InBox Kanban';
    $Self->{Translation}->{'Queue change by InBox Kanban'} = 'Cola modificada por InBox Kanban';
    $Self->{Translation}->{'Frontend module registration for the agent interface.'} = 'Registro frontend para el módulo en la interfaz de operadora';
    $Self->{Translation}->{'Loader module registration for the agent interface.'} = 'Registro del módulo cargador para la interfaz del agente.';
    $Self->{Translation}->{'Frontend module AJAX handler for the agent interface.'} = 'Controlador AJAX del módulo front-end para la interfaz del agente.';
    $Self->{Translation}->{'This column cannot be sorted manually. The calling card will be reordered.'} = 'Esta columna no se puede ordenar manualmente. La tarjeta de llamada será reordenada.';
    $Self->{Translation}->{'Parameters for the pages (in which the Kanbans are shown) of the Kanban overview.'} = 'Parámetros para las páginas (en las que se muestran los kanbans) del resumen de kanban.';

    $Self->{Translation}->{'Rules in use'} = 'Reglas en uso';
	$Self->{Translation}->{'Severity order'} = 'Orden de gravedad';
	$Self->{Translation}->{'Descending'} = 'Descendiente';
	$Self->{Translation}->{'Ascending'} = 'Ascendente';
	$Self->{Translation}->{'FullScreen'} = 'Pantalla completa';
    $Self->{Translation}->{'View Settings'} = 'Configuración de visión';
    $Self->{Translation}->{'To add the state, select them in the filter.'} = 'Para agregar el estado, selecciónelos en el filtro.';
    $Self->{Translation}->{'Add new board for object'} = 'Agregar nuevo marco';
    $Self->{Translation}->{'Add column'} = 'Agregar columna';
    $Self->{Translation}->{'New ticket'} = 'Nueva vocación';
    $Self->{Translation}->{'Edit board'} = 'Editar marco';
    $Self->{Translation}->{'Decrease Priority'} = 'Disminuir la prioridad';
    $Self->{Translation}->{'Share'} = 'Split';
    $Self->{Translation}->{'Email Ticket'} = 'Email llamado';
    $Self->{Translation}->{'Phone Ticket'} = 'Teléfono llamado';
    $Self->{Translation}->{'Which article will be added by splitting.'} = '¿Qué artículo se usará para dividir el llamado';
    $Self->{Translation}->{'First Article'} = 'Primer articulo';
    $Self->{Translation}->{'Last Article'} = 'Artículo más reciente';
    $Self->{Translation}->{'Ticket Email'} = 'Email llamado';
    $Self->{Translation}->{'Ticket Phone'} = 'Teléfono llamado';
    $Self->{Translation}->{'Buttons to card'} = 'Botones para la tarjeta';
    $Self->{Translation}->{'Close ticket'} = 'Cerrar llamada';
    $Self->{Translation}->{'Change Queues'} = 'Cambiar cola';
    $Self->{Translation}->{'Add note'} = 'Cambiar cola';
    $Self->{Translation}->{'Classify'} = 'Tasa';
    $Self->{Translation}->{'Increase Priority'} = 'Aumentar la prioridad';
    $Self->{Translation}->{'Start collapsed'} = 'Comience colapsado';
    $Self->{Translation}->{'By Phone'} = 'Por teléfono';
    $Self->{Translation}->{'By Email'} = 'Por correo electrónico';
    $Self->{Translation}->{'Manage Boards'} = 'Administrar marcos';
    $Self->{Translation}->{'Manage Columns'} = 'Administrar columnas';
    $Self->{Translation}->{'Preview Only'} = 'Vista previa solamente';
    $Self->{Translation}->{'Number of tickets'} = 'Numero de llamadas';
    $Self->{Translation}->{'Total of tickets'} = 'Llamadas totales';
    $Self->{Translation}->{'By Process'} = 'Vía proceso';
    $Self->{Translation}->{'Lock'} = 'Bloque';
    $Self->{Translation}->{'Define how the ticket when be open by kanban'} = 'Defina cómo se abrirá la llamada a través de Kanban';
    $Self->{Translation}->{'Define what data will appear on the task card. Set 0 to disable or 1 to enable'} = 'Defina qué datos aparecerán en la tarjeta de tareas. Establezca 0 para deshabilitar o 1 para habilitar';
    $Self->{Translation}->{'Add column'} = 'Agregar columna';
    $Self->{Translation}->{'SLA In'} = 'SLA dentro';
    $Self->{Translation}->{'Add SLA icon for tickets that have a solution deadline.'} = 'Agregue el ícono de SLA para los tickets que tienen una fecha límite de solución.';
    $Self->{Translation}->{'To add the priority, select them in the filter.'} = 'Para agregar la prioridad, selecciónelas en el filtro.';
    $Self->{Translation}->{'Priority change by InBox Kanban'} = 'Cambio de prioridad por InBox Kanban';
    $Self->{Translation}->{'Add permission for the attendant to be able to move cards between rows / columns. Ex: ro, move_into, rw, ...'} = 'Agregue permiso para que el asistente pueda mover tarjetas entre filas / columnas. Ej: ro, move_into, rw, ...';
    $Self->{Translation}->{'Define what dinamic field will appear on the task card'} = 'Define los campos dinámicos que aparecerán en la tarjeta.';

    $Self->{Translation}->{'Kanban Tags'} = 'Etiquetas do kanban';
    $Self->{Translation}->{'Create Kanban tags'} = 'Crear etiquetas kanban';
    $Self->{Translation}->{'Tags'} = 'Etiquetas';
    $Self->{Translation}->{'Tag color'} = 'Color etiqueta';
    $Self->{Translation}->{'The tag already exists.'} = 'La etiqueta ya existe.';

    $Self->{Translation}->{'New Watch'} = 'Nuevo Seguimiento';
    $Self->{Translation}->{'Users'} = 'Acomodadores';

    $Self->{Translation}->{'Error deleting column!'} = '¡Error al eliminar la columna!';
    $Self->{Translation}->{'You must disassociate the column from all boards before removing it.'} = 'Debe disociar la columna de todos los marcos antes de eliminarla.';
    $Self->{Translation}->{'Settings'} = 'Configuración';
    $Self->{Translation}->{'Save'} = 'Ahorrar';
    $Self->{Translation}->{'Delete Kanban'} = 'Eliminar Kanban';
    $Self->{Translation}->{'Solution SLA'} = 'SLA de la solución';


    push @{ $Self->{JavaScriptStrings} // [] }, (
        'Details',
        'New Queue',
        'Change Owner',
        'Change Responsible',
        'Share',
        'Add Tag',
        'New Watch',
        'Error deleting column!',
        'Settings',
        'Save',
        'Do you really want to delete this Kanban? ALL associated data will be LOST!',
        'Delete Kanban',
    );
}

1;