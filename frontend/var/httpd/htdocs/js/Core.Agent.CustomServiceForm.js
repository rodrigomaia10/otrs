// --
// var/httpd/htdocs/js/Core.Agent.CustomServiceForm.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * dsilva@serviceup.com.br
// * jsantos@serviceup.com.br
// * gesquetini@beonup.com.br
// * ghidalgo@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Agent.CustomServiceForm
 * @memberof Core.Agent
 * @author OTRS AG
 * @param {string} Title - short name of the AJAX loading
 * @description
 *      This namespace contains the special function for CustomServiceForm module.
 */
 Core.Agent.CustomServiceForm = (function (TargetNS) {

    var AJAXLoaderPrefix = 'AJAXLoader',
    ActiveAJAXCalls = {};

     /**
      * @name Init
      * @memberof Core.Agent.Admin.CustomServiceForm
      * @function
      * @description
      *      This function initializes the module functionality.
      */

    TargetNS.Init = function (Title) {

        var $ElemetParent = $("#ServiceID").parent();
        var Content =
        "<div id="+'AJAXLoaderForm'+' class="Spacing Center Hidden">'+
            "<span class="+'AJAXLoader'+" title="+Title+"></span>"+
        "</div>"+
        "<div class="+'FormContent Hidden'+" id="+'ServiceFormContent'+"></div>";

        $(Content).insertAfter($ElemetParent);

		var Data;

        $('#ServiceID').change(function() {
            if( $('input[name=Action]').val() == "AgentTicketPhone" || $('input[name=Action]').val() == "AgentTicketEmail" || $('input[name=Action]').val() == "AgentTicketFreeText" ){
                $("#FileUpload").parent().removeClass("Hidden");
                $("#FileUpload").parent().prev().removeAttr("style");

            }else if($('input[name=Action]').val() == "CustomerTicketMessage"){
                $("#FileUpload").parent().parent().removeClass("Hidden");
                $("#FileUpload").parent().parent().prev().removeAttr("style");
            }

            const urlParams = new URLSearchParams(window.location.search);
            const action = urlParams.get('Action');

            Data = {
                Action: 'CustomServiceFormAJAXHandler',
                Subaction: 'DisplayFormAJAX',
                ServiceID: $('#ServiceID').val(),
                OldAction: action,
            };

			if(window.location.search.indexOf('TicketID') > -1) {

				var TicketID = location.search.split('TicketID=').splice(1).join('').split('‌​&')[0];

				Data = {
					Action: 'CustomServiceFormAJAXHandler',
					Subaction: 'DisplayFormAJAX',
					ServiceID: $('#ServiceID').val(),
					TicketID: TicketID
				};
			}

            if ($('#ServiceID').val()) {

                // remove the content of the activity dialog
                $('#ServiceFormContent').empty();

                // fade out the empty container so it will fade in again on processes change
                // is not recommended to empty after fade out at this point since the transition offect
                // will not look so nice
                $('#ServiceFormContent').fadeOut('fast');

                // show loader icon
                $('#AJAXLoaderForm').removeClass('Hidden');

                // get new ActivityDialog content
                Core.AJAX.FunctionCall(
                    Core.Config.Get('CGIHandle'),
                    Data,
                    function (Response) {
                        let $ElementToUpdate = $('#ServiceFormContent'),
                            JavaScriptString = '',
                            ErrorMessage;

                        if (!Response) {

                            // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                            Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No content received.", 'CommunicationError'));
                            $('#AJAXLoaderForm').addClass('Hidden');
                        }
                        else if ($ElementToUpdate && isJQueryObject($ElementToUpdate) && $ElementToUpdate.length) {

                            var JSONResponse = JSON.parse(Response);
                         
                            $('.SidebarColumn #FormInfo').remove();
                            $('.DescriptionServiceForm').remove();

                            if(JSONResponse.FormHTML == 'No Form.') {
                                $('#AJAXLoaderForm').addClass('Hidden');
                                return 0;
                            }

                            if(JSONResponse.HideAttachment == 1){
                                if( $('input[name=Action]').val() == "AgentTicketPhone" || $('input[name=Action]').val() == "AgentTicketEmail" || $('input[name=Action]').val() == "AgentTicketFreeText" ){
                                    $("#FileUpload").parent().addClass("Hidden");
                                    $("#FileUpload").parent().prev().attr("style","display:none");

                                }else if($('input[name=Action]').val() == "CustomerTicketMessage"){
                                    $("#FileUpload").parent().parent().addClass("Hidden");
                                    $("#FileUpload").parent().parent().prev().attr("style","display:none");
                                }
                            }

                            if(JSONResponse.UserType == 'User' && JSONResponse.Description != ""){
                                $( ".SidebarColumn" ).append(
                                    "<div id='FormInfo' class='WidgetSimple'>"+
                                        "<div class='Header'>"+
                                            "<h2>Descrição do Formulário</h2>"+
                                        " </div>"+
                                        "<div class='Content'>"+
                                            JSONResponse.Description +
                                        " </div>"+
                                    "</div>"
                                );
                            }
                            else if (JSONResponse.Description != ""){
                                $("<div id='FormInfo' class='DescriptionServiceForm'>"+
                                    "<div class='WidgetSimple'>"+
                                        "<div class='Header'>"+
                                            "<h3>Descrição do Formulário</h3>"+
                                            "<div class='Clear'></div>"+
                                        "</div>"+
                                        "<div class='Content'>"+
                                            "<div class='Hint'>"+
                                                JSONResponse.Description +
                                            "</div>"+
                                        "</div>"+
                                    "</div>"+
                                "</div>" ).insertBefore($("#AJAXLoaderForm"));
                            }

                            $('#ServiceFormContent').removeClass('Hidden');
                         
                            $ElementToUpdate.get(0).innerHTML = JSONResponse.FormHTML;
                            // $('#ServiceFormContent').html( JSONResponse.FormHTML );

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

                            Core.Form.Validate.Init();

                            // Register event for tree selection dialog
                            Core.UI.TreeSelection.InitTreeSelection();

                            // move help triggers into field rows for dynamic fields
                            $('.Row > .FieldHelpContainer').each(function () {

                                if (!$(this).next('label').find('.Marker').length) {
                                    $(this).prependTo($(this).next('label'));
                                }
                                else {
                                    $(this).insertAfter($(this).next('label').find('.Marker'));
                                }
                            });

                            // Initially display dynamic fields with TreeMode = 1 correctly
                            Core.UI.TreeSelection.InitDynamicFieldTreeViewRestore();

                            // trigger again a responsive event
                            if (Core.App.Responsive.IsSmallerOrEqual(Core.App.Responsive.GetScreenSize(), 'ScreenL')) {
                                Core.App.Publish('Event.App.Responsive.SmallerOrEqualScreenL');
                            }

                            $('#AJAXLoaderForm').addClass('Hidden');
                            $('#AJAXDialog').val('1');
                        }
                        else {
                            // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                            Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No such element id: " + $ElementToUpdate.attr('id') + " in page!", 'CommunicationError'));
                            $('#AJAXLoaderForm').addClass('Hidden');
                        }
                        //  If the ShowHide module exists
                        if (Core.Agent.ShowHideField != undefined){
                            Core.Agent.ShowHideField.Init();
                        }
                        
                    }, 'html'

                );
            }
            else {
                $('#ServiceFormContent').fadeOut(400, function() {
                    $('#ServiceFormContent').empty();
                });

                $('.DescriptionServiceForm').remove();
                $('.SidebarColumn #FormInfo').remove();

            }

            // If the ShowHide module exists
            if (Core.Agent.ShowHideField != undefined){
                Core.Agent.ShowHideField.Init();
            }

            return false;
        });
    };

    /**
     * @name SerializeForm
     * @memberof Core.Agent.CustomServiceForm
     * @function
     * @returns {String} The query string.
     * @param {jQueryObject} $Element - The jQuery object of the form  or any element within this form that should be serialized
     * @param {Object} [Ignore] - Elements (Keys) which should not be included in the serialized form string (optional)
     * @description
     *      Serializes the form data into a query string.
     */
    TargetNS.SerializeServiceForm = function () {
        var QueryString = "";
		$("#ServiceFormContent").find("select, textarea, input").filter(':not([disabled=disabled])').each(function () {
			var Name = $(this).attr('name') || '';

			// only look at fields with name
			// only add element to the string, if there is no key in the data hash with the same name
			if (!Name.length){
				return;
			}

			if ($(this).is(':checkbox, :radio')) {
				if ($(this).is(':checked')) {
					QueryString += encodeURIComponent(Name) + '=' + encodeURIComponent($(this).val() || 'on') + ";";
				}
			}
			else if ($(this).is('select')) {
				$.each($(this).find('option:selected'), function(){
                    QueryString += encodeURIComponent(Name) + '=' + encodeURIComponent($(this).val() || '') + ";";   
                });
			}
			else {
				QueryString += encodeURIComponent(Name) + '=' + encodeURIComponent($(this).val() || '') + ";";
			}
		});

        return QueryString;
    };

	/**
     * @private
     * @name GetSessionInformation
     * @memberof Core.AJAX
     * @function
     * @returns {Object} Hash with session data, if needed.
     * @description
     *      Collects session data in a hash if available.
     */
    function GetSessionInformation() {
        var Data = {};
        if (!Core.Config.Get('SessionIDCookie')) {
            Data[Core.Config.Get('SessionName')] = Core.Config.Get('SessionID');
            Data[Core.Config.Get('CustomerPanelSessionName')] = Core.Config.Get('SessionID');
        }
        Data.ChallengeToken = Core.Config.Get('ChallengeToken');
        return Data;
    }

    /**
     * @private
     * @name GetAdditionalDefaultData
     * @memberof Core.AJAX
     * @function
     * @returns {Object} Hash with additional session and action data.
     * @description
     *      Collects additional data that are needed for the ajax requests.
     */
    function GetAdditionalDefaultData() {

        var Data = {};
        Data = GetSessionInformation();
        Data.Action = 'CustomServiceFormAJAXHandler';
        return Data;
    }

	/**
     * @private
     * @name SerializeData
     * @memberof Core.AJAX
     * @function
     * @returns {String} Query string of the data.
     * @param {Object} Data - The data that should be converted
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
     * @private
     * @name ToggleAJAXLoader
     * @memberof Core.AJAX
     * @function
     * @param {String} FieldID - Id of the field which is updated via ajax
     * @param {Boolean} Show - Show or hide the AJAX loader image
     * @description
     *      Shows and hides an ajax loader for every element which is updates via ajax.
     */
    function ToggleAJAXLoader(FieldID, Show) {

        var $Element = $('#' + FieldID),
            $Loader = $('#' + AJAXLoaderPrefix + FieldID),
            LoaderHTML = '<span id="' + AJAXLoaderPrefix + FieldID + '" class="AJAXLoader"></span>';

        // Ignore hidden fields
        if ($Element.is('[type=hidden]')) {
            return;
        }
        // Element not present, reset counter and ignore
        if (!$Element.length) {
                ActiveAJAXCalls[FieldID] = 0;
                return;
        }

        // Init counter value, if needed.
        // This counter stores the number of running AJAX requests for each field.
        // The loader image will be shown if it is > 0.
        if (typeof ActiveAJAXCalls[FieldID] === 'undefined') {
            ActiveAJAXCalls[FieldID] = 0;
        }

        // Calculate counter
        if (Show) {
            ActiveAJAXCalls[FieldID]++;
        }
        else {
            ActiveAJAXCalls[FieldID]--;
            if (ActiveAJAXCalls[FieldID] <= 0) {
                ActiveAJAXCalls[FieldID] = 0;
            }
        }

        // Show or hide the loader
        if (ActiveAJAXCalls[FieldID] > 0) {
            if (!$Loader.length) {
                $Element.after(LoaderHTML);
            }
            else {
                $Loader.show();
            }
        }
        else {
            $Loader.hide();
        }
    }

	/**
     * @private
     * @name RedirectAfterSessionTimeOut
     * @memberof Core.AJAX
     * @function
     * @returns {Boolean} Returns false, if Redirect is not necessary.
     * @param {Object} XHRObject - The original AJAX object.
     * @description
     *      Checks if session is timed out and redirects to the login to avoid
     *      ajax errors.
     */
    function RedirectAfterSessionTimeOut(XHRObject) {

        var Headers = XHRObject.getAllResponseHeaders(),
            OldUrl = location.href,
            NewUrl = Core.Config.Get('Baselink') + "RequestedURL=" + encodeURIComponent(OldUrl);

        if (Headers.match(/X-OTRS-Login: /)) {
            location.href = NewUrl;
            return true;
        }

        return false;
    }

	/**
     * @private
     * @name HandleAJAXError
     * @memberof Core.AJAX
     * @function
     * @param {Object} XHRObject - Meta data returned by the ajax request
     * @param {String} Status - Status information of the ajax request
     * @param {String} Error - Error information of the ajax request
     * @description
     *      Handles failing ajax request (only used as error callback in $.ajax calls)
     */
    function HandleAJAXError(XHRObject, Status, Error) {
        var ErrorMessage = 'Error during AJAX communication. Status: ' + Status + ', Error: ' + Error;

        // Check for expired sessions.
        if (RedirectAfterSessionTimeOut(XHRObject)) {
            return;
        }

        // Ignore aborted AJAX calls.
        if (Status === 'abort') {
            return;
        }

        // Collect debug information if configured.
        if (Core.Config.Get('AjaxDebug') && typeof XHRObject === 'object') {
            ErrorMessage += "\n\nResponse status: " + XHRObject.status + " (" + XHRObject.statusText + ")\n";
            ErrorMessage += "Response headers: " + XHRObject.getAllResponseHeaders() + "\n";
            ErrorMessage += "Response content: " + XHRObject.responseText;
        }

        if (!XHRObject.status) {

            // If we didn't receive a status, the request didn't get any result, which is most likely a connection issue.
            Core.Exception.HandleFinalError(new Core.Exception.ApplicationError(ErrorMessage, 'ConnectionError'));
            return;
        }

        // We are out of the OTRS App scope, that's why an exception would not be caught. Therefore we handle the error manually.
        Core.Exception.HandleFinalError(new Core.Exception.ApplicationError(ErrorMessage, 'CommunicationError'));
    }

	/**
     * @name FormUpdate
     * @memberof Core.AJAX
     * @function
     * @returns {Object} The jqXHR object.
     * @param {jQueryObject} $EventElement - The jQuery object of the element(s) which are included in the form that should be submitted.
     * @param {String} Subaction - The subaction parameter for the perl module.
     * @param {String} ChangedElement - The name of the element which was changed by the user.
     * @param {Object} FieldsToUpdate - DEPRECATED.
     *                      This used to be the names of the fields that should be updated with the server answer,
     *                      but is not needed any more and will be removed in a future version of OTRS.
     * @param {Function} [SuccessCallback] - Callback function to be executed on AJAX success (optional).
     * @description
     *      Submits a special form via ajax and updates the form with the data returned from the server
     */
    TargetNS.ServiceFormUpdate = function (ServiceID, Subaction, ChangedElement, FieldsToUpdate, SuccessCallback) {
        var URL = Core.Config.Get('Baselink'),
            Data = GetAdditionalDefaultData(),
            QueryString;

        Data.Subaction = Subaction;
        Data.ServiceID = ServiceID;
        Data.ElementChanged = ChangedElement;
        QueryString = TargetNS.SerializeServiceForm() + SerializeData(Data);

        if (FieldsToUpdate.length > 0 && FieldsToUpdate[0] !== '') {
            $.each(FieldsToUpdate, function (Index, Value) {
                ToggleAJAXLoader(Value, true);
            });
        }

        return $.ajax({
            type: 'POST',
            url: URL,
            data: QueryString,
            dataType: 'json',
            success: function (Response, Status, XHRObject) {

                Core.App.Publish('Core.App.AjaxErrorResolved');

                if (RedirectAfterSessionTimeOut(XHRObject)) {
                    return false;
                }

                if (!Response) {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefore we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Invalid JSON from: " + URL, 'CommunicationError'));
                }
                else {
                    UpdateFormElements(Response, FieldsToUpdate);
                    if (typeof SuccessCallback === 'function') {
                        SuccessCallback();
                    }
                    Core.App.Publish('Event.AJAX.FormUpdate.Callback', [Response]);
                }
            },
            complete: function () {
                if (FieldsToUpdate) {
                    $.each(FieldsToUpdate, function (Index, Value) {
                        if(Value) {
                            ToggleAJAXLoader(Value, false);
                        }
                    });
                }
            },
            error: function(XHRObject, Status, Error) {
                HandleAJAXError(XHRObject, Status, Error)
            }
        });
    };

	/**
     * @private
     * @name UpdateFormElements
     * @memberof Core.AJAX
     * @function
     * @param {Object} Data - The new field data. The keys are the IDs of the fields to be updated.
     * @description
     *      Updates the given fields with the given data.
     */
    function UpdateFormElements(Data) {

        if (typeof Data !== 'object') {
            return;
        }
        
        $.each(Data, function (DataKey, DataValue) {
            var $Element = $('#' + DataKey);

            if ((!$Element.length || !DataValue) && !$Element.is('textarea')) {
                return;
            }
            // Select elements
            if ($Element.is('select')) {

                //$Element.empty();
                $.each(DataValue, function (Index, Value) {
                    // var NewOption,
                    //     OptionText = Core.App.EscapeHTML(Value[1]);
                    //
                    // NewOption = new Option(OptionText, Value[0], Value[2], Value[3]);
                    //
                    // // Check if option must be disabled.
                    // if (Value[4]) {
                    //     NewOption.disabled = true;
                    // }
                    //
                    // // Overwrite option text, because of wrong html quoting of text content.
                    // // (This is needed for IE.)
                    // NewOption.innerHTML = OptionText;
                    // $Element.append(NewOption);

                });

                // Trigger custom redraw event for InputFields
                if ($Element.hasClass('Modernize')) {
                   //$Element.trigger('redraw.InputField');
                }

                return;
            }

            // text area elements like the ticket body
            if ($Element.is('textarea')) {
                UpdateTextarea($Element, DataValue);
                return;
            }

            // Other form elements
            $Element.val(DataValue);

            // Trigger custom redraw event for InputFields
            if ($Element.hasClass('Modernize')) {
                // $Element.trigger('redraw.InputField');
            }
        });
    }

    TargetNS.RegToField = function (ArrayOfRegex, DynamicField) {

        var FieldValue = $('#' + DynamicField).val();
        var bool = false;
        var ErrorMessage;

        if(ArrayOfRegex.length > 0) {

            for(var key in ArrayOfRegex) {

                let RegexObject = ArrayOfRegex[key];

                let Regex = new RegExp(RegexObject.Value);

                if (Regex.test(FieldValue)){
                    bool = true;
                }
                else{
                    bool = false;
                    ErrorMessage = RegexObject.ErrorMessage;
                }
            }

            $("#" + DynamicField+"ErrorServerError").css("display", "none");

            if (bool) {

                if ( $("#" + DynamicField).val() === "" ) {

                    $("#" + DynamicField + "Error p").text(Core.Language.Translate("This field is required."));
                    // $("#Label" + DynamicField).addClass("LabelError");
                    $("#" + DynamicField + "Error").css("display", "inline-block");
                    $("#" + DynamicField + "Error p").css("margin","1px 0 0 0px");
                }
                else {

                    $('#' + DynamicField).removeClass("Error");
                    $("#Label" + DynamicField).removeClass("LabelError");
                    $("#" + DynamicField+"ErrorServerError").css("display", "none");  
                    $("#" + DynamicField+"Error").css("display", "none");
                }
            }
            else {

                if ( $("#" + DynamicField).hasClass('Validate_Required') && !$("#" + DynamicField).hasClass('No_Required') ) {

                    $('#' + DynamicField).addClass("Error");
                    $("#Label" + DynamicField).addClass("LabelError");
                    $("#" + DynamicField).addClass("Validate_Required");

                    if ( $("#" + DynamicField).val() !== "" ) {

                        Core.Form.ErrorTooltips.InitTooltip( $("#" + DynamicField), "<p>"+ErrorMessage+"</p>");
                        
                        $("#" + DynamicField).val('');
                    }
                    else {

                        $("#" + DynamicField + "Error p").text(Core.Language.Translate("This field is required."));
                        $("#" + DynamicField + "Error p").css("margin","1px 0 0 0px");
                        $("#" + DynamicField + "Error").css("display", "inline-block");
                    }
                }
                else if ( $("#" + DynamicField).val() !== "" ) {

                    $('#' + DynamicField).addClass("Error");
                    $("#Label" + DynamicField).addClass("LabelError");
                    $("#" + DynamicField).addClass("Validate_Required");
                    $("#" + DynamicField).addClass("No_Required");
                    $("#" + DynamicField).val('');

                    Core.Form.ErrorTooltips.InitTooltip( $("#" + DynamicField), "<p>"+ErrorMessage+"</p>");
                }
                else {

                    $('#' + DynamicField).removeClass("Error");
                    $("#Label" + DynamicField).removeClass("LabelError");
                    $("#" + DynamicField+"ErrorServerError").css("display", "none");  
                    $("#" + DynamicField+"Error").css("display", "none");
                }      
            }
        }
    };

    return TargetNS;
}(Core.Agent.CustomServiceForm || {}));
