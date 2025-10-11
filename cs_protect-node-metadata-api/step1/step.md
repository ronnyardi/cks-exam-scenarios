# Step 1: Protect AWS Node Metadata API

Your organization hosts its Kubernetes cluster on AWS, where each node can access the instance metadata service at `http://169.254.169.254`. This metadata API can expose sensitive information if not properly secured.

As a Cloud Platform Security Engineer, your task is to restrict access to the node metadata API in the `default` namespace. Implement a network policy named `deny-access-cloud-metadata` that allows egress traffic to all destinations except `169.254.169.254/32`.

Additionally, there is a pod named `metadata-accessor` in the `default` namespace that requires access to the metadata API. To accommodate this, create a separate network policy named `allow-access-cloud-metadata` that permits only this pod to communicate with the metadata service.

<details>
  <summary>Solution</summary>

1. Create a network policy to allow egress traffic to all IP addresses except `169.254.169.254/32`
    
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: deny-access-cloud-metadata
      namespace: default
    spec:
      podSelector: {}
      policyTypes:
      - Egress
      egress:
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
            - 169.254.169.254/32
    ```

2. Create a network policy to allow `metadata-accessor` pod to access the metadata server

    Check the label of the pod metadata-accessor as it is needs to add it in the network policy
    ```bash
    kubectl get pod -n default --show-labels
    ```

    We can see the label `role=metadata-accessor`, we will use this to match the pod later

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-access-cloud-metadata
      namespace: default
    spec:
      podSelector: 
        matchLabels:
          role: metadata-accessor
      policyTypes:
      - Egress
      egress:
      - to:
        - ipBlock:
            cidr: 169.254.169.254/32
    ```

3. Apply network policies and test the result
    ```bash
    kubectl exec metadata-tester -- curl -s -m5 http://169.254.169.254
    command terminated with exit code 28

    kubectl exec metadata-accessor -- curl -s -m5 http://169.254.169.254
    <html>
      <head><title>Mock Metadata</title></head>
      <body>
        <h1>This is a mock AWS metadata server, welcome?</h1>
      </body>
    </html>
    ```
    Access for pod metadata-accessor is SUCCESS, meanwhile metadata-tester is FAILED due to the applied network policy in step 1

</details>