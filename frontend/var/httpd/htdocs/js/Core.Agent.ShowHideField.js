// --
// var/httpd/htdocs/js/Core.Agent.ShowHideField.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// * jsantos@serviceup.com.br
// * msantos@serviceup.com.br
// * ccresencio@serviceup.com.br
// * nfreitas@serviceup.com.br
// * gbolsoni@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

var Action = $('form.Validate').children('input[name=Action]').val();

if (Action == undefined){
    Action = $('form.Validate').find('input[name=Action]').val();
}

var Params;
var FieldValues = {};
var ServiceIDOfForm = '';

/**
 * @namespace Core.Agent.ShowHideField
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for ShowHideField module.
 */
 Core.Agent.ShowHideField = (function (TargetNS) {

    var FlagProcessFieldReadOnly;

    Core.App.Subscribe('Event.Agent.CustomerSearch.GetCustomerInfo.Callback', function() { 
        TargetNS.Init('');
    });

    $(document).ready( function() {
        if ( Action !== 'AgentTicketProcess' && Action !== 'CustomerTicketProcess' ) {
            TargetNS.Init('');
        }
    });

    $(document).change( function(event) {
        TargetNS.Init(event.target.id);
    });

    /*
    * @name Init
    * @memberof Core.Agent.ShowHideField
    * @function
    * @description
    *      This function initializes table filter.
    */

    TargetNS.Init = function ( TargetChange ) {

        var actions = [
            'AgentTicketProcess',
            'AgentTicketEmail',
            'AgentTicketPhone',
            'AgentTicketFreeText',
            'AgentTicketAddtlITSMField',
            'AgentTicketNote',
            'AgentTicketPending',
            'AgentTicketClose',
            'AgentTicketCompose',
            'CustomerTicketMessage',
            'CustomerTicketProcess',
            'AgentTicketOwner',
            'AgentTicketEmailOutbound',
            'AgentTicketPhoneInbound',
            'AgentTicketPhoneOutbound',
            'AgentTicketPhoneCommon',
            'AgentTicketPriority',
            'AgentTicketDecision',
            'AgentTicketForward',
            'AgentTicketMove',
            'AgentTicketMasterSlave',
            'NewTicketService',
            'NewTicketProcess',
            'AgentTicketProcessBulk',
            'CustomerPortalTicketZoom',
            'AgentEasyCategorization',
            'CustomerTicketZoom',
            'PublicProcessForm',
            'AgentTicketServiceFormFields',
        ];
        
        // && Action != undefined
        if ( $.inArray(Action, actions) == -1 ) {
            return;
        }

        if ( Action === 'AgentTicketProcess' || Action === 'CustomerTicketProcess' ) {
            $('#ProcessEntityID').change(function() {
                FieldValues = {};
            });
        }

        Params = TargetNS.GetParams(Action);

        TargetNS.GetDynamicFieldValues(Action, Params,  TargetChange);
      
    };

    /*
    * @name GetParams
    * @memberof Core.Agent.GetParams
    * @function
    * @description
    *      This function initializes filter.
    */
    TargetNS.GetParams = function (Action) {
        var Parameters;

        var InputsHide;

        if( Action === 'AgentTicketProcess' || Action === 'CustomerTicketProcess' || Action === 'NewTicketProcess' || Action === 'AgentTicketProcessBulk' ) {
            Parameters = { CustomerUserID: '', CustomerID: '', QueueID: '', ServiceID: '', PriorityID: '', RichText: '', Subject: '' };

            InputsHide = { ProcessEntityID: '', ActivityDialogEntityID: '', TicketID: '' };
        }
        else {
            Parameters = {
                Year: '', Month: '', Day: '', Hour: '', Minute: '', TimeUnits: '', CustomerUserID: '', CustomerID : '',
                PriorityID: '', Subject: '', Body: '', TypeID: '', ServiceID: '', SLAID: '', OwnerAll: '', OwnerID: '',
                ResponsibleAll: '', NewResponsibleID: '', NewUserID: '', NextStateID: '', StandardTemplateID: '', QueueID: '' , 
                Queue: '', TicketID: '', ComposeStateID: '', NewPriorityID: '', ContractID: ''
            };
        }

        for ( var Key in Parameters ) {
            if ( Action === 'AgentTicketEmail' || Action === 'AgentTicketPhone' || Action === 'CustomerTicketMessage' || Action === 'NewTicketService') {
                var count = 1;

                if ( Key === 'QueueID' ) {
                    if( $('#Dest').val() ) {
                        var aux = $('#Dest').val().split(/\|/) || '';
                        Parameters[Key] = aux[0];
                    }
                }
                else if(Key === 'CustomerID'){

                    Parameters[Key] = $("#CustomerID").val();
                }
                else if (Key === 'CustomerUserID'){
                    
                    Parameters[Key] = $("#CustomerKey_" + count).val();
                }
                else {
                    Parameters[Key] = $('#' + Key).val() || '';
                }
            }
            // Added action AgentTicketCompose and AgentTicketEmailOutbound to ACL
            else if ( Action === 'AgentTicketFreeText' || Action === 'AgentTicketPriority' || 
                Action === 'AgentTicketOwner' || Action === 'AgentTicketAddtlITSMField' || 
                Action === 'AgentTicketNote' || Action === 'AgentTicketPending' || 
                Action === 'AgentTicketClose' || Action === 'AgentTicketDecision' ||
                Action === 'AgentTicketMove' || Action === 'AgentTicketCompose' ||
                Action === 'AgentTicketEmailOutbound' || Action === 'CustomerTicketZoom' || 
                Action === 'AgentTicketServiceFormFields' || Action === 'CustomerPortalTicketZoom') {
                    ;

                if ( Key === 'QueueID' ) {
                    if ( $('#NewQueueID').val() ) {
                        Parameters[Key] = $('#NewQueueID').val() || '';
                    }
                    else if ( Action === 'AgentTicketMove' ) {
                        Parameters[Key] = $('#DestQueueID').val() || '';
                    }
                }
                else if ( Key === 'NextStateID' ) {
                    if( Action === 'AgentTicketCompose' ){
                        if ( $('#StateID').val() ) {
                            Parameters[Key] = $('#StateID').val() || '';
                        }    
                    }
                    else if ( Action === 'CustomerTicketZoom' ){
                        if ( $('#StateID').val() ) {
                            Parameters[Key] = $('#StateID').val() || '';
                        }    
                    }
                    else if ( Action === 'PublicProcessForm' ){
                        if ( $('#StateID').val() ) {
                            Parameters[Key] = $('#StateID').val() || '';
                        }    
                    }
                    else{
                        if ( $('#NewStateID').val() ) {
                            Parameters[Key] = $('#NewStateID').val() || '';
                        }
                    }
                    
                }
                else if ( Key === 'PriorityID' ) {
                    if ( $('#NewPriorityID').val() ) {
                        Parameters[Key] = $('#NewPriorityID').val() || '';
                    }
                }
                else if ( Key === 'TicketID' ) {
                    if ( $('[name=TicketID]').val() ) {
                        Parameters[Key] = $('[name=TicketID]').val() || '';
                    }
                }
                else {
                    Parameters[Key] = $('#' + Key).val() || '';
                }
            }
            else if ( Action === 'AgentTicketCompose' ) {
                if ( Key === 'NextStateID' ) {
                    if ( $('#StateID').val() ) {
                        Parameters[Key] = $('#StateID').val() || '';
                    }
                }
                else {
                    Parameters[Key] = $('#' + Key).val() || '';
                }
            }
            else if ( Action === 'AgentTicketForward' ) {
                if ( Key === 'NextStateID' ) {
                    if ( $('#ComposeStateID').val() ) {
                        Parameters[Key] = $('#ComposeStateID').val() || '';
                    }
                }
                else if ( Key === 'TicketID' ) {
                    if ( $('[name=TicketID]').val() ) {
                        Parameters[Key] = $('[name=TicketID]').val() || '';
                    }
                }
                else {
                    Parameters[Key] = $('#' + Key).val() || '';
                }
            }
            else {

                Parameters[Key] = $('#' + Key).val() || '';
            }
        }

        if ( InputsHide ) {

            for ( let KeyHide in InputsHide ) {

                Parameters[KeyHide] = $('input[name=' + KeyHide + ']').val() || '';
            }
        }

        return Parameters;
    }

    /*
    * @name GetDynamicFieldValues
    * @memberof Core.Agent.GetDynamicFieldValues
    * @function
    * @description
    *      This function initializes filter.
    */
    TargetNS.GetDynamicFieldValues = function (Action, Parameters, TargetChange ) {

        var Param = {};

        if( Action === 'AgentTicketProcess' || Action === 'CustomerTicketProcess' || Action === 'NewTicketProcess' || Action === 'AgentTicketProcessBulk' || Action === 'CustomerPortalTicketZoom' ) {

            var InputsHide = { ProcessEntityID: '', ActivityDialogEntityID: '' };

            if(InputsHide){
                for (var Key in InputsHide){
                    Param[Key] = $('input[name=' + Key + ']').val() || '';
                }
            }

            if ( Action === 'NewTicketProcess' && $('form.Validate').children('input[name=Subaction]').val() != "DisplayActivityDialog" ) {
                Parameters["ProcessEntityID"] = $("#ProcessEntityID").val() || '';
            }
        }

        var Data = {
            Action: 'ShowHideAJAXHandler',
            Subaction: 'GetViewFields',
            Params: JSON.stringify(Param),
            TicketAction: Action,
            ServiceID: $("#ServiceID").val()
        };

        if ( $.isEmptyObject(FieldValues) ) {

            let Response = [];

            if( Action === 'AgentEasyCategorization') {
                $(".DynamicFieldEasy").each(function() {

                    var id = $(this).attr('id');

                    // Check if the ID starts with "DynamicField_"
                    if (!id.startsWith('DynamicField_')) {
                        Response.push('DynamicField_' + id);
                    }
                    else{
                        Response.push(id);
                    }
                    
                });
                Response.push("QueueID");
                Response.push("ServiceID");
                Response.push("PriorityID");
                Response.push("OwnerID");
                Response.push("TypeID");
                Response.push("LockID");
                Response.push("StateID");
                Response.push("SLAID");
            }
            else {

                $("form label").each(function() {
                    if ( $(this).attr('for') != undefined ) {
                        if ( $(this).attr('for').split('DynamicField_')[1] != undefined ) {
                            Response.push( $(this).attr('for') );
                        }
                    }
                });
            }

            for ( var Field in Response ) {
                    
                FieldValues[ Response[Field] ] = $('#' + Response[Field]).val() || '';
            }

            TargetNS.GetACLs(FieldValues, Parameters, TargetChange);
        }
        else {


            // Added this check to reload FieldValues ​​when service is switched as it also affects the CustomServiceForm
            if ( Parameters.ServiceID && Parameters.ServiceID != ServiceIDOfForm ) {

                ServiceIDOfForm = Parameters.ServiceID;
               
                TargetNS.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
        
                    // Getting information needed to validate interaction with the ProcessFieldReadOnly module
                    FlagProcessFieldReadOnly = Response[Response.length-1];
                    Response.pop();
                    
                    for ( var Field in Response ) {
                        
                        FieldValues[ Response[Field] ] = $('#' + Response[Field]).val() || '';
                    }

                    TargetNS.GetACLs(FieldValues, Parameters, TargetChange);
                }, false);
            }
            else{
               
                $.each( FieldValues, function( key, value ) {
                
                    FieldValues[key] = $('#' + key).val() || '';
                });

                TargetNS.GetACLs(FieldValues, Parameters, TargetChange);
            }
          
        }
    }

    function ToggleAJAXLoader(FieldID, Show) {

        var AJAXLoaderPrefix = 'AJAXLoader',
        ActiveAJAXCalls = {};
    
        var $Element = $('#' + FieldID),
            $Loader = $('#' + AJAXLoaderPrefix + FieldID),
            LoaderHTML = '<span id="' + AJAXLoaderPrefix + FieldID + '" class="AJAXLoader"></span>';
    
        if ($Element.is('[type=hidden]')) {
            return;
        }
        if (!$Element.length) {
            ActiveAJAXCalls[FieldID] = 0;
            return;
        }
    
        if (typeof ActiveAJAXCalls[FieldID] === 'undefined') {
            ActiveAJAXCalls[FieldID] = 0;
        }
    
        if (Show) {
            ActiveAJAXCalls[FieldID]++;
        }
        else {
            ActiveAJAXCalls[FieldID]--;
            if (ActiveAJAXCalls[FieldID] <= 0) {
                ActiveAJAXCalls[FieldID] = 0;
            }
        }
    
        if (ActiveAJAXCalls[FieldID] > 0) {
            if (!$Loader.length) {
                $Element.after(LoaderHTML);
            }
            else {
                $Loader.show();
            }
        }
        else {
            $Loader.hide();
        }
    }    

    /*
    * @name GetACLs
    * @memberof Core.Agent.GetACLs
    * @function
    * @description
    *      This function initializes filter.
    */
    TargetNS.GetACLs = function (FieldValues, Parameters, TargetChange) {
        var Data = {
            Action: 'ShowHideAJAXHandler',
            Subaction: 'GetACLs',
            TicketAction: Action,
            Params: JSON.stringify(Parameters),
            FieldValues: JSON.stringify(FieldValues),
            TargetChange: TargetChange
        };

        if ( TargetChange && Action == 'PublicProcessForm' ) {
            ToggleAJAXLoader(TargetChange, true);
        }

        var AllFields = [];
        
        for ( var Field in FieldValues ) {
            AllFields.push(Field);
        }

        TargetNS.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            var ACLFields = [];

            for ( Field in Response ) {                

                if ( Response[Field].ShowHide == 'Hide' || Response[Field].ShowHide == 'HideWithValue' ) {
                    
                    if ( Response[Field].ShowHide == 'Hide' ){
                        $('#' + Response[Field].Field).val('');
                    }

                    $('#' + Response[Field].Field).trigger('redraw.InputField');
                    ACLFields.push(Response[Field].Field);
                }

                if ( Response[Field].FieldType === 'Default' ) {
                    TargetNS.SetShowHide(Response[Field], Action);
                }
                else {
                    TargetNS.SetShowHideDF(Response[Field]);
                }
            }

            if ( TargetChange && Action == 'PublicProcessForm' ) {
                ToggleAJAXLoader(TargetChange, false);
            }

            TargetNS.RemoveAJAXLoader(ACLFields, AllFields);
        }, true);
    }

    /*
    * @name SetShowHideDF
    * @memberof Core.Agent.SetShowHideDF
    * @function
    * @description
    *      This function initializes filter.
    */
   
    TargetNS.SetShowHideDF = function (Data) {
        
        if ( Data.ShowHide === 'Hide' ) {

            $('.Row_' + Data.Field).addClass('HiddenShowHide');            
            // $('.Row_' + Data.Field).addClass('HiddenShowHide');      
                  
            $('.Col_' + Data.Field).addClass('HiddenShowHide'); // To CustomerPortal

            if( Action == 'AgentEasyCategorization' ) {
           
                let name = Data.Field.replace("DynamicField_", "");

                $('#' + name ).parent().addClass('Hidden');
                $(`label[for='${name}ID']`).addClass('Hidden');
                $(`label[for='${name}ID']`).css('display','none');
    
                $('#' + name).removeClass('Validate_Required');        
                
                // To AgentEasyCategorization Text fields
                // $('input.ECTextField').each(function() {
                //     $(this).parent().addClass('Hidden');
                //     $(`label[for='${name}ID']`).addClass('Hidden');
                //     $(`label[for='${name}ID']`).css('display','none');
                //     $(this).removeClass('Validate_Required');        

                // });

                // // To AgentEasyCategorization Date fields
                // $('input.ECDateField').each(function() {
                //     $(this).parent().addClass('Hidden');
                //     // $(`label[for='${name}ID']`).addClass('Hidden');
                //     // $(`label[for='${name}ID']`).css('display','none');
                //     $(this).removeClass('Validate_Required');        

                // });

                if ( Data.FieldType === 'Date' || Data.FieldType === 'DateTime') {
                    $('#' + Data.Field + 'Used').removeClass('Validate_Required');
                    $('#' + Data.Field + 'Used').parent().addClass('Hidden');
                }else{
                    $('#' + Data.Field).parent().addClass('Hidden');
                    $(`label[for='${name}ID']`).addClass('Hidden');
                    $(`label[for='${name}ID']`).css('display','none');
                    $('#' + Data.Field).removeClass('Validate_Required');   
                }
            } 
            else if ( Action == 'PublicProcessForm' ) {
                $('.Row_' + Data.Field).parent().addClass('HiddenShowHide');
            }

            if ( Data.FieldType !== 'Date' && Data.FieldType !== 'DateTime' ) {

                $('#Label' + Data.Field).children('span[class="Marker"]').remove();
                $('#' + Data.Field).val();
                $('#Label' + Data.Field).removeClass('Mandatory');

                if (Data.FieldType === 'SelectDB') {
                    $('#' + Data.Field + '_Validate').removeClass('Validate_Required');
                    $('#remove_'+ Data.Field).click();
                }
                else if ( Data.FieldType == 'Radio' ) {
                    var RadioNameItem = "RadioItem_" + Data.Field;

                    $('input[type=radio][name=' + RadioNameItem +']').each(function(){
                        $(this).prop('checked', false);
                    });

                    $('#' + Data.Field).val('');

                    $('#' + Data.Field).removeClass('Validate_Required');

                }
                else{

                    $('#' + Data.Field).removeClass('Validate_Required');
                }
            }
            else{
                $('#Label' + Data.Field + 'Used').children('span[class="Marker"]').remove();
                $('#' + Data.Field + 'Used').val();
                $('#Label' + Data.Field + 'Used').removeClass('Mandatory');
                $('#' + Data.Field + 'Used').removeClass('Validate_Required');
            }

        }
        // Function to hide the dynamic field without losing value
        else if(Data.ShowHide === 'HideWithValue'){

            $('.Row_' + Data.Field).addClass('HiddenShowHide');            
            $('.Col_' + Data.Field).addClass('HiddenShowHide'); // To CustomerPortal

            if ( Action == 'PublicProcessForm' ) {
                $('.Row_' + Data.Field).parent().addClass('HiddenShowHide');
            }

            if(Data.FieldType !== 'Date' && Data.FieldType !== 'DateTime'){

                $('#Label' + Data.Field).children('span[class="Marker"]').remove();
                $('#Label' + Data.Field).removeClass('Mandatory');

                if (Data.FieldType === 'SelectDB') {
                    $('#' + Data.Field + '_Validate').removeClass('Validate_Required');
                }
                else{

                    $('#' + Data.Field).removeClass('Validate_Required');
                }
            }
            else{
                $('#Label' + Data.Field + 'Used').children('span[class="Marker"]').remove();
                $('#' + Data.Field + 'Used').val();
                $('#Label' + Data.Field + 'Used').removeClass('Mandatory');
                $('#' + Data.Field + 'Used').removeClass('Validate_Required');
            }

        }
        else if(Data.ShowHide === 'Show'){

            if($('.Row_' + Data.Field).hasClass("HiddenShowHide")){
                $('.Row_' + Data.Field).removeClass('HiddenShowHide');
            }

            // To CustomerPortal
            if($('.Col_' + Data.Field).hasClass("HiddenShowHide")){
                $('.Col_' + Data.Field).removeClass('HiddenShowHide');
            }

            if( Action == 'AgentEasyCategorization' ){

                let name = Data.Field.replace("DynamicField_", "");
    
                $('#' + name ).parent().removeClass('Hidden');
                $(`label[for='${name}ID']`).removeClass('Hidden');
                $(`label[for='${name}ID']`).css('display','block');
    
                $('#' + name).removeClass('Validate_Required');

                // // To AgentEasyCategorization Text fields
                // $('input.ECTextField').each(function() {
                //     $(this).parent().removeClass('Hidden');
                //     $(`label[for='${name}ID']`).removeClass('Hidden');
                //     $(`label[for='${name}ID']`).css('display','block');
        
                //     $(this).removeClass('Validate_Required');
                  
                // });

                // // To AgentEasyCategorization Date fields
                // $('input.ECDateField').each(function() {
                //     $(this).parent().removeClass('Hidden');
                //     // $(`label[for='${name}ID']`).removeClass('Hidden');
                //     // $(`label[for='${name}ID']`).css('display','block');
        
                //     $(this).removeClass('Validate_Required'); 

                // });

                if ( Data.FieldType === 'Date' || Data.FieldType === 'DateTime') {
                    $('#' + Data.Field + 'Used').removeClass('Validate_Required');
                    $('#' + Data.Field + 'Used').parent().removeClass('Hidden');
                }else{
                    $('#' + Data.Field).parent().removeClass('Hidden');
                    $(`label[for='${name}ID']`).removeClass('Hidden');
                    $(`label[for='${name}ID']`).css('display','block');
                    $('#' + Data.Field).removeClass('Validate_Required');
                }
                
            }
            else if ( Action == 'PublicProcessForm' ) {
                if($('.Row_' + Data.Field).parent().hasClass("HiddenShowHide")){
                    $('.Row_' + Data.Field).parent().removeClass('HiddenShowHide');
                }
            }

            if($('#Label' + Data.Field).hasClass("Mandatory") || $('#Label' + Data.Field + 'Used').hasClass("Mandatory")){
                if(Data.FieldType !== 'Date' && Data.FieldType !== 'DateTime'){
                    $('#Label' + Data.Field).children('span[class="Marker"]').remove();
                    $('#Label' + Data.Field).removeClass('Mandatory');
                    $('#' + Data.Field).removeClass('Validate_Required');
                }
                else{
                    $('#Label' + Data.Field + 'Used').removeClass('Mandatory');
                    $('#Label' + Data.Field + 'Used').children('span[class="Marker"]').remove();
                    $('#' + Data.Field + 'Used').removeClass('Validate_Required');
                }
            }
        }
        else if(Data.ShowHide === 'Mandatory'){

            if($('.Row_' + Data.Field).hasClass("HiddenShowHide")){
                $('.Row_' + Data.Field).removeClass('HiddenShowHide');
            }

            // To CustomerPortal
            if($('.Col_' + Data.Field).hasClass("HiddenShowHide")){
                $('.Col_' + Data.Field).removeClass('HiddenShowHide');
            }
            
            if ( Action == 'PublicProcessForm' ) {
                if($('.Row_' + Data.Field).parent().hasClass("HiddenShowHide")){
                    $('.Row_' + Data.Field).parent().removeClass('HiddenShowHide');
                }
            }

			if(Data.FieldType !== 'Date' && Data.FieldType !== 'DateTime'){

				if ( !$('#Label' + Data.Field).hasClass("Mandatory")){

                    $('#Label' + Data.Field).addClass('Mandatory');
                    $('#Label' + Data.Field).prepend('<span class="Marker">*</span>');

                    if (Data.FieldType === 'SelectDB') {
                        $('#' + Data.Field + '_Validate').addClass('Validate_Required');
                    }
                    else if ( Data.FieldType == 'FileSystem' ) {

                        // It will only add the mandatory class if the field has no attachments
                        if ( $("#" + Data.Field ).next().next().html() == undefined ) {

                            $('#' + Data.Field).addClass('Validate_Required');
                        }
                    }
                    else{
                        $('#' + Data.Field).addClass('Validate_Required');
                    }
                }
			}
			else{

				if(!$('#Label' + Data.Field + 'Used').hasClass("Mandatory")){
                    $('#Label' + Data.Field + 'Used').addClass('Mandatory');
                    $('#Label' + Data.Field + 'Used').prepend('<span class="Marker">*</span>');
                    $('#' + Data.Field + 'Used').addClass('Validate_Required');
				}
			}
        }
        else if (Data.ShowHide === 'Readonly'){

            $('#' + Data.Field).attr("readonly", true);

        }
    }

    /*
    * @name SetShowHide
    * @memberof Core.Agent.SetShowHide
    * @function
    * @description
    *      This function initializes filter.
    */
    TargetNS.SetShowHide = function (Data, Action) {
        // if(Data.ShowHide === 'Hide'){
        if ( Data.ShowHide === 'Hide' || Data.ShowHide === 'HideWithValue' ) {

            if ( Data.Field ===  'Attachment' ) {
                if ( Action == 'CustomerTicketMessage' ) {
                    $('label[for="' + Data.Field + '"]').css('display', 'none');
                    $('label[for="' + Data.Field + '"]').next().addClass('HiddenShowHide');
                }
                else if ( Action == 'AgentTicketPhone' ) {
                    $('#FileUpload').parent().prev().css('display', 'none');
                    $('#FileUpload').parent().addClass('HiddenShowHide');
                }
                else {
                    $('#FileUpload').parent().parent().prev().css('display', 'none');
                    $('#FileUpload').parent().parent().addClass('HiddenShowHide');
                }
            }
            else if( Data.Field ===  'RichText' ) {

                if(Action == 'CustomerTicketMessage'){
                  
                }
                else{
                    $('label[for="' + Data.Field + '"]').css('display', 'none');
                    $('label[for="' + Data.Field + '"]').next().addClass('HiddenShowHide');
                    $('label[for="' + Data.Field + '"]').children('span[class="Marker"]').remove();

                    if ( Data.ShowHide === 'Hide' ) {
                        $('#' + Data.Field).val([]);
                    }
                    $('label[for="' + Data.Field + '"]').removeClass('Mandatory');
                    $('#' + Data.Field).removeClass('Validate_Required');
                }
            }
            else if ( Data.Field ===  'PriorityID' && Action == 'NewTicketService' ) {

                $('label[for="Priority"]').css('display', 'none');
                $('label[for="Priority"]').next().addClass('HiddenShowHide');
                $('label[for="Priority"]').children('span[class="Marker"]').remove();
                $('label[for="Priority"]').parent().css('display', 'none');

                if ( Data.ShowHide === 'Hide' ) {
                    $('#' + Data.Field).val([]);
                }
                $('#' + Data.Field).css('display', 'none');
            }
            else {

                $('label[for="' + Data.Field + '"]').css('display', 'none');
                $('label[for="' + Data.Field + '"]').next().addClass('HiddenShowHide');
                $('label[for="' + Data.Field + '"]').children('span[class="Marker"]').remove();

                if ( Data.ShowHide === 'Hide' ) {
                    $('#' + Data.Field).val([]);
                }
                $('label[for="' + Data.Field + '"]').removeClass('Mandatory');
                $('#' + Data.Field).removeClass('Validate_Required');
            }
        }
        else if ( Data.ShowHide === 'Show' ) {

            if ( Data.Field ===  'Attachment' ) {
                if ( $('#FileUpload').parent().parent().hasClass('HiddenShowHide') ) {
                    // $('#FileUpload').parent().parent().parent().prev().css('display', '');
                    $('#FileUpload').parent().parent().prev().css('display', '');
                    // $('#FileUpload').parent().parent().parent().removeClass('HiddenShowHide');
                    $('#FileUpload').parent().parent().removeClass('HiddenShowHide');

                }
            }
            else {

                if ( $('label[for="' + Data.Field + '"]').next().hasClass("HiddenShowHide") ) {
                   
                    if( Data.Field ===  'RichText' ) {
                        $('label[for="' + Data.Field + '"]').next().css('display', '');   
                    }
                    
                    $('label[for="' + Data.Field + '"]').css('display', '');
                    $('label[for="' + Data.Field + '"]').next().removeClass('HiddenShowHide');
                }
            }

            $('label[for="' + Data.Field + '"]').children('span[class="Marker"]').remove();
            $('label[for="' + Data.Field + '"]').removeClass('Mandatory');
            $('label[for="' + Data.Field + '"]').removeClass('Validate_Required');
        }
        else if ( Data.ShowHide === 'Mandatory' ) {

            if ( Data.Field ===  'PriorityID' && Action == 'NewTicketService' ) {

                if ( !$('label[for="Priority"]').hasClass('Mandatory') ) {

                    $('label[for="Priority"]').css('display', '');
                    $('label[for="Priority"]').addClass('Mandatory');
                    $('label[for="Priority"]').prepend('<span class="Marker">*</span>');

                    $('#' + Data.Field).addClass('Validate_Required');
                }
            }
            else if ( $('label[for="' + Data.Field + '"]').next().hasClass("HiddenShowHide") ) {

                if( Data.Field ===  'RichText' ) {
                   
                    $('label[for="' + Data.Field + '"]').next().css('display', '');
                    $('label[for="' + Data.Field + '"]').next().removeClass('HiddenShowHide');
                    $('#' + Data.Field).addClass('Validate_Required');

                    $('label[for="' + Data.Field + '"]').css('display', '');
                    // $('label[for="' + Data.Field + '"]').addClass('Mandatory');
                    // $('label[for="' + Data.Field + '"]').prepend('<span class="Marker">*</span>');
                    // $('#' + Data.Field).addClass('Validate_Required');
                    
                }
                else{
                    $('label[for="' + Data.Field + '"]').css('display', '');
                    $('label[for="' + Data.Field + '"]').next().removeClass('HiddenShowHide');      
                }

                $('label[for="' + Data.Field + '"]').addClass('Mandatory');
                $('label[for="' + Data.Field + '"]').prepend('<span class="Marker">*</span>');
                $('#' + Data.Field).addClass('Validate_Required');

            }
            else if ( Data.Field ===  'Attachment' ) {
                if ( $('#FileUpload').parent().parent().hasClass('HiddenShowHide') ) {
                    // $('#FileUpload').parent().parent().parent().prev().css('display', '');
                    $('#FileUpload').parent().parent().prev().css('display', '');
                    // $('#FileUpload').parent().parent().parent().removeClass('HiddenShowHide');
                    $('#FileUpload').parent().parent().removeClass('HiddenShowHide');

                }
            }
            else {
                if ( !$('label[for="' + Data.Field + '"]').hasClass('Mandatory') ) {
                    $('label[for="' + Data.Field + '"]').addClass('Mandatory');
                    $('label[for="' + Data.Field + '"]').prepend('<span class="Marker">*</span>');
                    $('#' + Data.Field).addClass('Validate_Required');
                }
            }
        }
       
    }

    /*
    * @name SetShowHideDF
    * @memberof Core.Agent.RemoveAJAXLoader
    * @function
    * @description
    *      This function initializes filter.
    */
    TargetNS.RemoveAJAXLoader = function (ACLFields, AllFields) {        

        for ( var key in AllFields ) {

            $('#Loader_' + AllFields[key]).addClass('HiddenShowHide');

            if ( $.inArray(AllFields[key], ACLFields) == -1 ) {
               $('.Row_' + AllFields[key]).removeClass('HiddenShowHide');

               if ( $('#' + AllFields[key]).is('select') ) {               
                   Core.UI.InputFields.InitSelect($('#' + AllFields[key]));
               }
            }
        }    
    }

    /**
     * @name FunctionCall
     * @memberof Core.AJAX
     * @function
     * @returns {Object} The jqXHR object.
     * @param {String} URL - The URL which is called via Ajax.
     * @param {Object} Data - The data hash or data query string.
     * @param {Function} Callback - The callback function which is called after the request returned from the server.
     * @param {String} [Async=true] Defines if function is asynchronous, default treu, could also be false
     * @param {String} [DataType=json] Defines the datatype, default 'json', could also be 'html'
     * @description
     *      Calls an URL via Ajax and executes a given function after the request returned from the server.
     */
     TargetNS.FunctionCall = function (URL, Data, Callback, Async, DataType) {
        if (typeof Data === 'string') {
            Data += SerializeData(GetSessionInformation());
        } else {
            Data = $.extend(Data, GetSessionInformation());
        }

        return $.ajax({
            type: 'POST',
            url: URL,
            data: Data,
            async: Async,
            dataType: (typeof DataType === 'undefined') ? 'json' : DataType,
            success: function (Response, Status, XHRObject) {

                Core.App.Publish('Core.App.AjaxErrorResolved');

                if (RedirectAfterSessionTimeOut(XHRObject)) {
                    return false;
                }

                // call the callback
                if ($.isFunction(Callback)) {
                    Callback(Response);
                    // publish to event channel
                    Core.App.Publish('Event.AJAX.FunctionCall.Callback', [Response]);
                }
                else {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefore we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Invalid callback method: " + ((typeof Callback === 'undefined') ? 'undefined' : Callback.toString())));
                }
            },
            error: function(XHRObject, Status, Error) {
                HandleAJAXError(XHRObject, Status, Error)
            }
        });
    };

    /**
     * @private
     * @name RedirectAfterSessionTimeOut
     * @memberof Core.AJAX
     * @function
     * @returns {Boolean} Returns false, if Redirect is not necessary.
     * @param {Object} XHRObject - The original AJAX object.
     * @description
     *      Checks if session is timed out and redirects to the login to avoid
     *      ajax errors.
     */
     function RedirectAfterSessionTimeOut(XHRObject) {
        var Headers = XHRObject.getAllResponseHeaders(),
            OldUrl = location.href,
            NewUrl = Core.Config.Get('Baselink') + "RequestedURL=" + encodeURIComponent(OldUrl);

        if (Headers.match(/X-OTRS-Login: /i)) {
            location.href = NewUrl;
            return true;
        }

        return false;
    }

    /**
     * @private
     * @name GetSessionInformation
     * @memberof Core.AJAX
     * @function
     * @returns {Object} Hash with session data, if needed.
     * @description
     *      Collects session data in a hash if available.
     */
     function GetSessionInformation() {
        var Data = {};
        if (!Core.Config.Get('SessionIDCookie')) {
            Data[Core.Config.Get('SessionName')] = Core.Config.Get('SessionID');
            Data[Core.Config.Get('CustomerPanelSessionName')] = Core.Config.Get('SessionID');
        }
        Data.ChallengeToken = Core.Config.Get('ChallengeToken');
        return Data;
    }

    return TargetNS;
}(Core.Agent.ShowHideField || {}));