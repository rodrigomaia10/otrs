// --
// var/httpd/htdocs/js/Core.Agent.Admin.KPIChartSQLQuery.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dparavani@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.KPIChartSQLQuery
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the KPI module.
 */
Core.Agent.Admin.KPIChartSQLQuery = (function (TargetNS) {


  /**
     * @name Init
     * @memberof Core.Agent.Admin.KPIChartSQLQuery
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        var mime = 'text/x-mariadb';
        var  myCodeMirror  =  CodeMirror.fromTextArea(document.getElementById("SQL"), {
            lineNumbers: true,
            mode: mime,
            indentWithTabs: true,
            smartIndent: true,
            lineNumbers: true,
            matchBrackets : true,
            autofocus: true,
            theme: 'eclipse'
        });

        myCodeMirror.on("keyup", function (cm, event) {            
            $('#SQL').val( myCodeMirror.getValue() )
        });

        $('#RunSqlQuery').on('click', function (Event) {

            var Data = {
                "Action":"AdminKPIChartSQLQuery",
                "Subaction":"QueryExecute",
                "SQL":  myCodeMirror.getValue(),
                "Chart": $('#ReturnChart').val(),           
            };

            $('.AddedSQLResult').html("");
            
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
                
                if (!Response) {
                      // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{                  
                    if(Response.Error == 1){
                        $('.KPISQLErrorDiv').html("");
                        $('.KPISQLErrorDiv').removeClass();
                        $('#SubmitKpiQuery').attr('disabled', 'disabled');
                        $('#ViewChart').hide();
                        $('#chart').html("");
                        $('#ToolBar').after(Response.Template);

                    }else{
                        $('.AddedSQLResult').append(Response.Template);
                        $('#SubmitKpiQuery').removeAttr('disabled');
                        $('#ViewChart').show();
                        $('.KPISQLErrorDiv').remove();
                    }
                }
            });

        });

        $('#ViewChart').on('click', function() {

            var Data = {
                "Action":"AdminKPIChartSQLQuery",
                "Subaction":"QueryExecute",
                "SQL":  myCodeMirror.getValue(),
                "Chart": $('#ReturnChart').val(),           
            };

            $('#chart').html("");

            var chart;

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {

                if (!Response) {
                    // We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
                }
                else{
                    if ( Response.ChartData.Error ) {
                        $('.AddedSQLResult').html("");
                        $('.AddedSQLResult').append(Response.Template);
                        $('#ViewChart').hide();

                    }
                    else {
                        $('.AddedSQLResult').html("");
                        $('.AddedSQLResult').append(Response.Template);
                      
                        let labels;
                        if ( $('#DisplayTextChart').val() === 'Percentage' ) {
                            labels = {
                                format: function (v, id, i, j) { return v + '%'; }
                            }
                        }
                        else {
                            labels = true;
                        }
                        
                        chart = c3.generate({
                            data: {
                                x: Response.ChartData.X,
                                columns: Response.ChartData.Columns,
                                type : Response.ChartData.Type,
                                labels: labels,
                                groups: Response.ChartData.Groups
                            },
                            pie: {
                                label: {
                                    format: function (value, ratio, id) {
                                        return value;
                                    }
                                }
                            },
                            axis: {
                                rotated: Response.ChartData.Rotated,
                                x: {
                                    type: 'category',
                                    tick: {
                                        // rotate: 25,
                                        multiline: Response.ChartData.Rotated ? false : true,
                                        format: function (d) {
                                            var catName = this.api.categories()[d];
                                            
                                            if (catName && catName.length > 50) {
                                                tamanho = catName.length - 50;
                                                catName = "…"+catName.slice(tamanho,catName.length);
                                            }
                                            return catName;
                                        }
                                    },
                                },
                            },
                            padding: {
                                bottom: 20
                            },
                            color: {
                                pattern: ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5']
                            },
                            onrendered: function () {
                                var self = this;
                                d3.select(this.config.bindto)
                                    .selectAll(".c3-axis-x .tick text")
                                    .each(function (d) {
                                        var title = d3.select(this).select("title");
                                        if (title.empty()) {
                                            title = d3.select(this).append("title");
                                        }
                                        title.text (self.api.categories()[d]);
                                    })
                                ;
                            } 
                        });

                        chart.data.shown();
                        chart.resize();
                    }
                }
            });
            
        });

        if($('#ReturnFormat').val() == 'Link'){
            $('#LabelToLink').show();
            $('#Link').show();
        }else{
            $('#LabelToLink').hide();
            $('#Link').hide();
        }

        $('#ReturnFormat').change(function() {
          
            if($('#ReturnFormat').val() == 'Link'){
                $('#LabelToLink').show();
                $('#Link').show();
            }else{
                $('#LabelToLink').hide();
                $('#Link').hide();
                $('#Link').val('');
            }
        });

        // $("textarea").each(function () {
        //     this.setAttribute("style", "height:" + (this.scrollHeight) + "px;overflow-y:hidden;");
        // }).on("input", function () {
        //     this.style.height = "auto";
        //     this.style.height = (this.scrollHeight) + "px";
        // });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.KPISQLQuery || {}));
