// --
// var/httpd/htdocs/js/Core.Agent.Admin.KPI.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * pdias@beonup.com.br
// * dsilva@beonup.com.br
// * gtiburtino@beonup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.KPI
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the KPI module.
 */
Core.Agent.Admin.KPI = (function (TargetNS) {

    /**
     * @private
     * @name SerializeData
     * @memberof Core.Agent.Admin.KPI
     * @function
     * @returns {String} query string of the data
     * @param {Object} Data - The data that should be converted.
     * @description
     *      Converts a given hash into a query string.
     */
    function SerializeData(Data) {
        var QueryString = '';
        $.each(Data, function (Key, Value) {
            QueryString += ';' + encodeURIComponent(Key) + '=' + encodeURIComponent(Value);
        });
        return QueryString;
    }

    /**
     * @name Redirect
     * @memberof Core.Agent.Admin.KPI
     * @function
     * @param {String} FieldType - Type of DynamicField.
     * @param {String} ObjectType
     * @description
     *      Redirect to URL based on DynamicField config.
     */
    TargetNS.Redirect = function(ObjectType) {
        var URL;

        // redirect to correct url
        URL = Core.Config.Get('Baselink') + 'Action=AdminKPI'+ ObjectType +';Subaction=Add';
        URL += SerializeData(Core.App.GetSessionInformation());
        window.location = URL;
    };

    /**
     * @name KPIAddAction
     * @memberof Core.Agent.Admin.KPI
     * @function
     * @description
     *      Bind event on dynamic field add action field.
     */
    TargetNS.KPIAddAction = function () {

        $('#KPISelect').on('change', function() {
            if ($(this).val() !== null && $(this).val() !== '') {
                Core.Agent.Admin.KPI.Redirect($(this).val());

                // reset select value to none
                $(this).val('');
            }
        });
    };

    /**
     * @name ShowContextSettingsDialog
     * @memberof Core.Agent.Admin.KPI
     * @function
     * @description
     *      Bind event on Setting button.
     */
    TargetNS.ShowContextSettingsDialog = function() {
        $('#ShowContextSettingsDialog').on('click', function (Event) {
            Core.UI.Dialog.ShowContentDialog($('#ContextSettingsDialogContainer'), Core.Language.Translate("Settings"), '20%', 'Center', true,
                [
                    {
                        Label: Core.Language.Translate("Save"),
                        Type: 'Submit',
                        Class: 'Primary'}
                ]);
            Event.preventDefault();
            Event.stopPropagation();
            return false;
        });
    }

    /**
     * @name KPIDelete
     * @memberof Core.Agent.Admin.KPI
     * @function
     * @description
     *      Bind event on dynamic field delete button.
     */
    TargetNS.KPIDelete = function() {
        $('.KPIDelete').on('click', function (Event) {

            if (window.confirm(Core.Language.Translate("Do you really want to delete this KPI? ALL associated data will be LOST!"))) {

                Core.UI.Dialog.ShowDialog({
                    Title: Core.Language.Translate("Delete KPI"),
                    HTML: Core.Language.Translate("Deleting the field and its data. This may take a while..."),
                    Modal: true,
                    CloseOnClickOutside: false,
                    CloseOnEscape: false,
                    PositionTop: '20%',
                    PositionLeft: 'Center',
                    Buttons: []
                });

                Core.AJAX.FunctionCall(
                    Core.Config.Get('Baselink'),
                    $(this).data('query-string') + 'Confirmed=1;',
                    function() {
                        window.location.reload();
                    }
                );
            }

            // don't interfere with MasterAction
            Event.stopPropagation();
            Event.preventDefault();
            return false;
        });
    };

      /**
     * @name KPICopy
     * @memberof Core.Agent.Admin.KPI
     * @function
     * @description
     *      Bind event on copy button.
     */
    TargetNS.KPICopy = function() {
        $('.KPICopy').on('click', function (Event) {

            Core.AJAX.FunctionCall(
                Core.Config.Get('Baselink'),
                $(this).data('query-string'),
                function() {
                    window.location.reload();
                }
            );
            

            // don't interfere with MasterAction
            Event.stopPropagation();
            Event.preventDefault();
            return false;
        });
    };

  
    /**
     * @name Init
     * @memberof Core.Agent.Admin.KPI
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        // Initialize JS functions
        TargetNS.KPIAddAction();
        TargetNS.ShowContextSettingsDialog();
        TargetNS.KPIDelete();
        TargetNS.KPICopy();

        // Initialize dynamic field filter
        Core.UI.Table.InitTableFilter($('#FilterKPIs'), $('#KPIsTable'));

    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.KPI || {}));
