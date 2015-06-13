desc "Update favicon from favicon.svg"
task :update_favicon do
	require 'httpclient'
	require 'base64'
	require 'json'
	require 'uri'

	API_KEY = "<KEY>"
	API_URL = 'https://realfavicongenerator.net/api/favicon'

	FAVICON_HTML_FILE = 'layouts/include/favicon.html'

	data = {
		"favicon_generation" => {
			"api_key" => API_KEY,
			"master_picture" => {
				"type" => "inline",
				"content" => Base64.encode64(File.read('favicon.svg'))
			},
			"files_location" => { "type" => "root" },
			"favicon_design" => {
				"desktop_browser" => {},
				"ios" => {
					"picture_aspect" => "background_and_margin",
					"margin" => "4",
					"background_color" => "#F7EFDB",
					# "startup_image" => {
					# 	"master_picture" => {
								# "type" => "inline",
								# "content" => Base64.encode64(File.read('favicon.svg'))
					# 	},
					# 	"background_color" => "#654321"
					# }
				},
				# "windows" => {
				# 	"picture_aspect" => "white_silhouette",
				# 	"background_color" => "#da532c"
				# },
				# "firefox_app" => {
				# 	"picture_aspect" => "circle",
				# 	"keep_picture_in_circle" => "true",
				# 	"circle_inner_margin" => "5",
				# 	"background_color" => "#456789",
				# 	"manifest" => {
				# 		"app_name" => "My sample app",
				# 		"app_description" => "Yet another sample application",
				# 		"developer_name" => "Philippe Bernard",
				# 		"developer_url" => "http://stackoverflow.com/users/499917/philippe-b"
				# 	}
				# },
				# "android_chrome" => {
				# 	"picture_aspect" => "shadow",
				# 	"manifest" => {
				# 		"name" => "My sample app",
				# 		"display" => "standalone",
				# 		"orientation" => "portrait",
				# 		"start_url" => "/",
				# 		"existing_manifest" => "{\"name\" => \"Yet another app\"}"
				# 	},
				# 	"theme_color" => "#4972ab"
				# },
				# "coast" => {
				# 	"picture_aspect" => "background_and_margin",
				# 	"background_color" => "#136497",
				# 	"margin" => "12%"
				# },
				# "open_graph" => {
				# 	"picture_aspect" => "background_and_margin",
				# 	"background_color" => "#136497",
				# 	"margin" => "12%",
				# 	"ratio" => "1.91:1",
				# },
				# "yandex_browser" => {
				# 	"background_color" => "background_color",
				# 	"manifest" => {
				# 		"show_title" => true,
				# 		"version" => "1.0"
				# 	}
				# }
			},
			"settings" => {
				"compression" => "5",
				"scaling_algorithm" => "Mitchell",
				"error_on_image_too_small" => true
			},
			"versioning" => false
		}
	}

	client = HTTPClient.new

	puts "Generating favicon ..."
	r = client.post(API_URL, data.to_json)
	r.status == 200 or raise r.reason
	result = JSON.parse(r.content)['favicon_generation_result']
	result['favicon']['files_urls'].each do |file_url|
		file = "static/favicon/#{File.basename(URI.parse(file_url).path)}"
		puts "Downloading #{file} ..."
		File.open(file, 'wb') { |f| f.write(client.get_content(file_url)) }
	end
	puts "Writing #{FAVICON_HTML_FILE} ..." 
	File.write(FAVICON_HTML_FILE, result['favicon']['html_code'])

	puts "Done"
end
