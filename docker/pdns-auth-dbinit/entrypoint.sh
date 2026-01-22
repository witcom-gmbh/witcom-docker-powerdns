#!/bin/sh
set -e

if [[ "$FLYWAY_DBTYPE" == "mysql" ]] || [[ "$FLYWAY_DBTYPE" == "mariadb" ]]; then
    if [[ -z $FLYWAY_DRIVER ]]; then
        export FLYWAY_DRIVER="org.mariadb.jdbc.Driver"
    fi
    export MIGRATION_FOLDER="./sql/mariadb"
    export FLYWAY_URL="jdbc:${FLYWAY_DBTYPE}://${FLYWAY_DBHOST:-localhost}:${FLYWAY_DBPORT:-3306}/${FLYWAY_DBNAME:-powerdns}"
elif [[ "$FLYWAY_DBTYPE" == "postgresql" ]]; then
    if [[ -z $FLYWAY_DRIVER ]]; then
        export FLYWAY_DRIVER="org.postgresql.Driver"
    fi
    export MIGRATION_FOLDER="./sql/postgresql"
    export FLYWAY_URL="jdbc:postgresql://${FLYWAY_DBHOST:-localhost}:${FLYWAY_DBPORT:-5432}/${FLYWAY_DBNAME:-powerdns}"
else
    echo "Unsupported database-type - only postgresql or mariadb are supported"
    exit 1
fi

flyway -locations="filesystem:${MIGRATION_FOLDER}" migrate 
