# A filter to make all relative URLs absolute
class AbsolutifyCSSURLs < Nanoc::Filter
	identifier :absolutify_css_urls

	def run(content, params = {})
		item_path = Pathname.new(assigns[:item].path)
		content
			.gsub(/url\("([^"#]*)([^"]*)"\)/) do |match| 
				"url(\"#{absolutify_url($1, path: item_path)}#{$2}\")"
			end
			.gsub(/url\('([^'#]*)([^']*)'\)/) do |match| 
				"url('#{absolutify_url($1, path: item_path)}#{$2}')"
			end
	end
end

