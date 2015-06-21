require 'nokogiri'
require 'image_size'
require 'pathname'

class ImageSizeFilter < Nanoc::Filter
	type :text
	identifier :image_size
 
  def run(content, params={})
		pathname = Pathname.new(assigns[:item].identifier).parent
		image_paths = (params[:paths] || ["content"])
		doc = ::Nokogiri::HTML.parse(content)
		doc.css('img')
			.select { |img| img.has_attribute?('src') && !img['src'].start_with?("http") }
			.select { |img| !img.has_attribute?('width') && !img.has_attribute?('height')}
			.each do |img|
				image_path = image_paths
					.map { |p| p + (pathname + img['src']).to_s }
					.detect { |p| File.exist?(p) }
				if image_path
					size = ImageSize.path(image_path)
					img[:width] = size.width
					img[:height] = size.height
				else
					puts "File doesn't exist #{img['src']}"
				end
			end
		doc.to_html
  end
end
