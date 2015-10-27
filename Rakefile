require 'rake/clean'

Dir.glob('tasks/**/*.rake').each { |t| Rake.application.add_import t }

CLEAN.include(["output", "crash.log", "tmp"])

task :default => :build

desc "Initialize workspace. Installs required gems."
task :init do
	sh "bundle install"
end

desc "Build the site"
task :build do
	sh "nanoc compile"
end

desc "Run sanity checks"
task :check do
	sh "nanoc check --deploy"
end

desc "Start built-in webserver"
task :view do
	sh "nanoc view"
end

desc "Deploy the website"
task :deploy => [:check, :dist, :deploy_vps]
