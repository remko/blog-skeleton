class Cachebust < Nanoc::Filter
	identifier :cachebust

	def cachebust(url)
		if url.start_with?("/")
			item = @items.find { |i| i.path == url }
			if item && item.reps[:cache_busted]
				item.reps[:cache_busted].path
			else
				url
			end
		else
			url
		end
	end

	def run(content, params = {})
		type = params[:type] || :html
		if type == :html || type == :html_fragment
			doc = type == :html_fragment ? ::Nokogiri::HTML.fragment(content) : ::Nokogiri::HTML.parse(content)
			doc.css('img').select { |img| img.has_attribute?('src') }.each do |img|
				img[:src] = cachebust(img[:src])
			end
			doc.css('link[rel=stylesheet]').each do |link|
				link[:href] = cachebust(link[:href])
			end
			doc.css('script').select { |s| s.has_attribute?('src') }.each do |script|
				script[:src] = cachebust(script[:src])
			end
			doc.to_html
		elsif type == :css
			content.gsub(/url\(('|"|)([^'")]+)\1\)/i) do |m|
				"url(#{$1}#{cachebust($2)}#{$1})"
			end
		else
			raise "Unknown cachebust type"
		end
	end

	def absolutify_url(url, base)
		url.start_with?("/") ? "#{base}#{url}" : url
	end
end

