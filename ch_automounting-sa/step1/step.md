# Step 1: Default Behavior of Service Account Token Mounting

Understand that Kubernetes has a default behavior to automatically mounts the service account tokens inside the pod. You need to verify the presence of the token inside the pod.

* Create a namespace `poc-sa-mount`

* In that namespace, create a pod named `not-secure` using `busybox` image and add command `sleep 1d` to keep it running

* Verify if the default service account for that namespace is mounted in the pod filesystem

Tips: default location of token is at `/var/run/secrets/kubernetes.io/serviceaccount/token`

<details>
  <summary>Solution</summary>
  
1. **Create namespace**:

    ```bash
    kubectl create namespace poc-sa-mount
    ```
2. **Create a pod**:
    ```yaml
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: not-secure
      namespace: poc-sa-mount
    spec:
      containers:
      - args:
        - sh
        - -c
        - sleep 1d
        image: busybox
        name: not-secure
    EOF
    ```
3. **Exec into the container to view the token**:
    ```bash
    kubectl exec -it --namespace poc-sa-mount not-secure -- sh
    ```

    ```bash
    cat /var/run/secrets/kubernetes.io/serviceaccount/token
    ```
    You should see a long JWT token printed to the screen. This confirms that the service account token is mounted by default.
4. **Also check**:
    ```bash
    ls /var/run/secrets/kubernetes.io/serviceaccount/
    ```

    There should be files: `token`, `ca.crt`, `namespace` 

</details>
