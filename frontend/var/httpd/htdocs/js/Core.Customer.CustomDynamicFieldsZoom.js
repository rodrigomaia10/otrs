// --
// var/http/htdocs/js/Core.Customer.CustomDynamicFieldsZoom.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.Customer.CustomDynamicFieldsZoom = (function (TargetNS) {
    
    TargetNS.Init = function () {

        var Action = $("input[name='Action'").val();

        $("fieldset").css("padding-left","10%");
        $(".InputField_Container").css("width","100%");
        $(".InputField_InputContainer").css("width","100%");
        $(".InputField_Container").css("margin-right","10%");
        $("input").css("width","100%");
        $("input.W75pc").css("width","98.5%");
        $('input[id*="DynamicField_"]').css("width","100.7%");
        $('input[id*="DynamicField_"]').css("height","30px");
        $('input[id*="DynamicField_"]').css("border-radius", "6px");
       
        $.each($('input[type=checkbox]'),function(){
            $(this).css("height","12px");
            $(this).css("width","5%");
        })

        $(".DynamicFieldText.W50pc").css("width","100%");

        $("select").on("redraw.InputField", function(e){
           
            $(".InputField_Container").css("width","100%");
            $(".InputField_InputContainer").css("width","100%");
            $(".InputField_Container").css("margin-right","1%");
            $("input").css("width","100%");
            $("input.W75pc").css("width","98.5%");
            $('input[id*="DynamicField_"]').css("width","100.7%");
            $(".DynamicFieldText.W50pc").css("width","50%");
            $(".DynamicFieldMask.W50pc").css("width","98.5%");

            $.each($('input[type=checkbox]'),function(){
                $(this).css("height","12px");
                $(this).css("width","5%");
            })
            
            $(this).css('width',"35%");
        });
      
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CustomDynamicFieldsZoom || {}));

