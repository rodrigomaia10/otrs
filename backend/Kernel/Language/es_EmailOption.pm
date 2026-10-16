# --
# Kernel/Language/es_EmailOption.pm
# Copyright (C) 2019 Service Up, http://www.serviceup.com.br
#
# written/edited by:
# * msantos@serviceup.com.br
# * dsilva@serviceup.com.br
# * nfreitas@serviceup.com.br
# * dparavani@serviceup.com.br
# --

package Kernel::Language::es_EmailOption;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'Change ticket state when answered.'} = 'Cambia el estado es el llamado a ser contestada.';
    $Self->{Translation}->{'Defines the text that will appear in the article.'} = 'Define el texto que aparece en el artículo.';
    $Self->{Translation}->{'Dynamic field updated successfully.'} = 'Campo dinámico actualizado con éxito.';
    $Self->{Translation}->{'Write here...'} = 'Escribe aquí...';
    $Self->{Translation}->{'Defines the subject that will appear in the article.'} = 'Define el tema que aparecerá en el artículo.';
    $Self->{Translation}->{'Defines whether the EmailOption response will be visible to the customer.'} = 'Define si la respuesta de EmailOption será visible para el cliente.';
    
    $Self->{Translation}->{'Email of user who responded to EmailOption.'} = 'Correo electrónico del usuario que respondió a EmailOption.';    
    $Self->{Translation}->{'Subject and body of article created in EmailOption response.'} = 'Asunto y cuerpo del artículo creado en la respuesta de EmailOption.,';
    $Self->{Translation}->{'Settings for the text to be displayed in the title, header and button color.'} = 'Configuración del texto a mostrar en el título, encabezado y color de los botones.';
    $Self->{Translation}->{'The created article will not be visible to the agent.'} = 'El artículo creado no será visible para el agente.';
    $Self->{Translation}->{'Email from who responded to Email Option.'} = 'Correo electrónico de quien respondió a la opción de correo electrónico.';
    
    $Self->{Translation}->{'Information'} = 'Informaciones';
    $Self->{Translation}->{'You have already answer.'} = 'Usted ya ha contestado.';
    $Self->{Translation}->{'Ticket data'} = 'Datos del ticket';
    $Self->{Translation}->{'TicketNumber : '} = 'Numero de ticket:';
    $Self->{Translation}->{'Title : '} = 'Título :';
    $Self->{Translation}->{'Customer : '} = 'Cliente :';
    $Self->{Translation}->{'Agent : '} = 'Agente :';
    $Self->{Translation}->{'Email Option'} = 'Opción de correo electrónico';
    $Self->{Translation}->{'For more details, access the ticket clicking '} = 'Para más detalles, acceda a la compra de entradas clic ';
    $Self->{Translation}->{'here'} = 'aquí';
    $Self->{Translation}->{'Enter the information to complete the vote'} = 'Ingrese la información para completar la votación.';
    $Self->{Translation}->{'The dynamic field '} = 'El campo dinámico ';
    $Self->{Translation}->{' has been successfully updated, with the value: '} = ' ha sido actualizado con éxito, con el valor:';
    $Self->{Translation}->{'An error has occurred'} = 'Se ha producido un error';
    $Self->{Translation}->{'An error has occurred, please contact support'} = 'Ha ocurrido un error, por favor contacte a soporte';
    $Self->{Translation}->{'Approval'} = 'Aprobación';
    $Self->{Translation}->{'DynamicField update'} = 'Actualización de DynamicField';
    $Self->{Translation}->{'You answered: '} = 'Su respuesta: ';
    $Self->{Translation}->{'Click here'} = 'Haga clic aquí';
    $Self->{Translation}->{'or'} = 'o';
    $Self->{Translation}->{'Configuration of texts. First key: Dynamic Field. Second Key: ValueField1 - Text displayed when registering the value. ValueField2 - Text displayed if the answer has the text field enabled.'} = 'Configuración de textos. Primera clave: campo dinámico. Segunda clave: ValueField1: texto que se muestra al registrar el valor. ValueField2: texto que se muestra si la respuesta tiene habilitado el campo de texto.';
    $Self->{Translation}->{'to be redirected to the tool.'} = 'para ser redirigido a la herramienta.';
    $Self->{Translation}->{'Article creation obligatory'} = 'Creación obligatoria del artículo.';
    $Self->{Translation}->{'Dynamic Field not enabled'} = 'Campo dinámico no habilitado';
    $Self->{Translation}->{'Updated dynamic field via email'} = 'Campo dinámico actualizado por correo electrónico';
    $Self->{Translation}->{'Dynamic Fields enabled to be set via e-mail. Possible settings: 0 = Disabled, 1 = Available.'} = 'Campos dinámicos habilitados para configurarse por correo electrónico. Configuraciones posibles: 0 = Deshabilitado, 1 = Disponible.';
    $Self->{Translation}->{'Text show when a justification is needed.'} = 'El texto muestra cuándo se necesita una justificación.';
    $Self->{Translation}->{'Hidden notification for agent'} = "Notificación oculta para el asistente";
    $Self->{Translation}->{'Autoload for module EmailOptionNotificationHidden'} = "Autoload para el módulo EmailOptionNotificationHidden";
    $Self->{Translation}->{'Frontend module registration for the NotificationHidden in the admin area'} = "Registro del módulo frontend para NotificationHidden en el área de administración";
    $Self->{Translation}->{'NotificationHidden'} = "Notificación oculta";
    $Self->{Translation}->{'Article not visible for agent'} = "Artículo no visible para el asistente";

    $Self->{Translation}->{'This option enables the possibility of attaching files when sending a justification via EmailOption.'} = "Esta opción habilita la posibilidad de adjuntar archivos al enviar una justificación a través de EmailOption.";
    $Self->{Translation}->{'Dynamic field to save the justification for an approve / disapprove.'} = "Campo dinámico para guardar la justificación de una aprobación/desaprobación.";
    $Self->{Translation}->{'Defines dynamic fields to display when a ticket is disapproved.'} = "Define los campos dinámicos que se mostrarán cuando se desaprueba un ticket";
    $Self->{Translation}->{'Message configuration for notifications already responded to. First key: Dynamic Field used in EmailOption. Second Key: Message to be displayed, this message may contain TAGs referencing ticket information. Ex: <OTRS_TICKET_DynamicField_Field1>'} = "Configuración de mensajes para notificaciones ya respondidas. Primera clave: campo dinámico utilizado en EmailOption. Segunda clave: mensaje que se mostrará; este mensaje puede contener etiquetas que hagan referencia a la información del ticket. Ej: <OTRS_TICKET_DynamicField_Field1>";
    $Self->{Translation}->{'This configuration makes it possible to create the article when a notification is responded to. By disabling this config, the InBox::EmailOption::DynamicFieldsTexts, InBox::EmailOption::DefaultTextOfAnsweredArticle and InBox::EmailOption::DefaultSubjectOfAnsweredArticle configs will not work.'} = "Esta configuración permite crear el artículo cuando se responde a una notificación. Al deshabilitar esta configuración, las configuraciones InBox::EmailOption::DynamicFieldsTexts, InBox::EmailOption::DefaultTextOfAnsweredArticle y InBox::EmailOption::DefaultSubjectOfAnsweredArticle no funcionarán.";


}

1;
