// Background Image Fader Script by James Brocklehurst 2010
// Licensed under the MIT License:
// http://www.opensource.org/licenses/mit-license.php

// For full instructions visit http://www.mightymeta.co.uk/blog/

// Version 0.0.1

//Configuration:

var selector = ".odnode";
var node_container = ".node_container";
// CSS Selector/s for element/s you want to apply fade effect to.
var hoverOverSpeed = "300";
// Hover over fade speed (in milliseconds)
var hoverOutSpeed = "500";
// Hover out fade speed (in milliseconds)

// Start JQuery

function setupNodeHoveringStuff() {
	$(node_container).hover(function() {
		var node_menu_ttc = $(this).find('.node_menus');
		var this_node_background = $(this).find('.node_background,');

		//      var node_menu_tt = $(this).find('tt .document_children');
		//fades IN node gradient background

		this_node_background.stop().animate({
			'opacity' : 1
		}, hoverOutSpeed);
		//fades IN node gradient background

		//node_menu (show and fade in)
		node_menu_ttc.css("display", "inline");
		node_menu_ttc.stop().animate({
			'opacity' : 1
		}, hoverOutSpeed);
		//node_menu (show and fade in)
		//
		//

	},

	//2nd Argument of  $(selector).hover  <mouseout>

	function() {

		var node_menu_ttc = $(this).find('.node_menus');
		var this_node_background = $(this).find('.node_background');

		//
		//fades OUT node gradient background
		this_node_background.stop().animate({
			'opacity' : 0
		}, hoverOutSpeed);
		//fades OUT node gradient background
		//

		//node_menu (fade out and hide)
		node_menu_ttc.stop().animate({
			'opacity' : 0
		}, hoverOutSpeed, function() {//(after fade out) = display: none
			node_menu_ttc.css("display", "none");
		});
		//node_menu (fade out and hide)
	});
}

$(document).ready(function() {
  setupNodeHoveringStuff();
});

//end
