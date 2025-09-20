# Step 1: Create a Pod with Service Account for API Call

In the namespace `secure-api`, create a Pod named `secret-list` and use the container image `alpine/curl:3.14`. The container needs to make a curl call to the Kubernetes API `https://kubernetes.default.svc/api/v1/` that lists all Secrets objects in the default namespace. You can use this commands to make a curl call indefinitely in the container commands.
```bash
while true; do 
  curl -s -k -m 5 -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes.default.svc.cluster.local/api/v1/namespaces/<namespace name>/<object name>; \
  sleep 10; \
done
```

There is a service account named `call-api` in the namespace `secure-api`, attach it to the Pod.

Get the Pod logs and save it in `/opt/secure-api/answer`


<details>
  <summary>Solution</summary>

* Create the Pod manifest:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-list
  namespace: secure-api
spec:
  serviceAccountName: call-api
  containers:
  - name: curl
    image: alpine/curl:3.14
    command: ['sh', '-c', 'while true; do curl -s -k -m 5 -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc.cluster.local/api/v1/namespaces/default/secrets; sleep 10; done']
```

* Apply the Pod manifest: `kubectl apply -f secret-list.yaml`

* Inspect the container logs after the Pod has started: `kubectl logs -f secret-list -n secure-api`

* Save the container logs: `kubectl logs secret-list -n secure-api > /opt/secure-api/answer`

</details>
