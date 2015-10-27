require "yaml"

desc "Deploy the website to the VPS"
task :deploy_vps do
	config = YAML.load_file("nanoc.yaml")
	dst = config["deploy"]["default"]["dst"]
	options = config["deploy"]["default"]["options"].join(" ")
	sh "rsync #{options} dist/ #{dst}"
end
