# A filter to make all relative URLs absolute
class AbsolutifyURLs < Nanoc::Filter
	identifier :absolutify_urls

	def run(content, params = {})
		base = params[:base] || ""
		item_path = Pathname.new(assigns[:item].path)
		doc = ::Nokogiri::HTML.fragment(content)
		doc.css('img').select { |img| img.has_attribute?('src') }.each do |img|
			img[:src] = absolutify_url(img[:src], base: base, path: item_path)
		end
		doc.css('a').select { |a| a.has_attribute?('href') }.each do |a|
			a[:href] = absolutify_url(a[:href], base: base, path: item_path)
		end
		doc.to_html
	end
end
