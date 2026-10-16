// --
// var/httpd/htdocs/js/Core.Agent.Admin.DynamicFieldTable.js - a module used to handle ajax requests
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// * mbernardo@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.UI = Core.UI || {};
Core.Agent.Admin = Core.Agent.Admin || {};

Core.Agent.Admin.DynamicFieldTable = (function (TargetNS) {

    TargetNS.RemoveValue = function (IDSelector){

        var $Clone = $('.DeletedValue').clone(),            // copy HTML code for an input replacement for the deleted value
            $ObjectIndex = IDSelector.match(/.+_(\d+)/)[1], // get the index of the value to delete (its always the second element (1) in this RegEx
            $Key = $('#Key_' + $ObjectIndex).val(),         // get the key name to remove it from the defaults select
            $MaskItem = $('#Column_' + $ObjectIndex).val(),
            Type = $('#TypeColumn_' + $ObjectIndex).val();

        $('.DataItem_' + $MaskItem).remove();

        // set the input replacement attributes to match the deleted original value
        // new value and other controls are not needed anymore
        $Clone.attr('id', 'Key' + '_' + $ObjectIndex);
        $Clone.attr('name', 'Key' + '_' + $ObjectIndex);
        $Clone.removeClass('DeletedValue');

        // add the input replacement to the mapping type so it can be parsed and distinguish from
        // empty values by the server
        $('#' + IDSelector).closest('fieldset').append($Clone);

        // remove the value from default list
        if ($Key !== ''){
            $('#DefaultValue').find("option[value='" + $Key + "']").remove();
            $('#DefaultValue').trigger('redraw.InputField');
        }

        // remove possible value
        $('#' + IDSelector).parent().remove();

        if (Type == 'maskMoney' || Type == 'number'){
            Core.Agent.Admin.DynamicFieldTable.OperationColumn();
        }
        return false;
    };

    TargetNS.Init = function () {
        var Data;  
       
        $('#AddValue').bind('click', function () {

            // clone key dialog
            var ValueCounter = $('#ValueCounter').val();
            var UpdatedDiv =  $('#AjaxColumn_' + ValueCounter);

            // increment key counter
            ValueCounter++;

            $('#ValueCounter').val(ValueCounter);

            Data = {
                Action: 'AdminDynamicFieldTable',
                Subaction: 'NewColumnAJAX',
                ValueCounter: ValueCounter,
            };

            if (ValueCounter) {

                // get new content
                Core.AJAX.FunctionCall( Core.Config.Get('CGIHandle'), Data, function (Response) {

                    var $ElementToUpdate = UpdatedDiv;
                    var JavaScriptString = '';
                    var ErrorMessage;

                    if (!Response) {

                        // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                        Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No content received.", 'CommunicationError'));
                        $('#AJAXLoader').addClass('Hidden');
                    }
                    else if ($ElementToUpdate && isJQueryObject($ElementToUpdate) && $ElementToUpdate.length) {

                        $ElementToUpdate.get(0).innerHTML = Response;
                        $ElementToUpdate.find('script').each(function() {
                            JavaScriptString += $(this).html();
                            $(this).remove();
                        });

                        $ElementToUpdate.fadeIn();

                        Core.UI.InputFields.Activate($ElementToUpdate);
                        try {
                            /*eslint-disable no-eval */
                            eval(JavaScriptString);
                            /*eslint-enable no-eval */
                        }
                        catch (Event) {
                            // do nothing here (code needed  to not have an empty block here)
                            $.noop(Event);
                        }

                        // Handle special server errors (Response = <div class="ServerError" data-message="Message"></div>)
                        // Check if first element has class 'ServerError'
                        if ($ElementToUpdate.children().first().hasClass('ServerError')) {
                            ErrorMessage = $ElementToUpdate.children().first().data('message');

                            // Add class ServerError to the process select element
                            $('#ProcessEntityID').addClass('ServerError');
                            // Set a custom error message to the proccess select element
                            $('#ProcessEntityIDServerError').children().first().text(ErrorMessage);
                        }

                        $('#AJAXLoader').addClass('Hidden');

                        $('.DataTypeColumn_' + ValueCounter).bind('change', function () {

                            if ($(this).val() == 'select' && !($("#Column_" + ValueCounter).val() == '')){
                                $("#ContentColumn_" + ValueCounter).removeClass('Hidden');
                                $("#ContentColumn_" + ValueCounter).addClass('Validate_Required');
                                $('label[for="ContentColumn_'+ ValueCounter +'"]').removeClass('Hidden');
                            }
                            else{
                                $("#ContentColumn_" + ValueCounter).addClass('Hidden');
                                $("#ContentColumn_" + ValueCounter).removeClass('Validate_Required');
                                $('label[for="ContentColumn_'+ ValueCounter+'"]').addClass('Hidden');
                            }
                        
                            if ($(this).val() == 'mask' || $(this).val() == 'maskMoney'){
                                Core.Agent.Admin.DynamicFieldTable.NewMask($("#Column_" + ValueCounter).val(), $(this).val());
                            }
                            else{
                                var ColName = $("#Column_" + ValueCounter).val();
                                ColName = ColName.replace(/\ /g, "");
                        
                                $('.DataItem_' + ColName).remove();
                            }
                        
                            if ( $("#Column_" + ValueCounter).val() == '' ){
                                $(this).val("-");
                                $(this).addClass('Error');
                                $("#Column_" + ValueCounter).addClass('Error');
                            }                             
                        
                            if ($('#OperationColumn').val() !== ''){
                                Core.Agent.Admin.DynamicFieldTable.OperationColumn();
                            }
                        });

                        $('#Column_' + ValueCounter).bind('keydown', function () {
                            var $MaskName = $('#Column_' + ValueCounter).val();
                            $MaskName = $MaskName.replace(/\ /g, "");
                        
                            $('.DataItem_' + $MaskName).remove();
                        
                            var $Div = $('#TypeColumn_' + ValueCounter+ '_Search').parent();
                            var remove = $Div.find(".InputField_Selection");
                            remove.remove();
                        
                            $('.DataTypeColumn_' + ValueCounter).val("-");                        
                        
                            if ($('#OperationColumn').val() !== ''){
                                Core.Agent.Admin.DynamicFieldTable.OperationColumn();
                            }                        
                        });
                    }
                    else {

                        // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                        Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No such element id: " + $ElementToUpdate.attr('id') + " in page!", 'CommunicationError'));

                        $('#AJAXLoader').addClass('Hidden');
                    }
                }, 'html');
            }
            return false;
        });

        $('.ShowWarning').bind('change keyup', function (Event) {
            $('p.Warning').removeClass('Hidden');
        });
        
        //bind click function to remove button
        $('.ValueRemove').bind('click', function () {
            Core.Agent.Admin.DynamicFieldTable.RemoveValue($(this).attr('id'));
            return false;
        });
        
        // update sum of columns
        Core.Agent.Admin.DynamicFieldTable.UpdateOperationColumns();
        
        $('#OperationColumn').bind('change', function () {
            Core.Agent.Admin.DynamicFieldTable.UpdateOperationColumns();            
        });
        
        Core.Agent.Admin.DynamicField.ValidationInit();
    };

    TargetNS.NewMask = function(Name, Type) {

        var UpdatedDiv,
            Data,
            $ExistingDiv = $('.DataItem_' + Name);

        $ExistingDiv.remove();

        if (Name == ''){
            return false;
        }
        if (Type == 'mask'){
            UpdatedDiv =  $('.DataItemTextAjax');
        }
        else{
            UpdatedDiv =  $('.DataItemMoneyAjax');
        }

        Data = {
            Action: 'AdminDynamicFieldTable',
            Subaction: 'NewMaskAjax',
            Name: Name,
            Type: Type,
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (Response) {
            var $ElementToUpdate = UpdatedDiv,
                JavaScriptString = '',
                ErrorMessage;

            if (!Response) {

                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No content received.", 'CommunicationError'));
                $('#AJAXLoader').addClass('Hidden');
            }
            else if ($ElementToUpdate && isJQueryObject($ElementToUpdate) && $ElementToUpdate.length) {
                
                if (Type == 'mask'){
                    $ElementToUpdate.removeClass('DataItemTextAjax');
                }
                else{
                    $ElementToUpdate.removeClass('DataItemMoneyAjax');
                }

                //Remove element before insert it
                Name = Name.replace(/\ /g, "");
                $ElementToUpdate.addClass('DataItem_' + Name);

                $ElementToUpdate.get(0).innerHTML = Response;
                $ElementToUpdate.find('script').each(function() {
                    JavaScriptString += $(this).html();
                    $(this).remove();
                });

                $ElementToUpdate.fadeIn();
                Core.UI.InputFields.Activate($ElementToUpdate);
                try {
                    /*eslint-disable no-eval */
                    eval(JavaScriptString);
                    /*eslint-enable no-eval */
                }
                catch (Event) {
                    // do nothing here (code needed  to not have an empty block here)
                    $.noop(Event);
                }

                // Handle special server errors (Response = <div class="ServerError" data-message="Message"></div>)
                // Check if first element has class 'ServerError'
                if ($ElementToUpdate.children().first().hasClass('ServerError')) {
                    ErrorMessage = $ElementToUpdate.children().first().data('message');

                    // Add class ServerError to the process select element
                    $('#ProcessEntityID').addClass('ServerError');
                    // Set a custom error message to the proccess select element
                    $('#ProcessEntityIDServerError').children().first().text(ErrorMessage);
                }

                $('#AJAXLoader').addClass('Hidden');

                if (Type == 'mask'){
                    $('.TextMask').append("<li class='DataItemTextAjax'></li>");
                }
                else{
                    $('.MoneyMask').append("<li class='DataItemMoneyAjax'></li>");
                }
            }
            else {

                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No such element id: " + $ElementToUpdate.attr('id') + " in page!", 'CommunicationError'));
                $('#AJAXLoader').addClass('Hidden');
            }
        }, 'html');
        return false;
    };

    TargetNS.OperationColumn = function() {
        var UpdatedDiv =  $('.OperationColumn'),
            Count = $(".ValueCounter").val(),
            ID = $('input[name="ID"]').val(),
            possibleColumnStr = '',
            Type,
            Data,
            i;

        for (i = 1; i <= Count; i++){
            Type = $("#TypeColumn_" + i).val();

            if (Type == 'maskMoney' || Type == 'number'){
                possibleColumnStr += $("#Column_" + i).val() + ";";
            }
        }

        Data = {
            Action: 'AdminDynamicFieldTable',
            Subaction: 'OperationColumns',
            PossibleColumns: possibleColumnStr,
            ID: ID,
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'), Data, function (Response) {

                var $ElementToUpdate = UpdatedDiv,
                    JavaScriptString = '',
                    ErrorMessage;

                if (!Response) {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No content received.", 'CommunicationError'));
                    $('#AJAXLoader').addClass('Hidden');
                }
                else if ($ElementToUpdate && isJQueryObject($ElementToUpdate) && $ElementToUpdate.length) {

                    $ElementToUpdate.get(0).innerHTML = Response;
                    $ElementToUpdate.find('script').each(function() {
                        JavaScriptString += $(this).html();
                        $(this).remove();
                    });

                    $ElementToUpdate.fadeIn();
                    Core.UI.InputFields.Activate($ElementToUpdate);
                    try {
                        /*eslint-disable no-eval */
                        eval(JavaScriptString);
                        /*eslint-enable no-eval */
                    }
                    catch (Event) {
                        // do nothing here (code needed  to not have an empty block here)
                        $.noop(Event);
                    }

                    $ElementToUpdate.addClass('Field ');

                    // Handle special server errors (Response = <div class="ServerError" data-message="Message"></div>)
                    // Check if first element has class 'ServerError'
                    if ($ElementToUpdate.children().first().hasClass('ServerError')) {
                        ErrorMessage = $ElementToUpdate.children().first().data('message');

                        // Add class ServerError to the process select element
                        $('#ProcessEntityID').addClass('ServerError');
                        // Set a custom error message to the proccess select element
                        $('#ProcessEntityIDServerError').children().first().text(ErrorMessage);
                    }

                    $('#AJAXLoader').addClass('Hidden');
                }
                else {

                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No such element id: " + $ElementToUpdate.attr('id') + " in page!", 'CommunicationError'));
                    $('#AJAXLoader').addClass('Hidden');
                }
            }, 'html'
        );
        return false;
    }

    TargetNS.UpdateOperationColumns = function() {        

        if ( $('#OperationColumn').val() !== '') {
            $(".OperationColumn").removeClass('Hidden');
            $('label[for="SelectedOperationColumn"]').show();
            Core.Agent.Admin.DynamicFieldTable.OperationColumn();
        }else{
            $(".OperationColumn").addClass('Hidden');
            $('label[for="SelectedOperationColumn"]').hide();
        }

        if($('#OperationColumn').val() == 'Formula') {
            $('label[for="OperationFormula"]').show();
            $('#OperationFormula').parent().removeClass('Hidden');
        }
        else {
            $('label[for="OperationFormula"]').hide();
            $('#OperationFormula').parent().addClass('Hidden');
            $('#OperationFormula').val('');
        }
    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.DynamicFieldTable || {}));
