# WiTCOM PowerDNS Docker Images

[![Build Status](https://drone-gh-01.witcom.services/api/badges/witcom-gmbh/witcom-docker-powerdns/status.svg?ref=refs/heads/main)](https://drone-gh-01.witcom.services/witcom-gmbh/witcom-docker-powerdns)

This repository contains Docker images for running PowerDNS - preferably within a container orchestrator like K8S or openshift.

 - **docker-powerdns** contains completely configurable [PowerDNS 4.x server](https://www.powerdns.com/) with database backend (without mysql server).
 - **docker-powerdns-init** contains an init container for creating/upgrading the database schema required for PowerDNS 

## docker-powerdns
Docker image with [PowerDNS 4.x server](https://www.powerdns.com/) and database backend (defaut gmysql) - (without database server).

The image is based on the official PowerDNS docke-images (e.g. powerdns/pdns-auth-46:4.6.3)

For running, it needs an external database server. Example env vars for mysql configuration:
```
PDNS_gmysql_host=mysql
PDNS_gmysql_port=3306
PDNS_gmysql_user=root
PDNS_gmysql_password=powerdns
PDNS_gmysql_dbname=powerdns
```
PowerDNS server is configurable via env vars. Every variable starting with `PDNS_` will be inserted into `/etc/powerdns/pdns.conf` conf file in the following way: prefix `PDNS_` will be stripped and every `_` will be replaced with `-`. For example, from above mysql config, `PDNS_gmysql_host=mysql` will become `gmysql-host=mysql` in `/etc/powerdns/pdns.conf` file. This way, you can configure PowerDNS server any way you need within a `docker run` command.

You can find all available settings [here](https://doc.powerdns.com/md/authoritative/).

### Non-Root container
docker-powerdns is designed to run as non-root user, and can handle arbitrary uids.

## docker-powerdns-init
An init container for PowerDNS that handles database schema migrations. It is based on [flywaydb](https://flywaydb.org/).
The container can be either run as init container in K8S/Openshift, or as a standalone container to prepare an existing database.
The init-script is configured from environment-variables only. Here are the default values

```
FLYWAY_DRIVER="org.mariadb.jdbc.Driver"
FLYWAY_DBTYPE=mysql
FLYWAY_DBHOST=localhost
FLYWAY_DBPORT=3306
FLYWAY_DBNAME=powerdns
FLYWAY_USER=
FLYWAY_PASSWORD=
```

### example k8s deployment
Here is an example for an K8S deployment. Both containers are using the same secret to connect to the database. 

Better use the [helm-chart](charts/powerdns-pdns/README.md)

```
      containers:
        - env:
            - name: PDNS_gmysql_host
              value: mariadb
            - name: PDNS_gmysql_password
              valueFrom:
                secretKeyRef:
                  key: database-password
                  name: mariadb
            - name: PDNS_gmysql_user
              valueFrom:
                secretKeyRef:
                  key: database-user
                  name: mariadb
            - name: PDNS_gmysql_dbname
              valueFrom:
                secretKeyRef:
                  key: database-name
                  name: mariadb
            - name: PDNS_webserver
              value: 'yes'
            - name: PDNS_webserver_address
              value: 0.0.0.0
            - name: PDNS_webserver_allow_from
              value: 0.0.0.0/0
          image: docker-powerdns:4.3.0
          imagePullPolicy: Always
          name: docker-powerdns
          ports:
            - containerPort: 53
              protocol: TCP
            - containerPort: 53
              protocol: UDP
            - containerPort: 8081
              protocol: TCP
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      initContainers:
        - env:
            - name: FLYWAY_DBHOST
              value: mariadb
            - name: FLYWAY_DBNAME
              valueFrom:
                secretKeyRef:
                  key: database-name
                  name: mariadb
            - name: FLYWAY_USER
              valueFrom:
                secretKeyRef:
                  key: database-user
                  name: mariadb
            - name: FLYWAY_PASSWORD
              valueFrom:
                secretKeyRef:
                  key: database-password
                  name: mariadb
          image: image: docker-powerdns-init:4.3.0
          imagePullPolicy: Always
          name: init-powerdns-flyway
```
### Non-Root container
docker-powerdns-init is designed to run as non-root user, and can handle arbitrary uids.

## Development

### Local tests with docker

```console
docker network create --driver bridge pdns-net
docker run --network pdns-net --detach --name some-mariadb --env MARIADB_USER=example-user --env MARIADB_PASSWORD=my_cool_secret --env MARIADB_ROOT_PASSWORD=my-secret-pw  -e MARIADB_DATABASE=powerdns  mariadb:latest
cd docker-powerdns-init
docker build --build-arg PDNS_AUTH_IMAGE=powerdns/pdns-auth-47 --build-arg PDNS_AUTH_RELEASE=4.7.4 . -t pdns-auth-ginit:local-latest
cd ..
docker run --rm -e FLYWAY_DBHOST=some-mariadb -e FLYWAY_USER=example-user -e FLYWAY_PASSWORD=my_cool_secret --network pdns-net pdns-auth-ginit:local-latest
cd docker-powerdns
docker build --build-arg PDNS_AUTH_IMAGE=powerdns/pdns-auth-47 --build-arg PDNS_AUTH_RELEASE=4.7.4 . -t pdns-auth:local-latest
cd ..
docker run --rm --name pdns-auth \
  -e PDNS_gmysql_host=some-mariadb \
  -e PDNS_gmysql_user=example-user \
  -e PDNS_gmysql_password=my_cool_secret \
  -e PDNS_webserver=yes \
  -e PDNS_webserver_address="0.0.0.0" \
  -e PDNS_webserver_allow_from="0.0.0.0/0" \
  -e PDNS_api="yes" \
  -e PDNS_api_key=apikey \
  --network pdns-net -p 8081:8081 -p 53:53 pdns-auth:local-latest
```

Cleanup

```console
docker rm -f some-mariadb
docker network rm pdns-net
```

### Bump PowerDNS Version

* Test build 

```console
cd docker-powerdns
docker build --build-arg PDNS_AUTH_IMAGE=powerdns/pdns-auth-49 --build-arg PDNS_AUTH_RELEASE=4.9.1 . -t pdns-auth-witcom:latest
docker run --rm -e PDNS_launch=gsqlite3 -e PDNS_gsqlite3_database=/var/lib/powerdns/pdns.sqlite3 pdns-auth-witcom:latest
```

* Adjust env-variables configuration in `.drone.yml`

```yaml
global-variables:
  environment: &default_environment
    PDNS_AUTH_RELEASE: 4.6.3
    PDNS_AUTH_IMAGE: powerdns/pdns-auth-46
    ...
```

* If there are database-schema-changes, add them to the init-container
* Bump application-version in [helm-chart](charts/powerdns-pdns/Chart.yaml)
* Commit changes - choose commit-type according to version bump, e.g. patch-release is an improvement/fix, minor-release is a feature, ...

```console
cog commit improvement "Bump powerdns to x.y.z"
```
