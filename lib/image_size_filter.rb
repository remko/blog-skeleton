require 'nokogiri'
require 'image_size'
require 'pathname'

def add_suffix(file, suffix)
	ext = File.extname(file)
	dir = File.dirname(file)
	base = File.basename(file, ext)
	"#{dir}/#{base}#{suffix}#{ext}"
end

def get_suffix(file)
	base = File.basename(file, File.extname(file))
	base.gsub(/^.*@/, '')
end

class ImageSizeFilter < Nanoc::Filter
	type :text
	identifier :image_size
 
  def run(content, params={})
		item_path = Pathname.new(assigns[:item].path)
		doc = ::Nokogiri::HTML.parse(content)
		doc.css('img')
			.select { |img| img.has_attribute?('src') && !img['src'].start_with?("http") }
			.each do |img|
				img_path = (item_path + img[:src]).to_s
				item = @items.find { |i| i.path == img_path }
				if item
					size = ImageSize.path(item[:filename])

					# Image width/height
					if !img.has_attribute?('width') && !img.has_attribute?('height')
						img[:width] = size.width
						img[:height] = size.height
					end

					# Srcset
					alternative_files = Dir[add_suffix(item[:filename], '@*')]
					unless alternative_files.empty?
						srcset = alternative_files.map do |f|
							suffix = get_suffix(f)
							"#{add_suffix(item.path, "@#{suffix}")} #{suffix}"
						end
						srcset << "#{item.path} 1x"
						img[:srcset] = srcset.join(", ")
					end
				end
			end
		doc.to_html
  end
end
