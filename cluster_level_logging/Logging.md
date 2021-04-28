Reference
---------
```
https://www.sumologic.com/blog/kubernetes-logs/

https://kubernetes.io/docs/concepts/cluster-administration/logging/

https://fluentbit.io/blog/2020/12/03/common-architecture-patterns-with-fluentd-and-fluent-bit/

```
- Log streams
    - Logs of different formats and source.
- Log aggregator
    - Program that aggregates, process all the logging streams at the node level and publish to a central logging backend.
- Logging backend
    - Stores, analyze and query logs centrally.
- Log rotation
    - Mechanism that controls the logs based on time, size and other parameters.

- Source of Logs in a kubernetes cluster
    - System components that run as part of OS consumed by systemd logging framework - kubelet, Container run time.
    - System components that run as containers managed by kubelet consumed by container runtime logging framework - kube-apiserver, kube-controller-manager, kube-scheduler, kube-proxy, etcd.

- Basic logging capabilties
    - kubelet on the node handles the request (kubectl logs) and reads directly from the log file. The kubelet returns the content of the log file.
    - If a container restarts, the kubelet keeps one terminated container with its logs. 
    - If a pod is evicted from the node, all corresponding containers are also evicted, along with their logs.


- Patterns of Cluster Level Logging
    - Node level logging agent that runs on every node.
    - Dedicated sidecar container for logging in an application pod.
        - Resource intensive approach.
        - Won't be able to access those logs using kubectl logs because they are not controlled by the kubelet.
    - Push logs directly to logging backend from an application.
        - Needs to be implemented at application logic.


Fluentd
-------
input plugin - where to get logs
filter plugin - to transform logs before sending to destination
output plugin - where to send logs
