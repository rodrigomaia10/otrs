// --
// var/http/htdocs/js/Core.Customer.CustomerPortalSurvey.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};

/**
 * @namespace Core.Customer.CustomerPortalSurvey
 * @memberof Core.Customer
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for CustomerPortal module.
 */
Core.Customer.CustomerPortalSurvey = (function (TargetNS) {

    /**
    * @name Init
    * @memberof Core.Customer.CustomerPortalSurvey
    * @function
    * @description
    *      This function initializes the module functionality.
    */
    TargetNS.Init = function () {

        $('a.AsPopup').on('click', function () {
            Core.UI.Popup.OpenPopup($(this).attr('href'), 'SurveyAction');
            return false;
        });

    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CustomerPortalSurvey || {}));


