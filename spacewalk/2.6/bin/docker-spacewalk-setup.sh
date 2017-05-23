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
    spacewalk-setup --external-postgresql --answer-file=/root/answer.txt --upgrade --skip-services-restart --non-interactive
    spacewalk-schema-upgrade
else
    spacewalk-setup --external-postgresql --answer-file=/root/answer.txt --clear-db --skip-services-restart --non-interactive
fi

[ -z "$HOST_HOSTNAME" ] || /root/spacewalk-hostname-rename.sh $HOST_HOSTNAME

