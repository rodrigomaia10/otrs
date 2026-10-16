// --
// var/httpd/htdocs/js/Core.Agent.Admin.QueueAndService.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

Core.Agent.Admin.QueueAndService = (function (TargetNS) {
	 
    TargetNS.Init = function () {

		var RelationItems = Core.Config.Get('RelationItems');
		
        // initialize "SelectAll" checkbox and bind click event on "SelectAll" for each relation item
        if (RelationItems) {

            $.each(RelationItems, function (index) {

                Core.Form.InitSelectAllCheckboxes($('table td input[type="checkbox"][name=' + RelationItems[index] + ']'), $('#SelectAll' + RelationItems[index]));

                $('input[type="checkbox"][name=' + RelationItems[index] + ']').click(function () {
                    Core.Form.SelectAllCheckboxes($(this), $('#SelectAll' + RelationItems[index]));
                });
            });
        }
		
		Core.UI.Table.InitTableFilter($('#FilterQueues'), $('#Queues'));
		Core.UI.Table.InitTableFilter($('#FilterServices'), $('#Services'));
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.QueueAndService || {}));
