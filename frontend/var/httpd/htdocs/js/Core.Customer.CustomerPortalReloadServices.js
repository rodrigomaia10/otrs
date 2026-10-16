// --
// var/http/htdocs/js/Core.Customer.CustomerPortalReloadServices.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// * jsantos@serviceup.com.br
// * dsilva@serviceup.com.br
// -- 
 
"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.Customer.CustomerPortalReloadServices = (function (TargetNS) {

    // Add service favorite
    $('.ContractInfo').on('click', function(e){

        var ContractID = $(this).attr('data-contract-id');
    });

    history.pushState( "nohb", null, "" );

    $(window).on( "popstate", function(event){

        history.pushState( "nohb", null, "" );

        let ServiceParent = $("#Backbtn").attr("data-parentService");

        if (!ServiceParent){
            ServiceParent = "";
        }

        // TargetNS.ReloadServiceBackButton(ServiceParent);

        return;
    });

    TargetNS.ReloadService = function (ServiceID, LastLevel) {         

        const config = Core.Config.Get('DynamicFieldsJS');

        if ( config?.ServiceView === 'TreeView' && LastLevel !== true ) {

            $('.ServiceCardList').hide();
            $('.CardSearchTreeView').show();

            BuildServices(ServiceID, true);            
        }
        else {

            var Data = {
                "Action":"Services",
                "Subaction":"ReloadServices",
                "ServiceID": ServiceID,
            };
    
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
    
    
                if (!Response) {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    if(Response.HTMLString !== ''){
    
                        $( ".ServiceTitle" ).remove();
                        $( ".removecontent" ).remove();
                        $( ".MainBox" ).append(Response.HTMLString);
    
                        var URLDataService = Response.ServicesLevel;
    
                        // document.getElementById("NavTitle").innerHTML = URLDataService;
                    }
                    else{
                        if(Response.ExternalLink !== ''){
                            //window.open(Response.ExternalLink, '_blank');
                            window.location.href = Response.ExternalLink;
                        }
                        else{
                            window.location.href = Response.NextView;
                        }
                    }
                
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
    
                }
            });
        }
    };

    TargetNS.ReloadContractService = function (ContractID, ServiceID ) {

        var Data = {
            "Action":"Services",
            "Subaction":"ReloadContractServices",
            "ContractID": ContractID,
            "ServiceID": ServiceID,
            "TypeRequest": "AJAX",
        };

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {

            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{

                if(Response.HTMLString !== ''){
                    $( ".ServiceTitle" ).remove();
                    $( ".removecontent" ).remove();
                    $( ".MainBox" ).append(Response.HTMLString);

                    var URLDataService = Response.ServicesLevel;
                    document.getElementById("NavTitle").innerHTML= URLDataService;
                }
                else{

                    if(Response.ExternalLink !== ''){
                        window.open(Response.ExternalLink, '_blank');
                    }
                    else{
                        window.location.href = Response.NextView;
                    }
                }

                $('.StarFavorite').on('click', function(e){

                    var ServiceIDToFavorite = $(this).attr('data-service-favorite');
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
                            $('#ServiceFavoriteList').append(Response.HTMLString);
                            $(".fa-star-"+Response.ContractID).css("color","#ffc107");
                            $(".fa-star-"+Response.ContractID).css("display","block");

                        }
                    });
        
                    e.stopPropagation();
                });

                $('.FAQOFService').on('click', function(e){

                    e.preventDefault();
                
                    window.location.href = 'customer.pl?Action=CustomerFAQExplorer';
                
                    e.stopPropagation();
                });
            }
        });
    };
            
    TargetNS.ReloadServiceBackButton = function (ServiceID) {

        var Data = {
            "Action":"Services",
            "Subaction":"ReloadServices",
            "ServiceID": ServiceID,
        };

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {

            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{

                if(Response.HTMLString !== ''){
                    
                    $(".removecontent").remove();
                    $("#ServicesRowList").removeClass('HiddenElement');
                    $(".MainBox").append(Response.HTMLString);

                    var URLDataService = Response.ServicesLevel;

                    // document.getElementById("NavTitle").innerHTML = Response.ServicesLevel;
                }
                else{
                    
                    window.location.href = '?Action=Services';
                }
            }

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
                            $('#ServiceFavoriteList').append(Response.HTMLString);
                            $(".fa-star-"+Response.ServiceID).css("color","#ffc107");
                            $(".fa-star-"+Response.ServiceID).css("display","block");
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
        });

    };

    TargetNS.ReloadContractServiceBackButton = function (ContractID) {

        var Data = {
            "Action":"Services",
            "Subaction":"ReloadContractServices",
            "ContractID": ContractID,
        };

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {

            if (!Response) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else{

                if(Response.HTMLString !== ''){

                    $( ".removecontent" ).remove();
                    $("#ServicesRowList").removeClass('HiddenElement');
                    $( ".MainBox" ).append(Response.HTMLString);

                    document.getElementById("NavTitle").innerHTML= Response.ServicesLevel;
                }
                else{
                    window.location.href = '?Action=Services';
                }
            }

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
                            $('#ServiceFavoriteList').append(Response.HTMLString);
                            $(".fa-star-"+Response.ServiceID).css("color","#ffc107");
                            $(".fa-star-"+Response.ServiceID).css("display","block");
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

        });
    };

    function GetURLParameter(sParam) {

        var sPageURL = window.location.search.substring(1);
        var sURLVariables = sPageURL.split(';');
    
        for (var i = 0; i < sURLVariables.length; i++) {
            var sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] == sParam){
                return sParameterName[1];
            }
        }
    }

    TargetNS.Init = function() {

        const config = Core.Config.Get('DynamicFieldsJS');

        // service tree view
        if ( config?.ServiceView === 'TreeView' && config?.FisrtLevelCard === 'TreeView' ) {

            $('.ServiceCardList').hide();
            $('.CardSearchTreeView').show();
        }

        if ( config?.ServiceView === 'TreeView' && GetURLParameter('ServiceID')) {
            TargetNS.ReloadService(GetURLParameter('ServiceID'), false);
        }

        $('.ServiceParentClick').on('click', function(e) {
            event.preventDefault();
            if ( $(this).attr('data-last-level') === 'true' ) {
                TargetNS.ReloadService($(this).attr('data-service-id'), true);
            }                 
            else {
                BuildServices($(this).attr('data-service-id'));
            }          
        });

        var $Element             = $('#FullSearchService'),
        $AutocompleteElement = $('#FullSearchService');
    
        Core.UI.Autocomplete.Init(
            $AutocompleteElement,
            function (Request, Response) {
                var URL  = Core.Config.Get('Baselink'),
                    Data = {
                        Action:       'Services',
                        Subaction:    'SearchAutocompleteService',
                        Module:       'Services',
                        SearchTerms:  Request.term,
                        ServiceLevel: 0,
                        // TicketID:         TicketID
                    };                            

                $('#AJAXLoader' + $AutocompleteElement.attr('id')).show();

                $Element.data(
                    'AutoCompleteXHR',
                    Core.AJAX.FunctionCall(
                        URL,
                        Data,
                        function (Result) {    
                            
                            $('#ListServices').html('');

                            $Element.removeData('AutoCompleteXHR');

                            let HTML = '';

                            $.each(Result, function () {
                                if( this.LastLevel === true ) {
                                    HTML += '<div class="ServiceCard ServiceLevel card-header" role="tab" id="Service'+ this.Value+ '">' +
                                        '<a class="ServiceParentClick" data-service-id="'+ this.Value+ '" data-last-level="'+ this.LastLevel+ '" data-toggle="collapse" href="#ServiceCollapse_'+ this.Value+ '" aria-expanded="false" aria-controls="ServiceCollapse_'+ this.Value+ '">' +
                                            '<div class="ServiceName">' + 
                                                '<div class="ServiceLabel">'+ this.Label+ '</div>' +
                                                '</div>' +
                                                '</a>'+
                                                '<div class="ServiceComment">'+ this.Comment+ '</div>' +
                                                '<i id="ServiceIcon'+ this.Value+ '" class="ServiceIcon fa fa-angle-right"></i>' +
                                            '<div class="collapse ServiceNameLevel" id="ServiceCollapse_'+ this.Value+ '"></div>' +
                                        '</div>';
                                }
                                else {
                                    HTML += '<div class="ServiceCard card-header" role="tab" id="Service'+ this.Value+ '">' +
                                        '<div class="ServiceName">' + 
                                            '<div class="ServiceLabel">'+ this.Label+ '</div>' +
                                            '</div>' +
                                            '<div class="collapse ServiceNameLevel" id="ServiceCollapse_'+ this.Value+ '"></div>' +
                                            '<div class="ServiceComment">'+ this.Comment+ '</div>' +
                                            '<i id="ServiceIcon'+ this.Value+ '" class="ServiceIcon fa fa-angle-right"></i>' +
                                    '</div>';
                                }
                            });
                            
                            $('#ListServices').html(HTML);
                            
                            $('.ServiceParentClick').on('click', function(e) {
                                event.preventDefault();

                                if ( $(this).attr('data-last-level') === 'true' ) {
                                    TargetNS.ReloadService($(this).attr('data-service-id'), true);
                                }                 
                                else {

                                    BuildServices($(this).attr('data-service-id'));
                                }          
                            });

                            $('#AJAXLoader' + $AutocompleteElement.attr('id')).hide();                                                 
                        }
                    )
                );
            },
            function (Event, UI) {
                var Label = UI.item.label,
                    Value = UI.item.value,
                    InitAutoFill;
                
                if (typeof Label == "string") {
                    Label.trim();
                }
                if (typeof Value == "string") {
                    Value.trim();
                }

                Event.preventDefault();
                Event.stopPropagation();
        
                // Fixed bug where ajax loading icon does not get removed
                // after loading of the elements
                $AutocompleteElement.data('request-counter', 0);
                $('#AJAXLoader' + $AutocompleteElement.attr('id')).hide();               
                

                if ( ( !IdentifierKey) || !DynamicFieldTableWebservice.findDuplicity( DynamicFieldName, IdentifierKey, Value ) ) {

                    $AutocompleteElement.val(Label);
                    $AutocompleteElement.attr('data-selected-autocomplete-display-value', Label);
                    $Element.val(Value);

                    // prepare AutoFill
                    if (AdditionalTable && AdditionalTable.length){
                        $.each(AdditionalTable, function(Index, DynamicField) {
                            var Exists = Znuny.Form.Input.Exists('DynamicField_' + DynamicField);

                            if (Exists){
                                InitAutoFill = 1;
                                return false;
                            }
                        });
                        if (InitAutoFill){
                            TargetNS.InitAutoFill(DynamicFieldName,Value);
                        }
                    }                

                    DynamicFieldTableWebservice.insertTable( DynamicFieldName,AdditionalTableConfig, JSON.parse(Value) );

                    Core.App.Publish('Event.Agent.DynamicField.Webservice.Callback',
                        [
                            {
                                Label: Label,
                                Value: Value,
                                Field: DynamicFieldName
                            }
                        ]
                    );
                }
                
            },
            'DynamicFieldWebservice',
            {
                QueryDelay:          0,
                MinQueryLength:      3,
                MaxResultsDisplayed: 100
            }
        );        
    };    

    function BuildServices(ServiceParentID, teste) {

        var URL  = Core.Config.Get('Baselink'),
        Data = {
            Action:       'Services',
            Subaction:    'SearchParentService',
            Module:       'Services',
            ServiceParentID: ServiceParentID
        };
        Core.AJAX.FunctionCall(URL, Data, function (Result) {
            
            let HTML = '';
          
            $.each(Result, function () {
                var arr = this.Label.split("::");
                var isParent = 0;
                if(arr.length == 2){
                    isParent = 1;
                }

                if( this.LastLevel === true ) {
                    let comment = $(this).data('Comment');
                    
                    if(isParent){
                        HTML += '<div class="ServiceCard ServiceLevel card-header" role="tab" id="Service' + this.Value + '">' +
                            '<a class="ServiceParentClick" data-service-id="' + this.Value + '" data-last-level="' + this.LastLevel + '" href="#ServiceCollapse_' + this.Value + '">' +
                                '<div class="ServiceName">' + 
                                    '<div style="font-weight: bold" class="ServiceLabel">' + this.Label + '</div>' +
                                    '</div>' +
                                    '</a>'+
                                    '<i id="ServiceIcon' + this.Value + '" class="ServiceIcon fa fa-angle-right"></i>' +
                            '<div class="collapse ServiceNameLevel" id="ServiceCollapse_' + this.Value + '"></div>' +
                            (this.Comment ? '<div class="ServiceComment">' + this.Comment + '</div>' : '') +
                        '</div>';
                    }
                    else{
                        HTML += '<div class="ServiceCard ServiceLevel card-header" role="tab" id="Service' + this.Value + '">' +
                            '<a class="ServiceParentClick" data-service-id="' + this.Value + '" data-last-level="' + this.LastLevel + '" href="#ServiceCollapse_' + this.Value + '">' +
                                '<div class="ServiceName">' + 
                                    '<div class="ServiceLabel">' + this.Label + '</div>' +
                                    '</div>' +
                                    '</a>'+
                                    '<i id="ServiceIcon' + this.Value + '" class="ServiceIcon fa fa-angle-right"></i>' +
                            '<div class="collapse ServiceNameLevel" id="ServiceCollapse_' + this.Value + '"></div>' +
                            (this.Comment ? '<div class="ServiceComment">' + this.Comment + '</div>' : '') +
                        '</div>';
                    }
                }
                else {
                 
                    if(isParent){

                        HTML += '<div class="ServiceCard ServiceLevel card-header" role="tab" id="Service' + this.Value + '">' +
                        '<a class="ServiceParentClick" data-service-id="' + this.Value + '" data-last-level="' + this.LastLevel + '" data-toggle="collapse" href="#ServiceCollapse_' + this.Value + '" aria-expanded="false" aria-controls="ServiceCollapse_' + this.Value + '">' +
                            '<div class="ServiceName">' + 
                                '<div style="font-weight: bold" class="ServiceLabel">' + this.Label + '</div>' +
                                '</div>' +
                                '</a>'+
                                '<i id="ServiceIcon' + this.Value + '" class="ServiceIcon fa fa-angle-right"></i>' +
                            '<div class="collapse ServiceNameLevel" id="ServiceCollapse_' + this.Value + '"></div>' +
                        '</div>';
                    }
                    else {

                        HTML += '<div class="ServiceCard ServiceLevel card-header" role="tab" id="Service' + this.Value + '">' +
                        '<a class="ServiceParentClick" data-service-id="' + this.Value + '" data-last-level="' + this.LastLevel + '" data-toggle="collapse" href="#ServiceCollapse_' + this.Value + '" aria-expanded="false" aria-controls="ServiceCollapse_' + this.Value + '">' +
                            '<div class="ServiceName">' + 
                                '<div class="ServiceLabel">' + this.Label + '</div>' +
                                '</div>' +
                                '</a>'+
                                '<i id="ServiceIcon' + this.Value + '" class="ServiceIcon fa fa-angle-right"></i>' +
                            '<div class="collapse ServiceNameLevel" id="ServiceCollapse_' + this.Value + '"></div>' +
                        '</div>';
                    }
                }
            });

            // To not show acl fields
            if(Result.length === 0 ){
                TargetNS.ReloadService(ServiceParentID, true);
            }

            if ( teste == true ) {
                $('#ListServices').html(HTML);
                    $(".ServiceParentClick").each(function(index){
                        $(this).on('click', function(){
                            var el = $("#ServiceIcon"+$(this).data().serviceId);

                            if(el.css("transform") != "matrix(0, 1, -1, 0, 0, 0)"){
                                el.css("transform", "rotate(90deg)");
                                el.css("animation", "Rotate 0.15s linear");
                            }else{
                                el.css("transform", "rotate(0deg)");
                                el.css("animation", "unRotate 0.15s linear");
                            }
                        })
                    })
            }
            else {
                $(`#ServiceCollapse_${ServiceParentID}`).html(HTML);
            }

            $('.ServiceParentClick').on('click', function(e) {
                event.preventDefault();

                if ( $(this).attr('data-last-level') === 'true' ) {
                    TargetNS.ReloadService($(this).attr('data-service-id'), true);
                }                 
                else {
                    BuildServices($(this).attr('data-service-id'));
                }          
            });
        });
    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;

}(Core.Customer.CustomerPortalReloadServices || {}));