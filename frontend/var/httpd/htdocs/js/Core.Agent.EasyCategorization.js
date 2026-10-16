// --
// var/httpd/htdocs/js/Core.Agent.EasyCategorization.js
// Copyright (C) 2019 Service Up http://www.serviceup.com.br
//
// written/edited by:
// * pdias@beonup.com.br
// * gesquetini@beonup.com.br
// * poliveira@serviceup.com.br
// * lcavalheiro@serviceup.com.br
// * dparavani@serviceup.com.br
// * gbolsoni@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

Core.Agent.EasyCategorization = (function (TargetNS) {
	
	var labels = document.getElementsByTagName('label');

	var SLA = null;

	var buttonID = "Acordo de Nível de Serviço:";

	for (var i = 0; i < labels.length; i++){

		if (labels[i].innerHTML == buttonID) {
			SLA = labels[i];
			break;
		}
	}

	var Service = null;
	var buttonID = "Serviço:";

	for (var i = 0; i < labels.length; i++){
		if (labels[i].innerHTML == buttonID) {
			Service = labels[i];
			break;
		}
	}

	Core.InBoxLibrary.ConfigGet("InBox::EasyCategorization::Config", function (Result) {
				
		let ConfigManualSave = JSON.parse(Result.Data).ManualSave;
		
		
			$("#TypeID, #PriorityID, #StateID, #SLAID, #ServiceID, #QueueID, #OwnerID, #ResponsibleID, #LockID").bind('change',function(){
				
				var Data = {
					Action: 'EasyCategorizationAJAXHandler',
					Subaction: 'AJAXUpdate',
					TicketID: $("input[name=TicketID]").val(),
					TypeID: $('#TypeID').val(),
					PriorityID: $('#PriorityID').val(),
					StateID: $('#StateID').val(),
					SLAID: $('#SLAID').val(),
					ServiceID: $('#ServiceID').val(),
					QueueID: $('#QueueID').val(),
					OwnerID: $('#OwnerID').val(),
					ResponsibleID: $('#ResponsibleID').val(),
					LockID: $('#LockID').val(),
				};
			
				Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
					if (!Result){
						Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
					}
					else {
						
						for (var i = 0; i < Result.JSONString.length; i++){
							
							// Fix New version Chrome - INIT
							var tempDiv = $('<div>').html(Result.JSONString[i].Values);

							var options = tempDiv.find('select#'+ Result.JSONString[i].Name+' option');

							$('#' + Result.JSONString[i].Name).empty();
							$('#' + Result.JSONString[i].Name).append(options);

							//$(`#${Result.JSONString[i].Name}`).html(Result.JSONString[i].Values);

							// Fix New version Chrome - END
							$('#' + Result.JSONString[i].Name).show();

							$(`#${Result.JSONString[i].Name}`).closest(".FieldEC").find(".InputField_Container").remove();
							
							$('#' + Result.JSONString[i].Name).data('filters', '');

							Core.UI.InputFields.InitSelect( $('#' + Result.JSONString[i].Name));
						}
					}
				})
			})

			if (ConfigManualSave){

			TargetNS.UpdateForm = function (TicketID) {
				
				let DynamicField = {};

				$(".DynamicFieldEasy").map( 
					(_, element) => {
						let key = $(element).attr("id");
						let value = $(element).val();

						DynamicField[key] = value;
				 });
	
				var Data = {
					Action: 'EasyCategorizationAJAXHandler',
					Subaction: 'UpdateForm',
					DynamicFieldNames: JSON.stringify(DynamicField),
					TicketID: TicketID,
					TypeID: $('#TypeID').val(),
					PriorityID: $('#PriorityID').val(),
					StateID: $('#StateID').val(),
					SLAID: $('#SLAID').val(),
					ServiceID: $('#ServiceID').val(),
					QueueID: $('#QueueID').val(),
					OwnerID: $('#OwnerID').val(),
					ResponsibleID: $('#ResponsibleID').val(),
					LockID: $('#LockID').val(),
				};
	
			
				Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
	
					if (!Result){
						Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
					} else {
						document.location.reload();
					}
				})
			}
		}
      
		TargetNS.DynamicFieldUpdate = function (TicketID, AJAXLoaderID, OutherField) {

			var DynamicFieldValue =  $("#"+AJAXLoaderID).val();
			
			if( OutherField ){
				DynamicFieldValue = $("#DynamicField_"+AJAXLoaderID).val();
			}
			
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'DynamicFieldUpdate',
				DynamicFieldName: AJAXLoaderID,
				DynamicFieldValue: DynamicFieldValue,
				TicketID: TicketID,
				OutherField:  OutherField
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {

				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					$("#AJAXLoader"+AJAXLoaderID).css("display", "none");

					var SelectData = JSON.parse(Result.JSONString);
					UpdateFormElementsFields(SelectData);

					if ($('#ServiceID option').length == 1) {
						$('#ServiceID').attr("readonly", "true");
					}
					else{
						$('#ServiceID_Search').attr("readonly", false);
						$('#ServiceID').attr("readonly", false);
					}

					if ($('#SLAID option').length == 1) {
						$('#SLAID').attr("readonly", "true");
					}
					else{
						$('#SLAID_Search').attr("readonly", false);
						$('#SLAID').attr("readonly", false);
					}

					if ($('#TypeID option').length == 1) {
						$('#TypeID').attr("readonly", "true");
					}
					else{
						$('#TypeID_Search').attr("readonly", false);
						$('#TypeID').attr("readonly", false);
					}

					if ($('#PriorityID option').length == 1) {
						$('#PriorityID').attr("readonly", "true");
					}
					else{
						$('#PriorityID_Search').attr("readonly", false);
						$('#PriorityID').attr("readonly", false);
					}
				}
			});
		}
		TargetNS.DynamicFieldDateUpdate = function (TicketID, AJAXLoaderID) {

			var Checkbox = $('#DynamicField_' + AJAXLoaderID + 'Used');
			var IsCheck = 0; 
			
			if (Checkbox.is(':checked')) {
				IsCheck = 1;
			}
			
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'DynamicFieldDateUpdate',
				DynamicFieldName: AJAXLoaderID,
				DynamicFieldValueDay:    $('#DynamicField_' + AJAXLoaderID + 'Day').val(),
				DynamicFieldValueMonth:  $('#DynamicField_' + AJAXLoaderID + 'Month').val(),
				DynamicFieldValueYear:   $('#DynamicField_' + AJAXLoaderID + 'Year').val(),
				DynamicFieldValueHour:   $('#DynamicField_' + AJAXLoaderID + 'Hour').val(),
				DynamicFieldValueMinute: $('#DynamicField_' + AJAXLoaderID + 'Minute').val(),
				IsCheck:  IsCheck,
				TicketID: TicketID,
			};
			

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {

				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					$("#AJAXLoader"+AJAXLoaderID).css("display", "none");

					var SelectData = JSON.parse(Result.JSONString);
					UpdateFormElementsFields(SelectData);

					if ($('#ServiceID option').length == 1) {
						$('#ServiceID').attr("readonly", "true");
					}
					else{
						$('#ServiceID_Search').attr("readonly", false);
						$('#ServiceID').attr("readonly", false);
					}

					if ($('#SLAID option').length == 1) {
						$('#SLAID').attr("readonly", "true");
					}
					else{
						$('#SLAID_Search').attr("readonly", false);
						$('#SLAID').attr("readonly", false);
					}

					if ($('#TypeID option').length == 1) {
						$('#TypeID').attr("readonly", "true");
					}
					else{
						$('#TypeID_Search').attr("readonly", false);
						$('#TypeID').attr("readonly", false);
					}

					if ($('#PriorityID option').length == 1) {
						$('#PriorityID').attr("readonly", "true");
					}
					else{
						$('#PriorityID_Search').attr("readonly", false);
						$('#PriorityID').attr("readonly", false);
					}
				}
			});
		}

		TargetNS.TypeUpdate = function (TicketID) {
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'TypeUpdate',
				TypeID: $('#TypeID').val(),
				ServiceID: $('#ServiceID').val(),
				TicketID: TicketID,
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{

					var SelectData = JSON.parse(Result.JSONString);
					
					UpdateFormElements(SelectData);

					$("#AJAXLoaderTypeID").css("display", "none");

					if ($('#ServiceID option').length == 1) {
						$('#ServiceID').attr("readonly", "true");
					}
					else{
						$('#ServiceID').attr("readonly", "false");
					}
				}
			});
		}

		/**
		 * @name StateUpdate
		 * @memberof Core.Agent.EasyCategorization
		 * @function
		 * @param {String}
		 * @description
		 *      This function gets service data.
		 */
		
		TargetNS.StateUpdate = function (TicketID) {
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'StateUpdate',
				StateID: $('#StateID').val(),
				TicketID: TicketID,
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					var SelectData = JSON.parse(Result.JSONString);

					UpdateFormElements(SelectData);

					$("#AJAXLoaderStateID").css("display", "none");

					if ($('#StateID option').length == 1) {
						$('#StateID').attr("readonly", "true");
					}
					else{
						$('#StateID').attr("readonly", "false");
					}

					// location.reload();
				}
			});
		}


		/**
		 * @name ServiceUpdate
		 * @memberof Core.Agent.EasyCategorization
		 * @function
		 * @param {String}
		 * @description
		 *      This function gets service data.
		 */

		TargetNS.ServiceUpdate = function (TicketID) {
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'ServiceUpdate',
				ServiceID: $('#ServiceID').val(),
				SLAID: $('#SLAID').val(),
				PriorityID: $('#PriorityID').val(),
				TicketID: TicketID,
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					var SelectData = JSON.parse(Result.JSONString);
					
					UpdateFormElements(SelectData);
					$("#AJAXLoaderServiceID").css("display", "none");

					if ($('#SLAID option').length == 1) {
						$('#SLAID').attr("readonly", "true");
					}
					else{
						$('#SLAID_Search').attr("readonly", false);
						$('#SLAID').attr("readonly", false);
					}
				}
			});
		}

		/**
		 * @name SLAUpdate
		 * @memberof Core.Agent.EasyCategorization
		 * @function
		 * @param {String}
		 * @description
		 *      This function gets service data.
		 */

		TargetNS.SLAUpdate = function (TicketID) {
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'SLAUpdate',
				SLAID: $('#SLAID').val(),
				TicketID: TicketID,
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {

				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					$("#AJAXLoaderSLAID").css("display", "none");
				}

			});
		}

		/**
		 * @name PriorityUpdate
		 * @memberof Core.Agent.EasyCategorization
		 * @function
		 * @param {String}
		 * @description
		 *      This function gets service data.
		 */

		TargetNS.PriorityUpdate = function (TicketID) {
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'PriorityUpdate',
				PriorityID: $('#PriorityID').val(),
				TicketID: TicketID,
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					$("#AJAXLoaderPriorityID").css("display", "none");
				}
			});
		}

		/**
		 * @name QueueUpdate
		 * @memberof Core.Agent.EasyCategorization
		 * @function
		 * @param {String}
		 * @description
		 *      This function gets queue data.
		 */
		
		TargetNS.QueueUpdate = function (TicketID) {
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'QueueUpdate',
				QueueID: $('#QueueID').val(),
				OwnerID: $('#OwnerID').val(),
				TicketID: TicketID,
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					var SelectData = JSON.parse(Result.JSONString);

					UpdateFormElements(SelectData);

					$("#AJAXLoaderQueueID").css("display", "none");

					if ($('#QueueID option').length == 1) {
						$('#QueueID').attr("readonly", "true");
					}
					else{
						$('#QueueID').attr("readonly", "false");
					}
				}
			});
		}
		
		/**
		 * @name OwnerUpdate
		 * @memberof Core.Agent.EasyCategorization
		 * @function
		 * @param {String}
		 * @description
		 *      This function gets owner data.
		 */
		
		TargetNS.OwnerUpdate = function (TicketID) {
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'OwnerUpdate',
				OwnerID: $('#OwnerID').val(),
				TicketID: TicketID,
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					var SelectData = JSON.parse(Result.JSONString);

					UpdateFormElements(SelectData);

					$("#AJAXLoaderOwnerID").css("display", "none");

					if ($('#OwnerID option').length == 1) {
						$('#OwnerID').attr("readonly", "true");
					}
					else{
						$('#OwnerID').attr("readonly", "false");
					}
				}
			});
		}
		
		/**
		 * @name ResponsibleUpdate
		 * @memberof Core.Agent.EasyCategorization
		 * @function
		 * @param {String}
		 * @description
		 *      This function gets responsible data.
		 */
		
		TargetNS.ResponsibleUpdate = function (TicketID) {
			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'ResponsibleUpdate',
				ResponsibleID: $('#ResponsibleID').val(),
				TicketID: TicketID,
			};
		
			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
				if (!Result) {
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else {
					var SelectData = JSON.parse(Result.JSONString);
					UpdateFormElements(SelectData);
					$("#AJAXLoaderResponsibleID").css("display", "none");
		
					if ($('#ResponsibleID option').length == 1) {
						$('#ResponsibleID').attr("readonly", "true");
					}
					else {
						$('#ResponsibleID').attr("readonly", "false");
					}
				}
			});
		};		

		/**
    	 * @name LockUpdate
    	 * @memberof Core.Agent.EasyCategorization
    	 * @function
    	 * @param {String}
    	 * @description
    	 *      This function gets lock data.
    	 */

		 TargetNS.LockUpdate = function (TicketID) {

			var Data = {
				Action: 'EasyCategorizationAJAXHandler',
				Subaction: 'LockUpdate',
				LockID: $('#LockID').val(),
				TicketID: TicketID,
			};

			Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
				if (!Result){
					Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
				}
				else{
					var SelectData = JSON.parse(Result.JSONString);
	
					UpdateFormElements(SelectData);
	
					$("#AJAXLoaderLockID").css("display", "none");
	
					if ($('#LockID option').length == 1) {
						$('#LockID').attr("readonly", "true");
					}
					else{
						$('#LockID').attr("readonly", "false");
					}
				
					// location.reload(true);
				}
			});
		}

		/**
		 * @private
		 * @name UpdateFormElements
		 * @function
		 * @param {Object} Data - The new field data. The keys are the IDs of the fields to be updated.
		 * @description
		 *      Updates the given fields with the given data.
		 */

		function UpdateFormElementsFields(Data) {

			$.each(Data, function (Field, DataValue) {

				var $Element = $('#' + Field);
				var OlderValue = $Element.val();
				var OlderValueFlag = 0;

				// Select elements
				if ($Element.is('select')) {
					
					$Element.empty();

					$.each(DataValue, function (Index, Value) {					
						
						if(Field != 'ServiceID'){
							var NewOption;

							NewOption = "<option>"+Value+"</option>";
		
							$Element.append(NewOption);
							$Element.append('<option value='+ Index +' >' + Value + '</option>');		
							
							if(Value[0] == OlderValue){
								OlderValueFlag = 1;
							}
						}
					});

					RestoreFieldTreeViewFields($Element, DataValue, '' , 1);				
					
					if(OlderValueFlag == '1'){
						$('#'+Field).val(OlderValue);
					}else{
						$('#'+Field).val('');
					}

					$('#'+Field + ' option[value="' + OlderValue + '"]').attr('selected','selected');

					// Trigger custom redraw event for InputFields
					if ($Element.hasClass('Modernize')) {

						$Element.trigger('redraw.InputField');
					}

					return;
				}
			});
		}


	/**
	 * @private
	 * @name UpdateFormElements
	 * @function
	 * @param {Object} Data - The new field data. The keys are the IDs of the fields to be updated.
	 * @description
	 *      Updates the given fields with the given data.
	 */

		function UpdateFormElements(Data) {

			$.each(Data, function (Field, DataValue) {

				var $Element = $('#' + Field);
				
				// // Select elements
				// if ($Element.is('select')) {
					
				// 	$Element.empty();
				// 	$.each(DataValue, function (Index, Value) {

				// 		var NewOption,
				// 			OptionText = Core.App.EscapeHTML(Value[1]),
				// 			OptionText = TruncateText(OptionText);
				// 			DataValue[Index][1] = TruncateText(DataValue[Index][1]);

				// 		NewOption = new Option(OptionText, Value[0], Value[2], Value[3]);

				// 		// Overwrite option text, because of wrong html quoting of text content.
				// 		// (This is nee ded for IE.)

				// 		NewOption.innerHTML = NewOption;
				// 		$Element.append(NewOption);

				// 	});

				// 	RestoreFieldTreeView($Element, DataValue, '' , 1);

				// 	// Trigger custom redraw event for InputFields
				// 	if ($Element.hasClass('Modernize')) {
				// 		$Element.trigger('redraw.InputField');
				// 	}1

				// 	return;
				// }

				// Select elements
				if ($Element.is('select')) {
					$Element.empty();
					$.each(DataValue, function (Index, Value) {
						var NewOption,
							OptionText = Core.App.EscapeHTML(Value[1]);

						NewOption = new Option(OptionText, Value[0], Value[2], Value[3]);

						// Check if option must be disabled.
						if (Value[4]) {
							NewOption.disabled = true;
						}

						// Overwrite option text, because of wrong html quoting of text content.
						// (This is needed for IE.)
						NewOption.innerHTML = OptionText;
						$Element.append(NewOption);

					});
					
					RestoreFieldTreeView($Element, DataValue, '' , 1);

					// Trigger custom redraw event for InputFields
					if ($Element.hasClass('Modernize')) {
						$Element.trigger('redraw.InputField');
					}

					return;
				}
			});
		}

		/**
		 * @name TruncateText
		 * @memberof Core.Agent.EasyCategorization
		 * @function
		 * @param {String}
		 * @description
		 *      This function gets the string and truncate it to show only the firsts 29 chars and  [...] with them.
		 */
		function TruncateText (value) {
			if (value.length > 29) {
				var shortString = value.substring(0,29);
				return shortString + '[...]';
			}else{
				return value;
			}
		}

		/**
		 * @name RestoreDynamicFieldValueTreeView
		 * @memberof Core.UI.TreeSelectIC
		 * @function
		 * @returns {Boolean} False on error.
		 * @param {jQueryObject} $FieldObj
		 * @param {Array} Data
		 * @param {Boolean} CheckClass
		 * @param {Number} AJAXUpdate
		 * @description
		 *      Restores tree view (intended values) for dynamic fields.
		 */
		function RestoreFieldTreeView($FieldObj, Data, CheckClass, AJAXUpdate) {

			var Key,
				Value,
				Selected,
				SelectedAttr,
				Disabled,
				DisabledAttr,
				SelectData = [],
				NeededSpaces,
				Spaces,
				i;

			if (CheckClass && $FieldObj.hasClass('TreeViewRestored')) {
				return false;
			}

			$FieldObj.find('option').remove();

			$.each(Data, function(index, OptionData) {
				Key = OptionData[0] || '';
				Value = OptionData[1] || '';
				Spaces = '';
				NeededSpaces = 0;
				Selected = OptionData[2] || false;
				Disabled = OptionData[3] || false;

				if (AJAXUpdate === 1) {
					Selected = OptionData[3];
					Disabled = OptionData[4];
				}

				if (Value.match(/::/g)) {
					NeededSpaces = Value.match(/::/g).length;
				}

				if (NeededSpaces > 0) {
					NeededSpaces = NeededSpaces * 2;
					for (i = 0; i < NeededSpaces; i++) {
						Spaces = '&nbsp;' + Spaces;
					}
				}

				const parts = Value.split('::');
				Value = parts.pop();

				Value = Spaces + Value;

				SelectedAttr = '';
				if (Selected) {
					SelectedAttr = ' selected="selected"';
				}

				DisabledAttr = '';
				if (Disabled) {
					DisabledAttr = ' disabled="disabled"';
				}

				SelectData.push({
					'Key': Key,
					'Value': Value,
					'SelectedAttr': SelectedAttr,
					'DisabledAttr': DisabledAttr
				});
			});

			$.each(SelectData, function(index, SelectedData) {
				$FieldObj.append('<option value="' + SelectedData.Key + '"' + SelectedData.SelectedAttr + SelectedData.DisabledAttr + '>' + SelectedData.Value + '</option>');
			});

			$FieldObj.addClass('TreeViewRestored');
		};

		/**
		 * @name RestoreDynamicFieldValueTreeView
		 * @memberof Core.UI.TreeSelectIC
		 * @function
		 * @returns {Boolean} False on error.
		 * @param {jQueryObject} $FieldObj
		 * @param {Array} Data
		 * @param {Boolean} CheckClass
		 * @param {Number} AJAXUpdate
		 * @description
		 *      Restores tree view (intended values) for dynamic fields.
		 */
		function RestoreFieldTreeViewFields ($FieldObj, Data, CheckClass, AJAXUpdate) {

			var Key,
				Value,
				Selected,
				SelectedAttr,
				Disabled,
				DisabledAttr,
				SelectData = [],
				NeededSpaces,
				Spaces,
				i;

			if (CheckClass && $FieldObj.hasClass('TreeViewRestored')) {
				return false;
			}

			$FieldObj.find('option').remove();

			$.each(Data, function(index, OptionData) {

				Key = OptionData[0] || '';
				Value = OptionData[1] || '';
				Spaces = '';
				NeededSpaces = 0;
				Selected = OptionData[2] || false;
				Disabled = OptionData[3] || false;

				if (AJAXUpdate === 1) {
					Selected = OptionData[3];
					Disabled = OptionData[4];
				}

				if (Key.match(/::/g)) {
					NeededSpaces = Key.match(/::/g).length;
				}

				if (NeededSpaces > 0) {
					NeededSpaces = NeededSpaces * 2;
					for (i = 0; i < NeededSpaces; i++) {
						Spaces = '&nbsp;' + Spaces;
					}
				}
				Value = Spaces + Value;

				SelectedAttr = '';
				if (Selected) {
					SelectedAttr = ' selected="selected"';
				}

				// DisabledAttr = '';
				// if (Disabled) {
				//     DisabledAttr = ' disabled="disabled"';
				// }

				SelectData.push({
					'Key': Key,
					'Value': Value,
					'SelectedAttr': SelectedAttr,
					'DisabledAttr': DisabledAttr
				});
			});

			SelectData.sort(function(a, b) {

				var KeyA = a.Key.toLowerCase(),
					KeyB = b.Key.toLowerCase();

				if (KeyA < KeyB) {
				return -1;
				}
				if (KeyA > KeyB) {
				return 1;
				}
				return 0;
			});

			$.each(SelectData, function(index, SelectedData) {
				$FieldObj.append('<option value="' + SelectedData.Key + '"' + SelectedData.SelectedAttr + SelectedData.DisabledAttr + '>' + SelectedData.Value + '</option>');
			});

			$FieldObj.addClass('TreeViewRestored');
		};

});

	Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');
	
    return TargetNS;
}(Core.Agent.EasyCategorization || {}));
