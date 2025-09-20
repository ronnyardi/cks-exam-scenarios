# Step 2: Apply the Seccomp Profile to a Pod

Create a Pod named `seccomp-pod` in the namespace `seccomp`. Use `alpine/curl:3.14` as the container image. Add a command to the container to do a single `ping` to `kubernetes.io` indefinitely and add delay `5s`. Apply the seccomp profile to the Pod.

Of course, you need to ensure that the Pod scheduled in the respective nodes, which is having seccomp installed there. Get the last 50 lines of related logs from `/var/log/syslog` and save to `/opt/seccomp/answer` (save the answer in the controlplane or the default terminal session)


<details>
  <summary>Solution</summary>

* Get the worker node to be used as node selector to schedule the pod: `kubectl get node --show-labels`

* Create the Pod manifest using the seccomp profile:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: seccomp-pod
  namespace: seccomp
spec:
  nodeSelector:
    kubernetes.io/hostname: <node-name>
  securityContext:
    seccompProfile:
      type: Localhost
      localhostProfile: seccomp-audit.json
  containers:
  - name: secure-container
    image: alpine/curl:3.14
    command: ["sh", "-c", "while true; do ping -c 1 kubernetes.io; sleep 5; done"]
```

* Apply the Pod manifest: `kubectl apply -f seccomp-pod.yaml`

* Go to node01 where the seccomp is located: `ssh node01`

* Get the last related 50 lines of logs: `cat /var/log/syslog | grep "syscall" | tail -50`

* Copy and save the logs to `/opt/seccomp/answer`

* Aware that the syscall number are changing. When you run an infinite loop with sh, every iteration of the loop will execute the ping command and then sleep for 5 seconds. This activity will generate syscalls logged by seccomp.

</details>
