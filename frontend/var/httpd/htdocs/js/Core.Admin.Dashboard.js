// --
// var/httpd/htdocs/js/Core.Admin.Dashboard.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dparavani@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Admin = Core.Admin || {};

/**
 * @namespace Core.Admin.Dashboard
 * @memberof Core.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the KPI module.
 */
 Core.Admin.Dashboard = (function (TargetNS) {
    /**
     * @name Init
     * @memberof Core.Admin.Dashboard
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        Core.UI.Table.InitTableFilter($('#Filter'), $('#Dashboards'));

        if ( $('#AvailableInterface').val('AgentInterface')) {
            $('#AlertMessageGroup').show();
        }

        $('#AvailableInterface').on('change', function() {

            if ( $(this).val() == 'AgentInterface' ) {
                $('#GroupIDs').parent().prev().show();
                $('#GroupIDs').parent().show();
                $('#GroupIDs').addClass('Validate_Required');
                $('#AlertMessageGroup').show();
                Core.UI.InputFields.InitSelect( $('#GroupIDs') );

                $('#CustomerID').val('');
                $('#CustomerID').parent().prev().hide();
                $('#CustomerID').parent().hide();
                $('#CustomerID').removeClass('Validate_Required');
            }

            else if ( $(this).val() == 'CustomerInterface' ) {
                $('#CustomerID').parent().prev().show();
                $('#CustomerID').parent().show();
                $('#CustomerID').addClass('Validate_Required');
                Core.UI.InputFields.InitSelect( $('#CustomerID') );

                $('#GroupIDs').val('');
                $('#GroupIDs').parent().prev().hide();
                $('#GroupIDs').parent().hide();
                $('#GroupIDs').removeClass('Validate_Required');
                $('#AlertMessageGroup').hide();
            }

            else if ( $(this).val() == '' ) {
                $('#CustomerID').val('');
                $('#CustomerID').parent().prev().hide();
                $('#CustomerID').parent().hide();
                $('#CustomerID').removeClass('Validate_Required');

                $('#GroupIDs').val('');
                $('#GroupIDs').parent().prev().hide();
                $('#GroupIDs').parent().hide();
                $('#GroupIDs').removeClass('Validate_Required');
                $('#AlertMessageGroup').hide();
            }

            else {
                $('#GroupIDs').parent().prev().show();
                $('#GroupIDs').parent().show();
                $('#GroupIDs').addClass('Validate_Required');
                $('#AlertMessageGroup').show();
                Core.UI.InputFields.InitSelect( $('#GroupIDs') );

                $('#CustomerID').parent().prev().show();
                $('#CustomerID').parent().show();
                $('#CustomerID').addClass('Validate_Required');
                Core.UI.InputFields.InitSelect( $('#CustomerID') );
            }
            
        });



    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;

}(Core.Admin.Dashboard || {}));