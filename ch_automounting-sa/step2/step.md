# Step 2: Disable Automounting of Service Account Token

In this step, you need to disable automatic mounting of service account tokens and verify that the token is not present inside the pod. 

In the namespace `poc-sa-mount`, create a new service account `sa-secure` with automount disabled in the service account spec.

  * [Q1] Create a running busybox pod, name it `q1-secure-sa`, and attach the service account `sa-secure` to it. Verify if the service account token is mounted in the pod filesystem or not? (YES/NO)

  * [Q2] Create a running busybox pod, name it `q2-secure-sa` with automount enabled in the pod spec, and attach the service account `sa-secure` to it. Verify if the service account token is mounted in the pod filesystem or not? (YES/NO)

  * [Q3] In the `default` namespace, create a running busybox pod, name it `q3-secure-sa` with automount disabled in the pod spec. Verify if the service account token is mounted in the pod filesystem or not? (YES/NO)

Create a file `/tmp/ch-answer.txt` and write your answer inside it as comma-separated (below for example)
```
YES,NO,NO
```

<details>
  <summary>Solution</summary>

  1. **Create the service account with automount disabled:**
      ```
      cat <<EOF | kubectl apply -f -
      apiVersion: v1
      kind: ServiceAccount
      metadata:
        name: sa-secure
        namespace: poc-sa-mount
      automountServiceAccountToken: false
      EOF
      ```

  2. **Q1: Create a busybox pod using `sa-secure` (default pod spec):**
      ```yaml
      apiVersion: v1
      kind: Pod
      metadata:
        name: q1-secure-sa
        namespace: poc-sa-mount
      spec:
        serviceAccountName: sa-secure
        containers:
        - name: busybox
          image: busybox
          command: ["sh", "-c", "sleep 1d"]
      ```
      
      ```bash
      kubectl apply -f q1-secure-sa.yaml
      kubectl exec -n poc-sa-mount q1-secure-sa -- ls /var/run/secrets/kubernetes.io/serviceaccount/
      ```
      Nothing returned, that means the token is not mounted, then the answer is `NO`

  3. **Q2: Create a busybox pod with automount disabled in pod spec:**

      ```yaml
      apiVersion: v1
      kind: Pod
      metadata:
        name: q2-secure-sa
        namespace: poc-sa-mount
      spec:
        serviceAccountName: sa-secure
        automountServiceAccountToken: true
        containers:
        - name: busybox
          image: busybox
          command: ["sh", "-c", "sleep 1d"]
      ```

      ```bash
      kubectl apply -f q2-secure-sa.yaml
      kubectl exec -n poc-sa-mount q2-secure-sa -- ls /var/run/secrets/kubernetes.io/serviceaccount/
      ```
      It returns the files! `token`, `ca.crt`, `namespace`, that means the token is not mounted, then the answer is `YES`

  5. **Q3: Create a busybox pod in `default` namespace with automount disabled:**

      ```yaml
      apiVersion: v1
      kind: Pod
      metadata:
        name: q3-secure-sa
        namespace: default
      spec:
        automountServiceAccountToken: false
        containers:
        - name: busybox
          image: busybox
          command: ["sh", "-c", "sleep 1d"]
      ```

      ```bash
      kubectl apply -f q3-secure-sa.yaml
      kubectl exec q3-secure-sa -- ls /var/run/secrets/kubernetes.io/serviceaccount/
      ```
      Even though the default namespace did not state that automount is disabled. Nothing returned, that means the token is not mounted, then the answer is `NO`

  6. **Write answers to `/tmp/ch-answer.txt`:**

      ```bash
      echo "NO,YES,NO" > /tmp/ch-answer.txt
      ```
  
  7. **Important Notes**:

      If both the ServiceAccount and the Pod's .spec specify a value for automountServiceAccountToken, the Pod spec takes precedence. That's what happens in the Q2.

</details>
