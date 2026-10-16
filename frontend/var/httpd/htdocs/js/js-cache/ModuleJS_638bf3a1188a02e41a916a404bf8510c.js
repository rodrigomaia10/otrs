// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
"use strict";var Core=Core||{};Core.Agent=Core.Agent||{};Core.Agent.Admin=Core.Agent.Admin||{};Core.Agent.Admin.Log=(function(TargetNS){TargetNS.Init=function(){Core.UI.Table.InitTableFilter($('#FilterLogEntries'),$('#LogEntries'));$('#HideHint').on('click',function(){$(this).parents('.SidebarColumn').hide();});};Core.Init.RegisterNamespace(TargetNS,'APP_MODULE');return TargetNS;}(Core.Agent.Admin.Log||{}));
