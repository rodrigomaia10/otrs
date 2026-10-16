// --
// var/httpd/htdocs/js/Core.Agent.Admin.ServiceTemplate.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.ServiceTemplate
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for AdminServiceTemplate module.
 */
 Core.Agent.Admin.ServiceTemplate = (function (TargetNS) {

    /*
    * @name Init
    * @memberof Core.Agent.Admin.ServiceTemplate
    * @function
    * @description
    *      This function initializes table filter.
    */
    TargetNS.Init = function () {
        Core.UI.Table.InitTableFilter($('#FilterTemplates'), $('#Templates'));
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.ServiceTemplate || {}));
