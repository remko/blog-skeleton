require 'digest/sha1'
require 'fileutils'
require 'pathname'
require 'nokogiri'

class Optimizer
	attr_reader :source, :target

	def sh(args)
		@sh.call(args)
	end

	def initialize(source, target, options = {})
		@source = source
		@target = Pathname(target)
		@sh = options[:sh] || lambda { |args| system args }
		@assets_prefix = options[:assets_prefix] || ""
	end

	def run
		puts "Copying output ..."
		sh "rsync -a --delete-after #{source}/ #{target}/"

		puts "Cachebusting ..."
		mapping = {}

		# Cachebust images
		mapping = Dir.glob("#{target}/**/*.{png,jpg,svg,eot,ttf,ico}").inject(mapping) { |acc, f| cachebust(f, acc) }

		# Cachebust other static files
		mapping = Dir.glob("#{target}/**/*.{pdf,bz2}").inject(mapping) { |acc, f| cachebust(f, acc) }

		# Cachebust JavaScript
		mapping = Dir.glob("#{target}/**/*.{js}").inject(mapping) { |acc, f| cachebust(f, acc) }

		# Process & cachebust CSS
		Dir.glob("#{target}/**/*.css").each do |css_file| 
			css = File.read(css_file)
			css.gsub!(/url\("([^"#]*)([^"]*)"\)/) { |match| css_replace_match(match, $1, $2, css_file, mapping) }
			css.gsub!(/url\('([^'#]*)([^']*)'\)/) { |match| css_replace_match(match, $1, $2, css_file, mapping) }
			File.open(css_file, 'w') { |f| f.write(css) }
		end
		mapping = Dir.glob("#{target}/**/*.css").inject(mapping) { |acc, f| cachebust(f, acc) }

		# Process HTML
		Dir.glob("#{target}/**/*.html").each { |html| html_map_urls(html, mapping) }
	end

	private

	def fingerprint(filename)
		Digest::SHA1.hexdigest(File.read(filename))[0..9]
	end

	def cachebust(file, acc)
		base = Pathname(file).sub_ext ''
		new_file = "#{base}-cb-#{fingerprint(file)}#{Pathname(file).extname}"
		FileUtils.mv(file, new_file)
		acc["/" + Pathname(file).relative_path_from(target).to_s] = "/" + Pathname(new_file).relative_path_from(target).to_s
		acc
	end

	def map_url(url, file, mapping)
		if url
			dir = Pathname("/" + Pathname(file).parent.relative_path_from(target).to_s)
			m = url.match(/([^\?#]*)(.*)/)
			path = "#{dir + m[1]}"
			mapping[path] ? "#{@assets_prefix}#{mapping[path]}#{m[2]}" : url
		end
	end

	def css_replace_match(match, path, suffix, file, mapping)
		dir = Pathname("/" + Pathname(file).parent.relative_path_from(target).to_s)
		path = "#{dir + path}"
		mapped = mapping[path]
		if not mapped
			STDERR.puts "Unable to find #{path}"
			match
		else
			"url(\"#{@assets_prefix}#{mapped}#{suffix}\")"
		end
	end


	def html_map_urls(file, mapping)
		doc = ::Nokogiri::HTML.parse(File.read(file))
		doc.css("a").each do |a|
			a["href"] = map_url(a["href"], file, mapping) if a["href"]
		end
		doc.css("img").each do |img|
			img["src"] = map_url(img["src"], file, mapping) if img["src"]
		end
		doc.css("script").each do |script|
			script["src"] = map_url(script["src"], file, mapping) if script["src"]
		end
		doc.css("link").each do |link|
			link["href"] = map_url(link["href"], file, mapping) if link["href"]
		end
		File.open(file, "w") { |f| f.write(doc.to_html) }
	end
end

class OptimizingRSyncDeployer < ::Nanoc::Extra::Deployers::Rsync
	def initialize(source_path, config, params = {})
		@old_source_path = source_path
		super("dist", config, params)
	end

	def run
		Optimizer.new(@old_source_path, source_path, 
									sh: lambda { |x| run_shell_cmd(x) },
									assets_prefix: @config[:assets_prefix]).run
		super
	end
end

Nanoc::Extra::Deployer.register '::OptimizingRSyncDeployer', :optrsync
