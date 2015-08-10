# Which Branch?

We work in _develop_.

# Running the site

    $ grunt serve

If that doesn't work for you, make sure you've done the one-time set up from this directory:

    $ npm install
    $ bundle install

If you don't have `bundle`, run

    $ gem install bundler

You'll also need command-line PHP 5 to run `composer` to install PHP dependencies (such as the Mailgun client).

# Deploying the site

    $ grunt deploy

# Static files

If you want to upload anything for a customer, put it in _/srv/underscore.io/public/htdocs/files/_, which is mapped to _http://underscore.io/files_.
