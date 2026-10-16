 // --
// var/httpd/htdocs/js/Core.Public.EmailOption.js
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// * gesquetini@beonup.com.br
// * lsnevelin@serviceup.com.br
// * dsilva@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Public = Core.Public || {};

Core.Public.EmailOption = (function (TargetNS) {

    TargetNS.Init = function () {

        let searchParams = new URLSearchParams(window.location.search)
        let action = searchParams.get('Action')
        
        window.onload = function() {

            // check for old versions
            if ( action === 'EmailOption' ) {
                window.history.pushState("object or string", "Title", "/znuny/public.pl?Action=EmailOption");
            }
        }
        
        $('textarea').autoResize();

        $("#Send").click(function(e){  

            e.preventDefault();
            let valid = true;

            $('.Validate_Required').each((index, field) => {
                if (!field.value) {
                    alert('Campo obrigatório');
                    valid = false;
                }
            });

            if (!valid) return;
            if ( !$.trim($("#Article").val()) ) {
                alert("Esté campo não pode estar vazio.");
            }
            else { 
                
                $("#form").submit();
            }
        });
    };

    (function($){
            
        $.fn.autoResize = function(options) {
            
            // Just some abstracted details,
            // to make plugin users happy:
            var settings = $.extend({
                onResize : function(){},
                animate : true,
                animateDuration : 150,
                animateCallback : function(){},
                extraSpace : 20,
                limit: 1000
            }, options);
            
            // Only textarea's auto-resize:
            this.filter('textarea').each(function(){
                
                // Get rid of scrollbars and disable WebKit resizing:
                var textarea = $(this).css({resize:'none','overflow-y':'hidden'}),
                
                    // Cache original height, for use later:
                    origHeight = textarea.height(),
                    
                    // Need clone of textarea, hidden off screen:
                    clone = (function(){
                        
                        // Properties which may effect space taken up by chracters:
                        var props = ['height','width','lineHeight','textDecoration','letterSpacing'],
                            propOb = {};
                            
                        // Create object of styles to apply:
                        $.each(props, function(i, prop){
                            propOb[prop] = textarea.css(prop);
                        });
                        
                        // Clone the actual textarea removing unique properties
                        // and insert before original textarea:
                        return textarea.clone().removeAttr('id').removeAttr('name').css({
                            position: 'absolute',
                            top: 0,
                            left: -9999
                        }).css(propOb).attr('tabIndex','-1').insertBefore(textarea);
            
                    })(),
                    lastScrollTop = null,
                    updateSize = function() {
            
                        // Prepare the clone:
                        clone.height(0).val($(this).val()).scrollTop(10000);
            
                        // Find the height of text:
                        var scrollTop = Math.max(clone.scrollTop(), origHeight) + settings.extraSpace,
                            toChange = $(this).add(clone);
                
                        // Don't do anything if scrollTip hasen't changed:
                        if (lastScrollTop === scrollTop) { return; }
                        lastScrollTop = scrollTop;
            
                        // Check for limit:
                        if ( scrollTop >= settings.limit ) {
                            $(this).css('overflow-y','');
                            return;
                        }
                        // Fire off callback:
                        settings.onResize.call(this);
            
                        // Either animate or directly apply height:
                        settings.animate && textarea.css('display') === 'block' ?
                            toChange.stop().animate({height:scrollTop}, settings.animateDuration, settings.animateCallback)
                            : toChange.height(scrollTop);
                    };
                
                // Bind namespaced handlers to appropriate events:
                textarea
                    .unbind('.dynSiz')
                    .bind('keyup.dynSiz', updateSize)
                    .bind('keydown.dynSiz', updateSize)
                    .bind('change.dynSiz', updateSize);
            });
            
            // Chain:
            return this;
        };
    })(jQuery);

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Public.EmailOption || {}));
