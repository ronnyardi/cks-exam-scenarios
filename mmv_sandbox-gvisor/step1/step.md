# Step 1: Install gVisor and Configure runsc Runtime

Install [gVisor](https://gvisor.dev/docs/user_guide/install/) from the official website there. It is recommended to use install from `apt` repository. Find the container runtime that used from the existing session, whether it containerd or docker. Configure `containerd` if needed.

After successful installation, create Runtime Class named `gvisor` that use handler `runsc`. 

<details>
  <summary>Solution</summary>

* Install gVisor:
```sh
sudo apt-get update && \
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg
```

```sh
curl -fsSL https://gvisor.dev/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/gvisor-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gvisor-archive-keyring.gpg] https://storage.googleapis.com/gvisor/releases release main" | sudo tee /etc/apt/sources.list.d/gvisor.list > /dev/null
```

```sh
sudo apt-get update && sudo apt-get install -y runsc
```

* Configure Docker or Containerd to use runsc:

```sh
# Docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "runtimes": {
    "runsc": {
      "path": "runsc"
    }
  }
}
EOF
sudo systemctl restart docker
```


```sh
# Containerd
cat <<EOF | sudo tee /etc/containerd/config.toml
version = 2
[plugins."io.containerd.runtime.v1.linux"]
  shim_debug = true
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"
EOF
sudo systemctl restart containerd
```


* Create Runtime Class:
```yaml
cat <<EOF | kubectl apply -f -
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
EOF
```

</details>
