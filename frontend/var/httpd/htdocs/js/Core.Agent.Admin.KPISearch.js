// --
// var/httpd/htdocs/js/Core.Agent.Admin.KPISearch.js
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

/**
 * @namespace Core.Agent.Search
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the search.
 */
Core.Agent.Admin.KPISearch = (function (TargetNS) {


	/**
     * @name AdditionalAttributeSelectionRebuild
     * @memberof Core.Agent.Search
     * @function
     * @returns {Boolean} Returns true.
     * @description
     *      This function rebuilds attribute selection, only show available attributes.
     */
    TargetNS.Init = function () {
        var $ValidFilters = $("#SearchAttributesHiddenKPI").find('.ValidFilter');

		$ValidFilters.each(function () {
			var $Select = $(this).find('select');
			var $Input = $(this).find('input');
          
			TargetNS.SearchAttributeAdd($(this).parent().parent().attr('id'));

			TargetNS.AdditionalAttributeSelectionRebuild();

        });

        return true;
    };

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
            $AttributeSelection = $('#AttributeKPI').empty();

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
     * @name SearchAttributeAdd
     * @memberof Core.Agent.Search
     * @function
     * @returns {Boolean} Returns false.
     * @param {String} Attribute - Name of attribute to add.
     * @description
     *      This function adds one attributes for search.
     */
    TargetNS.SearchAttributeAdd = function (Attribute) {
        var $Label = $('#SearchAttributesHiddenKPI label#Label' + Attribute);
        
        if ($Label.length) {
            
            $Label.prev().clone().appendTo('#SearchInsertKPI');
            $Label.clone().appendTo('#SearchInsertKPI');

			var $CloneElement = $Label.next().clone();
            $CloneElement.appendTo('#SearchInsertKPI')
                // bind click function to remove button now
                .find('.RemoveButton').bind('click', function () {
                    var $Element = $(this).parent().parent();

					TargetNS.SearchAttributeRemove($Element);

                    // rebuild selection
                    TargetNS.AdditionalAttributeSelectionRebuild();

                    return false;
                }); 

			// $('#SearchInsertKPI').append('<div class="Clear"></div>')
			var $Input = $CloneElement.find('input');

			$Input.each(function(){
				var name = $(this).attr('name');

				$(this).attr('name', name + 'Valid');
			});

			var $Select = $CloneElement.find('select');

			$Select.each(function(){
				var name = $(this).attr('name');

				$(this).attr('name', name + 'Valid');
				$(this).attr('id', name + 'Valid');
			});

            // Register event for tree selection dialog
            Core.UI.TreeSelection.InitTreeSelection();

            // Modernize fields
            Core.UI.InputFields.Activate($('#SearchInsertKPI'));

            // Initially display dynamic fields with TreeMode = 1 correctly
            Core.UI.TreeSelection.InitDynamicFieldTreeViewRestore();

            // To Show or hide Min/Max SLA range values
            $('#SLARangeValid').on('change', function () {
                if( $('#SLARangeValid').val() == 'Personalize'){
                    $('#MinMaxSLARange').removeClass('Hidden');
                    $('#SearchInsertKPI').css('margin-bottom', '0');
                }else{
                    $('#MinMaxSLARange').addClass('Hidden');
                    $('#SearchInsertKPI').css('margin-bottom', '15px');

                }
            });

            // To Show or hide Min/Max First Reply SLA Interval values
            $('#FirstResponseRangeValid').on('change', function () {
                if( $('#FirstResponseRangeValid').val() == 'Personalize'){
                    $('#MinMaxFirstResponseRange').removeClass('Hidden');
                    $('#SearchInsertKPI').css('margin-bottom', '0');
                }else{
                    $('#MinMaxFirstResponseRange').addClass('Hidden');
                    $('#SearchInsertKPI').css('margin-bottom', '15px');
                }
            });

            // To Show or hide Min/Max SLA range values
            if( $('#SLARangeValid').val() == 'Personalize'){
                $('#MinMaxSLARange').removeClass('Hidden');
                $('#SearchInsertKPI').css('margin-bottom', '0');
            }else{
                $('#MinMaxSLARange').addClass('Hidden');
                $('#SearchInsertKPI').css('margin-bottom', '15px');
            
            }
            
            // To Show or hide Min/Max First Reply SLA Interval values
            if( $('#FirstResponseRangeValid').val() == 'Personalize'){
                $('#MinMaxFirstResponseRange').removeClass('Hidden');
                $('#SearchInsertKPI').css('margin-bottom', '0');
            }else{
                $('#MinMaxFirstResponseRange').addClass('Hidden');
                $('#SearchInsertKPI').css('margin-bottom', '15px');
            }
        }
		//event.preventDefault();
        return false;
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
    TargetNS.RuleAttributeAdd = function () {
		var Rules = parseInt( $("#TotalRules").val() );
		Rules++;
		$("#TotalRules").val( Rules );

        var $Element = $('.RuleTemplate');

        if ($Element.length) {
            var $CloneElement = $Element.clone();
			$CloneElement.removeClass('Hidden');
			$CloneElement.removeClass('RuleTemplate');
			$CloneElement.addClass('Rule' + Rules );

			var $CloneLabel = $Element.prev().clone().appendTo('#ViewSettingsKPI');
			$CloneLabel.removeClass('RuleLabelTemplate');
			$CloneLabel.removeClass('Hidden');

			$CloneLabel.appendTo('#ViewSettingsKPI');
			$CloneElement.appendTo('#ViewSettingsKPI')
				.find('.RemoveRule').bind('click', function () {
                    var $Element = $(this).parent();
					TargetNS.RuleAttributeRemove($Element);
                    return false;
                });;
		}

		// event.preventDefault();
        return false;
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

        if ( $Element.prev().attr('id') == 'LabelSLARange' ) {
            $('#SLARangeMinValue').val('');
            $('#SLARangeMaxValue').val('');
            $('#MinMaxSLARange').addClass('Hidden');
        }

        if ( $Element.prev().attr('id') == 'LabelFirstResponseRange' ) {
            $('#FirstResponseRangeMinValue').val('');
            $('#FirstResponseRangeMaxValue').val('');
            $('#MinMaxFirstResponseRange').addClass('Hidden');
        }

        $Element.prev().remove();
        $Element.remove();

    };

	 /**
     * @name SearchAttributeRemove
     * @memberof Core.Agent.Search
     * @function
     * @param {jQueryObject} $Element - The jQuery object of the form or any element within this form check.
     * @description
     *      This function removes attributes from an element.
     */
    TargetNS.RuleAttributeRemove = function ($Element) {
        $Element.prev().remove();
        $Element.remove();
    };

    return TargetNS;
}(Core.Agent.Admin.KPISearch || {}));
