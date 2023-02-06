# Cluster Configuration

This folder contains the set of baseline cluster configuration, for example cluster-wide services and namespace definitions

```yaml
kind: Namespace
apiVersion: v1
metadata:
  name: sample-app
```

Or a cluster wide certificate issuer

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: REPLACE_WITH_YOUR_EMAIL_ADDRESS
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
```
