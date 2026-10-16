// --
// var/httpd/htdocs/js/Core.Agent.Admin.PopUpTicketNote.js
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
 * @namespace Core.Agent.Admin.PopUpTicketNote
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the Kanban Boards module.
 */
Core.Agent.Admin.PopUpTicketNote = (function (TargetNS) {
    /** 
     * @name Init
     * @memberof Core.Agent.Admin.PopUpTicketNote
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {
        $('#submitRichText').on('click', function () {           
            var url = window.location.href;
            var fromKanban = url.split("OpenBy=");
          
            if(fromKanban[1] !== undefined) {
                var Form = $('#Compose').serializeArray();             
                var FreeTextFormObject = {};
                $('#submitRichText').attr('type', 'button');

                $.each(Form,
                function(i, v) {

                    if ( v.name == 'Body' ) {
                        FreeTextFormObject[v.name] = CKEDITOR.instances['RichText'].getData()
                    }
                    else {
                        FreeTextFormObject[v.name] = v.value;           
                    }
                });

                $.ajax({
                    cache: false,
                    url: "?Action=AgentTicketNote;Subaction=Store;",
                    data: FreeTextFormObject,
                    type: "POST",
                    success: function(data) {
                        window.close();
                        window.opener.location.reload();                                      
                    }
                });
            }
          
        });
    };
    
    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    
return TargetNS;
}(Core.Agent.Admin.PopUpTicketNote || {}));