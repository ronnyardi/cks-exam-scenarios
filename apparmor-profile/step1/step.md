# Objective 1: Deny All Write Operations

Your first objective is to ensure that a container is secured by denying all write operations. The AppArmor profile is provided below. Install the profile and enable it in the master node as `deny-write-profile`.

```
#include <tunables/global>

profile deny-write-profile flags=(attach_disconnected){
  # Allow everything else
  #include <abstractions/base>

  # Deny all write operations
  file,
  deny /** w,
}
```

Create a pod with these details:

* name: `deny-write-pod`
* namespace: `apparmor`
* image: `busybox`
* command: `sleep 1d`

You will need to apply the profile to a Pod and verify that the container cannot perform any write operations. Apply the necessary annotations for this. After deployed, test it to the container and do some writable actions.


<details>
  <summary>Solution</summary>

1. **Apply the apparmor profile**:

    ```bash
    sudo tee /etc/apparmor.d/deny-write-profile <<EOF
    #include <tunables/global>

    profile deny-write-profile flags=(attach_disconnected){
      #include <abstractions/base>

      # Deny all write operations
      file,
      deny /** w,
    }
    EOF
    ```
2. **Load the apparmor profile**:

    ```bash
    sudo apparmor_parser -r /etc/apparmor.d/deny-write-profile
    ```

3. **Create the Pod Manifest**:
    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
      name: deny-write-pod
      namespace: apparmor
    spec:
      securityContext:
        appArmorProfile:
          type: Localhost
          localhostProfile: deny-write-profile
      containers:
      - name: deny-write-container
        image: busybox
        command: ["sh", "-c", "sleep 1d"]

4. **Test the apparmor profile**:
    ```bash
    kubectl exec -n apparmor pods/deny-write-pod -- touch /test.txt
    ```{{copy}}

</details>
