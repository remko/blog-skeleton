# A filter to make all relative URLs absolute
class AbsolutifyURLs < Nanoc::Filter
	identifier :absolutify_urls

	def run(content, params = {})
		base = params[:base]
		doc = ::Nokogiri::HTML.fragment(content)
		doc.css('img').select { |img| img.has_attribute?('src') }.each do |img|
			img[:src] = absolutify_url(img[:src], base)
		end
		doc.css('a').select { |a| a.has_attribute?('href') }.each do |a|
			a[:href] = absolutify_url(a[:href], base)
		end
		doc.to_html
	end

	def absolutify_url(url, base)
		url.start_with?("/") ? "#{base}#{url}" : url
	end
end
