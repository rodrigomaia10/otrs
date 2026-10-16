// --
// var/httpd/htdocs/js/Core.Agent.Admin.KanbanBoard.js
// Copyright (C) 2019 Service nUp, http://www.serviceup.com.br
//
// written/edited by:
// * nfreitas@serviceup.com.br
// --


"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.KanbanBoard
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the Kanban Boards module.
 */
Core.Agent.Admin.KanbanBoard = (function (TargetNS) {
    /**
     * @name Init
     * @memberof Core.Agent.Admin.KanbanBoard
     * @function
     * @description
     *       Initialize module functionality
     */

    TargetNS.Init = function () {

        // Initialize filter
        Core.UI.Table.InitTableFilter($('#FilterKanbanBoards'), $('#KanbanBoardsTable'));

    };


    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

return TargetNS;
}(Core.Agent.Admin.KanbanBoard || {}));
