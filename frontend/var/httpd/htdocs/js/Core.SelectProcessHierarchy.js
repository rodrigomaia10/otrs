// --
// var/httpd/htdocs/js/Core.SelectProcessHierarchy.js
// Copyright (C) 2019 Service Up, http://serviceup.com.br/
// 
// written/edited by:
// * gtiburtino@beonup.com.br
// * jsantos@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.SelectProcessHierarchy = (function (TargetNS) {

    (function($){

        $.fn.selectHierarchy = function(options) {

            var defaults = {
                separator: '::',
                hideOriginal: true,
                placeholder: '------'
            };

            var options = $.extend(defaults, options);
            var obj = $(this);
            var max_depth = 1;

            $(this).nextAll('select').remove();
            
            // Changed to list nonexistent parent processes
            var txt = $(this).text();
            var segments = txt.split(options.separator);
            var depth = segments.length;

            var raiz = obj.find('option').map(function(){

                var val = $(this).val();

                if (val) {

                    var compilation, result;
                    var deflag   = 1;
                    var exist    = 0;
                    var txt      = $(this).text();
                    var segments = txt.split(options.separator);
                    var depth    = segments.length;            

                    while (deflag <= depth){
                            
                        compilation = new RegExp('::' + segments[depth - deflag] + '(.*)', 'gi');

                        result = txt.replace(compilation, "");

                        obj.find('option').map(function(){
                            if ($(this).text() == result) {
                                exist = 1;
                            }
                        });
                        
                        if (exist == 0) {

                            if ( obj[0].id == 'ProcessEntityID' ) {
                                obj[0].options[obj[0].length] = new Option(result, 'root');
                            }
                            else {
                                if ( squeue != null && obj[0].id == 'ServiceID' ) {
                                    obj[0].options[obj[0].length] = new Option(result, 'root');
                                }
                            }
                        }
                        
                        deflag++;
                    }
                }
            });
            
            // End of change
            
            var choices = obj.find('option').map(function(){

                var val = $(this).val();

                if (val) {
                    var txt      = $(this).text();
                    var segments = txt.split(options.separator);
                    var depth    = segments.length;

                    if (depth > max_depth) {
                        max_depth = depth;
                    }
                    
                    var result = {
                        label: txt,
                        short_label: segments[depth-1],
                        value: val,
                        depth: depth,
                        children: []
                    };

                    return result;
                }
            });

            var roots = [];

            // Build up child values
            for (var depth = 1; depth <= max_depth; depth++) {

                $.each(choices, function() {
                    var parent = this;

                    if (parent.depth == depth) {
                        if (depth === 1) {
                            roots.push(this);
                        }

                        $.each(choices, function() {

                            var child = this;
                            if (child.depth == depth+1 && child.label.match("^" + parent.label) == parent.label) {
                                parent.children.push(child);
                            }
                        });
                    }
                });
            }

            if (options.hideOriginal) {
                obj.hide();
            }
            obj.wrap('<span class="drilldown-wrapper" />');
            obj.after('<select class="drilldown-' + obj[0].id + '-1"><option value="">' + options.placeholder + '</option></select>');

            var root_select = obj.next();

            root_select.data('depth', 1);

            $.each(roots, function(){

                var opt = $('<option>');
                opt.val(this.value);
                opt.text(this.short_label);
                opt.data('node', this);
                root_select.append(opt);
            });

            var change_handler = function(){

                var this_select = $(this);
                var opt  = this_select.find('option:selected');
                var node = opt.data('node');

                if (this_select.val()) {
                    obj.val(this_select.val());

                    // Changed here
                    if (this_select.val() != 'root'){
                        $("#" + obj[0].id).trigger("change");
                    }
                    // End change

                }else if (this_select.data('depth') > 1) {
                    obj.val(this_select.prev().val());
                } else {
                    obj.val('');
                }

                this_select.nextAll('select').remove();

                // Check to see if there's any children, if there are we build another select box;
                if (node && node.children.length > 0) {
                    this_select.after('<select><option value="">' + options.placeholder +'</option></select>');

                    var next_select = this_select.next();

                    next_select.addClass('drilldown-' + obj[0].id + '-' + (node.depth + 1));
                    next_select.data('depth', node.depth + 1);

                    $.each(node.children, function(){
                        var opt = $('<option>');
                        opt.val(this.value);
                        opt.text(this.short_label);
                        opt.data('node', this);
                        next_select.append(opt);
                    });

                    next_select.change(change_handler);
                }
            }
            root_select.change(change_handler);

            // After setting up the behavior, set the drilldown select lists to the correct values for
            // forms with a default value.

            // Build an object of the choices keyed by short_label.
            var choices_by_short_label = {};
            $.each(choices, function() {
            choices_by_short_label[(this).short_label] = (this);
            });

            // Break selected label into segments/short_labels
            var selected_label = obj.find(' option:selected').text();
            var segments = selected_label.split(options.separator);

            // Loop over the segments of the selected value and select the appropriate values on the
            // drilldown select lists.
            var counter = 1;
            $.each(segments, function() {
                if(choices_by_short_label[(this)]) {
                    $('select.drilldown-' + obj[0].id + '-' + counter, obj.parent()).val(choices_by_short_label[(this)].value);
                    $('select.drilldown-' + obj[0].id + '-' + counter, obj.parent()).change();
                }
                counter++;
            });
        };
    })(jQuery);

return TargetNS;
}(Core.SelectProcessHierarchy || {}));
