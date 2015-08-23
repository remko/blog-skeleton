/* global jQuery */

(function ($) {
	// Clicking menus without a link but with children expands
	$('.main-navigation .menu-item-has-children > a:not([href])')
		.attr('href', 'javascript:void(0)') // eslint-disable-line no-script-url
		.click(function (ev) {
			$(ev.target).next('button').trigger('click');
		});

	////////////////////////////////////////////////////////////////////////////////	
	// Infinite scroll
	////////////////////////////////////////////////////////////////////////////////	
	
	if ($('body').hasClass('infinite-scroll')) {
		// Checks if an element is only a page scroll away
		var isAlmostVisible = function ($el) {
			var windowHeight = $(window).height();
			var windowTop = $(window).scrollTop();
			var windowBottom = windowTop + windowHeight;
			var elTop = $el.offset().top;
			var elBottom = elTop + $el.height();
			return (elTop >= windowTop && elTop <= windowBottom + windowHeight) 
				|| (elBottom >= windowTop - windowHeight && elBottom <= windowBottom);
		}

		// Simple implementation of throttle. Only works once.
		var throttled;
		var throttle = function (f, timeout) {
			return function () {
				if (!throttled) {
					throttled = window.setTimeout(function () {
						f();
						throttled = undefined;
					}, timeout);
				}
			}
		}

		// Visibility toggling
		$.fn.setVisible = function() {
			return this.css('visibility', 'visible');
		};

		$.fn.setInvisible = function() {
			return this.css('visibility', 'hidden');
		};

		// Extracts the URL of the next page from the navigation bar
		var getNextPageURL = function () {
			return $('main nav').find('.current').next('a').attr('href');
		}

		// Hide the navigation bar
		var $nav = $('main nav').setInvisible();

		// Initialize the 'next page' URL
		var nextPageURL = getNextPageURL();

		// Checks if we need to fetch the next page, and fetch if so
		var fetchNextPageIfNecessary = throttle(function() {
			if (isAlmostVisible($nav) && nextPageURL) {
				fetchPage(nextPageURL);
			}
		}, 300);

		// Fetches the page at the given URL, and append its articles
		var fetchPage = function (url) {
			$(window).off('scroll', fetchNextPageIfNecessary);
			$nav
				.html('<div class=\'nav-links\'><div class=\'spinner\'/></div>')
				.setVisible();
			$.ajax(url, { cache: false }).then(function (response) {
				$.each($.parseHTML(response), function (i, el) {
					var $main = $(el).find('main');
					if ($main.length) {
						// Append all the `article` elements.
						$main.find('article')
							.fadeIn(300)
							.insertAfter($('main article').last());

						// Update navbar
						$nav.replaceWith($main.find('nav'))
						$nav = $('main nav').setInvisible();

						// Get the URL for the next page to be fetched.
						nextPageURL = getNextPageURL();
						if (nextPageURL) {
							$(window).on('scroll', fetchNextPageIfNecessary);
						}
						else {
							// We loaded the last page. Hide the navbar completely.
							$nav.hide();
						}
					}
				});
			});
		}

		if (nextPageURL) {
			$(window).on('scroll', fetchNextPageIfNecessary);
		}
		else {
			$nav.hide();
		}
	}
})(jQuery);
