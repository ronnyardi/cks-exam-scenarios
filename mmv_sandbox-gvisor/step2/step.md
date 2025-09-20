# Step 2: Create a Pod Using the gVisor Runtime

In the namespace `sandbox`, create a pod named `gvisor-pod` using runtime class named `gvisor` that you've created before. The container uses image `nginx:1.23.2`. 

Write down the output of `dmesg` command from the pod and save to `/opt/gvisor/answer`


<details>
  <summary>Solution</summary>

* Create a Pod manifest using the gvisor runtime:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gvisor-pod
  namespace: sandbox
spec:
  runtimeClassName: gvisor
  containers:
  - name: nginx
    image: nginx:1.23.2
```

* Apply the Pod manifest: `kubectl apply -f gvisor-pod.yaml`

* Exec to the Pod and run `dmesg` command:  `kubectl exec -n sandbox gvisor-pod -- dmesg > /opt/gvisor/answer`

</details>
