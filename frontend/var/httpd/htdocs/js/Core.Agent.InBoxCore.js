// --
// var/httpd/htdocs/js/Core.Agent.InBoxCore.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// * dparavani@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Agent.InBoxCore
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for InBox Core module.
 */
 Core.Agent.InBoxCore = (function (TargetNS) {

     /**
      * @name Init
      * @memberof Core.Agent.InBoxCore
      * @function
      * @description
      *      This function initializes the module functionality.
      */
    TargetNS.Init = function () {

        var browser = GetBrowser();

        const queryString = window.location.search;

        let ActionURL;

        const urlParams = function(name){
            var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
            if (results == null){
               return null;
            }
            else {
               return decodeURI(results[1]) || 0;
            }
        }
            
        ActionURL =  urlParams('Action') || '';

        const formExist =  $('form').attr('action');

        if ( formExist !== undefined ) {
            const interface = $('form').attr('action').split('/')[$('form').attr('action').split('/').length - 1].split('.')[0];
            
            var Action;
            if( interface == 'index') {
                Action = $('form').children('input[name=Action]').val() || ActionURL.split(';')[0];
            }
            else {
                Action = $('form').children('input[name=Action]').val() || ActionURL.split(';')[0];
            }
        }
        else {
            Action = ActionURL.split(';')[0];
        }
                
        if ( Action == "Login" ) {

            if ( browser.name === 'IE' ) {

                let message = '<div class="ErrorBox">' +
                                '<span>' + 
                                    Core.Language.Translate('The browser version used is no longer supported by the system and the browser developer. Some features may not work correctly.') + ' ' +
                                    '<a target="_blank" href="https://docs.microsoft.com/en-us/lifecycle/announcements/internet-explorer-11-support-end-dates">' + Core.Language.Translate("Developer's Note.") + '</a>' +
                                '</span>' +
                            '</div>';

                if ( $('#LoginBox').length > 0 ) {

                    $('#LoginBox').prepend(message);
                    $('#LoginButton').attr('type', 'input');
                }
                else {     

                    $('#MainBox').prepend(message);
                    $('form button').attr('type', 'input');                            
                }

            }

            return;
        }    
        else {

            Core.InBoxLibrary.ConfigGet("Core::BrowserErrorMessage", function (Result) {                                
                if( Result.Data == 1 ) {
    
                    if ( browser.name === 'IE' ) {
                        
                        let message = '<div class="MessageBox Error">' +
                            '<p>'+
                                    Core.Language.Translate('The browser version used is no longer supported by the system and the browser developer. Some features may not work correctly.') + ' ' +
                                    '<a target="_blank" href="https://docs.microsoft.com/en-us/lifecycle/announcements/internet-explorer-11-support-end-dates">' + Core.Language.Translate("Developer's Note.") + '</a>' +
                            '</p>' + 
                        '</div>';       
                        
                        let regex = /\Customer\w+/g;
                        
                        if ( regex.test(Action) ) {
    
                            $('#Navigation').after(message);
                        }
                        else {
    
                            $('#NavigationContainer').after(message);   
                        }

                    }
                }
            });
        }
    };   

    function GetBrowser() {
        var ua = navigator.userAgent,tem,M=ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || []; 
        if (/trident/i.test(M[1])) {
            tem = /\brv[ :]+(\d+)/g.exec(ua) || []; 
            return { name:'IE',version:(tem[1]||'') };
        }   
        if ( M[1]==='Chrome' ) {
            tem = ua.match(/\bOPR\/(\d+)/)
            if (tem!=null) {
                return {name:'Opera', version:tem[1]};
            }
        }   
        M=M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
        if ( (tem=ua.match(/version\/(\d+)/i) ) !=null ) {
            M.splice(1,1,tem[1] ); 
        }
        return {
          name: M[0],
          version: M[1]
        };
    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.InBoxCore || {}));
