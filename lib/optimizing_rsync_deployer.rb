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
