require 'uglifier'

# A filter to uglify JS
class MinifyJSFilter < Nanoc::Filter
	identifier :minify_js

	def run(content, params = {})
		Uglifier.compile(content)
	end
end
