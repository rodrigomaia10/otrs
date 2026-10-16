// --
// var/httpd/htdocs/js/Core.Agent.Admin.CustomerPortalLayout.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * jsantos@serviceup.com.br
// * nfreitas@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace Core.Agent.Admin.CustomerPortalLayout
 * @memberof Core.Agent.Admin
 * @author OTRS AG
 * @description
 */
Core.Agent.Admin.CustomerPortalLayout = (function (TargetNS) {

    TargetNS.Init = function () {

        function onloadErrorLogo( img ){
            if (!img) return;

            var imgTester = new Image();
            imgTester.onerror=onerror = () => {
                // $(img).hide();
                // $("#LogoExample").show();
                // img.attr 
                imgTester.src = "https://storage.googleapis.com/serviceup/%20marca-06.png";
            }
            imgTester.src = img.src;

            $("#dialog").dialog({
                resizable: false,
                modal: true,
                title: "My Awesome Title",
                buttons: {
                    "Do Something": function() {
                        alert("Do something if I was clicked.");
                    },
                    Cancel: function() {
                        alert("Dialog Canceled");
                        $(this).dialog("close");
                    }
                }
            });
          
        }

        // onloadErrorLogo( document.getElementById("LogoPageTopMenu") );

        initListenersEdit();

        var slider = $("#Range");
        var Porcentage = $("#Porcentage");

        $('#Range').on('change', function(){

            $('#Porcentage').text(this.value + '%');
            $('#Opacity').val(this.value);
            $("#BackgroundPage").css("opacity", this.value + '%');
        });

        $( "#ColorMenu" ).change(function() {

            let Color = $(this).val();

            $('.ColorMenu').each(function() {
                $(this).css("color", Color);
            });
        });

        $( "#ColorSubMenu" ).change(function() {

            let Color = $(this).val();

            $('.ColorSubMenu').each(function() {
                $(this).css("color", Color);
            });
        });

        $( "#ColorUserName" ).change(function() {

            let Color = $(this).val();

            $('.ColorUserName').each(function() {
                $(this).css("color", Color);
            });
        });

        $( "#SideBarColor1, #SideBarColor2" ).change(function() {

            let Color1 = $("#SideBarColor1").val();
            let Color2 = $("#SideBarColor2").val();

            $('#Sidebar').css("background", "linear-gradient("+Color1+" 0%, "+Color2+" 80%)");
        });

        $( "#ClickLogo" ).click(function() {

            let URL = $("#ImgLogo").val();

            if ( URL.includes("https") || URL.includes("http") || URL.includes("ftp") ) {
                URL = $("#ImgLogo").val();
            }
            else {
                URL = Core.Config.Get('WebPath') + URL;
            }

            $("#PreviewLogo").attr("src", URL);
            $("#LogoPage").attr("src", URL);
        });

        $( "#ClickBackgroundImage" ).click(function() {

            let URL = $("#ImgBackground").val();

            if ( URL.includes("https") || URL.includes("http") || URL.includes("ftp") ) {
                URL = $("#ImgBackground").val();
            }
            else {
                URL = Core.Config.Get('WebPath') + URL;
            }

            $("#PreviewBackgroundImage").attr("src", URL);
            $("#BackgroundPage").attr("src", URL);
        });

        $( "#NavBarItemColor" ).change(function() {

            let Color = $(this).val();

            $('.ColorMenuTop').each(function() {
                $(this).css("color", Color);
            });
        });

        $( "#SelectedNavBarItemColor" ).change(function() {

            let Color = $(this).val();

            $('.ColorMenuTopSelected').each(function() {
                $(this).css("color", Color);
            });
        });

        $( "#NavBarBackgroundColor" ).change(function() {

            let Color = $(this).val();

            $('#NavBackgroundColor').css("background", Color);
            $('#NavBackgroundColorSide').css("background", Color);

        });

        $( "#MainPanelColor" ).change(function() {

            let Color = $(this).val();

            $('.PageTopMenu').css("background", Color);
            $('.PreviewArea .Page').css("background", Color);

        });

        $( "#BorderNavBarColor" ).change(function() {

            let Color = $(this).val();

            $('#NavBackgroundColor').css('border-bottom','1px solid '+ Color);
            $('#NavBackgroundColorSide').css('border-bottom','1px solid '+ Color);

        });

        $( "#MenuType" ).change(function() {
            var MenuType = 'Side bar';
            if( $(this).val() == '1' ){
                MenuType = 'Top bar';
            }
            var URL = Core.Config.Get('Baselink') + 'Action=AdminCustomerPortalLayout;MenuType='+MenuType;
            window.location = URL;
        });
       
    };

    function initListenersEdit(){

        $("#CardSearchPreview").css("background",$("#BackgroundGradient").val());

        $("#BackgroundGradient").on("change",function(e){
            $("#CardSearchPreview").css("background",$(this).val());
        })

        $("#CardSearchPreview").css("background-color",$("#SearchCardColor").val()); 

        $("#CardSearchPreviewTitle").css("color", $("#SearchCardTitleColor").val() );
        $("#CardSearchPreviewBody").css("color", $("#SearchCardBodyColor").val() );

        $("#SearchCardColor").on("change", function(){
            $("#CardSearchPreview").css("background-color",$(this).val()); 
        });

        $("#SearchCardTitleColor").on("change", function(){
            $("#CardSearchPreviewTitle").css("color",$("#SearchCardTitleColor").val());
         
        });

        $("#SearchCardBodyColor").on("change",function(){
            $("#CardSearchPreviewBody").css("color",$("#SearchCardBodyColor").val());
        })

        if ( $("#SearchCardOption").val() == 1) {
            $("#CardSearchPreview").addClass("CardSearchPreviewFull");
            $("#CardSearchPreview").removeClass("CardSearchPreviewCardItem");
        }else{
            $("#CardSearchPreview").removeClass("CardSearchPreviewFull");
            $("#CardSearchPreview").addClass("CardSearchPreviewCardItem");
        }
        $("#SearchCardOption").on("change",function(){
            if ( $(this).val() == 1) {
                $("#CardSearchPreview").addClass("CardSearchPreviewFull");
                $("#CardSearchPreview").removeClass("CardSearchPreviewCardItem");
            }else{
                $("#CardSearchPreview").removeClass("CardSearchPreviewFull");
                $("#CardSearchPreview").addClass("CardSearchPreviewCardItem");
            }
        });
        
    }

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Agent.Admin.CustomerPortalLayout || {}));