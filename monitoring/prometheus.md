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
    - Exporter is a “translator” or “adapter” program that is able to collect native metrics from targets and re-publish them using the Prometheus metrics format and exposes the metrics to be scraped.
    - Alert manager for configurations of recievers & gateways to deliver alert notifications.
    - Grafana for data visualization.
    - Push-gateways, an intermediary services to allow pushing metrics to prometheus from targets that are showt lived and can't be scrapped.

- Prometheus helm chart for kubernetes cluster deploys
    - Prometheus server
    - Node-Exporter
    - Kube-state-metrics
    - AlertManager
    - Grafana

- Monitoring Services running on kubernetes cluster
    - For services that natively support and expose prometheus metrics format, 
        - Update conifg map object of prometheus server to add static config of new target to be scrapped.
        - Alternative to using static target in configuration, Prometheus supports adding targets dynamically by annotating pods or services with metadata.
    - For services that doesn't natively support & expose prometheis metrics format,
        - Use appropriate exporter as side-car to the actual target containers you intend to monitor. Exporter exposes the service metrics converted into Prometheus metrics, so you just need to scrape the exporter.
        - Update conifg map object of prometheus server to add static config of new target to be scrapped.
- Monitoring kubernetes cluster
    - kubernetes hosts(nodes) metrics: Classic sysadmin metrics such as CPU, Load, Disk, Memory
        - Prometheus node-exporter deployed as Daemonset using HELM chart help exposing node level metrics.

    - Orchestration level metrics: kubernetes objects like Deployment, Replicasets etc.
        - kube-state-metrics that gets installed as part of Prometheus Helm chart help expose the metrics.
        - Prometheus config map needs to be updated to scrap endpoint exposed by kube-state-metrics service.

    - kubernetes control plane component metrics: 
        - Expose the control plane pods by a service.
        - Configure prometheus to scrap the service of the control plan pods for metrics.
    
