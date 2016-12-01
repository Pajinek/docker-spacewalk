#!/bin/bash
# author: Pavel Studenik <pstudeni@redhat.com>

### set postgresql ###
export PGPASSWORD="$POSTGRES_PASSWORD"
export DOCKER_POSTGRESQL=spacewalk-postgresql.docker
DB_USER=spaceuser
DB_PASS=spacepw
DB_NAME=spaceschema

function query() {
    psql -h $DOCKER_POSTGRESQL -U postgres <<< "$1"
}

query "select version()"
query "CREATE USER $DB_USER with password '$DB_PASS';"
query "CREATE DATABASE $DB_NAME;"
query "ALTER USER $DB_USER WITH SUPERUSER;"

createlang pltclu $DB_NAME -h $DOCKER_POSTGRESQL -U postgres

# echo "#!/bin/bash" > /usr/sbin/spacewalk-service
# disable waiting for tomcat
sed -i 's/\(^\s*wait_for_tomcat\)/#\1/g' /usr/bin/spacewalk-setup

spacewalk-setup --external-postgresql --answer-file=/root/answer.txt --clear-db

mv /root/ssl-build /var/satellite/
ln -s /var/satellite/ssl-build /root/ssl-build/
