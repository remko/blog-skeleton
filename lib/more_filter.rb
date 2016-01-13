#
# A filter to process <!-- more --> delimiters.
# - In 'strip' mode, splits on <!-- more --> delimiters, and optionally
#   leaves a link to the full article.
# - In 'replace' mode, replaces <!-- more --> with a #more anchor.
#
class MoreFilter < Nanoc::Filter
	identifier :more_filter

	def run(content, params = {})
		if params[:mode] == :replace
			replace_more(content, more_url: item.path)
		else
			strip_more(content, more_url: item.path)
		end
	end
end
