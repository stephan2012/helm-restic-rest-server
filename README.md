# Helm Chart for the Restic REST Server

This Helm chart deploys the [Restic REST Server](https://github.com/restic/rest-server) to a Kubernetes
cluster. It currently requires building the development version
because the highly useful feature of [reading the user list from an arbitrary location](https://github.com/restic/rest-server/pull/188)
has only been recently added.

## Exposing

The Helm charts allows exposing the REST server through an
Ingress and as Service.

### Ingress

Passing all request through an Ingress Controller allows full control
over HTTPS requests and all features of a reverse proxy. The traffic
can be HTTP or HTTPS. However, the Ingress Controller has to
deal with potentially large chunks of data.

Example configuration snippet for passing all traffic through an
Ingress Controller:

```yaml
service:
  type: ClusterIP
  port: 8000

ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
  hosts:
    - host: restic.domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: restic-tls-cert
      hosts:
        - restic.domain.com
```

### Service

The Helm chart allows exposing the REST server’s service for direct access.

Beware, however, that the REST server is currently [not able to reload](https://github.com/restic/rest-server/issues/94)
a renewed TLS server certificate online.

Example configuration snippet for exposing the service directly:

```yaml
service:
  type: LoadBalancer
  port: 8000
  annotations:
    external-dns.alpha.kubernetes.io/hostname: restic.domain.com
  loadBalancerIP: 10.2.3.4
  externalTrafficPolicy: Local

ingress:
  enabled: false

restic:
  restServer:
    tls:
      # Enable TLS support (optional, but recommended)
      enabled: true

      # Kubernetes Secret holding the TLS secret
      secretName: restic-tls-cert
```

## User Management

The restic REST server expects the list of acceptable users as a file
in the Apache `.htpasswd` format. For simple use-cases and testing
purposes, the Helm chart generates a single user (default: `restic`)
and stores it in a Kubernetes Secret unless a custom secret name is
specified. However, the preferable option is to maintain your own user
file as a Kubernetes Secret and pass its name to the Helm chart.

## Repositories

## Prometheus Monitoring

## Running Securely

When it comes to data backups, it is all about security and safety. A
good practice to reduce the attack surface is to drop all privileges
because the REST Server needs neither to run as root nor special
capabilities. Consider setting the `securityContext` (UID and GID
should match with your repository Persistent Volume):

```yaml
securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  allowPrivilegeEscalation: false
```
