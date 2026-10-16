// --
// var/httpd/htdocs/js/Core.Customer.CustomerPortalSearch.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

/**
* @namespace Core.Customer.CustomerPortalSearch
* @memberof Core.Customer
* @author OTRS AG
* @description
*      This namespace contains the special function for search bar of CustomerPortal module.
*/
Core.Customer.CustomerPortalSearch = (function (TargetNS) {

    $("#SearchAll").removeClass('Hidden');
    
    $('#input-search-service-all, #input-search-service-all-home').keypress(function(e) {
        //when user press 'Enter'
        if ( e.which == 13 ) {
            
            if ( ( e.target.id == "input-search-service-all" ) || ( e.target.id == "input-search-service-all-home" ) ) {

                var currentURL = window.location.href ;
                var currentURLSplit = currentURL.split("?");
                var dataES = $("#input-search-service-all").val();

                if( e.target.id == "input-search-service-all-home" ){
                    dataES = $("#input-search-service-all-home").val();
                }

                var CurrentValue;

                if ( currentURLSplit.length > 1 ) {
                    var currentAction  = currentURLSplit[1].split("Action=");
                    var currentOpenBy  = currentURLSplit[1].split("OpenBy=");

                    CurrentValue = currentAction[1];
    
                    if ( currentOpenBy[1] != undefined ) {
                        CurrentValue = currentOpenBy[1];
                    }
                }
                
                window.location.href = currentURLSplit[0]+"?Action=CustomerPortalSearch;SearchValue="+dataES+";OpenBy="+CurrentValue;
            }             
        }
    });

    $('html').click(function (event) {
        if( ( event.target.id !='service-list-all') || ( event.target.id !='service-list-all-home') ){
            $('#service-list-all li').remove();
            $('#input-search-service-all, #input-search-service-all-home').removeClass('InputServiceWithSearch');
        }

        if( ( event.target.id !='input-search-service-all')){
            $("#SearchAll").removeClass("SearchAllClick");
            $("#SearchAll").addClass("SearchAllClickAfter");
            $("#input-search-service-all").removeClass('Input-search-service-click-all');
            $("#input-search-service-all").val('');
            $("#icon-Search-all").removeClass('Icon-Search-click-all');

        }

        if( ( event.target.id !='input-search-service-all-home')){
            $("#SearchAll").removeClass("SearchAllClick");
            $("#SearchAll").addClass("SearchAllClickAfter");
            $("#input-search-service-all-home").removeClass('Input-search-service-click-all');
            $("#input-search-service-all-home").val('');
            $("#icon-Search-all").removeClass('Icon-Search-click-all');

        }
    });

    $("#input-search-service-all").on("click", function(){
        $("#SearchAll").addClass("SearchAllClick");
        $("#input-search-service-all").addClass('Input-search-service-click-all');
        $("#icon-Search-all").addClass('Icon-Search-click-all');
    });

    $('#input-search-service-all, #input-search-service-all-home').on("keyup", function(){
        $('#service-list-all li').remove();

        if ($(this).val() == ''){
            $('#input-search-service-all, #input-search-service-all-home').removeClass('InputServiceWithSearch');
        }
    });

    TargetNS.RedirectToOpenTicket = function (ItemID, type) {
        var currentURL = window.location.href ;
        var currentURL = currentURL.split("?");
        if(type == 'faq'){
            window.location.href = currentURL[0]+"?Action=CustomerFAQZoom;ItemID="+ItemID;
        }else if (type == 'service') {
            window.location.href = currentURL[0]+"?Action=NewTicketService;ServiceID="+ItemID;
        }
    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CustomerPortalSearch || {}));