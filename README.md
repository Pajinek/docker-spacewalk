# Spacewalk nightly

Official documentation: https://fedorahosted.org/spacewalk/
Docker image: https://hub.docker.com/r/pajinek/docker-spacewalk/

## How to run by Ansible

The way how to install Spacewalk nightly that takes 3 minute.

At first step you have to create file "config/hosts.ini" with list of hostname, where Spacewalk will be installed by Ansible. Only plain text format in hosts.ini:

```
host1.s1.example.com
host1.s2.example.com
```

Installation is realized in LXC container by Docker's images and due to it is needed to have installed Docker service on host(s) or you can run following script which prepares enviroment:

```
ansible-playbook -i config/hosts.ini spacewalk.yaml -tags "prepare"
```

If system is prepared, run this Ansible script that will install one instance Docker with postgresql and one with Spacewalk nightly.

```
ansible-playbook -i config/hosts.ini spacewalk.yaml
```

Now Spacewalk runs on all systems in "config/hosts.ini"
