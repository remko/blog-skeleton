usage "dist"

summary "Prepare the site for deployment"
description "Prepare the site for deployment (optimization, ...)"

class Dist < ::Nanoc::CLI::CommandRunner
	def run
		load 'lib/optimizer.rb'
		load_site
		Optimizer.new(
			"output", "dist", 
			assets_prefix: site.config[:deploy][:default][:assets_prefix]).run
	end
end

runner Dist
