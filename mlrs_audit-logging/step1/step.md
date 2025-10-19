# Step 1: Create an Audit Policy

Create a Kubernetes audit policy to achieve the following:
  - Purpose: 
      - Record Pod changes at `RequestResponse` level
      - Exclude all `ConfigMap` events
      - Exclude all `Secret` events
      - Include any others events at `Metadata` level
  
  
Save as: `/etc/kubernetes/audit/audit-granular.yaml`

Verify by clicking the check button.

<details>
  <summary>Solution</summary>

* Create a granular audit log policy:
  ```yaml
  apiVersion: audit.k8s.io/v1
  kind: Policy
  rules:
    # Log pods changes at `RequestResponse` level
    - level: RequestResponse
      resources:
        - group: ""
          resources: ["pods"]

    # Exclude all ConfigMap events
    - level: None
      resources:
        - group: ""
          resources: ["configmaps"]

    # Exclude all Secret events
    - level: None
      resources:
        - group: ""
          resources: ["secrets"]

    # Record everything else at `Metadata` level
    - level: Metadata
  ```

  Save into `/etc/kubernetes/audit/audit-granular.yaml`
  ```bash
  mkdir /etc/kubernetes/audit
  nano /etc/kubernetes/audit/audit-granular.yaml
  ```

* Verify it.

</details>
