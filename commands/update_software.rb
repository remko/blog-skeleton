usage "update_software"

summary "Update software pages"
description "Update software pages"

run do |opts, args, cmd|
	# 
	# A task for generating software project pages from the README file
	# in the project Git repositories.
	#
	# This task reads in `software_projects` from the top site folder to
	# get a list of project specifications to generate pages for.
	#

	require 'net/http'
	require 'json'

	# require 'openssl'
	# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


	GIT_URL_PREFIX = "https://raw.githubusercontent.com/remko"
	TRAVIS_INFO_URL_PREFIX = "https://api.travis-ci.org/repositories/remko"
	TRAVIS_IMG_URL_PREFIX = "https://api.travis-ci.org/remko"
	TRAVIS_PAGE_URL_PREFIX = "https://travis-ci.org/remko"
	COVERALLS_IMG_URL_PREFIX = "https://coveralls.io/repos/remko"
	COVERALLS_PAGE_URL_PREFIX = "https://coveralls.io/r/remko"
	PROJECT_PAGE_PREFIX = "content"
	PROJECT_INDEX = "content/software.md"
	CI_PAGE = "content/ci.md"

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

	# Check whether we have a Travis build
	def get_travis_image_url(project)
		travis_url = "#{TRAVIS_INFO_URL_PREFIX}/#{project}.json"
		response = Net::HTTP.get_response(URI.parse(travis_url))
		return nil if response.class != Net::HTTPOK
		build_info = JSON.parse(response.body)
		return nil unless build_info["last_build_id"]

		return "#{TRAVIS_IMG_URL_PREFIX}/#{project}.svg"
	end

	# Check whether we have a Coveralls build
	def get_coveralls_image_url(project)
		travis_url = "#{COVERALLS_PAGE_URL_PREFIX}/#{project}"
		response = Net::HTTP.get_response(URI.parse(travis_url))
		return nil if response.class != Net::HTTPOK and response.class != Net::HTTPMovedPermanently
		return "#{COVERALLS_IMG_URL_PREFIX}/#{project}/badge.png?branch=master"
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

	project_index = <<-EOS
---
title: Software
layout: page
generated: true
---
This is a list of all my public software projects:

- [Swift IM Project](http://swift.im) <span class="genericon genericon-external"></span>
EOS

	ci_page = <<-EOS
---
title: Software Build Status
layout: page
generated: true
---
EOS

	$projects.each do |project|
		puts "Processing #{project[:id]} ..."
		project.merge!(parse_readme(get_readme(project[:id])))
		project_index << "- [#{project[:title]}](#{project[:url]})\n"

		if travis_url = get_travis_image_url(project[:id])
			ci_line = "- #{project[:title]} [![Build Status](#{travis_url})](#{TRAVIS_PAGE_URL_PREFIX}/#{project[:id]})"
			if coveralls_url = get_coveralls_image_url(project[:id])
				ci_line << " [![Coverage](#{coveralls_url})](#{COVERALLS_PAGE_URL_PREFIX}/#{project[:id]}?branch=master)"
			end
			ci_line << "\n"
			ci_page << ci_line
		end

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
	File.open("#{CI_PAGE}", "w:UTF-8") { |f| f.write(ci_page) }
end
