usage "deploy_aws"

summary "Deploy the website to AWS."
description "Deploy the website to AWS."
flag :n, :dry, "Don't actually deploy" 

run do |opts, args, cmd|
	AWS_BUCKET = "el-tramo-be"
	sh "s3cmd sync --reduced-redundancy --delete-removed output/ s3://#{AWS_BUCKET}/" + (opts[:dry] ? " --dry-run" : "")
end
