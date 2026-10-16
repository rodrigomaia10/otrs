// --
// var/httpd/htdocs/js/Core.DynamicFieldTable.js - a module used to handle ajax requests
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dsilva@serviceup.com.br
// * mbernardo@serviceup.com.br
// * nfreitas@serviceup.com.br
// * jsantos@serviceup.com.br
// * lcavalheiro@serviceup.com.br
// * ykanegae@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.UI.Popup.GetWindowParentObject = Core.UI.Popup.GetWindowParentObject || {};

/**
 * @namespace Core.DynamicFieldTable
 * @memberof Core
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the DynamicFieldTable module.
 */

Core.DynamicFieldTable = (function (TargetNS) {

    /**
    * @name Init
    * @memberof Core.DynamicFieldTable
    * @function
    * @returns {Boolean} Returns false
    * @param {String} Caption
    * @param {String} Columns
    * @param {String} JSONMaskMoney
    * @param {String} JSONMask
    * @param {String} OperationColumn    
    * @param {String} OperationColJSON
    * @param {String} PossSumRowJSON
    * @param {String} PossibleRowSum
    * @description
    *      This function add a new value to the possible values list
    */  
    TargetNS.Init = function (Caption, Columns, JSONMaskMoney, JSONMask, OperationColumn, OperationColJSON, OperationFormula, PossibleRowSum, PossSumRowJSON, LabelOperation, Operation, Sort) {

        var Mandatory = GetURLParameter('Mandatory');

        if (parseInt(Sort)) {
            Columns.forEach(function(Column, i){
                if (Column.type == 'select') {
                    Columns[i].ctrlOptions = Object.values(Column.ctrlOptions).sort();
                }
            });
        }

        // bind autocomplete box
        let AutoCompleteColumnName = '';
        Columns.forEach(function(column, index){
            if(column.autocomplete_delay) {
                AutoCompleteColumnName = Columns[index].name;

                Columns[index].type = 'ui-autocomplete';
                Columns[index].uiOption = {
                    source: GetSearch,
                    delay: column.autocomplete_delay
                }
            }
        });

        // bind computed columns
        const regex = /\${([^}]*)}/g;
        let ComputedColumns = [];
        Columns.forEach(function(column, index){
            if(column.type == 'computed') {
                const ComputedColumn = { DependencyColumns: [], Formula: column.value, Target: column.name };
                
                let match;
                while ((match = regex.exec(column.value)) !== null) {
                    ComputedColumn.DependencyColumns.push(match[1]);
                }
                
                Columns[index].value = "0";
                Columns[index].type  = "number";

                ComputedColumns.push(ComputedColumn);
            }
        });

        var Operations = {
            Sum: '+',            
            Subtraction: '-',
            Multiplication: '*',
            Division: '/',
            Formula: 'fx'
        };

        const OperationRow = Operations[OperationColumn];

        let sumcolumns = false;
        if(OperationRow !== undefined){
            sumcolumns = true;
        }

		// Initialize appendGrid
        $('#tblAppendGrid').appendGrid({
            caption: Caption,
            initRows: 1,
            columns: Columns,
            sumcolumns: sumcolumns,
            sumrows: PossibleRowSum, 
			operation: LabelOperation,
            afterRowAppended: function (caller, parentRowIndex, addedRowIndex) {
				CheckDateInput();
                CheckDateTimeInput();
                $.each(JSONMask, function(key, val) {

                    var Element = $(caller).appendGrid('getCellCtrl', key, addedRowIndex);

                    $($(Element)).blur(function(){
                        var id = '#' + $(Element).attr("id");
                        var value = $(Element).val();
                      
                        MaskValidate(id, value, $(Element).attr("maxlength"));
                    });
    
                    $(Element).mask(val);
                });

                $.each(JSONMaskMoney, function(key, val) {
                    var Element = $(caller).appendGrid('getCellCtrl', key, addedRowIndex);
                    var AllowNegative = 0;

                    if (val.Negative == 'true'){
                        AllowNegative = 1;
                    }
                    $(Element).maskMoney({decimal:",", thousands:".", prefix: val.Prefix + " ", allowNegative: AllowNegative});
                });

                if(PossSumRowJSON){

                    if ( JSONMaskMoney ) {
                        let Prefix = "";
                        let Negative = false;
                        
                        for (let indexColumn in PossSumRowJSON) {
                            if( JSONMaskMoney[PossSumRowJSON[indexColumn]] != undefined) { 
                                Prefix = JSONMaskMoney[PossSumRowJSON[indexColumn]].Prefix;
                                Negative = JSONMaskMoney[PossSumRowJSON[indexColumn]].Negative;
                            }                           
                        }
                        JSONMaskMoney.RowTotal = {
                            Prefix: Prefix,
                            Negative: Negative
                        };                      
                    }  
                    
                    $.each(PossSumRowJSON, function(index, col) {
                        var Element = $('#tblAppendGrid').appendGrid('getCellCtrl', col, addedRowIndex);
                        $(Element).bind('keyup mouseup', function(){
                            CalculateRowOperation(PossSumRowJSON, OperationRow, OperationFormula, JSONMaskMoney);
                            CalculateSum('RowTotal', JSONMaskMoney['RowTotal'].Prefix);
                        });
                    });           
                }

                if (OperationColJSON) {
                    $.each(OperationColJSON, function(index, col) {
                        var Element = $(caller).appendGrid('getCellCtrl', col, addedRowIndex);
                        $(Element).bind('keyup mouseup', function(){
                            var prefix;
                            if (JSONMaskMoney[col]){
                                prefix = JSONMaskMoney[col].Prefix;
                            }
                            else{
                                prefix = col;
                            }
                            CalculateSum(col, prefix);
							
							if ( Operation != 'undefined' ){
								CalculateOperation(Operation, LabelOperation);
							}
                        });
                    });
                }

                if(AutoCompleteColumnName !== '')
                    $(`input[id^='tblAppendGrid_${AutoCompleteColumnName}'`).autocomplete({
                        select: HandleAutoCompleteOptionSelect
                    });

                ComputedColumns.forEach( (ComputedColumn) => {

                    let Selectors = ComputedColumn.DependencyColumns.map( 
                        (ColumnName) => `input[id^='tblAppendGrid_${ColumnName}']`
                    );

                    $(Selectors.join(', ')).change( function() {
                        
                        const 
                            targetName          = this.id,
                            targetNameParts     = targetName.split('_'),
                            selectorPrefix      = targetNameParts[0],
                            selectorSulfix      = targetNameParts[targetNameParts.length - 1];

                        // compute value
                        let formula = ComputedColumn.Formula;
                        ComputedColumn.DependencyColumns.forEach( (columnName) => {
                            const columnValue = $(`input[id='${selectorPrefix}_${columnName}_${selectorSulfix}']`).val();

                            formula = formula.replace("${" + columnName + "}", columnValue);
                        });

                        let ComputedValue = 0.00;
                        try {
                            ComputedValue = parseFloat(eval(formula)).toFixed(2);
                        } catch(e) { console.error(e); }

                        $(`input[id='${selectorPrefix}_${ComputedColumn.Target}_${selectorSulfix}']`).val(ComputedValue);
                        $(`input[id='${selectorPrefix}_${ComputedColumn.Target}_${selectorSulfix}']`).trigger('change');
                    });
                });
            },

            afterRowInserted: function (caller, parentRowIndex, addedRowIndex) {
				CheckDateInput();
                CheckDateTimeInput();
                $.each(JSONMask, function(key, val) {
                    var Element = $(caller).appendGrid('getCellCtrl', key, addedRowIndex);
                    $(Element).mask(val);
                });

                $.each(JSONMaskMoney, function(key, val) {
                    var Element = $(caller).appendGrid('getCellCtrl', key, addedRowIndex);
                    var AllowNegative = 0;

                    if (val.Negative == 'true'){
                        AllowNegative = 1;
                    }

                    $(Element).maskMoney({decimal:",", thousands:".", prefix: val.Prefix + " ", allowNegative: AllowNegative});
                });

                
                if ( PossSumRowJSON ) {

                    if ( JSONMaskMoney ) {

                        let Prefix = "";
                        let Negative = false;
                        
                        for (let indexColumn in PossSumRowJSON) {
                            if( JSONMaskMoney[PossSumRowJSON[indexColumn]] != undefined) { 
                                Prefix = JSONMaskMoney[PossSumRowJSON[indexColumn]].Prefix;
                                Negative = JSONMaskMoney[PossSumRowJSON[indexColumn]].Negative;
                            }                           
                        }
                        JSONMaskMoney.RowTotal = {
                            Prefix: Prefix,
                            Negative: Negative
                        };
                    }  
                    
                    $.each(PossSumRowJSON, function(index, col) {
                        var Element = $('#tblAppendGrid').appendGrid('getCellCtrl', col, addedRowIndex);
                        $(Element).bind('keyup mouseup', function(){
                            CalculateRowOperation(PossSumRowJSON, OperationRow, OperationFormula, JSONMaskMoney);
                            CalculateSum('RowTotal', JSONMaskMoney['RowTotal'].Prefix);
                        });
                    });           
                }

                if  (OperationColJSON){
                    $.each(OperationColJSON, function(index, col) {
                        var Element = $(caller).appendGrid('getCellCtrl', col, addedRowIndex);
                        $(Element).bind('keyup mouseup', function(){
                            var prefix;
                            if (JSONMaskMoney[col]){
                                prefix = JSONMaskMoney[col].Prefix;
                            }
                            else{
                                prefix = col;
                            }
                            CalculateSum(col, prefix);
							
							if ( Operation != 'undefined' ){
								CalculateOperation(Operation, LabelOperation);
							}
                        });
                    });
                }
            },

            afterRowRemoved: function () {
                if ( PossSumRowJSON ) {

                    if ( JSONMaskMoney ) {

                        let Prefix = "";
                        let Negative = false;
                        
                        for (let indexColumn in PossSumRowJSON) {
                            if( JSONMaskMoney[PossSumRowJSON[indexColumn]] != undefined) { 
                                Prefix = JSONMaskMoney[PossSumRowJSON[indexColumn]].Prefix;
                                Negative = JSONMaskMoney[PossSumRowJSON[indexColumn]].Negative;
                            }                           
                        }
                        JSONMaskMoney.RowTotal = {
                            Prefix: Prefix,
                            Negative: Negative
                        };                        
                    }                    
                    
                    $.each(PossSumRowJSON, function(index, col) {
                        CalculateRowOperation(PossSumRowJSON, OperationRow, OperationFormula, JSONMaskMoney);
                    });
                    CalculateSum('RowTotal', JSONMaskMoney['RowTotal'].Prefix);     
                }

                if  (OperationColJSON){
                    $.each(OperationColJSON, function(index, col) {
                        var prefix;
                        if (JSONMaskMoney[col]){
                            prefix = JSONMaskMoney[col].Prefix;
                        }
                        else{
                            prefix = col;
                        }
                        CalculateSum(col, prefix);
						
						if ( Operation != 'undefined' ){
							CalculateOperation(Operation, LabelOperation);
						}
                    });
                }
            },

            customFooterButtons:[{
                uiButton: { icons: { primary: 'ui-icon-arrowthickstop-1-s' }, text: false  },
                btnAttr: { title: 'Download Data', style: 'display: none', id:'export' },
                click: function () {
                    Core.DynamicFieldTable.Export(Caption);
                }
            }],

            dataLoaded: function (){
                if ($('#tblAppendGrid').appendGrid('isDataLoaded')) {
                    $("#export").show();
                }
            }
        });



        $('#Save').click(function() {

            if (Mandatory == "") {
                Core.DynamicFieldTable.SaveData(OperationColJSON, PossSumRowJSON);
            }
            else{
                var Empty = 0;
    
                var data = $('#tblAppendGrid').appendGrid('getAllValue');
        
                $.each( data, function( key, value ) {
        
                    $.each( value, function( key2, value2 ) {
        
                        if (value2 == "") {
                            Empty = 1;
                        }
                    });
                });
        
                if (Empty == 1) {
                    swal(Core.Language.Translate("Attention!"), Core.Language.Translate("All fields in the table must be completed!"));
                }
                else{
                    Core.DynamicFieldTable.SaveData(OperationColJSON, PossSumRowJSON);
                }
            }
        });

        return false;
    };

    /**
    * @name LoadData
    * @memberof Core.DynamicFieldTable
    * @function
    * @returns {Boolean} Returns false
    * @param {String} JSONValueLoaded
    * @param {String} JSONMaskMoney
    * @param {String} JSONMask
    * @param {String} OperationColumn
    * @param {String} OperationColJSON
    * @param {String} PossSumRowJSON
    * @param {String} LabelOperation
    * @param {String} Operation
    * @description
    *      This function load data to the table
    */
    TargetNS.LoadData = function (JSONValueLoaded, JSONMaskMoney, JSONMask, OperationColumn, OperationColJSON, OperationFormula, PossSumRowJSON, LabelOperation, Operation) {
        var count, i;
        var regEx = /^\d{2}\/\d{2}\/\d{4}$/;

		//Check if date is on br format
		$.each(JSONValueLoaded, function(key, val) {
			$.each(val, function(column, value) {
				if(value.match(regEx)){
					var date = value.split('/');
					JSONValueLoaded[key][column] = date[2] + '-' + date[1] + '-' + date[0];
				}
			});
        });

        // initial compute of value
        JSONValueLoaded.forEach( (rowValue) => {
            Object.keys(rowValue).forEach( (key) => {
                
                if(rowValue[key].includes("${")){
                    
                    let formula = rowValue[key];
                    Object.keys(rowValue).forEach( (key2) => {
                        
                        formula = formula.replace("${" + key2 + "}", rowValue[key2]);
                    });

                    let ComputedValue;
                    try {
                        ComputedValue = parseFloat(eval(formula)).toFixed(2);
                    } catch(e) { console.error(e) }

                    rowValue[key] = ComputedValue;
                }
            })
        });

        var Operations = {
            Sum: '+',            
            Subtraction: '-',
            Multiplication: '*',
            Division: '/',
            Formula: 'fx'
        };

        const OperationRow = Operations[OperationColumn];
        
        if(OperationColJSON){
            var Last = JSONValueLoaded.length - 1;
            JSONValueLoaded.splice(Last, 1);
        }
		
        // Initialize appendGrid with data
        $('#tblAppendGrid').appendGrid('load', JSONValueLoaded);
		
		count =  $('#tblAppendGrid').appendGrid('getRowCount');

        for (i = 0; i < count; i++){

            //Set mask on table load
            $.each(JSONMask, function(key, val) {
                var Element = $('#tblAppendGrid').appendGrid('getCellCtrl', key, i);

                $(Element).mask(val);             
            });

            //Set money mask on table load
            $.each(JSONMaskMoney, function(key, val) {
                var Element = $('#tblAppendGrid').appendGrid('getCellCtrl', key, i);

                $(Element).maskMoney({decimal:",", thousands:".", prefix: val.Prefix + " ", allowNegative: val.Negative});
            });

            // call sum function onchange
            if ( OperationColJSON ) {
                $.each(OperationColJSON, function(index, col) {
                    var Element = $('#tblAppendGrid').appendGrid('getCellCtrl', col, i);

                    $(Element).bind('keyup mouseup', function(){
                        var prefix;
                        if (JSONMaskMoney[col]){
                            prefix = JSONMaskMoney[col].Prefix;
                        }
                        else{
                            prefix = col;
                        }
                        CalculateSum(col, prefix);
						
						if ( Operation != 'undefined' ){
							CalculateOperation(Operation, LabelOperation);
						}
                    });
                });
            }

            if ( PossSumRowJSON ) {

                if ( JSONMaskMoney ) {

                    let Prefix = "";
                    let Negative = false;
                        
                    for (let indexColumn in PossSumRowJSON) {
                        if( JSONMaskMoney[PossSumRowJSON[indexColumn]] != undefined) { 
                            Prefix = JSONMaskMoney[PossSumRowJSON[indexColumn]].Prefix;
                            Negative = JSONMaskMoney[PossSumRowJSON[indexColumn]].Negative;
                        }                           
                    }
                    JSONMaskMoney.RowTotal = {
                        Prefix: Prefix,
                        Negative: Negative
                    };                    
                }  

                $.each(PossSumRowJSON, function(index, col) {

                    var Element = $('#tblAppendGrid').appendGrid('getCellCtrl', col, i);

                    $(Element).bind('keyup mouseup', function(){
                        CalculateRowOperation(PossSumRowJSON, OperationRow, OperationFormula, JSONMaskMoney);
                        CalculateSum('RowTotal', JSONMaskMoney['RowTotal'].Prefix);
                    });
                });                
            }
        }

        //Show labels onload
        if ( PossSumRowJSON ) {            

            if ( JSONMaskMoney ) {

                let Prefix = "";
                let Negative = false;
                
                for (let indexColumn in PossSumRowJSON) {
                    if( JSONMaskMoney[PossSumRowJSON[indexColumn]] != undefined) { 
                        Prefix = JSONMaskMoney[PossSumRowJSON[indexColumn]].Prefix;
                        Negative = JSONMaskMoney[PossSumRowJSON[indexColumn]].Negative;
                    }                           
                }
                JSONMaskMoney.RowTotal = {
                    Prefix: Prefix,
                    Negative: Negative
                };
            }  

            $.each(PossSumRowJSON, function(index, col) {
                CalculateRowOperation(PossSumRowJSON, OperationRow, OperationFormula, JSONMaskMoney);
            });
            CalculateSum('RowTotal', JSONMaskMoney['RowTotal'].Prefix);
        }

        //Show labels onload
        if (OperationColJSON){

            $.each(OperationColJSON, function(index, col) {

                var prefix;

                if (JSONMaskMoney[col]){
                    prefix = JSONMaskMoney[col].Prefix;
                }
                else{
                    prefix = col;
                }

                CalculateSum(col, prefix);
				CalculateOperation(Operation, LabelOperation);
            });
        }
		
        return false;
    };

    /**
    * @name SaveData
    * @memberof Core.DynamicFieldTable
    * @function
    * @returns {Boolean} Returns false
    * @description
    *      This function save data of the table
    */
    TargetNS.SaveData = function (OperationColJSON, PossSumRowJSON) {

        var AllValue = $('#tblAppendGrid').appendGrid('getAllValue'),
            $DocParent = window.opener;      

        if(PossSumRowJSON){      

            var RowCount = $('#tblAppendGrid').appendGrid('getRowCount');

            for (i = 0; i < RowCount; i++){
                AllValue[i].RowTotal = $('#tblAppendGrid_RowTotal_' + (i+1)).val();                
            }
        }
        
        if(OperationColJSON){

            var ColumnCount = $('#tblAppendGrid').appendGrid('getColumns').length;

            var TotalCollumns = new Object();
            var Columns = $('#tblAppendGrid').appendGrid('getColumns');
            
            $.each(OperationColJSON, function(index, col) {
                TotalCollumns[col] = $('#Sum_' + col).find( "strong" ).text();
            });
            
            if(PossSumRowJSON){      
                TotalCollumns.RowTotal = $('#Sum_RowTotal').find( "strong" ).text();
            }

            AllValue.push(TotalCollumns);
        }

        var Data = {
            Action: 'DynamicFieldTableRender',
            Subaction: 'SaveData',
            FormID:  $('#FormID').val(),
            TicketID:  $('#TicketID').val(),
            ContractID:  $('#ContractID').val(),
            FieldID: $('#FieldID').val(),
            JSON: JSON.stringify(AllValue),
        };

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {

            var value;

            if (!Result) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data saved on database.", 'CommunicationError'));
            }
            else {

                // TODO
                Core.UI.Popup.ClosePopup();
                var $UpdateForm = $('form', $DocParent.document);

                // To set mandatory in the label
                window.opener.$("#DynamicField_"+$('#FieldName').val()).val('1');
                
                if (Result != 'Data Saved.' || Result != 'Data not Saved.'){
                 
					if ( Result.ColumnsSum ){
						SumColumns = JSON.parse(Result.ColumnsSum);
						$.each(SumColumns, function(col, df) {
							col = col.replace(/\ /g, "");
							value = $("#Sum_" + col).text();
							value = value.replace(/[^0-9,]/g, '');
							value = value.replace(",",".");
							$UpdateForm
								.find('#' + df).val(value)
								.end();
						});
                    }
                    
					if ( Result.OperationConfig ){
						var df = Result.OperationConfig;                        
						var valueOperation = $("#OperationRow_value").text();
						valueOperation = valueOperation.replace(/[^0-9,]/g, '');
						valueOperation = valueOperation.replace(",",".");
						
						$UpdateForm.find('#DynamicField_' + df).val(valueOperation).end();				
					}				
					
                    if (typeof opener.TableTrigger == 'function'){
                        opener.TableTrigger();
                    }
                }
            }
        });

        return false;
    };

    /**
    * @name CalculateSum
    * @memberof Core.DynamicFieldTable
    * @function
    * @returns {Boolean} Returns false
    * @param {String} col
    * @param {String} prefix
    * @description
    *      This function calc the sum of columns table
    */
    function CalculateSum(col, prefix){

        var sum = 0, value, colid;

        var rows =  $('#tblAppendGrid').appendGrid('getRowOrder');

        for (var j = 0; j < rows.length; j++){

            var i = rows[j];

            if(col === 'RowTotal'){
                value = $("#tblAppendGrid_RowTotal_" + i).val();                
            }
            else{
                value = $('#tblAppendGrid').appendGrid('getCtrlValue', col, j);
            }           

            if (prefix != col){
                value = value.replace(prefix + " ", '');
                value = value.replace(/\./g, '');
                value = value.replace(",", '.');
            }

            if (value == ''){
                value = 0;
            }

            sum = parseFloat(sum) + parseFloat(value);
        }

        //Check if is money field or number field
        if (prefix != col){

            sum = sum.toFixed(2);
            sum = sum.replace(".", ',');
            sum = prefix + ' ' + sum.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1.");
        }
        else{

            if (!(sum % 1 === 0)){
                sum = sum.toFixed(2);
                sum = sum.replace(".", ',');
            }
        }
		
        colid = col.replace(/\ /g, "");

        $("#Sum_" + colid).html(function(){
            return '<h3 style="font-family: sans-serif"><strong>' + sum + '</strong></h3>'
        });

        return false;
    }

    /**
    * @name CalculateRowOperation
    * @memberof Core.DynamicFieldTable
    * @function
    * @returns {Boolean} Returns false
    * @param {String} col
    * @param {String} prefix
    * @description
    *      This function calc the sum of columns table
    */
    function CalculateRowOperation(RowJSON, Operation, OperationFormula, JSONMaskMoney) {
        
        var rows =  $('#tblAppendGrid').appendGrid('getRowOrder');

        const tagPattern = /<([^>]+)>/g;

        for (var j = 0; j < rows.length; j++){

            var i = rows[j];

            var total, totalFormula = 0;

            if (Operation == 'fx'){    
                totalFormula = OperationFormula
            }

            var RowPrefix;

            let CollumnValues = [];
            let CollumnNames = [];

            $.each(RowJSON, function(index, col) {

                var prefix;

                if (JSONMaskMoney[col]){
                    prefix = JSONMaskMoney[col].Prefix;
                }
                else{
                    prefix = col;
                }

                let value = $('#tblAppendGrid').appendGrid('getCtrlValue', col, j);                
                        
                if (prefix != col){
                    value = value.replace(prefix + ' ', '');
                    value = value.replace(/\./g, '');
                    value = value.replace(",", '.');
                    RowPrefix = prefix;
                }
        
                if (value == ''){
                    value = 0;
                }

                CollumnValues[index] = parseFloat(value);
                CollumnNames[index] = col;

                if ( Operation == 'fx') {
                    // Function to replace tags with values
                    function replaceTagsWithValues(match, tag) {
                        return CollumnNames[index] === tag ? CollumnValues[index] : match;
                    }
                    
                    // Replace tags in the input string with values
                    totalFormula = totalFormula.replace(tagPattern, replaceTagsWithValues);
                   
                    const regex = /^(?![\s\S]*[<>])/;
                    
                    if (regex.test(totalFormula)) {
                        total = eval(totalFormula)
                    }                    
                }
                else {
                    total = CollumnValues.reduce(function(accumulator, currentValue) {                     
                        let expression = accumulator + Operation + currentValue;
                        return eval(expression)
                    });
                }          

                if ( index + 1 == RowJSON.length ) {

                    prefix = RowPrefix;

                    //Check if is money field or number field
                    if ( prefix != col ) {

                        if ( prefix == undefined ) {
                            total = total.toFixed(2);
                            total = total.replace(".", ',');
                            total = ' ' + ' ' + total.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1.");
                        }
                        else {
                            total = total.toFixed(2);
                            total = total.replace(".", ',');
                            total = prefix + ' ' + total.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1.");
                        }
                    }
                    else {

                        if (!(total % 1 === 0)){
                            total = total.toFixed(2);
                            total = total.replace(".", ',');
                        }
                    }
                }
            });                   
                
            $("#tblAppendGrid_RowTotal_" + i).val(total);
        } 
    }    

    /**
    * @name CalculateOperation
    * @memberof Core.DynamicFieldTable
    * @function
    * @returns {Boolean} Returns false
    * @param {String} Operation
    * @param {String} LabelOperation
    * @description
    *      This function export data table
    */	
	function CalculateOperation(Operation, LabelOperation){

        var Regex=/<([^>]*)>/g, M, Tags=[];
        
		if ( Operation == 'undefined' ){
            return;
        }

		//Get the columns in the tags
		while(M=Regex.exec(Operation)){
		    Tags.push(M[1]);
		}
		
		//Get the each column total and replace on the configurated operation
		$.each(Tags, function(i, col) {

			var ResultCol = "#Sum_" + col.replace(/\ /g, "");
            var Total = $(ResultCol).text();
			
			Total = Total.replace(/[^0-9,]/g, '');
			Total = Total.replace(/\./g, '');
            Total = Total.replace(",", '.');
			
			if ( Total == '' ){
				Total = 0;
			}
			
			Operation = Operation.replace("<"+ col +">", "(" + parseFloat(Total) + ")");
		});
        
		//Do the math operation
		var Result = eval(Operation);		
		
		if (!(Result % 1 === 0)){

            Result = Result.toFixed(2);
			Result = Result.replace(".", ',');
        }
		
		$("#OperationRow_value").html(function(){
            return '<h4 style="font-family: sans-serif"><strong>' + Result + '</strong></h4>'
        });

		return false;
	}

    /**
    * @name Export
    * @memberof Core.DynamicFieldTable
    * @function
    * @returns {Boolean} Returns false
    * @param {String} Caption
    * @description
    *      This function export data table
    */
    TargetNS.Export = function (Caption) {

        var TableData = $('#tblAppendGrid').appendGrid('getAllValue'),
            JSONSum = new Object(),
            JSONOperation = new Object(),
            JSONSumData = '{}',
            JSONOperationData = '{}',
            Col,
            colid,
            value;
			
		$("#AJAXLoaderExport").show();

        if ($("#Format").val() == '') {

            $("#FormatError").show();

            return 0;
        }
        else {
            $("#FormatError").hide();
        }

        if ($("#SumRow").length){

            Col = $('#tblAppendGrid').appendGrid('getColumns');

            $.each(Col, function(key, val){

                let name = val.name;
				
				colid = name.replace(/\s+/g, "");
                colid = colid.replace(/\//g, "");
                value = $("#Sum_" + colid).text();

                JSONSum[val.name] = value;
            });

            if ($("#Sum_RowTotal").length){
                JSONSum['RowTotal'] = $('#Sum_RowTotal').find( "strong" ).text();
            }

            JSONSumData = JSON.stringify(JSONSum);
        }

        if ($("#Sum_RowTotal").length){

            var RowCount    =  $('#tblAppendGrid').appendGrid('getRowCount');

            for (i = 0; i < RowCount; i++){
                TableData[i].RowTotal = $('#_RowTotal_' + (i+1)).val();
            }
        }
		
		if ( $("#OperationRow").length ){

			var Label = $("#OperationRow_label").text();
			
			Label = Label.replace(":","");
			
            var Value = $("#OperationRow_value").text();
            
			JSONOperation[Label] = Value;
			JSONOperationData = JSON.stringify(JSONOperation);
        }
        
        var DataJSON = JSON.stringify(TableData);

		var Data = {
            Action: 'DynamicFieldTableRender',
            Subaction: 'CacheData',
            FormID: $('#FormID').val(),
            TicketID: $('#TicketID').val(),
            FieldID: $('#FieldID').val(),
            JSON: DataJSON,
            JSONSum: JSONSumData,
            JSONOperation: JSONOperationData,
        };
		
		Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {

            if (!Result) {
                // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data saved on database.", 'CommunicationError'));
            }
            else{
                // TODO
				$("#AJAXLoaderExport").hide();
				window.location.href = window.location.href +
				';Subaction=ExportData;Caption=' + Caption + ';Format=' + $("#Format").val() + ';TicketID=' + $("#TicketID").val() + ';FieldID=' +  $("#FieldID").val();
        
				return;
			}
        });		
    };

    function MaskValidate(id, value, size){

        var prop = "Telefone";

        if(size == 10){
            prop = "CEP";
        }
        else if (size == 18){
            prop = "CNPJ";
        }
        else if (size == 14){
            prop = "CPF";
        }
        
        var idMessage = "MessageWarn" + prop;

        if(value.length < size){

            if($('#'+idMessage).html() == undefined){
                $("#TitleDynamicField").append( "<h3 id="+idMessage+">Número de caracteres do " + prop + " incorreto!</h3>" );
            }

            $("#Save").prop("disabled", true);
            $(id).css("color", "red");
            $(idMessage).css("color", "red");
        }
        else{

            $('#'+idMessage).addClass("Hidden");   
            $("#Save").prop("disabled", false);
            $(id).css("color", "black");         
        }
    }
	
	function CheckDateInput(){

		//#Bug - Check if input date is not supported by browser, then create jquery datepicker		
		var notADateValue = 'not-a-date';
		
		$('#tblAppendGrid input[type=date]').each(function(){  

            $( $(this)).blur(function(){

                var id = "#" + $(this).attr('id');
                var valueDate =$(this).val();

                if(valueDate == ""){
                    alert("Data inválida!")
                    $("#Save").prop("disabled", true);
                    $(id).css("color", "red");
                }
                else{
                    $("#Save").prop("disabled", false);
                    $(id).css("color", "black");
                }
            });

            $(this).attr('value', notADateValue);
            
			if ( $(this).val() == notADateValue ){

				$(this).attr('value', '');
                $(this).attr('placeholder', 'dd/mm/aaaa');
                
				$(this).datepicker({
					// Consistent format with the HTML5 picker
						dateFormat : 'dd/mm/yyyy'
					},
					// Localization
					$.datepicker.regional['br']
				);
			}
		});
    }

    function CheckDateTimeInput(){

		//#Bug - Check if input date is not supported by browser, then create jquery datepicker		
		var notADateValue = 'not-a-date';
		
		$('#tblAppendGrid input[type=datetime-local]').each(function(){  

            $( $(this)).blur(function(){

                var id = "#" + $(this).attr('id');
                var valueDate =$(this).val();

                if(valueDate == ""){
                    alert("Data inválida!")
                    $("#Save").prop("disabled", true);
                    $(id).css("color", "red");
                }
                else{
                    $("#Save").prop("disabled", false);
                    $(id).css("color", "black");
                }
            });

            $(this).attr('value', notADateValue);
            
			if ( $(this).val() == notADateValue ){

				$(this).attr('value', '');
                $(this).attr('placeholder', 'dd/mm/aaaa');
                
				$(this).datepicker({
					// Consistent format with the HTML5 picker
                        displayFormat : 'dd/mm/yyyy'
					},
					// Localization
					$.datepicker.regional['br']
				);
			}
		});
    }

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

    function GetSearch(request, response) {

        const Data = {
            Action: 'DynamicFieldTableRender',
            Subaction: 'AutoComplete',

            FieldID: GetURLParameter('FieldID'),
            SearchTerm: request.term
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'), Data, function (data) {
                response(data);
            }
        );
    }

    function HandleAutoCompleteOptionSelect(event, ui){

        // prevent event to set value for column
        event.preventDefault();

        // get value from event
        const { label, value } = ui.item;
        
        // get info for selectors
        const 
            targetName          = event.target.name,
            targetNameParts     = targetName.split('_'),
            selectorPrefix      = targetNameParts[0],
            selectorSulfix      = targetNameParts[targetNameParts.length - 1];

        // set value for each key in values
        Object.keys(value).forEach(columnName => {

            $(`input[id='${selectorPrefix}_${columnName}_${selectorSulfix}']`).val(value[columnName]);
        });
    }
    
    return TargetNS;
}(Core.DynamicFieldTable || {}));
