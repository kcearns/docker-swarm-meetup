# Toronto July Docker Swarm Orchestration Meetup

> **Note:** An installation of Vagrant is required for this tutorial. If you have not done so already please go to the [Vagrant downloads page](https://www.vagrantup.com/downloads.html) and install it. A token for Digital Ocean is also required and will be provided at the meetup.

## Preparing Vagrant

> Update the Vagrant file where it says REPLACE_WITH_TOKEN with the token provided.

* Type **vagrant up**
* Type **vagrant ssh**
* Type **cd /vagrant**

## Preparing nodes for Swarm

* Type **make droplet NAME=[firstname][lastname]-node01** _ie. kevincearns-mgmt_
* Type **make droplet NAME=[firstname][lastname]-node02**
* Type **make droplet NAME=[firstname][lastname]-node03**

Let's see what those commands did!
```
$ docker-machine ls
NAME                 ACTIVE   DRIVER         STATE     URL                        SWARM   DOCKER        ERRORS
kevincearns-node01   -        digitalocean   Running   tcp://104.131.184.6:2376           v17.06.0-ce   
kevincearns-node02   -        digitalocean   Running   tcp://45.55.48.217:2376            v17.06.0-ce   
kevincearns-node03   -        digitalocean   Running   tcp://104.131.31.20:2376           v17.06.0-ce   
```
You now have three servers with Docker installed ready to add to your swarm cluster.

## Getting comfortable with [Docker Machine](https://docs.docker.com/machine/)

* Type **docker-machine env [firstname][lastname]-node01**
```
$ docker-machine env kevincearns-node01
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://104.131.184.6:2376"
export DOCKER_CERT_PATH="/home/vagrant/.docker/machine/machines/kevincearns-node01"
export DOCKER_MACHINE_NAME="kevincearns-node01"
# Run this command to configure your shell: 
# eval $(docker-machine env kevincearns-node01)
```

Next, run the _eval_ command output by the docker-machine. All _docker_ commands are executing on node01 now. 

Try this:
```
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
b04784fba78d: Pull complete 
Digest: sha256:f3b3b28a45160805bb16542c9531888519430e9e6d6ffc09d72261b0d26ff74f
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/

$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              1815c82652c0        6 weeks ago         1.84kB

$ eval $(docker-machine env -u)
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```

The **-u** in the last command resets your environment back to your Vagrant VM.
If you want to get comfortable moving from node to node and back to Vagrant feel free to take some time now.

## Initialize the Swarm cluster

We first need the IP of node01 to initialize the cluster as it will become a manager server.

* Type **docker-machine ip [firstname][lastname]-node01**

We now need to change our environment to node01

* Type **docker-machine env [firstname][lastname]-node01**

Let's initialize Swarm with the following command:

* docker swarm init --advertise-addr $(docker-machine ip [fistname][lastname]-node01)

```
Swarm initialized: current node (oitw4ompjab8ycb7i9vmv9hcn) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token YOUR_TOKEN 104.131.184.6:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
Initializing Swarm creates your first node. Type **docker node ls** to learn more about your node.
What's its MANAGER STATUS?

Lets add the other two nodes now as workers. Replace YOUR_TOKEN and YOUR_IP with the output from the output of the init command.

* Type **docker-machine ssh [firstname][lastname]-node02 "docker swarm join --token YOUR_TOKEN YOUR_IP:2377"**
* Type **docker-machine ssh [firstname][lastname]-node03 "docker swarm join --token YOUR_TOKEN YOUR_IP:2377"**

```
$ docker node ls
ID                            HOSTNAME             STATUS              AVAILABILITY        MANAGER STATUS
oitw4ompjab8ycb7i9vmv9hcn *   kevincearns-node01   Ready               Active              Leader
w41dma3bfpo1ny6wcdbfiv675     kevincearns-node03   Ready               Active              
y9gcw3iqmg12igrfu8ksuxa5n     kevincearns-node02   Ready               Active  
```

Your Swarm cluster is now ready to do something!

## Creating and managing Swarm services

