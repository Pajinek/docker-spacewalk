#!/bin/bash

# run spacewalk in docker
# docker run -it -p 5432:5432 -e POSTGRES_PASSWORD=redhat --name=spacewalk-postgresql postgres
# docker run -it -e POSTGRES_PASSWORD=redhat --name spacewalk-server -h spacewalk-server --link spacewalk-postgresql:spacewalk-postgresql  spacewalk

CHECK_DONE="/root/spacewalk-installation-done"

# setup spacewalk
if [ ! -f $CHECK_DONE ]; then
    if ! /root/docker-spacewalk-setup.sh; then
        echo "Error: can't setup spacewalk. Look at logs."
        exit 1
    fi
    touch $CHECK_DONE
fi

# set permissions on mounted storages
chown apache.apache -R /var/satellite

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
