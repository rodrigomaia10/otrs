// Copyright (C) 2019 Service Up, http://serviceup.com.br/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.Admin=Core.Agent.Admin||{};Core.Agent.Admin.DynamicFieldMask=(function(TargetNS){TargetNS.Init=function(){$("#Mask, #Monetary").addClass("Hidden");if($("#MaskType").val()=='Mask'){$("#Mask").removeClass("Hidden");}
else if($("#MaskType").val()=='Monetary'){$("#Monetary").removeClass("Hidden");}
$("#MaskType").bind('change',function(){var $Div=$("#"+$(this).val());if($(this).val()=='Mask'){$("#Monetary").addClass("Hidden");}
else{$("#Mask").addClass("Hidden");}
$Div.removeClass('Hidden');});};return TargetNS;}(Core.Agent.Admin.DynamicFieldMask||{}));
