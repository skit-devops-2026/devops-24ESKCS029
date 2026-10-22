# HostelFix — Hostel Complaint Management System

HostelFix is a full-stack web application that lets hostel students raise maintenance
complaints (electrical, plumbing, internet, furniture, cleanliness, water and other issues),
attach a photo of the problem, and follow the complaint until it is resolved. Wardens and
admins triage every complaint from a single dashboard, assign maintenance staff, add
remarks and track resolution performance through charts.

## Live Url

- **Live URL:** https://hostelfix-24eskcs029.onrender.com
- **Preview URL:** https://id-preview--977442ce-b91b-4acc-a56b-dae39855ff7f.lovable.app
- **Container Registry:** `ghcr.io/skit-devops-2026/devops-24eskcs029:latest`

## Milestones & Coursework Evidence

- [MT1 — Modules 1–4 Evidence](docs/MILESTONE-MT1.md) (Repository setup, branching, CI, Jenkins)
- [MT2 — Modules 5–7 Evidence](docs/MILESTONE-MT2.md) (Containerization, Monitoring, Kubernetes)

## Features

- Email/password authentication with two roles: **student** and **admin**
- Students raise complaints with title, description, category, block, room number and an image
- Complaint timeline with four states: pending, in progress, resolved, rejected
- Students may edit or delete their own complaint while it is still pending
- Admins update status, assign maintenance staff and post official remarks
- Search, filter (category, status, block, date) and paginated complaint list
- Analytics dashboard with bar and pie charts plus a resolution-rate summary
- Admin-only student directory with contact details and complaint counts
- Private image storage: photos are readable only by their owner and admins
- Glassmorphism UI, dark/light themes and Framer Motion animations

## Tech stack

| Layer | Technology |
| --- | --- |
| Framework | TanStack Start v1 (React 19, file-based routing, server functions) |
| Build tool | Vite 8 |
| Styling | Tailwind CSS v4, shadcn-style UI kit, Framer Motion (`motion`) |
| Data / charts | TanStack Query, Recharts |
| Backend | Lovable Cloud — PostgreSQL, authentication, row-level security, object storage |
| Containerization | Docker (multi-stage Alpine), Docker Compose |
| Monitoring | Prometheus metrics scraping, Grafana dashboards (`monitoring/`) |
| Orchestration | Kubernetes (`k8s/` Deployment and Service manifests) |
| CI/CD | GitHub Actions (`ci.yml`, `docker-publish.yml`) and Jenkins (`Jenkinsfile`) |

## Getting started

Requirements: Node.js 20 or newer and npm.

```sh
# After cloning this repository from its GitHub page, enter the cloned folder.
cd devops-24ESKCS029
npm install
npm run dev
```

Use the **Code** button on the GitHub repository page to copy its exact clone command.

The app starts on http://localhost:8080 (or http://localhost:3000 in preview/production).

### Environment variables

Create a `.env` file in the project root:

```text
Configure the Supabase environment variables using the values from your Supabase project. Do not commit .env or any secrets to GitHub.
```

These are publishable client values, safe to expose in the browser. No private keys are
stored in this repository, and `.env` is listed in `.gitignore`.

## npm scripts

| Script | Purpose |
| --- | --- |
| `npm run dev` | Start the development server |
| `npm run build` | Production build (compiles server and static assets) |
| `npm run start` | Start the compiled production Node server |
| `npm run preview` | Serve the production build locally |
| `npm run lint` | ESLint over the whole project |
| `npm run test` | Run the Vitest suite once |
| `npm run test:watch` | Run tests in watch mode |
| `npm run test:ci` | Run tests with a coverage report (used by CI) |
| `npm run format` | Format the codebase with Prettier |

## Containerization with Docker (Module 5)

HostelFix is containerized using a multi-stage `Dockerfile` based on `node:20-alpine`.

### Run with Docker Compose

```sh
# Build and run the app and Prometheus monitoring stack together
docker compose up -d

# Stop services
docker compose down
```

Services exposed:
- **HostelFix Web App:** `http://localhost:3000`
- **Prometheus Metrics:** `http://localhost:9090`

### Run with Docker directly

```sh
# Build container image
docker build -t hostelfix:latest .

# Run container
docker run -d -p 3000:3000 --name hostelfix hostelfix:latest
```

### Container Registry

Docker images are automatically built and published to GitHub Container Registry (GHCR) via GitHub Actions on every push to `main`:

```sh
docker pull ghcr.io/skit-devops-2026/devops-24eskcs029:latest
```

## Monitoring and Observability (Module 6)

- **Prometheus Config:** Configured in `prometheus.yml` and `monitoring/prometheus.yml` to scrape application metrics at `/metrics` every 10s.
- **Grafana Dashboard:** Complete pre-configured dashboard available in `monitoring/dashboard.json` tracking:
  - Application Status & Process Uptime
  - HTTP Request Rate & 2xx Success Rate
  - Latency percentiles (p50, p95, p99)
  - Process Memory (RSS & Heap) and CPU Utilization
- **Deployment Evidence:** Deployed production environment screenshot committed under `docs/deployment.png`.

## Kubernetes Orchestration (Module 7)

Production manifests are provided under the `k8s/` directory:

- `k8s/deployment.yaml`: Replicated deployment (2 replicas) with rolling updates, resource limits, liveness and readiness probes referencing `ghcr.io/skit-devops-2026/devops-24eskcs029:latest`.
- `k8s/service.yaml`: NodePort service routing external port 80 to container port 3000 (`nodePort: 30080`).
- `k8s/kustomization.yaml`: Kustomize orchestration manifest.

### Deploying to a Kubernetes Cluster (kind / k3d / minikube)

```sh
# Apply all manifests
kubectl apply -f k8s/

# Verify pods and service
kubectl get pods -l app=hostelfix -o wide
kubectl get deployments
kubectl get svc hostelfix-service

# Port forward to test locally
kubectl port-forward svc/hostelfix-service 8080:80
```

Pod verification screenshot is committed under `docs/kubectl-get-pods.png`.

## Project structure

```
.github/workflows/         GitHub Actions CI and GHCR container publishing pipelines
k8s/                       Kubernetes Deployment and Service manifests
monitoring/                Prometheus scrape configs and Grafana dashboard JSON
docs/                      Milestone evidence documentation and deployment screenshots
src/routes/                File-based routes (public pages + _authenticated area)
src/components/            Layout and shared UI kit
src/lib/                   Auth context, theme, domain constants, pure helpers
src/lib/__tests__/         Vitest unit tests
src/integrations/          Generated backend client and types
supabase/migrations/       Database schema, policies and storage setup
Dockerfile                 Multi-stage Docker container specification
docker-compose.yml         Docker Compose service definition (app + prometheus)
prometheus.yml             Prometheus metrics scraping configuration
vitest.config.ts           Test runner configuration
```

## Testing

```sh
npm run test        # run once
npm run test:ci     # run with coverage
```

Unit tests cover the complaint filtering, statistics, category grouping, pagination and
storage-path helpers in `src/lib/complaint-utils.ts`, plus the class-merging utility and the
domain constants. Every test runs on each push and pull request through GitHub Actions.
All automated tests are executed using Vitest with coverage reporting.

## Continuous integration

`.github/workflows/ci.yml` runs on every push, on pull requests targeting `main` and on
manual dispatch. Stages: checkout → install → test with coverage → production build →
upload the coverage artifact. A red pipeline blocks the merge until it is fixed.

`.github/workflows/docker-publish.yml` builds and pushes the container image to GitHub
Container Registry (`ghcr.io`) upon changes to the application and Dockerfile.

## Jenkins pipeline

`Jenkinsfile` defines a declarative pipeline with Checkout, Install, Test, Build and
Archive stages. It expects a Jenkins NodeJS tool installation named `node20`.

To run it locally:

1. Install Jenkins and the *NodeJS*, *Pipeline* and *Git* plugins.
2. In *Manage Jenkins → Tools*, add a NodeJS installation named `node20`.
3. Create a new *Pipeline* job, choose *Pipeline script from SCM*, point it at this
   repository and leave the script path as `Jenkinsfile`.
4. Build now. The Test stage runs the same Vitest suite as GitHub Actions, and the Build
   stage archives the compiled output.

## Branching and pull request workflow

- `main` — always deployable; changes only arrive through merged pull requests
- `develop` — integration branch for the current milestone
- `feature/<short-name>` — one branch per feature, e.g. `feature/complaint-filters`
- `fix/<short-name>` — bug fixes

Every pull request describes what changed, why, and how it was tested. CI must be green
before merging. See `CONTRIBUTING.md` for the full workflow and commit message convention.

## License

Released for academic coursework use.
DevOps workflow is managed using GitHub Actions and Jenkins.
The Jenkins pipeline automatically installs dependencies, runs the test suite, builds the application, and archives the generated outputs.
