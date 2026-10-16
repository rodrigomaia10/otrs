// --
// var/httpd/htdocs/js/Core.Agent.Admin.KPISQLQuery.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.KPISQLQuery
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the KPI module.
 */
Core.Agent.Admin.KPISQLQuery = (function (TargetNS) {


  /**
     * @name Init
     * @memberof Core.Agent.Admin.KPISQLQuery
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        var mime = 'text/x-mariadb';
        var  myCodeMirror  =  CodeMirror.fromTextArea(document.getElementById("SQL"), {
            lineNumbers: true,
            mode: mime,
            indentWithTabs: true,
            smartIndent: true,
            lineNumbers: true,
            matchBrackets : true,
            autofocus: true,
            theme: 'eclipse'
        });

        myCodeMirror.on("keyup", function (cm, event) {            
            $('#SQL').val( myCodeMirror.getValue() )
        });

        $('#RunSqlQuery').on('click', function (Event) {

            var Data = {
                "Action":"AdminKPISQLQuery",
                "Subaction":"QueryExecute",
                "SQL":  myCodeMirror.getValue() ,                
            };

            $('.AddedSQLResult').html("");

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    $('.AddedSQLResult').append(Response.Template);

                    if(Response.Error == 0){
                        $('#SubmitKpiQuery').attr('disabled', 'disabled');
                    }else{
                        $('#SubmitKpiQuery').removeAttr('disabled');
                    }
                }
            });

        });

        if($('#ReturnFormat').val() == 'Link'){
            $('#LabelToLink').show();
            $('#Link').show();
        }else{
            $('#LabelToLink').hide();
            $('#Link').hide();
        }

        $('#ReturnFormat').change(function() {
          
            if($('#ReturnFormat').val() == 'Link'){
                $('#LabelToLink').show();
                $('#Link').show();
            }else{
                $('#LabelToLink').hide();
                $('#Link').hide();
                $('#Link').val('');
            }
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.KPISQLQuery || {}));
