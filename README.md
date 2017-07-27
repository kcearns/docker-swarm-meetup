# Toronto July Docker Swarm Orchestration Meetup

> **Note:** An installation of Vagrant is required for this tutorial. If you have not done so already please go to the [Vagrant downloads page](https://www.vagrantup.com/downloads.html) and install it. A token for Digital Ocean is also required and will be provided at the meetup.

 > **Where you see [username] throughout the tutorial replace it with your Meetup.com username**

## Clone tutorial

**git clone https://github.com/kcearns/docker-swarm-meetup.git**

## Preparing Vagrant

1. Update the Vagrant file where it says REPLACE_WITH_TOKEN with the token provided.
2. Type ```vagrant up```
3. Type ```vagrant ssh```
4. Type ```cd /vagrant```

## Preparing nodes for Swarm
#### On the vagrant box

1. Type ```make droplet NAME=[username]-node01```
1. Type ```make droplet NAME=[username]-node02```
1. Type ```make droplet NAME=[username]-node03```

Let's see what those commands did!
```
$ docker-machine ls
NAME                 ACTIVE   DRIVER         STATE     URL                        SWARM   DOCKER        ERRORS
kcearns-node01   -        digitalocean   Running   tcp://104.131.184.6:2376           v17.06.0-ce   
kcearns-node02   -        digitalocean   Running   tcp://45.55.48.217:2376            v17.06.0-ce   
kcearns-node03   -        digitalocean   Running   tcp://104.131.31.20:2376           v17.06.0-ce   
```
You now have three servers with Docker installed ready to add to your swarm cluster.

## Getting comfortable with [Docker Machine](https://docs.docker.com/machine/)

* Type **docker-machine env [username]-node01**
```
$ docker-machine env kcearns-node01
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://104.131.184.6:2376"
export DOCKER_CERT_PATH="/home/vagrant/.docker/machine/machines/kcearns-node01"
export DOCKER_MACHINE_NAME="kcearns-node01"
# Run this command to configure your shell: 
# eval $(docker-machine env kcearns-node01)
```

Next, run the _eval_ command output by docker-machine. All _docker_ commands are executing on node01 now. 

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
When you ran _docker images_ the first time you were on node01, after resetting your environment you were back on your Vagrant VM. Because you ran _docker run hello-world_ on node01 the image isn't local.
If you want to get comfortable moving from node to node and back to Vagrant feel free to take some time now.

## Initialize the Swarm cluster

> **Note:** We will switch from using the _eval_ command to using _docker-machine ssh_ to run our commands on the remote nodes at some point during this section. Both methods are useful and interchangeable as demonstrated here but I find using docker-machine helpful in keeping me aware of which server I am running commands on.

We first need the IP of node01 to initialize the cluster as it will become a manager server.

* Type **docker-machine ip [username]-node01**

We now need to change our environment to node01

* Type **eval $(docker-machine env [username]-node01)**

We'll initialize Swarm with the following command:

* docker swarm init --advertise-addr $(docker-machine ip [username]-node01)

```
Swarm initialized: current node (oitw4ompjab8ycb7i9vmv9hcn) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token YOUR_SWARM_TOKEN 104.131.184.6:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
Initializing Swarm creates your first node. Type **docker node ls** to learn more about your node.

What's its MANAGER STATUS? Did you run the _docker node_ command in your Vagrant VM or on node01?


#### Joining the swarm

1. Replace YOUR_SWARM_TOKEN with the output from the init command.
1. Replace YOUR_IP with the output from the init command.
1. Type **docker-machine ssh [username]-node02 "docker swarm join --token YOUR_SWARM_TOKEN YOUR_IP:2377"**
1. Type **docker-machine ssh [username]-node03 "docker swarm join --token YOUR_SWARM_TOKEN YOUR_IP:2377"**

```
$ docker node ls
ID                            HOSTNAME             STATUS              AVAILABILITY        MANAGER STATUS
oitw4ompjab8ycb7i9vmv9hcn *   kcearns-node01   Ready               Active              Leader
w41dma3bfpo1ny6wcdbfiv675     kcearns-node03   Ready               Active              
y9gcw3iqmg12igrfu8ksuxa5n     kcearns-node02   Ready               Active  
```

Your Swarm cluster is now ready to do something!

## Creating Swarm services

We will create an nginx service that runs on port 80 and set the number of desired replicas at 3. 

* Type **docker-machine ssh [username]-node01 "docker service create --name nginx --replicas 3 --publish 80:80 nginx"**

If you run the **docker service ls** command you should see the service info below:

```
$ docker-machine ssh kcearns-node01 "docker service ls"
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
thzhheud4025        nginx               replicated          3/3                 nginx:latest        *:80->80/tcp
```

Lets try it out:

```
$ curl http://$(docker-machine ip [username]-node01)
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

You can also put the IP in your browser and get the more familiar "Welcome to Nginx"

## Managing Swarm services

Reset your environment back to your Vagrant VM.

* Type **eval $(docker-machine env -u)**

We will run the _service inspect_ command on the _nginx_ service to view details.

* Type **docker-machine ssh [username]-node01 "docker service inspect nginx --pretty"**

We can easily scale our service now using the _service scale_ commmand.

* Type **docker-machine ssh [username]-node01 "docker service scale nginx=1"**

Inspect the _nginx_ service again and notice how the number of Replics is now 1.
Try the curl commmand you used earlier. Change the node to node02 and node03.
You'll notice that regardless of the node you hit the Nginx page is returned. This is because Swarm uses mesh routing.
[UCP External L4 Load Balancing - Docker Routing Mesh](https://success.docker.com/Architecture/Docker_Reference_Architecture%3A_Designing_Scalable%2C_Portable_Docker_Container_Networks#routingmesh)

Run the _service scale_ command again and lets get our replicas back to 3.

Lets add another service.

* Type **docker-machine ssh [username]-node01 "docker service create --name redis --replicas 3 redis:3.2.9"**

```
$ docker-machine ssh [username]-node01 "docker service ls"
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
7vd3hc3jcf89        redis               replicated          3/3                 redis:3.2.9         
opq6mjhpd11p        nginx               replicated          3/3                 nginx:latest        *:80->80/tcp
```

Lets upgrade the _redis_ service.

* Type **docker-machine ssh [username]-node01 "docker service update --image redis:4.0.0 redis"**

If you run the _service inspect_ command during the update you can view the update status.

```
ID:		7vd3hc3jcf89xs32687suohd4
Name:		redis
Service Mode:	Replicated
 Replicas:	3
UpdateStatus:
 State:		updating
 Started:	3 seconds ago
 Message:	update in progress
Placement:
UpdateConfig:
 Parallelism:	1
 On failure:	pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Update order:      stop-first
RollbackConfig:
 Parallelism:	1
 On failure:	pause
 Monitoring Period: 5s
 Max failure ratio: 0
 Rollback order:    stop-first
 ```
We'll remove the services now.

* Type **docker-machine ssh [username]-node01 "docker service rm redis"**
* Type **docker-machine ssh [username]-node01 "docker service rm nginx"**

Lets clean up our cluster and remove the nodes.

* Type **docker-machine rm [username]-node01**
* Type **docker-machine rm [username]-node02**
* Type **docker-machine rm [username]-node03**
* Type **docker-machine ls**

## References

* [Swarm mode overview](https://docs.docker.com/engine/swarm/)
* [Swarm administration guide](https://docs.docker.com/engine/swarm/admin_guide/)




