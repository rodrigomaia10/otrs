// --
// var/httpd/htdocs/js/Core.Agent.KPIDashboard.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dparavani@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};

/**
 * @namespace Core.Agent.KPIDashboard
 * @memberof Core.Agent
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the KPI module.
 */
 Core.Agent.KPIDashboard = (function (TargetNS) {

    var grid;

    /**
     * @name Init
     * @memberof Core.Agent.KPIDashboard
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        var DataCards = Core.Config.Get('DataCards');
        var DataChart = Core.Config.Get('DataChart');
        var DataHTML  = Core.Config.Get('DataHTML');
        var DashboardPreference = Core.Config.Get('DashboardPreference');

        if ( $(`#${DashboardPreference}`) ) {
            
            let Preference = $(`#${DashboardPreference}`).children()[0];
            $(Preference).find('i').css('display', '')
            $(Preference).find('i').toggleClass('yellow-star')
            $(`#${DashboardPreference}`).css('border-left', '3px solid rgb(255, 193, 7)')
        }

        let ParamURL = GetParamURL();
        
        if ( ParamURL.Subaction ) {
            if ( DataCards != undefined ) {
                ShowCards(DataCards);
                UpdateWidgetChart(DataChart, DataCards);
                UpdateWidgetHTML(DataHTML);
            }
        }

        $('.fa-star').on('click', function(Event) {

            Event.preventDefault();
            Event.stopPropagation();
            
            let HasStar = $('.fa-star').hasClass('yellow-star');

            if ( !HasStar ) {
                $(this).toggleClass('yellow-star')
                $(this).css('display', '')
                $(this).closest('.card').css('border-left', '3px solid rgb(255, 193, 7)')

                let DashboardID = $(this).closest('.card').attr('id')
                SetDashboardPreferences(DashboardID)
            }
            else {
                if ( $(this).hasClass('yellow-star') ) {
                    $(this).toggleClass('yellow-star')
                    $(this).css('display', 'none')
                    $(this).closest('.card').css('border-left', '3px solid #929292')
                    let DashboardID = ''
                    SetDashboardPreferences(DashboardID)


                }
                else {
                    $('.fa-star').removeClass('yellow-star')
                    $('.fa-star').css('display', 'none')
                    $('.card').css('border-left', '3px solid #929292')
                    $(this).toggleClass('yellow-star')
                    $(this).css('display', '')
                    $(this).closest('.card').css('border-left', '3px solid rgb(255, 193, 7)')
                    
                    let DashboardID = $(this).closest('.card').attr('id')
                    SetDashboardPreferences(DashboardID)
                }
            }
        })
    };

    function SetDashboardPreferences (DashboardID) {

        var Data = {
            Action    : 'AgentKPIDashboard',
            Subaction : 'SetPreferences',
            DashboardID : DashboardID,
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (HTML) {

            }, 'html',
        );
    }

    function GetParamURL(str) {
        return (str || document.location.search).replace(/(^\?)/,'').split(";").map(function(n){return n = n.split("="),this[n[0]] = n[1],this}.bind({}))[0];
    }

    function ShowCards(DataCards) {

        let count = 0;
        DataCards.forEach( () => {

            var options = { // put in gridstack options here
                disableOneColumnMode: true, // for jfiddle small window size
                cellHeight: '20px',
                disableDrag: true,
                disableResize: true
            };

            grid = GridStack.init(options);

            var cards = {
                x: DataCards[count].PositionX,
                y: DataCards[count].PositionY,
                w: DataCards[count].Width,
                h: DataCards[count].Height,
                id: DataCards[count].CardID,
            };

            var node = cards;

            node.content = ('');

            if ( DataCards[count].CardType == 'KPI' ) {
                
                node.content += (
                                "<div id='ChartSQLQueryChart_" + DataCards[count].CardID + "' class='Charts c3' style='max-height: 400px; position: absolute;'></div>"
                                ); 
            }
            else if ( DataCards[count].CardType == 'HTML' ) {

                node.content += (
                    "<div id='Widget_" + DataCards[count].CardID + "' style='position: absolute; height: 100%; width: 100%'></div>"
                    ); 
            }

            grid.addWidget(node);

            grid.on('resize', function(event, el) {
                $Chart.resize();
            });

            count += 1;
            
        })

    }

    function UpdateWidgetChart(DataChart, DataCards) {
        
        $(DataChart).each(function(id, chart) {

            chart.data['onclick'] = function (d, i) {	
                GraphicSetorClickChartSQLQuery(chart.KPIID);								
            };

            let ChartHeight = GetChartHeight(chart, DataCards);

            var $Chart;
            
            $Chart = c3.generate({
                bindto: '#ChartSQLQueryChart_' + chart.cardID,
                data: {
                    x: chart.data.x,
                    columns: chart.data.columns,
                    type: chart.data.type,
                    labels: true,
                    groups: chart.data.groups,
                    onclick: chart.data.onclick,
                },
                pie: {
                    label: {
                        format: function (value, ratio, id) {
                            return value;
                        }
                    }
                },
                axis: {
                    rotated: chart.data.rotated,
                    x: {
                        type: 'category',
                        tick: {
                            // rotate: 25,
                            multiline: chart.data.rotated ? false : true,
                            fit: true,
                            format: function (d) {
                                var catName = this.api.categories()[d];
                                
                                if (catName && catName.length > 50) {
                                    DifLength = catName.length - 50;
                                    catName = "…"+catName.slice(DifLength,catName.length);
                                }
                                return catName;
                            }
                        },
                    },
                },
                title: {
                    text: chart.title.text
                },
                legend: {
                    show: true
                },
                size: {
                    height: ChartHeight,
                    width: 480
                },
                padding: {
                    bottom: 20, //adjust chart padding bottom
                    top: 20
                },
                color: {
                    pattern: ['#1f77b4', '#aec7e8', '#ff7f0e', '#ffbb78', '#2ca02c', '#98df8a', '#d62728', '#ff9896', '#9467bd', '#c5b0d5', '#8c564b', '#c49c94', '#e377c2', '#f7b6d2', '#7f7f7f', '#c7c7c7', '#bcbd22', '#dbdb8d', '#17becf', '#9edae5']
                }
            });

            $Chart.resize();

            grid.on('resize', function(event, el) {
                $Chart.resize();
            });

        })
    }

    function UpdateWidgetHTML(DataHTML) {
        
        $(DataHTML).each(function(id, HTML) {
        
            $('#Widget_' + HTML.CardID).append(HTML.ContentTemplate)
        })
    }

    function GraphicSetorClickChartSQLQuery(KPIID) {

		var URL;

		URL = Core.Config.Get('Baselink')+'Action=AgentKPISearch;Subaction=SearchSQL;TakeLastSearch=1;Profile='+KPIID;

		window.location.href = URL;
		
	}
    
    // Function to determine the height of the graphic based on the size of the card.
    // Each 1 point of height on the card corresponds to 20px.
    // In this case, the chart is 20% the height of the card.
    function GetChartHeight(chart, DataCards) {

        const CardSize = DataCards.find( card => card.CardID === chart.cardID );

        const ChartHeight = (CardSize.Height - (CardSize.Height * 0,2)) * 20;

        return ChartHeight;

    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;

}(Core.Agent.KPIDashboard || {}));