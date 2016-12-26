# Spacewalk nightly

* Official documentation: https://fedorahosted.org/spacewalk/
* Docker image: https://hub.docker.com/r/pajinek/docker-spacewalk/

## Travis test

This docker image, can be runned on Travis CI for testing PR

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

If system is prepared, run this Ansible script that will install one instance Docker with postgresql and one with Spacewalk nightly.

```
ansible-playbook -i config/hosts.ini spacewalk.yaml
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
