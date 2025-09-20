# Step 1: Run a Pod with a Non-Root User

There are a couple of pod running in the namespace `limited`. Your task is to configure both of the container from each pod to run as a non-root user. After applying the changes, you must find that not all images could be ran using non-root user. Write the pod name that failed in the `/opt/non-root/answer`

<details>
  <summary>Solution</summary>

1. Edit the `dark-illusion` pod and add `runAsNonRoot` in the security context:
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: dark-illusion
      namespace: limited
    spec:
      containers:
      - name: busybox
        image: busybox:1.34
        command: ["sh", "-c", "sleep 3600"]
        securityContext:
          runAsNonRoot: true      # Add this line
    ```

2. Edit the `prime-ships` pod as the above:
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: prime-ships
      namespace: limited
    spec:
      containers:
      - image: nginx:1.23.1
        name: nginx
        securityContext:
          runAsNonRoot: true      # Add this line
    ```

3. Write the answer: `echo prime-ships > /opt/non-root/answer`

</details>
