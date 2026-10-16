# --
# Kernel/Language/es_KPI.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::es_KPI;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # Template: AdminKPI
	$Self->{Translation}->{'This is the name to be shown on the screens where the KPI is active.'} = 'Este es el nombre que se mostrará en las pantallas donde KPI está activo.';
	$Self->{Translation}->{'This is the return format when click on chart.'} = 'Este es el formato de retorno al hacer clic en el gráfico.';
	$Self->{Translation}->{'Create and configure KPIs.'} = 'Crear y configurar KPIs.';
	$Self->{Translation}->{'KPI Management'} = 'KPI Management';
	$Self->{Translation}->{'KPI List'} = 'Lista de KPI';
	$Self->{Translation}->{'Add new KPI for object'} = 'Agregar un nuevo KPI para el objeto';
	$Self->{Translation}->{"To add a new KPI, select the search return type from one of the object's list, the object defines the boundary of the search and it can't be changed after the KPI creation."} = 'Para agregar un nuevo KPI, seleccione el tipo de retorno de búsqueda de uno de los objetos de la lista, el objeto define el dominio de búsqueda y no se puede cambiar después de crear el KPI.';
	$Self->{Translation}->{'SLA Range'} = 'Rango de consumo';
	$Self->{Translation}->{'First Response Range'} = 'Rango de consumo de primera respuesta';
	$Self->{Translation}->{'Min/Max values'} = 'Valores mín/máx';
	$Self->{Translation}->{'Rules in use'} = 'Reglas en uso';
	$Self->{Translation}->{'Severity order'} = 'Orden de gravedad';
	$Self->{Translation}->{'Severity'} = 'Gravedad';
	$Self->{Translation}->{'Severity color'} = 'Color de Gravedad';
	$Self->{Translation}->{'Descending'} = 'Descendiente';
	$Self->{Translation}->{'Ascending'} = 'Ascendente';
	$Self->{Translation}->{'Till 25%'} = 'Hasta 25%';
	$Self->{Translation}->{'25% Till 50%'} = '25% Hasta 50%';
	$Self->{Translation}->{'50% Till 75%'} = '50% Hasta 75%';
	$Self->{Translation}->{'75% Till 100%'} = '75% Hasta 100%';
	$Self->{Translation}->{'More than 100%'} = 'Más que 100%';
	$Self->{Translation}->{'Filter for KPI'} = 'Filtrar por KPI';
	$Self->{Translation}->{'Filter for KPI Series'} = 'Filtrar por Conjuntos de KPI';
	$Self->{Translation}->{'You can add a new KPI, select the search return type from one of the object lists, the object sets the search limit, and can not be changed after KPI is created.'} = 'Puede agregar un nuevo KPI, seleccionar el tipo de retorno de búsqueda de una de las listas de objetos, el objeto establece el límite de búsqueda y no se puede cambiar después de crear el KPI.';
	$Self->{Translation}->{'SQL query'} = 'Consulta SQL';
	$Self->{Translation}->{'Copy'} = 'Copia';
	$Self->{Translation}->{'Copy this KPI'} = 'Copie este KPI';
	$Self->{Translation}->{'There was an error creating the KPI'} = 'Se produjo un error al crear KPI';
	$Self->{Translation}->{'Fields per page'} = 'Campos por página';
	$Self->{Translation}->{'There is another KPI with the same name.'} = 'Hay otro KPI con el mismo nombre.';

	# Template: AdminSeries
	$Self->{Translation}->{'Create KPI series.'} = 'Crear conjuntos de KPI.';
    $Self->{Translation}->{'KPI Series'} = 'Conjuntos de KPI';
    $Self->{Translation}->{'Series Management'} = 'Establecer gestión';
    $Self->{Translation}->{'Add KPI Series'} = 'Agregar conjunto';
    $Self->{Translation}->{'Edit KPI Series'} = 'Editar conjunto';
    $Self->{Translation}->{'Series'} = 'Set';
    $Self->{Translation}->{'Add series'} = 'Agregar conjunto';
    $Self->{Translation}->{'Please activate KPISeries first!'} = '¡Primero habilite KPISeries!';
    $Self->{Translation}->{'Chart type'} = 'Tipo de carta';
    $Self->{Translation}->{'Bar'} = 'Bar';
    $Self->{Translation}->{'Funnel'} = 'Embudo';
    $Self->{Translation}->{'Pie'} = 'Pizza';
    $Self->{Translation}->{'Column'} = 'Columna';
    $Self->{Translation}->{'Column 1'} = 'Columna 1';
    $Self->{Translation}->{'Column 2'} = 'Columna 2';
    $Self->{Translation}->{'Column 3'} = 'Columna 3';
    $Self->{Translation}->{'Text format'} = 'Formato de texto';
    $Self->{Translation}->{'Display text format'} = 'Mostrar formato de texto';
    $Self->{Translation}->{'Percentage'} = 'Porcentaje';
    $Self->{Translation}->{'Default serie'} = 'Conjunto estándar';

    # Template: AdminKPISearch
    $Self->{Translation}->{'Ticket close time (current day)'} = 'Hora de cierre del ticket (día actual)';
    $Self->{Translation}->{'Active filter'} = 'Filtro activo.';

    # Template: AdminKPITicket
    $Self->{Translation}->{'KPI - Ticket'} = 'KPI - Llamado';
    $Self->{Translation}->{'Add KPI - Ticket'} = 'Agregar KPI - Llamado';
    $Self->{Translation}->{'Edit KPI - Ticket'} = 'Editar KPI - Llamado';
    $Self->{Translation}->{'KPI Settings'} = 'Configuración de KPI';
    $Self->{Translation}->{'View Settings'} = 'Configuración de visión';
    $Self->{Translation}->{'Personalize'} = 'Personalizar';
    $Self->{Translation}->{'Min/Max SLA range values'} = 'Valores de rango de SLA mín/máx';
    $Self->{Translation}->{'Min/Max First Reply SLA Interval values'} = 'Valores de intervalo de SLA de primera respuesta mín/máx';

    # Template: AdminKPISQLQuery
    $Self->{Translation}->{'KPI - SQL Query'} = 'KPI - Consulta SQL';
    $Self->{Translation}->{'Add KPI - SQL Query'} = 'Agregar  KPI - Consulta SQL';
    $Self->{Translation}->{'Edit KPI - SQL Query'} = 'Editar KPI - Consulta SQL';
    $Self->{Translation}->{'SQL Query'} = 'Consulta SQL';
    $Self->{Translation}->{'Test Query'} = 'Consulta de prueba';
    $Self->{Translation}->{'Only queries are released'} = 'Solo se lanzan consultas';
    $Self->{Translation}->{'Ticket search'} = 'Búsqueda de llamadas';
    $Self->{Translation}->{'Serie type'} = 'Tipo de montaje';

    # SysConfig
    $Self->{Translation}->{'ITIN'} = 'CPF';
    $Self->{Translation}->{'CNPJ'} = 'CNPJ';
    $Self->{Translation}->{'Zip Code'} = 'Código postal';
    $Self->{Translation}->{'Add series option to KPIs'} = 'Agregar opción de conjunto a KPI';
    $Self->{Translation}->{'Set the possible masks to be displayed.'} = 'Defina las posibles máscaras para mostrar.';
    $Self->{Translation}->{'Frontend module registration for the KPIWidgetAJAXHandler.'} = 'Registro de módulo frontend para KPIWidgetAJAXHandler.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the ticket widget overview of the agent interface . "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin. Note: Only Ticket attributes and Dynamic Fields (DynamicField_NameX) are allowed for DefaultColumns.'} = 'Parámetros para el backend del tablero de instrumentos de la vista general del widget de ticket de la interfaz del agente. "Grupo" se utiliza para restringir el acceso al complemento (por ejemplo, Grupo: admin; grupo1; grupo2;). "Predeterminado" determina si el complemento está habilitado de manera predeterminada o si el usuario necesita habilitarlo manualmente. "CacheTTLLocal" es el tiempo de caché en minutos para el complemento. Nota: Solo los atributos de Ticket y los Campos dinámicos (DynamicField_NameX) están permitidos para DefaultColumns.';
    $Self->{Translation}->{'Parameters for the pages (in which the KPIs are shown) of the KPI overview.'} = 'Parámetros para las páginas (en las que se muestran los KPI) de la descripción general de KPI.';

    $Self->{Translation}->{'Indicators'} = 'Indicadores';


    $Self->{Translation}->{'Graphic'} = 'Graph';
    $Self->{Translation}->{'Numeric'} = 'Numérico';
    $Self->{Translation}->{'Indicators'} = 'Indicadores';
    $Self->{Translation}->{'Sets whether the black background button will appear'} = 'Definir si aparecerá el botón de fondo negro';

    # Survey
    $Self->{Translation}->{'Add KPI - Survey'} = 'Agregar KPI - Buscar';
    $Self->{Translation}->{'Edit KPI - Survey'} = 'Editar KPI - Buscar';
    $Self->{Translation}->{'KPI - Survey'} = 'KPI - búsqueda';
    $Self->{Translation}->{'Answers'} = 'Responder';
    $Self->{Translation}->{'Metric'} = 'Métrico';
    $Self->{Translation}->{'Vote time'} = 'Tiempo de votacion';
    $Self->{Translation}->{'Vote time between'} = 'Tiempo de votación entre';
    $Self->{Translation}->{'Create Time between'} = 'Tiempo de creación entre';
    $Self->{Translation}->{'Send Time between'} = 'Tiempo de envío entre';
    $Self->{Translation}->{' and '} = ' y ';
    $Self->{Translation}->{'Percentage'} = 'Porcentaje';

    # Config Item
    $Self->{Translation}->{'KPI - Config Items'} = 'KPI - Elementos de configuración';
    $Self->{Translation}->{'Add KPI - Config Items'} = 'Agregar KPI - Elementos de configuración';
    $Self->{Translation}->{'Edit KPI - Config Items'} = 'Editar KPI - Elementos de configuración';

    # KPI Scheduler 
    $Self->{Translation}->{'KPI Scheduler'} = 'Programador KPI';
    $Self->{Translation}->{'Create KPI Scheduler.'} = 'Cree el programador de KPI.';
    $Self->{Translation}->{'Add scheduler'} = 'Agregar programador';
    $Self->{Translation}->{'KPI scheduler management'} = 'Gestión del programador';
    $Self->{Translation}->{'Create KPI Scheduler.'} = 'Agregar KPI Scheduler';
    $Self->{Translation}->{'Add KPI Scheduler'} = 'Agregar KPI Scheduler';
    $Self->{Translation}->{'Type export'} = 'Tipo de exportación';
    $Self->{Translation}->{'Prefix'} = 'Prefijo';
    $Self->{Translation}->{'Additional emails'} = 'Correos electrónicos adicionales';
    $Self->{Translation}->{'Template of email'} = 'Plantilla de correo electrónico';
    $Self->{Translation}->{'Runtime Configuration'} = 'Configuración en tiempo de ejecución';
    $Self->{Translation}->{'Days of Week'} = 'Dias de la semana';
    $Self->{Translation}->{'Months'} = 'Mes';
    $Self->{Translation}->{'Consider Time Zone'} = 'Considere la zona horaria';
    $Self->{Translation}->{'Add time zone.'} = 'Agregar zona horaria.';
    $Self->{Translation}->{'May'} = 'Mayo';
    $Self->{Translation}->{'Last execution'} = 'Última ejecución';
	$Self->{Translation}->{'Next execution'} = 'Siguiente ejecución';
	$Self->{Translation}->{'Execute now'} = 'Corre ahora';
	$Self->{Translation}->{'Execute'} = 'Ejecutar';
	$Self->{Translation}->{'Manage KPIs'} = 'Administrar KPIs';
	$Self->{Translation}->{'Manage KPI Series'} = 'Administrar Conjuntos de KPIs';
	$Self->{Translation}->{'Export KPIs'} = 'Exportar KPIs';
	$Self->{Translation}->{'Overwrite existing KPIs?'} = '¿Sobrescribir los KPI existentes?';
	$Self->{Translation}->{'Import KPIs configuration(s)'} = 'Importar configuración(es) de KPI';
	$Self->{Translation}->{'Import series configuration(s)'} = 'Importar configuración(es) de conjunto';
	$Self->{Translation}->{'The following KPIs have been added successfully: %s'} = 'Los siguientes KPI se han agregado correctamente: %s';
	$Self->{Translation}->{'The following KPIs series have been added successfully: %s'} = 'Los siguientes conjuntos se han agregado con éxito: %s';
	$Self->{Translation}->{'The following KPIs have been updated successfully: %s'} = 'Los siguientes KPI se han editado correctamente: %s';
	$Self->{Translation}->{'The following KPIs series have been updated successfully: %s'} = 'Los siguientes conjuntos se han editado con éxito: %s';
	$Self->{Translation}->{'KPIs could not be Imported due to a unknown error, please check OTRS logs for more information'} = 'Los KPI no se pudieron importar debido a un error desconocido, consulte los registros de OTRS para obtener más información';
	$Self->{Translation}->{'There where errors adding/updating the following KPIs: %s. Please check the log file for more information.'} = 'Hubo errores al agregar / actualizar los siguientes KPI:% s. Consulte el archivo de registro para obtener más información.';
	$Self->{Translation}->{'Here you can upload a configuration file to import KPIs to your system. The file needs to be in .yml format as exported by the KPI editor module.'} = 'Aquí puede cargar un archivo de configuración para importar KPI a su sistema. El archivo debe estar en formato .yml exportado por el módulo de edición de KPI.';
	$Self->{Translation}->{'Here you can upload a configuration file to import KPIs series to your system. The file needs to be in .yml format as exported by the KPI series editor module.'} = 'Aquí puede cargar un archivo de configuración para importar conjuntos de KPI a su sistema. El archivo debe estar en formato .yml exportado por el módulo de edición del conjunto de KPI.';
	$Self->{Translation}->{'Attention, the statistics can take a long time to run. Avoid creating multiple chrons that will run at the same time.'} = 'Atención, las estadísticas pueden tardar mucho en ejecutarse. Evite crear varias crónicas que se ejecuten al mismo tiempo.';
	$Self->{Translation}->{'Delete this Serie'} = 'Eliminar este conjunto';
	$Self->{Translation}->{'Copy this Serie'} = 'Copiar este conjunto';
	$Self->{Translation}->{'Export this Serie'} = 'Exportar este conjunto';
	$Self->{Translation}->{'Do you really want to delete this serie? ALL associated data will be LOST!'} = '¿Realmente desea eliminar este conjunto? ¡TODOS los datos asociados se PERDERÁN!';
	$Self->{Translation}->{'Do you really want to delete this KPI? ALL associated data will be LOST!'} = '¿Realmente desea eliminar este kpi? ¡TODOS los datos asociados se PERDERÁN!';
	$Self->{Translation}->{'Delete serie'} = 'Eliminar conjunto';
	$Self->{Translation}->{'Export series'} = 'Exportar conjuntos';
	$Self->{Translation}->{'Overwrite existing series?'} = '¿Sobrescribir los conjuntos existentes?';
	$Self->{Translation}->{'Deleting the field and its data. This may take a while...'} = 'Excluyendo el campo y sus datos. Esto puede tardar un rato ...';

    $Self->{Translation}->{'Scale'} = 'Escala';
    $Self->{Translation}->{'Line'} = 'Línea';
    $Self->{Translation}->{'SLA Status'} = 'Estado de SLA';
    $Self->{Translation}->{'SLA Out'} = 'SLA fuera';
    $Self->{Translation}->{'SLA In'} = 'SLA interior';
    $Self->{Translation}->{'Day(s)'} = 'Días(s)';
    $Self->{Translation}->{'Week(s)'} = 'Semana(s)';
    $Self->{Translation}->{'Month(s)'} = 'Mes(es)';
    $Self->{Translation}->{'Quarter(s)'} = 'Trimestre(s)';
    $Self->{Translation}->{'Semester(s)'} = 'Semestre(s)';
    $Self->{Translation}->{'Years(s)'} = 'Año(s)';
    $Self->{Translation}->{'Jan'} = 'Ene';
    $Self->{Translation}->{'Feb'} = 'Feb';
    $Self->{Translation}->{'Mar'} = 'Mar';
    $Self->{Translation}->{'Apr'} = 'Abr';
    $Self->{Translation}->{'May'} = 'Mayo';
    $Self->{Translation}->{'Jun'} = 'Jun';
    $Self->{Translation}->{'Jul'} = 'Jul';
    $Self->{Translation}->{'Aug'} = 'Ago';
    $Self->{Translation}->{'Sep'} = 'Sep';
    $Self->{Translation}->{'Oct'} = 'Oct';
    $Self->{Translation}->{'Nov'} = 'Nov';
    $Self->{Translation}->{'Dec'} = 'Dic';
    $Self->{Translation}->{'Trim'} = 'Trim';
    $Self->{Translation}->{'Sem'} = 'Sem';
    $Self->{Translation}->{'Showing %s tickets out of %s. According to the scale filter'} = 'Mostrando %s de %s llamado. Según el filtro de escala';

    $Self->{Translation}->{'Ticket last article interaction'} = 'Interacción del último artículo del ticket';
    $Self->{Translation}->{'Defines the columns of tables in HTML | If not filled in, it will have no effect'} = 'Define las columnas de tablas en HTML | Si no se completa, no tendrá ningún efecto';

    $Self->{Translation}->{'Data used to export the search result in Excel format.'} = 'Datos utilizados para exportar el resultado de la búsqueda en formato Excel.';
    $Self->{Translation}->{'Add the directory to save the files sent by the KPI Scheduler'} = 'Agregue el directorio para guardar los archivos enviados por el Programador de KPI';
    $Self->{Translation}->{'Generate scheduled tickets.'} = 'Genere tickets programados.';

    # Admin Dashboard
    $Self->{Translation}->{'Edit Dashboard'} = 'Editar Panel';
    $Self->{Translation}->{'Add Dashboard'} = 'Agregar Panel';
    $Self->{Translation}->{'Create Dashboard.'} = 'Crear Panel.';
    $Self->{Translation}->{'Access dashboard'} = 'Panel de acceso.';
    $Self->{Translation}->{'Agent Interface'} = 'Interfaz de Agente';
    $Self->{Translation}->{'Save and Continue'} = 'Guardar y Continuar';
    $Self->{Translation}->{'Customer Interface'} = 'Interfaz de Cliente';
    $Self->{Translation}->{'Dashboard Management'} = 'Gestión del Panel';
    $Self->{Translation}->{'Filter for Dashboard'} = 'Filtrar por Panel';
    $Self->{Translation}->{'Dashboard not found!'} = 'Panel de control no encontrado!';
    $Self->{Translation}->{'Agent and Customer Interface'} = 'Interfaz de Agente/Cliente';
    $Self->{Translation}->{'A dashboard with this name already exists!'} = '¡Ya existe un tablero con este nombre!';
    $Self->{Translation}->{'The groups defined for the dashboard will override the groups defined in the KPI'} = 'Los grupos definidos para el tablero anularán los grupos definidos en el KPI';

    # AdminKPIDashboardEdit
    $Self->{Translation}->{'Save'} = 'Ahorrar';
    $Self->{Translation}->{'Contents'} = 'Contenido';
    $Self->{Translation}->{'Add Card'} = 'Agregar Tarjeta';
    $Self->{Translation}->{'Save Dashboard'} = 'Guardar Panel';
    $Self->{Translation}->{'Card background'} = 'Color de la Tarjeta';
    $Self->{Translation}->{'Dashboard background'} = 'Color del Tablero';
    $Self->{Translation}->{'Card Settings'} = 'Configuración de la Tarjeta';
    $Self->{Translation}->{'Dashboard Settings'} = 'Configuración del Panel';
    $Self->{Translation}->{'Dashboard saved successfully!'} = '¡Panel guardado con éxito!';
    $Self->{Translation}->{'Do you really want to delete this card?'} = '¿Realmente quieres eliminar esta tarjeta?';

    # AdminKPIDashboardEdit
    $Self->{Translation}->{'Dashboard List'} = 'Lista de Tableros';

    # AgentKPIDashboard
    $Self->{Translation}->{'Without permission! Contact the administrator.'} = '¡Sin permiso! Póngase en contacto con el administrador.';
    
    # AgentDashboard
    $Self->{Translation}->{'Overview'} = 'Visión General';

    $Self->{Translation}->{'Customer IDs multiselect'} = 'CustomerID Multiclientes';

    
    push @{ $Self->{JavaScriptStrings} // [] }, (
        'Save',
        'Overview',
        'Contents',
        'Delete serie',
        'Card Settings',
        'Card background',
        'Dashboard Settings',
        'Dashboard background',
        'Dashboard saved successfully!',
        'Do you really want to delete this card?',
        'Deleting the field and its data. This may take a while...',
        'Do you really want to delete this KPI? ALL associated data will be LOST!',
        'Do you really want to delete this serie? ALL associated data will be LOST!',
    );    


    return 1;
}

1;
