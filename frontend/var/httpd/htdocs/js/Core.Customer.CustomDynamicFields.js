// --
// var/http/htdocs/js/Core.Customer.CustomDynamicFields.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.Customer.CustomDynamicFields= (function (TargetNS) {

    TargetNS.Init = function () {

        var Action = $("input[name='Action'").val();

        // $(window).on("load", function(){

        //     $("fieldset").css("padding-left","10%");
        //     // $(".InputField_Container").css("width","98.5%");
        //     $(".InputField_InputContainer").css("width","100%");
        //     $(".InputField_InputContainer").css("max-height","77%");
        //     $(".InputField_Container").css("margin-right","10%");
        //     $("input").css("width","100%");
        //     $("input.W75pc").css("width","98.5%");
        //     $('input[id*="DynamicField_"]').css("width","100.7%");
        //     $('input[id*="DynamicField_"]').css("height","30px");
        //     $('input[id*="DynamicField_"]').css("border-radius", "6px");

        //     // $.each($('input[type=checkbox]'),function(){
        //     //     $(this).css("height","12px");
        //     //     $(this).css("width","5%");
        //     // })

        //     $(".DynamicFieldText.W50pc").css("width","100%");
        //     // $(".InputField_Selection").css("padding", "4px");

        //     $("select").on("redraw.InputField", function(e){

        //         // $(".InputField_Selection").css("padding", "4px");
        //         // $(".InputField_Container").css("width","98.5%");
        //         $(".InputField_InputContainer").css("width","100%");
        //         $(".InputField_Container").css("margin-right","1%");
        //         $("input").css("width","100%");
        //         $("input.W75pc").css("width","98.5%");
        //         $('input[id*="DynamicField_"]').css("width","100.7%");
        //         $(".DynamicFieldText.W50pc").css("width","99%");
        //         $(".DynamicFieldMask.W50pc").css("width","98.5%");

        //         $.each($('input[type=checkbox]'),function(){
        //             $(this).css("height","12px");
        //             $(this).css("width","5%");
        //         })
                
        //         $(this).css('width',"35%");
        //     });
        // });

        var $Form,
        FieldID,
        DynamicFieldNames = Core.Config.Get('DynamicFieldNames'),
        Fields = ['TypeID', 'Dest', 'PriorityID', 'ServiceID', 'SLAID'],
        ModifiedFields;

        // Bind events to specific fields
        $.each(Fields, function(Index, Value) {

            
            ModifiedFields = Core.Data.CopyObject(Fields).concat(DynamicFieldNames);
            ModifiedFields.splice(Index, 1);

            FieldUpdate(Value, ModifiedFields);
        });

        // delete attachment
        $('button[id*=AttachmentDeleteButton]').on('click', function () {

            $Form = $(this).closest('form');

            FieldID = $(this).attr('id').split('AttachmentDeleteButton')[1];

            $('#AttachmentDelete' + FieldID).val(1);

            Core.Form.Validate.DisableValidation($Form);

            $Form.trigger('submit');
        });
    };

    function FieldUpdate (Value, ModifiedFields) {
        $('#' + Value).on('change', function () {
            Core.AJAX.FormUpdate($('#NewServiceTicket'), 'AJAXUpdate', Value, ModifiedFields);
        });
    }

    function GetURLParameter(sParam) {

        let sPageURL = window.location.search.substring(1);
        let sURLVariables = sPageURL.split(';');
    
        for (let i = 0; i < sURLVariables.length; i++) {
            let sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] == sParam){
                return sParameterName[1];
            }
        }
    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CustomDynamicFields || {}));

