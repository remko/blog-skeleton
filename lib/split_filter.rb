# A filter to split a page at a given delimiter.
class SplitFilter < Nanoc::Filter
	identifier :split_filter

	def run(content, params = {})
		split_index = content.index(params[:delimiter])
		case params[:keep]
			when :top
				return content[0..split_index-1]
			when :bottom
				return content[split_index+params[:delimiter].length..-1]
		end
	end
end
