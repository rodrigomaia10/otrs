// --
// var/httpd/htdocs/js/Core.Agent.ServicesDashboard.js
// Copyright (C) 2019 Service Up, http://serviceup.com.br/
//
// written/edited by:
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

Core.Agent.ServicesDashboard = (function (TargetNS) {
	
	TargetNS.Init = function () {

		var DataChart = Core.Config.Get('DataChart');

		var Datasets = JSON.parse( DataChart.Datasets );

		//Addind space between legend and chart---START
		function getBoxWidth(labelOpts, fontSize) {
			return labelOpts.usePointStyle ?
				fontSize * Math.SQRT2 :
				labelOpts.boxWidth;
		};

		Chart.NewLegend = Chart.Legend.extend({
			afterFit: function() {
				this.height = this.height + 25;
			},
		});

		function createNewLegendAndAttach(chartInstance, legendOpts) {

			var legend = new Chart.NewLegend({
				ctx: chartInstance.chart.ctx,
				options: legendOpts,
				chart: chartInstance
			});
			
			if ( chartInstance.legend ) {
				Chart.layoutService.removeBox(chartInstance, chartInstance.legend);
				delete chartInstance.newLegend;
			}
			
			chartInstance.newLegend = legend;
			Chart.layoutService.addBox(chartInstance, legend);
		}

		// Register the legend plugin
		Chart.plugins.register({
			beforeInit: function(chartInstance) {
				var legendOpts = chartInstance.options.legend;

				if ( legendOpts ) {
					createNewLegendAndAttach(chartInstance, legendOpts);
				}
			},
			beforeUpdate: function(chartInstance) {
				var legendOpts = chartInstance.options.legend;

				if ( legendOpts ) {
					legendOpts = Chart.helpers.configMerge(Chart.defaults.global.legend, legendOpts);

					if (chartInstance.newLegend) {
						chartInstance.newLegend.options = legendOpts;
					}
					else {
						createNewLegendAndAttach(chartInstance, legendOpts);
					}
				}
				else {
					Chart.layoutService.removeBox(chartInstance, chartInstance.newLegend);
					delete chartInstance.newLegend;
				}
			},
			afterEvent: function(chartInstance, e) {

				var legend = chartInstance.newLegend;

				if ( legend ) {
					legend.handleEvent(e);
				}
			}
		});
		//END

		var ctx = document.getElementById("myChart");

		var myChart = new Chart(ctx, {
			type: 'bar',
			data: {
				labels: ["Family/Service"],
				datasets: Datasets,
			},
			options: {
				scales: {
					yAxes: [{
						ticks: {
							beginAtZero:true,
							fontStyle: "bold",
						}
					}],
					xAxes:[{
						ticks: {
							// fontSize: 20,
							fontStyle: "bold",
						}
						
					}]
				},
				title: {
					display: true,
					text: DataChart.Period,
					fontSize: 20,
				},
				transition: {
					duration: 1000,
				},
				animation: {
					duration: 500,
					onComplete: function () {
						// render the value of the chart above the bar
						var ctx = this.chart.ctx;

						ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, 'normal', Chart.defaults.global.defaultFontFamily);
						ctx.fillStyle = this.chart.config.options.defaultFontColor;
						ctx.textAlign = 'center';
						ctx.textBaseline = 'bottom';

						this.data.datasets.forEach(function (dataset) {

							for (var i = 0; i < dataset.data.length; i++) {

								var model = dataset._meta[Object.keys(dataset._meta)[0]].data[i]._model;

								if( dataset.data[i] == 0){
									//Don't show the goal and values that are set on 0
								}
								else{
									ctx.font = 'bold 20px Arial';
									ctx.fillText(dataset.data[i], model.x, model.y - 5);
								}
							}
						});
					}
				}
			}			
		});
	}
	
    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.ServicesDashboard || {}));
