// --
// Copyright (C) 2019 OTRS AG, https://otrs.com/
// Copyright (C) 2019 Znuny GmbH, https://znuny.org/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (GPL). If you
// did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.GenericInterfaceTestXSLT
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the GenericInterface invoker module.
 */
Core.Agent.Admin.GenericInterfaceTestXSLT = (function (TargetNS) {

    TargetNS.Init = function () {

        $('#SendTest').on('click', function() {
            
            var Data = {
                Action: 'AdminGenericInterfaceMappingXSLT',
                Subaction: 'TestMapping',
                TicketNumber: $("#TestTicket").val(),
                JSON: $("#TestJSON").val(),
                WebserviceID: $("input[name='WebserviceID']").val(),
                CommunicationType: $("input[name='CommunicationType']").val(),
                Operation: $("input[name='Operation']").val(),
                Invoker: $("input[name='Invoker']").val(),
                Direction: $("input[name='Direction']").val()
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {

                var pretty = JSON.stringify(Result, undefined, 4);

                $("#TemplateTest").val(pretty)
            });
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.GenericInterfaceTestXSLT || {}));
