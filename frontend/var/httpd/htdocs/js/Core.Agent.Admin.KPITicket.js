// --
// var/httpd/htdocs/js/Core.Agent.Admin.KPITicket.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * pdias@beonup.com.br
// * dsilva@beonup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.KPITicket.KPI
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the KPI Ticket module.
 */
Core.Agent.Admin.KPITicket = (function (TargetNS) {

    /**
     * @name Init
     * @memberof Core.Agent.Admin.KPITicket
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        Core.Agent.Admin.KPISearch.Init();

        $('#AttributeKPI').on('change', function () {
            // var Attribute = $('#Attribute').val();
            Core.Agent.Admin.KPISearch.SearchAttributeAdd($("#AttributeKPI").val());
            Core.Agent.Admin.KPISearch.AdditionalAttributeSelectionRebuild();

            return false;
        });

    	$(".AddRule").click(function(){
            Core.Agent.Admin.KPISearch.RuleAttributeAdd();
        });


        // To Show or hide Numeric KPI configurtarions
        $('#TypeKPI').on('change', function () {
            if( $('#TypeKPI').val() == 'Numeric'){
                $('#ViewSettingsKPI').addClass('Hidden');
            }else{
                $('#ViewSettingsKPI').removeClass('Hidden');
            }

        });
        
        // To Show or hide Numeric KPI configurtarions
        if( $('#TypeKPI').val() == 'Numeric'){
            $('#ViewSettingsKPI').addClass('Hidden');
        }else{
            $('#ViewSettingsKPI').removeClass('Hidden');
        }
        
        if($('#ReturnFormat').val() == 'Link'){
            $('#LabelToLink').show();
            $('#Link').show();
        }else{
            $('#LabelToLink').hide();
            $('#Link').hide();
        }

        $('#ReturnFormat').change(function() {
          
            if($('#ReturnFormat').val() == 'Link'){
                $('#LabelToLink').show();
                $('#Link').show();
            }else{
                $('#LabelToLink').hide();
                $('#Link').hide();
                $('#Link').val('');
            }
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.KPITicket || {}));
