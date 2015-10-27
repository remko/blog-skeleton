require 'digest/sha1'
require 'fileutils'
require 'pathname'
require 'nokogiri'
require 'cssminify'
require 'uglifier'

TARGET_DIR = Pathname("dist")

def fingerprint(filename)
	Digest::SHA1.hexdigest(File.read(filename))[0..9]
end

def cachebust(file, acc)
	base = Pathname(file).sub_ext ''
	new_file = "#{base}-cb-#{fingerprint(file)}#{Pathname(file).extname}"
	FileUtils.mv(file, new_file)
	acc["/" + Pathname(file).relative_path_from(TARGET_DIR).to_s] = "/" + Pathname(new_file).relative_path_from(TARGET_DIR).to_s
	acc
end

def map_url(url, file, mapping)
	if url
		dir = Pathname("/" + Pathname(file).parent.relative_path_from(TARGET_DIR).to_s)
		m = url.match(/([^\?#]*)(.*)/)
		path = "#{dir + m[1]}"
		mapping[path] ? "#{mapping[path]}#{m[2]}" : url
	end
end

def css_replace_match(match, path, suffix, file, mapping)
	dir = Pathname("/" + Pathname(file).parent.relative_path_from(TARGET_DIR).to_s)
	path = "#{dir + path}"
	mapped = mapping[path]
	if not mapped
		STDERR.puts "Unable to find #{path}"
		match
	else
		"url(\"#{mapped}#{suffix}\")"
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

desc "Prepare the site for deployment"
task :dist do
	puts "Copying output ..."
	sh "rsync -a --delete-after output/ #{TARGET_DIR}/"

	puts "Optimizing PNGs ..."
	Dir.glob("#{TARGET_DIR}/**/*.png").each do |png|
		sh "optipng -quiet #{png}"
	end

	puts "Optimizing JPGs ..."
	Dir.glob("#{TARGET_DIR}/**/*.jpg").each do |jpg|
    sh "jpegtran -copy none -optimize -progressive -outfile #{jpg} #{jpg}"
	end
	
	puts "Cachebusting ..."
	mapping = {}

	# Cachebust images
	mapping = Dir.glob("#{TARGET_DIR}/**/*.{png,jpg,svg,eot,ttf,ico}").inject(mapping) { |acc, f| cachebust(f, acc) }

	# Process & cachebust JavaScript
	Dir.glob("#{TARGET_DIR}/**/*.js").each do |js_file|
		js = Uglifier.compile(File.read(js_file))
		File.open(js_file, 'w') { |f| f.write(js) }
	end
	mapping = Dir.glob("#{TARGET_DIR}/**/*.{js}").inject(mapping) { |acc, f| cachebust(f, acc) }

	# Process & cachebust CSS
	Dir.glob("#{TARGET_DIR}/**/*.css").each do |css_file| 
		css = File.read(css_file)
		css.gsub!(/url\("([^"#]*)([^"]*)"\)/) { |match| css_replace_match(match, $1, $2, css_file, mapping) }
		css.gsub!(/url\('([^'#]*)([^']*)'\)/) { |match| css_replace_match(match, $1, $2, css_file, mapping) }
		css = CSSminify.compress(css)
		File.open(css_file, 'w') { |f| f.write(css) }
	end
	mapping = Dir.glob("#{TARGET_DIR}/**/*.css").inject(mapping) { |acc, f| cachebust(f, acc) }

	# Process HTML
	Dir.glob("#{TARGET_DIR}/**/*.html").each { |html| html_map_urls(html, mapping) }
end

