Helm chart creation workflow
----------------------------
1. Create helm chart schema
```
helm create <chart-name>
```
2. Add/update manifests under templates/ and values.yml to meet your needs by comparing with kubernetes manifests
3. Lint helm chart
```
helm lint ./<chart-name>
```
4. Dry-run helm installation
```
helm install <release-name> ./<chart-name> --dry-run --debug
```
5. Install helm chart (un-packed)
```
helm install <release-name> ./<chart-name>
```
6. List helm release
```
helm list
```
7. Get all information of installed helm release
```
helm get all
```
8. List history of a named release
```
helm history <release-name>
```
9. Upgrade a helm release
```
helm upgrade <release-name> <chart-name>
```
10. Rollback a helm release
```
helm rollback <release-name> <revision-number>
```
11. Package a helm chart
```
helm package helm <release-name> ./<chart-name>
```
12. Un-install helm release
```
helm uninstall <release-name>
```
