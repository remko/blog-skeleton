usage "update_favicon"

summary "Update favicon from favicon.svg"
description "Update favicon from favicon.svg"

run do |opts, args, cmd|
	require 'httpclient'
	require 'base64'
	require 'json'
	require 'uri'
	require 'nokogiri'

	API_KEY = "<KEY>"
	API_URL = 'https://realfavicongenerator.net/api/favicon'

	FAVICON_HTML_FILE = 'layouts/include/favicon.html'

	FAVICON = File.read('favicon.svg')

	IOS_ICON = Nokogiri::XML(FAVICON)
	IOS_ICON.at_css("#path1")['fill'] = '#FFFFFF'

	data = {
		"favicon_generation" => {
			"api_key" => API_KEY,
			"master_picture" => {
				"type" => "inline",
				"content" => Base64.encode64(FAVICON)
			},
			"files_location" => { "type" => "root" },
			"favicon_design" => {
				"desktop_browser" => {},
				"ios" => {
					"master_picture" => {
						"type" => "inline",
						"content" => Base64.encode64(IOS_ICON.to_xml)
					},
					"picture_aspect" => "background_and_margin",
					"margin" => "4",
					"background_color" => "#4c4c4b"
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
			"versioning" => {
				"param_name" => "v",
				"param_value" => "#{Time.now.to_i}"
			}
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

