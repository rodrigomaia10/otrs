// --
// var/http/htdocs/js/Core.Customer.Kanban.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * ccresencio@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

/**
* @namespace Core.Customer.Kanban
* @memberof Core.Customer
* @author OTRS AG
* @description
*      This namespace contains the special function for search bar of CustomerPortal module.
*/
Core.Customer.Kanban = (function (TargetNS) {

    TargetNS.Init = function () {

        var BoardsColumnData  = JSON.parse(Core.Config.Get('BoardsColumnData'));


        var Kanban = new jKanban({
            element : '#kanban',
            gutter  : '10px',
            revertOnSpill: true,
            widthBoard: '295px',
            dragBoards: false,                                        
            boards: BoardsColumnData.ColumnData,
            click            : function (el) {},                             // callback when any board's item are clicked
            context          : function (el, event) {},                      // callback when any board's item are right clicked
            dragEl           : function (el, source) {},                     // callback when any board's item are dragged
            dragendEl        : function (el) {},                             // callback when any board's item stop drag
            dropEl           : function (el, target, source, sibling) {},    // callback when any board's item drop in a board
            dragBoard        : function (el, source) {},                     // callback when any board stop drag
            dragendBoard     : function (el) {},                             // callback when any board stop drag
            buttonClick      : function(el, boardId) {},                     // callback when the board's button is clicked
            propagationHandlers: [],          
        });
    }

    TargetNS.TicketZoom = function (TicketNumber) {           
        window.open(Core.Config.Get('Baselink') + 'Action=CustomerPortalTicketZoom;TicketNumber='+TicketNumber, '_blank');
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
    
}(Core.Customer.Kanban || {}));