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

function schema {
     spacewalk-sql -i <<EOF
        select rhnPackageName.name || '-' || (PE.evr).version || '-' || (PE.evr).release
        from rhnVersionInfo, rhnPackageName, rhnPackageEVR PE
        where rhnVersionInfo.label = 'schema'
                and rhnVersionInfo.name_id = rhnPackageName.id
                and rhnVersionInfo.evr_id = PE.id;
EOF
}

query "select version()" || exit 1
query "CREATE USER $DB_USER with password '$DB_PASS';"
query "CREATE DATABASE $DB_NAME;"
query "ALTER USER $DB_USER WITH SUPERUSER;"

createlang pltclu $DB_NAME -h $DOCKER_POSTGRESQL -U postgres

# echo "#!/bin/bash" > /usr/sbin/spacewalk-service
# disable waiting for tomcat
sed -i 's/\(^\s*wait_for_tomcat\)/#\1/g' /usr/bin/spacewalk-setup
sed '3i\echo "Docker workaround - skip restarting..." && exit 0\' -i /usr/sbin/spacewalk-service

if schema | grep spacewalk-schema; then
    spacewalk-setup --external-postgresql --answer-file=/root/answer.txt --skip-db-population --non-interactive
    spacewalk-schema-upgrade
else
    spacewalk-setup --external-postgresql --answer-file=/root/answer.txt --clear-db --non-interactive
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

