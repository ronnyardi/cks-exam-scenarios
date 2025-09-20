# Step 1: Get Image Digest from Docker Hub

There are already 3 pods inside the `digest` namespace. Retrieve the SHA256 digest for all used image in those Pods from Docker Hub.

You may also verify it manually by checking through Docker Hub website [Docker Hub](https://hub.docker.com/). Save all of the image digest to `/opt/digest/answer` with format `<image>@<digest>`.

<details>
  <summary>Solution</summary>
  
  1. Pull the nginx image locally: `docker pull <image:version>`
  2. Get the image digest: `docker inspect <image:version> --format='{{index .RepoDigests 0}}'`
  3. Note down the image digest (e.g., `nginx@sha256:<digest>`).
  
</details>
