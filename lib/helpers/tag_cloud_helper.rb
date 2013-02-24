include Nanoc::Helpers::Tagging
include Nanoc::Helpers::Blogging

module TagCloudHelper
	
	# Generates a tag cloud for all tags used in articles.
	#
	# @option params [Number] :threshold (1) The minimum number of posts for a tag to include
	#
	# @option params [Number] :minimum_size (80) The font size (in %) of the least occurring tag
	#
	# @option params [Number] :maximumm_size (180) The font size (in %) of the most occurring tag
	#
	# @return The HTML content of the tag cloud
	#		
	def tag_cloud(base_url, params = {}) 
		threshold = (params[:threshold] or 1)
		minimum_font_size = (params[:minimum_size] or 80)
		maximum_font_size = (params[:maximum_size] or 180)
		link_for_tag = (params[:link_for_tag] or (lambda { |x,y| Nanoc::Helpers::Tagging::link_for_tag}))

		# Count tags
		tag_counts = Hash.new(0)
		articles.each do |item|
			item[:tags].each { |tag| tag_counts[tag] += 1 }
		end
		tag_counts.delete_if { |_, v| v <= threshold }

		# Generate tag list
		(_, min_count), (_, max_count) = tag_counts.minmax_by { |k, v| v }
		tag_counts.sort_by {|tag, count| tag}.reduce "" do |result, (tag, count)|
			if max_count == min_count 
				factor = 0.5
			else 
				factor = (Math.log(count) - Math.log(min_count)) / (Math.log(max_count) - Math.log(min_count))
			end
			tag_size = minimum_font_size + (factor*(maximum_font_size - minimum_font_size))
			result << "<span style='font-size: #{tag_size.round}%'>#{link_for_tag.call(tag, base_url)}</span>\n"
		end
	end
end
