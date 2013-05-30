# A filter to redirect all /git urls to GitHub
class GitLinkFilter < Nanoc::Filter
	identifier :git_link_filter

	def run(content, params = {})
		url_prefix = "https://github.com/#{@config[:github_id]}"
		raw_url_prefix = "https://raw.github.com/#{@config[:github_id]}"

		content = content.gsub(/href="\/git\/([^\/]+)\/tree/, "href=\"#{url_prefix}/\\1/blob/master")
		content = content.gsub(/href="\/git\/([^\/]+)\/snapshot\/(.*)-master\.zip/, "href=\"#{url_prefix}/\\1/archive/master.zip")
		content = content.gsub(/href="\/git\/([^\/]+)\/plain\/([^\/]+)\/?"/, "href=\"#{raw_url_prefix}/\\1/master/\\2\"")
		content = content.gsub(/href="\/git\/([^\/]+)\/?"/, "href=\"#{url_prefix}/\\1/\"")
		content = content.gsub(/href="\/git\/?"/, "href=\"#{url_prefix}/\"")
	end
end
