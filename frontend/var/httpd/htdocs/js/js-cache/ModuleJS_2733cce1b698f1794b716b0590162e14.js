// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.Admin=Core.Agent.Admin||{};Core.Agent.Admin.CustomServiceForm=(function(TargetNS){TargetNS.Init=function(){Core.UI.Table.InitTableFilter($('#FilterForms'),$('#Forms'));function UpdateFields(Event,UI){var Fieldname,DefaultFieldConfig={};if(UI.sender.attr('id')==='AssignedFields'){$(UI.item)
.removeData('config')
.removeAttr('data-config');}
else{Fieldname=$.trim($(UI.item).data('id'));if($.inArray(Fieldname)>-1){DefaultFieldConfig.Display="2";}
else{DefaultFieldConfig.Display="1";}
$(UI.item).data('config',Core.JSON.Stringify(DefaultFieldConfig)).find('.FieldDetailsOverlay').trigger('click');}}
Core.UI.AllocationList.Init("#AvailableFields, #AssignedFields",".AllocationList",UpdateFields);$('#Submit').bind('click',function(){SendForm();return false;});function SendForm(){var FieldConfig=Core.UI.AllocationList.GetResult('#AssignedFields','id'),FieldDetails={};$('#AssignedFields').find('li').each(function(){var Details,ConfigValue=$(this).data('config'),Field=$(this).data('id');if(typeof ConfigValue==='string'){Details=Core.JSON.Parse(ConfigValue);}
else{Details=ConfigValue;}
FieldDetails[Field]=Details;});$('input[name=Fields]').val(Core.JSON.Stringify(FieldConfig));$('input[name=FieldDetails]').val(Core.JSON.Stringify(FieldDetails));$(window).unbind("beforeunload.PMPopup");$('#CustomServiceForm').submit();};$('.FieldDetailsOverlay').unbind('click').bind('click',function(){var FieldConfig=$(this).closest('li').data('config'),$Element=$(this),Fieldname=$.trim($(this).closest('li').data('id')),FieldNameTranslated=$('.AllocationList').find('li[data-id="'+Fieldname+'"]').data('name-translated'),FieldType=$(this).closest('li').data('type');if(typeof FieldConfig==='string'){FieldConfig=Core.JSON.Parse(FieldConfig);}
Core.UI.Dialog.ShowContentDialog($('#Dialogs #FieldDetails'),Core.Language.Translate('Edit Field Details')+': '+FieldNameTranslated,'200px','Center',true,[{Label:Core.Language.Translate('Save'),Class:'Primary',Function:function(){var FieldConfigElement={};FieldConfigElement.DescriptionShort=$('#DescShort').val();FieldConfigElement.DefaultValue=$('#DefaultValue').val();FieldConfigElement.Display=$('#Display').val();if(FieldType==='Text'){FieldConfigElement.Mask=$('#Mask').val();}
else{FieldConfigElement.Mask='';}
$Element.closest('li').data('config',Core.JSON.Stringify(FieldConfigElement));Core.UI.Dialog.CloseDialog($('.Dialog'));}},{Label:Core.Language.Translate('Cancel'),Function:function(){Core.UI.Dialog.CloseDialog($('.Dialog'));}}]);if($.inArray(Fieldname)>-1){$('#Display')
.find('option[value=1]').remove()
.end()
.val('2');}
else{$('#Display').val('1');}
if(typeof FieldConfig!=='undefined'){$('#DescShort').val(FieldConfig.DescriptionShort);$('#Mask').val(FieldConfig.Mask);$('#DefaultValue').val(FieldConfig.DefaultValue);if(typeof FieldConfig.Display!=='undefined'){$('#Display').val(FieldConfig.Display);}}
$('#Display').trigger('redraw.InputField');if(FieldType==='Text'){$('#MaskContainer').removeClass('Hidden');$('#MaskContainer').prev('label').css('display','block');$('#MaskContainer .Modernize').trigger('redraw.InputField');}
else{$('#MaskContainer').addClass('Hidden');$('#MaskContainer').prev('label').css('display','none');}
return false;});};$('.FormCopy').on('click',function(Event){Core.AJAX.FunctionCall(Core.Config.Get('Baselink'),$(this).data('query-string')+'Confirmed=1;',function(){window.location.reload();});Event.stopPropagation();Event.preventDefault();return false;});function InitProcessPopups(){$('a.AsPopup').bind('click',function(){var Matches,PopupType='Process';Matches=$(this).attr('class').match(/PopupType_(\w+)/);if(Matches){PopupType=Matches[1];}
if(PopupType!=='ProcessOverview'){TargetNS.ShowOverlay();}
Core.UI.Popup.OpenPopup($(this).attr('href'),PopupType);return false;});$('a.AsPopup_Redirect').bind('click',function(){var $Form=$(this).closest('form');$('#PopupRedirect').val(1);$('#PopupRedirectAction').val($(this).data('action'));$('#PopupRedirectSubaction').val($(this).data('subaction'));$('#PopupRedirectID').val($(this).data('id'));$('#PopupRedirectStartActivityID').val($(this).data('startactivityid'));if($(this).hasClass('Edit_Confirm')){if(window.confirm(Core.Language.Translate.EditConfirm)){if(!($Form.hasClass("Validate"))){$(window).unbind("beforeunload.PMPopup");}
$(this).closest('form').submit();}}
else{if(!($Form.hasClass("Validate"))){$(window).unbind("beforeunload.PMPopup");}
$(this).closest('form').submit();}
return false;});$('a.GoBack').bind('click',function(){$(window).unbind("beforeunload.PMPopup");});}
InitProcessPopups();$(window).unbind("beforeunload.PMPopup").bind("beforeunload.PMPopup",function(){});$('.ClosePopup').bind("click",function(){$(window).unbind("beforeunload.PMPopup");});Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.Admin.CustomServiceForm||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.UI=Core.UI||{};Core.UI.AllocationList=(function(TargetNS){if(!Core.Debug.CheckDependency('Core.UI.AllocationList','$([]).sortable','jQuery UI sortable')){return false;}
TargetNS.GetResult=function(ResultListSelector,DataAttribute){var $List=$(ResultListSelector),Result=[];if(!$List.length||!$List.find('li').length){return[];}
$List.find('li').each(function(){var Value=$(this).data(DataAttribute);if(typeof Value!=='undefined'){Result.push(Value);}});return Result;};TargetNS.Init=function(ListSelector,ConnectorSelector,ReceiveCallback,RemoveCallback,SortStopCallback){var $Lists=$(ListSelector);if(!$Lists.length){return;}
$Lists
.find('li').removeClass('Even').end()
.sortable({connectWith:ConnectorSelector,receive:function(Event,UI){if($.isFunction(ReceiveCallback)){ReceiveCallback(Event,UI);}},remove:function(Event,UI){if($.isFunction(RemoveCallback)){RemoveCallback(Event,UI);}},stop:function(Event,UI){if($.isFunction(SortStopCallback)){SortStopCallback(Event,UI);}}}).disableSelection();};return TargetNS;}(Core.UI.AllocationList||{}));
