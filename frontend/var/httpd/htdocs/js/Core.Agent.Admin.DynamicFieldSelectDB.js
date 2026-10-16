// --
// var/httpd/htdocs/js/Core.Agent.Admin.DynamicFieldSelectDB.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br

// written/edited by:
// * gesquetini@beonup.com.br
// * dsilva@serviceup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.DynamicFieldSelectDB
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the DynamicFieldSelectDB module.
 */
Core.Agent.Admin.DynamicFieldSelectDB = (function (TargetNS) {

    /**
     * @name RemoveValue
     * @memberof Core.Agent.Admin.DynamicFieldSelectDB
     * @function
     * @returns {Boolean} Returns false
     * @param {String} IDSelector - ID of the pressed remove value button.
     * @description
     *      This function removes a value from possible values list and creates a stub input so
     *      the server can identify if a value is empty or deleted (useful for server validation)
     *      It also deletes the Value from the DefaultValues list
     */
    TargetNS.RemoveValue = function (IDSelector){

        // copy HTML code for an input replacement for the deleted value
        var $Clone = $('.DeletedValue').clone(),

        // get the index of the value to delete (its always the second element (1) in this RegEx
        $ObjectIndex = IDSelector.match(/.+_(\d+)/)[1],

        // get the key name to remove it from the defaults select
        $Key = $('#Key_' + $ObjectIndex).val();

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

        return false;
    };

    /**
     * @name AddValue
     * @memberof Core.Agent.Admin.DynamicFieldSelectDB
     * @function
     * @returns {Boolean} Returns false
     * @param {Object} ValueInsert - HTML container of the value mapping row.
     * @description
     *      This function add a new value to the possible values list
     */
    TargetNS.AddValue = function (ValueInsert) {

        // clone key dialog
        var $Clone = $('.ValueTemplate').clone(),
            ValueCounter = $('#ValueCounter').val();

        // increment key counter
        ValueCounter++;

        // remove unnecessary classes
        $Clone.removeClass('Hidden ValueTemplate');

        // add needed class
        $Clone.addClass('ValueRow');

        // copy values and change ids and names
        $Clone.find(':input, a.RemoveButton').each(function(){
            var ID = $(this).attr('id');
            $(this).attr('id', ID + '_' + ValueCounter);
            $(this).attr('name', ID + '_' + ValueCounter);

            if(ID != 'Value'){
                $(this).addClass('Validate_Required');
            }

            // set error controls
            $(this).parent().find('#' + ID + 'Error').attr('id', ID + '_' + ValueCounter + 'Error');
            $(this).parent().find('#' + ID + 'Error').attr('name', ID + '_' + ValueCounter + 'Error');

            $(this).parent().find('#' + ID + 'ServerError').attr('id', ID + '_' + ValueCounter + 'ServerError');
            $(this).parent().find('#' + ID + 'ServerError').attr('name', ID + '_' + ValueCounter + 'ServerError');

            // add event handler to remove button
            if($(this).hasClass('RemoveButton')) {

                // bind click function to remove button
                $(this).on('click', function () {
                    TargetNS.RemoveValue($(this).attr('id'));
                    return false;
                });
            }
        });

        $Clone.find('label').each(function(){
            var FOR = $(this).attr('for');
            $(this).attr('for', FOR + '_' + ValueCounter);
        });

        // append to container
        ValueInsert.append($Clone);

        // set new value for KeyName
        $('#ValueCounter').val(ValueCounter);

        $('.DefaultValueKeyItem,.DefaultValueItem').on('keyup', function () {
            TargetNS.RecreateDefaultValueList();
        });

        return false;
    };

    /**
     * @name RecreateDefaultValueList
     * @memberof Core.Agent.Admin.DynamicFieldSelectDB
     * @function
     * @returns {Boolean} Returns false
     * @description
     *      This function re-creates and sort the Default Values list taking the Possible Values
     *      as source, all deleted values will not be part of the re-created value list
     */
    TargetNS.RecreateDefaultValueList = function() {

        // get the selected default value
        var SelectedValue = $("#DefaultValue option:selected").val(),

        // define other variables
        ValueIndex, Key, Value, KeyID, SelectOptions;

        // delete all elements
        $('#DefaultValue').empty();

        // add the default "possible none" element
        $('#DefaultValue').append($('<option>', { value: '' }).text('-'));

        // find all active possible values keys (this will omit all previously deleted keys)
        $('.ValueRow > .DefaultValueKeyItem').each(function(){

            // for each key:
            // Get the ID
            KeyID = $(this).attr('id');

            // extract the index
            ValueIndex = KeyID.match(/.+_(\d+)/)[1];

            // get the Key and Value
            Key = $(this).val();
            Value = $('#Value_' + ValueIndex).val();

            // check if both are none empty and add them to the default values list
            if (Key !== '' && Value !== '') {
                $('#DefaultValue').append($('<option>', { value: Key }).text(Value));

            }
        });

        // extract the new value list into an array
        SelectOptions = $("#DefaultValue option");

        // sort the array by the text (this means the Value)
        SelectOptions.sort(function(a, b) {
            if (a.text > b.text) {
                return 1;
            }
            else if (a.text < b.text) {
                return -1;
            }
            else {
                return 0;
            }
        });

        // clear the list again and re-populate it with the sorted list
        $("#DefaultValue").empty().append(SelectOptions);

        // set the selected value as it was before, this will not apply if the key name was
        // changed
        $('#DefaultValue').val(SelectedValue);

        $('#DefaultValue').trigger('redraw.InputField');

        return false;
    };

    /**
     * @name Init
     * @memberof Core.Agent.Admin.DynamicFieldSelectDB
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        $('.ShowWarning').on('change keyup', function () {
            $('p.Warning').removeClass('Hidden');
        });

        //bind click function to add button
        $('#AddValue').on('click', function () {
            TargetNS.AddValue(
                $(this).closest('fieldset').find('.ValueInsert')
            );
            return false;
        });

        //bind click function to remove button
        $('.ValueRemove').on('click', function () {
            TargetNS.RemoveValue($(this).attr('id'));
            return false;
        });

        $('.DefaultValueKeyItem,.DefaultValueItem').on('keyup', function () {
            TargetNS.RecreateDefaultValueList();
        });

        $('#MaxArraySize').bind('change', function (Event) {
            if ( isNaN( $('#MaxArraySize').val() ) ) {
                $('#MaxArraySize').val('1');
            }
            if ( $('#MaxArraySize').val() < 1 ) {
                $('#MaxArraySize').val('1');
            }
            while ( $('input[name=DefaultValues]').length > $('#MaxArraySize').val() ) {
                $('input[name=DefaultValues]').last().siblings('div.Remove').find('a').trigger('click');
            }
            if ( $('input[name=DefaultValues]').length >= $('#MaxArraySize').val() ) {
                $('#DefaultValues_AutoComplete').hide();
            }
            if ( $('input[name=DefaultValues]').length < $('#MaxArraySize').val() ) {
                $('#DefaultValues_AutoComplete').show();
            }
        });

        var DataJS = JSON.parse(Core.Config.Get('DataJS'));
        var DefaultValueCount = DataJS.DefaultValuesCount;

        $('#DefaultValues_AutoComplete').autocomplete({
            delay: 300,
            minLength: 3,
            source: function (Request, Response) {
                var URL = '';
                var Data = {};
                Data.Action     = 'AdminDynamicFieldSelectDB';
                Data.Subaction  = 'DefaultValueSearch';
                Data.Search     = Request.term;
        
                var QueryString = Core.AJAX.SerializeForm($('#DefaultValues_AutoComplete'), Data);
                $.each(Data, function (Key, Value) {
                    QueryString += ';' + encodeURIComponent(Key) + '=' + encodeURIComponent(Value);
                });
        
                if ($('#DefaultValues_AutoComplete').data('AutoCompleteXHR')) {
                    $('#DefaultValues_AutoComplete').data('AutoCompleteXHR').abort();
                    $('#DefaultValues_AutoComplete').removeData('AutoCompleteXHR');
                }
                $('#DefaultValues_AutoComplete').data('AutoCompleteXHR', Core.AJAX.FunctionCall(URL, QueryString, function (Result) {
                    if(Result.Error){
                        alert(Result.Error);
                        return false;
                    }
                    var Data = [];
                    $.each(Result, function () {
                        Data.push({
                            key:   this.Key,
                            value: this.Value,
                            label: this.Label,
                            title: this.Title
                        });
                    });
                    $('#DefaultValues_AutoComplete').data('AutoCompleteData', Data);
                    $('#DefaultValues_AutoComplete').removeData('AutoCompleteXHR');
                    Response(Data);
                }).fail(function() {
                    Response($('#DefaultValues_AutoComplete').data('AutoCompleteData'));
                }));
            },
            select: function (Event, UI) {
                DefaultValueCount++;
                $('#DefaultValues_Container').append(
                    '<div class="InputField_Selection" style="display:block;position:inherit;">'
                    + '<input id="DefaultValues_'
                    + DefaultValueCount
                    + '" type="hidden" name="DefaultValues" value="'
                    + UI.item.key
                    + '" />'
                    + '<div class="Text">'
                    + UI.item.value
                    + '</div>'
                    + '<div class="Remove"><a href="#" role="button" title="' + Core.Language.Translate("Remove") 
                    + '" tabindex="-1" aria-label="'+ Core.Language.Translate("Remove") + ': ' + UI.item.value
                    + '">x</a></div><div class="Clear"></div>'
                    + '</div>'
                );
                $('#DefaultValues_' + DefaultValueCount).siblings('div.Remove').find('a').data('counter', DefaultValueCount);
                $('#DefaultValues_' + DefaultValueCount).siblings('div.Remove').find('a').bind('click', function() {
                    $('#DefaultValues_' + $(this).data('counter')).parent().remove();
                    if ($('input[name=DefaultValues]').length == 0) {
                        $('#DefaultValues_Container').hide();
                    }
                    if ($('input[name=DefaultValues]').length < $('#MaxArraySize').val()) {
                        $('#DefaultValues_AutoComplete').show();
                    }
                    return false;
                });
                $('#DefaultValues_Container').show();
                $('#DefaultValues_AutoComplete').val('');
                if ($('input[name=DefaultValues]').length >= $('#MaxArraySize').val()) {
                    $('#DefaultValues_AutoComplete').hide();
                }
                $('#DefaultValues').trigger('change');
                Event.preventDefault();
                return false;
            },
        });

        var DefaultValueCounter = DataJS.DefaultValueCounter;

        $('#DefaultValues_' + DefaultValueCounter).siblings('div.Remove').find('a').bind('click', function() {
            $('#DefaultValues_' + DefaultValueCounter).parent().remove();
            if ($('input[name=DefaultValues]').length == 0) {
                $('#DefaultValues_Container').hide();
            }
            if ($('input[name=DefaultValues]').length < $('#MaxArraySize').val()) {
                $('#DefaultValues_AutoComplete').show();
            }
            return false;
        });

        $('#DefaultValues_AutoComplete').blur(function() {
            $(this).val('');
        });
        if ($('input[name=DefaultValues]').length == 0) {
            $('#DefaultValues_Container').hide();
        }
        if ($('input[name=DefaultValues]').length >= $('#MaxArraySize').val()) {
            $('#DefaultValues_AutoComplete').hide();
        }

        var DataDBJS = JSON.parse(Core.Config.Get('DataDBJS'));

        var DatabaseDSN  = DataDBJS.DatabaseDSN;
        var DatabaseUser = DataDBJS.DatabaseUser;
        var DatabasePw   = DataDBJS.DatabasePw;
        var DatabaseType = DataDBJS.DatabaseType;

        if(DataDBJS.StandardConnection == 0){
            $("label[for='DatabaseDSN']").css("display", "block");
            $("#DatabaseDSN").parent().removeClass("Hidden");

            $("label[for='DatabaseUser']").css("display", "block");
            $("#DatabaseUser").parent().removeClass("Hidden");

            $("label[for='DatabasePw']").css("display", "block");
            $("#DatabasePw").parent().removeClass("Hidden");

            $("label[for='DatabaseType']").css("display", "block");
            $("#DatabaseType").parent().removeClass("Hidden");
        }

        $('#StandardConnection').bind('change', function (Event) {

            if( $(this).val() == 1){

                $("label[for='DatabaseDSN']").css("display", "none");
                $("#DatabaseDSN").parent().addClass("Hidden");
                $("#DatabaseDSN").val(DatabaseDSN);

                $("label[for='DatabaseUser']").css("display", "none");
                $("#DatabaseUser").parent().addClass("Hidden");
                $("#DatabaseUser").val(DatabaseUser);

                $("label[for='DatabasePw']").css("display", "none");
                $("#DatabasePw").parent().addClass("Hidden");
                $("#DatabasePw").val(DatabasePw);

                $("label[for='DatabaseType']").css("display", "none");
                $("#DatabaseType").parent().addClass("Hidden");
                $("#DatabaseType").val(DatabaseType);

            }
            else{
                $("label[for='DatabaseDSN']").css("display", "block");
                $("#DatabaseDSN").parent().removeClass("Hidden");

                $("label[for='DatabaseUser']").css("display", "block");
                $("#DatabaseUser").parent().removeClass("Hidden");

                $("label[for='DatabasePw']").css("display", "block");
                $("#DatabasePw").parent().removeClass("Hidden");

                $("label[for='DatabaseType']").css("display", "block");
                $("#DatabaseType").parent().removeClass("Hidden");
            }

        });

        Core.Agent.Admin.DynamicField.ValidationInit();
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.DynamicFieldSelectDB || {}));
