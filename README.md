# Spacewalk

* Official documentation: https://fedorahosted.org/spacewalk/
* Docker image: https://hub.docker.com/r/pajinek/docker-spacewalk/

## How to run in Docker

At first you need installed postgresql. Easy way to use Docker image for creating database:
(PostreSQL has to have installed postgresql-pltcl)

```
docker run -d --name spacewalk-postgresql.docker -h spacewalk-postgresql.docker \
        -e POSTGRES_PASSWORD=password postgres:9.4
docker exec spacewalk-postgresql.docker /bin/bash -c \
        "apt update && apt install postgresql-pltcl-9.4 -y"
docker restart spacewalk-postgresql.docker
```

Now you can run installation of Spacewalk following command:

```
docker run -it --link spacewalk-postgresql.docker:postgresql-host \
         -e POSTGRES_PASSWORD=password pajinek/docker-spacewalk:nightly
```
Available versions:

 * Spacewalk Nightly PostgreSQL - `spacewalk:nightly`
 * Spacewalk 2.7 PostgreSQL - `spacewalk:2.7`  or `spacewalk:latest`
 * Spacewalk 2.6 PostgreSQL - `spacewalk:2.6`
 * Spacewalk 2.5 PostgreSQL - `spacewalk:2.5`

## How to run by Ansible

The way how to install Spacewalk nightly that takes 3 minute.

At first step you have to create file "config/hosts.ini" with list of hostname, where Spacewalk will be installed by Ansible. Only plain text format in hosts.ini:

```
[spacewalk]
spacewalk.example.com

[proxy]
proxy.s1.example.com host=spacewalk.example.com
proxy.s2.example.com host=spacewalk.example.com

[client]
client1.s1.example.com host=proxy.s1.example.com
client2.s1.example.com host=proxy.s1.example.com
server1.s2.example.com host=proxy.s2.example.com
server2.s2.example.com host=proxy.s2.example.com
```

Installation is realized in LXC container by Docker's images and due to it is needed to have installed Docker service on host(s) or you can run following script which prepares enviroment:

```
ansible-playbook -i config/hosts.ini spacewalk.yaml -tags "prepare"
```

If system is prepared, run this Ansible script that will install one instance Docker with postgresql and one with Spacewalk latest version.

```
ansible-playbook -i config/hosts.ini spacewalk.yaml
```

If you want to install old version or nightly version, you can define image for installation following form

```
ansible-playbook -i config/hosts.ini spacewalk.yaml -e "docker_image=pajinek/docker-spacewalk:2.6"
```

```
ansible-playbook -i config/hosts.ini spacewalk.yaml -e "docker_image=pajinek/docker-spacewalk:nightly"
```


After installation is completed, go to fill data for first login by webui.
If you login to Spacewalk create needed channels and distribution mapping for your systems.
In file `group_vars/all` change following variables by filled data for authentization.

```
spacewalk_user: "admin"
spacewalk_pass: "passadmin"
```

And now you can configure proxy and register clients to spacewalk through
these proxies.


```
ansible-playbook -i config/hosts.ini proxy.yaml
ansible-playbook -i config/hosts.ini client.yaml
```
