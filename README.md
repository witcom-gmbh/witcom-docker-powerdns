# WiTCOM PowerDNS Docker Images

[![Build Status](https://drone-gh-01.witcom.services/api/badges/witcom-gmbh/witcom-docker-powerdns/status.svg?ref=refs/heads/main)](https://drone-gh-01.witcom.services/witcom-gmbh/witcom-docker-powerdns)

This repository contains Docker images for running PowerDNS Authorative-Server - preferably within a container orchestrator like K8S.

 - **docker-powerdns** contains completely configurable [PowerDNS 4.x server](https://www.powerdns.com/) with database backend (without mysql server).
 - **pdns-auth-dbinit** contains an init container for creating/upgrading the database schema required for PowerDNS authorative-server

## pdns-auth
Docker image with [PowerDNS authorative server](https://doc.powerdns.com/authoritative) and database backend (defaut gpgsql) - (without database server).

The image is based on the official PowerDNS docker-images (e.g. powerdns/pdns-auth-50:5.0.2)

For running, it needs an external database server. Example env vars for postgresql configuration:
```
PDNS_gpgsql_host=dbhost
PDNS_gpgsql_port=5432
PDNS_gpgsql_user=my-user
PDNS_gpgsql_password=powerdns
PDNS_gpgsql_dbname=powerdns
```
PowerDNS server is configurable via env vars. Every variable starting with `PDNS_` will be inserted into `/etc/powerdns/pdns.conf` conf file in the following way: prefix `PDNS_` will be stripped and every `_` will be replaced with `-`. For example, from above mysql config, `PDNS_gpgsql_host=dbhost` will become `gpgsql-host=dbhost` in `/etc/powerdns/pdns.conf` file. This way, you can configure PowerDNS server any way you need within a `docker run` command.

You can find all available settings [here](https://doc.powerdns.com/md/authoritative/).

### Non-Root container
docker-powerdns is designed to run as non-root user, and can handle arbitrary uids.

## pdns-auth-dbinit
An init container for PowerDNS that handles database schema migrations.
For details see [flywaydb](./docker/pdns-auth-dbinit/README.md).

### Example k8s deployment
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
          image: image: pdns-auth-dbinit:5.0.2
          name: init-powerdns-flyway
```
### Non-Root container
docker-powerdns-init is designed to run as non-root user, and can handle arbitrary uids.

## Development

#### Test helm

```console
cd ./charts/powerdns-pdns
helm install pdns-01 ./ -f ./tests/helm-pdns-01.yml
```

### Local tests with docker

Example for mariadb

```console
docker network create --driver bridge pdns-net
docker run --network pdns-net --detach --name some-mariadb --env MARIADB_USER=example-user --env MARIADB_PASSWORD=my_cool_secret --env MARIADB_ROOT_PASSWORD=my-secret-pw  -e MARIADB_DATABASE=powerdns  mariadb:latest
cd docker/pdns-auth-dbinit
just docker-build
cd ..
cd pdns-auth
just docker-build
cd ..

docker run --rm -e FLYWAY_DBHOST=some-mariadb -e FLYWAY_USER=example-user -e FLYWAY_PASSWORD=my_cool_secret --network pdns-net pdns-auth-dbinit:local-latest
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

## Bump PowerDNS Version

### Test build 

If there are database-schema-changes, add them to the initdb-container !

```console
export PDNS_IMAGE=powerdns/pdns-auth-50
export PDNS_RELEASE=5.0.2
cd docker/pdns-auth-dbinit
just docker-build $PDNS_RELEASE
cd ../pdns-auth
just docker-build $PDNS_IMAGE $PDNS_RELEASE
```

Test like described above

### Prepare for build

Adjust env-variables configuration in `.drone.yml`, e.g.

```yaml
global-variables:
  environment: &default_environment
    PDNS_AUTH_RELEASE: 5.0.2
    PDNS_AUTH_IMAGE: powerdns/pdns-auth-50
    ...
```

* Bump application-version in [helm-chart](charts/powerdns-pdns/Chart.yaml)
* Commit changes - choose commit-type according to version bump, e.g. patch-release is an improvement/fix, minor-release is a feature, ...

```console
cog commit improvement "Bump powerdns to x.y.z"
```
