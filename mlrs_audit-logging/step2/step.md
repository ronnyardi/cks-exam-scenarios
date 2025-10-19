# Step 2: Configure the API Server to Use the Audit Policy

Enable the minimal audit policy to the kube-apiserver. The Kubernetes API Server manifest is located at `/etc/kubernetes/manifests` in the node where the pod remains.

Use a directory to save the logs into `/var/log/kubernetes/audit`. This means, you will need to mount a volume inside the pod above.

When enabling the audit logging, also ensure the following:
- Set the maximum number of days to retain old audit log files for `30` days
- Set the maximum number of audit log to retain to `10` files
- Set the maximum size of the audit log file to `150` MB

Ensure the that the underlying container for the kube-apiserver is working correctly after making the changes.

To test the audit records, try to create a pod, create and delete a configmap or a secret. Check the audit log file and verify if your activity has recorded. 

<details>
  <summary>Solution</summary>

* Edit the kube-apiserver pod manifest: 
    ```bash
    vim /etc/kubernetes/manifests/kube-apiserver.yaml
    ```


    ```yaml
    ...
    spec:
      containers:
      - command:
        - kube-apiserver
        - --audit-policy-file=/etc/kubernetes/audit/audit-granular.yaml # location of the policy file 
        - --audit-log-path=/var/log/kubernetes/audit/audit.log # log file to the API server process
        - --audit-log-maxage=30
        - --audit-log-maxbackup=10
        - --audit-log-maxsize=150
        ...
        volumeMounts:
        - mountPath: /etc/kubernetes/audit/audit-granular.yaml # mounts policy file
          name: audit
          readOnly: true
        - mountPath: /var/log/kubernetes/audit/ # mounts log file
          name: audit-log
          readOnly: false
      ...
      volumes:
      - name: audit # volume policy
        hostPath:
          path: /etc/kubernetes/audit/audit-granular.yaml
          type: File
      - name: audit-log # volume logs
        hostPath:
          path: /var/log/kubernetes/audit/
          type: DirectoryOrCreate
    ```

* Apply and monitor the container status:
    ```bash
    $ crictl ps -a | grep kube-apiserver
    c022de05ee1e8       ee794efa53d85       28 seconds ago      Running             kube-apiserver            0                   0e61901a133ce       kube-apiserver-controlplane               kube-system

    $ kubectl get pod -n kube-system | grep kube-apiserver
    kube-apiserver-controlplane               1/1     Running   0              52s
    ```

* Run a pod, create and delete configmap or a secret, inspect the log
    ```bash
    kubectl run i-create-pod --image busybox -- sleep 1h
    kubectl create configmap i-create-configmap --from-literal hello=world
    kubectl create secret generic i-create-secret --from-literal password=who --from-literal username=me
    kubectl expose pod i-create-pod --name=i-create-svc --port 80
    ```

    ```bash
    $ grep 'i-create-pod' /var/log/kubernetes/audit/audit.log | tail -1 | jq .
    {
      "kind": "Event",
      "apiVersion": "audit.k8s.io/v1",
      "level": "RequestResponse",   # Confirmed the level is set to `RequestResponse`
      "auditID": "dcb781a9-bdcf-4f50-8178-1972f1fcc7cf",
      "stage": "ResponseComplete",
      "requestURI": "/api/v1/namespaces/default/pods/i-create-pod",
      "verb": "get",
    ....

    $ grep 'i-create-configmap' /var/log/kubernetes/audit/audit.log | tail -1 | jq .
    # Return nothing

    $ grep 'i-create-secret' /var/log/kubernetes/audit/audit.log | tail -1 | jq .
    # Return nothing

    $ grep 'i-create-svc' /var/log/kubernetes/audit/audit.log | tail -1 | jq .
    {
      "kind": "Event",
      "apiVersion": "audit.k8s.io/v1",
      "level": "Metadata",  # Confirmed other events recorded at `Metadata` level
      "auditID": "49f442ce-870b-41f1-b99b-b19dfb72c36c",
      "stage": "ResponseComplete",
      "requestURI": "/api/v1/namespaces/default/endpoints",
      "verb": "create",
      "objectRef": {
        "resource": "endpoints",
        "namespace": "default",
        "name": "i-create-svc",
        "apiVersion": "v1"
      },
    ...
    
    ```

</details>
