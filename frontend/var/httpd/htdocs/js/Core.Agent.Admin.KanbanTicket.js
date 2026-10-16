// --
// var/httpd/htdocs/js/Core.Agent.Admin.KanbanTicket.js
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
 * @namespace Core.Agent.KanbanTicket
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the Kanban module.
 */
Core.Agent.Admin.KanbanTicket = (function (TargetNS) {

    /**
     * @name Init
     * @memberof Core.Agent.Admin.KanbanTicket
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {
        Core.Agent.Admin.KanbanSearch.Init();
      
        $('#AttributeKanban').on('change', function () {
            var Attribute = $('#Attribute').val();
            Core.Agent.Admin.KanbanSearch.SearchAttributeAdd($("#AttributeKanban").val());
            Core.Agent.Admin.KanbanSearch.AdditionalAttributeSelectionRebuild();
            TargetNS.QueueToMove();
            TargetNS.StateToMove();
            TargetNS.PriorityToMove();
            return false;
        });

    	$(".AddRule").click(function(){
            Core.Agent.Admin.KanbanSearch.RuleAttributeAdd();
        });
        
        $('#QueueIDsValid').on('change', function () {

            var QueuesIDs =  JSON.stringify($('#QueueIDsValid').val());
            var Data = {
                "Action":"AdminKanbanTicket",
                "Subaction":"QueuesLoader",
                "QueuesIDs": QueuesIDs,
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    $('#QueueToMove').html('');
                    
                    $.each(JSON.parse(Response.JSONString),function(key, value) {
                        var opt = document.createElement('option');
                        opt.textContent = value;
                        opt.value = key;
                        if( Response.SelectedValue && key === Response.SelectedValue ){
                            opt.setAttribute("selected", "selected");
                        }
                        $('#QueueToMove').append(opt);
                    });
        
                    if ($('#QueueToMove').hasClass('Modernize')) {
                        $('#QueueToMove').trigger('redraw.InputField');
                    }
        
                   $('#QueueToMove').trigger('redraw.InputField');
                }
            });
        });

        $('#StateIDsValid').on('change', function () {
            var StateIDs =  JSON.stringify($('#StateIDsValid').val());
            var Data = {
                "Action":"AdminKanbanTicket",
                "Subaction":"StatesLoader",
                "StateIDs": StateIDs,
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    $('#StateToMove').html('');
                    
                    $.each(JSON.parse(Response.JSONString),function(key, value) {
                        var opt = document.createElement('option');
                        opt.textContent = value;
                        opt.value = key;
                        if( Response.SelectedValue && key === Response.SelectedValue ){
                            opt.setAttribute("selected", "selected");
                        }
                        $('#StateToMove').append(opt);
                    });
        
                    if ($('#StateToMove').hasClass('Modernize')) {
                        $('#StateToMove').trigger('redraw.InputField');
                    }
        
                   $('#StateToMove').trigger('redraw.InputField');
                }
            });
        });

        $('#PriorityIDsValid').on('change', function () {
            var PriorityIDs =  JSON.stringify($('#PriorityIDsValid').val());
            var Data = {
                "Action":"AdminKanbanTicket",
                "Subaction":"PriorityLoader",
                "PriorityIDs": PriorityIDs,
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    $('#PriorityToMove').html('');
                    
                    $.each(JSON.parse(Response.JSONString),function(key, value) {
                        var opt = document.createElement('option');
                        opt.textContent = value;
                        opt.value = key;
                        if( Response.SelectedValue && key === Response.SelectedValue ){
                            opt.setAttribute("selected", "selected");
                        }
                        $('#PriorityToMove').append(opt);
                    });
        
                    if ($('#PriorityToMove').hasClass('Modernize')) {
                        $('#PriorityToMove').trigger('redraw.InputField');
                    }
        
                   $('#PriorityToMove').trigger('redraw.InputField');
                }
            });
        });
    };

    TargetNS.ManualSorting = function () {
        if($("#ManualSorting").is(':checked')){
            $("#ManualSorting").val('1');
        }else{
            $("#ManualSorting").val('0');
        }
    };

    TargetNS.StartCollapsed = function () {
        if($("#StartCollapsed").is(':checked')){
            $("#StartCollapsed").val('1');
        }else{
            $("#StartCollapsed").val('0');
        }
    };
    
    TargetNS.PreviewOnly = function () {
        if($("#PreviewOnly").is(':checked')){
            $("#PreviewOnly").val('1');
        }else{
            $("#PreviewOnly").val('0');
        }
    };


    TargetNS.QueueToMove = function () {
        $('#QueueIDsValid').on('change', function () {
            var QueuesIDs =  JSON.stringify($('#QueueIDsValid').val());
            var Data = {
                "Action":"AdminKanbanTicket",
                "Subaction":"QueuesLoader",
                "QueuesIDs": QueuesIDs,
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    $('#QueueToMove').html('');
                    
                    $.each(JSON.parse(Response.JSONString),function(key, value) {
                        var opt = document.createElement('option');
                        opt.textContent = value;
                        opt.value = key;
                        if( Response.SelectedValue && key === Response.SelectedValue ){
                            opt.setAttribute("selected", "selected");
                        }
                        $('#QueueToMove').append(opt);
                    });
        
                    if ($('#QueueToMove').hasClass('Modernize')) {
                        $('#QueueToMove').trigger('redraw.InputField');
                    }
        
                   $('#QueueToMove').trigger('redraw.InputField');
                }
            });
        });

    };

    TargetNS.StateToMove = function () {
        $('#StateIDsValid').on('change', function () {
            var StateIDs =  JSON.stringify($('#StateIDsValid').val());
            
            var Data = {
                "Action":"AdminKanbanTicket",
                "Subaction":"StatesLoader",
                "StateIDs": StateIDs,
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    $('#StateToMove').html('');
                    
                    $.each(JSON.parse(Response.JSONString),function(key, value) {
                        var opt = document.createElement('option');
                        opt.textContent = value;
                        opt.value = key;
                        
                        if( Response.SelectedValue && key === Response.SelectedValue ){
                            opt.setAttribute("selected", "selected");
                        }
                        $('#StateToMove').append(opt);
                    });
        
                    if ($('#StateToMove').hasClass('Modernize')) {
                        $('#StateToMove').trigger('redraw.InputField');
                    }
        
                   $('#StateToMove').trigger('redraw.InputField');
                }
            });
        });
    };

    TargetNS.PriorityToMove = function () {
        $('#PriorityIDsValid').on('change', function () {
            var PriorityIDs =  JSON.stringify($('#PriorityIDsValid').val());
            
            var Data = {
                "Action":"AdminKanbanTicket",
                "Subaction":"PriorityLoader",
                "PriorityIDs": PriorityIDs,
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    $('#PriorityToMove').html('');
                    
                    $.each(JSON.parse(Response.JSONString),function(key, value) {
                        var opt = document.createElement('option');
                        opt.textContent = value;
                        opt.value = key;
                        
                        if( Response.SelectedValue && key === Response.SelectedValue ){
                            opt.setAttribute("selected", "selected");
                        }
                        $('#PriorityToMove').append(opt);
                    });
        
                    if ($('#PriorityToMove').hasClass('Modernize')) {
                        $('#PriorityToMove').trigger('redraw.InputField');
                    }
        
                   $('#PriorityToMove').trigger('redraw.InputField');
                }
            });
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.KanbanTicket || {}));
