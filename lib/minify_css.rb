require 'cssminify'

# A filter to minify CSS
class MinifyCSSFilter < Nanoc::Filter
	identifier :minify_css

	def run(content, params = {})
		CSSminify.compress(content)
	end
end
