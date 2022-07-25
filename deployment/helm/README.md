# PowerDNS Authorative DNS server packaged by WiTCOM

## TL;DR

```bash
$ helm repo add witcom-charts https://witcom-gmbh.github.io/witcom-charts
$ helm install my-release witcom-charts/powerdns-pdns
```

## Introduction

This chart bootstraps a [PowerDNS](https://www.powerdns.com/auth.html) authorative DNS service on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

The PowerDNS instance is backed by MariaDB and  therefore needs a running MarieDB instance, e.g. https://github.com/bitnami/charts/blob/master/bitnami/mariadb

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Running instance of mariadb
- PV provisioner support in the underlying infrastructure

## Optional requirements

- Loadbalancer for accessing DNS-Services from outside of the cluster (if running on bare-metal take a look at https://metallb.universe.tf/)
- CNI that supports networkpolicies

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install my-release witcom-charts/powerdns-pdns -f /path/to/config.yml
```

There is no such thing as a default configuration that works out of the box. You have to provide a configuration for

* using the database-backend
* exposing the DNS services

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.