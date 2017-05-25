# underscore.io

The Underscore web site and blog.

## Which branch/domain?

We work in `master`.

Releases to `underscore.io` must be made from `master`.

Please issue PRs against changes.

## Daily Build

A build and deploy of the master branch is triggered Mon-Fri at 8am.
This is via an [AWS Lambda job](https://eu-west-1.console.aws.amazon.com/lambda/home?region=eu-west-1#/functions/CURL?tab=triggers)
called "CURL" using a Circle CI token called "LAMBDA_CRON_CURL".

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

Here's the complete deployment process
Start by implementing and testing a change on `develop`:

~~~bash
git checkout develop
# edit code here...
git add .
git commit -m 'New feature added'
git push
# site published automatically
~~~

When you're happy to release to production, merge onto master.
Here's the sequence using `git-flow` to tag the release:

~~~bash
git checkout develop
git tag --list # workout the next version number
git flow release start VERSIONNUMBER # start a release
git flow release finish VERSIONNUMBER # finish the release, write release note
git push --tags ; git push --all
# site published automatically
~~~

Remember to switch back to develop again when you're done:

~~~bash
git checkout develop
~~~
