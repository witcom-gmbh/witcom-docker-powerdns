#!/bin/sh
set -e
export FLYWAY_URL="jdbc:${FLYWAY_DBTYPE}://${FLYWAY_DBHOST:-localhost}:${FLYWAY_DBPORT:-3306}/${FLYWAY_DBNAME:-powerdns}"
flyway migrate 
