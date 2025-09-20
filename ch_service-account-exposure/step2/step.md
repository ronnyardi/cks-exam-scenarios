# Step 2: Assign ClusterRole and RoleBinding to the Service Account

Create a Cluster Role with name `secret-list` to the resources `secrets` and verb `get, list`. Bind the ClusterRole to the `call-api` service account that only allows the operation needed by the Pod. 

Check the logs of the `service-list` Pod again to verify. You shall see a changes in the logs against the previous step.

<details>
  <summary>Solution</summary>

* Create a ClusterRole that allows listing services:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: secret-list
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```

* Create a ClusterRoleBinding to bind the ClusterRole to the service account:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: secret-list-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: secret-list
subjects:
- kind: ServiceAccount
  name: call-api
  namespace: secure-api
```

* Apply the ClusterRole and RoleBinding manifests:
```sh
kubectl apply -f secret-list-clusterrole.yaml
kubectl apply -f secret-list-rolebinding.yaml
```

* Check the logs of the `secret-list` Pod again: `kubectl logs -f secret-list -n secure-api`

After applying the correct permissions, the curl command in the Pod should list all secrets in the default namespace without authorization errors.
</details>