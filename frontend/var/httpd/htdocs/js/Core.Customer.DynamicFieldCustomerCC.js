// --
// var/httpd/htdocs/js/Core.Customer.DynamicFieldCustomerCC.js - a module used to handle ajax requests
// Copyright (C) 2019 Service Up, http://www.serviceup.com.br
//
// written/edited by:
// dsilva@serviceup.com.br
// gbolsoni@serviceup.com.br
// --

"use strict";

var Core = Core || {};
Core.Customer = Core.Customer || {};

Core.Customer.DynamicFieldCustomerCC = (function (TargetNS) {

    TargetNS.Init = function (FieldName) {

        function processEmail() {
            var Email = $('#Input_' + FieldName).val().trim();

            if (!Email) return;

            if (!validateEmail(Email)) {
                $('#' + FieldName + 'InvalidError').removeClass('Hidden');
                return;
            } else {
                $('#' + FieldName + 'InvalidError').addClass('Hidden');

                var count = $('#CountCC_' + FieldName).val();
                count = parseInt(count) + 1;

                $('#CountCC_' + FieldName).val(count);

                $('#CCFields_' + FieldName).append(
                    '<tr style="width: 100%;">' +
                        '<td>' + 
                            '<input id="' + FieldName + '_CopyKey_' + count + '" name="' + FieldName + '_CopyKey_' + count + '" type="text" value="' + Email + '" readonly="readonly" style="width: 95%; margin-bottom: 5px; margin-top: 5px;"/>' +
                        '</td>' +
                        '<td style="width: 0%;">' +
                            '<a href="javascript:void(0);" class="RemoveCC">' +
                                '<i class="fa fa-minus-square-o"></i>' +
                            '</a>' +
                        '</td>' +
                    '</tr>'
                );

                $('#CC_' + FieldName).removeClass('Hidden');
                $('#Input_' + FieldName).val('');

                let FieldValue = $('#' + FieldName).val();

                if (FieldValue !== '') {
                    FieldValue += ';';
                }
                FieldValue += Email;

                $('#' + FieldName).val(FieldValue);
            }
        }

        $('#Input_' + FieldName).on('keypress', function (e) {
            if (e.which === 13) {
                e.preventDefault();
                processEmail();
            }
        });

        $('#Input_' + FieldName).on('focusout', function () {
            processEmail();
        });

        $('#CCFields_' + FieldName).on('click', '.RemoveCC', function () {
            var RowCount = $('#CCFields_' + FieldName + ' tr').length;

            let Count = $('#CountCC_' + FieldName).val();

            if (RowCount > 1) {
                $(this).parent().parent().remove();
            } else {
                $(this).parent().parent().remove();
                $('#CC_' + FieldName).addClass('Hidden');
            }

            let FieldValue = '';

            for (var i = 1; i <= Count; i++) {
                if ($('#' + FieldName + '_CopyKey_' + i).val() !== undefined) {
                    if (FieldValue !== '') {
                        FieldValue += ';';
                    }
                    FieldValue += $('#' + FieldName + '_CopyKey_' + i).val();
                }
            }

            $('#' + FieldName).val(FieldValue);
            $('#CountCC_' + FieldName).val(Count - 1);
        });
    };

    function validateEmail(email) {
        const re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    }

    return TargetNS;

}(Core.Customer.DynamicFieldCustomerCC || {}));
