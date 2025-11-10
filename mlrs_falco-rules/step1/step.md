# Step 1: Setup Falco Rules

Falco has been installed in the controlplane node and is running to detect the activity such as container runtime. Try to run any pod in the Kubernetes cluster and use `securityContext.privileged: true` in the container spec. Then, inspect Falco logs to see the detection message, it should has priority level of Informational.

Your task is to customize the associated Falco rule for the following points to follow your organization compliances:
- Change the priority of the detection rule from `INFO` to `WARNING`.
- Change the text `Privileged container started` into `[P2] Privileged Container Detected` at the beginning of the output message.
- Right after the pipe `|`, add a new label `evt_time=...` with the value of event timestamp in ISO 8601 format, including nanoseconds and time zone offset. 

<details>
  <summary>Solution</summary>

1. Run a privileged container in the cluster:

    ```sh
    kubectl run priv-pod --image busybox --dry-run=client -o yaml -- sleep 1d > priv-pod.yaml
    ```
    Edit the pod manifest to enable privileged container as below

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      labels:
        run: priv-pod
      name: priv-pod
    spec:
      containers:
      - args:
        - sleep
        - 1d
        image: busybox
        name: priv-pod
        resources: {}
        securityContext:            # Add these lines
          privileged: true          # Add these lines
      dnsPolicy: ClusterFirst
      restartPolicy: Always
    ```

    ```bash
    kubectl apply -f priv-pod.yaml 
    ```

2. Inspect the syslog related to Falco to find the associated rule:

    ```bash
    cat /var/log/syslog | grep falco
    ...
    2025-11-10T03:56:00.916131+00:00 controlplane falco: 03:56:00.914363477: Informational Privileged container started | evt_type=execve user=root user_uid=0 user_loginuid=-1 process=sleep proc_exepath=/bin/sleep parent=containerd-shim command=sleep 1d terminal=0 container_id=6f79d4e96acb container_name=priv-pod container_image_repository=docker.io/library/busybox container_image_tag=latest k8s_pod_name=priv-pod k8s_ns_name=default
    ...
    ```
    You can use this command to find the rule:
    ```bash
    grep -l 'Privileged container started' /etc/falco/falco*
    /etc/falco/falco_rules.local.yaml
    ```
3. Edit the rule in the file above:
    ```yaml
    # Your custom rules!
    - macro: container_started
      condition: >
        (spawned_process and proc.vpid=1 and container)

    - rule: Launch Privileged Container
      desc: > 
        Detect the initial process initiation within a privileged container, with exemptions for known and trusted images. 
        This rule primarily serves as an excellent auditing mechanism since highly privileged containers, when compromised, 
        can result in significant harm. For instance, if another rule triggers within such a privileged container, it could be 
        seen as more suspicious, prompting a closer inspection.
      condition: >
        container_started 
        and container.privileged=true
      output: '[P2] Privileged Container Detected | evt_time=%evt.time.iso8601 evt_type=%evt.type user=%user.name user_uid=%user.uid user_loginuid=%user.loginuid process=%proc.name proc_exepath=%proc.exepath parent=%proc.pname command=%proc.cmdline terminal=%proc.tty'    #Change this!
      priority: WARNING       #Change this!
      tags: [maturity_incubating, container, cis, mitre_execution, T1610, PCI_DSS_10.2.5]
    ```
4. Restart Falco to take the effects:
    ```bash
    systemctl restart falco
    ```

    Verify if Falco is running correctly!
    ```bash
    systemctl status falco
    ● falco-modern-bpf.service - Falco: Container Native Runtime Security with modern ebpf
        Loaded: loaded (/usr/lib/systemd/system/falco-modern-bpf.service; enabled; preset: enabled)
        Active: active (running) since Mon 2025-11-10 04:37:50 UTC; 41s ago
          Docs: https://falco.org/docs/
      Main PID: 13531 (falco)
          Tasks: 11 (limit: 2534)
        Memory: 57.8M (peak: 66.3M)
            CPU: 1.303s
        CGroup: /system.slice/falco-modern-bpf.service
                └─13531 /usr/bin/falco -o engine.kind=modern_ebpf

    Nov 10 04:37:51 controlplane falco[13531]:    /etc/falco/falco_rules.yaml | schema validation: ok
    Nov 10 04:37:51 controlplane falco[13531]:    /etc/falco/falco_rules.local.yaml | schema validation: ok
    ```
5. Rerun the previous privileged container, you can use the following command:
    ```bash
    kubectl replace -f priv-pod.yaml --force --grace-period 0
    pod "priv-pod" deleted from default namespace
    pod/priv-pod replaced
    ```
    Check the Falco syslog again!
    ```bash
    2025-11-10T04:39:57.579597+00:00 controlplane falco: 04:39:57.577937037: Warning [P2] Privileged Container Detected | evt_time=2025-11-10T04:39:57.577937037+0000 evt_type=execve user=root user_uid=0 user_loginuid=-1 process=sleep proc_exepath=/bin/sleep parent=containerd-shim command=sleep 1d terminal=0 container_id=745776de8a4c container_name=priv-pod container_image_repository=docker.io/library/busybox container_image_tag=latest k8s_pod_name=priv-pod k8s_ns_name=default
    ```
    Congrats.

</details>
