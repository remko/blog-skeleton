module MoreHelper
	def strip_more(content, params = {})
		more_index = content.index("<!--more-->")
		if more_index.nil?
			more_index = content.index("<!-- more -->")
		end
		unless more_index.nil?
			return content[0..more_index-1] + more_url(params[:more_url])
		end
		return content
	end

	def replace_more(content, params = {})
		content.gsub(/<!--\s*more\s*-->/, '<a name="more"></a>')
	end

	def more_url(url) 
		if url
			return "<p> <a href=\"" + url + "#more\" class=\"more-link\">Continue reading <span class='screen-reader-text'>post</span></a></p>"
		else
			return ""
		end
	end
end
