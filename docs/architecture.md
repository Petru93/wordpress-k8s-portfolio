# Architecture

## CI/CD Flow
```
Developer
    │
    │  git push
    ▼
GitHub Repository
    │
    │  webhook trigger
    ▼
Jenkins Pipeline
    ├── Stage 1: Checkout
    │       └── pulls source from GitHub
    │
    ├── Stage 2: Docker Build
    │       └── multi-stage Dockerfile → hardened Alpine image
    │
    ├── Stage 3: Trivy Scan
    │       ├── LOW/MEDIUM → reported, pipeline continues
    │       └── HIGH/CRITICAL → pipeline fails, no push
    │
    ├── Stage 4: Push to GHCR
    │       └── tagged :BUILD_NUMBER and :latest
    │
    └── Stage 5: Helm Deploy
            └── helm upgrade --install --atomic
                    │
                    ▼
              k3s Cluster
              ┌─────────────────────┐
              │  namespace:wordpress │
              │  ┌───────────────┐  │
              │  │  WordPress    │  │
              │  │  Pod          │  │
              │  │  (nginx+fpm)  │  │
              │  └──────┬────────┘  │
              │         │           │
              │  ┌──────▼────────┐  │
              │  │  MySQL Pod    │  │
              │  └───────────────┘  │
              └─────────────────────┘
```

## Component Responsibilities

| Component | Responsibility |
|---|---|
| Nginx Ingress | Routes external traffic into the cluster |
| WordPress Pod | Runs nginx + php-fpm via supervisord |
| MySQL Pod | Persistent database backend |
| PersistentVolumeClaims | Survives pod restarts for both app and DB data |
| Kubernetes Secrets | Holds DB credentials — injected as env vars |