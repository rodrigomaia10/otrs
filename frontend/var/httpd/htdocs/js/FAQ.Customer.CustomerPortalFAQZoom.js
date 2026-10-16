// --
// var/httpd/htdocs/js/FAQ.Customer.CustomerPortalFAQZoom.js
// Copyright (C) 2019 Service Up, http://serviceup.com.br/
// 
// written/edited by:
// * gtiburtino@beonup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var FAQ = FAQ || {};
FAQ.Customer = FAQ.Customer || {};
FAQ.Customer.CustomerPortalFAQZoom = FAQ.Customer.CustomerPortalFAQZoom || {};
FAQ.Customer.CustomerPortalFAQZoom = (function (TargetNS) {

     TargetNS.IframeAutoHeight = function ($Iframe) {

        var NewHeight;

        if (isJQueryObject($Iframe)) {

            // slightly change the width of the iframe to not be exactly 100% width anymore
            // this prevents a double horizontal scrollbar (from iframe and surrounding div)
            // $Iframe.width(673);
            // $Iframe.width($Iframe.width() - 2);

            NewHeight = $Iframe.contents().find('body').height();

           
            // if the iFrames height is 0, we collapse the widget
            if (NewHeight === 0) {
                $Iframe.closest('.WidgetSimple').removeClass('Expanded').addClass('Collapsed');

            } else if (!NewHeight || isNaN(NewHeight)) {
                NewHeight = Core.Config.Get('FAQ::Frontend::AgentHTMLFieldHeightDefault');

            }
            else {
                if (NewHeight > Core.Config.Get('FAQ::Frontend::AgentHTMLFieldHeightMax')) {
                    NewHeight = Core.Config.Get('FAQ::Frontend::AgentHTMLFieldHeightMax');
                }
            }

            // add delta for scrollbar
            if (NewHeight > 0) {
                NewHeight = parseInt(NewHeight, 10) + 25;

            }
            
            $Iframe.height(NewHeight + 'px');
        }
    };

    function ToggleMessage($Message){
        if ($Message.hasClass('Visible')) {
            $Message.removeClass('Visible');
        }
        else {
            $Message.addClass('Visible');
        }
    }

    TargetNS.Init = function(){

        $(window).scroll(function(e){

            var $Cards = $('.col-md-4');
    
            var isPositionFixed = ($Cards.css('position') == 'fixed');
    
            if ($(this).scrollTop() > 200 && !isPositionFixed){
    
                if ($(window).width() > 1500) {
                    $Cards.css({'position': 'fixed', 'top': '0px', "max-width": "33.333333%", "margin-left": "64%"});
                }
                else{
                    $Cards.css({'position': 'fixed', 'top': '0px', "max-width": "33.333333%", "margin-left": "64%"}); 
                }
            }
    
            if ($(this).scrollTop() < 200 && isPositionFixed){
                $Cards.css({'position': 'static', 'top': '0px', "max-width": "33.333333%", "margin-left": "0%"}); 
            } 
        });


        var $Messages = $('#Messages > li'),
            $MessageHeaders = $('.MessageHeader', $Messages);

        $MessageHeaders.click(function(Event){
            ToggleMessage($(this).parent());
            Event.preventDefault();
        });

        // init browser link message close button
        if ($('.FAQMessageBrowser').length) {
            $('.FAQMessageBrowser a.Close').on('click', function () {
                var Data = {
                    Action: 'CustomerFAQZoom',
                    Subaction: 'BrowserLinkMessage'
                };

                $('.FAQMessageBrowser').fadeOut("slow");

                // call server, to save that the button was closed and do not show it again on reload
                Core.AJAX.FunctionCall(
                    Core.Config.Get('CGIHandle'),
                    Data,
                    function () {}
                );

                return false;
            });
        }

        $('a.AsPopup').on('click', function () {
            Core.UI.Popup.OpenPopup($(this).attr('href'), 'TicketAction');
            return false;
        });

        $('.RateButton').on('click', function () {
            var RateNumber = parseInt($(this).closest('div').attr('id').replace(/RateButton/, ''), 10);
            $('#RateValue').val(RateNumber);
            $('#RateSubmitButton').fadeIn(250);
            $('#FAQVoting').find('.RateButton').each(function() {
                var ItemRateNumber = parseInt($(this).closest('div').attr('id').replace(/RateButton/, ''), 10);
                if (ItemRateNumber <= RateNumber) {
                    $(this).addClass('RateChecked');
                    $(this).removeClass('RateUnChecked');
                }
                else {
                    $(this).addClass('RateUnChecked');
                    $(this).removeClass('RateChecked');
                }
            });
        });

        // Make whole FAQ Item row clickable, but not the headers, can't use Core.Customer.ClickableRow()
        // since it uses "table tr" as selector, see bug#9329.
        $("tbody tr").click(function(){
            window.location.href = $("a", this).attr("href");
            return false;
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(FAQ.Customer.CustomerPortalFAQZoom || {}));
