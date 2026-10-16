// --
// var/httpd/htdocs/js/Core.Agent.Admin.CustomServiceForm.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * dsilva@serviceup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.CustomServiceForm
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for AdminCustomServiceForm module.
 */
 Core.Agent.Admin.CustomServiceForm = (function (TargetNS) {

     /**
      * @name Init
      * @memberof Core.Agent.Admin.CustomServiceForm
      * @function
      * @description
      *      This function initializes the module functionality.
      */

    TargetNS.Init = function () {

        // Initialize filter
        Core.UI.Table.InitTableFilter($('#FilterForms'), $('#Forms'));
        
        function UpdateFields(Event, UI) {
            var Fieldname,
                DefaultFieldConfig = {};

			// if the element was removed from the AssignedFields list, remove FieldDetails data
            if (UI.sender.attr('id') === 'AssignedFields') {
                //Core.UI.Table.InitTableFilter($('#FilterAvailableFields'), $('#AvailableFields'));
                $(UI.item)
                    .removeData('config')
                    .removeAttr('data-config');
            }
            // otherwise, force the user to enter data in the modal dialog
            else {
                Fieldname = $.trim($(UI.item).data('id'));

                // if Field is Mandatory set Display to "Show As Mandatory" as default
                if ($.inArray(Fieldname) > -1) {
                    DefaultFieldConfig.Display = "2";
                }
                else {
                    DefaultFieldConfig.Display = "1";
                }

                $(UI.item).data('config', Core.JSON.Stringify(DefaultFieldConfig)).find('.FieldDetailsOverlay').trigger('click');
            }
        }

        // Initialize Allocation List
        Core.UI.AllocationList.Init("#AvailableFields, #AssignedFields", ".AllocationList", UpdateFields);

        $('#Submit').bind('click', function() {
            // $('#CustomServiceForm').submit();
            SendForm();
            return false;
        });

        // Core.Form.Validate.SetSubmitFunction($('#CustomServiceForm'), function (Form) {
        function SendForm () {

            var FieldConfig = Core.UI.AllocationList.GetResult('#AssignedFields', 'id'),
            FieldDetails = {};

            // get FieldDetails and add them to config
            $('#AssignedFields').find('li').each(function () {

                var Details,
                ConfigValue = $(this).data('config'),
                Field = $(this).data('id');

                if (typeof ConfigValue === 'string') {
                    Details = Core.JSON.Parse(ConfigValue);
                }
                else {
                    Details = ConfigValue;
                }

                FieldDetails[Field] = Details;
            });

            // get assigned activity dialogs
            $('input[name=Fields]').val(Core.JSON.Stringify(FieldConfig));
            $('input[name=FieldDetails]').val(Core.JSON.Stringify(FieldDetails));


            // not needed for normal submit
            $(window).unbind("beforeunload.PMPopup");

            $('#CustomServiceForm').submit();
            //Form.submit();
        // });
        };

		// Init Fields modal overlay
		$('.FieldDetailsOverlay').unbind('click').bind('click', function () {

			var FieldConfig = $(this).closest('li').data('config'),
			$Element = $(this),
			Fieldname = $.trim($(this).closest('li').data('id')),
			FieldNameTranslated = $('.AllocationList').find('li[data-id="' + Fieldname + '"]').data('name-translated'),
			FieldType = $(this).closest('li').data('type');

			if (typeof FieldConfig === 'string') {
				FieldConfig = Core.JSON.Parse(FieldConfig);
			}

			// Open dialog
			Core.UI.Dialog.ShowContentDialog(

				$('#Dialogs #FieldDetails'),
				Core.Language.Translate('Edit Field Details') + ': ' + FieldNameTranslated,
				'200px',
				'Center',
				true,
				[
					{
						Label: Core.Language.Translate('Save'),
						Class: 'Primary',
						Function: function () {
							var FieldConfigElement = {};

							FieldConfigElement.DescriptionShort = $('#DescShort').val();
							FieldConfigElement.DefaultValue = $('#DefaultValue').val();
							FieldConfigElement.Display = $('#Display').val();

							if(FieldType === 'Text') {
								FieldConfigElement.Mask = $('#Mask').val();
							}
							else {
								FieldConfigElement.Mask = '';
							}

							$Element.closest('li').data('config', Core.JSON.Stringify(FieldConfigElement));

							Core.UI.Dialog.CloseDialog($('.Dialog'));
						}
					},
					{
						Label: Core.Language.Translate('Cancel'),
						Function: function () {
							Core.UI.Dialog.CloseDialog($('.Dialog'));
						}
					}
				]
			);

			// some fields must be mandatory, if they are present.
			// remove option from dropdown for these fields
			// set "Show As Mandatory" as default
			if ($.inArray(Fieldname) > -1) {
				$('#Display')
					.find('option[value=1]').remove()
					.end()
					.val('2');
			}
			// otherwise set "Show Field" as default
			else {
				$('#Display').val('1');
			}

			// if there is a field config already the default settings from above are now overwritten
			if (typeof FieldConfig !== 'undefined') {

				$('#DescShort').val(FieldConfig.DescriptionShort);
				$('#Mask').val(FieldConfig.Mask);
				$('#DefaultValue').val(FieldConfig.DefaultValue);

				if (typeof FieldConfig.Display !== 'undefined') {
					$('#Display').val(FieldConfig.Display);
				}
			}

			// redraw display field
			$('#Display').trigger('redraw.InputField');

			if (FieldType === 'Text') {

				$('#MaskContainer').removeClass('Hidden');
				$('#MaskContainer').prev('label').css('display', 'block');
				$('#MaskContainer .Modernize').trigger('redraw.InputField');
			}
			else {
                $('#MaskContainer').addClass('Hidden');
                $('#MaskContainer').prev('label').css('display', 'none');
            }

			return false;
		});
    };

    /**
     * @name FormCopy
     * @memberof Core.Agent.Admin.CustomServiceForm
     * @function
     * @description
     *      Bind event on form copy button.
     */    
    $('.FormCopy').on('click', function (Event) {
           
        Core.AJAX.FunctionCall(
            Core.Config.Get('Baselink'),
            $(this).data('query-string') + 'Confirmed=1;',                    
            function() {
                window.location.reload();
            }
        );
        
        Event.stopPropagation();
        Event.preventDefault();

        return false;
    });

    function InitProcessPopups() {

        $('a.AsPopup').bind('click', function () {
            var Matches,
            PopupType = 'Process';

            Matches = $(this).attr('class').match(/PopupType_(\w+)/);

            if (Matches) {
                PopupType = Matches[1];
            }

            if (PopupType !== 'ProcessOverview') {
                TargetNS.ShowOverlay();
            }

            Core.UI.Popup.OpenPopup($(this).attr('href'), PopupType);

            return false;
        });

        $('a.AsPopup_Redirect').bind('click', function () {

            var $Form = $(this).closest('form');

            $('#PopupRedirect').val(1);
            $('#PopupRedirectAction').val($(this).data('action'));
            $('#PopupRedirectSubaction').val($(this).data('subaction'));
            $('#PopupRedirectID').val($(this).data('id'));

            // Only used for path popup
            $('#PopupRedirectStartActivityID').val($(this).data('startactivityid'));

            if ($(this).hasClass('Edit_Confirm')) {

                if (window.confirm(Core.Language.Translate.EditConfirm)) {

                    // Remove onbeforeunload event only if there is no validation pending on form submit
                    if (!($Form.hasClass("Validate"))) {
                        $(window).unbind("beforeunload.PMPopup");
                    }

                    $(this).closest('form').submit();
                }
            }
            else {

                // Remove onbeforeunload event only if there is no validation pending on form submit
                if (!($Form.hasClass("Validate"))) {
                    $(window).unbind("beforeunload.PMPopup");
                }

                $(this).closest('form').submit();
            }

            return false;
        });

        $('a.GoBack').bind('click', function () {
            // Remove onbeforeunload event (which is only needed if you close the popup via the window "X")
            $(window).unbind("beforeunload.PMPopup");
        });
    }

	InitProcessPopups();

	// Init handling of closing popup with the OS functionality ("X")
	$(window).unbind("beforeunload.PMPopup").bind("beforeunload.PMPopup", function () {
		// window.opener.Core.Agent.Admin.ProcessManagement.HandlePopupClose();
	});

	$('.ClosePopup').bind("click", function () {
		$(window).unbind("beforeunload.PMPopup");
	});

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.CustomServiceForm || {}));