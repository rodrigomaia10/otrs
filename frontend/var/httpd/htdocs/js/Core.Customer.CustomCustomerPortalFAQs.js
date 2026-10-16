// --
// var/http/htdocs/js/Core.Customer.CustomCustomerPortalFAQs.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
// --
// written/edited by:
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};
var CountSubCategory = 0; 
/**
* @namespace Core.Customer.CustomCustomerPortalFAQs
* @memberof Core.Customer
* @author OTRS AG
* @description
*      This namespace contains the special function for ServiceTemplate module.
*/
Core.Customer.CustomCustomerPortalFAQs = (function (TargetNS) {

        /**
        * @name Init
        * @memberof Core.Customer.CustomCustomerPortalFAQs
        * @function
        * @description
        *      This function initializes the module functionality.
        */
        TargetNS.Init = function () {
        };

        function SearchFAQs(CategoryFAQsIDs, FAQTextSearch) {
            
            var Data = {
                Action: 'CustomCustomerPortalFAQs',
                Subaction: 'SearchFAQs',
                CategoryFAQsIDs: JSON.stringify(CategoryFAQsIDs),
                FAQTextSearch: FAQTextSearch,
            };

            $('#BtnFAQSearch').prop('disabled', true); 
            $('#FAQTextSearch').prop('disabled', true); 

            $("#FAQsSolution").empty();
            $("#CardQuestionFAQ").empty();
            $("#CardQuestionFAQ").append("<p class='FaqTitleSearch'>" + Core.Language.Translate('Search results') +"</p>");

            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
    
                if (!Result){
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
                }
                else{

                    var Count = 1;
                  
                    Result.FAQsData.forEach(function(hash) {
                        for (var FAQId in hash) {
                            if (hash.hasOwnProperty(FAQId)) {
                                $("#CardQuestionFAQ").append("<div class='FAQProblemList' data-faq-id='"+FAQId+"'>" + Count + ". " + hash[FAQId] + "</div>");
                                Count++;
                            }                          
                        }                  
                    });

                    if ( Count == 1){
                        $("#CardQuestionFAQ").append("<div class='FAQProblemList'>"+ Core.Language.Translate('No data found') +"</div>");
                    }

                    $('.FAQProblemList').on('click', function () {
                        var FAQId = $(this).data('faq-id');

                        $("*").removeClass("ResponseFAQSelected");

                        $(this).addClass('ResponseFAQSelected');
                   
                        FAQSearchSolution(FAQId);

                    });

                    $("#BackInitialFAQ").removeClass("Hidden");

                    $('#BtnFAQSearch').prop('disabled', false); 
                    $('#FAQTextSearch').prop('disabled', false); 

                }
            });

        };

        function isObjectEmpty(obj) {
            return Object.keys(obj).length === 0 && obj.constructor === Object;
        }

        function FAQSearchSolution(FAQId) {

            var Data = {
                Action: 'CustomCustomerPortalFAQs',
                Subaction: 'SearchFAQSolution',
                FAQID: FAQId,
            };

            $("#FAQsSolution").empty();

            $("#FAQsSolution").append('<span id="AJAXLoaderCustomFAQ" class="AJAXLoaderCustomFAQ"></span>');

           
            Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
    
                if (!Result){
                    Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
                }
                else{
                    $("#FAQsSolution").empty();

                    if( !isObjectEmpty( Result ) ){

                        $.each(Result.AttachmentsOfFAQ, function(index, object) {
                            $("#FAQsSolution").append("<a style='color: #073759;' href='" + Core.Config.Get('Baselink') + "Action=CustomCustomerPortalFAQs;Subaction=DownloadAttachment;ItemID=" + FAQId + ";FileID=" + object.FileID + "'><i class='fa fa-paperclip'></i> " + object.Filename + "</a>");
                        });
                        // $("#FAQsSolution").append("<br/><div class=''>" + Result.FAQResponse + "</div>");
                        $("#FAQsSolution").append("<br/><div class=''> " +
                        "<iframe sandbox='allow-same-origin allow-popups ms-allow-popups allow-popups-to-escape-sandbox' class='FAQField IframeSizeFAQ' id='IframeFAQField1'" + 
                        " onload='window.setTimeout( function (){ CheckIFrameHeight('IframeFAQField1'); }, 500);'" +
                        " src='?Action=CustomerFAQZoom;Subaction=HTMLView;ItemID=" +Result.ItemID+ ";Field=" + Result.FieldID+";" + Result.SessionName + "=" + Result.SessionID + "' style='height: 1000px;'></iframe></div>");

                    }
                }
            });
          
        }

        $('.FAQProblemList').on('click', function () {
            var FAQId = $(this).data('faq-id');

            $("*").removeClass("ResponseFAQSelected");

            $(this).addClass('ResponseFAQSelected'); 

            FAQSearchSolution(FAQId);
        });

        $('#FAQTextSearch').on('keyup', function (event) {
            // Key Enter event
            if (event.which === 13) {               
                var CategoryFAQsIDs = $('#CategoryFAQsIDs').val();
                var FAQTextSearch = $('#FAQTextSearch').val();

                $("#BackInitialFAQ").attr( "href", "?Action=CustomCustomerPortalFAQs" );
                $("#BackInitialFAQ").removeAttr( "onclick" );

                if ( $('#FAQTextSearch').val().trim() === '' ) {
                    event.preventDefault(); 
                    $('#EmptyErrorMessage').show(); 
                }
                else{
                    $('#EmptyErrorMessage').hide(); 

                    SearchFAQs(CategoryFAQsIDs, FAQTextSearch);
                }
            }
        });

        $('#BtnFAQSearch').on('click', function (event) {
            var CategoryFAQsIDs = $('#CategoryFAQsIDs').val();
            var FAQTextSearch = $('#FAQTextSearch').val();

            $("#BackInitialFAQ").attr( "href", "?Action=CustomCustomerPortalFAQs" );
            $("#BackInitialFAQ").removeAttr( "onclick" );

            if ( $('#FAQTextSearch').val().trim() === '' ) {
                event.preventDefault(); 
                $('#EmptyErrorMessage').show(); 
            }
            else{
                $('#EmptyErrorMessage').hide();  

                SearchFAQs(CategoryFAQsIDs, FAQTextSearch);
            }

        });

        $('.CollapseStyleCategoryFAQ').on('click', function () {
            var CategoryID = $(this).attr('data-category-faq-id');
            var $ClickedElement = $(this); 

            var Data = {
                Action: 'CustomCustomerPortalFAQs',
                Subaction: 'SearchFAQCategoryTop10',
                FAQCategoryID: CategoryID,
            };

            $ClickedElement.closest('.FAQCategoryMenu').find('.FAQProblemList, .FAQSubCategoriesBox').remove();

            var Accordion = $(this).parent();
            Accordion.toggleClass('active');
            var Content = Accordion.find('.accordion-content');

            if (Accordion.hasClass('active')) {
                Content.slideDown();
                $(this).find('i.SinalFAQ').removeClass('fa-chevron-down').addClass('fa-chevron-up');

                Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Result) {
    
                    if (!Result){
                        Core.Exception.HandleFinalError(new Core.Exception.ApplicationError("Error! No server response.", 'CommunicationError'));
                    }
                    else{
                      
                        var Count = 1;
                        var MyHTML = '';

                        var Size = Object.keys(Result).length;
                
                        if ( !Size ) {
                            MyHTML += "<div class='FAQProblemList'>Nenhuma dúvida cadastrada.</div>";
                        }

                        for (let Category in Result) {

                            CountSubCategory++;
                            if ( Size >= 1) {
                                MyHTML += '<div class="card-header FAQSubCategoriesBox" data-toggle="collapse" href="#collapse'+CountSubCategory+'"><div class="IconSubCategoryFAQ" aria-expanded="false" aria-controls="collapseExample"><img src="'+ Result[Category][0].ImageCategory +'"></div>'+ Category +'</div>';
                            }

                            MyHTML += '<div class="collapse" id="collapse'+CountSubCategory+'">';
                            Result[Category].forEach(function(value, index) {
                                MyHTML += "<div class='FAQProblemList' data-faq-id='"+value.ItemID+"'>" + (index + 1) + ". " + value.Name + "</div>";
                            });
                            MyHTML += '</div>';
                        }

                        $ClickedElement.parent().parent().append(MyHTML);

                        $('.FAQProblemList').on('click', function () {
                            var FAQId = $(this).data('faq-id');

                            $("*").removeClass("ResponseFAQSelected");

                            $(this).addClass('ResponseFAQSelected');
                    
                            FAQSearchSolution(FAQId);
                        });

                    }
                });
            } else {
                Content.slideUp();
                $(this).find('i.SinalFAQ').removeClass('fa-chevron-up').addClass('fa-chevron-down');
            }    
      
        });

        Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');
    
        return TargetNS;
    }(Core.Customer.CustomCustomerPortalFAQs || {}));