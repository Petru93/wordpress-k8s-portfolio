# k3s Cluster Setup

## Specs
- Single-node k3s cluster on Debian 12 VM
- k3s version: (output of `k3s --version`)
- Helm version: (output of `helm version`)

## Components
| Component         | Namespace       | Method      |
|-------------------|-----------------|-------------|
| k3s               | kube-system     | k3s install |
| Nginx Ingress     | ingress-nginx   | Helm         |
| WordPress         | wordpress       | Helm (Phase 4)|

## Access
- API server: https://<VM_IP>:6443
- WordPress HTTP: http://<VM_IP>:30080