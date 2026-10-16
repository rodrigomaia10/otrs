# --
# Kernel/Language/es_TicketInvoker.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * dsilva@serviceup.com.br
# * ccresencio@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::es_TicketInvoker;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # SysConfig
    $Self->{Translation}->{'Ticket attributes that should be available in ticket invoker configuration frontend (0 = visible/selectable, 1 = default/preselected).'} = 'Atributos del ticket que deberían estar disponibles en la interfaz de configuración del invocador del ticket (0 = visible / seleccionable, 1 = predeterminado / preseleccionado).';
    $Self->{Translation}->{'Article attributes that should be available in ticket invoker configuration frontend (0 = visible/selectable, 1 = default/preselected).'} = 'Atributos del artículo que deberían estar disponibles en la interfaz de configuración del invocador de tickets (0 = visible / seleccionable, 1 = predeterminado / preseleccionado).';
    $Self->{Translation}->{'Define a result field for the TicketID of the invoker response per web service (WebserviceID => DynamicFieldName).'} = 'Defina un campo de resultado para el TicketID de la respuesta del invocador por servicio web (WebserviceID => DynamicFieldName).';
    
    $Self->{Translation}->{'General invoker data'} = 'Datos generales del invocador';
    $Self->{Translation}->{'Settings for outgoing request data'} = 'Configuración de datos de solicitudes salientes';
    $Self->{Translation}->{'Only the selected ticket fields will be considered for the request data.'} = 'Solo los campos de ticket seleccionados serán considerados para los datos de la solicitud.';
    $Self->{Translation}->{'Only the selected article fields will be considered for the request data.'} = 'Solo los campos de artículo seleccionados serán considerados para los datos de la solicitud.';
    $Self->{Translation}->{'Article fields'} = 'Campos de artículo';
    $Self->{Translation}->{'Only the selected ticket dynamic fields will be considered for the request data.'} = 'Solo los campos dinámicos del ticket seleccionados se considerarán para los datos de la solicitud.';
    $Self->{Translation}->{'Ticket dynamic fields'} = 'Campos dinámicos de tickets';
    $Self->{Translation}->{'Only the selected article dynamic fields will be considered for the request data.'} = 'Solo los campos dinámicos del artículo seleccionado se considerarán para los datos de la solicitud.';
    $Self->{Translation}->{'Article dynamic fields'} = 'Campos dinámicos del artículo';
    $Self->{Translation}->{'Number of articles'} = 'Número de artículos';
    $Self->{Translation}->{'The outgoing request data will only contain the configured number of articles. If left empty, only 1 article will be sent.'} = 'Los datos de la solicitud saliente solo contendrán el número de artículos configurado. Si se deja vacío, solo se enviará 1 artículo.';
    $Self->{Translation}->{'The outgoing request data will only consider articles of the selected communication channels. If left empty, articles created by all communication channels will be used.'} = 'Los datos de la solicitud de salida solo considerarán artículos de los canales de comunicación seleccionados. Si se deja en blanco, se utilizarán los artículos creados por todos los canales de comunicación.';
    $Self->{Translation}->{'Communication channels'} = 'Canales de comunicación';
    $Self->{Translation}->{'The outgoing request data will only consider articles created with the selected customer visibility.'} = 'Los datos de la solicitud saliente solo considerarán los artículos creados con la visibilidad del cliente seleccionada.';
    $Self->{Translation}->{'Sender Types'} = 'Tipos de remitente';
    $Self->{Translation}->{'The outgoing request data will only consider articles created by the selected sender types. If left empty, articles created by all sender types will be used.'} = 'Los datos de la solicitud saliente solo considerarán los artículos creados por los tipos de remitentes seleccionados. Si se deja en blanco, se utilizarán los artículos creados por todos los tipos de remitentes.';
    
    $Self->{Translation}->{'Additional request headers'} = 'Encabezados de solicitud adicionales';
    $Self->{Translation}->{'Endpoint'} = 'Endpoint';
    $Self->{Translation}->{'Disable SSL hostname certificate verification:'} = 'Desactive la verificación del certificado de nombre de host SSL:';
    $Self->{Translation}->{'Disables hostname certificate verification. This is not recommended and should only be used in test environments.'} = 'Desactiva la verificación del certificado de nombre de host. Esto no se recomienda y solo debe usarse en entornos de prueba.';
    $Self->{Translation}->{'Content type'} = 'Tipo de contenido';
    $Self->{Translation}->{'The default content type added to HTTP header to use for POST and PUT requests.'} = 'El tipo de contenido predeterminado agregado al encabezado HTTP para usar en solicitudes POST y PUT.';
    $Self->{Translation}->{'Add request header'} = 'Agregar encabezado de solicitud';

    $Self->{Translation}->{'Mapping'} = 'Cartografía';

    $Self->{Translation}->{'Settings for incoming response data'} = 'Configuración de los datos de respuesta entrantes';
    $Self->{Translation}->{'Remote TicketID dynamic field'} = 'Campo dinámico Remote TicketID';

    $Self->{Translation}->{'The selected ticket dynamic field is being used to store the remote TicketID.'} = 'El campo dinámico del ticket seleccionado se utiliza para almacenar el TicketID remoto.';
    $Self->{Translation}->{'If left empty, the remote TicketID will not be stored, unless you define a system configuration value for this web service.'} = 'Si se deja vacío, el TicketID remoto no se almacenará, a menos que defina un valor de configuración del sistema para este servicio web.';
    $Self->{Translation}->{'The selected field is already in use by the Ticket dynamic fields option.'} = 'El campo seleccionado ya está siendo utilizado por la opción Campos dinámicos del ticket.';
    
    $Self->{Translation}->{'Only the selected ticket dynamic fields are being considered for processing the incoming response data. If left empty, no dynamic field will be processed.'} = 'Solo los campos dinámicos de ticket seleccionados se están considerando para procesar los datos de respuesta entrantes. Si se deja vacío, no se procesará ningún campo dinámico.';
    $Self->{Translation}->{'Ticket and Article dynamic fields'} = "Campos dinámicos de ticket y artículo";

    $Self->{Translation}->{'Authentication webservice.'} = "Servicio web de autenticación.";
    $Self->{Translation}->{'Authentication Invoker.'} = "Invoker de autenticação.";
    $Self->{Translation}->{'Validity time (in minutes) of authentication key.'} = "Tiempo de validez (en minutos) de la clave de autenticación.";

    $Self->{Translation}->{'Select the FAQ association type it will fetch to insert into the request data.'} = "Seleccione el tipo de asociación de preguntas frecuentes que buscará para insertar en los datos de la solicitud.";
    $Self->{Translation}->{'The exit request data will only contain the last article.'} = "Los datos de la solicitud de salida solo contendrán el último artículo.";
    $Self->{Translation}->{'Select this option if you want the attachments to be returned in the request data.'} = "Seleccione esta opción si desea que los archivos adjuntos se devuelvan en los datos de la solicitud.";
    $Self->{Translation}->{'FAQ membership type'} = "Preguntas frecuentes tipo de membresía";
    $Self->{Translation}->{'Link by Service'} = "Enlace por servicio";
    $Self->{Translation}->{'Link per Ticket'} = "Enlace por boleto";
    $Self->{Translation}->{'Minimum confidence score'} = "Pontuação minimá de confiança";
    $Self->{Translation}->{'Satisfactory Answer'} = "Respuesta satisfactoria";
    $Self->{Translation}->{'Insufficient answer'} = "Respuesta insuficiente";
    $Self->{Translation}->{'Your ticket will be closed, thanks for contacting us.'} = "Su ticket será cerrado, gracias por contactarnos.";
    $Self->{Translation}->{'Your ticket will be forwarded to an agent who will contact you.'} = "Su billete será enviado a un agente que se pondrá en contacto con usted.";

    $Self->{Translation}->{'Enter tags separated by space so that their value is passed in DecodeJSON before mapping. (Provider: Enter the tag value received. Requester: Use in dynamic field with a value in JSON).'} = "Ingrese etiquetas separadas por espacios para que su valor se pase en DecodeJSON antes del mapeo. (Proveedor: Ingrese el valor de la etiqueta recibida. Solicitante: Use en campo dinámico con un valor en JSON).";
    $Self->{Translation}->{'Force array for tags'} = "Forzar matriz para etiquetas";
    $Self->{Translation}->{'Owner, customer and company data'} = "Datos del propietario, cliente y empresa";
    $Self->{Translation}->{'Include Owner, Customer and Customer User Data in the ticket.'} = "Incluir Datos de Titular, Cliente y Usuario del Cliente en el ticket.";
    $Self->{Translation}->{'Keep XML attributes'} = "Mantener atributos XML";
    $Self->{Translation}->{'Only needed for content type XML.'} = "Solo se necesita para el tipo de contenido XML.";
    $Self->{Translation}->{'Enter tags separated by space for which array representation should be forced.'} = "Ingrese etiquetas separadas por espacios para las cuales se debe forzar la representación de matriz.";
    $Self->{Translation}->{'Force number for tags'} = "Número de fuerza para etiquetas";
    $Self->{Translation}->{'Enter tags separated by space for which number representation should be forced.'} = "Digite as tags separadas por espaço para as quais a representação de number deve ser forçada.";
    $Self->{Translation}->{'Enter tags separated by space for which boolean representation should be forced.'}  = "Ingrese etiquetas separadas por espacios para las cuales se debe forzar la representación de boolean.";
    $Self->{Translation}->{'Force boolean for tags'}= "Forzar boolean para etiquetas";
    $Self->{Translation}->{'Only first article'}= "Sólo el primer artículo";

    return 1;
}

1;
