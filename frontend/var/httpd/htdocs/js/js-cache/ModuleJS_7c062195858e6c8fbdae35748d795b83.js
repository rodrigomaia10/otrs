// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.Admin=Core.Agent.Admin||{};Core.Agent.Admin.CustomerCompany=(function(TargetNS){TargetNS.Init=function(){if(parseInt(Core.Config.Get('ReadOnly'),10)===1){Core.Form.DisableForm($("form#edit"));}};Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.Admin.CustomerCompany||{}));
