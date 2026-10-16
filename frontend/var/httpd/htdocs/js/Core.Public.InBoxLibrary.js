 // --
// var/httpd/htdocs/js/Core.Public.InBoxLibrary.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * mbernardo@serviceup.com.br
// --


"use strict";

var Core = Core || {};
Core.Public = Core.Public || {};

/**
 * @namespace Core.Public.InBoxLibrary
 * @memberof Core
 * @author Service Up
 * @description
 *      This namespace contains the special module functions for the InBoxLibrary module.
 */
Core.Public.InBoxLibrary = (function (TargetNS) {

    /**
     * @name Init
     * @memberof Core.Public.InBoxLibrary
     * @function
     * @description
     *      This function initializes the module functionality.
     */


    TargetNS.ConfigGet = function (Config, Callback ) {

        var Data = {
            Action: 'ConfigGetAJAXHandler',
            Subaction: 'Get',
            Config: Config
        };
		
        Core.AJAX.FunctionCall( Core.Config.Get('CGIHandle'), Data, function (Result) {
            Callback(Result);
        });
    };

   Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

   return TargetNS;
}(Core.Public.InBoxLibrary || {}));