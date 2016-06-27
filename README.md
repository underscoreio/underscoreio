# Which Branch?

We work in _develop_.

# Running the site

    $ ./go.sh
    
From the prompt you see

    $ grunt serve

If that doesn't work for you, make sure you've done the one-time set up from this directory:

    $ npm install

# Deploying the site

    $ grunt deploy

If deploy doesn't work, check you have given Noel or Dave your public key. If you use a key name other than `id_rsa`, you'll need to add the key to your agent using:

```
$ ssh-add
```
which will give something similar to:

```
Identity added: /Users/jonoabroad/.ssh/identity (/Users/jonoabroad/.ssh/identity)
```

As an FYI `grunt depoy` runs the following `rsync --progress -a --delete --exclude files -e "ssh -q" underscoreio/ admin@underscore.io:underscore.io/public/htdocs/`.


# Static files

If you want to upload anything for a customer, put it in _/srv/underscore.io/public/htdocs/files/_, which is mapped to _http://underscore.io/files_.

For example:

    $ scp essential-slick-3-preview.pdf  underscore.io:/srv/underscore.io/public/htdocs/files/essential-slick-3-preview.pdf
