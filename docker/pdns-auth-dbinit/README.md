# Container for PowerDNS Authorative-Server database schema configuration

Dockercontainer that initializes and updates the database schema for the PowerDNS Authorative-Server.

Supported databases

* PostgreSQL
* Mariadb/MySQL

## Why
Intended for kubernetes-deployments this container should be run as init-container befor the PDNS-Auth container

The container is based on Redgate Flyway to run database migrations

## Configuration

Configuration is done purely by environment-variables

| Variable    | Default | Description |
| -------- | ------- | ------- |
| FLYWAY_DBTYPE  | postgresql    | Supported values: `postgresql`, `mariadb`, `mysql`|
| FLYWAY_DBHOST | localhost     | Hostname of the Database-Instance |
| FLYWAY_DBNAME    | powerdns    | Name of the powerdns-database. For postgresql-databases the `public` schema is assumed |
| FLYWAY_USER | -     | Username for accessing the DB |
| FLYWAY_PASSWORD | -     | Password for accessing the DB |
| FLYWAY_DBPORT | -     | Default depends on `FLYWAY_DBTYPE`, if set overrides the defaults. |
| FLYWAY_DRIVER | -     | Default depends on `FLYWAY_DBTYPE`, if set overrides the defaults. |

Since this is based on Flyway all their environment-variables are available, too.

## Applying a baseline

If the DB-Schema (or parts of ) already exist, you can do a "Baseline on migrate", as described
here https://documentation.red-gate.com/flyway/reference/configuration/flyway-namespace/flyway-baseline-on-migrate-setting

Example

The database already is running the schema for PDNS-Auth Version 4.3.0. This schema was has been applied manually. We now want to use the Init-Container for automatic schema migrations.

To achieve this the following ENVIRONMENT variables have to be provided

* FLYWAY_BASELINE_ON_MIGRATE=true
* FLYWAY_BASELINE_VERSION="4.3.0"
