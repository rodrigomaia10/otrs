// --
// var/httpd/htdocs/js/Core.Agent.ProcessFieldReadOnly.js
// Copyright (C) 2019 Service Up, http://www.beonup.com.br
//
// written/edited by:
// * dsilva@beonup.com.br
// * jsantos@beonup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.UI = Core.UI || {};
var ReturnFields = "";

/**
 * @namespace Core.Agent.ProcessFieldReadOnly
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the ProcessFieldReadOnly module.
 */
Core.Agent.ProcessFieldReadOnly = (function (TargetNS) {
    $(document).change(function() {
        TargetNS.Init();
    });

    /**
     * @name Init
     * @memberof Core.Agent.ProcessFieldReadOnly
     * @function
     * @description
     *      This function initializes module functionality.
    */
    TargetNS.Init = function () {

        if (ReturnFields) {

            var Fields = ReturnFields;

            $.each( Fields, function( key, value ) {

                if( value.Type == 'Input' ) {
                    $( '#' + value.Field ).attr('readonly', 'readonly');
                }
                else if( value.Type == 'Select' ) {

                    $( "#" + value.Field + "_Search" ).attr('readonly', 'readonly');
                    $( "#" + value.Field + "_Search" ).next().children().next().css('display', 'none');

                    if( value.Field === 'OwnerID' ) {
                        $('#OwnerSelectionGetAll').css('display', 'none');
                    }
                    else if ( value.Field === 'ResponsibleID' ) {
                        $('#ResponsibleSelectionGetAll').css('display', 'none');
                    }
                }
                else if( value.Type == 'FileSystem' ) {

                    $('#' + value.Field).css('display', 'none');

                    if( $('#' + value.Field).next().text() === '' ){
                        $('#' + value.Field).next().remove();
                    }
                }
                else if( value.Type == 'SelectDB' ) {

                    $( "#" + value.Field + "_Search" ).attr('readonly', 'readonly');
                    $(".Row_" + value.Field + " .Remove").remove();
                }
            });

        }
        else {
            var Data = {
                Action: 'FieldReadOnlyAJAXHandler',
                Subaction: 'GetReadOnlyFields',
                ProcessEntityID: GetURLParameter('ProcessEntityID'),
                ActivityDialogEntityID: GetURLParameter('ActivityDialogEntityID')
            };
        
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
                if (!Result.JSONString) {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No content ProcessEntityID received.", 'CommunicationError'));
                }
                else {
                
                    var Fields = JSON.parse(Result.JSONString);

                    ReturnFields = Fields;

                    $.each( Fields, function( key, value ) {

                        if( value.Type == 'Input' ) {
                            $( '#' + value.Field ).attr('readonly', 'readonly');
                        }
                        else if( value.Type == 'Select' ) {

                            $( "#" + value.Field + "_Search" ).attr('readonly', 'readonly');
                            $( "#" + value.Field + "_Search" ).next().children().next().css('display', 'none');

                            if( value.Field === 'OwnerID' ) {
                                $('#OwnerSelectionGetAll').css('display', 'none');
                            }
                            else if ( value.Field === 'ResponsibleID' ) {
                                $('#ResponsibleSelectionGetAll').css('display', 'none');
                            }
                        }
                        else if( value.Type == 'FileSystem' ) {

                            $('#' + value.Field).css('display', 'none');

                            if( $('#' + value.Field).next().text() === '' ){
                                $('#' + value.Field).next().remove();
                            }
                        }
                        else if( value.Type == 'SelectDB' ) {

                            $( "#" + value.Field + "_Search" ).attr('readonly', 'readonly');
                            $(".Row_" + value.Field + " .Remove").remove();
                        }
                    });
                }
            });
        }
    };

    function GetURLParameter(sParam) {
        var sPageURL = window.location.search.substring(1);
        var sURLVariables = sPageURL.split(';');
    
        for (var i = 0; i < sURLVariables.length; i++) {
            var sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] == sParam)
            {
                return sParameterName[1];
            }
        }
    }    

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.ProcessFieldReadOnly || {}));