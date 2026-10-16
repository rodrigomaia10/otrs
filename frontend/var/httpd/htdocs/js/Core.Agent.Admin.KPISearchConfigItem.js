// --
// var/httpd/htdocs/js/Core.Agent.Admin.KPISearchConfigItem.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * nfreitas@beonup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.SearchConfigItem
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the search.
 */
Core.Agent.Admin.KPISearchConfigItem = (function (TargetNS) {
   
    if( $('#SearchClassID').val() !== ''){
        var Data = {
            "Action":"AdminKPIConfigItems",
            "Subaction":"AjaxUpdateToAttribute",
            "ClassID": $('#SearchClassID').val(),                              
        };
                                                
        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
           
            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{        
                
                $('#Attribute').html('');
                $('#SearchAttributesHidden').html('');
                    
                $.each(JSON.parse(Response.JSONString),function(key, value) {      
                    var opt = document.createElement('option');
                    opt.textContent = value;
                    opt.value = key;
                    $('#Attribute').append(opt);
                });
    
                if ($('#Attribute').hasClass('Modernize')) {
                    $("#Attribute").val('');
                    $('#Attribute').trigger('redraw.InputField');
                }

                $('#Attribute').after(Response.JSONStringAttribute);
                
            }
        });
    }

    // Search Attributes
    $('#SearchClassID').change(function() {
        var Data = {
            "Action":"AdminKPIConfigItems",
            "Subaction":"AjaxUpdateToAttribute",
            "ClassID": $('#SearchClassID').val(),                              
        };
                                                
        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{        
                  
                $('#Attribute').html('');
                $('#SearchAttributesHidden').html('');
                    
                $.each(JSON.parse(Response.JSONString),function(key, value) {      
                    var opt = document.createElement('option');
                    opt.textContent = value;
                    opt.value = key;
                    $('#Attribute').append(opt);
                });
    
                if ($('#Attribute').hasClass('Modernize')) {
                    $("#Attribute").val('');
                    $('#Attribute').trigger('redraw.InputField');
                }

                $('#Attribute').after(Response.JSONStringAttribute);
                
            }
        });
    });

    
    $('#Attribute').change(function() {
        
        var Attribute = $('#Attribute').val();
       
        TargetNS.SearchAttributeAdd($("#Attribute").val());
        // TargetNS.AdditionalAttributeSelectionRebuild();

        return false;
    });

     /**
     * @name AdditionalAttributeSelectionRebuild
     * @memberof Core.Agent.Search
     * @function
     * @returns {Boolean} Returns true.
     * @description
     *      This function rebuilds attribute selection, only show available attributes.
     */
    TargetNS.AdditionalAttributeSelectionRebuild = function () {
        // get original selection with all possible fields and clone it
        var $AttributeClone = $('#AttributeOrigKPI option').clone(),
            $AttributeSelection = $('#Attribute').empty();

        // strip all already used attributes
        $AttributeClone.each(function () {
            if (!$('#SearchInsertKPI label#Label' + $(this).attr('value')).length) {
                $AttributeSelection.append($(this));
            }
        });

        $AttributeSelection.trigger('redraw.InputField');

        return true;
    };

    /**
     * @name SearchAttributeRemove
     * @memberof Core.Agent.Search
     * @function
     * @param {jQueryObject} $Element - The jQuery object of the form or any element within this form check.
     * @description
     *      This function removes attributes from an element.
     */
    TargetNS.SearchAttributeRemove = function ($Element) {
        $Element.prev().remove();
        $Element.remove();
    };

    /**
     * @name SearchAttributeAdd
     * @memberof Core.Agent.Search
     * @function
     * @returns {Boolean} Returns false.
     * @param {String} Attribute - Name of attribute to add.
     * @description
     *      This function adds one attributes for search.
     */
    TargetNS.SearchAttributeAdd = function (Attribute) {
        var $Label = $('#SearchAttributesHidden label#Label' + Attribute);

        if ($Label.length) {
            $Label.prev().clone().appendTo('#SearchInsertKPI');
            $Label.clone().appendTo('#SearchInsertKPI');

			var $CloneElement = $Label.next().clone();
            $CloneElement.appendTo('#SearchInsertKPI')
                // bind click function to remove button now
                .find('.RemoveButton').bind('click', function () {
                    var $Element = $(this).parent();
					TargetNS.SearchAttributeRemove($Element);

                    // rebuild selection
                    // TargetNS.AdditionalAttributeSelectionRebuild();

                    return false;
                });

			// $('#SearchInsertKPI').append('<div class="Clear"></div>')
			var $Input = $CloneElement.find('input');

			// $Input.each(function(){
			// 	var name = $(this).attr('name');

			// 	$(this).attr('name', name + 'Valid');
			// });

			// var $Select = $CloneElement.find('select');

			// $Select.each(function(){
			// 	var name = $(this).attr('name');

			// 	$(this).attr('name', name + 'Valid');
			// 	$(this).attr('id', name + 'Valid');
			// });

            // Register event for tree selection dialog
            Core.UI.TreeSelection.InitTreeSelection();

            // Modernize fields
            Core.UI.InputFields.Activate($('#SearchInsertKPI'));

            // Initially display dynamic fields with TreeMode = 1 correctly
            Core.UI.TreeSelection.InitDynamicFieldTreeViewRestore();
        }
		//event.preventDefault();
        return false;
    };

    


    
    return TargetNS;
    
}(Core.Agent.Admin.KPISearchConfigItem || {}));


