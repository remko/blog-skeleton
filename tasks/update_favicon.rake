
desc "Update content/favicon.ico from favicon.svg"
task :update_favicon do
	require 'RMagick'

	img = Magick::Image::read('favicon.svg') { self.background_color = 'none' }.first
	favicon = Magick::ImageList.new
	favicon += [16, 32, 64].map { |size| img.resize(size, size) }
	favicon.write('content/favicon.ico')
end
