Autoscaling capabilities on k8s
-------------------------------

Pre-requsite:
    - Requires metric server to be deployed to the cluster for leveraging the autoscaling capabilities.

- Cluster Auto-scaler
    - Cluster Autoscaler is a tool that automatically adjusts the size of the Kubernetes cluster when one of the following conditions is true:
        - there are pods that failed to run in the cluster due to insufficient resources.
        - there are nodes in the cluster that have been underutilized for an extended period of time and their pods can be placed on other existing nodes.
    - Designed to run as a deployment on kubernetes control plane node.
    - Most of cloud providers support Cluster Autoscaler implementation.
    - On AWS, Cluster Autoscaler utilizes Amazon EC2 Auto scaling Groups to manage node groups.
    ```
    https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md

    ```

- Horizontal Pod Auto-scaler
    - Manages the auto-scaling of pods in a deployment/statefulset based on observed CPU utilization, Memory utilization or custom metrics.
    - HPA is implemented as a control loop which periodically queries the resource utlization (from a series of aggregated APIs) against the metrics specified in each HPA definition.
    - HPA is supported by kubectl commands like
        - kubectl [create | get | delete | describe] hpa
        - kubectl autoscale <controller> <resource-name> --min=n --max=m --cpu-percent=<target utilization value>
    ```
    https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
    https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/

    ```

- Vertical Pod Auto-scaler
    - VPA manages updating the resource limits and requests for the container in the pods based on usage pattern over time automatically.
    - VPA can also be used to understand the resource requirements of pods by leveraging the recommendation feature.
    - VPA is configured with a custom resource definition called VerticalPodAutoscaler.
    - VPA should not be used with the Horizontal Pod Autoscaler (HPA) on CPU or memory at this moment. However, you can use VPA with HPA on custom and external metrics.
    - Configured as a resource for deployment controller to handle vertical scaling (in/out) of pods.
    - Components of VPA:
        - Recommender - it monitors the current and past resource consumption and, based on it, provides recommended values containers' cpu and memory requests.
        - Updater - it checks which of the managed pods have correct resources set and, if not, kills them so that they can be recreated by their controllers with the updated requests.
        - Admission Plugin - it sets the correct resource requests on new pods (either just created or recreated by their controller due to Updater's activity).
    ```
    https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#readme

    ```