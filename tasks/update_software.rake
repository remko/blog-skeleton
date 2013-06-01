#!/usr/bin/env ruby

# 
# A task for generating software project pages from the README file
# in the project Git repositories.
#
# This task reads in `software_projects` from the top site folder to
# get a list of project specifications to generate pages for.
#

require 'net/http'

GIT_URL_PREFIX = "https://raw.github.com/remko"
PROJECT_PAGE_PREFIX = "content"
PROJECT_INDEX = "content/software.md"

# Helper for creating & tracking projects
$projects = []
def project(id, opts = {})
	$projects << {
		:id => id, 
		:url => "/#{id}", 
		:generate_page => true,
		:add_download_section => true,
		:extra_download_links => [] }.merge(opts)
end

# Read all projects
eval File.open('software_projects.rb').read

# Download the README.md file for the given project from 
# the Git repo
def get_readme(project)
	url = "#{GIT_URL_PREFIX}/#{project}/master/README.md"
	response = Net::HTTP.get_response(URI.parse(url))
	response.class == Net::HTTPOK ? response.body.force_encoding("UTF-8") : nil
end

# Parse a README.md, and return a hash with information 
# about the project
def parse_readme(contents)
	contents.lines.each_with_index do |line, index|
		if md = /^#\s+(.*)/.match(line)
			title = md[1]
			title = md[1] if md = /\[([^\]]+)\](.*)/.match(title)
			return {
				:title => title,
				:body=> contents.lines[index+1..-1].join.lstrip.gsub(/(\]\s*\()http:\/\/el-tramo\.be\//, "\\1/")
			}
		end
	end
	raise RuntimeError
end

def add_screenshots_section(project)
	screenshots = Dir.glob("#{PROJECT_PAGE_PREFIX}/#{project[:id]}/*.png")
	screenshot_thumbs = Dir.glob("#{PROJECT_PAGE_PREFIX}/#{project[:id]}/*.thumb.png")
	return if screenshots.empty? and screenshot_thumbs.empty?
	section = "\n\n## Screenshots\n\n"
	section << "<div class='screenshots'>\n"
	if screenshot_thumbs.empty?
		screenshots.each do |img|
			section << "<img src='/#{project[:id]}/#{File.basename(img)}'/> "
		end
	else
		screenshot_thumbs.each do |img|
			section \
				<< "<a href='/#{project[:id]}/#{File.basename(img).gsub(/\.thumb/, '')}'>" \
				<< "<img src='/#{project[:id]}/#{File.basename(img)}'/>" \
				<< "</a> "
		end
	end
	section << "\n</div>\n\n"
	project[:body] << section
end

def add_download_section(project)
	return unless project[:add_download_section]
	contents = project[:body]
	section = "## Download\n\n"
	project[:extra_download_links].each { |link| section << "- " << link << "\n"}
	section \
		<< "- [Latest Snapshot (Source)](/git/#{project[:id]}/snapshot/#{project[:id]}-master.zip)\n" \
		<< "- [Git Repository](/git/#{project[:id]})\n\n"
	index = contents.index(/^## Requirements/)
	index = contents.index(/^## Prerequisites/) unless index
	index = contents.index(/^## About/) unless index
	index = contents.index(/^## /, index + 1) if index
	if index
		contents.insert(index, section)
	else
		contents << "\n\n" << section
	end
	project[:body] = contents
end

task :update_software do
	project_index = <<-EOS
---
title: Software
layout: page
generated: true
---
This is a list of all my software projects:

- [Swift IM Project](http://swift.im)
EOS

	$projects.each do |project|
		puts "Processing #{project[:id]} ..."
		project.merge!(parse_readme(get_readme(project[:id])))
		project_index << "- [#{project[:title]}](#{project[:url]})\n"
		if project[:generate_page]
			project_page = <<-EOS
---
title: "#{project[:title].gsub(/"/,"\\\"")}"
layout: page
generated: true
---
EOS
			add_download_section(project)
			add_screenshots_section(project)
			project_page << project[:body]
			project_prefix = "#{PROJECT_PAGE_PREFIX}/#{project[:id]}"
			project_page_file = Dir.exists?("#{project_prefix}") ? "#{project_prefix}/index.md" : "#{project_prefix}.md"
			File.open("#{project_page_file}", "w:UTF-8") { |f| f.write project_page }
		end
	end
	File.open("#{PROJECT_INDEX}", "w:UTF-8") { |f| f.write(project_index) }
end
