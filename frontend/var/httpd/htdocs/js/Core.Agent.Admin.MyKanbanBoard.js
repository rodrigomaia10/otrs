// --
// var/httpd/htdocs/js/Core.Agent.Admin.MyKanbanBoard.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * nfreitas@serviceup.com.br
// * poliveira@serviceup.com.br
// --


"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};


$('.KanbanAddBoard').click(function(){
    window.open(Core.Config.Get('Baselink') + 'Action=AdminKanbanBoards;Subaction=BoardsEdit;ID=NEW;OpenBy=Kanban','_blank');
});

var currentURL = (window.location.href).split("Subaction=");
//currentURL = currentURL.split("Subaction=");
var currentURL2 = (currentURL[1]).split(";");
var timeToReload;





if( currentURL2[0] != 'KanbanBoard'){
    console.log("No action available");
}
else {
    /**
     * @namespace Core.Agent.Admin.KanbanBoard
     * @memberof Core.Agent.Admin
     * @author OTRS AG
     * @description
     *      This namespace contains the special module functions for the Kanban Boards module.
     */
    Core.Agent.Admin.MyKanbanBoard = (function (TargetNS) {
        /**
         * @name Init
         * @memberof Core.Agent.Admin.MyKanbanBoard
         * @function
         * @description
         *       Initialize module functionality
         */
        TargetNS.Init = function () {

            var BoardsColumnData  = JSON.parse(Core.Config.Get('BoardsColumnData'));
            
            // Convert minutes to milisecounds
            setTimeout(Refresh, BoardsColumnData.RefreshTime*60000);
            
            function Refresh() {
                window.location.reload(true);
            }       

            $(document).ready(function () {
              
                if(BoardsColumnData){
                    var KanbanTest = new jKanban({
                        element : '#kanban',
                        gutter  : '10px',
                        revertOnSpill: true,
                        widthBoard: '295px',
                        click : function(el){                           
                        },
                        dragBoards       : false,   
                        boards: BoardsColumnData.ColumnData,
                        click : function (el) {},                     
                        dragEl : function (el, source) {                          
                        },           
                        dragendEl : function (el) {                            
                        },                             
                        dropEl : function (el, target, source, sibling) {                                                                                    
                            // var TicketBelow =   sibling.getAttribute('data-eid');  
                            // EL = Card changed data-eid                         
                            var TicketID = el.getAttribute('data-eid');
                            // Target = New Column                     
                            var NewColumn =  target.getAttribute('data-id-column'); 
                            
                            // Verify to readonly columns                         
                            if($(target).hasClass('kanban-drag-after')){
                                KanbanTest.drake.cancel(true);
                                return 0;
                            }                        

                            //To AJAX Spinner
                            $('#AJAXLoaderKanbanColumn_'+NewColumn).css('display','inline-block');
                            $('#ColumnTitleFormat_'+NewColumn).css('min-width','76%' );
                            $('#ColumnTitleFormat_'+NewColumn).css('max-width','76%' );
     
                            // Get the position of cards in new column
                            var NewColumnsTickets = [];
                            $("main[data-id-column]").each( function () {
                                if($(this).attr("data-id-column") == NewColumn){
                                    
                                    $.each($(this).children("div"), function() {
                                        var TicketIDPush = $(this).attr("data-eid");
                                        NewColumnsTickets.push(TicketIDPush);
                                    });
                                }                           
                            });

                            // Get the position of cards in old column
                            var OldColumn =  source.getAttribute('data-id-column');
                            var OldColumnsTickets = [];
                            $("main[data-id-column]").each( function () {
                                if($(this).attr("data-id-column") == OldColumn){                                    
                                    $.each($(this).children("div"), function() {
                                        var TicketIDPush = $(this).attr("data-eid");
                                        OldColumnsTickets.push(TicketIDPush);
                                    });
                                }                           
                            });

                            var Data = {
                                        "Action":"KanbanAJAXHandler",
                                        "Subaction":"TicketChangeOfColumn",
                                        "TicketID": TicketID ,                
                                        "NewColumnID": NewColumn ,                
                                        "OldColumn": OldColumn ,                
                                        "BoardID": $('#BoardID').val() ,                
                                        "OldColumnsTickets": JSON.stringify(OldColumnsTickets),                
                                        "NewColumnsTickets": JSON.stringify(NewColumnsTickets),                
                                    };
                                                                            
                                Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                                    if (!Response) {
                                            // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                                        Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                                    }
                                    else{
                                        
                                        //Generate toast to permission of queue change error
                                        if(Response.Message){
                                            $.toast({
                                                text: Response.Message,
                                                icon: 'info',
                                                loader: true,        
                                                loaderBg: '#ff9922', 
                                                hideAfter: 4000,
                                                afterHidden: function () { location.reload() }, 
                                            });                                                                                                                            
                                        }

                                        $('#AJAXLoaderKanbanColumn_'+NewColumn).css('display','none');
                                        $('#ColumnTitleFormat_'+NewColumn).css('min-width','84%' );
                                        $('#ColumnTitleFormat_'+NewColumn).css('max-width','84%' );

                                    }
                            });
                        },   
                        dragBoard        : function (el, source) {
                           
                        },// callback when any board stop drag
                        dragendBoard     : function (el) {
                         
                        }, // callback when any board stop drag
                        buttonClick      : function(el, boardId) {},
                                         
                    });                

                    // Change header and label color
                    $(".kanban-board header").css("background-color", BoardsColumnData.BoardColor);
                    $(".kanban-board header .kanban-title-board").css("color", BoardsColumnData.BoardColorLabel);

                    // To Collapsed the collumn when is loaded
                    $("div[data-id]").each( function () {
                        var divFather = this;                        

                        $(BoardsColumnData.ColumnData).each( function () {   
                            if(this.StartCollapsed == 'Colapsed'){
                                if($(divFather).attr("data-id") == this.id){    
                                    $(divFather).children("header").addClass('Colapsed');
                                    $(divFather).children("header").next().slideToggle('fast');
                                    $(divFather).children("header").parent().css('width', '30px');
                                }
                            }                        
                        });
                    });

                    //To added readonly on the collumn
                    $("main[data-id-column]").each( function () {
                        var divMain = this;
                     
                        $(BoardsColumnData.ColumnData).each( function () {   
                            if(this.PreviewOnly == 'kanban-drag-after'){
                                if($(divMain).attr("data-id-column") == this.id){    
                                    $(divMain).addClass(this.PreviewOnly);

                                }
                            }                        
                        });                   
                    });

                }                  
                
                $('.ColumnTitleFormat').click(function(){
                    
                    if($(this).parent().parent().hasClass('Colapsed')){
                        $(this).parent().parent().next().slideToggle('fast');
                        $(this).parent().parent().css('writing-mode', 'unset');
                        $(this).parent().parent().parent().css('width', '290px');
                        $(this).parent().parent().removeClass('Colapsed');
                    }else{
                        $(this).parent().parent().next().slideToggle('fast');
                        $(this).parent().parent().css('writing-mode', 'vertical-lr');
                        $(this).parent().parent().parent().css('width', '30px');
                        $(this).parent().parent().addClass('Colapsed');
                        $(this).parent().parent().css('min-height','100%');

                    }
               
                });
            });
           
            $('#DashboardKanban-FullscreenIcon').on('click', function(){
                if (
                    document.fullscreenElement ||
                    document.webkitFullscreenElement ||
                    document.mozFullScreenElement ||
                    document.msFullscreenElement
                ) {
                  
                    $('.MainBox').css('padding', '4px 16px 8px 3px;');
                    $('.MainBox').css('width', '97.8%');
               
                    $('.kanban-drag').css('max-height', '461px');

                    if (document.exitFullscreen) {
                        document.exitFullscreen();
                    } else if (document.mozCancelFullScreen) {
                        document.mozCancelFullScreen();
                    } else if (document.webkitExitFullscreen) {
                        document.webkitExitFullscreen();
                    } else if (document.msExitFullscreen) {
                        document.msExitFullscreen();
                    }
                } else {
                   
                    $('.kanban-drag').css('max-height', '608px');

                    var element = $('.MainBox').get(0);
                    $('.MainBox').css('padding-left', '1%');
                    $('.MainBox').css('width', '98%');
                    $('.MainBox').css('height', '96%');

                    if (element.requestFullscreen) {
                        element.requestFullscreen();
                    } else if (element.mozRequestFullScreen) {
                        element.mozRequestFullScreen();
                    } else if (element.webkitRequestFullscreen) {
                        element.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
                    } else if (element.msRequestFullscreen) {
                        element.msRequestFullscreen();
                    }
                }
            });

        };
     
        TargetNS.TicketLock = function (TicketID) { 
          
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketLock",
                "TicketID": TicketID ,                
             };
          
 
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    if(Response.Success == 1){
                        document.location.reload(true);
                    }
                }
            });

        };
      
        TargetNS.TicketUnLock = function (TicketID) { 
          
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketUnlock",
                "TicketID": TicketID ,                
             };
          
 
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    if(Response.Success == 1){
                        document.location.reload(true);
                    }
                }
            });

        };

        var currentPageURL = (window.location.href).split("Action=AgentKanban") ;

        TargetNS.TicketClose = function (TicketID) { 
            var URL = Core.Config.Get('Baselink') + 'Action=AgentTicketClose;TicketID='+TicketID+';OpenBy=Kanban';
            Core.UI.Popup.OpenPopup(URL, "Action", "Default");
        };

        TargetNS.TicketFreeText = function (TicketID) { 
            var URL = Core.Config.Get('Baselink') + 'Action=AgentTicketFreeText;TicketID='+TicketID+';OpenBy=Kanban';
            Core.UI.Popup.OpenPopup(URL, "Action", "AgentKanban");
        };

        TargetNS.TicketPrioriyUp = function (TicketID) { 
          
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketPrioriyUp",
                "TicketID": TicketID ,                
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    if(Response.Success == 1){    
                        $("#Flag_"+TicketID).css('background-color',Response.PriorityColor);
                        document.location.reload(true);
                    }
                }
            });

        };

        TargetNS.TicketPrioriyDown = function (TicketID) { 
          
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketPrioriyDown",
                "TicketID": TicketID ,                
             };
          
 
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    if(Response.Success == 1){                     
                        $("#Flag_"+TicketID).css('background-color',Response.PriorityColor);
                        document.location.reload(true);
                    }
                }
            });

        };

        TargetNS.TicketDetails = function (TicketID) {           
            
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketDetails",
                "TicketID": TicketID ,                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                   
                    Core.UI.Dialog.ShowContentDialog(Response, Core.Language.Translate('Details'), '100px', 'Center', true);
                  
                }
            });

        };

        TargetNS.TicketNote = function (TicketID) { 
            var URL = Core.Config.Get('Baselink') + 'Action=AgentTicketNote;TicketID='+TicketID+';OpenBy=Kanban';
            Core.UI.Popup.OpenPopup(URL, "Action", "AgentKanban");
        };
       
        TargetNS.TicketSetQueue = function (TicketID) {           
         
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketSetQueue",
                "TicketID": TicketID ,                
                "BoardID": $('#BoardID').val(),                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                    Core.UI.Dialog.ShowContentDialog(Response, Core.Language.Translate('New Queue'), '100px', 'Center', true);
                  
                }
            });

        };
        
        TargetNS.TicketZoom = function (TicketID) {           
            window.open(Core.Config.Get('Baselink') + 'Action=AgentTicketZoom;TicketID='+TicketID, '_blank');
        };

        TargetNS.TicketChangeOwner = function (TicketID) {      
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketChangeOwnerAndResponsible",
                "TicketID": TicketID ,                
                "BoardID": $('#BoardID').val(),                
                "TypeUser": 'Owner',                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                    Core.UI.Dialog.ShowContentDialog(Response, Core.Language.Translate('Change Owner'), '100px', 'Center', true);
                  
                }
            });
        };

        TargetNS.TicketChangeResponsible = function (TicketID) {
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketChangeOwnerAndResponsible",
                "TicketID": TicketID ,                
                "BoardID": $('#BoardID').val(),                
                "TypeUser": 'Responsible',                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                    Core.UI.Dialog.ShowContentDialog(Response, Core.Language.Translate('Change Responsible'), '100px', 'Center', true);
                  
                }
            });

        };

        TargetNS.TicketShare = function(TicketID){
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketShare",
                "TicketID": TicketID ,                
                "BoardID": $('#BoardID').val(),                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                    Core.UI.Dialog.ShowContentDialog(Response, Core.Language.Translate('Share'), '100px', 'Center', true);
                  
                }
            });

        }

        TargetNS.TicketSplit = function(){
            var SplitType = $('#SplitSelection').val();
            var TicketID = $('#TicketID').val();
            var ArticleID = $('#ArticleID').val();

            if(SplitType == 'EmailTicket'){
                var URL = Core.Config.Get('Baselink') + 'Action=AgentTicketEmail;ArticleID='+ArticleID+';LinkTicketID='+TicketID+';TicketID='+TicketID+';OpenBy=Kanban';
                Core.UI.Popup.OpenPopup(URL, "Action", "AgentKanban");
            }
            else if (SplitType == 'PhoneTicket'){
                var URL = Core.Config.Get('Baselink') + 'Action=AgentTicketPhone;ArticleID='+ArticleID+';LinkTicketID='+TicketID+';TicketID='+TicketID+';OpenBy=Kanban';
                Core.UI.Popup.OpenPopup(URL, "Action", "AgentKanban");
            }
        }

        TargetNS.NewTicket = function(){
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"NewTicket",                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                    Core.UI.Popup.OpenPopup(Response, "Action", "AgentKanban");
                  
                }
            });

        }

        TargetNS.TicketReplyAll = function(TicketID){
            var URL = Core.Config.Get('Baselink') + 'Action=AgentTicketCompose&TicketID='+TicketID+'&ReplyAll=1&OpenBy=Kanban';
            Core.UI.Popup.OpenPopup(URL, "Action", "AgentKanban");
        }

        TargetNS.TicketKanbanSLA = function (TicketID) { 
            
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketSLA",
                "TicketID": TicketID ,                
            };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                   
                    Core.UI.Dialog.ShowContentDialog(Response, Core.Language.Translate('SLA'), '100px', 'Center', true);
                  
                }
            });
        
        };

        TargetNS.TicketSetTag = function (TicketID) {           
         
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketSetTag",
                "TicketID": TicketID ,                
                "BoardID": $('#BoardID').val(),                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                    Core.UI.Dialog.ShowContentDialog(Response, Core.Language.Translate('Add Tag'), '100px', 'Center', true);
                  
                }
            });

        };

        TargetNS.AddTicketTag = function (TagID, TicketID, BoardID) {
         
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"AddTicketTag",
                "TicketID": TicketID ,                
                "TagID": TagID,                
                "BoardID": BoardID,                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    location.reload();      
                }
            });
           
        };

        TargetNS.TicketWatchers = function (TicketID) {           
         
            var Data = {
                "Action":"KanbanAJAXHandler",
                "Subaction":"TicketWatchers",
                "TicketID": TicketID ,                
                "BoardID": $('#BoardID').val(),                
             };
   
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    var html = $.parseHTML( Response );
                    Core.UI.Dialog.ShowContentDialog(Response, Core.Language.Translate('New Watch'), '300px', 'Center', true);
                  
                }
            });

        };
        

        Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
    }(Core.Agent.Admin.MyKanbanBoard || {}));
}