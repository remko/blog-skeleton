# A filter to split on <!-- more --> delimiters, and optionally
# leave a link to the full article.
class MoreFilter < Nanoc::Filter
	identifier :more_filter

	def run(content, params = {})
		strip_more(content, params)
	end
end
