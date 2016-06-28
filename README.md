# Which Branch?

We work in _develop_.

# Running the site

    $ ./go.sh
    
From the prompt you see

    $ grunt serve

If that doesn't work for you, make sure you've done the one-time set up from this directory:

    $ npm install

# Deploying the site

Deployment is a bit convoluted, because I don't know any way to get a Docker container and the host to share an `ssh-agent` (at least on OS X I could not get it to work.) Instead the container has `~/.ssh` mounted as `/ssh`. From there you can load your SSH keys into the container's `ssh-agent`.

First, start `ssh-agent`

    $ eval `ssh-agent -s`

Then load your keys

    $ ssh-add /ssh/id_rsa
    
Now deploy

    $ grunt deploy
    
Starting `ssh-agent` and loading keys only needs to be done once per terminal session.

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
