// --
// var/httpd/htdocs/js/Core.InBoxLibrary.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// --

"use strict";

var Core = Core || {};

/**
 * @namespace Core.InBoxLibrary
 * @memberof Core
 * @author Service Up
 * @description
 *      This namespace contains the special module functions for the InBoxLibrary module.
 */
Core.InBoxLibrary = (function (TargetNS) {

    /**
     * @private
     * @name ConfigGet
     * @memberof Core.InBoxLibrary
     * @function
     * @param {Function} Callback
     * @description
     *      Get system settingss.
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

    return TargetNS;
}(Core.InBoxLibrary || {}));
