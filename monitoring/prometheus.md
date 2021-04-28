Refrence
```
https://itnext.io/prometheus-for-beginners-5f20c2e89b6c

https://www.youtube.com/watch?v=h4Sl21AKiDg&t=0s

https://sysdig.com/blog/kubernetes-monitoring-prometheus/

```
- Features
    - Pull based mechanism to scrap metrics from targets
    - Agentless design, No additional logic to be included at targets
    - Service discovery based architecture
    - Modular & Highly available

- Core components of Prometheus Server
    - Time Series Database to store all our metrics data.
    - Data retrieval worker that is responsible for pulling/scraping metrics from external targets and pushing them into the time series database.
    - Web server that provides a simple web interface for configuration and querying of the data stored.
    - PromQL for quering metric data.

- Ports
    - Prometheus Server: 9090

- Metrics collection apart from application metrics,
    - Node exporter for the classical host-related metrics: cpu, mem, network, etc
    - kube-state-metrics for orchestration and cluster level metrics: deployments, pod metrics, resource reservation, etc.
    - Kubernetes control plane metrics: kubelet, etcd, dns, scheduler, etc.

- Additional components that work with Prometheus
    - Exporters to collect and transform metrics and expose them as /metrics from targets that doesn't natively serve metrics in prometheus format.
    - Alert manager for configurations of recievers & gateways to deliver alert notifications.
    - Grafana for data visualization.
    - Push-gateways, an intermediary services to allow pushing metrics to prometheus from targets that can't be scrapped.

- Prometheus helm chart for kubernetes cluster deploys
    - Prometheus server
    - Node-Exporter
    - Kube-state-metrics
    - AlertManager
    - Grafana
