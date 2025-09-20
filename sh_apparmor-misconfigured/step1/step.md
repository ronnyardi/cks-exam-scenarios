# Objective 1: Fix Misconfigured AppArmor Profile

There is a deployment named `corndog-service` in the namespace `apparmor`. However, the deployment has 0 replicas out of its desired replicas. The current kubernetes node is already installed and enabled with AppArmor profiles. Your task is to fix the deployment that has a misconfiguration in the AppArmor config in its manifest. 

Find the root cause and apply the necessary fix to ensure that all desired replicas are running correctly!


<details>
  <summary>Solution</summary>

1. **Check the pod events**:

    ```bash
    kubectl describe pods -n apparmor -lapp=corndog-service
    ```
2. **Notice the following error**:
    ```
    Error: failed to get container spec opts: failed to generate apparmor spec opts: apparmor profile not found dockerz-default
    ```
3. **Get the correct AppArmor profile**:
    ```
    apparmor_status | grep docker
    ```

    You will see that there is a profile named `docker-default`, this is the correct one.

4. **Fix the deployment manifest**:
    ```yaml
    template:
      spec:
        containers:
        ...
        securityContext:
          appArmorProfile:
            localhostProfile: docker-default    #Fix this line
            type: Localhost
    ```

    Reapply or replace the deployment.

5. **Check the deployment replicas**:
    ```bash
    kubectl get pod -A -lapp=corndog-service
    ```{{copy}}

</details>
