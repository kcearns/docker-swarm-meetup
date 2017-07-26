# Toronto July Docker Swarm Orchestration Meetup

> **Note:** An installation of Vagrant is required for this tutorial. If you have not done so already please go to the [Vagrant downloads page](https://www.vagrantup.com/downloads.html) and install it. A token for Digital Ocean is also required and will be provided at the meetup.

## Preparing Vagrant

> Update the Vagrant file where it says REPLACE_WITH_TOKEN with the token provided.

* Type *vagrant up*
* Type *vagrant ssh*
* Type *cd /vagrant*

## Preparing nodes for Swarm

* Type *make droplet NAME=[firstname][lastname]-node01 _ie. kevincearns-mgmt_
* Type *make droplet NAME=[firstname][lastname]-node02
* Type *make droplet NAME=[firstname][lastname]-node03

Lets see what those commands did!
```
$ docker-machine ls
NAME                 ACTIVE   DRIVER         STATE     URL                        SWARM   DOCKER        ERRORS
kevincearns-node01   -        digitalocean   Running   tcp://104.131.184.6:2376           v17.06.0-ce   
kevincearns-node02   -        digitalocean   Running   tcp://45.55.48.217:2376            v17.06.0-ce   
kevincearns-node03   -        digitalocean   Running   tcp://104.131.31.20:2376           v17.06.0-ce   
```
You now have three servers with Docker installed ready to add to your swarm cluster.

## Swarm Nodes


