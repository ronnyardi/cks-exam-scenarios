# Step 1: Enforce PSA in a Namespace

You are a Kubernetes security specialist at a fintech company. Developers frequently deploy workloads into the `dev` namespace without applying proper security best practices. Recently, a developer deployed a Pod with privileged access and no security context, exposing the node to potential container breakout attacks.

Your task is to `enforce` Pod Security Admission (PSA) in the `dev` namespace to prevent such insecure configurations and ensure all Pods comply with the `restricted` Pod Security Standard (PSS).

<details>
  <summary>Solution</summary>

1. Get the namespace with the labels:
    ```bash
    kubectl get namespace dev --show-labels
    ```
    As we can see below, there is only one label to mark the namespace name. 
    ```
    NAME   STATUS   AGE    LABELS
    dev    Active   100s   kubernetes.io/metadata.name=dev
    ```

2. Label the namespace to apply PSA enforcement:
    
    ```bash
    kubectl label ns dev pod-security.kubernetes.io/enforce=restricted
    ```
    The label above detailed as the below:

    * Mode `enforce` :	Policy violations will cause the pod to be rejected.
    
    * Profile `Restricted`:	Heavily restricted policy, following current Pod hardening best practices.

3. Verify by deploying Privileged pod:
    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Pod
    metadata:
      name: privileged-web-serv
      namespace: dev
    spec:
      containers:
      - name: nginx
        image: nginx:1.23.1
        securityContext:
          privileged: true
    EOF
    ```

4. You will receive a Forbidden error as the below:
    ```bash
    Error from server (Forbidden): error when creating "STDIN": pods "privileged-web-serv" is forbidden: violates PodSecurity "restricted:latest": privileged (container "nginx" must not set securityContext.privileged=true), allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    ```

    This marks that your PSA enforcement to the `dev` namespace has successfully working.

</details>
