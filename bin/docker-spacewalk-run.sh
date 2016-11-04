#!/usr/bin/bash

# run spacewalk in docker
# docker run -it -p 5432:5432 -e POSTGRES_PASSWORD=redhat --name=spacewalk-postgresql postgres
# docker run -it -e POSTGRES_PASSWORD=redhat --name spacewalk-server -h spacewalk-server --link spacewalk-postgresql:spacewalk-postgresql  spacewalk

# setup spacewalk
[ -f /root/spacewalk-installation-done ] || \
/root/docker-spacewalk-setup.sh

# start httpd
httpd -k start

# start cobblerd
/usr/bin/python -s /usr/bin/cobblerd

# start taskomatic
/usr/sbin/taskomatic start

# start rhn-search
rhn-search start

# start tomcat
/usr/libexec/tomcat/server start 
