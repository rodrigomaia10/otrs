// --
// var/httpd/htdocs/js/Core.Customer.ConsumptionOfHours.js
// Copyright (C) 2019 Service Up, http://serviceup.com.br/
//
// written/edited by:
// * gesquetini@beonup.com.br
// * dsilva@beonup.com.br
// --

"use strict";

// responsive minimizeSidebar
$('#minimizeSidebar').on('click', function(){
	var element = $("body");
  
	//Maximize
	if(element.hasClass('sidebar-mini') == true){
	  $('body').removeClass("sidebar-mini");
	//   $('.ContentResponsive').css('margin-left','20%');
	//   $('.ContentResponsive').css('width','78%');
	  $('.logo-mini').css('display','none');
  
	  // To company name
	  $('#CompanyNameDiv').removeClass("Hidden");
  
	  $(".CardNews" ).attr('style', 'margin-left: -22px !important;');
  
  
	//Minimize
	}else{
	  $('body').removeClass("sidebar-regular");
	  $('body').addClass("sidebar-mini");
	//   $('.ContentResponsive').css('margin-left','7%');
	//   $('.ContentResponsive').css('width','90%');
	  $('.logo-mini').css('display','');
  
	  // To stats view
	  // $(".card-charts" ).attr('style', 'width: 49% !important;');
	  $(".CardNews" ).attr('style', 'margin-left: -118px !important;');
  
	  // To company name
	  $('#CompanyNameDiv').addClass("Hidden");
  
	}
  
  });
var Core = Core || {};
Core.Customer = Core.Customer || {};

/**
 * @namespace Core.Customer.ConsumptionOfHours
 * @memberof Core.Customer
 * @author OTRS AG
 * @description
 *      This namespace contains all functions for CustomerStats.
 */
Core.Customer.ConsumptionOfHours = (function (TargetNS) {

	TargetNS.Init = function () {
		var DataChart = JSON.parse(Core.Config.Get('Chart'));
	
		var chart = new Chart({
			parent: "#chart", // or a DOM element
			title: Core.Language.Translate("Hours spent per month"),
			data: DataChart,
			type: 'line', // or 'line', 'scatter', 'pie', 'percentage','bar'
			height: 250,
			format_tooltip_x: d => (d + '').toUpperCase(),
			format_tooltip_y: d => d + ' h'
		});
	}
 
    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Customer.ConsumptionOfHours || {}));
