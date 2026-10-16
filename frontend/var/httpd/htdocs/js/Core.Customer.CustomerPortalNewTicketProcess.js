// --
// var/httpd/htdocs/js/Core.Customer.CustomerPortalNewTicketProcess.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.Customer.CustomerPortalNewTicketProcess = (function (TargetNS) {
    
    TargetNS.Init = function () {

        $(".styled-select .InputField_Container").remove();

        var ProcessID = document.getElementById("ProcessEntityID");
    
        if (ProcessID != null) {
            $('#ProcessEntityID').selectHierarchy({
                hideOriginal: true
            });
        }

        var ProcessEntityID = GetURLParameter('ProcessEntityID');
        var Subaction       = GetURLParameter('Subaction');

        if (ProcessEntityID && Subaction != "DisplayActivityDialog") {

            newProcessName();

            showFieldsOfProcess(ProcessEntityID);
        }

        $('#ProcessEntityID').on('change', function () {

            newProcessName();

            showFieldsOfProcess($('#ProcessEntityID').val());
        });

        var PreSelectedProcessID = Core.Config.Get('PreSelectedProcessID');

        // If process is pre-selected trigger change event on ProcessEntityID field.
        if (typeof PreSelectedProcessID !== 'undefined') {
            $('#ProcessEntityID').val(PreSelectedProcessID).trigger('change');
        }

        $( "#DialogButton1" ).click(function() {
            $("#Overlay").addClass('Hidden'); 
        });
    };

    function showFieldsOfProcess(ProcessID){

        var TicketNumber = GetURLParameter('TicketNumber');
        var TicketEqual  = GetURLParameter('TicketEqual');

        var Data = {
            Action: 'NewTicketProcess',
            Subaction: 'DisplayActivityDialogAJAX',
            ProcessEntityID: ProcessID,
            FormID: $('input:hidden[name=FormID]').val(),
            IsAjaxRequest: 1,
            IsMainWindow: 1,
            TicketEqual: TicketEqual,
            TicketNumber: TicketNumber
        };

        if ($('#IsProcessEnroll').val() !== 'undefined' && $('#IsProcessEnroll').val() === '1') {
            $.extend(Data, {
                IsMainWindow: 0,
                IsProcessEnroll: 1,
                TicketID: $('#TicketID').val()
            });
        }

        // remove/destroy CKEditor instances
        // This is needed to initialize other instances (in other activity dialogs)
        // without a page reload
        if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances) {
            $.each(CKEDITOR.instances, function (Key) {
                CKEDITOR.instances[Key].destroy();
            });
        }

        if (ProcessID) {

            // remove the content of the activity dialog
            $('#ActivityDialogContent').empty();

            // fade out the empty container so it will fade in again on processes change
            // is not recommended to empty after fade out at this point since the transition offect
            // will not look so nice
            $('#ActivityDialogContent').fadeOut('fast');

            // show loader icon
            $('#AJAXLoader').removeClass('Hidden');

            // get new ActivityDialog content
            Core.AJAX.FunctionCall(
                Core.Config.Get('CGIHandle'),
                Data,
                function (Response) {
                var $ElementToUpdate = $('#ActivityDialogContent'),
                    JavaScriptString = '',
                    ErrorMessage;

                if (!Response) {

                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No content received.", 'CommunicationError'));
                    $('#AJAXLoader').addClass('Hidden');
                }
                else if ($ElementToUpdate && isJQueryObject($ElementToUpdate) && $ElementToUpdate.length) {
                    $ElementToUpdate.get(0).innerHTML = Response;
                    $ElementToUpdate.find('script').each(function() {
                        JavaScriptString += $(this).html();
                        $(this).remove();
                    });
                    $ElementToUpdate.fadeIn();
                    Core.UI.InputFields.Activate($ElementToUpdate);
                    try {
                        /*eslint-disable no-eval */
                        eval(JavaScriptString);
                        /*eslint-enable no-eval */
                    }
                    catch (Event) {
                        // do nothing here (code needed  to not have an empty block here)
                        $.noop(Event);
                    }

                    if (typeof Core.Config.Get('ParentReload') !== 'undefined' && parseInt(Core.Config.Get('ParentReload'), 10) === 1){
                        if (Core.UI.Popup.IsPopupWindow()) {
                            Core.UI.Popup.ExecuteInParentWindow(function (ParentWindow) {
                                ParentWindow.Core.UI.Popup.FirePopupEvent('Reload');
                            });
                        }
                    }

                    // Handle special server errors (Response = <div class="ServerError" data-message="Message"></div>)
                    // Check if first element has class 'ServerError'
                    if ($ElementToUpdate.children().first().hasClass('ServerError')) {
                        ErrorMessage = $ElementToUpdate.children().first().data('message');

                        // Add class ServerError to the process select element
                        $('#ProcessEntityID').addClass('ServerError');
                        // Set a custom error message to the proccess select element
                        $('#ProcessEntityIDServerError').children().first().text(ErrorMessage);
                    }

                    Core.Form.Validate.Init();

                    // Register event for tree selection dialog
                    Core.UI.TreeSelection.InitTreeSelection();

                    // initialize ajax dnd upload
                    Core.UI.InitAjaxDnDUpload();

                    // move help triggers into field rows for dynamic fields
                    $('.Row > .FieldHelpContainer').each(function () {
                        if (!$(this).next('label').find('.Marker').length) {
                            $(this).prependTo($(this).next('label'));
                        }
                        else {
                            $(this).insertAfter($(this).next('label').find('.Marker'));
                        }
                    });

                    // Initially display dynamic fields with TreeMode = 1 correctly
                    Core.UI.TreeSelection.InitDynamicFieldTreeViewRestore();

                    // trigger again a responsive event
                    if (Core.App.Responsive.IsSmallerOrEqual(Core.App.Responsive.GetScreenSize(), 'ScreenL')) {
                        Core.App.Publish('Event.App.Responsive.SmallerOrEqualScreenL');
                    }

                    $('#AJAXLoader').addClass('Hidden');
                    $('#AJAXDialog').val('1');

                    Core.TicketProcess.Init();

                    // Publish event on first activity dialog load, so other code can know to execute again.
                    Core.App.Publish('TicketProcess.Init.FirstActivityDialog.Load', [$ElementToUpdate]);
                }
                else {

                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No such element id: " + $ElementToUpdate.attr('id') + " in page!", 'CommunicationError'));
                    $('#AJAXLoader').addClass('Hidden');
                }
            }, 'html');
        }
        else {
            $('#ActivityDialogContent').fadeOut(400, function() {
                $('#ActivityDialogContent').empty();
            });
        }
        return false;
    }

    function GetURLParameter(sParam) {

        let sPageURL = window.location.search.substring(1);
        let sURLVariables = sPageURL.split(';');
    
        for (let i = 0; i < sURLVariables.length; i++) {
            let sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] == sParam){
                return sParameterName[1];
            }
        }
    }

    function newProcessName(){

        let ProcessName = $('#ProcessEntityID option:selected').text();

        let Arrayname = ProcessName.split("::");
        let ArraySize = Arrayname.length;

        let novoNome = "";

        $.each( Arrayname, function( i, name ) {

            if (i + 1 == ArraySize) {
                novoNome += name;
            }
            else{
                novoNome += name + " → ";
            }
        });

        $("#MyProcessName").html("");

        $("#MyProcessName").append( "<span>" + novoNome + "</span>" );
    }

  Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

  return TargetNS;
}(Core.Customer.CustomerPortalNewTicketProcess || {}));
