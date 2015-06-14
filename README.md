# [My Nanoc Blog Skeleton](https://el-tramo.be/blog-skeleton)

## About

This repository contains the skeleton and code for my [nanoc](http://nanoc.ws)-based blog,
hosted at <https://el-tramo.be>. 
More information about this code can be found in my [blog post](https://el-tramo.be/blog/wordpress-to-nanoc).


## Dependencies

The Ruby gem `bundler` is used to manage the dependencies of the
site on other Gems. After installing the `bundler` gem, run

    bundle install

To install all required gems.

If you want to deploy to Amazon S3 (using the `deploy_aws` task), you also 
need [s3cmd](http://s3tools.org/s3cmd).

## Usage

- Compiling the site: `nanoc compile`
- Viewing (start a local webserver): `nanoc view`
- Checking: `nanoc check --deploy`
- Deploying: `nanoc deploy`

Alternatively, you can use `rake` to perform these (and other)
tasks. For a full list of tasks, run

    rake --tasks


## Notes

- The layouts are written in HAML, which is a bit harder to understand at first. If you
  want to see how the site looked like using ERB, there is a Git tag 'erb' with an (earlier) 
  ERB version of the site.

