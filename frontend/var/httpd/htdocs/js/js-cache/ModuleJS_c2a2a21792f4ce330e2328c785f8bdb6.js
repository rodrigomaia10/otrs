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
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.Preferences=(function(TargetNS){TargetNS.Init=function(){Core.SystemConfiguration.InitConfigurationTree('AgentPreferences',null,1);$('tr.Mandatory .NotificationEvent').closest('form').off().on('submit',function(Event){$(this).find('tr.Mandatory').each(function(){var FoundEnabled=false;$(this).find('.NotificationEvent').each(function(){if($(this).prop('checked')){FoundEnabled=true;}});if(!FoundEnabled){Core.UI.Dialog.ShowAlert(Core.Language.Translate('An Error Occurred'),Core.Language.Translate("Sorry, but you can't disable all methods for notifications marked as mandatory."));Event.preventDefault();Event.stopPropagation();return false;}});});$('.NotificationEvent').on('click',function(Event){var FoundEnabled=false,$TargetObj=$(this).parent().find('input[type=hidden]');if(!$(this).prop('checked')&&$(this).closest('tr').hasClass('Mandatory')){$(this).closest('tr.Mandatory').find('.NotificationEvent').each(function(){if($(this).prop('checked')){FoundEnabled=true;return true;}});if(!FoundEnabled){Core.UI.Dialog.ShowAlert(Core.Language.Translate('An Error Occurred'),Core.Language.Translate("Sorry, but you can't disable all methods for this notification."));Event.stopPropagation();return false;}}
if($TargetObj.val()==0){$TargetObj.val(1);}
else{$TargetObj.val(0);}});$('#SaveAll').on('click',function(){$('button.Update:visible').trigger('click');return false;});$('.PreferenceClassic button.Update').on('click',function(){var $FormObj=$(this).closest('form'),$WidgetObj=$(this).closest('.WidgetSimple'),$ButtonObj=$(this),Link=window.location.href.split('?')[1];Core.UI.WidgetOverlayShow($WidgetObj,'Loading');Core.AJAX.FunctionCall(Core.Config.Get('Baselink')+'ChallengeToken='+Core.Config.Get('ChallengeToken'),Core.AJAX.SerializeForm($FormObj),function(Response){if(Response){if(Response.Priority==='Error'){if($WidgetObj.find('.WidgetMessage').length){$WidgetObj.find('.WidgetMessage').text(Response.Message);}
else{$WidgetObj.find('.Content').before('<div class="WidgetMessage Top Error" style="display: none;"></div>');$WidgetObj.find('.WidgetMessage').text(Response.Message);$WidgetObj.find('.WidgetMessage').slideDown().delay(5000).slideUp(function(){$(this).remove();});}
Core.UI.WidgetOverlayHide($WidgetObj);}
else{Core.UI.WidgetOverlayHide($WidgetObj,true);if(typeof Response.NeedsReload!=='undefined'&&parseInt(Response.NeedsReload,10)>0){Core.UI.ShowNotification(Core.Language.Translate('Please note that at least one of the settings you have changed requires a page reload. Click here to reload the current screen.'),'Notice',Link);}}}
else{if($WidgetObj.find('.WidgetMessage').length){$WidgetObj.find('.WidgetMessage').text(Response.Message);}
else{$WidgetObj.find('.Content').before('<div class="WidgetMessage Top Error" style="display: none;"></div>');$WidgetObj.find('.WidgetMessage').text(Core.Language.Translate('An unknown error occurred. Please contact the administrator.'));$WidgetObj.find('.WidgetMessage').slideDown().delay(5000).slideUp(function(){$(this).remove();});}
Core.UI.WidgetOverlayHide($WidgetObj);}
$WidgetObj.find('input[type=password]').val('');$WidgetObj.find('input[name=TwoFactorToken]').val('');$ButtonObj.blur();});return false;});TargetNS.InitSysConfig();Core.UI.Table.InitTableFilter($("#FilterSettings"),$(".SettingsList"));};function SettingReset($Widget){var SettingName=$Widget.find("input[name='SettingName']").val(),Data="Action=AgentPreferences;Subaction=SettingReset;";Data+='SettingName='+encodeURIComponent(SettingName)+';';Core.UI.WidgetOverlayShow($Widget,'Loading');Core.AJAX.FunctionCall(Core.Config.Get('Baselink'),Data,function(Response){if(Response.Error!=null){alert(Response.Error);Core.UI.WidgetOverlayHide($Widget);return;}
Core.SystemConfiguration.SettingRender(Response,$Widget);Core.UI.WidgetOverlayHide($Widget);});}
TargetNS.InitSysConfig=function(){$('#SaveAll').on('click',function(){$('.Setting').find('button.Update').trigger('click');return false;});$('.WidgetSimple:not(.PreferenceClassic) button.Update').on('click',function(){Core.SystemConfiguration.Update($(this),0,0);return false;});$('.WidgetSimple .ResetUserSetting a').on('click',function(){SettingReset($(this).closest(".WidgetSimple"));return false;});$('#Category').on('change',function(){var ParagraphHeight=$('#ConfigTree').height(),SelectedCategory=$(this).val();Core.Agent.PreferencesUpdate('UserSystemConfigurationCategory',SelectedCategory);$('#ConfigTree').html('<p class="Center"><i class="fa fa-spinner fa-spin"></i></p>');$('#ConfigTree > p').css('line-height',ParagraphHeight+'px');Core.SystemConfiguration.InitConfigurationTree('AgentPreferences',SelectedCategory,1);});}
Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.Preferences||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.SharedSecretGenerator=(function(TargetNS){TargetNS.Init=function(){var letters=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7"];var i,r,tempLetter,sharedSecret;$("#UserGoogleAuthenticatorSecretKey").parent().append("<button id=\"GenerateUserGoogleAuthenticatorSecretKey\" type=\"button\" class=\"CallForAction\"><span>"+Core.Language.Translate("Generate")+"</span></button>");$("#UserGoogleAuthenticatorSecretKey + button").on("click",function(){sharedSecret="";for(i=0;i<letters.length;i++){r=Math.floor(Math.random()*letters.length);tempLetter=letters[i];letters[i]=letters[r];letters[r]=tempLetter;}
for(i=0;i<16;i++){sharedSecret+=letters[i];}
$("#UserGoogleAuthenticatorSecretKey").val(sharedSecret);});}
Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.SharedSecretGenerator||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.SystemConfiguration=(function(TargetNS){var ValueTypes=new Array();function SerializeData(Data){var QueryString='';$.each(Data,function(Key,Value){QueryString+=';'+encodeURIComponent(Key)+'='+encodeURIComponent(Value);});return QueryString;}
TargetNS.Init=function(){var Index,Type;$("button.RemoveButton").on("click",function(){$(this).blur();TargetNS.RemoveItem($(this));});$("button.AddArrayItem").on("click",function(){$(this).blur();TargetNS.AddArrayItem($(this));});$("button.AddHashKey").on("click",function(){$(this).blur();TargetNS.AddHashKeyClick($(this));});$("a.ResetSetting").on("click",function(){Core.Agent.Admin.SystemConfiguration.InitDialogReset($(this));return false;});$("a.RevertToHistoricalValue").on("click",function(){TargetNS.RevertToHistoricalValue($(this));return false;});$("input:checkbox").on("click",function(){TargetNS.CheckboxValueSet($(this));});$('.WidgetSimple.Setting').on('keydown','input, select, checkbox',function(Event){var $WidgetObj=$(this).closest('.WidgetSimple.Setting');if(!Event){return false;}
if($WidgetObj.hasClass('IsLockedByMe')){if(Event.keyCode&&Event.keyCode===13){if($(this).hasClass('Key')){$(this).closest('.HashItem').find('button.AddKey').trigger('click');}
else{$WidgetObj.find('button.Update').trigger('click');}
return false;}
else if(Event.keyCode&&Event.keyCode===27){$WidgetObj.find('button.Cancel').trigger('click');}}});TargetNS.InitButtonVisibility();for(Index in window["Core"]["SystemConfiguration"]){Type=typeof window["Core"]["SystemConfiguration"][Index];if(Type!="function"){ValueTypes.push(Index);}}
Core.App.Subscribe('SystemConfiguration.SettingListUpdate',function(){if(!$('.WidgetSimple.Setting:visible').length){$('#EditAll, #SaveAll, #CancelAll').prop('disabled',true).addClass('Disabled');}
else{$('#EditAll, #SaveAll, #CancelAll').prop('disabled',false).removeClass('Disabled');}
if(!$('.WidgetSimple.Setting.IsLockedByMe:visible').length){$('#SaveAll, #CancelAll').prop('disabled',true).addClass('Disabled');}
else{$('#SaveAll, #CancelAll').prop('disabled',false).removeClass('Disabled');}});Core.UI.Table.InitTableFilter($("#FilterUsers"),$("#Users"));if(typeof String.prototype.endsWith==='undefined'){String.prototype.endsWith=function(search,this_len){if(this_len===undefined||this_len>this.length){this_len=this.length;}
return this.substring(this_len-search.length,this_len)===search;};}};TargetNS.InitConfigurationTree=function(RedirectAction,Category,UserModificationActive){var Data={Action:'AdminSystemConfiguration',Subaction:'AJAXNavigationTree',Category:Category||$('#Category').val(),UserModificationActive:UserModificationActive};if(Core.Config.Get('Action')=='AgentPreferences'){Data.Action='AgentPreferences';}
if($('#Category option').length<=2){$('.SystemConfigurationCategories').hide();$('.SystemConfigurationCategories').next('a').hide();$('#Category').val('All').trigger('change');Data["Category"]='All';}
$('#ConfigTree').on('click','.OpenNodeInNewWindow',function(Event){window.open(Core.Config.Get('CGIHandle')+'?Action=AdminSystemConfigurationGroup;RootNavigation='+$(this).data('node'),'_blank');Event.preventDefault;return false;});if(Core.Config.Get('Action')=='AgentPreferences'){Data["IsValid"]=1;}
if(!$('#ConfigTree').length){return false;}
Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'),Data,function(HTML){var Group,SelectedNode=$('#SelectedNode').val(),Data={'Action':RedirectAction};if($('#ConfigTree').hasClass('jstree')){$('#ConfigTree').jstree('destroy');$('#ConfigTree').empty();}
$('#ConfigTree').html(HTML);$('#ConfigTree')
.jstree({core:{multiple:false,animation:70,themes:{name:'InputField',variant:'Tree',icons:false,dots:false,url:false}},search:{show_only_matches:true,show_only_matches_children:true},plugins:['search','wholerow']})
.on('after_open.jstree',function(Node,Selected,Event){Core.UI.InitStickyElement();})
.on('after_close.jstree',function(Node,Selected,Event){Core.UI.InitStickyElement();})
.on('hover_node.jstree',function(Node,Selected,Event){$('#ConfigTree #'+Core.App.EscapeSelector(Selected.node.id)).children('a').append('<span class="OpenNodeInNewWindow" style="display:inline-block" title="'+Core.Language.Translate('Open this node in a new window')+'" data-node="'+Selected.node.id+'"><i class="fa fa-external-link"></i></span>').find('.OpenNodeInNewWindow').fadeIn();})
.on('dehover_node.jstree',function(Node,Selected,Event){$('#ConfigTree #'+Core.App.EscapeSelector(Selected.node.id)).find('.OpenNodeInNewWindow').remove();});if(SelectedNode){$('#ConfigTree').jstree('select_node',Core.App.EscapeHTML(SelectedNode));}
$('#ConfigTree')
.on('select_node.jstree',function(Node,Selected,Event){$('.ContentColumn').html(Core.Template.Render("Agent/WidgetLoading"));Data["RootNavigation"]=Selected.node.id;Group=$("input#Group").val();if(Group!=""){Data["Subaction"]="Group";Data["Group"]=Group;}
Data.Category=$('#Category').val();if($('#CurrentUserID').val()){Data.EditUserID=parseInt($('#CurrentUserID').val(),10);}
SettingList(Selected.selected[0]);return false;});$("#ConfigTreeSearch").on('keyup keydown',function(){$('#ConfigTree').jstree('search',$(this).val());});},'html');};TargetNS.Update=function($Object,ToggleValid,ToggleUserModification){var
URL,Data={},Action,Key,Value,$Widget=$Object.closest(".WidgetSimple"),SettingName=$Widget.find("input[name='SettingName']").val(),ValidationError,IsValid,UserModificationActive,Item,$InvalidElement;if($Widget.find('button.AddKey:visible').length){Core.UI.Dialog.ShowAlert(Core.Language.Translate('An Error Occurred'),Core.Language.Translate('Please add values for all keys before saving the setting.'));return;}
CheckIDs($Widget);$Widget
.find('form')
.find('input:not(:checkbox):not(:file):not([name=SettingName]):not(.Key):not(.InputField_Search),'+
' textarea, select, div.Array, div.Hash, .AddArrayItem, .AddHashKey, div.WorkingHoursItem input')
.filter(':not([disabled=disabled])')
.each(function(){var FullName=$(this).attr('id'),Value,$Container,ValueType;if($(this).hasClass("hasDatepicker")){return;}
if($(this).is('div')){return;}
if(!Core.Form.Validate.ValidateElement($(this))){ValidationError=1;Core.Form.Validate.HighlightError(this,"Error");$(this).on("change",function(){Core.Form.Validate.UnHighlightError(this);});return;}
for(Item in ValueTypes){if($(this).hasClass(ValueTypes[Item])){ValueType=ValueTypes[Item];break;}}
if($(this).hasClass("AddArrayItem")){$Container=$(this).closest(".Array");if($Container.find("> .ArrayItem").length==0){if($Container.hasClass("VacationDaysArray")||$Container.hasClass("VacationDaysOneTimeArray")){Value={};}
else{Value=[];}
FullName=SettingName+$(this).attr("data-suffix");FullName=FullName.substr(0,FullName.lastIndexOf("_Array"));}
else{return;}}
else if($(this).hasClass("AddHashKey")){if($(this).closest(".Hash").find("> .HashItem > .SettingContent").length==0){Value={};FullName=SettingName+$(this).attr("data-suffix");FullName=FullName.substr(0,FullName.lastIndexOf("_Hash"));}
else{return;}}
else if(ValueType!=null){Value=window["Core"]["SystemConfiguration"][ValueType]["ValueGet"]($(this));if(Value==null){return;}}
else if($(this).is('select')){Value=$(this).find('option:selected').val();}
else if(Value===undefined){Value=$(this).val();}
if($(this).parent().parent().hasClass("HashItem")){Key=$(this).parent().parent().find(".Key").val();FullName=FullName.substr(0,FullName.lastIndexOf("###"));FullName+="###"+Key;}
Data[SettingName]=ValueSet(Data[SettingName],FullName,Value);});if(ValidationError){$InvalidElement=$Widget.find('.Error:first');$('html, body').animate({scrollTop:$InvalidElement.offset().top-100},'slow');$InvalidElement.focus();return;}
Value={EffectiveValue:Core.JSON.Stringify(Data[SettingName])};Core.UI.WidgetOverlayShow($Widget,'Loading');if(Core.Config.Get('Action')=='AgentPreferences'){Action='AgentPreferences';}
else{Action='AdminSystemConfigurationGroup';}
URL=Core.Config.Get('Baselink')+
'Action='+Action+
';Subaction=SettingUpdate;'+
'SettingName='+encodeURIComponent(SettingName)+
';ChallengeToken='+Core.Config.Get('ChallengeToken');if(ToggleValid){IsValid=0;if($Widget.find(".SettingDisabled:visible").length||$Widget.find(".SettingEnable:visible").length){IsValid=1;}
URL+=';IsValid='+IsValid;}
if(ToggleUserModification){UserModificationActive=0;if($Widget.find(".UserModificationNotActive:visible").length){UserModificationActive=1;}
URL+=';UserModificationActive='+UserModificationActive;}
Core.AJAX.FunctionCall(URL,Value,function(Response){var LinkURL='Action=AdminSystemConfigurationDeployment;Subaction=Deployment';TargetNS.CleanWidgetClasses($Widget);TargetNS.SettingRender(Response,$Widget);if(Response.Data.SettingData.IsDirty){if(Core.Config.Get('SessionUseCookie')==='0'){LinkURL+=';'+Core.Config.Get('SessionName')+'='+Core.Config.Get('SessionID');}
Core.UI.ShowNotification(Core.Language.Translate('You have undeployed settings, would you like to deploy them?'),'Notice',LinkURL,function(){Core.UI.InitStickyElement();},undefined,'fa-bell');Core.UI.InitMessageBoxClose();}
else if(Response.Data.DeploymentNeeded==0){Core.UI.HideNotification(Core.Language.Translate('You have undeployed settings, would you like to deploy them?'),'Notice',function(){Core.UI.InitStickyElement();});}
Core.UI.WidgetOverlayHide($Widget,Response.Data.Error===undefined);});}
function ValueSet(Data,Name,Value){var Result=Data,StructureArray=Name.split(/_(?=Array|Hash)/),HashKey,SettingName=StructureArray.shift(),Structure,ArrayIndex,SubName,RemoveIndexes=[],Item;if(StructureArray.length){Structure=StructureArray.shift();if(Structure.match(/Array\d+/)){ArrayIndex=Structure.match(/\d+/)[0];ArrayIndex--;if(Result===undefined){Result=[];}
while(Result.length<ArrayIndex){RemoveIndexes.push(Result.length);Result.push("");}
if(StructureArray.length==0){Result.push(Value);}
else{SubName=StructureArray.join("_");if(SubName!=""){SubName="_"+SubName;}
SubName=SettingName+SubName;if(Result.length<ArrayIndex){Result.push(ValueSet(undefined,SubName,Value));}
else{Result[ArrayIndex]=ValueSet(Result[ArrayIndex],SubName,Value);}}
if(RemoveIndexes.length){RemoveIndexes.reverse();for(ArrayIndex in RemoveIndexes){Result.splice(RemoveIndexes[ArrayIndex],1);}}}
else if(Structure.match(/Hash/)){HashKey=Structure.match(/###(.*?)$/)[1];if(Result===undefined){Result={};}
if(StructureArray.length==0){Result[HashKey]=Value;}
else{SubName=StructureArray.join("_");if(SubName!=""){SubName="_"+SubName;}
SubName=SettingName+SubName;if(Result[HashKey]===undefined){Result[HashKey]=ValueSet(undefined,SubName,Value);}
else{Result[HashKey]=ValueSet(Result[HashKey],SubName,Value);}}}
else{Result=Value;}}
else{if($.isArray(Value)){if(Result===undefined){Result=[];}
for(Item in Value){Result.push(ValueSet(Result[Item],"",Value[Item]));}}
else if(typeof Value=="object"){if(Result===undefined){Result={};}
for(Item in Value){Result[Item]=ValueSet(Result[Item],"",Value[Item]);}}
else{Result=Value;}}
return Result;}
TargetNS.RemoveItem=function($Object){var $Div=$Object.closest(".Array, .Hash");$Object.closest("div")
.remove();CheckMinItems($Div);CheckMaxItems($Div);}
TargetNS.AddArrayItem=function($Object){var
Data='Action=AdminSystemConfigurationGroup;Subaction=AddArrayItem;',$Widget=$Object.closest(".WidgetSimple"),$SettingName=$Widget.find("input[name='SettingName']"),IDSuffix=$Object.attr("data-suffix"),Structure=StructureGet($Object);if($Widget.find(".AJAXLoader:visible").length>0){return;}
Data+='SettingName='+encodeURIComponent($SettingName.val())+';';Data+='IDSuffix='+encodeURIComponent(IDSuffix)+';';Data+='Structure='+encodeURIComponent(Structure)+';';Core.UI.WidgetOverlayShow($Widget,'Loading');Core.AJAX.FunctionCall(Core.Config.Get('Baselink'),Data,function(Response){var Suffix=$Object.attr("data-suffix"),SuffixID=Suffix.match(/\d+$/)[0],$Array=$Object.parent(),RemoveButton,Key="",ElementSuffix;if(Response.Error){alert(Response.Error);$Widget.find(".AJAXLoader").hide();return;}
if(Response.Item){$Object.before(Core.Template.Render("SysConfig/AddArrayItem"));$Array.find(".ArrayItem:last").append(Response.Item);RemoveButton=Core.Template.Render("SysConfig/RemoveButton");$Array.find("> .ArrayItem:last, > .ArrayItem:last .ArrayItem")
.append(RemoveButton);$Array.find("> .ArrayItem:last .RemoveButton")
.show()
.on("click",function(){TargetNS.RemoveItem($(this).closest("div"));});$Array.find("> .ArrayItem:last .Array,> .ArrayItem:last .Hash").each(function(){var Count=0,Suffix=[],$Element=$(this),$HashItem=$(this).closest(".HashItem");if($HashItem.length){Key=$HashItem.find(".Key").val();}
while(!$Array.is($Element)){Count=$Element.find("> .Array > .ArrayItem, > .Hash > .HashItem, > .ArrayItem, > .HashItem").length;Count++;if($Element.hasClass("Array")){Suffix.push("_Array"+Count);}
else{Suffix.push("_Hash###"+Key);}
$Element=$Element.parent().closest(".Hash, .Array");}
Suffix.shift();ElementSuffix=IDSuffix+Suffix.join("");$(this).find("> .ArrayItem:last").after(Core.Template.Render("SysConfig/AddButton",{Suffix:ElementSuffix+"_Array"+Count,Class:'AddArrayItem'}));$(this).find("> .HashItem:last").after(Core.Template.Render("SysConfig/AddButton",{Suffix:ElementSuffix+"_Hash###",Class:'AddHashKey'}));$(this).find("> button.AddArrayItem")
.show()
.off("click")
.on("click",function(){TargetNS.AddArrayItem($(this));});$(this).find("button.AddKey")
.show()
.off("click")
.on("click",function(){AddHashKey($(this));});$(this).find("> button.AddHashKey")
.show()
.off("click")
.on("click",function(){TargetNS.AddHashKeyClick($(this));});});Core.UI.InputFields.InitSelect($Array.find("> .ArrayItem:last .Modernize"));$Array.find("> .ArrayItem:last input:checkbox").on("change",function(){TargetNS.CheckboxValueSet($(this));});}
CheckMinItems($Object);CheckMaxItems($Object);SuffixID++;Suffix=Suffix.replace(/\d+$/,SuffixID);$Object.attr("data-suffix",Suffix);Core.UI.WidgetOverlayHide($Widget);});}
TargetNS.AddHashKeyClick=function($Object){var $Widget=$Object.closest(".WidgetSimple"),RemoveButton=Core.Template.Render("SysConfig/RemoveButton");if($Widget.find(".AJAXLoader:visible").length>0){return;}
Core.UI.WidgetOverlayShow($Widget,'Loading');$Object.before(Core.Template.Render("SysConfig/AddHashKey",{'IDSuffix':$Object.attr("data-suffix")}));$Object
.closest("div")
.find("button.AddKey:last")
.off("click")
.on("click",function(){AddHashKey($(this));})
.after(RemoveButton);$Object
.closest("div")
.find("button.RemoveButton:last").on("click",function(){TargetNS.RemoveItem($(this).closest("div"));});CheckMinItems($Object);CheckMaxItems($Object);Core.UI.WidgetOverlayHide($Widget);}
function AddHashKey($Object){var
$Widget=$Object.closest(".WidgetSimple"),$HashItem=$Object.parent(),$KeyElement=$HashItem.find(".Key"),Key=$KeyElement.val(),Name=$Widget.find("input[name='SettingName']").val(),Data='Action=AdminSystemConfigurationGroup;Subaction=AddHashKey;',IDSuffix=$KeyElement.attr("data-suffix")+Key,Structure=StructureGet($Object);if($Widget.find(".AJAXLoader:visible").length>0){return;}
if(!$KeyElement.val()){Core.UI.Dialog.ShowAlert(Core.Language.Translate('An Error Occurred'),Core.Language.Translate('The key must not be empty.'));return;}
if($HashItem.closest(".Hash").find("> .HashItem >.Key").filter(function(){return $(this).val()===Key;}).length>1){Core.UI.Dialog.ShowAlert(Core.Language.Translate('An Error Occurred'),Core.Language.Translate("A key with this name ('%s') already exists.",Key));return;}
Data+='Key='+encodeURIComponent(Key)+';';Data+='SettingName='+encodeURIComponent($Widget.find("input[name='SettingName']").val());Data+=';IDSuffix='+encodeURIComponent(IDSuffix)+';';Data+='Structure='+encodeURIComponent(Structure)+';';Core.UI.WidgetOverlayShow($Widget,'Loading');Core.AJAX.FunctionCall(Core.Config.Get('Baselink'),Data,function(Response){var $Hash=$Object.closest(".Hash"),RemoveButton,Key="";if(Response.Error){alert(Response.Error);$Widget.find(".AJAXLoader").hide();return;}
if(Response.Item){$HashItem.find("input").attr("name",Name+"Key[]");$HashItem.find("button.AddKey").remove();$HashItem.append(Response.Item);RemoveButton=Core.Template.Render("SysConfig/RemoveButton");$HashItem.append(RemoveButton);$HashItem.find(".ArrayItem")
.append(RemoveButton);$HashItem.find(".RemoveButton")
.show()
.on("click",function(){TargetNS.RemoveItem($(this).closest("div"));});$HashItem.find(".Array, .Hash").each(function(){var Count=0,Suffix=[],$Element=$(this),$ClosestHashItem=$(this).closest(".HashItem"),ElementSuffix;if($ClosestHashItem.length){Key=$ClosestHashItem.find(".Key").val();}
while(!$Hash.is($Element)){Count=$Element.find("> .Array > .ArrayItem, > .Hash > .HashItem, > .ArrayItem, > .HashItem").length;Count++;if($Element.hasClass("Array")){Suffix.push("_Array"+Count);}
else{Suffix.push("_Hash###"+Key);}
$Element=$Element.parent().closest(".Hash, .Array");}
Suffix.shift();ElementSuffix=IDSuffix+Suffix.join("");$(this).find("> .ArrayItem").after(Core.Template.Render("SysConfig/AddButton",{Suffix:ElementSuffix+"_Array"+Count,Class:'AddArrayItem'}));$(this).find("> .HashItem").after(Core.Template.Render("SysConfig/AddButton",{Suffix:ElementSuffix+"_Hash###",Class:'AddHashKey'}));$HashItem.find("button.AddArrayItem")
.show()
.off("click")
.on("click",function(){TargetNS.AddArrayItem($(this));});$Hash.find("button.AddKey")
.show()
.off("click")
.on("click",function(){AddHashKey($(this));});$HashItem.find("button.AddHashKey")
.show()
.off("click")
.on("click",function(){TargetNS.AddHashKeyClick($(this));});});$Hash.find("input:checkbox").on("change",function(){TargetNS.CheckboxValueSet($(this));});Core.UI.InputFields.InitSelect($Hash.find(".Modernize"));$KeyElement.attr("readonly","readonly");}
Core.UI.WidgetOverlayHide($Widget);});}
TargetNS.SettingReset=function($Object,ResetOptions){var $Widget=$Object.closest(".WidgetSimple"),$SettingName=$Widget.find("input[name='SettingName']"),Data='Action=AdminSystemConfigurationGroup;Subaction=SettingReset;';Data+='SettingName='+encodeURIComponent($SettingName.val())+';';Data+='ResetOptions='+encodeURIComponent(ResetOptions)+';';Core.UI.WidgetOverlayShow($Widget,'Loading');Core.AJAX.FunctionCall(Core.Config.Get('Baselink'),Data,function(Response){var LinkURL='Action=AdminSystemConfigurationDeployment;Subaction=Deployment';TargetNS.SettingRender(Response,$Widget);TargetNS.CleanWidgetClasses($Widget);if(Response.Data.SettingData.IsDirty){$Widget.addClass('IsDirty');}
if(Response.Error===undefined){Core.UI.WidgetOverlayHide($Widget,true);if(Response.DeploymentNeeded==0){Core.UI.HideNotification(Core.Language.Translate('You have undeployed settings, would you like to deploy them?'),'Notice',function(){Core.UI.InitStickyElement();});}
else{if(Core.Config.Get('SessionUseCookie')==='0'){LinkURL+=';'+Core.Config.Get('SessionName')+'='+Core.Config.Get('SessionID');}
Core.UI.ShowNotification(Core.Language.Translate('You have undeployed settings, would you like to deploy them?'),'Notice',LinkURL,function(){Core.UI.InitStickyElement();},undefined,'fa-bell');Core.UI.InitMessageBoxClose();}}
Core.App.Publish('SystemConfiguration.SettingListUpdate');});}
TargetNS.RevertToHistoricalValue=function($Object){var $SettingName=$("#SettingName"),URL=Core.Config.Get('Baselink')+'Action=AdminSystemConfigurationSettingHistory;Subaction=RevertToHistoricalValue;';URL+='SettingName='+encodeURIComponent($SettingName.attr('value'))+';';URL+='ModifiedVersionID='+encodeURIComponent($Object.attr('value'));URL+=SerializeData(Core.App.GetSessionInformation());if(window.confirm(Core.Language.Translate("Do you really want to revert this setting to its historical value?"))){window.location=URL;}
return false;}
TargetNS.CheckboxValueSet=function($Object){$Object
.next()
.val($Object.is(":checked")?1:0);}
TargetNS.CleanWidgetClasses=function($Widget){$Widget.removeClass('IsLockedByMe IsDirty IsModified IsLockedByAnotherUser');}
TargetNS.SettingRender=function(Response,$Widget){var $EditLink=$Widget.find(".SettingEdit");$Widget.find("fieldset").html(Response.Data.HTMLStrg);$EditLink.find("i").removeClass();$EditLink.removeClass();if(Response.Data.SettingData.ExclusiveLockGUID=="0"){$EditLink.find("i").addClass("fa fa-pencil-square-o");$EditLink.addClass("SettingEdit Unlocked");$EditLink.attr("title",Core.Language.Translate("Edit this setting"));}
else{$EditLink.find("i").addClass("fa fa-unlock");$EditLink.addClass("SettingEdit Locked");$EditLink.attr("title",Core.Language.Translate("Unlock setting."));$Widget.find("fieldset .Update").on("click",function(){TargetNS.Update($(this),0,0);});$Widget.find("fieldset .Cancel").off("click").on("click",function(){Core.Agent.Admin.SystemConfiguration.Cancel($(this));return false;});TargetNS.InitButtonVisibility($Widget);$Widget.find("button.AddArrayItem").on("click",function(){$(this).blur();TargetNS.AddArrayItem($(this));});$Widget.find("button.AddHashKey").on("click",function(){$(this).blur();TargetNS.AddHashKeyClick($(this));});$Widget.find(".RemoveButton").on("click",function(){TargetNS.RemoveItem($(this).closest("div"));});}
if(Response.Data.SettingData.IsValid=='1'){$Widget.find(".Header .Icon i")
.addClass("Hidden");$Widget.find(".SettingDisabled").addClass("Hidden");$Widget.find(".SettingEnabled").removeClass("Hidden");$Widget.removeClass("IsDisabled");}
else{$Widget.find(".Header .Icon i")
.removeClass("Hidden");$Widget.find(".SettingDisabled").removeClass("Hidden");$Widget.find(".SettingEnabled").addClass("Hidden");$Widget.addClass("IsDisabled");}
if(Response.Data.SettingData.UserModificationActive=='1'){$Widget.find(".UserModificationNotActive").addClass("Hidden");$Widget.find(".UserModificationActive").removeClass("Hidden");}
else{$Widget.find(".UserModificationNotActive").removeClass("Hidden");$Widget.find(".UserModificationActive").addClass("Hidden");}
if(Response.Data.Error!=null){alert(Response.Data.Error);}
if(Response.Data.HTMLStrg.indexOf("<select")>-1){Core.UI.InputFields.Activate($Widget.find("fieldset"));}
if(Response.Data.SettingData.IsModified){$Widget.addClass('IsModified');$Widget.find("button.ResetSetting").show();$Widget.find(".ResetUserSetting").removeClass("Hidden");}
else{$Widget.removeClass('IsModified');$Widget.find(".ResetUserSetting").addClass("Hidden");}
if(Response.Data.SettingData.IsDirty){$Widget.addClass('IsDirty');}
if($Widget.hasClass('MenuExpanded')){$Widget.find('.WidgetMessage.Bottom').show();}
$Widget.find("a.ResetSetting")
.off("click")
.on("click",function(){Core.Agent.Admin.SystemConfiguration.InitDialogReset($(this));return false;});if(Response.Data.SettingData.IsLockedByMe=="1"){$Widget.addClass('IsLockedByMe');}
if(Response.Data.SettingData.Invalid!="1"){$Widget.find(".Icon .fa-check-circle-o").removeClass("Hidden");}
$Widget.find("input:checkbox")
.off("change")
.on("change",function(){TargetNS.CheckboxValueSet($(this));});}
function CheckMinItems($Object){var $Structure=$Object,MinItems;if(!$Structure.hasClass("Array")&&!$Structure.hasClass("Hash")){$Structure=$Object.closest(".Array, .Hash");}
MinItems=$Structure.attr("data-min-items");if(MinItems!==undefined){if($Structure.find("> .ArrayItem, > .HashItem").length<=MinItems){$Structure.find("> .ArrayItem .RemoveButton, > .HashItem .RemoveButton").hide();}
else{$Structure.find("> .ArrayItem .RemoveButton, > .HashItem .RemoveButton").show();}}
else{$Structure.find("> .ArrayItem .RemoveButton, > .HashItem .RemoveButton").show();}}
function CheckMaxItems($Object){var $Structure=$Object,MaxItems;if(!$Structure.hasClass("Array")&&!$Structure.hasClass("Hash")){$Structure=$Object.closest(".Array, .Hash");}
MaxItems=$Structure.attr("data-max-items");if(MaxItems!==undefined){if($Structure.find("> .ArrayItem, > .HashItem").length>=MaxItems){$Structure.find("> .AddArrayItem, > .AddHashKey").hide();}
else{$Structure.find("> .AddArrayItem:not(.Hidden), > .AddHashKey:not(.Hidden)").show();}}
else{$Structure.find("> .AddArrayItem:not(.Hidden), > .AddHashKey:not(.Hidden)").show();}}
function StructureGet($Object,Structure){var Result="",$Item;if(Structure){Result=Structure;}
$Item=$Object.parent().closest(".Array, .Hash, .Setting");if($Item.hasClass("Setting")){return Result;}
else if($Item.hasClass("Array")){if(Result){Result+='.';}
Result+="Array";}
else if($Item.hasClass("Hash")){if(Result){Result+='.';}
Result+="Hash";}
return StructureGet($Item,Result);}
function CheckIDs($Object){$Object.find(".Entry, .AddArrayItem").each(function(){var OldID,ID,Key,SubString,Count=0,$ClosestItem,ValueType,Index;if($(this).hasClass("Entry")){OldID=$(this).attr("id");}
else{OldID=$(this).attr("data-suffix");}
ID=OldID;for(Index in ValueTypes){if($(this).hasClass(ValueTypes[Index])){ValueType=ValueTypes[Index];break;}}
if(ID.indexOf("_Hash###")>0){while(ID.indexOf("_Hash###")>0){SubString=ID.match(/(_Hash###.*?)(_Array|_Hash|Day$|Month$|Year$|Hour$|Minute$|$)/)[1];ID=ID.replace(SubString,"_PLACEHOLDER"+Count);Count++;}
$ClosestItem=$(this).closest(".HashItem");while(Count>0){Count--;Key=$ClosestItem.find(".Key").val();Key=Core.App.EscapeHTML(Key);ID=ID.replace("_PLACEHOLDER"+Count,"_Hash###"+Key);$ClosestItem=$ClosestItem.parent().closest(".HashItem");}
if($(this).hasClass("Entry")){$(this).attr("id",ID);}
else{$(this).attr("data-suffix",ID);}}
if(ID.indexOf("_Array")>=0){if($(this).closest('.Array').find(".ArrayItem").length>0){$(this).closest('.Array').find(".ArrayItem").each(function(){Count=0;$(this).find(".SettingContent input:visible:not(.InputField_Search), "+
".SettingContent select:visible, .SettingContent select.Modernize, "+
".SettingContent textarea:visible").each(function(){OldID=$(this).attr('id');ID=OldID;while(ID.indexOf("_Array")>=0){SubString=ID.match(/(_Array\d+)/)[1];ID=ID.replace(SubString,"_PLACEHOLDER"+Count);Count++;}
$ClosestItem=$(this).closest('.ArrayItem');while(Count>0){Count--;Key=$ClosestItem.index()+1;ID=ID.replace("_PLACEHOLDER"+Count,"_Array"+Key);$(this).attr('id',ID);$ClosestItem=$ClosestItem.parent().closest(".ArrayItem");}
if(OldID!=ID&&ValueType){if(window["Core"]["SystemConfiguration"][ValueType]["CheckID"]){window["Core"]["SystemConfiguration"][ValueType]["CheckID"]($(this),OldID);}}});});}
else{OldID=$(this).closest('.Array').find("button").attr('data-suffix');ID=OldID;while(ID.indexOf("_Array")>=0){SubString=ID.match(/(_Array\d+)/)[1];ID=ID.replace(SubString,"_PLACEHOLDER"+Count);Count++;}
$ClosestItem=$(this).closest('.ArrayItem');for(Index=0;Index<Count;Index++){Key=$ClosestItem.index();if(Key<0){Key=0;}
Key++;ID=ID.replace("_PLACEHOLDER"+Index,"_Array"+Key);$(this).closest('.Array').find("button").attr('data-suffix',ID);$ClosestItem=$ClosestItem.parent().closest(".ArrayItem");}}}});}
TargetNS.InitButtonVisibility=function($Object){if($Object===undefined){$Object=$(document);}
$Object.find(".Hash[data-min-items], .Array[data-min-items]").each(function(){CheckMinItems($(this));});$Object.find(".Hash[data-max-items], .Array[data-max-items]").each(function(){CheckMaxItems($(this));});$Object.find(".Hash:not([data-min-items]), .Array:not([data-min-items])").each(function(){$(this).find("> .ArrayItem > .RemoveButton, > .HashItem > .RemoveButton").show();});$Object.find(".Hash:not([data-max-items]), .Array:not([data-max-items])").each(function(){$(this)
.find("> .AddHashKey:not(.Hidden), > .AddArrayItem:not(.Hidden)").show();});}
function SettingList(Selected){var Data,Action='AdminSystemConfigurationGroup',BreadCrumbItems,ListItem,URL=Core.Config.Get('CGIHandle'),Index;$('.ContentColumn').html(Core.Template.Render("Agent/WidgetLoading"));$('ul.BreadCrumb li:nth-child(2)').nextAll().remove();BreadCrumbItems=Selected.split("::");if(Core.Config.Get('Action')=='AgentPreferences'){URL+="?Action=AgentPreferences;Subaction=Group;Group=Advanced;RootNavigation=";}
else{URL+="?Action=AdminSystemConfigurationGroup;RootNavigation=";}
for(Index in BreadCrumbItems){if(Index!=0){URL+="::";}
URL+=BreadCrumbItems[Index];ListItem=Core.Template.Render("SysConfig/BreadCrumbItem",{Title:BreadCrumbItems[Index],URL:URL});$('ul.BreadCrumb').append(ListItem);}
if(Core.Config.Get('Action')=='AgentPreferences'){Action="AgentPreferences";}
window.history.pushState(null,null,URL);Data={Action:Action,Subaction:'SettingList',Category:$('#Category').val(),RootNavigation:Selected};if(Core.Config.Get('Action')=='AgentPreferences'){Data["IsValid"]=1;Data["Group"]='Advanced';}
if(!$('#ConfigTree').length){return;}
Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'),Data,function(HTML){var Counter=0;$(".ContentColumn").html(HTML);TargetNS.Init();if(Core.Config.Get('Action')=='AgentPreferences'){Core.Agent.Preferences.InitSysConfig();Core.UI.Table.InitTableFilter($("#FilterSettings"),$(".SettingsList"));}
else{Core.Agent.Admin.SystemConfiguration.InitGroupView(true);}
if($('.WidgetSimple .Setting').length){$('#UserWidgetState_SystemConfiguration_Help, #UserWidgetState_SystemConfiguration_Sticky').removeClass('Hidden');}
else{$('#UserWidgetState_SystemConfiguration_Help, #UserWidgetState_SystemConfiguration_Sticky').addClass('Hidden');}
Core.UI.InitStickyElement();Core.App.Publish('SystemConfiguration.SettingListUpdate');Core.UI.InputFields.InitSelect($(".SettingsList .Modernize"));$('html, body').animate({scrollTop:$('.ContentColumn .WidgetSimple').first().position().top},{duration:'fast',always:function(){if(Counter===1){$('ul.SettingsList').addClass('Initialized');}
Counter++;},});},'html');window.setTimeout(function(){Core.Agent.Admin.SystemConfiguration.InitFavourites();},1000);}
Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.SystemConfiguration||{}));
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.SystemConfiguration=Core.SystemConfiguration||{};Core.SystemConfiguration.Date=(function(TargetNS){TargetNS.ValueGet=function($Object){var Value;if($Object.attr("name").endsWith("Day")){Value=DateValueGet($Object);}
return Value;};TargetNS.CheckID=function($Object,OldID){var ID,OldSubID,SubID,Class,ErrorDivID;if($Object.hasClass("Entry")){ID=$Object.attr("id");}
else{ID=$Object.attr("data-suffix");}
if(!OldID.endsWith("Day")){return;}
SubID=ID.substr(0,ID.length-3);OldSubID=OldID.substr(0,OldID.length-3);Class=$Object.attr("class");Class=Class.replace("Validate_DateYear_"+OldSubID+"Year","Validate_DateYear_"+SubID+"Year");Class=Class.replace("Validate_DateMonth_"+OldSubID+"Month","Validate_DateMonth_"+SubID+"Month");$Object.attr("class",Class);OldSubID=Core.App.EscapeSelector(OldSubID);ErrorDivID=$('div#'+OldSubID+"YearError").attr('id');ErrorDivID.replace(OldSubID,SubID);$('div#'+OldSubID+"YearError").attr('id',ErrorDivID);ErrorDivID=$('div#'+OldSubID+"MonthError").attr('id');ErrorDivID.replace(OldSubID,SubID);$('div#'+OldSubID+"MonthError").attr('id',ErrorDivID);ErrorDivID=$('div#'+OldSubID+"DayError").attr('id');ErrorDivID.replace(OldSubID,SubID);$('div#'+OldSubID+"DayError").attr('id',ErrorDivID);};function DateValueGet($Object){var
Day,Month,Year,Prefix,Result;Prefix=$Object.attr("id");Prefix=Prefix.substr(0,Prefix.length-3);Prefix=Core.App.EscapeSelector(Prefix);if($Object.is('select')){Day=$Object.find("option:selected").val();if(Day<10){Day="0"+Day;}
Month=$("#"+Prefix+"Month").find("option:selected").val();if(Month<10){Month="0"+Month;}
Year=$("#"+Prefix+"Year").find("option:selected").val();}
else{Day=$Object.val();Month=$("#"+Prefix+"Month").val();Year=$("#"+Prefix+"Year").val();}
Result=Year+"-"+Month+"-"+Day;return Result;}
Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.SystemConfiguration.Date||{}));
