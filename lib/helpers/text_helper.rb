require 'htmlentities'

module TextHelper
	@@htmlentities_decoder = HTMLEntities.new

	def decode_html_entities(text)
		@@htmlentities_decoder.decode text
	end
end
