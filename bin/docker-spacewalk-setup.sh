#!/bin/bash
# author: Pavel Studenik <pstudeni@redhat.com>

### set postgresql ###
export PGPASSWORD="$POSTGRES_PASSWORD"
export DOCKER_POSTGRESQL=postgresql-host
DB_USER=spaceuser
DB_PASS=spacepw
DB_NAME=spaceschema

function query() {
    psql -h $DOCKER_POSTGRESQL -U postgres <<< "$1"
}

function is_db_install {
    echo "select * from rhnVersionInfo;" | spacewalk-sql -i
}

# echo "#!/bin/bash" > /usr/sbin/spacewalk-service
# disable waiting for tomcat
sed -i 's/\(^\s*wait_for_tomcat\)/#\1/g' /usr/bin/spacewalk-setup
sed -i '3i\echo "Docker workaround - skip restarting..." && exit 0\' /usr/sbin/spacewalk-service

if [ -z $(spacewalk-cfg-get db_name) ]; then
    # need filled database information
    echo "db_backend = postgresql" >> /etc/rhn/rhn.conf
    echo "db_user = $DB_USER" >> /etc/rhn/rhn.conf
    echo "db_password = $DB_PASS" >> /etc/rhn/rhn.conf
    echo "db_name = $DB_NAME" >> /etc/rhn/rhn.conf
    echo "db_host = $DOCKER_POSTGRESQL" >>  /etc/rhn/rhn.conf
    echo "db_port = 5432" >> /etc/rhn/rhn.conf
fi

if is_db_install; then
    spacewalk-setup --external-postgresql --answer-file=/root/answer.txt --skip-db-population --skip-services-restart --non-interactive
    spacewalk-schema-upgrade
else
    # create db user
    query "select version()" || exit 1
    query "CREATE USER $DB_USER with password '$DB_PASS';"
    query "CREATE DATABASE $DB_NAME;"
    query "ALTER USER $DB_USER WITH SUPERUSER;"
    createlang pltclu $DB_NAME -h $DOCKER_POSTGRESQL -U postgres

    spacewalk-setup --external-postgresql --answer-file=/root/answer.txt --clear-db --skip-services-restart --non-interactive
fi

echo """
import sys, os

if __name__=='__main__':
    f = open(sys.argv[2]); c = f.read(); f.close()
    data = [it.split('=') for it in c.split('\n') if it.startswith('ssl')]
    options={}
    for key, it in data:
        options.update({key.strip(): it.strip()})
    os.system('/root/spacewalk-hostname-rename.sh %s --ssl-country=\"%s\" --ssl-state=\"%s\" --ssl-org=\"%s\" --ssl-orgunit=\"%s\" --ssl-email=\"%s\" --ssl-ca-password=\"%s\"' % (sys.argv[1], options['ssl-set-country'],  options['ssl-set-state'], options['ssl-set-org'], options['ssl-set-org-unit'], options['ssl-set-email'], options['ssl-password']))
""" > rename-answer.py

chmod a+x /root/spacewalk-hostname-rename.sh

[ -z "$HOST_HOSTNAME" ] || python rename-answer.py $HOST_HOSTNAME /root/answer.txt

