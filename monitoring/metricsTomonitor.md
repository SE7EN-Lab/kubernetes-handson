Refrence
```
https://www.datadoghq.com/blog/monitoring-kubernetes-performance-metrics/
```

- Metrics to alert on
    - Cluster state metrics
        - Desired vs. Current Pods
            - Indicates nodes lacking resource capacity to schedule new pods or problem with configuration that is causing pods to fail.
        - Available vs. Un-available Pods
            - Spikes in the number of un-available pods or pods that are consistently un-available indicate a problem with their configuration (poorly configured Readiness probes).
    
    - Resource metrics
        - Memory limits per pod vs. Memory Utilization per pod
            - Indicate the risk of Pod being OOMkilled.
        - Memory requests per node vs. Allocatable memory per node
            - Indicates that nodes of the cluster have enough resource capacity to host new pods or to provision more nodes for your cluster.
        - Disk Utilization at node level
            - Indicate the disk utilization(capacity, utilization, available space) at Node level and volume level to provision new volumes.
        - CPU requests per node vs. Allocatable CPU per node
            - Provides insight on capacity planning and whether your cluster can support more pods.
        - CPU limits per pod vs. CPU utilization per pod
            - Helps to determine if your limits are configured properly based on the pod's actual CPU needs.
        - CPU utilization at node level
            - Provides insight into cluster performance and to ensure that all pods running on a node are requesting enough CPU to run properly.
    - Kubernetes events
        - Collecting events from Kubernetes and from the container engine helps to point to mis-configured launch manifests or issues of resource saturation on your nodes.
    