// --
// Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (GPL). If you
// did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
// --
"use strict";

var Core = Core || {};
Core.UI = Core.UI || {};

/**
 * @namespace Core.UI.ActionRow
 * @memberof Core.UI
 * @author OTRS AG
 * @description
 *      Action row functionality.
 */
Core.UI.ActionRow = (function (TargetNS) {

    var TicketElementSelectors = 'table td input[type="checkbox"][name=TicketID]';

    TargetNS.Init = function () {

        $('#SelectAllTickets').on('click', function () {
            var Status = $(this).prop('checked');
            $(TicketElementSelectors + ':not(:disabled)').prop('checked', Status).triggerHandler('click');
        });
        
        // $(TicketElementSelectors).on('click', function (Event) {
        //     Event.stopPropagation();
        //     Core.Form.SelectAllCheckboxes($(this), $('#SelectAllTickets'));
        // });
        
        $('#BulkAction a').on('click', function () {

            if ($(TicketElementSelectors + ':checked').length === 0) {

                showPopup("⚠️ Nenhum chamado selecionado!", "warning");
                return false;
            }

            var $Element = $(this),
                $SelectedTickets,
                TicketIDParameter = "TicketID=",
                TicketIDsURL = "",
                TicketIDs = "",
                URL;

            if ($Element.parent('li').hasClass('Inactive')) {
                return false;
            }
            else {
                $SelectedTickets = $(TicketElementSelectors + ':checked');
                $SelectedTickets.each(function () {
                    TicketIDsURL += TicketIDParameter + $(this).val() + ";";
                    TicketIDs += $(this).val() + ";";
                });

                URL = Core.Config.Get('Baselink') + "Action=CustomerPortalTicketBulk;" + TicketIDsURL;
                URL += SerializeData(Core.App.GetSessionInformation());
        
                Core.UI.Popup.OpenPopup(URL, 'TicketAction');
        
            }
            return false;
        });
    };

    function showPopup(message, type) {
        
        $(".custom-popup").remove();
    
        var bgColor = "#28a745"; // verde por padrão
        if (type === "warning") bgColor = "#fff0c3"; // amarelo
        if (type === "error") bgColor = "#dc3545";   // vermelho
    
        var popup = $(
            '<div class="custom-popup">' + message + '</div>'
        ).css({
            position: "fixed",
            top: "-50px",
            left: "50%",
            transform: "translateX(-50%)",
            background: bgColor,
            color: "#000",
            padding: "10px 20px",
            borderRadius: "5px",
            boxShadow: "0px 4px 6px rgba(0,0,0,0.2)",
            zIndex: 9999,
            transition: "top 0.7s ease"
        });
    
        $("body").append(popup);
    
        setTimeout(function() {
            popup.css("top", "10%");
        }, 50);
    
        setTimeout(function() {
            popup.css("top", "-50px");
            setTimeout(function() {
                popup.remove();
            }, 500);
        }, 5000);
    }

    function SerializeData(Data) {
        var QueryString = '';
        $.each(Data, function (Key, Value) {
            QueryString += ';' + encodeURIComponent(Key) + '=' + encodeURIComponent(Value);
        });
        return QueryString;
    }


    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.UI.ActionRow || {}));


