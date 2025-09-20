# Step 1: Inspect and Mark Insecure Configurations

You are provided with a set of files that contain potential security issues. Your task is to inspect these files and identify any insecure configurations. Once identified, mark these insecure parts with comments explaining the security risks.

Files to Inspect:
- `/opt/static-analysis/deployment.yaml`
- `/opt/static-analysis/service.yaml`
- `/opt/static-analysis/role.yaml`
- `/opt/static-analysis/pod.yaml`
- `/opt/static-analysis/Dockerfile1`
- `/opt/static-analysis/Dockerfile2`
- `/opt/static-analysis/Dockerfile3`

Instructions:
1. **Inspect each file**: Open each file and review its contents.
2. **Identify security risks**: Look for any configurations or practices that could be considered insecure.
3. **Mark insecure configurations**: Add comments to the files (using `#` for YAML and `#` or `//` for Dockerfile) explaining why certain configurations are insecure.
4. **Rename the insecure files**: Rename the insecure files by adding suffix `.insecure` to each file

### Example:
In the `deployment.yaml`, you might find a `privileged: true` setting. You would add a comment like:
```yaml
privileged: true  # INSECURE: Privileged containers should be avoided
```

<details>
  <summary>Solution</summary>

List of insecure manifests:
- `/opt/static-analysis/deployment.yaml`

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: insecure-deployment
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: insecure-app
      template:
        metadata:
          labels:
            app: insecure-app
        spec:
          containers:
          - name: insecure-container
            image: nginx:latest
            ports:
            - containerPort: 80
            securityContext:
              privileged: true   # INSECURE: Privileged containers should be avoided
              capabilities:
                add: ["ALL"]     # INSECURE: Adding all capabilities is unnecessary and insecure
              readOnlyRootFilesystem: false # INSECURE: Root filesystem should be read-only
    ```
- `/opt/static-analysis/role.yaml`

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: insecure-role
      namespace: default
    rules:
    - apiGroups: [""]
      resources: ["pods", "secrets"]
      verbs: ["get", "list", "create", "delete"]  # INSECURE: Role has too many privileges, especially 'delete' on secrets
    ```
- `/opt/static-analysis/pod.yaml`
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: insecure-pod
    spec:
      containers:
      - name: insecure-container
        image: ubuntu:latest
        command: ["sh", "-c", "apt-get update && apt-get install -y netcat && nc -l -p 8080"]
        securityContext:
          runAsUser: 0   # INSECURE: Running as root user should be avoided
          runAsGroup: 0  # INSECURE: Running as root group should be avoided
          allowPrivilegeEscalation: true  # INSECURE: Privilege escalation should be disallowed
    ```

- `/opt/static-analysis/Dockerfile1`
    ```
    FROM ubuntu:latest

    # INSECURE: Always use a specific version of the base image, not 'latest'
    RUN apt-get update && apt-get install -y sudo vim netcat

    # INSECURE: Avoid installing unnecessary packages like sudo and vim in containers
    USER root  # INSECURE: Running as root should be avoided in Docker containers

    CMD ["bash"]
    ```

- `/opt/static-analysis/Dockerfile2`
    ```
    # INSECURE: Using an outdated and unsupported base image increases security risks.
    FROM ubuntu:14.04

    # INSECURE: Avoid installing unnecessary packages like sudo.
    # INSECURE: Always use the least privilege principle and avoid running as root.
    RUN apt-get update && apt-get install -y wget curl sudo

    COPY . /app

    WORKDIR /app

    # INSECURE: Running as the root user inside containers should be avoided.
    USER root

    CMD ["./run-app.sh"]
    ```

</details>