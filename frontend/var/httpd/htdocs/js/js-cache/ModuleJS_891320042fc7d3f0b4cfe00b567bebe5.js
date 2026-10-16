// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.CustomerSearchAutoComplete=(function(TargetNS){TargetNS.Init=function(){$("#CustomerAutoComplete, .CustomerAutoComplete").each(function(){Core.Agent.CustomerSearch.Init($(this));});};Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.CustomerSearchAutoComplete||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.TicketAction=(function(TargetNS){function SerializeData(Data){var QueryString='';$.each(Data,function(Key,Value){QueryString+=';'+encodeURIComponent(Key)+'='+encodeURIComponent(Value);});return QueryString;}
function OpenCustomerUserAddressBook(RecipientField,RecipientFieldLabel,RecipientType){var CustomerUserAddressBookIFrameURL,CustomerUserAddressBookIFrame;CustomerUserAddressBookIFrameURL=Core.Config.Get('CGIHandle')+'?Action=AgentCustomerUserAddressBook;RecipientField='+RecipientField+';RecipientFieldLabel='+RecipientFieldLabel+';RecipientType='+RecipientType;CustomerUserAddressBookIFrameURL+=SerializeData(Core.App.GetSessionInformation());CustomerUserAddressBookIFrame='<iframe class="TextOption CustomerUserAddressBook" src="'+CustomerUserAddressBookIFrameURL+'"></iframe>';Core.UI.Dialog.ShowContentDialog(CustomerUserAddressBookIFrame,'','10px','Center',true);}
function OpenCustomerDialog(){var CustomerIFrameURL,CustomerIFrame;CustomerIFrameURL=Core.Config.Get('CGIHandle')+'?Action=AdminCustomerUser;Nav=None;Subject=;What=';CustomerIFrameURL+=SerializeData(Core.App.GetSessionInformation());CustomerIFrame='<iframe class="TextOption Customer" src="'+CustomerIFrameURL+'"></iframe>';Core.UI.Dialog.ShowContentDialog(CustomerIFrame,'','10px','Center',true);}
function OpenCustomerIDSelection(){var Data={Action:'AgentCustomerSearch',Subaction:'AssignedCustomerIDs',CustomerUserID:$('#SelectedCustomerUser').val(),};$('#SelectionCustomerIDAssigned').empty();Core.AJAX.FunctionCall(Core.Config.Get('Baselink'),Data,function(Response){$.each(Response,function(Index,CustomerID){var CustomerIDOption=new Option(CustomerID,CustomerID);CustomerIDOption.innerHTML=CustomerID;$('#SelectionCustomerIDAssigned').append(CustomerIDOption);});if(!$('#SelectionCustomerIDAssigned > option').length){$('#TemplateSelectionCustomerID fieldset:last').addClass('Hidden');}
else{$('#TemplateSelectionCustomerID fieldset:last').removeClass('Hidden');}
Core.UI.Dialog.ShowContentDialog($('#TemplateSelectionCustomerID'),Core.Language.Translate('Select a customer ID to assign to this ticket'),'10px','Center',true);Core.Agent.CustomerSearch.InitSimple($('#SelectionCustomerIDAll'));$('#SelectionCustomerIDAssigned').val($('#CustomerID').val()).trigger('redraw.InputField').trigger('change');$('#SelectionCustomerIDAll').on('select.Autocomplete',function(){CloseCustomerIDSelection($(this).val());});$('#SelectionCustomerIDAssigned').on('change',function(){CloseCustomerIDSelection($(this).val());});});}
function CloseCustomerIDSelection(CustomerID){$('#CustomerID').val(CustomerID);$('#ShowCustomerID').html(CustomerID);Core.UI.Dialog.CloseDialog($('.Dialog'));}
function MarkPrimaryCustomer(){$('.CustomerContainer').children('div').each(function(){var $InputObj=$(this).find('.CustomerTicketText'),$RadioObj=$(this).find('.RadioRound');if($RadioObj.prop('checked')){$InputObj.addClass('MainCustomer');}
else{$InputObj.removeClass('MainCustomer');}});}
TargetNS.Init=function(){$('.OptionCustomerUserAddressBook').on('click',function(){OpenCustomerUserAddressBook($(this).data('recipient-field'),$(this).data('recipient-field-label'),$(this).data('recipient-type'));return false;});$('#OptionCustomer').on('click',function(){OpenCustomerDialog();return false;});$('#SelectionCustomerID').on('click',function(){OpenCustomerIDSelection();return false;});Core.UI.InputFields.Deactivate($('#TemplateSelectionCustomerID'));MarkPrimaryCustomer();Core.App.Subscribe('Event.Agent.CustomerSearch.GetCustomerInfo.Callback',function(){MarkPrimaryCustomer();});$('#submitRichText').on('click',function(Event){var ToCustomer=$('#ToCustomer').val()||'',CcCustomer=$('#CcCustomer').val()||'',BccCustomer=$('#BccCustomer').val()||'',FromCustomer=$('#FromCustomer').val()||'';if(ToCustomer.length||CcCustomer.length||BccCustomer.length||FromCustomer.length){window.setTimeout(function(){$('#submitRichText').trigger('click');},100);Event.preventDefault();Event.stopPropagation();return false;}});Core.App.Subscribe('Event.UI.ToggleWidget',function($WidgetElement){if($WidgetElement.attr('id')!=='WidgetArticle'){return;}
if($WidgetElement.hasClass('Expanded')){$('#CreateArticle').prop('checked',true);}});};TargetNS.UpdateCustomer=function(Customer){var $UpdateForm=$('form[name=compose]',parent.document);$UpdateForm
.find('#ExpandCustomerName').val('2')
.end()
.find('#PreSelectedCustomerUser').val(Customer)
.end()
.submit();parent.Core.UI.Dialog.CloseDialog($('.Dialog',parent.document));};TargetNS.SelectRadioButton=function(Value,Name){$('input[type="radio"][name='+Name+'][value='+Value+']').prop('checked',true);};TargetNS.ConfirmTemplateOverwrite=function(FieldName,$TemplateSelect,Callback){var Content='',LastValue=$TemplateSelect.data('LastValue')||'';Content=$('#'+FieldName).val();if(typeof CKEDITOR!=='undefined'&&CKEDITOR.instances[FieldName]){Content=CKEDITOR.instances[FieldName].getData();}
if(Content.length&&!window.confirm(Core.Language.Translate('Setting a template will overwrite any text or attachment.')+' '+Core.Language.Translate('Do you really want to continue?')))
{$TemplateSelect.val(LastValue).trigger('redraw');}
else if($.isFunction(Callback)){Callback();$TemplateSelect.data('LastValue',$TemplateSelect.val());}}
TargetNS.SetTimeUnits=function(Selector){var Count=0,$TimeUnits=$('#'+Selector);$('.TimeUnitDropdown.'+Selector).each(function(){Count+=Number($(this).val()||0);if($(this).hasClass('Validate_Required')){$(this).attr('data-needs-class-validate-required','1');$(this).removeClass('Validate_Required');}});$TimeUnits.val(Count);if(!Count){$('.TimeUnitDropdown.'+Selector).each(function(){if($(this).attr('data-needs-class-validate-required')){$(this).addClass('Validate_Required');}});}};Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.TicketAction||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.TicketEmail=(function(TargetNS){TargetNS.Init=function(){var CustomerKey,ArticleComposeOptions=Core.Config.Get('ArticleComposeOptions'),DynamicFieldNames=Core.Config.Get('DynamicFieldNames'),DataEmail=Core.Config.Get('DataEmail'),DataCustomer=Core.Config.Get('DataCustomer'),Fields=['TypeID','Dest','NewUserID','NewResponsibleID','NextStateID','PriorityID','ServiceID','SLAID'],ModifiedFields;$.each(Fields,function(Index,Value){ModifiedFields=Core.Data.CopyObject(Fields).concat(DynamicFieldNames);ModifiedFields.splice(Index,1);FieldUpdate(Value,ModifiedFields);});$('#OwnerSelectionGetAll').on('click',function(){$('#OwnerAll').val('1');Core.AJAX.FormUpdate($('#NewEmailTicket'),'AJAXUpdate','OwnerAll',['NewUserID'],function(){$('#NewUserID').focus();});return false;});$('#ResponsibleSelectionGetAll').on('click',function(){$('#ResponsibleAll').val('1');Core.AJAX.FormUpdate($('#NewEmailTicket'),'AJAXUpdate','ResponsibleAll',['NewResponsibleID'],function(){$('#NewResponsibleID').focus();});return false;});$('#StandardTemplateID').on('change',function(){Core.Agent.TicketAction.ConfirmTemplateOverwrite('RichText',$(this),function(){Core.AJAX.FormUpdate($('#NewEmailTicket'),'AJAXUpdate','StandardTemplateID',['RichTextField']);});return false;});$('.RadioRound').on('change',function(){if($(this).prop('checked')){CustomerKey=$('#CustomerKey_'+$(this).val()).val();Core.Agent.CustomerSearch.ReloadCustomerInfo(CustomerKey);}
return false;});$('.CustomerTicketRemove').on('click',function(){Core.Agent.CustomerSearch.RemoveCustomerTicket($(this));return false;});if(typeof DataEmail!=='undefined'&&typeof DataCustomer!=='undefined'){Core.Agent.CustomerSearch.AddTicketCustomer('ToCustomer',DataEmail,DataCustomer,true);}
if(typeof ArticleComposeOptions!=='undefined'){$.each(ArticleComposeOptions,function(Key,Value){$('#'+Value.Name).on('change',function(){Core.AJAX.FormUpdate($('#NewEmailTicket'),'AJAXUpdate',Value.Name,Value.Fields);});});}};function FieldUpdate(Value,ModifiedFields){var SignatureURL,FieldValue,CustomerUser;$('#'+Value).on('change',function(){Core.AJAX.FormUpdate($('#NewEmailTicket'),'AJAXUpdate',Value,ModifiedFields);if(Value==='Dest'){FieldValue=$(this).val()||'';CustomerUser=$('#SelectedCustomerUser').val()||'';SignatureURL=Core.Config.Get('Baselink')+'Action='+Core.Config.Get('Action')+';Subaction=Signature;Dest='+FieldValue+';SelectedCustomerUser='+CustomerUser;if(!Core.Config.Get('SessionIDCookie')){SignatureURL+=';'+Core.Config.Get('SessionName')+'='+Core.Config.Get('SessionID');}
$('#Signature').attr('src',SignatureURL);}});}
Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.TicketEmail||{}));
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
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.Service=(function(TargetNS){var AJAXLoaderPrefix='AJAXLoader',ActiveAJAXCalls={};const myInterval=setInterval(function(){if($('#ServiceID').length){$('#ServiceID').bind('change',function(Event){var ServiceID=$(this).val();TargetNS.Init(ServiceID);});clearInterval(myInterval);}},1000);TargetNS.Init=function(ServiceID){var Data={Action:'ServiceTemplateAJAXHandler',Subaction:'ServiceUpdate',ServiceID:ServiceID};var $RichTextElement=$('#RichText'),$SubjectElement=$('#Subject'),Content='';Content=$RichTextElement.val();if(typeof CKEDITOR!=='undefined'&&CKEDITOR.instances['RichText']){Content=CKEDITOR.instances['RichText'].getData();}
if(Content.length&&!window.confirm(Core.Language.Translate('Setting up a new service will overwrite any text. Do you really want to continue?'))){$('#ServiceID').val(ServiceID).trigger('redraw');}
else{ToggleAJAXLoader('Subject',true);Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'),Data,function(Response){if(Response.Text&&Response.Subject){$SubjectElement.val(Response.Subject);UpdateTextarea($RichTextElement,Response.Text);}
else{$SubjectElement.val('');UpdateTextarea($RichTextElement,'');}
ToggleAJAXLoader('Subject',false);$.each(Response.Fields,function(Field,value){if($('#'+Field).length){if(value!=null){$('#'+Field).val(value);$('#'+Field).trigger('change');if($('#'+Field+'_Search').length){$('#'+Field+'_Search').hide();$('<input type="text" class="DynamicFieldText " id="TemporaryField_'+Field+'" name="TemporaryField_'+Field+'" title="'+value+'" value="'+value+'" readonly="readonly" aria-invalid="false">').insertAfter('#'+Field+'_Search');$("#TemporaryField_"+Field).attr('size',$("#TemporaryField_"+Field).val().length-3);$('#TemporaryField_'+Field).next().remove();}}
else{$('#'+Field+'_Search').show();$("#TemporaryField_"+Field).remove();}}});});}};function UpdateTextarea($Element,Value){var $ParentBody,ParentBody,Range,StartRange=0,NewPosition=0,CKEditorObj=parent.CKEDITOR;if($Element.length){$ParentBody=$Element;ParentBody=$ParentBody[0];if(Core.App.Responsive.IsSmallerOrEqual(Core.App.Responsive.GetScreenSize(),'ScreenL')&&(!localStorage.getItem("DesktopMode")||parseInt(localStorage.getItem("DesktopMode"),10)<=0)){CKEditorObj=CKEDITOR;}
if(CKEditorObj&&CKEditorObj.instances.RichText){CKEditorObj.instances.RichText.focus();window.setTimeout(function(){try{CKEditorObj.instances.RichText.setData(Value);}
catch(Error){$.noop();}},100);return;}
else{if($Element.parent().data('Cursor')){StartRange=parent.$Element.data('Cursor').StartRange;}
$ParentBody.val(Value);NewPosition=StartRange+Value.length;if(ParentBody.selectionStart){ParentBody.selectionStart=NewPosition;ParentBody.selectionEnd=NewPosition;}
else if(document.selection){Range=document.selection.createRange().duplicate();Range.moveStart('character',NewPosition);Range.select();}
return;}}
else{alert('$JSText{"This window must be called from compose window"}');return;}}
function ToggleAJAXLoader(FieldID,Show){var $Element=$('#'+FieldID),$Loader=$('#'+AJAXLoaderPrefix+FieldID),LoaderHTML='<span id="'+AJAXLoaderPrefix+FieldID+'" class="AJAXLoader"></span>';if($Element.is('[type=hidden]')){return;}
if(!$Element.length){ActiveAJAXCalls[FieldID]=0;return;}
if(typeof ActiveAJAXCalls[FieldID]==='undefined'){ActiveAJAXCalls[FieldID]=0;}
if(Show){ActiveAJAXCalls[FieldID]++;}
else{ActiveAJAXCalls[FieldID]--;if(ActiveAJAXCalls[FieldID]<=0){ActiveAJAXCalls[FieldID]=0;}}
if(ActiveAJAXCalls[FieldID]>0){if(!$Loader.length){$Element.after(LoaderHTML);}
else{$Loader.show();}}
else{$Loader.hide();}}
return TargetNS;}(Core.Agent.ServiceTemplate||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var ITSM=ITSM||{};ITSM.Agent=ITSM.Agent||{};ITSM.Agent.ITSMIncidentProblemManagement=(function(TargetNS){TargetNS.ShowIncidentState=function(Data){Data.Action='AgentITSMIncidentProblemManagement';Data.Subaction='GetServiceIncidentState';Core.AJAX.FunctionCall(Core.Config.Get('Baselink'),Data,function(Response){if(Response.CurInciSignal){$('#ServiceIncidentStateSignal').attr('class',Response.CurInciSignal);$('#ServiceIncidentStateSignal').attr('title',Response.CurInciState);$('#ServiceIncidentState').html(Response.CurInciState);$('#ServiceIncidentStateContainer')
.show()
.prev()
.show();}
else{$('#ServiceIncidentStateContainer')
.hide()
.prev()
.hide();}});};TargetNS.Init=function(){var ServiceIncidentStateHTML=Core.Template.Render('Agent/ITSMIncidentProblemManagement/ServiceIncidentState'),ActionShowIncidentState=Core.Config.Get('Action')+'ShowIncidentState';if(Core.Config.Get(ActionShowIncidentState)){$(ServiceIncidentStateHTML).insertBefore($('label[for=SLAID]'));$('#ServiceID').on('change',function(){ITSM.Agent.ITSMIncidentProblemManagement.ShowIncidentState({TicketID:$('input[type=hidden][name=TicketID]').val(),ServiceID:$('#ServiceID').val()});});if($('#ServiceID').val()){ITSM.Agent.ITSMIncidentProblemManagement.ShowIncidentState({TicketID:$('input[type=hidden][name=TicketID]').val(),ServiceID:$('#ServiceID').val()});}}
$('a.AsPopup').on('click',function(){Core.UI.Popup.OpenPopup($(this).attr('href'),'Action');return false;});};Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(ITSM.Agent.ITSMIncidentProblemManagement||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var FAQ=FAQ||{};FAQ.Agent=FAQ.Agent||{};FAQ.Agent.RelatedArticles=(function(TargetNS){TargetNS.Init=function(){var WidgetPosition=Core.Config.Get('AgentFAQRelatedArticlesPosition'),QueuesEnabled=Core.Config.Get('AgentFAQRelatedArticlesQueues'),LastData,LastResponse,SlideDuration=400,HelpText=Core.Language.Translate('This might be helpful'),$Widget=$('<div id="FAQRelatedArticlesLabel" for="FAQRelatedArticles" class="WidgetSimple Expanded FAQ-related-articles-widget"> <div class="Header"> <h2>'+HelpText+'</h2> </div> <div id="FAQRelatedArticles" class="Content"> </div></div>'),$AJAXLoader=$('<span id="AJAXLoaderFAQRelatedArticles" class="AJAXLoader"></span>');if(WidgetPosition==1){$('#Subject')
.parent()
.parent()
.after($Widget);}
else if(WidgetPosition==2){$('#RichText')
.parent()
.parent()
.after($Widget);}
$('#FAQRelatedArticlesLabel').hide();$('#FAQRelatedArticles').hide();$('#Subject').after($AJAXLoader);$AJAXLoader.hide();Core.App.Subscribe('Event.UI.RichTextEditor.InstanceReady',function(){$('#Dest').on('change.RelatedFAQArticle',function(){var SelectedQueue=$(this).val(),SelectedQueueName=SelectedQueue.replace(/\d*\|\|-?/,'');if((!QueuesEnabled.length||!SelectedQueueName||$.inArray(SelectedQueueName,QueuesEnabled)>-1)){if($('#Subject').val()||CKEDITOR.instances['RichText'].getData()){$('#Subject').trigger('change');}}
else if(!SelectedQueueName||(QueuesEnabled.length&&$.inArray(SelectedQueueName,QueuesEnabled)==-1)){if($('#FAQRelatedArticles').html()){$('#FAQRelatedArticlesLabel').hide();$('#FAQRelatedArticles').slideUp(SlideDuration,function(){$('#FAQRelatedArticles')
.empty()
.css('padding-top','0px')
.css('padding-bottom','0px');});}}});$('#Subject').on('change',function(){var SelectedQueue=$('#Dest').val(),SelectedQueueName,Data;if(SelectedQueue){SelectedQueueName=SelectedQueue.replace(/\d*\|\|-?/,'');}
if(!QueuesEnabled.length||!SelectedQueueName||$.inArray(SelectedQueueName,QueuesEnabled)>-1){Data={Action:'AgentFAQRelatedArticles',Subject:$('#Subject').val(),Body:CKEDITOR.instances['RichText'].getData()};if(!LastData||LastData.Subject!=Data.Subject||LastData.Body!=Data.Body){$AJAXLoader.show();if($('#Subject').data('RelatedFAQArticlesXHR')){$('#Subject').data('RelatedFAQArticlesXHR').abort();$('#Subject').removeData('RelatedFAQArticlesXHR');}
$('#Subject').data('RelatedFAQArticlesXHR',Core.AJAX.FunctionCall(Core.Config.Get('Baselink'),Data,function(Response){var AmountOldElements=0,AmountNewElements=0;$('#Subject').removeData('RelatedFAQArticlesXHR');LastData=Data;if($('#FAQRelatedArticles').length){if(Response&&Response.Success){if(!LastResponse||LastResponse!=Response.AgentRelatedFAQArticlesHTMLString){if($('#FAQRelatedArticles').html()){AmountOldElements=$('#FAQRelatedArticles table tr').length;AmountNewElements=$(Response.AgentRelatedFAQArticlesHTMLString).find('tr').length;if(AmountOldElements!=AmountNewElements){$('#FAQRelatedArticles').slideUp(SlideDuration,function(){$('#FAQRelatedArticles')
.empty()
.html(Response.AgentRelatedFAQArticlesHTMLString)
.css('padding-top','0px')
.css('padding-bottom','0px')
.slideDown(SlideDuration);$('#FAQRelatedArticlesLabel').show();});}
else{$('#FAQRelatedArticles')
.empty()
.html(Response.AgentRelatedFAQArticlesHTMLString)
.css('padding-top','0px')
.css('padding-bottom','0px');}}
else{$('#FAQRelatedArticles')
.html(Response.AgentRelatedFAQArticlesHTMLString)
.css('padding-top','0px')
.css('padding-bottom','0px')
.slideDown(SlideDuration,function(){$('#FAQRelatedArticlesLabel').show();});}}
LastResponse=Response.AgentRelatedFAQArticlesHTMLString;}
else{$('#FAQRelatedArticlesLabel').hide();$('#FAQRelatedArticles').slideUp(SlideDuration,function(){$('#FAQRelatedArticles')
.empty()
.css('padding-top','0px')
.css('padding-bottom','0px');});LastResponse=undefined;}
$AJAXLoader.hide();}}));}}});$('#Subject').on('paste keydown',function(Event){if((Event.type==='keydown'&&(Event.which==32||Event.which==13))||Event.type!=='keydown'){$('#Subject').trigger('change');}});CKEDITOR.instances['RichText'].on('key',function(Event){if(Event.data.keyCode==32||Event.data.keyCode==13){$('#Subject').trigger('change');}});CKEDITOR.instances['RichText'].on('paste',function(){$('#Subject').trigger('change');});CKEDITOR.instances['RichText'].on('blur',function(){$('#Subject').trigger('change');});if(!$('#Dest').length){if($('#Subject').val()||CKEDITOR.instances['RichText'].getData()){$('#Subject').trigger('change');}}
else{$('#Dest').trigger('change.RelatedFAQArticle');}});};Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(FAQ.Agent.RelatedArticles||{}));
