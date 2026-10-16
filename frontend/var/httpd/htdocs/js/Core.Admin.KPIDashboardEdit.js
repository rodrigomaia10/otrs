// --
// var/httpd/htdocs/js/Core.Admin.KPIDashboardEdit.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * dparavani@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Admin = Core.Admin || {};

/**
 * @namespace Core.Admin.KPIDashboardEdit
 * @memberof Core.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the KPI module.
 */
 Core.Admin.KPIDashboardEdit = (function (TargetNS) {

    var grid;

    /**
     * @name Init
     * @memberof Core.Admin.KPIDashboardEdit
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        var DataCards = Core.Config.Get('DataCards');
        var DataChart = Core.Config.Get('DataChart');
        var DataHTML  = Core.Config.Get('DataHTML');
        
        if ( DataCards.length ) {
            ShowCards(DataCards);
            UpdateWidgetChart(DataChart, DataCards);
            UpdateWidgetHTML(DataHTML);

            var LastIDCard = GetLastIDCard(DataCards);
        }

        var count = LastIDCard || 0;

        // add new card
        $('#AddNewCard').on('click', function (Event) {
            
            count++;

            Core.Admin.KPIDashboardEdit.AddNewCard(count);

            let cards = GetSizePositionCard();
            Core.Admin.KPIDashboardEdit.SaveCardsPosition(cards);

            $('#CardSettings_' + count).on('click', function (Event) {
                
                var CardSettingsID = $(this).attr('id');
                
                Core.Admin.KPIDashboardEdit.OpenCardConfig(CardSettingsID);

                Event.preventDefault();
                Event.stopPropagation();
    
                return false;
            });
            
            $('#Delete_' + count).on('click', function (Event) {
                    
                var el = $(this).closest('.grid-stack-item')[0]

                Core.UI.Dialog.ShowDialog({
                    HTML: Core.Language.Translate('Do you really want to delete this card?'), 
                    Title: Core.Language.Translate("Dashboard"),
                    Modal: true,
                    PositionTop: '100px', 
                    PositionLeft: 'Center', 
                    AllowAutoGrowtrue: true,
                    CloseOnClickOutside: false,
                    CloseOnEscape: false,
                    Buttons: [
                                {
                                    Label: Core.Language.Translate("Confirm"),
                                    Function: function () {

                                        grid.removeWidget(el);

                                        DeleteCard(count);

                                        Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                                        return false;
                                    },
                                    Class: 'Primary CallForAction'
                                },
                                {
                                    Label: Core.Language.Translate("Cancel"),
                                    Function: function () {
                                        Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                                        return false;
                                    },
                                    Class: 'CallForAction'
                                }
                            ]
                });
                
                Event.preventDefault();
                Event.stopPropagation();
    
                return false;
            });

            $('.grid-stack-item[gs-id="' + count + '"]').on('mouseover', function() {
                var ToolID = $(this).attr('gs-id');
                $('#ToolSettings_' + ToolID ).show();
            });
              
            $('.grid-stack-item[gs-id="' + count + '"]').on('mouseout', function() {
                var ToolID = $(this).attr('gs-id');
                $('#ToolSettings_' + ToolID ).hide();
            });

            $('.grid-stack-item[gs-id="' + count + '"]').on('dblclick', function(Event) {
                
                var CardSettingsID = $(this).attr('gs-id');

                Core.Admin.KPIDashboardEdit.OpenCardConfig(CardSettingsID);

                Event.preventDefault();
                Event.stopPropagation();
    
                return false;
            });

        });
        
        // save dashboard
        $('#SaveDashboard').on('click', function () {
    
            let cards = GetSizePositionCard()
            let save = 1;
            Core.Admin.KPIDashboardEdit.SaveCardsPosition(cards, save);

        });

        // settings dashboard
        $('#DashboardSettings').on('click', function (Event) {

            Core.Admin.KPIDashboardEdit.OpenDashboardConfig();

        });

        // grid.on('resizestop', function(event: Event, el: GridItemHTMLElement) {
        //     let width = parseInt(el.getAttribute('gs-w')) || 0;
        //     // or all values...
        //     let node: GridStackNode = el.gridstackNode; // {x, y, width, height, id, ....}
        //   });

        $('.grid-stack').on('change', function(event, items) {
            let cards = GetSizePositionCard()
            let save = 1;
            Core.Admin.KPIDashboardEdit.SaveCardsPosition(cards, save);
          });
    };


    /**
     * @private
     * @name AddNewCard
     * @memberof Core.Admin.KPIDashboardEdit
     * @function
     * @description
     *      This function initializes grid-stack-item settings.
     */
    TargetNS.AddNewCard = function(count) {
        
        var options = { // put in gridstack options here
            disableOneColumnMode: true, // for jfiddle small window size
            float: true,
            cellHeight: '20px',
        };

        grid = GridStack.init(options);
        
        var cards = {
            // x: 0,
            // y: 0,
            w: 1,
            h: 10,
            id: count,
        };
        
        var node = cards;

        node.content = (
                        "<div id='ToolSettings_" + count + "' style='display: none'>" +
                            "<div class='WidgetAction Delete' style='float: right; margin-right: 2px;'>" +
                                "<a href=# id='Delete_" + count + "' title='Delete'>" +
                                    "<i class='fa fa-trash' style='color: #666666'></i>" + 
                                "</a>" + 
                            "</div>" +
                            "<div class='WidgetAction Settings' style='float: right; margin-right: 2px;'>" +
                                "<a href=# id='CardSettings_" + count + "' title='Settings'>" +
                                    "<i class='fa fa-cog' style='color: #666666'></i>" + 
                                "</a>" + 
                            "</div>" +
                        "</div>"
                        );

        grid.addWidget(node);
        return false;
    };


    /**
     * @private
     * @name OpenCardConfig
     * @memberof Core.Admin.KPIDashboardEdit
     * @function
     * @description
     *      This function open card settings.
     */
    TargetNS.OpenCardConfig = function(CardSettingsID, DataSettings) {
        
        CKEDITOR.config.allowedContent = true;
        
        let ParamURL = GetParamURL();
        
        var Data = {
            Action    : 'AdminKPIDashboardEdit',
            Subaction : 'CardSettings',
            DashboardID : ParamURL.DashboardID,
        };

        if (!CardSettingsID.length) {
            return;
        }
        
        Core.UI.Dialog.ShowContentDialog('<div class="Spacing Center"><span class="AJAXLoader" title="' + Core.Language.Translate('Loading...') + '"></span></div>', Core.Language.Translate('Loading...'), '10px', 'Center', true);
        
        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (HTML) {

                // if the waiting dialog was cancelled, do not show the search
                //  dialog as well
                if (!$('.Dialog:visible').length) {
                    return;
                }
                
                Core.UI.Dialog.ShowDialog({
                    HTML: HTML,
                    Modal: true,
                    Title: Core.Language.Translate('Card Settings'), 
                    PositionTop: '100px', 
                    PositionLeft: 'Center', 
                    AllowAutoGrow: true,
                    CloseOnClickOutside: false,
                    CloseOnEscape: false,
                });

                if ( DataSettings ) {
                    
                    if ( DataSettings.CardType == 'KPI' ) {

                        $('#SelectCardType').val(DataSettings.CardType)
                        $('#KPIsFieldLabel').show()
                        $('#KPIsField').show()
                        $('#KPIsField').css('display', 'flex')

                        $('#AssociatedKPIs').val(DataSettings.KPIID)
                        Core.UI.InputFields.InitSelect( $('#AssociatedKPIs') )

                        $('#optionHTML').hide()

                        $('#RichTextKPI').val('')
                    }
                    else if ( DataSettings.CardType == 'HTML' ) {
                        $('#SelectCardType').val(DataSettings.CardType)
                        $('.InnerContent').css('max-height', '25%')
                        $('#optionHTML').show()

                        $('#RichTextKPI').val(DataSettings.ContentTemplate)

                        $('#KPIsFieldLabel').hide()
                        $('#KPIsField').hide()

                        $('#AssociatedKPIs').val('')
                    }
                }

                Core.UI.InputFields.InitSelect( $('#SelectCardType') );
                
                var ID = CardSettingsID.split('_');
                $('#CardSettingsID').val(ID[1]);
                
                $('#SelectCardType').on('change', function (Event) {
                   
                    if ( $('#SelectCardType').val() == 'HTML' ) {
                        $('.InnerContent').css('max-height', '25%')
                        $('#optionHTML').show()

                        $('#KPIsFieldLabel').hide()
                        $('#KPIsField').hide()

                        $('#AssociatedKPIs').val('')
                    }
                    else if ( $('#SelectCardType').val() == 'KPI' ) {
                        $('#KPIsFieldLabel').show()
                        $('#KPIsField').show()
                        $('#KPIsField').css('display', 'flex')
                        Core.UI.InputFields.InitSelect( $('#AssociatedKPIs') );

                        $('#optionHTML').hide()

                        $('#RichTextKPI').val('')
                    }
                });
                
                Core.UI.RichTextEditor.InitEditor( $('#RichTextKPI') );
            
                // register submit
                $('#SettingsCardFormSubmit').on('click', function () {
                    
                    $('#SettingsCardForm').submit();
                })

            }, 'html',
        );
    }

    /**
     * @private
     * @name SaveCardsPosition
     * @memberof Core.Admin.KPIDashboardEdit
     * @function
     * @description
     *      This function saves the new card and its position within the dashboard.
     */
    TargetNS.SaveCardsPosition = function(cards, save) {
        
        let ParamURL = GetParamURL();

        var Data = {
            Action    : 'AdminKPIDashboardEdit',
            Subaction : 'SaveCardsPosition',
            DashboardID : ParamURL.DashboardID,
            Cards : JSON.stringify(cards),
        };

        if (!cards.length) {
            return;
        }
        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (HTML) {
                // if (save) {
                //     Core.UI.Dialog.ShowAlert(
                //         Core.Language.Translate('Status'),
                //         Core.Language.Translate('Dashboard saved successfully!'),
                //         function () {
                //             Core.UI.Dialog.CloseDialog($('.Alert'));
                //             return false;
                //         }
                //     );

                //     $('.fa-warning').removeClass('fa-warning').addClass('iconClass fa-check');
                //     $('.iconClass').css('color', 'green');
                //     $('.Alert').css('max-width', '300px');
                //     $('.Alert').css('top', '100px');
                // }

            }, 'html',
        );
    }

    /**
     * @private
     * @name OpenDashboardConfig
     * @memberof Core.Admin.KPIDashboardEdit
     * @function
     * @description
     *      This function initializes dashboard settings.
     */
    TargetNS.OpenDashboardConfig = function() {
        
        let ParamURL = GetParamURL();

        var Data = {
            Action    : 'AdminKPIDashboardEdit',
            Subaction : 'DashboardSettings',
            DashboardID : ParamURL.DashboardID,
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (HTML) {

                // if the waiting dialog was cancelled, do not show the search
                //  dialog as well
                // if (!$('.Dialog:visible').length) {
                //     return;
                // }

                Core.UI.Dialog.ShowDialog({
                    HTML: HTML,
                    Modal: true,
                    Title: Core.Language.Translate('Dashboard Settings'), 
                    PositionTop: '100px', 
                    PositionLeft: 'Center', 
                    AllowAutoGrow: true,
                    CloseOnClickOutside: false,
                    CloseOnEscape: false,
                });

                $("#DashboardBG").spectrum({  
                    showAlpha: true,
                    showInput: true,
                    hideAfterPaletteSelect:true,
                    preferredFormat: "hex", 
                    allowEmpty: true          
                });

                $("#CardBG").spectrum({  
                    showAlpha: true,
                    showInput: true,
                    hideAfterPaletteSelect:true,
                    preferredFormat: "hex",   
                    allowEmpty: true     
                });
        
                $('.Dialog').css('width', '250px');
                $('label').css('width', '60%');
                $('.sp-replacer').css('margin-left', '10px');

                            
                // register submit
                $('#SettingsDashboardFormSubmit').on('click', function () {
                    
                    $('#SettingsDashboardForm').submit();
                })

            }, 'html',
        );

    }

    function GetParamURL(str) {
        return (str || document.location.search).replace(/(^\?)/,'').split(";").map(function(n){return n = n.split("="),this[n[0]] = n[1],this}.bind({}))[0];
    }

    function GetSizePositionCard() {

        var cards = [];

        let item = document.querySelectorAll('.grid-stack-item');
        item.forEach( (gridstackNode) => {

            var card = {};

            card['CardID'] = $(gridstackNode).attr("gs-id");
            card['PositionX'] = $(gridstackNode).attr("gs-x");
            card['PositionY'] = $(gridstackNode).attr("gs-y");
            card['CardWidth'] = $(gridstackNode).attr("gs-w");
            card['CardHeight'] = $(gridstackNode).attr("gs-h");

            cards.push(card);
        })
        
        return cards;
    }

    function ShowCards(DataCards) {
        
        let count = 0;
        DataCards.forEach( () => {
            
            var options = { // put in gridstack options here
                disableOneColumnMode: true, // for jfiddle small window size
                float: true,
                cellHeight: '20px',
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

            node.content = (
                            "<div id='ToolSettings_" + DataCards[count].CardID + "' style='display: none; position: absolute; right: 2px; z-index: 999;'>" +
                                "<div class='WidgetAction Delete_" + DataCards[count].CardID + "' style='float: right; margin-right: 2px;'>" +
                                "<a href=# id='Delete_" + DataCards[count].CardID + "' title='Delete'>" +
                                        "<i class='fa fa-trash' style='color: #666666'></i>" + 
                                    "</a>" + 
                                "</div>" +
                                "<div class='WidgetAction Settings_" + DataCards[count].CardID + "' style='float: right; margin-right: 2px;'>" +
                                "<a href=# id='CardSettings_" + DataCards[count].CardID + "' title='Settings'>" +
                                        "<i class='fa fa-cog' style='color: #666666'></i>" + 
                                    "</a>" + 
                                "</div>" +
                            "</div>"
                            );

                            if ( DataCards[count].CardType == 'KPI' ) {
                                
                                node.content += (
                                                "<div id='ChartSQLQueryChart_" + DataCards[count].CardID + "' class='Charts c3' style='max-height: 240px; position: relative;'></div>"
                                                ); 
                            }
                            else if ( DataCards[count].CardType == 'HTML' ) {

                                node.content += (
                                                "<div id='Widget_" + DataCards[count].CardID + "' style='position: relative; height: 100%'></div>"
                                                ); 
                            }

            grid.addWidget(node);

            grid.on('resize', function(event, el) {
                $Chart.resize();
            });

            var DataSettings = DataCards[count];

            $('#CardSettings_' + DataCards[count].CardID).on('click', function (Event) {
                var CardSettingsID = $(this).attr('id');
                
                Core.Admin.KPIDashboardEdit.OpenCardConfig(CardSettingsID, DataSettings);

                Event.preventDefault();
                Event.stopPropagation();

                return false;
            });

            $('.grid-stack-item[gs-id="' + DataCards[count].CardID + '"]').on('mouseover', function() {
                var ToolID = $(this).attr('gs-id');
                $('#ToolSettings_' + ToolID ).show();
            });
              
            $('.grid-stack-item[gs-id="' + DataCards[count].CardID + '"]').on('mouseout', function() {
                var ToolID = $(this).attr('gs-id');
                $('#ToolSettings_' + ToolID ).hide();
            });

            $('#Delete_' + DataCards[count].CardID).on('click', function (Event) {
                
                var el = $(this).closest('.grid-stack-item')[0]

                Core.UI.Dialog.ShowDialog({
                    HTML: Core.Language.Translate('Do you really want to delete this card?'), 
                    Title: Core.Language.Translate("Dashboard"),
                    Modal: true,
                    PositionTop: '100px', 
                    PositionLeft: 'Center', 
                    AllowAutoGrowtrue: true,
                    CloseOnClickOutside: false,
                    CloseOnEscape: false,
                    Buttons: [
                                {
                                    Label: Core.Language.Translate("Confirm"),
                                    Function: function () {

                                        grid.removeWidget(el);

                                        DeleteCard(DataSettings.CardID);

                                        Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                                        return false;
                                    },
                                    Class: 'Primary CallForAction'
                                },
                                {
                                    Label: Core.Language.Translate("Cancel"),
                                    Function: function () {
                                        Core.UI.Dialog.CloseDialog($('.Dialog:visible'));
                                        return false;
                                    },
                                    Class: 'CallForAction'
                                }
                            ]
                });
                
                Event.preventDefault();
                Event.stopPropagation();
    
                return false;
            });

            $('.grid-stack-item[gs-id="' + DataCards[count].CardID + '"]').on('dblclick', function(Event) {
                var CardSettingsID = 'CardSettings_'+ $(this).attr('gs-id');

                Core.Admin.KPIDashboardEdit.OpenCardConfig(CardSettingsID, DataSettings);

                Event.preventDefault();
                Event.stopPropagation();

                return false;
            })

            // $(".Loader").addClass("Hidden");

            count += 1;
            
        })

    }

    function GetLastIDCard(DataCards) {

        let IDs = [];
        let count = 0;

        DataCards.forEach( () => {

            IDs.push(DataCards[count].CardID);
            count += 1;
        })

        var maxID = Math.max(...IDs);
        
        return maxID;
    }

    function UpdateWidgetChart(DataChart, DataCards) {
        
        $(DataChart).each(function(id, chart) {

            let ChartHeight = GetChartHeight(chart, DataCards);

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
                        },
                    }
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

    function DeleteCard(CardID) {
        
        let ParamURL = GetParamURL();

        var Data = {
            Action    : 'AdminKPIDashboardEdit',
            Subaction : 'DeleteCard',
            DashboardID : ParamURL.DashboardID,
            CardID : CardID,
        };

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (HTML) {

            }, 'html',
        );
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
}(Core.Admin.KPIDashboardEdit || {}));
