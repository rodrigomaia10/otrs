// --
// var/httpd/htdocs/js/Core.Agent.Admin.AdminKPISurvey.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * nfreitas@beonup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.AdminKPISurvey
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the search.
 */
Core.Agent.Admin.AdminKPISurvey = (function (TargetNS) {
   
    // Search Question
    $('#SurveyID').change(function() {
        $('#AnswerID').html('');
        $('#AnswerID').val('').trigger('redraw.InputField');

        var Data = {
            "Action":"AdminKPISurvey",
            "Subaction":"AjaxToUpdateQuestion",
            "SurveyID":  $('#SurveyID').val(),                              
        };
                                                
        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{       
                
                $('#QuestionID').html('');
                $.each(JSON.parse(Response.JSONString),function(key, value) {                      
                    var opt = document.createElement('option');
                    opt.textContent = value;
                    opt.value = key;
                    $('#QuestionID').append(opt);
                });
    
                if ($('#QuestionID').hasClass('Modernize')) {
                    $('#QuestionID').trigger('redraw.InputField');
                }

                $('#QuestionID').val('').trigger('redraw.InputField');


            }
        });
    });

    // Search Answer
    $('#QuestionID').change(function() {

        var Data = {
            "Action":"AdminKPISurvey",
            "Subaction":"AjaxToUpdateAnswer",
            "QuestionID":  $('#QuestionID').val(),                              
        };
                                                
        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{       
                
                $('#AnswerID').html('');
                    
                $.each(JSON.parse(Response.JSONString),function(key, value) {                      
                    var opt = document.createElement('option');
                    opt.textContent = value;
                    opt.value = key;
                    $('#AnswerID').append(opt);
                });
    
                if ($('#AnswerID').hasClass('Modernize')) {
                    $('#AnswerID').trigger('redraw.InputField');
                }

            }
        });
    });
    
    return TargetNS;
    
}(Core.Agent.Admin.AdminKPISurvey || {}));


