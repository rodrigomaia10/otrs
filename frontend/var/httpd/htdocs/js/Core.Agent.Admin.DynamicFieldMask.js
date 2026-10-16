// --
// var/httpd/htdocs/js/Core.Agent.Admin.DynamicFieldMask.js
// Copyright (C) 2019 Service Up, http://serviceup.com.br/
//
// written/edited by:
// * pdias@beonup.com.br
// * gtiburtino@beonup.com.br
// * mtatangelo@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.DynamicFieldMask
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the DynamicFieldTable module.
 */
Core.Agent.Admin.DynamicFieldMask = (function (TargetNS) {

    /**
     * @name Init
     * @memberof Core.Agent.Admin.DynamicFieldMask
     * @function
     * @returns {Void} Returns void
     * @param {String} None.
     * @description
     *      This function initialize all the jquery functions to hid/show the field respective to
     *      the selected mask type
     */
    TargetNS.Init = function (){

		$("#Mask, #Monetary").addClass("Hidden");

		if ( $("#MaskType").val() == 'Mask' ){
			$("#Mask").removeClass("Hidden");
		}
		else if ( $("#MaskType").val() == 'Monetary' ){
			$("#Monetary").removeClass("Hidden");
		}

		$("#MaskType").bind('change', function(){
			var $Div = $("#" + $(this).val());
			if ( $(this).val() == 'Mask' ){
				$("#Monetary").addClass("Hidden");
			}
			else{
				$("#Mask").addClass("Hidden");
			}
			$Div.removeClass('Hidden');
		});
    };

    return TargetNS;
}(Core.Agent.Admin.DynamicFieldMask || {}));
