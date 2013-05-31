# Deploys the site to Amazon S3 using `s3cmd`

AWS_BUCKET = "el-tramo-be"

desc "Deploy the website to AWS"
task :deploy_aws => :check do
	sh "s3cmd sync --delete-removed output/ s3://#{AWS_BUCKET}/"
end
