# Step 1: Create a Pod with Read-Only Filesystem

Create a Pod named `secure-app` in the namespace `secure-fs` with a read-only filesystem. The container image use `busybox:1.35.0` and should run these commands:

```sh
while true; do
  echo "Writing to /tmp";
  echo "$(date)" > /tmp/date.log;
  sleep 5;
done
```

Check the output of the container logs and see what's your thoughts

<details>
  <summary>Solution</summary>

* Create the Pod manifest:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: secure-fs
spec:
  containers:
  - name: busybox
    image: busybox:1.35.0
    command: ['/bin/sh', '-c', 'while true; do echo "Writing to /tmp"; echo "$(date)" > /tmp/date.log; sleep 5; done']
    securityContext:
      readOnlyRootFilesystem: true
```

* Apply the Pod manifest: `kubectl apply -f secure-app.yaml`

* Verify the Pod is running: `kubectl get pods -n secure-fs`

</details>
