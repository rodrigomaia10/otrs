// --
// var/httpd/htdocs/js/Core.Agent.ServiceTemplate.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Agent.ServiceTemplate
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for ServiceTemplate module.
 */
 Core.Agent.Service = (function (TargetNS) {

    var AJAXLoaderPrefix = 'AJAXLoader', ActiveAJAXCalls = {};

    const myInterval = setInterval(function () {

        if ( $('#ServiceID').length ) {

            $('#ServiceID').bind('change', function (Event) {

                var ServiceID = $(this).val();

                TargetNS.Init(ServiceID);
            });

            clearInterval(myInterval);
        }

    }, 1000);

    /*
    * @name Init
    * @memberof Core.Agent.ServiceTemplate
    * @function
    * @description
    *      This function initializes table filter.
    */
    TargetNS.Init = function (ServiceID) {

        var Data = {
            Action: 'ServiceTemplateAJAXHandler',
            Subaction: 'ServiceUpdate',
            ServiceID: ServiceID
        };

        var $RichTextElement = $('#RichText'),
		$SubjectElement =  $('#Subject'),
		Content = '';

        // Fallback for non-richtext content
        Content = $RichTextElement.val();

        // get RTE content
        if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances['RichText']) {
            Content = CKEDITOR.instances['RichText'].getData();
        }

        // if content already exists let user confirm to really overwrite that content with a template
        if ( Content.length &&
            !window.confirm( Core.Language.Translate('Setting up a new service will overwrite any text. Do you really want to continue?') )
        ) {
            // if user cancels confirmation, reset template selection
            $('#ServiceID').val(ServiceID).trigger('redraw');
        }
        else {
            
            ToggleAJAXLoader('Subject', true);

            Core.AJAX.FunctionCall( Core.Config.Get('CGIHandle'), Data, function (Response) {

                if(Response.Text && Response.Subject){

					$SubjectElement.val(Response.Subject);

					UpdateTextarea($RichTextElement, Response.Text);
				}
				else {

					$SubjectElement.val('');

					UpdateTextarea($RichTextElement, '');
				}

				ToggleAJAXLoader('Subject', false);

                $.each( Response.Fields, function( Field, value ) {

                    if ( $('#' + Field).length ) {

                        if ( value != null ) {

                            $('#' + Field).val(value);
                            $('#' + Field).trigger('change');

                            if ( $('#' + Field + '_Search').length ) {
                                $('#' + Field + '_Search').hide();
                                
                                $( '<input type="text" class="DynamicFieldText " id="TemporaryField_'+Field+'" name="TemporaryField_'+Field+'" title="'+value+'" value="'+value+'" readonly="readonly" aria-invalid="false">' ).insertAfter( '#' + Field + '_Search');
                                $("#TemporaryField_"+Field).attr('size', $("#TemporaryField_"+Field).val().length - 3);
                                $('#TemporaryField_'+Field).next().remove();
                            }
                        }
                        else {

                            $('#' + Field + '_Search').show();
                            $("#TemporaryField_"+Field).remove();
                        }
                    }
                });
            });
        }
    };

    /**
     * @private
     * @name UpdateTextarea
     * @memberof Core.AJAX
     * @function
     * @param {Object} $Element - the field selector.
     * @param {Object} Value - the field value. The keys are the IDs of the fields to be updated.
     * @description
     *      Inserts value in textarea components or RichText editors for the ajax requests.
     */
    function UpdateTextarea($Element, Value) {
        var $ParentBody,
            ParentBody,
            Range,
            StartRange = 0,
            NewPosition = 0,
            CKEditorObj = parent.CKEDITOR;

        if ($Element.length) {
            $ParentBody = $Element;
            ParentBody = $ParentBody[0];

            // for regular popups, parent is a reference to the popup itself, which is why parent.CKEDITOR is a reference to the CKEDITOR
            // object of the popup window. But if we're on a mobile environment, the popup would instead open as an iframe, which would cause
            // parent.CKEDITOR to be the CKEDITOR object of the parent window which contains the iframe. This is why we want to use only
            // CKEDITOR in this case (see bug#12680).
            if (Core.App.Responsive.IsSmallerOrEqual(Core.App.Responsive.GetScreenSize(), 'ScreenL') && (!localStorage.getItem("DesktopMode") || parseInt(localStorage.getItem("DesktopMode"), 10) <= 0)) {
                CKEditorObj = CKEDITOR;
            }

            // add the text to the RichText editor
            if (CKEditorObj && CKEditorObj.instances.RichText) {
                CKEditorObj.instances.RichText.focus();
                window.setTimeout(function () {

                    // In some circumstances, this command throws an error (although inserting the HTML works)
                    // Because the intended functionality also works, we just wrap it in a try-catch-statement
                    try {

                        // set new text
                        CKEditorObj.instances.RichText.setData(Value);
                    }
                    catch (Error) {
                        $.noop();
                    }
                }, 100);
                return;
            }

            // insert body and/or link to textarea (if possible to cursor position otherwise to the top)
            else {

                // Get previously saved cursor position of textarea
                if ($Element.parent().data('Cursor')) {
                    StartRange = parent.$Element.data('Cursor').StartRange;
                }

                // Add new text to textarea
                $ParentBody.val(Value);
                NewPosition = StartRange + Value.length;

                // Jump to new cursor position (after inserted text)
                if (ParentBody.selectionStart) {
                    ParentBody.selectionStart = NewPosition;
                    ParentBody.selectionEnd = NewPosition;
                }
                else if (document.selection) {
                    Range = document.selection.createRange().duplicate();
                    Range.moveStart('character', NewPosition);
                    Range.select();
                }

                return;
            }
        }
        else {
            alert('$JSText{"This window must be called from compose window"}');
            return;
        }
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

    return TargetNS;
}(Core.Agent.ServiceTemplate || {}));
