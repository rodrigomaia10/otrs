// --
// var/httpd/htdocs/js/Core.Agent.KPIWidget.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * pdias@beonup.com.br
// * dsilva@beonup.com.br
// * gtiburtino@beonup.com.br
// * lsnevelin@serviceup.com.br
// * nfreitas@serviceup.com.br
// * msantos@serviceup.com.br
// * dparavani@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Agent.KPIWidget
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the KPI Series module.
 */
Core.Agent.KPIWidget = (function (TargetNS) {
    /**
     * @name Init
     * @memberof Core.Agent.KPIWidget
     * @function
     * @description
     *       Initialize module functionality
     */

    TargetNS.Init = function (DataJSON) {

		if ( Core.Config.Get('FullScreen') ) {
            FullScreen();
		}
		
		if ( Core.Config.Get('Adjust') ) {
			Adjust();
		}
		$(DataJSON).each(function(id, JSONData) {
			
			if ( JSONData.TypeKPI == 'Graphic' ) {
				BuildC3GaugeChart(JSONData);
			}
			else if ( JSONData.TypeKPI == 'Numeric' ) {
				BuildNumericChart(JSONData);
			}
			else if ( JSONData.TypeKPI == 'SQLQuery' ) {
				BuildSQLQueryChart(JSONData);
			}
			else if (JSONData.TypeKPI == 'Simple'){
				BuildSimpleChart(JSONData);
			}
			else if (JSONData.TypeKPI == 'SimpleITSM'){
				BuildSimpleITSMChart(JSONData);
			}
		});
		Core.Agent.KPIWidget.UpdateWidget(DataJSON);

		$(".NumberGraphicResult").click(function() {
			var ID = $(this).attr('data-kpi-id');
			var URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=Search;TakeLastSearch=1;Profile='+ID;
			window.location.href = URL;
		});

		$(".SQLQueryGraphicResult").click(function() {
			var ID = $(this).attr('data-kpi-id');
			var URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=SearchSQL;TakeLastSearch=1;Profile='+ID;
			window.location.href = URL;
		});	

		$(".SimpleGraphicResult").click(function() {
			var ID = $(this).attr('data-kpi-id');
			var URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=SearchSurvey;TakeLastSearch=1;Profile='+ID;
			window.location.href = URL;
		});

		$(".SimpleITSMGraphicResult").click(function() {
			var ID = $(this).attr('data-kpi-id');
			var URL = Core.Config.Get('Baselink')+'Action=AgentITSMConfigItem';
			window.location.href = URL;
		});

	};
	
	function BuildNumericChart (DataJSON){
		var KPIID = DataJSON.ID.split("NumericChart_");
		$('#'+DataJSON.ID).append('<h1 class="NumberGraphicResult" data-kpi-id="'+KPIID[1]+'" id="'+DataJSON.ID+'_number"></h1>');
	}

	function BuildSQLQueryChart (DataJSON){
		var KPIID = DataJSON.ID.split("SQLQueryChart_");
		$('#'+DataJSON.ID).append('<h1 class="SQLQueryGraphicResult" data-kpi-id="'+KPIID[1]+'" id="'+DataJSON.ID+'_number"></h1>');
	}

	function BuildSimpleChart (DataJSON){
		var KPIID = DataJSON.ID.split("SimpleChart_");
		$('#'+DataJSON.ID).append('<h1 class="SimpleGraphicResult" data-kpi-id="'+KPIID[1]+'" id="'+DataJSON.ID+'_number"></h1>');
	}

	function BuildSimpleITSMChart (DataJSON){
		var KPIID = DataJSON.ID.split("SimpleChart_");
		$('#'+DataJSON.ID).append('<h1 class="SimpleITSMGraphicResult" data-kpi-id="'+KPIID[1]+'" id="'+DataJSON.ID+'_number"></h1>');
	}

    function BuildC3GaugeChart(JSONData){

		var ColorPattern = JSONData.ColorOrder;
		
		var Selector = "#" + JSONData.ID;

		var thresholdValue = JSONData.Values.Max/4;			
		var thresholdData = { first: thresholdValue, 
						second: thresholdValue * 2, 
						third: thresholdValue * 3, 
						fourth: thresholdValue * 4  
					};

		var $Chart = c3.generate({
			bindto: Selector,
			data: {
				columns: [
					['data', 0]
				],
				type: 'gauge',
				onclick: function (d, i, Selector) {
					// Redirect page
					var ID = JSONData.ID.replace("GaugeChart_", "");
					var URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=Search;TakeLastSearch=1;Profile='+ID;

					window.location.href = URL;

				},
			},

			tooltip: {
				show: false
			},
			gauge: {
				label: {
					format: function(value, ratio) {
						return value;
					},
					show: true,
				},
			min: JSONData.Values.Min,
			max: JSONData.Values.Max,
			width: 20
			},
			color: {
				pattern: [
					ColorPattern.First,
					ColorPattern.Second,
					ColorPattern.Third,
					ColorPattern.Fourth	
				], // the three color levels for the percentage values.
				threshold: {
					values: [thresholdData.first,thresholdData.second,thresholdData.third,thresholdData.four]
				}
			},
			size: {
				height: 90,
				width: 190
			}
		});

		$(Selector).data('c3-data', $Chart);
	}

	TargetNS.UpdateWidget = function(DataJSON){
		
		var NewChartHeight = ScreenSize();

		var Data = {
			Action: 'KPIWidgetAJAXHandler',
		};

		Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
			
			if (!Response) {
				// We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
				Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
			}
			else{		
				var ColId = 0;
				$(Response.JSON).each(function(id, chart) {
					// To the tooltip of Line Chart
					$("#Title_ComplexChart_"+chart.serieID+"_"+chart.columnID).html(chart.returnPhrase);
				
					ColId++;
					var $Chart;

					let labels;
					if ( chart.DisplayText === 'Percentage' ) {
						labels = {
							format: function (v, id, i, j) { return v + '%'; }
						}
					}
					else {
						labels = true;
					}
					
					if ( chart.TypeKPI == 'Graphic' ) {
						$Chart =  $("#"+chart.ID).data('c3-data');
						var CurrentChartValue = $Chart.data.values('data')[0];
						var NewChartValue = chart.Total;
	
						$(".Loader").addClass("Hidden");
	
						if ( CurrentChartValue != NewChartValue ){
									
							$Chart.internal.config.gauge_units = chart.Label;
										
							$Chart.load({
								columns: [['data', NewChartValue]]
							});
	
							$("#"+chart.ID).data('c3-data', $Chart);
						}
					}
					else if ( chart.TypeKPI == 'Numeric' ) {
						$('#'+chart.ID+"_number").html(chart.Total);
						$(".Loader").addClass("Hidden");

					}
					else if ( chart.TypeKPI == 'SQLQuery' ) {
						$('#'+chart.ID+"_number").html('<i class="fa fa-table SQLQueryImage" aria-hidden="true"></i><div class="SQLResult">'+chart.Total+'</div>');
						$(".Loader").addClass("Hidden");

					}
					else if ( chart.TypeKPI == 'ChartSQLQuery' ){
						chart.data['onclick'] = function (d, i) {	
							GraphicSetorClickChartSQLQuery(chart.KPIID);								
						};

						const myTimeout = setTimeout(function(){	
							$Chart = c3.generate({
								bindto: '#ChartSQLQueryChart_'+chart.serieID+'_'+chart.columnID,
								data: {
									x: chart.data.x,
									columns: chart.data.columns,
									type: chart.data.type,
									labels: labels,
									groups: chart.data.groups,
									onclick: chart.data.onclick,
								},
								axis: {
									rotated: chart.data.rotated,
									x: {
										type: 'category'
									}
								},
								legend: {
									show: true
								},
								size: {
									height: 240,
									// width: 480
								},
								color: {
									pattern: ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5']
								}
							});

							$Chart.resize();

						}, 500);
						
						myTimeout;

						$(".Loader").addClass("Hidden");

						$('#Expand_Chart_ChartSQLQueryChart_' + chart.serieID + '_' + chart.columnID).on('click', function (Event) {
							
							let title = $('#Chart_ChartSQLQueryChart_' + chart.serieID + '_' + chart.columnID).children('#Title').text()

							Core.UI.Dialog.ShowContentDialog(
								'<div id="Title" style="text-align: center; margin-top: 25px; font-size: xx-large;">' + title + '</div>' + 
								'<div id="Chart_' + chart.serieID + '_' + chart.columnID + '" class="Charts c3" style="max-height: 240px; position: relative;"></div>', 
								Core.Language.Translate('Overview'), 
								'50px',
								'',
								true,
							);

							$('.Dialog').css('max-width', '75vw');
							$('.Dialog').css('margin', '0 auto');
							$('.Dialog').css('left', '0');
							$('.Dialog').css('right', '0');
								
								$Chart = c3.generate({
									bindto: '#Chart_' + chart.serieID + '_' + chart.columnID,
									data: {
										x: chart.data.x,
										columns: chart.data.columns,
										type: chart.data.type,
										labels: labels,
										groups: chart.data.groups,
										onclick: chart.data.onclick,
									},
									axis: {
										rotated: chart.data.rotated,
										x: {
											type: 'category',
											tick: {
												// rotate: 25,
												multiline: chart.data.rotated ? false : true,
												format: function (d) {
													var catName = this.api.categories()[d];

													if (catName && catName.length > 80) {
														DifLength = catName.length - 80;
														catName = "…"+catName.slice(DifLength,catName.length);
													}
													return catName;
												}
											},
										},
									},
									legend: {
										show: true
									},
									size: {
										height: NewChartHeight,
										// width: 480
									},
									padding: {
										bottom: 50, //adjust chart padding bottom
										top: 10
									},
									color: {
										pattern: ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5']
									}
								});
	
								$Chart.resize();
				
							Event.preventDefault();
							Event.stopPropagation();
				
							return false;
						});

						$('#Chart_ChartSQLQueryChart_' + chart.serieID + '_' + chart.columnID).on('mouseover', function() {
							var ChartID = $(this).attr('id');
							$('#Expand_' + ChartID).show();
						});
						  
						$('#Chart_ChartSQLQueryChart_' + chart.serieID + '_' + chart.columnID).on('mouseout', function() {
							var ChartID = $(this).attr('id');
							$('#Expand_' + ChartID).hide();
						});

					}
					else if ( chart.TypeKPI == 'Complex' ) {
						// to Complex charts
						// Adds the click event to each sector of the complex chart.
						chart.data['onclick'] = function (d, i) {								
							GraphicSetorClick(d);									
						};
						
						if ( chart.qtdColumn == '1' ) {
							if ( chart.typeRotate  == 'Column' ) {
								Chart = c3.generate({
									bindto: '#ComplexChart_'+chart.serieID+'_'+chart.columnID,
									data: chart.data,
									axis: {
										rotated: 'true' 
									},
									legend: {
										show: true
									},
									size: {
										height: 240,
										width: 480
									},
								});
							}
							else {
								Chart = c3.generate({
									bindto: '#ComplexChart_'+chart.serieID+'_'+chart.columnID,
									data: chart.data,
									axis: chart.axis,
									legend: {
										show: true
									},
									size: {
										height: 240,
										width: 480
									},
									donut: {
										label: {
											format: function (value, ratio, id, index) { 
												if(chart.chartLabelType == 'Number'){
													return value; 
												}
												else{
													return d3.format('.2%')(value/100);
												}
											 
											}
										},

									},
									pie: {
										label: {
											format: function (value) { 
												if(chart.chartLabelType == 'Percentage'){
													return value + '%';
												}else{
													return value;
												}
											 
											}
										}
									},
									tooltip: {
										format: {											
											value:  function (value) { return value; }																					
										},
									},									
								});							
							}
						} 
						if ( chart.qtdColumn == '2' ) {
							if ( chart.typeRotate  == 'Column' ) {
								Chart = c3.generate({
									bindto: '#ComplexChart_'+chart.serieID+'_'+chart.columnID,
									data: chart.data,
									axis: {
										rotated: 'true' 
									},
									legend: {
										show: true
									},
									size: {
										height: 240,
										width: 480
									},
								});
							} 
							else {

								Chart = c3.generate({
									bindto: '#ComplexChart_'+chart.serieID+'_'+chart.columnID,
									data: chart.data,
									axis: chart.axis,									 
									legend: {
										show: true
									},
									size: {
										height: 240,
										width: 480
									},
									donut: {
										label: {
											format: function (value) { 
												if(chart.chartLabelType == 'Percentage'){
													return value + '%';
												}else{
													return value; 
												}
											 
											}
										}
									},
									pie: {
										label: {
											format: function (value) { 
												if(chart.chartLabelType == 'Percentage'){
													return value + '%';
												}else{
													return value; 
												}
											 
											}
										}
									},
									tooltip: {
										format: {											
											value:  function (value) { return value; }																					
										},
									},
								});
							}	
						}
						if ( chart.qtdColumn == '3' ) {
							if ( chart.typeRotate  == 'Column' ) {
								Chart = c3.generate({
									bindto: '#ComplexChart_'+chart.serieID+'_'+chart.columnID,
									data: chart.data,
									axis: {
										rotated: 'true' 
									},
									legend: {
										show: true
									},
									size: {
										height: 270,
										width: 330
									},
								});
							}else{

								Chart = c3.generate({
									bindto: '#ComplexChart_'+chart.serieID+'_'+chart.columnID,
									data: chart.data,
									axis: chart.axis,
									legend: {
										show: true
									},
									size: {
										height: 240,
										width: 320
									},
									donut: {
										label: {
										  format: function (value) { 
												if(chart.chartLabelType == 'Percentage'){
													return value + '%';
												}else{
													return value; 
												}
											 
											}
										}
									},
									pie: {
										label: {
											format: function (value) { 
												if(chart.chartLabelType == 'Percentage'){
													return value + '%';
												}else{
													return value; 
												}
											 
											}
										}
									},
									tooltip: {
										format: {											
											value:  function (value) { return value; }																					
										},
									},
								});
							}
						}					
						
						$(".Loader").addClass("Hidden");
						
						$('#Expand_Complex_ComplexChart_' + chart.serieID + '_' + chart.columnID).on('click', function (Event) {
						
							let title = $('#Complex_ComplexChart_' + chart.serieID + '_' + chart.columnID).children('#Title').text()

							Core.UI.Dialog.ShowContentDialog(
								'<div id="Title" style="text-align: center; margin-top: 25px; font-size: xx-large;">' + title + '</div>' + 
								'<div id="Chart_' + chart.serieID + '_' + chart.columnID + '" class="Charts c3" style="max-height: 240px; position: relative;"></div>', 
								Core.Language.Translate('Overview'), 
								'50px', 
								'', 
								true,
							);
							
							$('.Dialog').css('max-width', '75vw');
							$('.Dialog').css('margin', '0 auto');
							$('.Dialog').css('left', '0');
							$('.Dialog').css('right', '0');

							if ( chart.qtdColumn == '1' ) {
								if ( chart.typeRotate  == 'Column' ) {
									Chart = c3.generate({
										bindto: '#Chart_'+chart.serieID+'_'+chart.columnID,
										data: chart.data,
										axis: {
											rotated: 'true' 
										},
										legend: {
											show: true
										},
										size: {
											height: NewChartHeight,
											// width: 480
										},
										padding: {
											bottom: 50, //adjust chart padding bottom
											top: 10
										},
									});
								}
								else {
									Chart = c3.generate({
										bindto: '#Chart_'+chart.serieID+'_'+chart.columnID,
										data: chart.data,
										axis: chart.axis,
										legend: {
											show: true
										},
										size: {
											height: NewChartHeight,
											// width: 480
										},
										padding: {
											bottom: 50, //adjust chart padding bottom
											top: 10
										},
										donut: {
											label: {
												format: function (value, ratio, id, index) { 
													if(chart.chartLabelType == 'Number'){
														return value; 
													}
													else{
														return d3.format('.2%')(value/100);
													}
												 
												}
											}
										},
										pie: {
											label: {
												format: function (value) { 
													if(chart.chartLabelType == 'Percentage'){
														return value + '%';
													}else{
														return value;
													}
												 
												}
											}
										},
										tooltip: {
											format: {											
												value:  function (value) { return value; }																					
											},
										},									
									});							
								}
							} 
							if ( chart.qtdColumn == '2' ) {
								if ( chart.typeRotate  == 'Column' ) {
									Chart = c3.generate({
										bindto: '#Chart_'+chart.serieID+'_'+chart.columnID,
										data: chart.data,
										axis: {
											rotated: 'true' 
										},
										legend: {
											show: true
										},
										size: {
											height: NewChartHeight,
											// width: 480
										},
										padding: {
											bottom: 50, //adjust chart padding bottom
											top: 10
										},
									});
								} 
								else {
	
									Chart = c3.generate({
										bindto: '#Chart_'+chart.serieID+'_'+chart.columnID,
										data: chart.data,
										axis: chart.axis,									 
										legend: {
											show: true
										},
										size: {
											height: NewChartHeight,
											// width: 480
										},
										padding: {
											bottom: 50, //adjust chart padding bottom
											top: 10
										},
										donut: {
											label: {
												format: function (value) { 
													if(chart.chartLabelType == 'Percentage'){
														return value + '%';
													}else{
														return value; 
													}
												 
												}
											}
										},
										pie: {
											label: {
												format: function (value) { 
													if(chart.chartLabelType == 'Percentage'){
														return value + '%';
													}else{
														return value; 
													}
												 
												}
											}
										},
										tooltip: {
											format: {											
												value:  function (value) { return value; }																					
											},
										},
									});
								}	
							}
							if ( chart.qtdColumn == '3' ) {
								if ( chart.typeRotate  == 'Column' ) {
									Chart = c3.generate({
										bindto: '#Chart_'+chart.serieID+'_'+chart.columnID,
										data: chart.data,
										axis: {
											rotated: 'true' 
										},
										legend: {
											show: true
										},
										size: {
											height: NewChartHeight,
											// width: 480
										},
										padding: {
											bottom: 50, //adjust chart padding bottom
											top: 10
										},
									});
								}else{
	
									Chart = c3.generate({
										bindto: '#Chart_'+chart.serieID+'_'+chart.columnID,
										data: chart.data,
										axis: chart.axis,
										legend: {
											show: true
										},
										size: {
											height: NewChartHeight,
											// width: 480
										},
										padding: {
											bottom: 50, //adjust chart padding bottom
											top: 10
										},
										donut: {
											label: {
											  format: function (value) { 
													if(chart.chartLabelType == 'Percentage'){
														return value + '%';
													}else{
														return value; 
													}
												 
												}
											}
										},
										pie: {
											label: {
												format: function (value) { 
													if(chart.chartLabelType == 'Percentage'){
														return value + '%';
													}else{
														return value; 
													}
												 
												}
											}
										},
										tooltip: {
											format: {											
												value:  function (value) { return value; }																					
											},
										},
									});
								}
							}
				
							Event.preventDefault();
							Event.stopPropagation();
				
							return false;
						});

						$('#Complex_ComplexChart_' + chart.serieID + '_' + chart.columnID).on('mouseover', function() {
							var ChartID = $(this).attr('id');
							$('#Expand_' + ChartID).show();
						});
						  
						$('#Complex_ComplexChart_' + chart.serieID + '_' + chart.columnID).on('mouseout', function() {
							var ChartID = $(this).attr('id');
							$('#Expand_' + ChartID).hide();
						});
					}
					else if ( chart.TypeKPI == 'Simple' ) {
						
						$('#'+chart.ID+"_number").html(chart.Total);
						$(".Loader").addClass("Hidden");
					}
					else if ( chart.TypeKPI == 'SimpleITSM' ) {
						
						$('#'+chart.ID+"_number").html(chart.Total);
						$(".Loader").addClass("Hidden");
					}
				});
			}
		});

		setTimeout(Core.Agent.KPIWidget.UpdateWidget,50000);

	}

    function FullScreen(){
        $('#Dashboard0000-KPIWidget-toggle').on('click', function(){
			// if already full screen; exit
				// else go fullscreen
			if (
				document.fullscreenElement ||
				document.webkitFullscreenElement ||
				document.mozFullScreenElement ||
				document.msFullscreenElement
			) {
				$('.MainBox').css('padding', '4px 16px 8px 3px;');
				$('.MainBox').css('width', '97.8%');
				
				if (document.exitFullscreen) {
					document.exitFullscreen();
				} else if (document.mozCancelFullScreen) {
					document.mozCancelFullScreen();
				} else if (document.webkitExitFullscreen) {
					document.webkitExitFullscreen();
				} else if (document.msExitFullscreen) {
					document.msExitFullscreen();
				}
			} else {
				var element = $('.MainBox').get(0);
				$('.MainBox').css('padding-left', '1%');
				$('.MainBox').css('width', '98%');
				$('.MainBox').css('height', '96%');
				$('.MainBox').css('overflow-y', 'scroll');

				if (element.requestFullscreen) {
					element.requestFullscreen();
				} else if (element.mozRequestFullScreen) {
					element.mozRequestFullScreen();
				} else if (element.webkitRequestFullscreen) {
					element.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
				} else if (element.msRequestFullscreen) {
					element.msRequestFullscreen();
				}
			}
		});
	}

	function Adjust(){
        $('#Dashboard0000-KPIWidget-Adjust').on('click', function(){

			if ($('#Dashboard0000-KPIWidget-Adjust').hasClass("BlackAdjust")){
				$('.WidgetSimple > .Header h2, .WidgetSimple > .Header h3').css('color','#555');
				$('.WidgetSimple > .Content').css('background-color','#313030');
				$('.c3-chart-arcs .c3-chart-arcs-background').css('fill','#e0e0e0');
				$('.c3-chart-arc path').css('stroke','#fff');
				$('#Dashboard0000-KPIWidget-Adjust').removeClass("BlackAdjust");
				$('.WidgetSimple > .Content').css('background-color','#f5f5f5');
				$('.Widget li').css('box-shadow','#b9b3b3');
				$('.Widget li').css('background','#fff');
				$('#Title span').css('color','black');
				$('.c3-chart-arc .c3-gauge-value').css('fill','#313030');
				$('.c3-chart-arcs-gauge-unit').css('fill','#777');
				$('.c3-chart-arcs .c3-chart-arcs-gauge-min').css('fill','#313030');
				$('.c3-chart-arcs .c3-chart-arcs-gauge-max').css('fill','#313030'); 
				$('.GroupingHeader').css('background-color','#fff'); 
				$('.GroupingHeader').css('color','black'); 
				$('.WidgetSimple > .Header h2,.WidgetSimple > .Header h3').removeClass('AddedColorBlack'); 
				$('.WidgetSimple > .Header, .WidgetSimple.Collapsed.AnimationRunning > .Header').removeClass('AddedColorBlack'); 
				$('.WidgetSimple > .Header h2, .WidgetSimple > .Header h3').css('text-shadow','none'); 
				$('.WidgetSimple').css('box-shadow','0px 0px 0px #2196F3'); 
				$('.WidgetSimple > .Header, .WidgetSimple.Collapsed.AnimationRunning > .Header').css('border-bottom','#313030'); 

				// To Complex Chart
				$('.c3-legend-item').css('fill','black');
				$('.ExportAllKPI').css('color','black');
				$('.c3-axis-y text').css('fill','black');
				$('.c3-axis-x text').css('color','black');			
				$('.SQLQueryImage').css('color','#eaeaea');			
			} else{

				$('#Dashboard0000-KPIWidget-Adjust').addClass("BlackAdjust");
				$('.WidgetSimple > .Header h2, .WidgetSimple > .Header h3').css('color','#fff');
				$('.WidgetSimple > .Content').css('background-color','#313030');
				$('.c3-chart-arc path').css('stroke','#000000');
				$('.c3-chart-arcs .c3-chart-arcs-background').css('fill','#3a3a3a');
				$('.Widget li').css('box-shadow','#b9b3b3');
				$('.Widget li').css('background','black');
				$('#Title span').css('color','#fff');
				$('.c3-chart-arc .c3-gauge-value').css('fill','#fff');
				$('.c3-chart-arcs-gauge-unit').css('fill','#fff');
				$('.c3-chart-arcs .c3-chart-arcs-gauge-min').css('fill','#fff');
				$('.c3-chart-arcs .c3-chart-arcs-gauge-max').css('fill','#fff'); 
				$('.GroupingHeader').css('background-color','black'); 
				$('.GroupingHeader').css('color','#fff'); 
				$('.WidgetSimple > .Header h2,.WidgetSimple > .Header h3').addClass('AddedColorBlack'); 
				$('.WidgetSimple > .Header, .WidgetSimple.Collapsed.AnimationRunning > .Header').addClass('AddedColorBlack'); 
				$('.WidgetSimple > .Header h2, .WidgetSimple > .Header h3').css('text-shadow','none'); 
				$('.WidgetSimple').css('box-shadow','0px 0px 0px #2196F3'); 

				// To Complex Chart
				$('.c3-legend-item').css('fill','#ffffff');
				$('.ExportAllKPI').css('color','#ffffff');
				$('.c3-axis-y text').css('fill','#ffffff');
				$('.c3-axis-x text').css('color','#ffffff');			
				$('.SQLQueryImage').css('color','#313030');			
							
			}
		});
	
	}

	function GraphicSetorClick(GraphicSetorData) {

		var Data = {
			Action: 'KPIWidgetAJAXHandler',
			Subaction: 'GetKPIIDByName',
			ClickedKPIName: $(GraphicSetorData).attr('id'),
		};

		Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
			if (!Response) {
				// We are out of the OTRS App scope, that's why an exception would not be caught. Therefor we handle the error manually.
				Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("No data retrieved on system.", 'CommunicationError'));
			}
			else {
				var ID = Response.KPIID;
				var URL;
				if ( Response.ObjectType === 'Ticket') {
					URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=Search;TakeLastSearch=1;Profile='+ID;
				}
				else if (Response.ObjectType === 'Survey'){
					URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=SearchSurvey;TakeLastSearch=1;Profile='+ID;
				}
				else if (Response.ObjectType === 'Config Items'){
					URL = Core.Config.Get('Baselink')+'Action=AgentITSMConfigItem';
				}
				else {
					URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=SearchSQL;TakeLastSearch=1;Profile='+ID;
				}
				window.location.href = URL;

			}
		});
	}

	function GraphicSetorClickChartSQLQuery(KPIID) {

		var URL;

		URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=SearchSQL;TakeLastSearch=1;Profile='+KPIID;

		window.location.href = URL;
		
	}

	function ScreenSize() {

		var height = window.screen.height;

		var SizeDialogScreen = height - (height * 0.5);

		return SizeDialogScreen
	}


return TargetNS;
}(Core.Agent.KPIWidget || {}));