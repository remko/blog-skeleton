---
---
(function (window) {
	<% require 'json' %>
	window.searchData = <%= JSON.generate(search_index(items.select { |i| is_content?(i) })) %>;
	document.querySelector(".search-form").style.display = "block";
})(window);
