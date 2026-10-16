// --
// var/http/htdocs/js/Core.Customer.CustomerPortalDashboard.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var currentURL = window.location.href ;
var currentURL = currentURL.split("Subaction=");


var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Customer.CustomerPortalDashboard
 * @memberof Core.Customer
 * @author OTRS AG
 * @description
 *      This namespace contains the special function for CustomerPortal module.
 */
Core.Customer.CustomerPortalDashboard = (function (TargetNS) {

    /**
    * @name Init
    * @memberof Core.Customer.CustomerPortalDashboard
    * @function
    * @description
    *      This function initializes the module functionality.
    */
    TargetNS.Init = function () {

        if (GetURLParameter('BulkStatus') == 1) {
            showPopupAlert();
        }

        var DataChartSearch = Core.Config.Get('DataChartSearch');
        var DataChart = Core.Config.Get('DataChart');

        if ( DataChartSearch && DataChartSearch.length > 0 ) {


            for (var key in DataChartSearch) {
                var JSONChart = JSON.parse(DataChartSearch[key].DataJSON);

                JSONChart.Options.animation = {
                    onComplete: function () {
                      var chartInstance = this.chart;
                      var ctx = chartInstance.ctx;
                      var data = chartInstance.config.data.datasets[0].data;
                      var total = data.reduce(function (a, b) { return a + b; }, 0);
                  
                      ctx.font = "12px Arial";
                      ctx.fillStyle = "#fff";
                      ctx.textAlign = "center";
                      ctx.textBaseline = "middle";
                  
                      this.data.datasets[0]._meta[Object.keys(this.data.datasets[0]._meta)[0]].data.forEach(function (element, index) {
                        var model = element._model;
                        var mid_radius = model.innerRadius + (model.outerRadius - model.innerRadius) / 2;
                        var start_angle = model.startAngle;
                        var end_angle = model.endAngle;
                        var mid_angle = start_angle + (end_angle - start_angle) / 2;
                  
                        var x = model.x + mid_radius * Math.cos(mid_angle);
                        var y = model.y + mid_radius * Math.sin(mid_angle);
                  
                        var value = data[index];
                        var percent = (value / total * 100).toFixed(1) + '%';
                        ctx.fillText(value + ' (' + percent + ')', x, y);
                      });
                    }
                };

                SetChartSearch(JSONChart.Identifier, JSONChart.Type, JSONChart.Data, JSONChart.Options);
            }
        }
        else if ( DataChart && DataChart.length > 0 ) {

            var Height = $("canvas").height() - 24;
            var Width = $("canvas").width();

            if(DataChart.length > 0){
                $('.chart-open-closed').html(DataChart[0].ChartName);

                for (var key in DataChart) {
                    var JSONChart = JSON.parse(DataChart[key].DataJSON);

                    SetChart(DataChart[key].ChartName, JSONChart.Type, JSONChart.Data, JSONChart.Options);
                }

                $(".Loader").addClass("Hidden");
            }
        }
    
    };

    /**
    * @private
    * @name SetChart
    * @memberof Core.Customer.Dashboard.Init
    * @function
    * @param {String} Context
    * @param {String} Type
    * @param {JSON} Data
    * @param {JSON} Options
    * @description
    *      Create on change event handler
    */

    function SetChartSearch (Identifier, Type, Data, Options) {
        var Height = $("#ChartContainer").height() - 150;
        var Width = $("#ChartContainer").width() - 30;

        var BackgroundColor;

        if(Type === 'pie' || Type === 'doughnutChartToTicketType'){
            BackgroundColor = palette('mpn65', Data.datasets[0].data.length);
        }
        else{

            BackgroundColor = palette('mpn65', Data.datasets.length);
        }

        var Border = 0;
        var Colors = {
            BackgroundColor: [],
            BorderColor    : [],
        };

        var DataSet;
        if(Type === 'line'){
            Border = 1;
            var BorderColor = BackgroundColor;
            BackgroundColor = GenerateBackgroundRGBA(BorderColor);

            Colors.BackgroundColor = BackgroundColor;
            Colors.BorderColor     = BorderColor;

            DataSet = SetColors(Data.datasets, Colors, Type, Border);
        }
        else{

            Colors.BackgroundColor = BackgroundColor;
            DataSet = SetColors(Data.datasets, Colors, Type, Border);
        }

        Data.datasets = DataSet;

        if(Type === 'line'){
            var ctx = document.getElementById("line");

            new Chart(ctx, {
                type: Type,
                data: Data,
                options: Options
            });

        }else if (Type === 'pie') {
            var ctx = document.getElementById("pie" + Identifier);

            new Chart(ctx, {
                type: Type,
                data: Data,
                options: Options
            });
        }else if (Type === 'bar') {
            var ctx = document.getElementById("bar");
            new Chart(ctx, {
                type: Type,
                data: Data,
                options: Options
            });
        }
        // else if (Type === 'lineOpenMonth') {
        //     var ctx = document.getElementById("OpenAndClosedMonth");
        //     new Chart(ctx, {
        //         type: 'line',
        //         data: Data,
        //         options: Options
        //     });
        // }
        else if (Type === 'doughnutChartToTicketType') {

            var ctx = document.getElementById("TicketType");
            new Chart(ctx, {
                type: 'doughnut',
                data: Data,
                options: Options
            });
        }
    }

    function SetChart (Context, Type, Data, Options) {
        var Height = $("#ChartContainer").height() - 150;
        var Width = $("#ChartContainer").width() - 30;

        var BackgroundColor;

        if(Type === 'pie' || Type === 'doughnutChartToTicketType'){
            BackgroundColor = palette('mpn65', Data.datasets[0].data.length);
        }
        else{

            BackgroundColor = palette('mpn65', Data.datasets.length);
        }

        var Border = 0;
        var Colors = {
            BackgroundColor: [],
            BorderColor    : [],
        };

        var DataSet;
        if(Type === 'line'){
            Border = 1;
            var BorderColor = BackgroundColor;
            BackgroundColor = GenerateBackgroundRGBA(BorderColor);

            Colors.BackgroundColor = BackgroundColor;
            Colors.BorderColor     = BorderColor;

            DataSet = SetColors(Data.datasets, Colors, Type, Border);
        }
        else{

            Colors.BackgroundColor = BackgroundColor;
            DataSet = SetColors(Data.datasets, Colors, Type, Border);
        }

        Data.datasets = DataSet;

        if(Type === 'line'){
            var ctx = document.getElementById("line");

            new Chart(ctx, {
                type: Type,
                data: Data,
                options: Options
            });

        }else if (Type === 'pie') {
            var ctx = document.getElementById("pie");
            new Chart(ctx, {
                type: Type,
                data: Data,
                options: Options
            });
        }else if (Type === 'bar') {
            var ctx = document.getElementById("bar");
            new Chart(ctx, {
                type: Type,
                data: Data,
                options: Options
            });
        }
        // else if (Type === 'lineOpenMonth') {
        //     var ctx = document.getElementById("OpenAndClosedMonth");
        //     new Chart(ctx, {
        //         type: 'line',
        //         data: Data,
        //         options: Options
        //     });
        // }
        else if (Type === 'doughnutChartToTicketType') {

            var ctx = document.getElementById("TicketType");
            new Chart(ctx, {
                type: 'doughnut',
                data: Data,
                options: Options
            });
        }
    }

    /**
        * @private
        * @name SetColors
        * @memberof Core.Agent.OverviewDashboard.SetColors
        * @function
        * @param {Array} Dataset
        * @param {String} Type
        * @param {Boolean} Border
        * @description
        *      Create on change event handler
    */
    function SetColors (Dataset, Colors, Type, Border) {

        if(Border){
            for (Data in Dataset){
                Dataset[Data].borderColor     = '#'+Colors.BorderColor[Data];
                Dataset[Data].backgroundColor = Colors.BackgroundColor[Data];
            }
        }
        else{
            if(Type === 'pie' || Type === 'doughnutChartToTicketType'){
                var ColorBackground = [];
                for (Color in Colors.BackgroundColor){
                    ColorBackground[Color] = '#'+Colors.BackgroundColor[Color];
                }
                Dataset[0].backgroundColor = ColorBackground;
            }
            else{
                for (Data in Dataset){
                    Dataset[Data].backgroundColor = '#'+Colors.BackgroundColor[Data];
                }
            }
        }

        return Dataset;
    }

    /**
     * @private
     * @name GenerateBackgroundRGBA
     * @memberof Core.Agent.OverviewDashboard.GenerateBackgroundRGBA
     * @function
     * @param {String} BorderColor
     * @description
     *      Create on change event handler
     */

    function GenerateBackgroundRGBA (BorderColor) {

        var BackgroundColor = [];

        for (Hex in BorderColor){
            BackgroundColor[Hex] = hexToRGB('#'+BorderColor[Hex], 0.2);
        }

        return BackgroundColor;
    }

    function hexToRGB(hex, alpha) {
        var r = parseInt(hex.slice(1, 3), 16),
            g = parseInt(hex.slice(3, 5), 16),
            b = parseInt(hex.slice(5, 7), 16);

        if (alpha) {
            return "rgba(" + r + ", " + g + ", " + b + ", " + alpha + ")";
        } else {
            return "rgb(" + r + ", " + g + ", " + b + ")";
        }
    }

    function showPopupAlert() {
        const alertBox = document.getElementById("successAlert");
        alertBox.classList.add("show");
    
        setTimeout(() => {
            alertBox.classList.remove("show");
        }, 5000);
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

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CustomerPortalDashboard || {}));

