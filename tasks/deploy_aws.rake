# Deploys the site to Amazon S3 using `s3cmd`

AWS_BUCKET = "el-tramo-be"

desc "Deploy the website to AWS. Use 'deploy_dry=1' to do a dry-run."
task :deploy_aws => :check do
	sh "s3cmd sync --reduced-redundancy --delete-removed output/ s3://#{AWS_BUCKET}/" + (ENV["deploy_dry"] ? " --dry-run" : "")
end
