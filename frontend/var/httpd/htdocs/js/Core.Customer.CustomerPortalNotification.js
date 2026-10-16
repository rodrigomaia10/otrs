// --
// var/http/htdocs/js/Core.Customer.CustomerPortalNotification.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};

/**
 * @namespace Core.Customer.CustomerPortalNotification
 * @memberof Core.Customer
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for CustomerPortal module.
 */
Core.Customer.CustomerPortalNotification = (function (TargetNS) {

    /**
    * @name Init
    * @memberof Core.Customer.CustomerPortalNotification
    * @function
    * @description
    *      This function initializes the module functionality.
    */
    TargetNS.Init = function () {


    $(".btn-delete-notify").on("click", function(){
    
        var NotificationID = $(this).attr('data-ID');
        
        if (window.confirm(Core.Language.Translate("Do you really want to delete this message?"))) {

            var Data = {
                "Action":"CustomerPortalNotifications",
                "Subaction":"DeleteNotification",
                "NotificationID": NotificationID,
            };
        
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{

                    $('#LineTableNotify_'+NotificationID).html('');
                }
            });


        };
    });

    $(".btn-unread-notify").on("click", function(){
    
        var NotificationID = $(this).attr('data-ID');
    
        var Data = {
            "Action":"CustomerPortalNotifications",
            "Subaction":"UnreadNotification",
            "NotificationID": NotificationID,
        };
        
        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{
                window.location.reload();
            }
        });

    });  
    
    $(".btn-read-notify").on("click", function(){
    
        var NotificationID = $(this).attr('data-ID');
    
        var Data = {
            "Action":"CustomerPortalNotifications",
            "Subaction":"ReadNotification",
            "NotificationID": NotificationID,
        };
        
        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{
                window.location.reload();
            }
        });

    });  

    var SizeConfig = Core.Config.Get('NotificationTableSize');

    $('#NotificationTable').DataTable({          
        pageLength: SizeConfig,
        bFilter: false,
        lengthChange: false,
        language: {
            "sEmptyTable": Core.Language.Translate("No record found"),
            "sInfo": Core.Language.Translate("Mostrando de") +" _START_ "+Core.Language.Translate('up until') +" _END_ "+ Core.Language.Translate('in') +" _TOTAL_ "+Core.Language.Translate('records'),
            "sInfoEmpty": Core.Language.Translate("Showing 0 to 0 of 0 records"),
            "sInfoFiltered": "("+ Core.Language.Translate("Filtered from")+" _MAX_ "+Core.Language.Translate("records")+")",
            "sInfoPostFix": "",
            "sInfoThousands": ".",
            "sLengthMenu": Core.Language.Translate("Mostrando") + " _MENU_ " + Core.Language.Translate("records"),
            "sLoadingRecords": Core.Language.Translate("Loading..."),
            "sProcessing": Core.Language.Translate("Processing..."),
            "sZeroRecords":  Core.Language.Translate("No record found"),
            "searchPlaceholder": Core.Language.Translate("Search records"),
            "sSearch": "",
            "oPaginate": {
                "sNext": Core.Language.Translate("Next"),
                "sPrevious": Core.Language.Translate("Previous"),
                "sFirst": Core.Language.Translate("First"),
                "sLast": Core.Language.Translate("Last")
            },
            "oAria": {
                "sSortAscending": ": Ordenar colunas de forma ascendente",
                "sSortDescending": ": Ordenar colunas de forma descendente"
            },   
        },
        
    });

    $(".PopupNotification").on("click", function(){
    
        var NotificationID = $(this).attr('data-notifyID');
       
        $('#BodyNotify').html('');

        $('#AJAXLoaderNotification').css('display','inline-block');

        $('#BtnNextNotification').css('display','inline-block');

        var Data = {
            "Action":"CustomerPortalNotifications",
            "Subaction":"NotificationShow",
            "NotificationID": NotificationID,
        };
        
        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{
                $('#BodyNotify').append(Response.HTMLData);
                $('#CurrentNotificationID').val(Response.CurrentNotificationID);
                $('#AJAXLoaderNotification').css('display','none');

            }
        });

    }); 

    $(".NextNotification").on("click", function(){
    
        var NotificationID = $('#CurrentNotificationID').val();
        $('#AJAXLoaderNotification').css('display','inline-block');

        $('#BodyNotify').html('');

        getBodyNextNotication(NotificationID);

    }); 

    function getBodyNextNotication (NotificationID){
        var Notifications = Core.Config.Get('NotificationBody');
         
        var keys = Object.keys(Notifications);
        var index = keys.indexOf(NotificationID);
        var nextID = keys[index-1];
        var nextBody = Notifications[nextID];

        $('#CurrentNotificationID').val(nextID);

        if(nextBody != undefined){
            $('#BodyNotify').append(nextBody);
        }
        else{
            $('#BodyNotify').append("<spam><i class='fa fa-info-circle' aria-hidden='true'></i> "+Core.Language.Translate("You have already gone through all notifications")+"</spam>");
            $('#BtnNextNotification').css('display','none');
        }

        $('#AJAXLoaderNotification').css('display','none');

    }   
}
    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CustomerPortalNotification || {}));


