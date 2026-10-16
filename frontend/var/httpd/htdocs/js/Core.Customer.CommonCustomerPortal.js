// --
// var/http/htdocs/js/Core.Customer.CommonCustomerPortal.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.Customer.CommonCustomerPortal = (function (TargetNS) {

    TargetNS.Init = function(){

        // DarkReader.enable({
        //     brightness: 100,
        //     contrast: 90,
        //     sepia: 10
        // });


        $('.navbar-toggler').on('click', function(){

            if ( $('#navigation').hasClass('show') ) {
                $("#NavbarTop").addClass("navbar-transparent").removeClass("bg-white");
            }
            else {
                $("#NavbarTop").removeClass("navbar-transparent").addClass("bg-white");
            }
        });

        $("#minimizeSidebar").click( function() {
            
            setCookie('SidebarMini', $('body').hasClass( 'sidebar-mini' ), 10);
        });
        
        $("#PreviousScreen").click( function() {

            var Action = $("input[name='Action'").val();

            if (Action == 'NewTicketService') {
                window.location = document.getElementById('LastService').href;
            }
            else {
                history.back();
            }
            
            
        });

        Core.InBoxLibrary.ConfigGet("CustomerPortal::Core::BackgroundImageDefault", function (Result) {

            if( Result.Data ){
                // $('.BackgroundPortal').css('background-image', "url("+Result.Data+")");
            }           
        });
    };

    $("#minimizeSidebar").click( function() {
            
        setCookie('SidebarMini', $('body').hasClass( 'sidebar-mini' ), 10);
    });

    function setCookie(key, value, expiry) {

        var expires = new Date();

        expires.setTime(expires.getTime() + (expiry * 24 * 60 * 60 * 1000));

        document.cookie = key + '=' + value + ';expires=' + expires.toUTCString();
    }
    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CommonCustomerPortal || {}));