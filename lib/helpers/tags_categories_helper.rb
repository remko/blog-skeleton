include Nanoc::Helpers::LinkTo

module TagsCategoriesHelper
	def tag_links(item) 
		links(item[:tags], "tag")
	end

	def category_links(item) 
		links(item[:categories], "category")
	end

	def category_list
		"<ul>" + all_article_categories.map{|i| "<li>" + link(i, "category") + "</li>"}.join("\n") + "</ul>"
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

	def slugify(text) 
		text.downcase.gsub(" ", "-").gsub("'","-")
	end

	private
		def links(items, prefix)
			items.map{|x| link(x, prefix)}.join(", ")
		end

		def link(name, prefix)
			link_to(name, "/blog/" + prefix + "/" + slugify(name))
		end
end

