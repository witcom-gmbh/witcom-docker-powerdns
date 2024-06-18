# PowerDNS Authorative DNS server packaged by WiTCOM

PowerDNS authorative dns-server

![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.6.4](https://img.shields.io/badge/AppVersion-4.6.4-informational?style=flat-square)

## TL;DR

```bash
$ helm install my-release oci://artifactory.witcom.services/witcom-charts/powerdns-pdns
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
$ helm install my-release oci://artifactory.witcom.services/witcom-charts/powerdns-pdns -f /path/to/config.yml
```

There is no such thing as a default configuration that works out of the box. You have to provide a configuration for

* using the database-backend
* exposing the DNS services

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Examples

Example for network-policies

```
networkPolicy:
  enabled: true
  ingressRules:
    pdnsTcpAccessOnlyFrom:
      customRules:
      - from:
        - ipBlock:
            cidr: 0.0.0.0/0
        ports:
        - port: 53
          protocol: TCP
      enabled: true
    pdnsUdpAccessOnlyFrom:
      customRules:
      - from:
        - ipBlock:
            cidr: 0.0.0.0/0
        ports:
        - port: 53
          protocol: UDP
      enabled: true
    pdnsWebAccessOnlyFrom:
      customRules:
      - from:
        - namespaceSelector:
            matchLabels:
              name: infra-public
          podSelector:
            matchLabels:
              app.kubernetes.io/component: powerdns-admin
              app.kubernetes.io/part-of: pda01
        ports:
        - port: 8081
          protocol: TCP
      enabled: true
      namespaceSelector:
        name: infra-private
      podSelector:
        app.kubernetes.io/component: controller
        app.kubernetes.io/instance: ngix-ingress-private
        app.kubernetes.io/name: ingress-nginx

```

Example for additional powerdns config

```
pdns:
  additionalConfig:
  - config: loglevel
    value: "4"
  - config: primary
    value: true
  - config: dnsupdate
    value: false
  - config: only_notify
    value: 0.0.0.0/0
  - config: allow_axfr_ips
    value: 0.0.0.0/0
  - config: local_address
    value: 0.0.0.0
  - config: default-soa-content
    value: clouddns1.witcom.de hostmaster.witcom.de@ 0 10800 3600 604800 3600

```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | common | 2.x.x |

## Values

### Database configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pdns.database.host | string | `""` | database-host for powerdns-database |
| pdns.database.db | string | `""` | database-name for powerdns-database |
| pdns.database.port | int | `3306` | database-port for powerdns-database |
| pdns.database.user | string | `"pdns"` | database-user for accessing powerdns-database |
| pdns.database.password | string | `""` | database-password for accessing powerdns-database. Must be provided if `pdns.database.existingSecret` is empty |
| pdns.database.secretKey | string | `"password"` | secret-key where `pdns.database.password` will be stored or looked up in `pdns.database.existingSecret` |
| pdns.database.existingSecret | string | `""` | Use existing for secret for the database-password |

### Database backup configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pdns.database.backup.enabled | bool | `false` | Wether to enable backup-job |
| pdns.database.backup.retention | string | `"30"` | Backup-Retention in days. Defaults to 30. Beware - this is set on bucket level, so please coordinate the values |
| pdns.database.backup.schedule | string | `"0 */4 * * *"` | Backup-Schedule as cron-job. Defaults to every 4 hours. |
| pdns.database.backup.cronJobLabels | object | `{}` | Labels for cron-jobs and job-instances |
| pdns.database.backup.podLabels | object | `{}` | Labels for backup-pods, can be useful for Networkpolicies |
| pdns.database.backup.resources | object | `{}` | Resource-configuration for backup-pods |
| pdns.database.backup.image.repository | string | `"artifactory.witcom.services/cloud-backup/mysql-cloud-backup"` | Image repository for backup-job-pod |
| pdns.database.backup.image.pullPolicy | string | `"IfNotPresent"` | Image pullPolicy for backup-job-pod |
| pdns.database.backup.image.tag | string | `"0.0.3"` | Image tag for backup-job-pod |
| pdns.database.backup.s3.endpoint | string | `nil` | S3-Endpoint - Required |

### Database backup configuration       

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pdns.database.backup.s3.bucket | string | `nil` | S3-Bucket - Required |
| pdns.database.backup.s3.prefix | string | `""` | Prefix for folder in bucket. If not provided, will default to powerdns-pdns.fullname |
| pdns.database.backup.s3.existingSecret | string | `nil` | Take S3 Secret-Access-Key and S3 Secret-Access-Key from an existing secret. Keys can be defined with `pdns.database.backup.s3.accessKeyIdSecretKey` and `pdns.database.backup.s3.secretAccessKeySecretKey` |
| pdns.database.backup.s3.accessKeyId | string | `""` | S3 Access-Key-ID - required |
| pdns.database.backup.s3.secretAccessKey | string | `""` | S3 Secret-Access-Key |
| pdns.database.backup.s3.accessKeyIdSecretKey | string | `"S3_ACCESS_KEY_ID"` | Key for S3-Access-Key-Id in secret `pdns.database.backup.s3.existingSecret` |
| pdns.database.backup.s3.secretAccessKeySecretKey | string | `"S3_SECRET_ACCESS_KEY"` | Key for S3-Secret-Access-Key in secret `pdns.database.backup.s3.existingSecret` |

### Database initialization

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pdns.database.init.enabled | bool | `true` | Initialize PowerDNS-Database with init-container |
| pdns.database.init.baseline | string | `"false"` | Should an existing database be initialized. See https://documentation.red-gate.com/fd/baseline-on-migrate-224919695.html |

### Web-Access

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pdns.web.enabled | bool | `true` | Wether to enable powerdns-web-access |
| pdns.web.allowFrom | string | `"0.0.0.0/0"` | ACL for powerdns-web-access |
| pdns.web.api.enabled | bool | `true` | Wether to enable powerdns-rest-api |
| pdns.web.api.apiKey | string | `"secret"` | Create secret with provided API-Key |
| pdns.web.api.existingSecret | string | `""` | Take api-key from existing secret  |
| pdns.web.api.secretKey | string | `"apikey"` | Secret-Key where api-key is available |

### PowerDNS Authorative configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pdns.additionalConfig | list | `[]` | Additional configuration-parameters for powerdns authorative-server. See https://doc.powerdns.com/authoritative/settings.html |

### Network-Policies

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| networkPolicy.enabled | bool | `false` | Enable network policies |
| networkPolicy.metrics.enabled | bool | `false` | Enable network policy for metrics (prometheus) |
| networkPolicy.metrics.podSelector | object | `{}` | Monitoring pod selector labels. These labels will be used to identify the Prometheus pods. |
| networkPolicy.metrics.namespaceSelector | object | `{}` | Monitoring namespace selector labels. These labels will be used to identify the prometheus' namespace. If object is empty, access from all namespaces will be allowed |
| networkPolicy.ingressRules.pdnsWebAccessOnlyFrom.enabled | bool | `false` | Enable network policy for Web-Interface |
| networkPolicy.ingressRules.pdnsWebAccessOnlyFrom.namespaceSelector | object | `{}` | Monitoring namespace selector labels. These labels will be used to identify the prometheus' namespace. If object is empty, access from all namespaces will be allowed |
| networkPolicy.ingressRules.pdnsWebAccessOnlyFrom.podSelector | object | `{}` | Monitoring pod selector labels. These labels will be used to identify the Prometheus pods. |
| networkPolicy.ingressRules.pdnsWebAccessOnlyFrom.customRules | object | `{}` | Custom ingress-rules |
| networkPolicy.ingressRules.pdnsUdpAccessOnlyFrom.enabled | bool | `false` | Enable network policy for DNS-UDP |
| networkPolicy.ingressRules.pdnsUdpAccessOnlyFrom.namespaceSelector | object | `{}` | Monitoring namespace selector labels. These labels will be used to identify the prometheus' namespace. If object is empty, access from all namespaces will be allowed |
| networkPolicy.ingressRules.pdnsUdpAccessOnlyFrom.podSelector | object | `{}` | Monitoring pod selector labels. These labels will be used to identify the Prometheus pods. |
| networkPolicy.ingressRules.pdnsUdpAccessOnlyFrom.customRules | object | `{}` | Custom ingress-rules |
| networkPolicy.ingressRules.pdnsTcpAccessOnlyFrom.enabled | bool | `false` | Enable network policy for DNS-UDP |
| networkPolicy.ingressRules.pdnsTcpAccessOnlyFrom.namespaceSelector | object | `{}` | Monitoring namespace selector labels. These labels will be used to identify the prometheus' namespace. If object is empty, access from all namespaces will be allowed |
| networkPolicy.ingressRules.pdnsTcpAccessOnlyFrom.podSelector | object | `{}` | Monitoring pod selector labels. These labels will be used to identify the Prometheus pods. |
| networkPolicy.ingressRules.pdnsTcpAccessOnlyFrom.customRules | object | `{}` | Custom ingress-rules |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` |  |
| image.repository | string | `"artifactory.witcom.services/powerdns/pdns"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.tag | string | `""` |  |
| initImage.repository | string | `"artifactory.witcom.services/powerdns/pdns-gmysql-init"` |  |
| initImage.pullPolicy | string | `"IfNotPresent"` |  |
| initImage.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| fullnameOverride | string | `""` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.name | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.web.type | string | `"ClusterIP"` |  |
| service.web.port | int | `8081` |  |
| service.udp.enabled | bool | `true` |  |
| service.udp.type | string | `"ClusterIP"` |  |
| service.udp.loadBalancerIP | string | `nil` |  |
| service.udp.annotations | object | `{}` |  |
| service.tcp.enabled | bool | `true` |  |
| service.tcp.type | string | `"ClusterIP"` |  |
| service.tcp.annotations | object | `{}` |  |
| ingress.enabled | bool | `true` |  |
| ingress.className | string | `""` |  |
| ingress.annotations | object | `{}` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| resources | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| nodeSelector | object | `{}` |  |
| tolerations | list | `[]` |  |
| affinity | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.jobLabel | string | `""` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.scrapeTimeout | string | `""` |  |
| serviceMonitor.relabelings | list | `[]` |  |
| serviceMonitor.metricRelabelings | list | `[]` |  |
| serviceMonitor.honorLabels | bool | `false` |  |
| serviceMonitor.labels."app.kubernetes.io/monitoring-instance" | string | `"playground"` |  |

# Upgrading

## To 1.0.0

Breaking change !!

* Init-container image specification is moved from `pdns.database.init.image` to `initImage`

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)