# Which Branch?

We work in _develop_.

# Running the site

    $ ./go.sh

From the prompt you see run:

    $ grunt serve

# Deploying the site

You will need to create a `.env` file containing the AWS credentials one-time.
Run `cp dotenv.template .env` then edit `.env` and add the missing credentials, available from one of the partners.

    $ grunt deploy

