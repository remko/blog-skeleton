/* global $ */

$(function () {
	// Clicking menus without a link but with children expands
	$('.main-navigation .menu-item-has-children > a:not([href])')
		.attr('href', 'javascript:void(0)') // eslint-disable-line no-script-url
		.click(function (ev) {
			$(ev.target).next('button').trigger('click');
		});
});
