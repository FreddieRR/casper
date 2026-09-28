# Prometheus

Configuration for Prometheus, which scrapes the API's `/metrics` endpoint and the GPU exporter on the laptop, and stores the time series that Grafana displays.

**Built in:** Week 7, Day 33. Read the Prometheus overview (prometheus.io/docs/introduction/overview) and the Google SRE book chapter "Monitoring Distributed Systems" first.

**Will contain:** `prometheus.yml` (scrape targets and intervals) and alert rules (e.g. p95 latency above a threshold, GPU above 85 °C).
