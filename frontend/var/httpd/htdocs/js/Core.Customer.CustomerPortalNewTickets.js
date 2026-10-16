// --
// var/httpd/htdocs/js/Core.Customer.CustomerPortalNewTickets.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// * jguedes@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

/**
* @namespace Core.Customer.CustomerPortalNewTickets
* @memberof Core.Customer
* @author OTRS AG
* @description
*      This namespace contains the special function for ServiceTemplate module.
*/
Core.Customer.CustomerPortalNewTickets = (function (TargetNS) {

    $('#input-search-service').keypress(function(e) {
        //when user press 'Enter'
        if ( e.which == 13 ) {
            var currentURL = window.location.href ;
            var currentURLSplit = currentURL.split("?");
            var dataES = $("#input-search-service").val();

            var currentAction = currentURLSplit[1].split("Action=");

            window.location.href = currentURLSplit[0]+"?Action=CustomerPortalSearch;SearchValue="+dataES+";OpenBy="+currentAction[1];   
        }
    });

    $('html').click(function (event) {
        if(event.target.id !='service-list'){
            $('#service-list li').remove();
            $('#input-search-service').removeClass('InputServiceWithSearch');
        }

        if(event.target.id !='input-search-service'){
            $("#input-search-service").removeClass('Input-search-service-click');
            $("#input-search-service").val('');
            $("#icon-Search").removeClass('Icon-Search-click');
            $("#Overlay").addClass('Hidden');
        }
    });

    // $("#input-search-service").on("click", function(){
    //     $("#Overlay").removeClass('Hidden');
    //     $("#input-search-service").addClass('Input-search-service-click');
    //     $("#icon-Search").addClass('Icon-Search-click');
    // });

    $("#input-search-service").on("keyup", function(){
        $('#service-list li').remove();

        if ($(this).val() == ''){
            $('#input-search-service').removeClass('InputServiceWithSearch');
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

    /**
     * @name FormUpdate
     * @memberof Core.AJAX
     * @function
     * @description
     *   To treat as dynamic field regex
     */
    TargetNS.RegToField = function (ArrayOfRegex, DynamicField, RegexMessage) {
        var FieldValue = $('#'+DynamicField).val();
        var bool = false;
        var ErrorMessage;

        $("#RegexMessageError_"+DynamicField).css("display", "none");
        if(ArrayOfRegex.length > 0) {

            for(var key in ArrayOfRegex) {

                let RegexObject = ArrayOfRegex[key];

                let Regex = new RegExp(RegexObject.Value);

                if (Regex.test(FieldValue)){

                    bool = true;
                }
                else{
                    bool = false;
                    ErrorMessage = RegexObject.ErrorMessage;
                    break
                }
            }

            if (bool){
                $('#'+DynamicField).removeClass("Error");
                $('#'+DynamicField).removeClass("Validate_Required");
                $("#Label"+DynamicField).removeClass("LabelError");
                $("#"+DynamicField+"ErrorServerError").css("display", "none");
                $("#"+DynamicField+"Error").css("display", "none");
                $("#RegexMessageError_"+DynamicField).css("display", "none");

            }
            else{
                $('#'+DynamicField).addClass("Error");
                $('#'+DynamicField).val("");
                $("#Label"+DynamicField).addClass("LabelError");
                $("#Label"+DynamicField).addClass("Validate_Required");
                $("#"+DynamicField).addClass("Validate_Required");
                $("#"+DynamicField).after("<div id='RegexMessageError_"+DynamicField+"'><p>"+ErrorMessage+"</p></div>");

            }
        }
    };

    $(document).ready( function(){
        enableText = $('#TextConfig').data('enabled');
        if(!enableText){
            $("head").append('<style type="text/css"></style>');
            var newStyleElement = $("head").children(':last');
            newStyleElement.html('#cke_1_top{display: none !important;}');
        }
    })

  Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

  return TargetNS;
}(Core.Customer.CustomerPortalNewTickets || {}));