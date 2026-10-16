// --
// var/httpd/htdocs/js/Core.Agent.Admin.PopUpShareKanban.js
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
 * @namespace Core.Agent.Admin.PopUpShareKanban
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the Kanban Boards module.
 */
Core.Agent.Admin.PopUpShareKanban = (function (TargetNS) {
    /**
     * @name Init
     * @memberof Core.Agent.Admin.PopUpShare
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {
        $('#submitRichText').on('click', function () {
            var url = window.location.href;
            var fromKanban = url.split("OpenBy=");

            var action = $("input[name=Action]").val();

            if(action == 'AgentTicketEmail'){
                if(fromKanban[1] !== undefined){
                    var Form = $('#NewEmailTicket').serializeArray();
                    var FreeTextFormObject = {};
                    $('#submitRichText').attr('type', 'button');
    
                    $.each(Form,
                    function(i, v) {
                        FreeTextFormObject[v.name] = v.value;           
                    });
    
                    $.ajax({
                        cache: false,
                        url: "?Action=AgentTicketEmail;Subaction=StoreNew;",
                        data: FreeTextFormObject,
                        type: "POST",
                        success: function(data) {
                            window.close();
                            window.opener.location.reload();                                      
                        }
                    });
                }
            }else if(action == 'AgentTicketPhone'){ 
                if(fromKanban[1] !== undefined){
                    var Form = $('#NewPhoneTicket').serializeArray();
                    var FreeTextFormObject = {};
                    $('#submitRichText').attr('type', 'button');
    
                    $.each(Form,
                    function(i, v) {
                        FreeTextFormObject[v.name] = v.value;           
                    });
    
                    $.ajax({
                        cache: false,
                        url: "?Action=AgentTicketPhone;Subaction=StoreNew;",
                        data: FreeTextFormObject,
                        type: "POST",
                        success: function(data) {
                            window.close();
                            window.opener.location.reload();                                      
                        }
                    });
                }
            }
            
          
        });
    };
    
    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    
return TargetNS;
}(Core.Agent.Admin.PopUpShareKanban || {}));