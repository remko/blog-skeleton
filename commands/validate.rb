usage "validate"

summary "Validate HTML, feeds, and CSS"
description "Validate HTML, feeds, and CSS"

run do |opts, args, cmd|
	require 'w3c_validators'

	validator = ::W3CValidators::MarkupValidator.new
	results = validator.validate_file("output/index.html")
	results.errors.each { |err| puts "Error: #{err}" }
	results.warnings
		.select { |w| !w.to_s.include?("This interface to HTML5 document checking is obsolete") }
		.select { |w| !w.to_s.include?("does not need a role attribute") }
		.each { |err| puts "Warning: #{err}" }

	validator = ::W3CValidators::FeedValidator.new
	results = validator.validate_file("output/feed.xml")
	results.errors.each { |err| puts "Error: #{err}" }
	results.warnings.each { |err| puts "Warning: #{err}" }

	validator = ::W3CValidators::CSSValidator.new
	results = validator.validate_file("output/css/all.css")
	results.errors.each { |err| puts "Error: #{err}" }
	results.warnings.each { |err| puts "Warning: #{err}" }
end


