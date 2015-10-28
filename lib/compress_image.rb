require 'fileutils'

class CompressImage < Nanoc::Filter
	identifier :compress_image
	type :binary

	def run(filename, params={})
		if filename.end_with?("png")
			if have("optipng")
				system "optipng -out #{output_filename} -quiet #{filename}"
			else
				STDERR.puts("Warning: Unable to find 'optipng'. Not compressing #{filename}.")
				FileUtils.cp filename, output_filename
			end
		elsif filename.end_with?("jpg")
			if have("jpegtran")
				system "jpegtran -copy none -optimize -progressive -outfile #{output_filename} #{filename}"
			else
				STDERR.puts("Warning: Unable to find 'jpegtran'. Not compressing #{filename}.")
				FileUtils.cp filename, output_filename
			end
		end
	end

	private

	def have(binary)
		exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
		ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
			exts.each do |ext|
				exe = File.join(path, "#{binary}#{ext}")
				return true if File.executable?(exe) && !File.directory?(exe)
			end
		end
		return false
	end
end
