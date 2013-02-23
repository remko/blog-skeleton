# My Nanoc Blog Skeleton

This repository contains the skeleton and code for my [nanoc](http://nanoc.ws)-based blog,
hosted at <http://el-tramo.be>. 
More information about this code can be found in my [blog post](http://el-tramo.be/blog/wordpress-to-nanoc).


## Dependencies

The following Ruby gems are required to compile the site:

- nanoc
- rdiscount
- builder
- mime-types
- nokogiri
- htmlentities
- systemu
- coderay
- adsf


## Usage

- Compiling the site: `nanoc compile`
- Viewing (start a local webserver): `nanoc view`
- Checking: `nanoc check ilinks`
- Deploying: `nanoc view`
