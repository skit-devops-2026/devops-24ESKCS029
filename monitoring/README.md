# Monitoring & Observability (Module 6)

This directory contains the production monitoring configurations for HostelFix.

## Stack Overview

- **Prometheus**: Pulls time-series metrics from application and container runtime (`prometheus.yml`).
- **Grafana Dashboard**: JSON export (`dashboard.json`) ready for direct import into Grafana.
- **Docker Compose Integration**: Configured in `docker-compose.yml` for unified local observability.

## Key Monitored Metrics

| Metric Panel | Description | Source / PromQL |
| :--- | :--- | :--- |
| **Application Status** | Live status of the HostelFix container | `up{job="hostelfix-app"}` |
| **Process Uptime** | Application duration since last boot | `time() - process_start_time_seconds` |
| **HTTP Request Rate** | Traffic throughput in requests/sec | `rate(http_requests_total[1m])` |
| **HTTP Success Rate** | Percentage of 2xx responses | `rate(http_requests_total{status=~"2.."}[5m]) / ...` |
| **Latency Percentiles** | Median (p50), 95th, and 99th latency | `histogram_quantile(..., rate(http_request_duration_seconds_bucket[5m]))` |
| **Memory Consumption** | RSS and Node.js heap usage | `process_resident_memory_bytes`, `nodejs_heap_size_used_bytes` |
| **CPU Utilization** | Process CPU consumption | `rate(process_cpu_user_seconds_total[1m])` |

## Running Locally

To spin up HostelFix together with Prometheus:

```sh
docker compose up -d
```

- HostelFix Application: `http://localhost:3000`
- Prometheus UI: `http://localhost:9090`

## Importing the Grafana Dashboard

1. Access Grafana UI at `http://localhost:3001` (or your cloud Grafana instance).
2. Go to **Dashboards → New → Import**.
3. Select or paste the contents of `monitoring/dashboard.json`.
4. Connect your Prometheus data source and click **Import**.
