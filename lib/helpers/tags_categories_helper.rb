include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Tagging

module TagsCategoriesHelper
	require 'nanoc/helpers/html_escape'
	include Nanoc::Helpers::HTMLEscape

	def slugify(text) 
		text.downcase.gsub(" ", "-").gsub("'","-")
	end

	# Overriding the built-in tags_for
	def tags_for(item, params = {}) 
		links_for(item[:tags], params.update(:rel => "tag"))
	end

	# Overriding the built-in link_for_tag
	def link_for_tag(tag, params = {}) 
		link_for(tag, "tag", params)
	end

	def tag_links(item)
		tags_for item, :base_url => "/blog/tag/", :rel => "tag"
	end

	def category_links(item) 
		links_for(item[:categories], :base_url => "/blog/category/", :rel => "category")
	end

	def category_list
		"<ul>" + all_article_categories.map{|i| "<li>" + link_for(i, "category", "/blog/category/") + "</li>"}.join("\n") + "</ul>"
	end

	def all_article_categories
		@items.map{|i| i[:categories]}.flatten.uniq.compact.sort
	end

	def all_article_tags
		@items.map{|i| i[:tags]}.flatten.uniq.compact.sort
	end

	def articles_with_category(category) 
		sorted_articles.select{|i| i[:categories] and i[:categories].include?(category)}
	end

	def articles_with_tag(tag) 
		sorted_articles.select{|i| i[:tags] and i[:tags].include?(tag)}
	end

	private
		def link_for(name, rel, base_url)
			%[<a href="#{h base_url}#{h slugify(name)}" rel="#{rel}">#{h name}</a>]
		end

		def links_for(values, params = {})
			if values.empty?
				"(none)"
			else
				values.map {|v| link_for(v, params[:rel], params[:base_url]) }.join(", ")
			end
		end

end

