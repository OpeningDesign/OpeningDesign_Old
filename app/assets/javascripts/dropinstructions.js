
!function($){
  "use strict";
  /* TODO: totally not configurable right now... */

  function showInstructions() {
    $('.drop_instruction').show();
  }
  function hideInstructions() {
    $('.drop_instruction').hide();
  }

  $().ready(function() {
    /* hide initially */
    hideInstructions();

    /* show/hide drop instruction when dragging files over the browser window */
    $('*:visible').on('dragenter dragover', function(e) {
        showInstructions();
    });
    $('body').on('dragleave dragexit', function(e) {
        if (event.pageX == "0") {
            hideInstructions();
        }
    });
    $('*:visible').on('drop', function(e) {
        hideInstructions();
    });

    /* also show/hide drop instruction when just hovering over
     * TODO: disabled for now, as it shows/hides all of them, not just the one hovering over right now
    $('.dropupload').hover(function(e) {
        showInstructions();
    }, function(e) {
        hideInstructions();
    });
    */
  });

  $.fn.dropinstructions = function(options) {

    return this.each(function() {
      var $this = $(this), options = typeof option == 'object' && option
      /* TODO: we don't do anything useful here :-/ */
    })
  }

}(window.jQuery);
