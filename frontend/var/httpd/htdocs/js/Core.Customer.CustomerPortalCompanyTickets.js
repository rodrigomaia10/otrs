// --
// var/http/htdocs/js/Core.Customer.CustomerPortalCompanyTickets.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

/**
* @namespace Core.Customer.CustomerPortalCompanyTickets
* @memberof Core.Customer
* @author OTRS AG
* @description
*      This namespace contains the special function for ServiceTemplate module.
*/
Core.Customer.CustomerPortalCompanyTickets = (function (TargetNS) {

    /**
    * @name Init
    * @memberof Core.Customer.CustomerPortalCompanyTickets
    * @function
    * @description
    *      This function initializes the module functionality.
    */

    TargetNS.Init = function () {

        var Star = '.StarAvaliation',
        Selected = '.SelectedStarVote';

        if (GetURLParameter('BulkStatus') == 1) {
            showPopupAlert();
        }
    
        $(Star).on('click', function(){
            var TicketNumber   = parseInt($(this).data('ticket'), 10);
            var Classification = $(this).attr('data-value');
            var Stars          = $(this).parent().children('li.StarAvaliation');

            var Comment = '';
            var Modal   = $('#ModalCommentStarVote');
        
            for (i = 0; i < Stars.length; i++) {
                $(Stars[i]).removeClass('CheckStarTicketVote');
            }

            // $(Selected).each(function(){                
            //     $(this).removeClass('SelectedStarVote');
            // });

            $(this).addClass('SelectedStarVote');

            Core.InBoxLibrary.ConfigGet("CustomerPortal::Core::TicketStarAvaliation::VoteToNoteRequired", function (Result) { 
                if( Result.Data ){
                    var ConfigMapping = JSON.parse( Result.Data );
                    var ConfigNameStar = 'Star';

                    if ( Classification > 1 ){
                        ConfigNameStar = 'Stars';
                    }

                    var NameStarClassification = `${Classification}\ ${ConfigNameStar}`;                   

                    if ( ConfigMapping[NameStarClassification] == 1){                      
                        Modal.css("display", "block");   
                        TargetNS.SaveVoteStar(Classification, TicketNumber, Comment);                           
                    

                    }else{
                        TargetNS.SaveVoteStar(Classification, TicketNumber, Comment);                           

                    }
                    
                }
                      
            });

            // click outside the modal and close it
            const root = document.getElementById("content functions-content");
            root.addEventListener("click", (event) => {
                if ( ! event.target.matches(".CardButtonModalVote") && ! event.target.matches("#AnswerMessageToStar")  && ! event.target.matches("#Evaluation")
                    && ! event.target.matches("#BtnCommentStarVote") && ! event.target.matches("#Evaluation") && ! event.target.matches("#ModalFormStarVote") 
                   ){
                    
                    CloseModal();                 
                }
            });

            $('#ModalClose').on('click', function() {

                CloseModal();             

            });

            $('#BtnCommentStarVote').on('click', function() {
                Comment = $('#AnswerMessageToStar').val();
                Modal.css("display", "none");

                // send the vote
                TargetNS.SaveVoteStar(Classification, TicketNumber, Comment);       
            });
        });

        return 1;
        
        var table = $("#TicketTable").dataTable({  
            initComplete: function (settings, json) {  
                $("#TicketTable").wrap("<div style='overflow:auto; width:100%;position:relative;'></div>");            
            },  
            language: {
                "sEmptyTable": Core.Language.Translate("No record found"),
                "sInfo": Core.Language.Translate("Mostrando de") +" _START_ "+Core.Language.Translate('up until') +" _END_ "+ Core.Language.Translate('in') +" _TOTAL_ "+Core.Language.Translate('tickets'),
                "sInfoEmpty": Core.Language.Translate("Showing 0 to 0 of 0 ticket"),
                "sInfoFiltered": "("+ Core.Language.Translate("Filtered from")+" _MAX_ "+Core.Language.Translate("tickets")+")",
                "sInfoPostFix": "",
                "sInfoThousands": ".",
                "sLengthMenu": Core.Language.Translate("Mostrando") + " _MENU_ " + Core.Language.Translate("tickets"),
                "sLoadingRecords": Core.Language.Translate("Loading..."),
                "sProcessing": Core.Language.Translate("Processing..."),
                "sZeroRecords":  Core.Language.Translate("No record found"),
                "searchPlaceholder": Core.Language.Translate("Search records"),
                "sSearch": "",
                "oPaginate": {
                    "sNext": Core.Language.Translate("Next"),
                    "sPrevious": Core.Language.Translate("Previous"),
                    "sFirst": Core.Language.Translate("First"),
                    "sLast": Core.Language.Translate("Last")
                },
                "oAria": {
                    "sSortAscending": ": Ordenar colunas de forma ascendente",
                    "sSortDescending": ": Ordenar colunas de forma descendente"
                },   
            },
        });     

        if( Core.Config.Get('StateFilter') ){
            var StateFilter  = JSON.parse(Core.Config.Get('StateFilter'));

            //filter by ticket state
            $('#type-filter').change( function() {

                var table = $('#TicketTable').DataTable();

                var valueFilter = $('#type-filter').val();

                var filter = '';
                var size = StateFilter.Data[valueFilter].length;

                var getcolumnEstado = table.column(':contains(Estado)');
                
                $.each( StateFilter.Data[valueFilter], function( index, value ){
                
                    if( (size-1) == index ){

                        filter = filter + value;
                    }
                    else{
                        filter = filter + value + '|';
                    }
                });
            
                table.columns().every( function () {
                    if(valueFilter == 'all'){
                        // $('#TicketTable').dataTable().fnFilter(filter, getcolumnEstado[0][0], true, false); # Old method
                        $('#TicketTable').dataTable().fnFilter(filter.replace( /\(/g, "\\(").replace(/\)/g, "\\)"),getcolumnEstado[0][0], true, false);
                    }
                    else if(valueFilter == 'closed'){

                        $('#TicketTable').dataTable().fnFilter(filter.replace( /\(/g, "\\(").replace(/\)/g, "\\)"),getcolumnEstado[0][0], true, false);
                    }
                    else{

                        $('#TicketTable').dataTable().fnFilter(filter.replace( /\(/g, "\\(").replace(/\)/g, "\\)"),getcolumnEstado[0][0], true, false);
                    }
                } );
            } );

            // To order by Age
            var tableTicket = $('#TicketTable').DataTable();
            var getcolumnAge = tableTicket.column(':contains(Idade)');
            if( getcolumnAge[0][0] ){
                table.fnSort( [ [getcolumnAge[0][0],'asc'] ] ); 
            }

            // To filter the initial state of filters
            var CompanyTicketsInitialFilter  = Core.Config.Get('CompanyTicketsInitialFilter');
            var valueFilter = CompanyTicketsInitialFilter;
            
            $("#type-filter").val(CompanyTicketsInitialFilter);

            var filter = '';
            var size = StateFilter.Data[valueFilter].length;

            var getcolumnEstado = tableTicket.column(':contains(Estado)');
            
            $.each( StateFilter.Data[valueFilter], function( index, value ){
            
                if( (size-1) == index ){

                    filter = filter + value;
                }
                else{
                    filter = filter + value + '|';
                }
            });
        
            tableTicket.columns().every( function () {
                if(valueFilter == 'all'){
                    // $('#TicketTable').dataTable().fnFilter(filter, getcolumnEstado[0][0], true, false); # Old method
                    $('#TicketTable').dataTable().fnFilter(filter.replace( /\(/g, "\\(").replace(/\)/g, "\\)"),getcolumnEstado[0][0], true, false);
                }
                else if(valueFilter == 'closed'){

                    $('#TicketTable').dataTable().fnFilter(filter.replace( /\(/g, "\\(").replace(/\)/g, "\\)"),getcolumnEstado[0][0], true, false);
                }
                else{

                    $('#TicketTable').dataTable().fnFilter(filter.replace( /\(/g, "\\(").replace(/\)/g, "\\)"),getcolumnEstado[0][0], true, false);
                }
            } );
        }
    };

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

     /**
     * @private
     * @name CloseModal
     * @memberof Core.Customer.CustomerPortalMyTickets
     * @function
     * @description
     *      Close modal.
     */
    function CloseModal() {
        var Modal = $('#ModalCommentStarVote');
        $('#AnswerMessageToStar').val('');

        Modal.css("display", "none");
    }

    TargetNS.SaveVoteStar = function (Classification, TicketNumber, Comment) {
        
        var Data = {
            Action: 'MyTickets',
            Subaction: 'SetVoteStar',
            Classification: Classification,
            TN: TicketNumber, 
            Comment: Comment,
        };
  
        Core.AJAX.FunctionCall( Core.Config.Get('CGIHandle'), Data, function (Response) {
            if(!Response){
                alert(Core.Language.Translate('Could not complete vote!'));
            }
            else{
                // window.location.reload();    
            }
        });
    };
    

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.CustomerPortalCompanyTickets || {}));


