// --
// var/httpd/htdocs/js/Core.Customer.CustomerPortal.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

/**
* @namespace Core.Customer.CustomerPortal
* @memberof Core.Customer
* @author OTRS AG
* @description
*      This namespace contains the special function for search bar of CustomerPortal module.
*/
Core.Customer.CustomerPortal = (function (TargetNS) {

    // Search on my Tickets
    function searchOnTable() {

        var $rows = $('#datatable tbody tr');

        $('#searchTable').keyup(function() {

            var val = $.trim($(this).val()).replace(/ +/g, ' ').toLowerCase();

            $rows.show().filter(function() {

                var text = $(this).text().replace(/\s+/g, ' ').toLowerCase();

                return !~text.indexOf(val);
                
            }).hide();
        });
    }

    // responsive minimizeSidebar
    $('#minimizeSidebar').on('click', function(){

        element = $("body");

        //Maximize
        if(element.hasClass('sidebar-mini') == true){

            $('body').removeClass("sidebar-mini");
            // $('.ContentResponsive').css('margin-left','20%');
            // $('.ContentResponsive').css('width','78%');
            // $('.logo-mini').css('display','none');

            // To company name
            $('#CompanyNameDiv').removeClass("Hidden");

            $(".CardNews" ).attr('style', 'margin-left: -22px !important;');
        //Minimize
        }
        else{

            $('body').removeClass("sidebar-regular");
            $('body').addClass("sidebar-mini");
            // $('.ContentResponsive').css('margin-left','7%');
            // $('.ContentResponsive').css('width','90%');
            // $('.logo-mini').css('display','');

            // To stats view
            // $(".card-charts" ).attr('style', 'width: 49% !important;');
            $(".CardNews" ).attr('style', 'margin-left: -118px !important;');

            // To company name
            $('#CompanyNameDiv').addClass("Hidden");
        }
    });

    $('#ResponsiveButton').on('click', function(){

        element = $("body");

        $('body').removeClass("sidebar-regular");
        $('body').addClass("sidebar-mini");
        // $('.ContentResponsive').css('margin-left','7%');
        // $('.ContentResponsive').css('width','90%');
        $('.sidebar').css('transform','none');
        $('#ResponsiveButtonNav').css('display','inline-block');

        // $('.logo-mini').css('display','none');
        $('.logo-image-small').css('display','none');
    });

    $('#ResponsiveButtonNav').on('click', function(){
        $('.sidebar').css('transform','translate3d(-260px, 0, 0)');
        $('#ResponsiveButtonNav').css('display','none');
    });

    //show all tickets
    $('.all-tickets').on('click', function(){

        $('.searched-priority').each(function(){
            $(this).removeAttr('style');
        });

        $('.selected-priority').each(function(){
            $(this).removeClass('selected-priority');
        });
    });

    //filter table all tickets
    function filterTableAllTickets(element){

        var table = $('#TicketTable').DataTable();

        table.columns().every( function () {

            var that = this;

            $('#TicketTable').dataTable().fnFilter("^", 1, true, false);
        } );
    }

    //filter table tickets by priority
    function filterTableByPriority(element){

        if(hasClass(element, 'selected-priority') == false){

            var flag = 0;

            $('.selected-priority').each(function(){
                $(this).removeClass('selected-priority');
            });

            element.children[0].classList.add("selected-priority");

            var selectedPriority = element.getAttribute('data-selected-priority');

            var table = $('#TicketTable').DataTable();

            table.columns().every( function () {

                var that = this;

                $('#TicketTable').dataTable().fnFilter('^'+selectedPriority+"$", 1, true, false);
            });
        }
        else{

            var flag = 0;

            $('.selected-priority').each(function(){
                flag++;
            });

            element.classList.remove("selected-priority");

            $('.searched-priority').each(function(){
                $(this).removeAttr("style");
            });
        }
    }

    // Add service favorite
    $('.StarFavorite').on('click', function(e){
        
        e.preventDefault();

        var ServiceIDToFavorite = $(this).attr('data-service-favorite');

        if ($(this).hasClass("FavoriteAdded")) {

            var Data = {
                "Action":"Services",
                "Subaction":"RemoveFavoriteService",
                "ServiceIDToRemove": ServiceIDToFavorite,
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {

                if (!Response) {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    $( ".ServiceFav-"+Response ).remove();
                    $(".fa-star-"+Response).css("display","none");
                    $(".StarFavorite").removeClass("FavoriteAdded");
                }
            });

        }
        else{
            var Data = {
                "Action":"Services",
                "Subaction":"AddSFavoriteService",
                "ServiceIDToFavorite": ServiceIDToFavorite,
            };

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {

                if (!Response) {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{

                    if( Response.ModalHTMLString ){
                        $('.ServicesRowListReload').append(Response.ModalHTMLString);

                        $('#ModalCloseServiceFavorite').on('click', function() {
                            $( "#ModalLimitServiceFavorite" ).remove();             
                        });
                        
                         // click outside the modal and close it
                        const root = document.getElementById("content functions-content");
                        root.addEventListener("click", (event) => {
                            if ( ! event.target.matches("#ModalLimitServiceFavorite")
                            ){
                                
                                $( "#ModalLimitServiceFavorite" ).remove();                       
                            }
                        });

                    }else{
                        $('#ServiceFavoriteList').append(Response.HTMLString);
                        $(".fa-star-"+Response.ServiceID).css("color","#ffc107");
                        $(".fa-star-"+Response.ServiceID).css("display","block");
                    }                    
                }
            });
        }

        $(this).addClass("FavoriteAdded");

        e.stopPropagation();

    });

    $('.FAQOFService').on('click', function(e){

        e.preventDefault();

        window.location.href = 'customer.pl?Action=CustomerFAQExplorer';

        e.stopPropagation();
    });

    // Add service favorite
    $('.RemoveFavorite').on('click', function(e){

        var ServiceIDToRemove = $(this).attr('data-service-favorite-remove');

        var Data = {
            "Action":"Services",
            "Subaction":"RemoveFavoriteService",
            "ServiceIDToRemove": ServiceIDToRemove,
        };

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {

            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{
                $( ".ServiceFav-"+Response ).remove();
                $(".fa-star-"+Response).css("display","none");
                $(".StarFavorite").removeClass("FavoriteAdded");
            }
        });
    });

    $('.FavoriteClick').on('click', function(){
      
        var NewLink = $(this).attr('data-serviceNewTicketLink');
        var NavBarName = $(this).attr('data-service-name');

        window.location.href = NewLink;
    });

    //This function check if element has determinated class
    function hasClass(element, cls) {
        return (' ' + element.className + ' ').indexOf(' ' + cls + ' ') > -1;
    }

    // To datable of fullsearch
    $(document).ready(function() {

        $('#FullSearchTable').DataTable({
            language: {
                "sEmptyTable": Core.Language.Translate("No record found"),
                "sInfo": Core.Language.Translate("Mostrando de") +" _START_ "+Core.Language.Translate('up until') +" _END_ "+ Core.Language.Translate('in') +" _TOTAL_ "+Core.Language.Translate('records'),
                "sInfoEmpty": Core.Language.Translate("Showing 0 to 0 of 0 records"),
                "sInfoFiltered": "("+ Core.Language.Translate("Filtered from")+" _MAX_ "+Core.Language.Translate("records")+")",
                "sInfoPostFix": "",
                "sInfoThousands": ".",
                "sLengthMenu": Core.Language.Translate("Mostrando") + " _MENU_ " + Core.Language.Translate("records"),
                "sLoadingRecords": Core.Language.Translate("Loading..."),
                "sProcessing": Core.Language.Translate("Processing..."),
                "sZeroRecords":  Core.Language.Translate("No record found"),
                "searchPlaceholder": Core.Language.Translate("Search records"),
                "sSearch": "",
                "oPaginate": {
                        "sNext": Core.Language.Translate("Next"),
                        "sPrevious": Core.Language.Translate("Previous"),
                        "sFirst": Core.Language.Translate("First"),
                        "sLast": Core.Language.Translate("Last")
                },
                "oAria": {
                    "sSortAscending": ": Ordenar colunas de forma ascendente",
                    "sSortDescending": ": Ordenar colunas de forma descendente"
                },   
            },
            "order": [[ 1, "asc" ]],
            "pageLength": 25,
            "columnDefs": [
                { "width": "20%", "targets": 0 },
                { "width": "20%", "targets": 1 },
              ]
        });
        // Animation card
        $(".cardTransition").on({
            mouseenter: function () {
                $(this).find('.face1').css("background",$(this).attr("data-hover"));
            },
            mouseleave: function () {
                $(this).find('.face1').css("background",$(this).attr("data-default")); 
            }
        });
    } );

    //This function returns a strigs with no spelling accents
    var map={"â":"a","Â":"A","à":"a","À":"A","á":"a","Á":"A","ã":"a","Ã":"A","ê":"e","Ê":"E","è":"e","È":"E","é":"e","É":"E","î":"i","Î":"I","ì":"i","Ì":"I","í":"i","Í":"I","õ":"o","Õ":"O","ô":"o","Ô":"O","ò":"o","Ò":"O","ó":"o","Ó":"O","ü":"u","Ü":"U","û":"u","Û":"U","ú":"u","Ú":"U","ù":"u","Ù":"U","ç":"c","Ç":"C"};

    function removeAccents(s){ return s.replace(/[\W\[\] ]/g,function(a){return map[a]||a}) };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CustomerPortal || {}));