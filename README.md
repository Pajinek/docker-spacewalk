# docker-spacewalk

## How to run

The way how to install Spacewalk nightly that takes 3 minute.

At first step you have to create file "config/hosts.ini" with list of hostname, where Spacewalk will be installed by Ansible.
Installation is realized in Dockers and due to it needed have installed Docker service or you can run prepare script:

```
ansible-playbook -i config/hosts.ini spacewalk.yaml -tags "prepare"
```

If system is prepared, run following script that install one instance Docker with postgresql and one with Spacewalk nightly.

```
ansible-playbook -i config/hosts.ini spacewalk.yaml
```

Now Spacewalk runs on all systems in "config/hosts.ini"
