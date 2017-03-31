#!/bin/bash

# run spacewalk in docker
# docker run -it -p 5432:5432 -e POSTGRES_PASSWORD=redhat --name=spacewalk-postgresql postgres
# docker run -it -e POSTGRES_PASSWORD=redhat --name spacewalk-server -h spacewalk-server --link spacewalk-postgresql:spacewalk-postgresql  spacewalk

CHECK_DONE="/root/spacewalk-installation-done"

# set permissions on mounted storages
chown apache.apache -R /var/satellite

# setup spacewalk
[ -f $CHECK_DONE ] || /root/docker-spacewalk-setup.sh && touch $CHECK_DONE

# start cobblerd
/usr/bin/python -s /usr/bin/cobblerd

# start taskomatic
/usr/sbin/taskomatic start

# start rhn-search
rhn-search start

# start osa-dispatcher
/usr/bin/router -c /etc/jabberd/router.xml &
/usr/bin/sm -c /etc/jabberd/sm.xml &
/usr/bin/c2s -c /etc/jabberd/c2s.xml &
/usr/bin/s2s -c /etc/jabberd/s2s.xml &

# start httpd
httpd -k start

# start tomcat
/usr/libexec/tomcat/server start 
