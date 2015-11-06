---
---
(function (window) {
	<% require 'json' %>
	window.searchData = <%= JSON.generate(search_index(items.select { |i| is_content?(i) })) %>;
	document.querySelector("#search-form .search-field").disabled = false;
	document.querySelector("#search-form .search-submit").disabled = false;
})(window);
