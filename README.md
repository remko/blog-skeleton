# My Nanoc Blog Skeleton

This repository contains the skeleton and code for my [nanoc](http://nanoc.ws)-based blog,
hosted at <http://el-tramo.be>. 
More information about this code can be found in my [blog post](http://el-tramo.be/blog/wordpress-to-nanoc).


## Dependencies

The Ruby gem `bundler` is used to manage the dependencies of the
site on other Gems. After installing the `bundler` gem, run

    bundle install

To install all required gems.


## Usage

- Compiling the site: `nanoc compile`
- Viewing (start a local webserver): `nanoc view`
- Checking: `nanoc check --deploy`
- Deploying: `nanoc deploy`

Alternatively, you can use `rake` to perform these (and other)
tasks. For a full list of tasks, run

    rake --tasks


