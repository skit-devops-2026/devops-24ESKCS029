# MT2 — Modules 5–7 Evidence (20 marks)

This file maps each milestone check for MT2 (due 18 October 2026) to what exists in the repository, how to run and verify it, and how the automated evaluator scans it.

## M5 · Containerization — 6 marks

| Check | Marks | Status | Location & Details |
| :--- | :---: | :---: | :--- |
| **Dockerfile present** | 2 | **Done** | `Dockerfile` (root) — Multi-stage alpine build (`node:20-alpine`), compiles server bundle with `NITRO_PRESET=node-server`, non-root user (`USER node`), healthcheck. |
| **docker-compose.yml present** | 2 | **Done** | `docker-compose.yml` (root) — Defines `app` container (port 3000) and `prometheus` container (port 9090). |
| **An image pushed to the container registry** | 2 | **Done** | `.github/workflows/docker-publish.yml` — Automated CI/CD workflow pushing to GitHub Container Registry `ghcr.io/skit-devops-2026/devops-24eskcs029:latest` using `GITHUB_TOKEN`. |

### Running the Container

```sh
# Build and run locally with Docker Compose
docker compose up -d

# Or run directly with Docker
docker build -t hostelfix .
docker run -p 3000:3000 hostelfix
```

---

## M6 · Deployment and Monitoring — 8 marks

| Check | Marks | Status | Location & Details |
| :--- | :---: | :---: | :--- |
| **Live URL responding** | 2 | **Done** | `README.md` — Live URL documented under the Live Deployment section. Responding with HTTP 200. |
| **Prometheus config present** | 2 | **Done** | `prometheus.yml` (root) and `monitoring/prometheus.yml` — Scrapes `hostelfix-app` targets, metrics intervals, and job configurations. |
| **Monitoring dashboard committed under `monitoring/`** | 2 | **Done** | `monitoring/dashboard.json` — Comprehensive Grafana dashboard with request rate, latency (p50/p95/p99), HTTP status codes, memory, CPU, and uptime panels. |
| **Deployment screenshot committed under `docs/`** | 2 | **Done** | `docs/deployment.png` — Visual evidence showing live deployed application, service health, and active HTTP 200 response. |

### Running the Monitoring Stack

```sh
# Start app and Prometheus monitoring together
docker compose up -d

# App accessible at http://localhost:3000
# Prometheus UI accessible at http://localhost:9090
```

---

## M7 · Kubernetes — 6 marks

| Check | Marks | Status | Location & Details |
| :--- | :---: | :---: | :--- |
| **Deployment manifest under `k8s/`** | 3 | **Done** | `k8s/deployment.yaml` — 2 replicas, rolling updates, references container registry image `ghcr.io/skit-devops-2026/devops-24eskcs029:latest`, resource requests/limits, liveness and readiness probes. |
| **Service manifest under `k8s/`** | 3 | **Done** | `k8s/service.yaml` — NodePort service routing port 80 to container port 3000 on nodePort 30080 with selector `app: hostelfix`. |
| **Kubectl get pods screenshot under `docs/`** | viva | **Done** | `docs/kubectl-get-pods.png` — Committed screenshot showing `kubectl get pods -l app=hostelfix -o wide`, `kubectl get deployments`, and `kubectl get svc` with 2/2 pods in Running & Ready state. |

### Running on Local Kubernetes (kind or k3d)

```sh
# Create a local kind cluster
kind create cluster --name hostelfix

# Apply Kubernetes manifests
kubectl apply -f k8s/

# Verify pods and service
kubectl get pods -l app=hostelfix -o wide
kubectl get svc hostelfix-service

# Port-forward to test locally
kubectl port-forward svc/hostelfix-service 8080:80
```
