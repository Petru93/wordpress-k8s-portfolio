# WordPress Kubernetes CI/CD Portfolio Project

A production-grade CI/CD pipeline that builds, scans, and deploys a custom
WordPress image to a Kubernetes cluster using Jenkins, Trivy, Helm, and k3s.

---

## Architecture Overview
```
GitHub Push → Jenkins Pipeline → Docker Build → Trivy Scan → GHCR Push → Helm Deploy → k3s
```

See [Architecture Documentation](docs/architecture.md) for the full system diagram.

---

## Stack

| Layer | Tool | Purpose |
|---|---|---|
| Source Control | GitHub | Version control and container registry (GHCR) |
| CI/CD | Jenkins (containerized) | Pipeline orchestration |
| Containerization | Docker | Image build and runtime |
| Security Scanning | Trivy (Aqua Security) | CVE scanning — blocks HIGH/CRITICAL |
| Package Manager | Helm 3 | Kubernetes deployment and upgrades |
| Orchestration | k3s | Lightweight production-like Kubernetes |
| Reverse Proxy | Nginx | Ingress controller + in-container proxy |
| Database | MySQL 8 | WordPress backend |

---

## Pipeline Stages
```
Checkout → Build Image → Trivy Scan → Push to GHCR → Helm Deploy
```

- **Checkout** — pulls latest code from GitHub
- **Build Image** — multi-stage Dockerfile, produces hardened Alpine-based image
- **Trivy Scan** — LOW/MEDIUM reported, HIGH/CRITICAL break the build
- **Push to GHCR** — tagged with build number and `latest`
- **Helm Deploy** — `helm upgrade --install --atomic` with auto-rollback on failure

---

## Security Decisions

- Container runs as **non-root user** (UID 1001)
- **Multi-stage build** — build tools never reach the final image
- Trivy scan is a **hard gate** — HIGH/CRITICAL CVEs fail the pipeline
- Base image kept patched via `apk update && apk upgrade` in Dockerfile
- All credentials injected at runtime via **Jenkins credential store** — never in code
- `.env` files excluded from version control via `.gitignore`
- Helm `values.yaml` contains only empty placeholders for secrets

---

## Project Structure
```
wordpress-k8s-portfolio/
├── docker/
│   ├── Dockerfile          # Multi-stage, non-root, Alpine-based
│   ├── .dockerignore
│   └── config/
│       ├── nginx.conf      # In-container reverse proxy
│       ├── supervisord.conf
│       ├── php-opcache.ini
│       └── proxy.conf      # External proxy config
├── helm/
│   └── wordpress/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── secrets.yaml
│           ├── mysql/
│           │   ├── deployment.yaml
│           │   ├── service.yaml
│           │   └── pvc.yaml
│           └── wordpress/
│               ├── deployment.yaml
│               ├── service.yaml
│               ├── pvc.yaml
│               └── ingress.yaml
├── jenkins/
│   └── Jenkinsfile
├── docs/
│   ├── architecture.md
│   └── cluster-setup.md
├── docker-compose.yml      # Local development stack
├── .env.example
└── README.md
```

---

## Key Challenges & How I Solved Them

### 1. Docker socket permissions in Jenkins
Jenkins runs as a non-root user inside its container. Mounting
`/var/run/docker.sock` alone wasn't enough — the Jenkins user had no
permission to use it. Fixed by setting `chmod 666` on the socket and
documenting a custom Jenkins Dockerfile as the durable long-term solution.

### 2. Silent GHCR push failure
The image built successfully but the push silently failed. Root cause:
`docker.build()` was called outside `docker.withRegistry()`, so the image
was built without registry authentication context. Moving the build call
inside the `withRegistry` block resolved it.

### 3. Critical CVE in base image
Trivy flagged a HIGH severity CVE in `libexpat` from the `php:8.2-fpm-alpine`
base image. Fixed by adding `RUN apk update && apk upgrade --no-cache` before
the `apk add` block in the Dockerfile, ensuring all base packages are patched
at build time.

### 4. Helm readiness probe mismatch
During Helm chart validation using the official WordPress FPM image, the pod
showed `0/1 Not Ready`. The HTTP readiness probe targeted port 80, but the
FPM image has no web server — only PHP-FPM on port 9000. Resolved by
temporarily disabling probes for validation, then restoring them correctly
configured for the custom image on port 8080.

### 5. Non-root permission conflicts
Running WordPress as UID 1001 caused file permission issues on mounted
volumes. Resolved by explicitly setting ownership in the Dockerfile with
`chown -R wordpress:wordpress` on all relevant paths.

---

## Local Development
```bash
# Copy and fill in your credentials
cp .env.example .env

# Build and start the full stack
docker compose up -d

# Verify health
docker compose ps
```

Access WordPress at `http://localhost`

---

## Kubernetes Deployment
```bash
# Deploy with Helm
helm install wp-release helm/wordpress \
  --namespace wordpress \
  --set secrets.mysqlRootPassword=<password> \
  --set secrets.mysqlPassword=<password>

# Check rollout
kubectl get pods -n wordpress -w
```

---

## Known Technical Debt

| Item | Description | Priority |
|---|---|---|
| Custom Jenkins image | Docker CLI, Trivy, Helm currently installed manually inside container — ephemeral on restart | High |
| TLS/HTTPS | Ingress currently HTTP only — cert-manager + Let's Encrypt planned | Medium |
| External secrets | Helm `--set` flags for credentials — HashiCorp Vault or Kubernetes External Secrets planned | Medium |

---

## Author

**[Petru Astefanoaie]**
Systems Administrator → DevOps Engineer
[LinkedIn URL](https://www.linkedin.com/in/petru-astefanoaie) | [GitHub URL](https://github.com/Petru93)

