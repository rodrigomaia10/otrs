// --
// var/httpd/htdocs/js/Core.Agent.Admin.CustomerPortalService.js
// Copyright (C)  2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.CustomerPortalService
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for ConsumptionHoursCustomer module.
 */
Core.Agent.Admin.CustomerPortalService = (function (TargetNS) {

    var RemoveButtonHTML = '<a href="#" title="'
        + Core.Language.Translate('Remove this dynamic field')
        + '" class="RemoveButton SpacingLeft"><i class="fa fa-minus-square-o"></i><span class="InvisibleText">'
        + Core.Language.Translate('Remove') + '</span></a>';

    var Count = 1;
    var elems = [];

    TargetNS.Init = function () {

        $('#AddDynamicFields, #AddNewDynamicFields').on('change', function () {
            var Widget = $(this).closest('div.Field').data('widget');

            if (Widget === 'Select' || Widget === 'Update') {
                TargetNS.InsertDynamicField(Widget, $(this).val());
            }
        });

        // On page load, add remove button and init its click event.
        $('#SelectedDynamicFields, #SelectedNewDynamicFields').find('div.Field').each(function() {
            var AddFieldsID;

            if ($(this).closest('#SelectedDynamicFields').length) {
                AddFieldsID = 'AddDynamicFields';
            }
            else {
                AddFieldsID = 'AddNewDynamicFields';
            }

            $(this).append(RemoveButtonHTML);
            TargetNS.InitRemoveButtonEvent($(this).find('.RemoveButton'), AddFieldsID);
        });


        var DynamicFieldsValueJS = Core.Config.Get('DynamicFieldsValueJS');

        $.each(DynamicFieldsValueJS, function( index, value ) {
            TargetNS.InsertDynamicField("Update", "DynamicField_" + value.DynamicFieldName, value.ValueDF, value.ValueMacro );
        });        
    };


    TargetNS.InsertDynamicField = function (Widget, Value, ValueDF, ValueMacro) {

        var Data,
            AddFieldsID,
            SelectedFieldsID,
            DynamicFieldsJS = Core.Config.Get('DynamicFieldsJS');

        if (!Value) {
            return;
        }

        Data = {
            Action: 'ServiceMacroAJAXHandler',
            Subaction: 'AddDynamicField',
            DynamicFieldID: DynamicFieldsJS[Value].ID,
            SelectedValue: Value,
            Widget: Widget,
            ValueDF: ValueDF,
            ValueMacro: ValueMacro
        };

        if (Widget === 'Select') {
            Data.Type = DynamicFieldsJS[Value].Type
            AddFieldsID = 'AddDynamicFields';
            SelectedFieldsID = 'SelectedDynamicFields';
        }
        else if (Widget === 'Update') {
            AddFieldsID = 'AddNewDynamicFields';
            SelectedFieldsID = 'SelectedNewDynamicFields';
        }

        // Get field HTML by AJAX.
        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (Response) {

                var MacroHTML = Response.FieldMacro;
                var FieldHTML = Response.Label + '<div class="Field" data-id="' + Response.ID +'">' + Response.Field + '→' + MacroHTML + RemoveButtonHTML + '</div><div class="Clear"></div>';
                var DynamicFieldName = Response.DynamicFieldName;


                FieldHTML = FieldHTML.replace( new RegExp(DynamicFieldName, "g"), DynamicFieldName + '_' + Count);
                FieldHTML = FieldHTML.replace( new RegExp("MacroName", "g"), "MacroName" + '_' + Count);


                Response.ID = Response.ID + "_" + Count;

                Value = Value + "_" + Count;

                elems.push(Value);

                $("#ServiceMacro").val(JSON.stringify(elems));

                // Append field HTML from response to selected fields area.
                $('#' + SelectedFieldsID).append(FieldHTML);
                TargetNS.InitRemoveButtonEvent($('div.Field[data-id="' + Response.ID + '"]').find('.RemoveButton'), AddFieldsID);

                // Remove the field from add fields dropdown and redraw this dropdown.
                $('#' + AddFieldsID).val('').trigger('redraw.InputField').trigger('change');

                // Modernize field if there is select element.
                if ($('#' + Value).closest('div.Field').find('select.Modernize').length) {
                    Core.UI.InputFields.Activate($('#' + Value).closest('div.Field'));
                }

                // Register event for tree selection dialog
                $('.ShowTreeSelection').off('click').on('click', function () {
                    Core.UI.TreeSelection.ShowTreeSelection($(this));
                    return false;
                });

                // Trigger dynamic field event initialization (needed for specific fields from packages).
                Core.App.Publish('Event.DynamicField.Init', [Response.ID]);

                Count++;

                return false;

            }, 'json'
        );
    };

    function removeArray(arr) {
        var what, a = arguments, L = a.length, ax;
        while (L > 1 && arr.length) {
            what = a[--L];
            while ((ax= arr.indexOf(what)) !== -1) {
                arr.splice(ax, 1);
            }
        }
        return arr;
    }

    TargetNS.InitRemoveButtonEvent = function ($Element, AddFieldsID) {

        $Element.off('click').on('click', function(Event) {
            var Value = $(this).closest('div.Field').data('id'),
                Options,
                OptionObjects = [];

            removeArray(elems, Value);

            $("#ServiceMacro").val(JSON.stringify(elems));
                     
            // Remove a label, div.Clear and div.Field elements from selected fields area.
            $(this).closest('div.Field').prev('label').remove();
            $(this).closest('div.Field').next('div.Clear').remove();
            $(this).closest('div.Field').remove();

            Event.stopPropagation();
            Event.preventDefault();
            return false;
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.CustomerPortalService || {}));
