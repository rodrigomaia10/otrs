// --
// var/httpd/htdocs/js/Core.Agent.FileSystem.js
// Copyright (C)  2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dparavani@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

Core.Agent.FileSystem = (function (TargetNS) {

    TargetNS.Init = function () {
        
        $(".DeleteFile").click(function(Event) {
            
            var link = $(this);

            Core.UI.Dialog.ShowContentDialog(
                Core.Language.Translate('Do you really want to delete this file?'),
                Core.Language.Translate('Attachment deletion'),
                '240px',
                'Center',
                true,
               [
                    {
                        Label: Core.Language.Translate('Yes'),
                        Class: 'Primary',
                        Function: function () {
                            window.location.href = link.attr('href');
                        }
                    },
                    {
                        Label: Core.Language.Translate('No'),
                        Class: 'Primary',
                        Function: function () {
                            Core.UI.Dialog.CloseDialog($('.Dialog'));
                            return false;
                        }
                    }                    
                ] 
            );

            Event.stopPropagation();
            Event.preventDefault();
            return false;
        }); 

    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.FileSystem || {}));