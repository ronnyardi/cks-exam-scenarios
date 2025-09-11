# Objective 2: Block chmod Execution

The second objective is to block the execution of `chmod` commands within the container. The custom AppArmor profile already denies this operation. You will now apply this profile to another Pod and verify that the `chmod` command is blocked.


Create a pod with name `block-chmod-pod` using `busybox` image and add a command as the below:

```
sh -c chmod 777 /tmp
```

<details>
  <summary>Solution</summary>

1. **Create the Pod Manifest**:
   Create a YAML file named `block-chmod-pod.yaml` with the following content:
   ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: block-chmod-pod
      namespace: apparmor
    spec:
      securityContext:
        appArmorProfile:
          type: Localhost
          localhostProfile: deny-write-profile
      containers:
      - name: block-chmod-container
        image: busybox
        command: ["sh", "-c", "chmod 777 /tmp"]
    ```

2. **Check the pod logs**:
   The pod will not be deployed as it will be prevented to run, you will see the status as CrashLoopbackOff. Run the following command:
   ```bash
   kubectl logs -n apparmor pods/block-chmod-pod
   ```

3. **The result**:
   Ensure the result is Permission denied.

</details>
