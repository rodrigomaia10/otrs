// --
// var/httpd/htdocs/js/Core.Agent.Admin.Kanban.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// nfreitas@serviceup.com.br
// poliveira@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.Kanban
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 *      This namespace contains the special module functions for the Kanban module.
 */
Core.Agent.Admin.Kanban = (function (TargetNS) {

    /**
     * @private
     * @name SerializeData
     * @memberof Core.Agent.Admin.Kanban
     * @function    
     */
    function SerializeData(Data) {
        var QueryString = '';
        $.each(Data, function (Key, Value) {
            QueryString += ';' + encodeURIComponent(Key) + '=' + encodeURIComponent(Value);
        });
        return QueryString;
    }

    /**
     * @name Redirect
     * @memberof Core.Agent.Admin.Kanban
     * @function
     * @description
     *      Redirect to URL 
     */
    TargetNS.Redirect = function(ObjectType) {
        var URL;

        // redirect to correct url
        URL = Core.Config.Get('Baselink') + 'Action=AdminKanbanTicket;Subaction=Add';
        URL += SerializeData(Core.App.GetSessionInformation());
        window.location = URL;
    };

    /**
     * @name KanbanAddAction
     * @memberof Core.Agent.Admin.Kanban
     * @function
     * @description
     *      Bind event on dynamic field add action field.
     */
    TargetNS.KanbanAddAction = function () {

        $('#KanbanSelect').on('change', function() {
            if ($(this).val() !== null && $(this).val() !== '') {
                Core.Agent.Admin.Kanban.Redirect($(this).val());

                // reset select value to none
                $(this).val('');
            }
        });
    };

    /**
     * @name ShowContextSettingsDialog
     * @memberof Core.Agent.Admin.Kanban
     * @function
     * @description
     *      Bind event on Setting button.
     */
    TargetNS.ShowContextSettingsDialog = function() {
        $('#ShowContextSettingsDialog').on('click', function (Event) {
            Core.UI.Dialog.ShowContentDialog($('#ContextSettingsDialogContainer'), Core.Language.Translate("Settings"), '20%', 'Center', true,
                [
                    {
                        Label: Core.Language.Translate("Save"),
                        Type: 'Submit',
                        Class: 'Primary'}
                ]);
            Event.preventDefault();
            Event.stopPropagation();
            return false;
        });
    }

    /**
     * @name KanbanDelete
     * @memberof Core.Agent.Admin.Kanban
     * @function
     * @description
     *      Bind event on delete button.
     */
    TargetNS.KanbanDelete = function() {
        $('.KanbanDelete').on('click', function (Event) {

            if (window.confirm(Core.Language.Translate("Do you really want to delete this Kanban? ALL associated data will be LOST!"))) {               

                Core.AJAX.FunctionCall(
                    Core.Config.Get('Baselink'),
                    $(this).data('query-string') + 'Confirmed=1;',
                    function(Response) {
                        
                        if ( Response.Message ) {

                            Core.UI.Dialog.ShowDialog({
                                Title: Core.Language.Translate("Error deleting column!"),
                                HTML: Response.Message,
                                Modal: true,
                                CloseOnClickOutside: false,
                                CloseOnEscape: false,
                                PositionTop: '20%',
                                PositionLeft: 'Center',
                                Buttons: [{
                                    Label: 'OK',
                                    Type: 'Close',                    
                                }]
                            });

                        } else {

                            Core.UI.Dialog.ShowDialog({
                                Title: Core.Language.Translate("Delete Kanban"),
                                HTML: Core.Language.Translate("Deleting the field and its data. This may take a while..."),
                                Modal: true,
                                CloseOnClickOutside: false,
                                CloseOnEscape: false,
                                PositionTop: '20%',
                                PositionLeft: 'Center',
                                Buttons: []
                            });
                            
                            window.location.reload();
                        }
                       
                    }
                );
            }
    

            // don't interfere with MasterAction
            Event.stopPropagation();
            Event.preventDefault();
            return false;
        });
    };

    /**
     * @name KanbanCopy
     * @memberof Core.Agent.Admin.Kanban
     * @function
     * @description
     *      Bind event on kanban column copy button.
     */
    TargetNS.KanbanCopy = function() {
        $('.KanbanCopy').on('click', function (Event) {

                Core.AJAX.FunctionCall(
                    Core.Config.Get('Baselink'),
                    $(this).data('query-string') + 'Confirmed=1;',                    
                    function() {
                        window.location.reload();
                    }
                );
           
            Event.stopPropagation();
            Event.preventDefault();
            return false;
        });
    };


    /**
     * @name Init
     * @memberof Core.Agent.Admin.Kanban
     * @function
     * @description
     *       Initialize module functionality
     */
    TargetNS.Init = function () {

        // Initialize JS functions
        TargetNS.KanbanAddAction();
        TargetNS.ShowContextSettingsDialog();
        TargetNS.KanbanDelete();
        TargetNS.KanbanCopy();

        // Initialize dynamic field filter
        Core.UI.Table.InitTableFilter($('#FilterKanbans'), $('#KanbansTable'));

    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.Kanban || {}));
