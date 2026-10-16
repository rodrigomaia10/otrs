// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.UI=Core.UI||{};Core.UI.AllocationList=(function(TargetNS){if(!Core.Debug.CheckDependency('Core.UI.AllocationList','$([]).sortable','jQuery UI sortable')){return false;}
TargetNS.GetResult=function(ResultListSelector,DataAttribute){var $List=$(ResultListSelector),Result=[];if(!$List.length||!$List.find('li').length){return[];}
$List.find('li').each(function(){var Value=$(this).data(DataAttribute);if(typeof Value!=='undefined'){Result.push(Value);}});return Result;};TargetNS.Init=function(ListSelector,ConnectorSelector,ReceiveCallback,RemoveCallback,SortStopCallback){var $Lists=$(ListSelector);if(!$Lists.length){return;}
$Lists
.find('li').removeClass('Even').end()
.sortable({connectWith:ConnectorSelector,receive:function(Event,UI){if($.isFunction(ReceiveCallback)){ReceiveCallback(Event,UI);}},remove:function(Event,UI){if($.isFunction(RemoveCallback)){RemoveCallback(Event,UI);}},stop:function(Event,UI){if($.isFunction(SortStopCallback)){SortStopCallback(Event,UI);}}}).disableSelection();};return TargetNS;}(Core.UI.AllocationList||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.Overview=(function(TargetNS){TargetNS.Init=function(){var Profile=Core.Config.Get('Profile'),View=Core.Config.Get('View'),TicketID,ActionRowTickets=Core.Config.Get('ActionRowTickets')||{};$('ul.Actions form > label').off("click").on("click",function(){return false;});$('ul.Actions form > select').off("change").on("change",function(){var URL;if($(this).val()!=='0'){if(Core.Config.Get('Action')==='AgentTicketQueue'||Core.Config.Get('Action')==='AgentTicketService'||Core.Config.Get('Action')==='AgentTicketStatusView'||Core.Config.Get('Action')==='AgentTicketEscalationView'){$(this).closest('form').submit();}
else{URL=Core.Config.Get('Baselink')+$(this).parents().serialize();Core.UI.Popup.OpenPopup(URL,'TicketAction');$(this).val('0');}}});$('#TicketSearch').on('click',function(){Core.Agent.Search.OpenSearchDialog('AgentTicketSearch',Profile);return false;});$('#ShowContextSettingsDialog').on('click',function(Event){Core.UI.Dialog.ShowContentDialog($('#ContextSettingsDialogContainer'),Core.Language.Translate("Settings"),'15%','Center',true,[{Label:Core.Language.Translate("Save"),Type:'Submit',Class:'Primary',Function:function(){var $ListContainer=$('.AllocationListContainer').find('.AssignedFields'),FieldID;if(isJQueryObject($ListContainer)&&$ListContainer.length){$.each($ListContainer.find('li'),function(){FieldID='UserFilterColumnsEnabled-'+$(this).attr('data-fieldname');if(!$('#'+Core.App.EscapeSelector(FieldID)).length){$('<input name="UserFilterColumnsEnabled" type="hidden" />').attr('id',FieldID).val($(this).attr('data-fieldname')).appendTo($ListContainer.closest('div'));}});}
return true;}}],true);Event.preventDefault();Event.stopPropagation();Core.Agent.TableFilters.SetAllocationList();return false;});$('.InlineActions, .OverviewActions').on('change','select[name=DestQueueID]',function(){$(this).closest('form').submit();});for(TicketID in ActionRowTickets){Core.UI.ActionRow.AddActions($('#TicketID_'+TicketID),ActionRowTickets[TicketID]);}
if(View==='Small'){TargetNS.InitViewSmall();}
else if(View==='Medium'){TargetNS.InitViewMedium();}
else if(View==='Preview'){TargetNS.InitViewPreview();}
$('a.SplitSelection').off('click').on('click',function(){Core.Agent.TicketSplit.OpenSplitSelection($(this).attr('href'));return false;});};TargetNS.InitViewSmall=function(){var URL,ColumnFilter,NewColumnFilterStrg,MyRegEx,SessionInformation,$MasterActionLink;Core.UI.InitCheckboxSelection($('table td.Checkbox'));Core.Agent.TableFilters.InitCustomerUserAutocomplete($(".CustomerUserAutoComplete"));Core.Agent.TableFilters.InitCustomerIDAutocomplete($(".CustomerIDAutoComplete"));Core.Agent.TableFilters.InitUserAutocomplete($(".UserAutoComplete"));$('a.AsPopup').on('click',function(){Core.UI.Popup.OpenPopup($(this).attr('href'),'Action');return false;});$('.ColumnFilter').on('change',function(){URL=Core.Config.Get("Baselink")+'Action='+Core.Config.Get("Action")+';'+Core.Config.Get('LinkPage');SessionInformation=Core.App.GetSessionInformation();$.each(SessionInformation,function(Key,Value){URL+=encodeURIComponent(Key)+'='+encodeURIComponent(Value)+';';});ColumnFilter=$(this)[0].name;NewColumnFilterStrg=$(this)[0].name+'='+encodeURIComponent($(this).val())+';';MyRegEx=new RegExp(ColumnFilter+"=[^;]*;");if(URL.match(MyRegEx)){URL=URL.replace(MyRegEx,NewColumnFilterStrg);}
else{URL=URL+NewColumnFilterStrg;}
window.location.href=URL;});$('.OverviewHeader').off('click').on('click','.ColumnSettingsTrigger',function(){var $TriggerObj=$(this),FilterName=$TriggerObj.next('.ColumnSettingsContainer').find('select').attr('name');Core.UI.InputFields.InitSelect($('#'+FilterName),{Force:true});if($TriggerObj.hasClass('Active')){$TriggerObj
.next('.ColumnSettingsContainer')
.find('.ColumnSettingsBox')
.fadeOut('fast',function(){$TriggerObj.removeClass('Active');});}
else{$('.ColumnSettingsTrigger')
.next('.ColumnSettingsContainer')
.find('.ColumnSettingsBox')
.fadeOut('fast',function(){$(this).parent().prev('.ColumnSettingsTrigger').removeClass('Active');});$TriggerObj
.next('.ColumnSettingsContainer')
.find('.ColumnSettingsBox')
.fadeIn('fast',function(){$TriggerObj.addClass('Active');if($TriggerObj.closest('th').hasClass('CustomerID')||$TriggerObj.closest('th').hasClass('CustomerUserID')||$TriggerObj.closest('th').hasClass('Responsible')||$TriggerObj.closest('th').hasClass('Owner')){if(!$TriggerObj.parent().find('.SelectedValue').length){Core.AJAX.FormUpdate($('#Nothing'),'AJAXFilterUpdate',FilterName,[FilterName],function(){var AutoCompleteValue=$TriggerObj
.next('.ColumnSettingsContainer')
.find('select')
.val(),AutoCompleteText=$TriggerObj
.next('.ColumnSettingsContainer')
.find('select')
.find('option:selected')
.text();if(AutoCompleteValue!=='DeleteFilter'){$TriggerObj
.next('.ColumnSettingsContainer')
.find('select')
.after('<span class="SelectedValue Hidden">'+AutoCompleteText+' ('+AutoCompleteValue+')</span>')
.parent()
.find('input[type=text]')
.after('<a href="#" class="DeleteFilter"><i class="fa fa-trash-o"></i></a>')
.parent()
.find('a.DeleteFilter')
.off()
.on('click',function(){$(this)
.closest('.ColumnSettingsContainer')
.find('select')
.val('DeleteFilter')
.trigger('change');return false;});}});}}
else{Core.AJAX.FormUpdate($('#ColumnFilterAttributes'),'AJAXFilterUpdate',FilterName,[FilterName]);}});}
return false;});$('.MasterAction').off('click').on('click',function(Event){$MasterActionLink=$(this).find('.MasterActionLink');if($(Event.target).hasClass('DynamicFieldLink')){return true;}
if(Event.target!==$MasterActionLink.get(0)){if(Event.ctrlKey||Event.metaKey){Core.UI.Popup.OpenPopup($MasterActionLink.attr('href'));}
else{window.location=$MasterActionLink.attr('href');}
return false;}});};TargetNS.InitInlineActions=function(){$('.OverviewMedium > li, .OverviewLarge > li').on('mouseenter',function(){$(this).find('ul.InlineActions').css('top','0px');Core.App.Publish('Event.Agent.TicketOverview.InlineActions.Shown');});$('.OverviewMedium > li, .OverviewLarge > li').on('mouseleave',function(Event){if(Event.target.tagName.toLowerCase()==='select'||$(Event.target).hasClass('InputField_Search'))
{return false;}
$(this).find('ul.InlineActions').css('top','-35px');Core.App.Publish('Event.Agent.TicketOverview.InlineActions.Hidden',[$(this).find('ul.InlineActions')]);});};TargetNS.InitViewMedium=function(){var $MasterActionLink,Matches,PopupType='TicketAction';Core.UI.InitCheckboxSelection($('div.Checkbox'));TargetNS.InitInlineActions();$('ul.InlineActions').click(function(Event){Event.cancelBubble=true;if(Event.stopPropagation){Event.stopPropagation();}});$('.MasterAction').off('click').on('click',function(Event){$MasterActionLink=$(this).find('.MasterActionLink');if($(Event.target).hasClass('DynamicFieldLink')){return true;}
if(Event.target!==$MasterActionLink.get(0)){if(Event.ctrlKey||Event.metaKey){Core.UI.Popup.OpenPopup($MasterActionLink.attr('href'));}
else{window.location=$MasterActionLink.attr('href');}
return false;}});$('a.AsPopup').on('click',function(){Matches=$(this).attr('class').match(/PopupType_(\w+)/);if(Matches){PopupType=Matches[1];}
Core.UI.Popup.OpenPopup($(this).attr('href'),PopupType);return false;});if($('body').hasClass('TouchDevice')){$('ul.InlineActions li:not(.ResponsiveActionMenu)').hide();}
$('li.ResponsiveActionMenu').on('click.ToggleResponsiveActionMenu',function(){$(this).siblings().toggle();$(this).toggleClass('Opened');return false;});};TargetNS.InitViewPreview=function(){var Matches,PopupType='TicketAction',$MasterActionLink,URL,Index,ReplyFieldsFormID=Core.Config.Get('ReplyFieldsFormID');function ReplyFieldsOnChange(FormID){$('#'+FormID+' select[name=ResponseID]').on('change',function(){if($(this).val()>0){URL=Core.Config.Get('Baselink')+$(this).parents().serialize();Core.UI.Popup.OpenPopup(URL,'TicketAction');$(this).val('0');}});}
function ReplyFieldsOnClick(FormID){$('#'+FormID+' select[name=ResponseID]').on('click',function(Event){Event.stopPropagation();return false;});}
Core.UI.InitCheckboxSelection($('div.Checkbox'));TargetNS.InitInlineActions();Core.UI.Accordion.Init($('.Preview > ul'),'li h3 a','.HiddenBlock');Core.App.Subscribe('Event.UI.Accordion.OpenElement',function($Element){Core.UI.InputFields.Activate($Element);});$('ul.InlineActions').click(function(Event){Event.cancelBubble=true;if(Event.stopPropagation){Event.stopPropagation();}});$('a.AsPopup').on('click',function(){Matches=$(this).attr('class').match(/PopupType_(\w+)/);if(Matches){PopupType=Matches[1];}
Core.UI.Popup.OpenPopup($(this).attr('href'),PopupType);return false;});$('.MasterAction').off('click').on('click',function(Event){$MasterActionLink=$(this).find('.MasterActionLink');if(typeof Event.target==='object'&&($(Event.target).hasClass('ArticleBody')||$(Event.target).hasClass('ItemActions')||$(Event.target).parents('.Actions').length))
{return true;}
if($(Event.target).hasClass('DynamicFieldLink')){return true;}
if($(Event.target).hasClass('InputField_Search')){return true;}
if(Event.target!==$MasterActionLink.get(0)){if(Event.ctrlKey||Event.metaKey){Core.UI.Popup.OpenPopup($MasterActionLink.attr('href'));}
else{window.location=$MasterActionLink.attr('href');}
return false;}});if(typeof ReplyFieldsFormID!=='undefined'){for(Index in ReplyFieldsFormID){ReplyFieldsOnChange(ReplyFieldsFormID[Index]);ReplyFieldsOnClick(ReplyFieldsFormID[Index]);}}
if($('body').hasClass('TouchDevice')){$('ul.InlineActions li:not(.ResponsiveActionMenu)').hide();}
$('li.ResponsiveActionMenu').on('click.ToggleResponsiveActionMenu',function(){$(this).siblings().toggle();$(this).toggleClass('Opened');return false;});};Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.Overview||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.TableFilters=(function(TargetNS){if(!Core.Debug.CheckDependency('Core.Agent.TableFilters','Core.UI.AllocationList','Core.UI.AllocationList')){return false;}
TargetNS.InitCustomerIDAutocomplete=function($Input){var AutoCompleteConfig=Core.Config.Get('CustomerIDAutocomplete');if(typeof AutoCompleteConfig==='undefined'){return;}
$Input.autocomplete({minLength:AutoCompleteConfig.MinQueryLength,delay:AutoCompleteConfig.QueryDelay,open:function(){$(this).autocomplete('widget').addClass('ui-overlay-autocomplete');return false;},source:function(Request,Response){var URL=Core.Config.Get('Baselink'),Data={Action:'AgentCustomerSearch',Subaction:'SearchCustomerID',IncludeUnknownTicketCustomers:parseInt(Core.Config.Get('IncludeUnknownTicketCustomers'),10),Term:Request.term,MaxResults:AutoCompleteConfig.MaxResultsDisplayed};if($Input.data('AutoCompleteXHR')){$Input.data('AutoCompleteXHR').abort();$Input.removeData('AutoCompleteXHR');Response({});}
$Input.data('AutoCompleteXHR',Core.AJAX.FunctionCall(URL,Data,function(Result){var ValueData=[];$Input.removeData('AutoCompleteXHR');$.each(Result,function(){ValueData.push({label:this.Label+' ('+this.Value+')',value:this.Value});});Response(ValueData);}));},select:function(Event,UI){$(Event.target)
.parent()
.find('select')
.append('<option value="'+UI.item.value+'">SelectedItem</option>')
.val(UI.item.value)
.trigger('change');}});};TargetNS.InitCustomerUserAutocomplete=function($Input){var AutoCompleteConfig=Core.Config.Get('CustomerUserAutocomplete');if(typeof AutoCompleteConfig==='undefined'){return;}
$Input.autocomplete({minLength:AutoCompleteConfig.MinQueryLength,delay:AutoCompleteConfig.QueryDelay,open:function(){$(this).autocomplete('widget').addClass('ui-overlay-autocomplete');return false;},source:function(Request,Response){var URL=Core.Config.Get('Baselink'),Data={Action:'AgentCustomerSearch',IncludeUnknownTicketCustomers:parseInt(Core.Config.Get('IncludeUnknownTicketCustomers'),10),Term:Request.term,MaxResults:AutoCompleteConfig.MaxResultsDisplayed};if($Input.data('AutoCompleteXHR')){$Input.data('AutoCompleteXHR').abort();$Input.removeData('AutoCompleteXHR');Response({});}
$Input.data('AutoCompleteXHR',Core.AJAX.FunctionCall(URL,Data,function(Result){var ValueData=[];$Input.removeData('AutoCompleteXHR');$.each(Result,function(){ValueData.push({label:this.Label+" ("+this.Value+")",value:this.Label,key:this.Value});});Response(ValueData);}));},select:function(Event,UI){$(Event.target)
.parent()
.find('select')
.append('<option value="'+UI.item.key+'">SelectedItem</option>')
.val(UI.item.key)
.trigger('change');}});};TargetNS.InitUserAutocomplete=function($Input,Subaction){var AutoCompleteConfig=Core.Config.Get('UserAutocomplete');if(typeof AutoCompleteConfig==='undefined'){return;}
$Input.autocomplete({minLength:AutoCompleteConfig.MinQueryLength,delay:AutoCompleteConfig.QueryDelay,open:function(){$(this).autocomplete('widget').addClass('ui-overlay-autocomplete');return false;},source:function(Request,Response){var URL=Core.Config.Get('Baselink'),Data={Action:'AgentUserSearch',Subaction:Subaction,Term:Request.term,MaxResults:AutoCompleteConfig.MaxResultsDisplayed};if($Input.data('AutoCompleteXHR')){$Input.data('AutoCompleteXHR').abort();$Input.removeData('AutoCompleteXHR');Response({});}
$Input.data('AutoCompleteXHR',Core.AJAX.FunctionCall(URL,Data,function(Result){var ValueData=[];$Input.removeData('AutoCompleteXHR');$.each(Result,function(){ValueData.push({label:this.UserValue+" ("+this.UserKey+")",value:this.UserValue,key:this.UserKey});});Response(ValueData);}));},select:function(Event,UI){$(Event.target)
.parent()
.find('select')
.append('<option value="'+UI.item.key+'">SelectedItem</option>')
.val(UI.item.key)
.trigger('change');}});};TargetNS.Init=function(){TargetNS.SetAllocationList();};function UpdateAllocationList(Event,UI){var $ContainerObj=$(UI.sender).closest('.AllocationListContainer'),Data={},FieldName;if(Event.type==='sortstop'){$ContainerObj=$(UI.item).closest('.AllocationListContainer');}
Data.Columns={};Data.Order=[];$ContainerObj.find('.AvailableFields').find('li').each(function(){FieldName=$(this).attr('data-fieldname');Data.Columns[FieldName]=0;});$ContainerObj.find('.AssignedFields').find('li').each(function(){FieldName=$(this).attr('data-fieldname');Data.Columns[FieldName]=1;Data.Order.push(FieldName);});$ContainerObj.closest('form').find('.ColumnsJSON').val(Core.JSON.Stringify(Data));}
TargetNS.SetAllocationList=function(Name){var AllocationListArray=[];if(typeof Name!=='undefined'){AllocationListArray.push($('#Widget'+Name+' .AllocationListContainer'));}
else{$('.AllocationListContainer').each(function(){AllocationListArray.push($(this));});}
$.each(AllocationListArray,function(){var $ContainerObj=$(this),DataEnabledJSON=$ContainerObj.closest('form.WidgetSettingsForm').find('input.ColumnsEnabledJSON').val(),DataAvailableJSON=$ContainerObj.closest('form.WidgetSettingsForm').find('input.ColumnsAvailableJSON').val(),DataEnabled,DataAvailable,Translation,$FieldObj,IDString='#'+$ContainerObj.find('.AssignedFields').attr('id')+', #'+$ContainerObj.find('.AvailableFields').attr('id');if(DataEnabledJSON){DataEnabled=Core.JSON.Parse(DataEnabledJSON);}
if(DataAvailableJSON){DataAvailable=Core.JSON.Parse(DataAvailableJSON);}
$.each(DataEnabled,function(Index,Field){Translation=Core.Config.Get('Column'+Field)||Field;$FieldObj=$('<li />').attr('title',Translation).attr('data-fieldname',Field).text(Translation);$ContainerObj.find('.AssignedFields').append($FieldObj);});$.each(DataAvailable,function(Index,Field){Translation=Core.Config.Get('Column'+Field)||Field;$FieldObj=$('<li />').attr('title',Translation).attr('data-fieldname',Field).text(Translation);$ContainerObj.find('.AvailableFields').append($FieldObj);});Core.UI.AllocationList.Init(IDString,$ContainerObj.find('.AllocationList'),'UpdateAllocationList','',UpdateAllocationList);Core.UI.Table.InitTableFilter($ContainerObj.find('.FilterAvailableFields'),$ContainerObj.find('.AvailableFields'));Core.UI.Table.InitTableFilter($ContainerObj.find('.FilterAssignedFields'),$ContainerObj.find('.AssignedFields'));});};TargetNS.RegisterUpdatePreferences=function($ClickedElement,ElementID,$Form){if(isJQueryObject($ClickedElement)&&$ClickedElement.length){$ClickedElement.click(function(){var URL=Core.Config.Get('Baselink')+Core.AJAX.SerializeForm($Form);Core.AJAX.ContentUpdate($('#'+ElementID),URL,function(){Core.UI.ToggleTwoContainer($('#'+ElementID+'-setting'),$('#'+ElementID));});return false;});}};return TargetNS;}(Core.Agent.TableFilters||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.TicketSplit=(function(TargetNS){TargetNS.OpenSplitSelection=function(DataHref){var DataHrefArray=DataHref.split(';'),TicketIDArray=DataHrefArray[1].split('='),ArticleIDArray=DataHrefArray[2].split('='),LinkTicketIDArray=DataHrefArray[3].split('='),Data={Action:'AgentSplitSelection',TicketID:TicketIDArray[1],ArticleID:ArticleIDArray[1],LinkTicketID:LinkTicketIDArray[1]};Core.UI.Dialog.ShowWaitingDialog(Core.Config.Get('LoadingMsg'),Core.Config.Get('LoadingMsg'));Core.UI.InputFields.Activate($('#SplitSelection'));Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'),Data,function(HTML){var URL;if(!$('.Dialog:visible').length){return;}
Core.UI.Dialog.ShowContentDialog(HTML,Core.Language.Translate("Split"),'20%','Center',true);$('#SplitSelection').unbind('change.SplitSelection').bind('change.SplitSelection',function(){if($('#SplitSelection').val()=='ProcessTicket'){$('#ProcessSelectionLabel').fadeIn();$('#ProcessSelection').fadeIn();Core.UI.InputFields.Activate();}
else{$('#ProcessSelectionLabel').fadeOut();$('#ProcessSelection').fadeOut();}});$('#SplitSubmit').off('click').on('click',function(){if($('#SplitSelection').val()=='ProcessTicket'){$('<input/>')
.attr('type','hidden')
.attr('name','ProcessEntityID')
.attr('value',$('#ProcessEntityID').val())
.appendTo($('#AgentSplitSelection'));}
if(Core.UI.Popup!==undefined&&Core.UI.Popup.CurrentIsPopupWindow()){URL=Core.Config.Get('Baselink')+$('#AgentSplitSelection').serialize();Core.UI.Popup.ExecuteInParentWindow(function(WindowObject){WindowObject.Core.UI.Popup.FirePopupEvent('URL',{URL:URL});});Core.UI.Popup.ClosePopup();}
else{$('#AgentSplitSelection').submit();}});},'html');};Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.TicketSplit||{}));
