# Which Branch?

We work in _develop_.

# Running the site

    $ ./go.sh

From the prompt you see run:

    $ grunt serve

If that doesn't work for you, make sure you've done the one-time set up from this directory:

    $ npm install

# Deploying the site

You will need to create a `.env` file containing the AWS credentials one-time.
Run `cp dotenv.template .env` then edit `.env` and add the missing credentials, available from one of the partners.

    $ grunt deploy

