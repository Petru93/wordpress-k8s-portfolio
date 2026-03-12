# wordpress-k8s-portfolio-tier_2

wordpress-k8s-portfolio/
├── docker/
│   ├── Dockerfile
│   └── .dockerignore
├── helm/
│   └── wordpress/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── jenkins/
│   └── Jenkinsfile
├── docs/
│   └── architecture.md
├── docker-compose.yml
└── README.md

## Known Issues & Fixes
- Fixed supervisord.log permission denied by pre-creating log file with correct ownership
- Fixed nginx pid file permission denied by creating /run/nginx with non-root ownership