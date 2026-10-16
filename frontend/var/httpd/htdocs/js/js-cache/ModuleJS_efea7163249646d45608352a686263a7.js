// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Customer=Core.Customer||{};Core.Customer.Login=(function(TargetNS){if(!Core.Debug.CheckDependency('Core.Customer.Login','Core.UI','Core.UI')){return false;}
TargetNS.Init=function(){var Now=new Date(),Diff=Now.getTimezoneOffset(),FormID,$ContainerLinks=$('[data-container-link]'),LoginFailed=Core.Config.Get('LoginFailed'),SignupError=Core.Config.Get('SignupError');if(!Core.Customer.SupportedBrowser){$('#Login').hide();$('#Reset').hide();$('#Signup').hide();$('#PreLogin').hide();$('#OldBrowser').show();return false;}
Core.Form.EnableForm($('#Login form, #Reset form, #Signup form'));$('#TimeZoneOffset').val(Diff);if($('#PreLogin').length){$('#PreLogin form').submit();return false;}
$('#User').blur(function(){if($(this).val()){$('#ResetUser').val($(this).val()).prev('label').hide();}});$ContainerLinks.on('click',function(){FormID=$(this).data('containerLink');TargetNS.ActivateForm(FormID);});if(typeof LoginFailed!=='undefined'&&parseInt(LoginFailed,10)===1){Core.UI.Animate($('#Login'),'Shake');}
if(typeof SignupError!=='undefined'&&parseInt(SignupError,10)===1){TargetNS.ActivateForm('Signup');}};TargetNS.ActivateForm=function(FormID){$('#Container > div').addClass('Hidden');$('#'+FormID).removeClass('Hidden');}
Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Customer.Login||{}));
