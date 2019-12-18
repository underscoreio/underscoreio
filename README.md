# underscore.io

The Underscore web site and blog.

## Which branch/domain?

We work in `master`.

Releases to `underscore.io` must be made from `master`.

Please issue PRs against changes.

## Daily Build

A build and deploy of the master branch is triggered every day at 8am.

## Building the Site

The site is built using a combination
of Ruby, NodeJS, and Python libraries.
Start by running `go.sh`,
which runs everything in a Docker container:

~~~bash
./go.sh
~~~

Now use Rake to build the site:

~~~bash
# Build the site and place in the _site directory
# (will install/update Ruby/NodeJS dependencies on the fly):
rake build

# Build the site, run a web server on localhost, and watch for changes
# (will install/update Ruby/NodeJS dependencies on the fly):
rake serve
~~~

## Deploying the Site

Pushing to master will trigger a build and deploy via CircleCI.com

The site is deployed to Amazon S3
using a Ruby tool called s3_website.
Pushing to `develop` deploys to `beta.underscore.io`.
Pushing to `master` deploys to `underscore.io`.

## CircleCi

To test the CircleCi config:

```
$ circleci local execute --job test-build
```

...or any other job named in the config file.

## Software versions

As of December 2019, we're using:

```
source# /usr/local/bin/rake --version
rake, version 10.4.2

source# /usr/local/bin/ruby --version
ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-linux]

source# /usr/local/bin/bundle --version
Bundler version 1.13.6

source# npm --version
3.10.8
```


