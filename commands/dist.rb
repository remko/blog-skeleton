usage "dist"

summary "Prepare the site for deployment"
description "Prepare the site for deployment (optimization, ...)"

run do |opts, args, cmd|
	load 'lib/optimizer.rb'
	Optimizer.new("output", "dist").run
end
