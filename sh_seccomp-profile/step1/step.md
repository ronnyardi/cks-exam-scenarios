# Step 1: Create a Seccomp Profile

Create a seccomp profile that audit all activities from a container. Apply the profile to the worker node and save as `seccomp-audit.json` under the seccomp profile directory `/var/lib/kubelet/seccomp`

Here is the seccomp profile. SSH to the respective node.

```
{
    "defaultAction": "SCMP_ACT_LOG"
}
```{{copy}}



<details>
  <summary>Solution</summary>

* SSH to the worker node: `ssh node01`

* Copy the profile as `seccomp-audit.json` to the Kubernetes worker node.
```sh
sudo mkdir -p /var/lib/kubelet/seccomp
sudo cp seccomp-audit.json /var/lib/kubelet/seccomp/
```

</details>
