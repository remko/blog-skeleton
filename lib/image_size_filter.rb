require 'nokogiri'
require 'image_size'
require 'pathname'

class ImageSizeFilter < Nanoc::Filter
	type :text
	identifier :image_size
 
  def run(content, params={})
		item_path = Pathname.new(assigns[:item].path)
		doc = ::Nokogiri::HTML.parse(content)
		doc.css('img')
			.select { |img| img.has_attribute?('src') && !img['src'].start_with?("http") }
			.select { |img| !img.has_attribute?('width') && !img.has_attribute?('height')}
			.each do |img|
				img_path = (item_path + img[:src]).to_s
				item = @items.find { |i| i.path == img_path }
				if item
					size = ImageSize.path(item[:filename])
					img[:width] = size.width
					img[:height] = size.height
				end
			end
		doc.to_html
  end
end
