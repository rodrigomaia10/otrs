// --
// var/httpd/htdocs/js/Core.Agent.Admin.InBoxCore.js
// Copyright (C) 2019 ServiceUp, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.InBoxCore
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for ConsumptionHoursCustomer module.
 */
 Core.Agent.Admin.InBoxCore = (function (TargetNS) {

     /**
      * @name Init
      * @memberof Core.Agent.Admin.InBoxCore
      * @function
      * @description
      *      This function initializes the module functionality.
      */
    TargetNS.Init = function () {

        $("[name='GetRepositoryList']").attr("type", "button");
        $("[name='GetRepositoryList']").click(function() {
            
            var regex = new RegExp(/^(?:(?:https?|s?ftp))/i);

            if ( !regex.test( $('#Source').val() ) ) {

                TargetNS.ShowInBoxRequiredDialog();
                return false;
            }
            else{
                $('#Source').parent().submit();
            }

        });        
    };

    /**
     * @name ShowInBoxRequiredDialog
     * @memberof Core.Agent
     * @function
     * @description
     *      This function shows InBox upgrade dialog.
     */
    TargetNS.ShowInBoxRequiredDialog = function() {
        var InBoxLabel = '<strong>InBox ServiceUp Premium</strong>';

        Core.UI.Dialog.ShowContentDialog(
            '<div class="InBoxRequiredDialogLogo"></div><div class="InBoxRequiredDialog">' + Core.Language.Translate('This feature is part of the %s. Please contact us at %s for an upgrade.', InBoxLabel, 'comercial@serviceup.com.br') + '<a class="Hidden" href="https://otrsinbox.cloud/" target="_blank"><span></span></a></div>',
            '',
            '240px',
            'Center',
            true,
            [
                {
                    Label: Core.Language.Translate('Find out more'),
                    Class: 'Primary',
                    Function: function () {
                        $('.InBoxRequiredDialog').find('a span').trigger('click');
                    }
                }
            ]
        );
    };


    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.InBoxCore || {}));
