# node-red-kubernetes

Deploy **Node-RED** on Kubernetes as a production service — persistent storage for flows, a hashed
admin password stored in a Kubernetes Secret, a Service, and Ingress with TLS. Reference
implementation for the Node-RED deployment project.

## What's here

```
.
├── manifests/
│   ├── namespace.yaml
│   ├── pvc.yaml                # PersistentVolumeClaim for /data (flows survive restarts)
│   ├── secret.example.yaml     # template for the hashed admin password (DO NOT commit real)
│   ├── configmap.yaml          # settings.js (adminAuth, projects)
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml            # TLS via cert-manager
└── scripts/
    └── hash-password.sh        # generate a bcrypt hash for the admin password
```

## What this demonstrates

- Stateful workload on Kubernetes (PVC-backed flows that survive pod restarts)
- Secrets handled correctly: a **bcrypt-hashed** password in a Secret, mounted into `settings.js`
- Production wiring: namespace isolation, Service, and TLS Ingress
- A documented password-reset/rotation procedure

## Quick start

```bash
# 1. Generate a hashed admin password
./scripts/hash-password.sh 'your-strong-password'
#   copy the hash into your Secret (see secret.example.yaml), then:
kubectl apply -f manifests/namespace.yaml
kubectl create secret generic node-red-admin \
  --from-literal=password-hash='<bcrypt-hash>' -n node-red

# 2. Apply the rest
kubectl apply -f manifests/

# 3. Access
kubectl -n node-red port-forward svc/node-red 1880:1880
# or via the Ingress host once DNS + cert-manager are set up
```

## Security notes

- The admin password is **never** stored in plaintext — only a bcrypt hash, in a Secret.
- `secret.example.yaml` is a template; create the real Secret with `kubectl create secret` (it stays
  out of Git).
- Flows persist on the PVC; back them up (or sync to Git via Node-RED Projects) for DR.

## Password reset

Regenerate a hash with `scripts/hash-password.sh`, update the Secret, and restart the deployment:

```bash
kubectl -n node-red rollout restart deployment/node-red
```

## License

MIT
