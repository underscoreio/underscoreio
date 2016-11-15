# Which Branch?

We work in _develop_.

The public web site is _master_.

# Running the site

    $ ./go.sh

From the prompt you see run:

    $ grunt serve

# Deploying the site

The site is deployed on push to master via Travis.

To deploy manually, define the following environment variables:

- `AWS_KEY`
- `AWS_SECRET`

...and pass then unencrypted to docker.

NB: These are already [encrypted for Travis](https://docs.travis-ci.com/user/environment-variables/#Encrypted-Variables) in the `.travis.yml` file.


