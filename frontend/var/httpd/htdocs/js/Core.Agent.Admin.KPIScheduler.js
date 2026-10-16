// --
// var/httpd/htdocs/js/Core.Agent.Admin.KPIScheduler.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

 Core.Agent.Admin.KPIScheduler = (function (TargetNS) {

    TargetNS.Init = function () {

        $('input[type=radio]').attr('style','display: none !important');

        $('.executeJob').on('click', function(){

            TargetNS.ExecuteKPISchedulerNowAJAX( $(this).attr('data-job-key') );
            
            $(this).children('i:first').remove();
            $(this).text('');
            $(this).append('<i class="fa fa-spinner fa-spin"></i> Enviando e-mail');
            
        });

        Core.UI.Table.InitTableFilter($('#FilterScheduled'), $('#Scheduleds'));
    };

   TargetNS.ExecuteKPISchedulerNowAJAX = function ( JobKey ) {

        var Data = {
            Action: 'AdminKPISchedulerAJAXHandler',
            Subaction: 'ExecuteNow',
            JobKey: JobKey
        };

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {

			if (!Result){
				Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
			}
			else{

                $('.executeJob').each(function(){

                    if( $(this).attr('data-job-key') === JobKey ){

                        $(this).css('color','green');
                        $(this).children('i:first').remove();
                        $(this).text('');
                        $(this).append('<i style="color: green;" class="fa fa-check"></i> Enviado com sucesso');

                        location.reload();
                    }
                });
			}
		});
    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.KPIScheduler || {}));