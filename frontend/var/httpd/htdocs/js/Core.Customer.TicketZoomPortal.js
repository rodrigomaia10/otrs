// --
// var/http/htdocs/js/Core.Customer.TicketZoomPortal.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// * dsilva@serviceup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.Customer.TicketZoomPortal = (function (TargetNS) {

    $('a.AsPopup').on('click', function () {
        Core.UI.Popup.OpenPopup($(this).attr('href'), 'TicketAction');
        return false;
    });

    // responsive minimizeSidebar
    $('#minimizeSidebar').on('click', function(){
        var element = $("body");

        //Maximize
        if(element.hasClass('sidebar-mini') == true){
            $('body').removeClass("sidebar-mini");
            // $('.ContentResponsive').css('margin-left','20%');
            // $('.ContentResponsive').css('width','78%');
            $('.logo-mini').css('display','none');
        
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
            $('.logo-mini').css('display','');
        
            // To stats view
            // $(".card-charts" ).attr('style', 'width: 49% !important;');
            $(".CardNews" ).attr('style', 'margin-left: -118px !important;');
        
            // To company name
            $('#CompanyNameDiv').addClass("Hidden");
        }
    });

    TargetNS.CustomerResponse = function () {

        $("#ErrorNoBodyAlert").remove();

        /*
        * Definitions of all OTRS specific rules and rule methods
        */
        $.validator.addMethod("Validate_Required", ValidatorMethodRequired, "");

        $(document).ready(function(){
            ValidatorMethodRequired
         }); 

        // To validate mandatory fields
        var ValidForm = true;

        $('[name ^= "DynamicField_"').each(function() {

            var Valid = Core.Form.Validate.ValidateElement( $("#" + $(this).attr("name") ) );

            if( Valid == false){
                ValidForm = false;
            }
        });

        if( ValidForm ){
            $("#SendResponse").prop("disabled", true);

            SendMessage(0);
        }
    };

    /**
     * @private
     * @name ValidatorMethodRequired
     * @memberof Core.Form.Validate
     * @function
     * @returns {Boolean} True, if Value has a length, false otherwise.
     * @param {String} Value
     * @param {DOMObject} Element
     * @description
     *      Validator method for checking if a value is present for
     *      different types of elements.
     */
    function ValidatorMethodRequired(Value, Element) {
        var Text,
            $Element = $(Element);
        // special treatment of <select> elements in OTRS
        if (Element.nodeName.toLowerCase() === 'select') {
            Text = $(Element).find('option:selected').text();
            return (Text.length && Text !== '-');
        }
        // for richtextareas, get editor code and remove all tags and whitespace
        // keep tags if images are embedded because of inline-images
        // keep tags if codemirror plugin is used (for XSLT editor)
        if (Core.UI.RichTextEditor.IsEnabled($Element)) {
            Value = CKEDITOR.instances[Element.id].getData();
            if (typeof CKEDITOR.instances[Element.id].config.codemirror === 'undefined' && !Value.match(/<img/)) {
                Value = Value.replace(/\s+|&nbsp;|<\/?\w+[^>]*\/?>/g, '');
            }
        }
        // checkable inputs
        if ($Element.filter('input[type="checkbox"], input[type="radio"]').length) {
            return $Element.filter(':checked').length > 0;
        }
        return $.trim(Value).length > 0;
    }

    TargetNS.CustomerResponseAll = function () {

        $("#ErrorNoBodyAlert").remove();

        $("#SendAllResponse").prop("disabled", true);

        SendMessage(1);
    };

    function SendMessage (ReplayALL){

        var DynamicField = {};

        $('[name ^= "DynamicField_"').each(function() {

            if ( $(this).attr('type') == 'checkbox' ) {

                if ( $(this).is(":checked") ) {
                    DynamicField["" + $(this).attr("name")] = 1;
                }
                else {
                    DynamicField["" + $(this).attr("name")] = 0;
                }
            }
            else {
                DynamicField["" + $(this).attr("name")] = $(this).val();
            }
        });

        var Data = {
            "Action":                 "CustomerPortalTicketZoom",
            "Subaction":              "CustomerResponse",
            "ReplayAll":              ReplayALL,
            "TicketID":               $("input[name=TicketID]").val(),
            "Body":                   CKEDITOR.instances.Body.getData(),
            "FormID":                 $("input[name=FormID]").val(),
            "StateID":                $("#StateID").val(),
            "PriorityID":             $("#PriorityID").val(),
            "ErrorStateQueueMessage": $("#ErrorStateQueueMessage").val(),
            "ErrorNoBody":            $("#ErrorNoBody").val(),
            "DynamicFields":          JSON.stringify(DynamicField),
        };

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {

            if (!Response) {
                $("#SendResponse").prop("disabled", false);
                $("#SendAllResponse").prop("disabled", false);

                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
            }
            else {

                if ( Response.HTMLString !== '' ) {

                    if ( Response.ErrorDynamicField ) {

                        Core.Form.Validate.HighlightError($("#DynamicField_" + Response.DynamicFieldName), 'Error');
                    }
                    else {

                        $("#Body").val('');

                        // Clean body
                        CKEDITOR.instances.Body.setData('');

                        var attachmentDelete = $('.AttachmentDelete');

                        //remove attachments div list
                        attachmentDelete.trigger('click');

                        $("#cke_1_contents").animate({
                            height : "65px",
                            // width : "100px"
                        }, 600);
                    }

                    $("#MessagesPortal" ).append(Response.HTMLString);

                    //Change state
                    if ( Response.TicketState !== '' ) {
                        $("#SpanOfState").text(Response.TicketState);
                    }
                    
                    if ( Response.PriorityName !== '' ) {
                        $("#SpanPriority").text(Response.PriorityName);
                    }

                    var Messages = document.getElementById('MessagesPortal');

                    Messages.scrollTop = Messages.scrollHeight;

                    if ( Response.DynamicFieldsSpan !== undefined ) {

                        // Display DynamicFields new values
                        Object.keys(Response.DynamicFieldsSpan).forEach(function(item){

                            if( $("#SpanValue" + Response.DynamicFieldsSpan[item].Name).length ){
                                $("#SpanValue" + Response.DynamicFieldsSpan[item].Name).text(Response.DynamicFieldsSpan[item].Value);       
                            }
                            else {

                                if( Response.DynamicFieldsSpan[item].Value ){

                                    var List = document.getElementById("InformationsList").innerHTML;
                                    List = List +"<li><span class='Key' id='SpanLabel"+Response.DynamicFieldsSpan[item].Name+"'>"+Response.DynamicFieldsSpan[item].Label+": </span><span id='SpanValue"+Response.DynamicFieldsSpan[item].Name+"'>"+Response.DynamicFieldsSpan[item].Value+"</span></li>";
                                    document.getElementById("InformationsList").innerHTML = List;
                                }                          
                            }
                        });            
                    }

                    if(ReplayALL == 0){
                        $("#SendAllResponse").attr("hidden",true);
                    }

                    $("#SendResponse").prop("disabled", false);
                    $("#SendAllResponse").prop("disabled", false);

                }
            }
        });
    }

    function CalculateHeight(Iframe){

        Iframe = isJQueryObject(Iframe) ? Iframe.get(0) : Iframe;

        var NewHeight = $(Iframe).contents().find('body').height();

        if (!NewHeight || isNaN(NewHeight)) {
            NewHeight = 100;
        }
        else {
            if (NewHeight > 2500) {
                NewHeight = 2500;
            }
        }

        NewHeight = parseInt(NewHeight, 10);

        $(Iframe).height(NewHeight + 'px');
    }

    function ResizeIframe(Iframe, Callback){

        Iframe = isJQueryObject(Iframe) ? Iframe.get(0) : Iframe;

        CalculateHeight(Iframe);

        if ($.isFunction(Callback)) {
            Callback();
        }
    }

    function CheckIframe(Iframe, Callback){
        
        var Source;

        Iframe = isJQueryObject(Iframe) ? Iframe.get(0) : Iframe;

        if ($.browser.safari || $.browser.opera){

            $(Iframe).on('load', function() {
                setTimeout(ResizeIframe, 0, Iframe, Callback);
            });

            Source = Iframe.src;
            Iframe.src = '';
            Iframe.src = Source;
        }
        else {
            $(Iframe).on('load', function() {
                ResizeIframe(this, Callback);
            });
        }
    }

    function ToggleMessage($Message){

        switch ($Message.attr('data-articlestate')) {
            case "untouched":
                LoadMessage($Message);
            break;
            case "true":
                $Message.removeClass('Visible');
                $Message.attr('data-articlestate', "false");
            break;
            case "false":
                $Message.addClass('Visible');
                $Message.attr('data-articlestate', "true");
            break;
        }
    }

    function LoadMessage($Message){

        var $Iframe = $('iframe', $Message),
            Source = $Iframe.attr('title');

        // /*  Load iframe -> get title and put it in src */
        if (Source !== 'about:blank') {
            $Iframe.attr('src', Source);
        }

        function Callback(){
            /*  Set data-articlestate to true and add class Visible */
            $Message.attr('data-articlestate', "true").addClass('Visible');
        }

        if ($Iframe.length) {
            CheckIframe($Iframe, Callback);
        }
    }

    TargetNS.Init = function(){
        for ( var instance in CKEDITOR.instances) {

            var editor = CKEDITOR.instances[instance];

            if (editor) {

                editor.on('focus', function(event) {

                    $("#cke_1_contents").animate({
                        height : "150px",
                        // width : "100px"
                    }, 600);
                });
                
                editor.on('blur', function () {

                    if ( editor.getData().length == 0) {

                        $("#cke_1_contents").animate({
                            height : "65px",
                            // width : "100px"
                        }, 600);
                    }
                });
            }
        }

        var $VisibleIframe = $('.VisibleFrame'),
        ZoomExpand = $('#ZoomExpand').val();

        /* Set statuses saved in the hidden fields for all visible messages if ZoomExpand is present */
        if (!ZoomExpand || isNaN(ZoomExpand)) {

            $('.CardMessage').attr('data-articlestate', "true");

            $('.ArticleIframe').each(function(i,e) { 
            
                CheckIframe($(this));
            });
        }
        else {

            /* Set statuses saved in the hidden fields for all messages */
            $('.CardMessage:not(:last)').attr('data-articlestate', "untouched");
            $('.CardMessage:last').attr('data-articlestate', "true");

            CheckIframe($VisibleIframe.get(0));
        }

        $('.CardMessage > div > a').on('click', function(Event){

            ToggleMessage($(this).parent().parent());

            Event.preventDefault();
        });

        $('.AttachmentIcon').on('click', function (Event) {

            var Position;

            if ($(this).attr('rel') && $('#' + $(this).attr('rel')).length) {

                Position = $(this).offset();
                Core.UI.Dialog.ShowContentDialog($('#' + $(this).attr('rel'))[0].innerHTML, Core.Language.Translate('Attachments'), Position.top - $(window).scrollTop(), parseInt(Position.left, 10) + 25);
            }

            Event.preventDefault();
            Event.stopPropagation();

            return false;
        });

        // Original function - Changed to document.ready to work in Safari
        // $(window).on("load", function(){
        //     $("#MessagesPortal").css('visibility', 'visible');
        //     var Messages = document.getElementById('MessagesPortal');
        //     Messages.scrollTop = Messages.scrollHeight;
        // });
        
        $(document).ready(function(){
            $("#MessagesPortal").css('visibility', 'visible');
            var Messages = document.getElementById('MessagesPortal');

            Messages.scrollTop = Messages.scrollHeight;
        });

    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.TicketZoomPortal || {}));