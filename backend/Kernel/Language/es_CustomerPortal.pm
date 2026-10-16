# --
# Kernel/Language/es_CustomerPortal.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * nfreitas@serviceup.com.br
# * jsantos@serviceup.com.br
# * dsilva@serviceup.com.br
# * jguedes@serviceup.com.br
# --

package Kernel::Language::es_CustomerPortal;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'General contract data shown in the additional information on the contract cards on the portal. Possible configurations: 0 = Disabled, 1 = Available.'} = 'Los datos generales del contrato se muestran en la información adicional de las fichas de contrato del portal. Configuraciones posibles: 0 = Deshabilitado, 1 = Disponible.';
    $Self->{Translation}->{'General contract data shown in the additional information for contract cards on the portal. Possible configurations: 0 = Disabled, 1 = Available.'} = 'Los datos generales del contrato se muestran en la información adicional para tarjetas de contrato en el portal. Configuraciones posibles: 0 = Deshabilitado, 1 = Disponible.';
    $Self->{Translation}->{'General contract data shown in the card views on the portal. Possible configurations: 0 = Disabled, 1 = Available.'} = 'Los datos generales del contrato se muestran en las vistas de tarjeta en el portal. Configuraciones posibles: 0 = Deshabilitado, 1 = Disponible.';
    $Self->{Translation}->{'Dynamic fields that will be displayed on contract cards.'} = 'Campos dinámicos que se mostrarán en tarjetas de contrato.';
    $Self->{Translation}->{'Macro Management'} = 'Nombre de la Macro';
    $Self->{Translation}->{'Edit Macro'} = 'Editar Macro';
    $Self->{Translation}->{'Add Macro'} = 'Agregar Macro';
    $Self->{Translation}->{'Filter for Macros'} = 'Filtrar por Macros';
    $Self->{Translation}->{'Macro Settings'} = 'Configuración de Macros';
    $Self->{Translation}->{'Macro name'} = 'Nombre de la Macro';
    $Self->{Translation}->{'This event module runs macros configured for the ticket.'} = 'Este módulo de eventos ejecuta macros configuradas para el ticket.';
    $Self->{Translation}->{'"%s" macro executed.'} = 'Macro "%s" ejecutada.';
    $Self->{Translation}->{'By activating this option, the opening of a ticket will be based on the Contract and not on the Service. (InBox ContractManagement module must be installed)'} = 'Al activar esta opción, la apertura de un ticket se basará en el Contrato y no en el Servicio. (Se debe instalar el módulo InBox ContractManagement)';
    $Self->{Translation}->{"Ops... You don't have any associated contracts."} = 'Vaya... No tiene ningún contrato asociado.';

    $Self->{Translation}->{'This service is not available to the logged in user.'} = 'Este servicio no está disponible para el usuario registrado.';
    $Self->{Translation}->{'You are not allowed to access this service. Please contact the responsible team for more information.'} = 'No se le permite acceder a este servicio. Póngase en contacto con el equipo responsable para obtener más información.';
    $Self->{Translation}->{'This contract is not available to the logged in user.'} = 'Este contrato no está disponible para el usuario registrado.';
    $Self->{Translation}->{'This contract is not associated with the service informed in the URL. Please contact the responsible team for more information.'} = 'Este contrato no está asociado al servicio informado en la URL. Póngase en contacto con el equipo responsable para obtener más información.';
    $Self->{Translation}->{'This service is not available for that contract.'} = 'Este servicio no está disponible para ese contrato.';
    $Self->{Translation}->{'You are not allowed to access this Contract-Service association. Please contact the responsible team for more information.'} = 'No se le permite acceder a esta asociación Contrato-Servicio. Póngase en contacto con el equipo responsable para obtener más información.';
    $Self->{Translation}->{'Contract not selected.'} = 'Contrato no seleccionado.';
    $Self->{Translation}->{'Call opening without a contract is not available. Please contact the responsible team for more information.'} = 'La apertura de llamadas sin contrato no está disponible. Póngase en contacto con el equipo responsable para obtener más información.';

    $Self->{Translation}->{'Enter the Activity ID to hide the answer button from the ticket.'} = 'Ingrese el ID de actividad para ocultar el botón de respuesta del ticket.';
    $Self->{Translation}->{'Service'} = 'Servicio';
    $Self->{Translation}->{'Enter the activity IDs so that the activity button is hidden from view in the ticket. Key: process ID. Value: Activity ID.'} = 'Ingrese los ID de actividad para que el botón de actividad esté oculto a la vista en el ticket. Clave: ID de proceso. Valor: ID de actividad.';
    $Self->{Translation}->{'Statistics'} = 'Estadísticas';
    $Self->{Translation}->{'Possible state mapping for filter on MyTicket screen.'} = 'Posible asignación de estado para el filtro en la pantalla MyTicket y CompanyTicket.';
    $Self->{Translation}->{'Possible state display name mapping for filter on MyTicket screen.'} = 'Posible asignación del nombre para mostrar del estado para filtrar en la pantalla MyTicket.';
    $Self->{Translation}->{'Tickets'} = 'Llamado';
    $Self->{Translation}->{'Text'} = 'Texto';
    $Self->{Translation}->{'New Ticket Process'} = 'Nuevo proceso de llamada';
    $Self->{Translation}->{'Enable new tickets process'} = 'Activar nueva llamada mediante proceso';
    $Self->{Translation}->{'Next Steps'} = 'Próximos pasos';
    $Self->{Translation}->{'Customize navbar texts'} = 'Personalizar textos de la barra de navegación';
    $Self->{Translation}->{'Define the size of service card'} = 'Establecer el tamaño de la tarjeta de servicio';
    $Self->{Translation}->{'Subject'} = 'Asunto';
    $Self->{Translation}->{'Reply'} = 'Responder';
    $Self->{Translation}->{'Square'} = 'Square';
    $Self->{Translation}->{'Define the format of service card'} = 'Establecer formato de tarjeta de servicio';
    $Self->{Translation}->{'Rectangle'} = 'Rectángulo';
    $Self->{Translation}->{'Send'} = 'Enviar';
    $Self->{Translation}->{'Subtitle'} = 'Subtítulo';
    $Self->{Translation}->{'Informations'} = 'Informaciones';
    $Self->{Translation}->{'Ticket priority'} = 'Prioridad de llamada';
    $Self->{Translation}->{'Created a new ticket!'} = 'Se ha creado una nueva llamada!';
    $Self->{Translation}->{'Apply CustomServiceForm in CustomerPortal.'} = 'Aplicar CustomServiceForm en CustomerPortal ';
    $Self->{Translation}->{'With Number:'} = 'Tu numero es:';
    $Self->{Translation}->{'Response added via CustomerPortal interface to ticket'} = 'Respuesta agregada a través de la interfaz CustomerPortal a la invocación';
    $Self->{Translation}->{'Can\'t reopen ticket, not possible in this queue!'} = '¡No se puede volver a abrir el ticket en esta cola!';
    $Self->{Translation}->{'Create a new ticket!'} = '¡Crea una nueva vocación!';
    $Self->{Translation}->{'Reply from'} = 'Respuesta de';
    $Self->{Translation}->{'File Manager'} = 'Administrador de archivos';
    $Self->{Translation}->{'Last Modified'} = 'última modificación';
    $Self->{Translation}->{'Company Tickets'} = 'Llamadas de empresa';
    $Self->{Translation}->{'My Tickets'} = 'Mis llamamientos';
    $Self->{Translation}->{'Enter an answer to submit'} = 'Ingrese una respuesta para enviar';
    $Self->{Translation}->{'News'} = 'Noticias';
    $Self->{Translation}->{'New Password'} = 'Nueva contraseña';
    $Self->{Translation}->{'Verify Password'} = 'Verificar contraseña';
    $Self->{Translation}->{'Interface Language'} = 'Idioma de la interfaz';
    $Self->{Translation}->{'Change Password'} = 'Cambiar contraseña';
    $Self->{Translation}->{'Password'} = 'Contraseña';
    $Self->{Translation}->{'Set the transition effect of service cards'} = 'Establecer el efecto de transición de las tarjetas de servicio';
    $Self->{Translation}->{'Select the main interface language.'} = 'Seleccione el idioma principal de la interfaz.';
    $Self->{Translation}->{'Current  Password'} = 'Contraseña actual';
    $Self->{Translation}->{'Enable service name as subject in ticket opening screen'} = 'Habilite el nombre del servicio como asunto en la pantalla de apertura del ticket';
    $Self->{Translation}->{'Set a new password by filling in your current password and a new one.'} = 'Establezca una nueva contraseña completando su contraseña actual y una nueva..';
    $Self->{Translation}->{'Preferences'} = 'Preferencias';
    $Self->{Translation}->{'Timezone'} = 'Huso horario';
    $Self->{Translation}->{'Select your personal time zone. All times will be displayed according to this time zone.'} = 'Seleccione su zona horaria personal. Todos los horarios se mostrarán de acuerdo con esta zona horaria.';
    $Self->{Translation}->{'Service Favorite'} = 'Servicios favoritos';
    $Self->{Translation}->{'IconColor'} = 'Color del icono';
    $Self->{Translation}->{'ServiceColor'} = 'Servicio de color';
    $Self->{Translation}->{'Icon Name'} = 'Nombre del icono';
    $Self->{Translation}->{'CustomerPortal ACL to add service parameters to call via attendant opening'} = 'CustomerPortal ACL para agregar parámetros de servicio para llamar a través de la apertura del operador';
    $Self->{Translation}->{'Enable ticket opening service parameters via attendant interface'} = 'Habilite los parámetros del servicio de apertura de llamadas a través de la interfaz del operador';
    $Self->{Translation}->{'Add News to the interface of the client. Exemple: NameToShow -> News text'} = 'Agregue noticias a la interfaz del cliente. Ejemplo: Título -> Cuerpo';
    $Self->{Translation}->{'FrontendModuleRegistration for CustomerPortal module.'} = 'FrontendModuleRegistration for InBox CustomerPortal Module ';
    $Self->{Translation}->{'Set preferences to MyTickets Dashboard.'} = 'Establecer preferencias para el panel "Mis llamadas"';
    $Self->{Translation}->{'Enables hour consumption on statistics screen.'} = 'Mostrar horas de consumo del contrato en "Estadísticas"';
    $Self->{Translation}->{'Loader module registration for the agent interface.'} = 'Cargador para registro de módulos';
    $Self->{Translation}->{'Set the queue to new tickets of CustomerPortal interface.'} = 'Agregue el nombre de la cola para crear el ticket de interfaz CustomerPortal.';
    $Self->{Translation}->{'Set the SLA ID to new tickets of CustomerPortal interface.'} = 'Agregue la ID de SLA para crear el ticket de interfaz CustomerPortal.';
    $Self->{Translation}->{'Set the CustomerLogo to CustomerPortal interface. Example: CustomerID -> path/to/logo.img'} = 'Agregue el logotipo del cliente a la interfaz CustomerPortal. Ejemplo: CustomerId -> ruta / a / logo.img';
    $Self->{Translation}->{'Parameters of the example service attribute Color.'} = 'Parámetros para el color de la tarjeta de servicio en la interfaz del puerto del cliente';
    $Self->{Translation}->{'Parameters of the service attribute Description.'} = 'Parámetros para la descripción de la tarjeta de servicio en la interfaz de CustomerPortal';
    $Self->{Translation}->{'Parameters of the service attribute icon color.'} = 'Parâmetros para a cor do ícone do card de serviço na interface CustomerPortal';
    $Self->{Translation}->{'Parameters of the example service attribute Icon.'} = 'Parámetros para el icono de la tarjeta de servicio en la interfaz CustomerPortal ';
    $Self->{Translation}->{'Set the CustomerLogo default to CustomerPortal interface. Example: path/to/logo.img'} = 'Agregue el logotipo predeterminado del cliente a la interfaz CustomerPortal. Ejemplo: ruta / a / logo.img';
    $Self->{Translation}->{"Add colors default to the user's navbar. Because it is a gradient, you can add 2 colors. If you want one, repeat it in both fields."} = 'Agregue colores predeterminados a la barra de navegación del usuario del cliente. Como es un gradiente, es posible agregar 2 colores, separados por; Si solo quieres uno, repite con;';
    $Self->{Translation}->{"Add colors to the user's navbar. Because it is a gradient, you can add 2 colors. If you want one, repeat it in both fields."} = 'Agregue colores a la barra de navegación del usuario del cliente. Como es un gradiente, es posible agregar 2 colores, separados por; Si solo quieres uno, repite con;';
    $Self->{Translation}->{'Add Customer NavBar Font Colors'} = 'Agregue colores de fuente NavBar del lado del cliente en la interfaz CustomerPortal';
    $Self->{Translation}->{'Define the SLA to ticket'} = 'Establece el SLA para el servicio.';
    $Self->{Translation}->{'Define the type to ticket'} = 'Establece el tipo para el servicio.';
    $Self->{Translation}->{'Define the queue to ticket'} = 'Define la cola para el servicio.';
    $Self->{Translation}->{'TicketType'} = 'Tipo';
    $Self->{Translation}->{'TicketSLA'} = 'SLA';
    $Self->{Translation}->{'TicketQueue'} = 'Cola';
    $Self->{Translation}->{'Outhers'} = 'Otros';
    $Self->{Translation}->{'Back'} = 'Volver';
    $Self->{Translation}->{'Home'} = 'Inicio';
    $Self->{Translation}->{'Search'} = 'Buscar';
    $Self->{Translation}->{'Stats'} = 'Estadísticas';
    $Self->{Translation}->{'New Ticket'} = 'Nueva vocación';
    $Self->{Translation}->{'My Tickets - Tickets open by: '} = 'Mis llamadas - Llamadas abiertas por:';
    $Self->{Translation}->{'My Tickets'} = 'Mis llamadas';
    $Self->{Translation}->{'Select your personal time zone. All times will be displayed relative to this time zone.'} = 'Seleccione su zona horaria personal. Todos los horarios se mostrarán para esta zona horaria.';
    $Self->{Translation}->{'Main services'} = 'Servicios principales';
    $Self->{Translation}->{'Set the subaction default to CustomerPortal interface. Example: Stats'} = 'Adicionar a Subaction após login do usuário. Exemplo: Stats';
    $Self->{Translation}->{'Add colors default and icon to service card.'} = 'Agregue colores e íconos predeterminados a la tarjeta de servicio.';
    $Self->{Translation}->{'Add links to the interface of the client. Exemple: NameToShow -> http://link.com.br'} = 'Agregue enlaces en la interfaz del cliente. Ejemplo: Nombre para mostrar -> http://link.com.br ';
    $Self->{Translation}->{'Ticket Priority'} = 'Prioridad';
    $Self->{Translation}->{'Form Description'} = 'Descripción del formulario';
    $Self->{Translation}->{'Define the priority to ticket'} = 'Define la prioridad para el servicio.';
    $Self->{Translation}->{'Add description to card or not'} = 'Añadir descripción a la tarjeta o no';
    $Self->{Translation}->{'Without description'} = 'No hay una descripción';
    $Self->{Translation}->{'With description'} = 'Con descripción';
    $Self->{Translation}->{'No record found'} = 'No se encontraron registros';
    $Self->{Translation}->{'Showing 0 to 0 of 0 ticket'} = 'Mostrando entradas de 0 a 0 de 0';
    $Self->{Translation}->{'Loading...'} = 'Cargando...';
    $Self->{Translation}->{'Processing...'} = 'Procesamiento...';
    $Self->{Translation}->{'Search records'} = 'Buscar registros';
    $Self->{Translation}->{'Next'} = 'Siguiente';
    $Self->{Translation}->{'Previous'} = 'Anterior';
    $Self->{Translation}->{'Search records'} = 'Buscar registros';
    $Self->{Translation}->{'First'} = 'Primero';
    $Self->{Translation}->{'Last'} = 'Pasado';
    $Self->{Translation}->{'Showing'} = 'Mostrando';
    $Self->{Translation}->{'tickets'} = 'llamado';
    $Self->{Translation}->{'Showing from'} = 'Mostrando desde';
    $Self->{Translation}->{'up until'} = 'hasta';
    $Self->{Translation}->{'in'} = 'de';
    $Self->{Translation}->{'Filtered from'} = 'Filtrado desde';
    $Self->{Translation}->{'Showing results for'} = 'Mostrando resultados para';
    $Self->{Translation}->{'Search full text'} = 'Buscar texto completo';
    $Self->{Translation}->{'FAQ(s)'} = 'FAQ(s)';
    $Self->{Translation}->{'Set as favorite'} = 'Establecer como favorito';
    $Self->{Translation}->{'View FAQ(s)'} = 'Ver FAQ(s)';
    $Self->{Translation}->{'records'} = 'registros';
    $Self->{Translation}->{'Name/Title'} = 'Nombre/Titulo';
    $Self->{Translation}->{'Type of object'} = 'Tipo do objeto';
    $Self->{Translation}->{'Open ticket'} = 'Abrir llamado';
    $Self->{Translation}->{'Showing 0 to 0 of 0 records'} = 'Mostrando de 0 a 0 registros';
    $Self->{Translation}->{'Customer Portal Cards'} = 'Tarjetas del  Customer Portal';
    $Self->{Translation}->{'Create and edit Customer Portal Cards'} = 'Crear y editar tarjetas del portal del cliente';
    $Self->{Translation}->{'Cards Management of Customer Portal'} = 'Gestión de la tarjeta del portal del cliente';
    $Self->{Translation}->{'Add card'} = 'Agregar tarjeta';
    $Self->{Translation}->{'Mark as read'} = 'Marcar como leído';
    $Self->{Translation}->{'Mark as unread'} = 'Marcar como no leído';
    $Self->{Translation}->{'Enable customized cards by the attendant'} = 'Habilitar tarjetas personalizadas por el asistente';
    $Self->{Translation}->{'Enable DashBoard graphics. Being 1 - Enabled and 0 - Disabled'} = 'Habilite los gráficos del tablero de instrumentos. Siendo 1: habilitado y 0: deshabilitado';
    $Self->{Translation}->{'Do you really want to delete this message?'} = '¿Realmente quieres eliminar este mensaje?';
    $Self->{Translation}->{'You have already gone through all notifications'} = 'Ya has pasado por todas las notificaciones.';
    $Self->{Translation}->{'Define the FAQ to service'} = 'Define las preguntas frecuentes para el servicio';
    $Self->{Translation}->{'Define the Owner to ticket'} = 'Define el propietario del servicio';
    $Self->{Translation}->{'Define the Responsible to ticket'} = 'Define el responsable del servicio.';
    $Self->{Translation}->{'FAQ solved my problem!'} = '¡Las preguntas frecuentes resolvieron mi problema!';
    $Self->{Translation}->{"The FAQ did not solve my problem! I want to open a ticket"} = '¡Las preguntas frecuentes no resolvieron mi problema! Quiero abrir una llamada';
    $Self->{Translation}->{"Apply ServiceTemplate in CustomerPortal."} = 'Aplicar ServiceTemplate a CustomerPortal';
    $Self->{Translation}->{"Apply ShowHide in CustomerPortal."} = 'Aplicar ShowHide a CustomerPortal';
    $Self->{Translation}->{"Open link in a new tab"} = 'Abrir enlace en una pestaña nueva';
    $Self->{Translation}->{"Set the notification table size"} = 'Establecer el tamaño de la visualización de notificaciones';
    $Self->{Translation}->{"Set preferences to CompanyTickets Dashboard."} = 'Establezca las preferencias para el panel CompanyTickets.';
    $Self->{Translation}->{'Mapping of ticket types to display SLA on the client interface.'}  = 'Mapeo de tipos de tickets para mostrar SLA en la interfaz del cliente.';
    $Self->{Translation}->{'Service Timeout'} = 'Tiempo de espera de servicio';
    $Self->{Translation}->{'Service Time Spent'} = 'Tiempo de servicio realizado';
    $Self->{Translation}->{'Solution Timeout'} = 'Tiempo de espera de solución';
    $Self->{Translation}->{'Solution Time Spent'} = 'Tiempo de solución realizado';
    $Self->{Translation}->{'Enter the customer id for viewing the SLA on the customer interface'} = 'Ingrese la identificación del cliente para ver el SLA en la interfaz del cliente';
    $Self->{Translation}->{'Apply CustomerTicketZoomSLA in CustomerPortal.'} = 'Aplicar CustomerTicketZoomSLA a CustomerPortal';
    $Self->{Translation}->{'View the solution time for all customers in CustomerPortal.'} = 'Vea el tiempo de solución para todos los clientes en CustomerPortal.';
    $Self->{Translation}->{'View the first response time for all customers in CustomerPortal.'} = 'Vea el primer tiempo de respuesta de todos los clientes en CustomerPortal.';
    $Self->{Translation}->{'Pick an Icon'} = 'Elige un icono';
    $Self->{Translation}->{'Choose an icon'} = 'Elige un icono';
    $Self->{Translation}->{'To define'} = 'Definir';
    $Self->{Translation}->{'Consumption of Hours'} = 'Horas de consumo';
    $Self->{Translation}->{'hour(s)'} = 'hora(s)';
    $Self->{Translation}->{'tickets and registered(s)'} = 'llamado y registrado(s)';
    $Self->{Translation}->{'In the current month'} = 'En el mes actual,';
    $Self->{Translation}->{'Apply ConsumptionOfHours in CustomerPortal.'} = 'Permite el consumo de horas en CustomerPortal';
    $Self->{Translation}->{'Shows the number of hours in the months'} = 'Muestra la cantidad de horas dedicadas en el mes actual ';
    $Self->{Translation}->{'Shows the number of hours used in the last months.'} = 'Muestra la cantidad de horas dedicadas en los últimos meses.';
    $Self->{Translation}->{'Vision of the last months'} = 'Vista de los últimos meses.';
    $Self->{Translation}->{'Month/Year'} = 'Mes/Año';
    $Self->{Translation}->{'Hours Used'} = 'Horas Utilizadas';
    $Self->{Translation}->{'Open Tickets'} = 'Llamadas Abiertas';
    $Self->{Translation}->{'Closed Tickets'} = 'Llamadas cerradas';
    $Self->{Translation}->{'Jan'} = 'Ene';
    $Self->{Translation}->{'Feb'} = 'Feb';
    $Self->{Translation}->{'Mar'} = 'Mar';
    $Self->{Translation}->{'Apr'} = 'Abr';
    $Self->{Translation}->{'May'} = 'May';
    $Self->{Translation}->{'Jun'} = 'Jun';
    $Self->{Translation}->{'Jul'} = 'Jul';
    $Self->{Translation}->{'Aug'} = 'Ago';
    $Self->{Translation}->{'Sep'} = 'Sep';
    $Self->{Translation}->{'Oct'} = 'Oct';
    $Self->{Translation}->{'Nov'} = 'Nov';
    $Self->{Translation}->{'Dec'} = 'Dic';
    $Self->{Translation}->{'Hours spent per month'} = 'Horas dedicadas por mes';

    $Self->{Translation}->{'Enable archived tickets in CustomerPortal.'} = 'Habilitar tickets archivados en CustomerPortal';
    $Self->{Translation}->{'Queues that should not be filtered in CustomerPortal'} = 'Colas que no deben filtrarse en el CustomerPortal';
    $Self->{Translation}->{'Enable ticket search parameter by date on CustomerPortal'} = 'Habilitar el parámetro de búsqueda de entradas por fecha en el CustomerPortal';
    $Self->{Translation}->{'Default number of days to search'} = 'Número predeterminado de días para buscar';
    $Self->{Translation}->{'Numbers of days to search by customer. Ex: CustomerName -> 30'} = 'Número de días de búsquedas, definido por cliente. Ejemplo: CustomerName -> 30';

    $Self->{Translation}->{'Set the default values ​​for the buttons on the Service screen with FAQ'} = 'Establezca los valores predeterminados para los botones en la pantalla de servicio con Preguntas frecuentes';
    $Self->{Translation}->{'My Data'} = 'Mis datos';
    $Self->{Translation}->{'Company Data'} = 'Datos de la empresa';
    $Self->{Translation}->{'Data updated successfully!'} = '¡Datos actualizados con éxito!';
    $Self->{Translation}->{'Error while updating data!'} = '¡Error al actualizar los datos!';
    $Self->{Translation}->{'Download my personal data'} = 'Descargar mis datos personales';
    $Self->{Translation}->{'Information cannot be changed through this panel. Contact your administrator for more information.'} = 'La información no se puede cambiar a través de este panel. Póngase en contacto con el administrador para obtener más información. ';
    $Self->{Translation}->{'Edit Layout'} = 'Editar diseño';
    $Self->{Translation}->{'Logo'} = 'Logo';
    $Self->{Translation}->{'Define the image that will appear at the beginning of the sidebar.'} = 'Defina la imagen que aparecerá al principio de la barra lateral.';
    $Self->{Translation}->{'Image path'} = 'Ruta de la imagen';
    $Self->{Translation}->{'Preview in page'} = 'Vista previa en vista previa';
    $Self->{Translation}->{'Navigation bar color'} = 'Color de la barra de navegación';
    $Self->{Translation}->{'Background colors of the Customer Portal side menu.'} = 'Colores de fondo del menú lateral del Portal del cliente.';
    $Self->{Translation}->{'It is possible to define a gradient of two colors.'} = 'Es posible definir un degradado de dos colores.';
    $Self->{Translation}->{'Top Color'} = 'Color superior';
    $Self->{Translation}->{'Bottom Color'} = 'Color inferior';
    $Self->{Translation}->{'Menu colors'} = 'Colores del menú';
    $Self->{Translation}->{'Side menu font colors.'} = 'Colores de fuente del menú lateral.';
    $Self->{Translation}->{'Main menu'} = 'Menú principal';
    $Self->{Translation}->{'Submenu color'} = 'Color del submenú';
    $Self->{Translation}->{'Username color'} = 'Color del nombre de usuario';
    $Self->{Translation}->{'User Exemple'} = 'Nombre de usuario';
    $Self->{Translation}->{'New ticket'} = 'Nueva llamada';
    $Self->{Translation}->{'Save Change'} = 'Guardar ediciones';
    $Self->{Translation}->{'Apply show New Ticket in sidebar in CustomerPortal.'} = 'Mostrar nueva llamada en la barra lateral de CustomerPortal.';
    $Self->{Translation}->{'This page is currently unavailable.'} = 'Esta página no está disponible.';
    $Self->{Translation}->{'Please contact the responsible team for more information.'} = 'Póngase en contacto con el equipo responsable para obtener más información.';

    $Self->{Translation}->{'Apply show FAQ in sidebar in CustomerPortal.'} = 'Aplicar show FAQ en la barra lateral de CustomerPortal.';
    $Self->{Translation}->{'Define my client user data report layout.'} = 'Definir el diseño del informe de datos de usuario de mi cliente.';
    $Self->{Translation}->{'Fields to be displayed on the My Data tab. 0 - Hide, 1 - Display and allow changes, 2 - Display only.'} = 'Campos que se mostrarán en la pestaña Mis datos. 0 - Ocultar, 1 - Mostrar y permitir cambios, 2 - Solo mostrar. ';
    $Self->{Translation}->{'Registration of cards to be displayed on the My Data page.'} = 'Registro de tarjetas que se mostrarán en la página Mis datos';
    $Self->{Translation}->{'Edit the Customer Portal layout'} = 'Editar el diseño del portal de clientes';
    $Self->{Translation}->{'Event responsible for setting the service values in the ticket. Set 1 to set the value or 0 to not set.'} = 'Evento responsable de configurar los valores del servicio en el ticket. Configure 1 para configurar el valor o 0 para no configurar.';
   
    $Self->{Translation}->{'To view'} = 'Para ver';
    $Self->{Translation}->{'Add the initial filter to the My Tickets table'} = 'Agregue el filtro inicial de la tabla Mis llamadas';
    $Self->{Translation}->{'Add the initial filter to the Company Tickets table'} = 'Agregue el filtro inicial de la tabla Llamadas de la empresa';


    $Self->{Translation}->{'Set the Background Image default to CustomerPortal interface. Example: path/to/logo.img'} = 'Establezca la imagen de fondo predeterminada en la interfaz CustomerPortal. Ejemplo: caminho/para/logo.img';
    $Self->{Translation}->{'Background image'} = 'Imagen de fondo';
    $Self->{Translation}->{'Choose the field name and value present in the customer user registration so that the CompanyTickets menu can be displayed'} = 'Elija el nombre del campo y el valor presente en el registro de usuario del cliente para que se pueda mostrar el menú CompanyTickets';
    $Self->{Translation}->{'No permissions to view screen.'} = 'No hay permisos para ver la pantalla.';
    $Self->{Translation}->{'No permissions to view screen. Please contact the responsible team for more information.'} = 'No hay permisos para ver la pantalla. Póngase en contacto con el equipo responsable para obtener más información.';

    $Self->{Translation}->{'Time Units'} = 'Tiempo contable';
    $Self->{Translation}->{'Order field'} = 'Pedido';
    $Self->{Translation}->{'Customize the title of CustomerPortal actions'} = 'Personalizar el título de las acciones de CustomerPortal';
    $Self->{Translation}->{'Define the service icon.'} = 'Define el icono de servicio.';
    $Self->{Translation}->{'Add dynamic field:'} = 'Agregar campo dinámico:';
    $Self->{Translation}->{'Define the service color.'} = 'Establece el color del servicio';
    $Self->{Translation}->{'Define the service Icon Color.'} = 'Establece el color del icono de servicio.';
    $Self->{Translation}->{'Define the service order. Enter an integer'} = 'Orden de exhibición del servicio. Ingrese un número entero.';
    $Self->{Translation}->{'Enables display of time accounted for in ticket information'} = 'Permite la visualización del tiempo contabilizado en la información del ticket.';
    $Self->{Translation}->{'Format of the article time display.'} = 'Formato de visualización de la hora del artículo.';
    $Self->{Translation}->{'Creation date'} = 'Fecha de creación';
    $Self->{Translation}->{'Minimize'} = 'Minimizar';
    $Self->{Translation}->{'Last Tickets'} = 'Últimas Llamadas';
    $Self->{Translation}->{'Dynamic field value %s is invalid!'} = '¡El valor del campo dinámico %s no es válido!';
    $Self->{Translation}->{'Dynamic field %s is required!'} = '¡El campo dinámico %s es obligatorio!';
    $Self->{Translation}->{'Reply and Update'} = 'Responder y actualizar';
    $Self->{Translation}->{'Update ticket data'} = 'Actualizar los datos del ticket';
    $Self->{Translation}->{'Time recorded'} = 'Tiempo registrado';
    $Self->{Translation}->{'Hides the next state button according to the service. Enter the service ID.'} = 'Oculta el siguiente botón de estado según el servicio. Ingrese la identificación del servicio.';
    $Self->{Translation}->{'Hides the next state button according to the state. Enter the state name.'} = 'Oculta el siguiente botón de estado según el estado. Introduzca el nombre del estado.';
    $Self->{Translation}->{'Consumption of Contract'} = 'Consumo de contrato';
    $Self->{Translation}->{'Type of Consumption'} = 'Tipo de consumo';
    $Self->{Translation}->{'Contracted Hours'} = 'Horas contratadas';
    $Self->{Translation}->{'Hours Consumed'} = 'Horas consumidas';
    $Self->{Translation}->{'Percentage of Consumption'} = 'Porcentaje de consumo';
    $Self->{Translation}->{'Consumption of Hours by Contract'} = 'Consumo de Horas por Contrato';
    $Self->{Translation}->{'You do not have permission to view this page.'} = 'No tienes permiso para ver esta página.';
    $Self->{Translation}->{'Current month'} = 'Mes actual';
    $Self->{Translation}->{'Accounted Time'} = 'Tiempo grabado';
    $Self->{Translation}->{'Appointment Date'} = 'Fecha de Registro';
    $Self->{Translation}->{'Enable the option to download a report with the record of hours of tickets with contract.'} = 'Habilita la opción de descargar un informe con el registro de horas de tickets con contrato.';
    $Self->{Translation}->{'View the last 5 tickets'} = 'Ver las últimas 5 llamadas';
    $Self->{Translation}->{'View the last 10 tickets'} = 'Ver las últimas 10 llamadas';
    $Self->{Translation}->{'Do not show'} = 'No mostrar';
    $Self->{Translation}->{'System'} = 'Service Desk';
    $Self->{Translation}->{'Defines the number of days that will be considered when searching for unanswered surveys. 0 will bring up all unanswered surveys.'} = 'Define la cantidad de días que se considerarán al buscar encuestas sin respuesta. 0 mostrará todas las encuestas sin respuesta.';
    $Self->{Translation}->{'Survey Age'} = 'Edad de la encuesta';
    $Self->{Translation}->{'Unanswered Surveys'} = 'Encuestas sin respuesta';
    $Self->{Translation}->{'Hides the consumed hours option if the customer has a contract.'} = 'Oculta la opción de horas consumidas si el cliente tiene un contrato.';
    $Self->{Translation}->{'Defines the name of the label that will be displayed on top of the text area when opening a ticket.'} = 'Define el nombre de la etiqueta que se mostrará en la parte superior del área de texto al abrir una llamada.';
    $Self->{Translation}->{'Displays the ImpactOperation dynamic field on the ticket opening screen.'} = 'Muestra el campo dinámico ImpactOperation en la pantalla de apertura del ticket.';
    $Self->{Translation}->{'Display last user tickets.'} = 'Mostrar las últimas llamadas de usuario.';
    $Self->{Translation}->{'Apply Consumption of Contract in CustomerPortal.'} = 'Aplicar Consumo de Contrato en CustomerPortal.';
    $Self->{Translation}->{'No data found'} = 'Datos no encontrados';
    $Self->{Translation}->{'title'} = 'título';
    $Self->{Translation}->{'Search tickets'} = 'Buscar entradas';

      $Self->{Translation}->{'Ticket view configuration, it is possible to create different filters for each view, being possible to include a title in the Model, in the Search the ticket search parameters (if it is an ARRAY, insert data separated by semicolons) and in the VisibleColumns the columns that will be displayed.
The views start from the base of calls that the client user can see, so he already sends the standard filters.
The first key defined will be the parameter that must be sent as a parameter in the URL Action=MyTickets;Subaction=MyTickets;ViewModel=Key'} = 'Configuración de vista de ticket, es posible crear diferentes filtros para cada vista, siendo posible incluir un título en el Modelo, en la Búsqueda los parámetros de búsqueda del ticket (si es un ARRAY, insertar datos separados por punto y coma) y en las ColumnasVisibles los columnas que se mostrarán.
Las vistas parten de la base de llamadas que el usuario cliente puede ver, por lo que ya envía los filtros estándar.
La primera clave definida será el parámetro que se debe enviar como parámetro en la URL Action=MyTickets;Subaction=MyTickets;ViewModel=Key';
    $Self->{Translation}->{'Configuration of visible columns for each ticket view model defined in the CustomerPortal::Core::ViewTickes###Config configuration.'} = 'Configuración de columnas visibles para cada modelo de vista de ticket definido en la configuración CustomerPortal::Core::ViewTickes###Config.';
    $Self->{Translation}->{'Card view type.'} = 'Tipo de vista de tarjeta.';
    $Self->{Translation}->{'List view'} = 'Vista de la lista';
    $Self->{Translation}->{'Card view'} = 'Vista de tarjeta';
    $Self->{Translation}->{"Display of the first service level. Note: the list option will only work if the config 'CustomerPortal::Core::TypeViewService' is selected as List View."} = "Visualización del primer nivel de servicio. Nota: la opción de lista solo funcionará si la configuración 'CustomerPortal::Core::TypeViewService' está seleccionada como Vista de lista";

    $Self->{Translation}->{'FAQ Categories'} = 'Categorías de preguntas frecuentes';
    $Self->{Translation}->{'Define the service Description.'} = 'Defina la descripción del servicio.';
    $Self->{Translation}->{'Defines an image for the service. Accepts internal or external images.'} = 'Define una imagen para el servicio. Acepta imágenes internas o externas.';
    $Self->{Translation}->{'Service Image'} = 'imagen de servicio';
    $Self->{Translation}->{'2 - Enabled and in bold'} = '2: habilitado y en negrita';
    $Self->{Translation}->{'How can we help?'} = '¿Cómo podemos ayudar?';
    $Self->{Translation}->{'Browse the categories or use the search bar'} = 'Navega por las categorías o usa la barra de búsqueda';
    $Self->{Translation}->{'In the current month %s tickets were counted and %s hours were recorded'} = 'En el mes actual se han contado% s llamadas y se han registrado% s horas';
    $Self->{Translation}->{'Edit Home Page'} = 'Editar página de inicio';
    $Self->{Translation}->{'Quick access'} = 'Acceso rapido';
    $Self->{Translation}->{"Customize the Home Page with HTML and CSS in the 'Source Code' area. Use the examples below if necessary."} = "Personalice la página de inicio con HTML y CSS en el área 'Código fuente'. Utilice los ejemplos siguientes si es necesario.";
    $Self->{Translation}->{"Central card with access buttons for internal and external links."} = "Tarjeta central con botones de acceso para enlaces internos y externos.";
    $Self->{Translation}->{"Use this example"} = "Usa este ejemplo";
    $Self->{Translation}->{"Access cards for internal and external links."} = "Tarjetas de acceso para enlaces internos y externos.";
    $Self->{Translation}->{"access cards"} = "tarjetas de acceso";
    $Self->{Translation}->{"Set portal menu type."} = "Defina el tipo de menú del portal.";
    $Self->{Translation}->{"Service card title color and style."} = "Color y estilo del título de la tarjeta de servicio.";
    $Self->{Translation}->{"Home page search center card."} = "Tarjeta del centro de búsqueda de la página de inicio.";
    $Self->{Translation}->{"Central service search card."} = "Tarjeta de búsqueda de servicio central.";
    $Self->{Translation}->{"Screens that will display the background image."} = "Pantallas que mostrarán la imagen de fondo.";

    $Self->{Translation}->{"Displays the back button on the top menu."} = "Muestra el botón Atrás en el menú superior.";
    $Self->{Translation}->{"Home page custom card position."} = "Posición de la tarjeta personalizada de la página de inicio.";
    $Self->{Translation}->{"Above"} = "Arriba";
    $Self->{Translation}->{"Below"} = "Debajo";
    $Self->{Translation}->{"Side bar"} = "Menú lateral";
    $Self->{Translation}->{"Top bar"} = "Menu principal";
    $Self->{Translation}->{"Show the ImpactOperation dynamic field according to the service. Enter the service name."} = "Mostrar el campo dinámico ImpactOperation según el servicio. Introduzca el nombre del servicio.";
    $Self->{Translation}->{"FAQ Only"} = "Solo FAQ";
    $Self->{Translation}->{"Service Only"} = "Solo Servicio";
    $Self->{Translation}->{"Standard Search"} = "Busqueda estandar";
    $Self->{Translation}->{"Ticket Only"} = "Sólo llamadas";
    $Self->{Translation}->{"Sets a default value in the search."} = "Establece un valor predeterminado en la búsqueda.";
    $Self->{Translation}->{"Portal form title style."} = "Estilo de título del formulario del portal.";
    $Self->{Translation}->{"Setting to show company calls to specific customers."} = "Configuración para mostrar las llamadas de la empresa a clientes específicos.";
    $Self->{Translation}->{"Defines the text that will be displayed in the article."} = "Define el texto que se mostrará en el artículo";
    $Self->{Translation}->{"View preview of the article"} = "Exibir vista previa del artículo";
    $Self->{Translation}->{"View article subject"} = "Exibir asunto del artículo";
    $Self->{Translation}->{"Transparent main card."} = "Tarjeta principal transparente.";
    $Self->{Translation}->{"Possible mapping for filter on MyTicket screen."} = "Posible mapeo para filtro en la pantalla MyTicket.";
    $Self->{Translation}->{"Possible mapping for filter on CompanyTickets screen."} = "Posible mapeo para filtro en la pantalla CompanyTickets.";
    $Self->{Translation}->{'Aware wish to continue'} = 'Soy consciente del deseo de continuar';
    $Self->{Translation}->{'Go to searches'} = 'Ir a búsquedas';
    $Self->{Translation}->{'Date submission of the survey'} = 'Fecha de presentación de la encuesta';
    $Self->{Translation}->{'Defines where the BlockTicketSurvey will be displayed.'} = 'Define dónde se mostrará BlockTicketSurvey.';
    $Self->{Translation}->{'FrontendModuleRegistration for module.'} = 'Configuración para registrar el módulo.';
    $Self->{Translation}->{'Tell you how many days you want the search to have been sent.'} = 'cuántos días desea que se haya enviado la búsqueda.';
    $Self->{Translation}->{'Setting to set search IDs'} = 'Configuración para establecer identificadores de búsqueda';
    $Self->{Translation}->{'Enter message that will be displayed to the user'} = 'Introduzca el mensaje que se mostrará al usuario';
    $Self->{Translation}->{'Please answer the questions below to continue with the opening of the so-called'} = 'Por favor, responda a las preguntas a continuación para continuar con la apertura de la llamada';
    $Self->{Translation}->{'Enter title message that will be displayed to the user'} = 'Introduzca el mensaje de título que se mostrará al usuario';
    $Self->{Translation}->{'You have pending searches'} = 'Tienes búsquedas pendientes';
    $Self->{Translation}->{'Configuration to enable the module.'} = 'Configuración para habilitar el módulo.';
    $Self->{Translation}->{'Company Name'} = 'Nombre de la empresa';
    $Self->{Translation}->{'Home Page'} = 'Página principal';
    $Self->{Translation}->{'Home Page '} = 'Página principal';
    $Self->{Translation}->{'New Ticket'} = 'Nueva convocatoria';
    $Self->{Translation}->{'New Ticket Process'} = 'Nueva llamada a través del proceso';
    $Self->{Translation}->{'My Tickets'} = 'Mis llamamientos';
    $Self->{Translation}->{'Company Tickets'} = 'Llamadas de empresa';
    $Self->{Translation}->{'Other'} = 'Otro';
    $Self->{Translation}->{'Favorites Services'} = 'Servicios favoritos';
    $Self->{Translation}->{'Notification'} = 'Notificaciones';
    $Self->{Translation}->{'Hour Consumption'} = 'Consumo de horas';
    $Self->{Translation}->{'Contract Consumption'} = 'Consumo por contrato';
    $Self->{Translation}->{'The FAQ did not solve my problem! I want to open a ticket'} = '¡Las preguntas frecuentes no resolvieron mi problema! Quiero abrir una convocatoria';
    $Self->{Translation}->{'The FAQ solved my problem!'} = '¡Las preguntas frecuentes resolvieron mi problema!';
    $Self->{Translation}->{'My Data'} = 'Mis datos';
    $Self->{Translation}->{'Preferences'} = 'Preferencias';
    $Self->{Translation}->{'Research'} = 'Investigación';
    $Self->{Translation}->{'Service FAQ'} = 'Preguntas frecuentes sobre el servicio';
    $Self->{Translation}->{'File Manager'} = 'Administrador de archivos';
    $Self->{Translation}->{'Total by state'} = 'Total por estado';
    $Self->{Translation}->{'Ticket by state'} = 'Llamado por estado';
    $Self->{Translation}->{'Ticket Services'} = 'Llamadas de servicio';
    $Self->{Translation}->{'Ticket type'} = 'Llamado por tipo';
    $Self->{Translation}->{'Open x Closed Tickets'} = 'Llamadas abiertas vs. cerradas';
    $Self->{Translation}->{'Open Tickets'} = 'Convocatorias abiertas';
    $Self->{Translation}->{'Family/Service'} = 'Familia/Servicio';
    $Self->{Translation}->{'Inform the logins of the customer users who will be able to add another customer user.'} = 'Informe los inicios de sesión de los usuarios del cliente que podrán agregar otro usuario del cliente.';
    $Self->{Translation}->{'Add customer user'} = 'Añadir usuario cliente';
    $Self->{Translation}->{'User %s added successfully!'} = 'Usuario %s agregado exitosamente!';
    $Self->{Translation}->{'Preferences updated successfully!'} = '¡Preferencias actualizadas con éxito!';

    $Self->{Translation}->{"Add additional CSS content to the page."} = "Agregue contenido CSS adicional a la página.";
    $Self->{Translation}->{'Disable Fields Default Service'} = 'Deshabilitar el servicio predeterminado de campos';
    $Self->{Translation}->{'Define Fields Default.'} = 'Defina los campos predeterminados.';
    $Self->{Translation}->{'Adds new columns to the portal contract report'} = 'Agrega nuevas columnas al informe de contrato del portal';
    $Self->{Translation}->{'Set the display format for the contract report. If you select Article, the report will be displayed by article; if you select Ticket, the report will be displayed by ticket accumulating all times recorded on the ticket.'} = 'Defina o formato de exibição do relatório de contrato. Se você selecionar Artigo, o relatório será exibido por artigo; se você selecionar Ticket, o relatório será exibido por ticket acumulando o todos tempos registrados no ticket.';
    $Self->{Translation}->{'Rounded edges'} = 'Bordes redondeados';
    $Self->{Translation}->{'Set contract at the opening of the call with Acl RelationServiceContract use only if Ticket::Acl::Module###Acl::RelationServiceContract is enabled'} = 'Establecer contrato en la apertura de la llamada con Acl RelationServiceContract use solo si Ticket::Acl::Module###Acl::RelationServiceContract está habilitado';
    $Self->{Translation}->{'ACL para relacionar contratos a serviços no portal'} = 'ACL para relacionar contratos con servicios en el portal';
    $Self->{Translation}->{'Enables the priority field on my tickets in the customer porta'} = 'Habilita el campo de prioridad en mis tickets en el portal del cliente';
    $Self->{Translation}->{'Change default message in new call via process'} = 'Activar el campo de prioridad en mis tickets en el portal del cliente';
    $Self->{Translation}->{'Enable Scroll bar in screen my tickets'} = 'Habilitar barra de desplazamiento en la pantalla mis boletos';

    $Self->{Translation}->{'Select files'} = 'Selecciona archivos';
    $Self->{Translation}->{'Select a file'} = 'Seleccione un archivo';
    $Self->{Translation}->{'Disable my tickets menu.'} = 'Desactivar el menú de mis entradas';

    $Self->{Translation}->{'Displays the article index to the customer on the portal'} = 'Muestra el índice del artículo al cliente en el portal.';
    $Self->{Translation}->{'Display the field with the default value.'} = 'Muestra el campo con el valor predeterminado.';
    $Self->{Translation}->{'Display the field as mandatory and the default option is empty.'} = 'Muestra el campo como obligatorio y la opción predeterminada está vacía.';
    $Self->{Translation}->{'Error creating ticket! Contact your system administrator.'} = '¡Error al crear el ticket! Póngase en contacto con el administrador de su sistema.';

    $Self->{Translation}->{'Parameters of the service opening wait time attribute.'} = 'Parámetros para el intervalo mínimo entre nuevas solicitudes de servicio';
    $Self->{Translation}->{'Opening wait time (in days)'} = 'Intervalo mínimo de nueva apertura (en días)';
    $Self->{Translation}->{'Define the service opening wait time in days. Enter an integer.'} = 'Define el intervalo mínimo en días para llamadas de servicio. Introduzca un número entero.';
    $Self->{Translation}->{'You can\'t open a new ticket in this service yet.'} = 'Aún no puedes abrir un nuevo ticket en este servicio.';
    $Self->{Translation}->{'Plase, wait until %s.'} = 'Por favor, espere hasta %s.';

    $Self->{Translation}->{'User Information'} = 'Informacion del usuario';
    $Self->{Translation}->{'Full Name'} = 'Nombre completo';
    $Self->{Translation}->{'First Name'} = 'Nombre de pila';
    $Self->{Translation}->{'Last Name'} = 'Apellido';
    $Self->{Translation}->{'User Tickets'} = 'Entradas de usuario';
    $Self->{Translation}->{'Created on'} = 'Creado en';

    $Self->{Translation}->{'Enables the display of icons in the top navigation bar with description.'} = 'Habilita a exibição de ícones na barra de navegação superior com descrição.';
    $Self->{Translation}->{'Customize the descriptions of the navbar icons.'} = 'Personalize as descrições dos ícones da barra de navegação. Manter as chaves e alterar os valores.';

    $Self->{Translation}->{'Research FAQ'} = 'Buscar';
    $Self->{Translation}->{'FAQ Problem'} = 'Preguntas';
    $Self->{Translation}->{'FAQ Solution'} = 'Respuestas';
    $Self->{Translation}->{'How can we help you?'} = '¿Cómo podemos ayudarte?';
    $Self->{Translation}->{'Enter keywords here to find the subject you want...'} = 'Ingrese las palabras clave aquí para encontrar el tema que desea...';
    $Self->{Translation}->{'Browse the areas'} = 'Explorar categorías';
    $Self->{Translation}->{'Search results'} = 'Resultados de la búsqueda';
    $Self->{Translation}->{'Define the icon of the FAQ Category, CategoryName -> Icon path.'} = 'Configure el ícono de la categoría de preguntas frecuentes, Nombre de categoría -> Ruta del ícono.';
    $Self->{Translation}->{'No data found'} = 'No se encontraron datos';
    $Self->{Translation}->{'Enable the setting so that the list view does not show the full name in the service, but rather the last level. If FirstLevelViewService is List view.'} = 'Habilite la configuración para que la vista de lista no muestre el nombre completo en el servicio, sino el último nivel. Si FirstLevelViewService es la vista de lista.';
    $Self->{Translation}->{'Set the CustomerLogo to CustomerPortal in cernter interface'} = 'Deja el logotipo de CustomerPortal centrado en la barra de navegación superior.';
    $Self->{Translation}->{'Configuration to enable Acessibility menu in CustomerPortal view.'} = 'Configuração para habilitar o menu Acessibilidade na visualização do CustomerPortal.';

    $Self->{Translation}->{'Enable tickets in the companys ticket tab that have that user copied (Cc) on the ticket. They may also have permission to interact.'} = 'Habilite los tickets en la pestaña de tickets de la empresa que tengan a ese usuario copiado (Cc) en el ticket. También pueden tener permiso para interactuar.';

    push @{ $Self->{JavaScriptStrings} // [] }, (
        'No record found',
        'Showing 0 to 0 of 0 ticket',
        'Loading...',
        'Processing...',
        'Search records',
        'Next',
        'Previous',
        'First',
        'Last',
        'Showing',
        'tickets',
        'Showing from',
        'up until',
        'in',
        'Filtered from',
        'records',
        'Showing 0 to 0 of 0 records',
        'Do you really want to delete this message?',
        'You have already gone through all notifications',
        'Hours spent per month',
        'No data found',
        'Select files or drop them here',
        'Choose an icon',
        'Browse the areas',
        'Search results',
        'No data found',
    );
}

1;