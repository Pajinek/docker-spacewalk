#!/bin/bash


### set postgresql ###
# export PGPASSWORD=???
export DOCKER_POSTGRESQL=spacewalk-postgresql

function query() {
    psql -h $DOCKER_POSTGRESQL -U postgres <<< "$1"
}

query "select version()"
query "CREATE USER spaceuser with password spacepw;"
query "CREATE DATABASE spaceschema;"
query "ALTER USER spaceuser WITH SUPERUSER;"

createlang pltclu spaceschema -h $DOCKER_POSTGRESQL -U postgres

spacewalk-setup --external-postgresql --answer-file=/root/answer.txt

touch /root/spacewalk-installation-done
