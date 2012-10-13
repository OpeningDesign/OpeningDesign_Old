/*
 *     Character Count Plugin - jQuery plugin
 *     Dynamic character count for text areas and input fields
 *    written by Alen Grakalic    
 *    http://cssglobe.com/post/7161/jquery-plugin-simplest-twitterlike-dynamic-character-count-for-textareas
 *
 *    Copyright (c) 2009 Alen Grakalic (http://cssglobe.com)
 *    Dual licensed under the MIT (MIT-LICENSE.txt)
 *    and GPL (GPL-LICENSE.txt) licenses.
 *
 *    Built for jQuery library
 *    http://jquery.com
 *    
 *    Slightly modified by Chris to enable validation-like feedback (new option
 *    validationSelector).
 */

(function($) {

    $.fn.charCount = function(options) {

        // default configuration properties
        var defaults = {
            allowed: 140,
            warning: 25,
            css: 'counter',
            counterElement: 'span',
            cssWarning: 'warning',
            cssExceeded: 'exceeded',
            validationSelector: '.validation_feedback',
            counterText: ''
        };

        var options = $.extend(defaults, options);

        function calculate(obj) {
            var count = $(obj).val().length;
            var available = options.allowed - count;
            if (available <= options.warning && available >= 0) {
                $(obj).next().addClass(options.cssWarning);
            } else {
                $(obj).next().removeClass(options.cssWarning);
            }
            if (available < 0) {
                $(obj).next().addClass(options.cssExceeded);
                $(options.validationSelector).html("Please use " + options.allowed + " characters or less.");
            } else {
                $(obj).next().removeClass(options.cssExceeded);
                $(options.validationSelector).html("");
            }
            $(obj).next().html(options.counterText + available);
        };

        this.each(function() {
            $(this).after('<' + options.counterElement + ' class="' + options.css + '">' + options.counterText + '</' + options.counterElement + '>');
            calculate(this);
            $(this).keyup(function() {
                calculate(this)
            });
            $(this).change(function() {
                calculate(this)
            });
        });

    };

})(jQuery);
