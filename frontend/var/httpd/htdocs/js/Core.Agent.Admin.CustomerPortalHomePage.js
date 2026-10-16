// --
// var/httpd/htdocs/js/Core.Agent.Admin.CustomerPortalHomePage.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.CustomerPortalHomePage
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 */
Core.Agent.Admin.CustomerPortalHomePage = (function (TargetNS) {

    TargetNS.Init = function () {

        var myCodeMirror = CodeMirror.fromTextArea(document.getElementById('RichText2'), {
            lineNumbers: true,
            mode: "html",
            smartIndent: true
        });


        var QuickAcess = `<div class="row">
            <div class="card text-center" style="width: 100%;">
                <div class="card-body">
                    <h5 class="card-title">Quick access</h5>
                    <a class="btn btn-primary" href="javascript:window.open('https://www.google.com');">Search Google (New window)</a>
                    <a class="btn btn-primary" href="javascript:window.open('customer.pl?Action=Services');">Open ticket (New window)</a>
                    <a class="btn btn-primary" href="javascript:window.location.href=customer.pl?Action=CustomerPortalFAQs';">FAQ's (Same window)</a>
                    <a class="btn btn-primary" href="javascript:window.location.href='https://www.google.com';">Search Google (Same window)</a>
                </div>
            </div>
        </div>`;

        var CardsAcess = `<div class="row">

            <div class="col-lg-3 col-md-6 col-sm-6" onclick="window.open('http://www.google.com')">
            
                <div class="card card-stats">
                    <div class="card-body ">
                        <div class="row">
                            <div class="col-5 col-md-3">
                                <div class="text-center"> <img style='' src='https://media.istockphoto.com/vectors/magnifying-glass-in-hand-in-flat-styleicon-of-hand-holding-a-glass-vector-id1167517759?b=1&k=20&m=1167517759&s=170667a&w=0&h=dynmtJOOwD-x57FeEhTDTFp7-sKZ6Ux0q7QlkKB5aEQ='></div>
                            </div>
                            <div class="col-7 col-md-9">
                                <h6 class="card-title">Search Google</h6>
                                <p class="card-text">New window</p>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer "></div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-6" onclick="window.open('customer.pl?Action=Services')">
                <div class="card card-stats" style="background-image: url(https://kinsta.com/pt/wp-content/uploads/sites/3/2019/08/google-search-console-1024x512.png);background-size: cover;">
                    <div class="card-body ">
                        <h6 class="card-title">Open ticket</h6>
                        <p class="card-text">New window</p>
                    </div>
                    <div class="card-footer "></div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-6" onclick="window.location.href='customer.pl?Action=CustomerPortalFAQs'">
                <div class="card card-stats">
                    <div class="card-body ">
                        <div class="row">
                            <div class="col-5 col-md-3">
                                <div class="text-center"> <i class="fa fa-question-circle-o text-primary Card-Icon"></i></div>
                            </div>
                            <div class="col-7 col-md-9">
                                <h6 class="card-title">FAQ's</h6>
                                <p class="card-text">Same window</p>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer "></div>
                </div>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-6" onclick="window.location.href='https://www.google.com'">
                <div class="card card-stats">
                    <div class="card-body ">
                        <h6 class="card-title">Search Google</h6>
                        <p class="card-text">Same window</p>
                    </div>
                    <div class="card-footer "></div>
                </div>
            </div>
        </div>`;

        var CardsAnimeted = `
        <div class="ContainerCardTransition">`+
            `<div class="cardTransition" data-hover="red" data-default="blue">
                <div class="face face1" style="background-color:black">
                    <div class="content">
                        <i class="fa fa-laptop Card-Icon-Big" style="color:#ddd"></i>
                        <h3>Design</h3>
                    </div>
                </div>
                <div class="face face2">
                    <div class="content">
                        <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cum cumque minus iste veritatis provident at.</p>
                            <a href="#">Read More</a>
                    </div>
                </div>
            </div>
            <div class="cardTransition" data-hover="#ddd"  data-default="#333">
                <div class="face face1" >
                    <div class="content">
                    <i class="fa fa-code Card-Icon-Big" style="color:#ddd"></i>
                        <h3>Code</h3>
                    </div>
                </div>
                <div class="face face2">
                    <div class="content">
                        <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cum cumque minus iste veritatis provident at.</p>
                            <a href="#">Read More</a>
                    </div>
                </div>
            </div>
            <div class="cardTransition" data-hover="blue"  data-default="#333">
                <div class="face face1"  >
                    <div class="content">
                        <i class="fa fa-newspaper-o Card-Icon-Big" style="color:#ddd"></i>
                        <h3>Project</h3>
                    </div>
                </div>
                <div class="face face2">
                    <div class="content">
                        <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Quas cum cumque minus iste veritatis provident at.</p>
                            <a href="#">Read More</a>
                    </div>
                </div>
            </div>
        </div>
        `;

        let FlagCode = 0;

        $( "#QuickAcess" ).click(function() {
            FlagCode = 1;

            myCodeMirror.setValue(QuickAcess);
        });

        $( "#CardsAcess" ).click(function() {

            myCodeMirror.setValue(CardsAcess);
        });

        $("#CardsAnimated").click(function(){
            myCodeMirror.setValue(CardsAnimeted);
        })

        
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.CustomerPortalHomePage || {}));