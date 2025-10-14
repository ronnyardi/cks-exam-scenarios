# Step 1: Patch Vulnerable Workload with Trivy and Generate SBOM

A deployment named `morc-api` is running in the `team-supply` namespace. However, it is reportedly has been vulnerable. Using Trivy, scan the image that is used by the deployment and verify if the container contains vulnerable dependencies. Review the SBOM and identify any known vulnerable packages (e.g., outdated OpenSSL, curl, etc).

As DevSecOps engineer, you're tasked to patch the underlying image of the `morc-api`. The source manifest is located in the directory `/opt/morc-api`. Fix the base image in the Dockerfile to use the latest version, ensure it has no vulnerabilities by scanning it first with using Trivy.

After verified, you will need to rebuild a new docker image and load it into containerd in the current cluster node with commands below e.g.,:
```bash
docker build -t morc-api:<version-patched> .
docker save morc-api:<version-patched> -o /opt/morc-api/morc-api_<version-patched>.tar
ctr -n k8s.io images import /opt/morc-api/morc-api_<version-patched>.tar
```

Then edit the deployment manifest to use the newly morc-api image with the new tag you've choosen. Ensure that the deployment is running correctly. Verify the new image by using Trivy scanner and ensure it has 0 vulnerabilities. Lastly, export the SBOM document as CycloneDX into `/tmp/morc-api-patched.json`

Hint:
```
trivy image morc-api:<version-patched> --format cyclonedx --output /tmp/morc-api-patched.json
```

<details>
  <summary>Solution</summary>

* Scan the image using Trivy:
  ```bash
  $ kubectl describe deployment morc-api -n team-supply | grep -i image
      Image:         morc-api:0.1-5

  $ trivy image morc-api:0.1-5
  2025-10-14T08:26:24Z    INFO    [vulndb] Need to update DB
  2025-10-14T08:26:24Z    INFO    [vulndb] Downloading vulnerability DB...
  2025-10-14T08:26:24Z    INFO    [vulndb] Downloading artifact...        repo="mirror.gcr.io/aquasec/trivy-db:2"
  72.61 MiB / 72.61 MiB [-------------------------------------------------------------->] 100.00% 7.60 MiB p/s ETA

  Report Summary

  ┌────────────────────────────────┬────────┬─────────────────┬─────────┐
  │             Target             │  Type  │ Vulnerabilities │ Secrets │
  ├────────────────────────────────┼────────┼─────────────────┼─────────┤
  │ morc-api:0.1-5 (alpine 3.22.1) │ alpine │       18        │    -    │
  └────────────────────────────────┴────────┴─────────────────┴─────────┘
  Legend:
  - '-': Not scanned
  - '0': Clean (no security findings detected)


  morc-api:0.1-5 (alpine 3.22.1)

  Total: 18 (UNKNOWN: 0, LOW: 5, MEDIUM: 9, HIGH: 2, CRITICAL: 2)

  ┌────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬──────────────────────────────────────────────────────────────┐
  │  Library   │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                            Title                             │
  ├────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
  │ curl       │ CVE-2025-10148 │ MEDIUM   │ fixed  │ 8.14.1-r1         │ 8.14.1-r2     │ curl: predictable WebSocket mask                             │
  │            │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2025-10148                   │
  │            ├────────────────┤          │        │                   │               ├──────────────────────────────────────────────────────────────┤
  │            │ CVE-2025-9086  │          │        │                   │               │ curl: libcurl: Curl out of bounds read for cookie path       │
  │            │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2025-9086                    │
  ├────────────┼────────────────┤          │        ├───────────────────┼───────────────┼──────────────────────────────────────────────────────────────┤
  # trimmed
  ```
  We can understand that morc-api is built based on the alpine image and it has some vulnerabilities.

* Now we know that morc-api:0.1-5 contains several vulnerabilites. The instruction is to patch the source of the morc-api. Go to /opt/morc-api directory and follow the below:

  ```bash
  $ cd /opt/morc-api
  $ ls
  Dockerfile  index.html  morc-api_0.1-5.tar  nginx.conf

  $ cat Dockerfile 
  FROM nginx:1.29.0-alpine  # PATCH THIS: Contains vulnerable dependencies

  RUN rm /etc/nginx/conf.d/default.conf
  COPY nginx.conf /etc/nginx/conf.d/default.conf
  COPY index.html /usr/share/nginx/html/index.html

  EXPOSE 8989
  ```
* Use the latest version of alpine, nginx:alpine, scan it first!
  ```bash
  $ trivy image nginx:alpine
  2025-10-14T08:44:53Z    INFO    [vuln] Vulnerability scanning is enabled
  2025-10-14T08:44:53Z    INFO    [secret] Secret scanning is enabled
  2025-10-14T08:44:53Z    INFO    [secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
  2025-10-14T08:44:53Z    INFO    [secret] Please see https://trivy.dev/v0.67/docs/scanner/secret#recommendation for faster secret detection
  2025-10-14T08:45:00Z    INFO    Detected OS     family="alpine" version="3.22.2"
  2025-10-14T08:45:00Z    INFO    [alpine] Detecting vulnerabilities...   os_version="3.22" repository="3.22" pkg_num=70
  2025-10-14T08:45:00Z    INFO    Number of language-specific files       num=0

  Report Summary

  ┌──────────────────────────────┬────────┬─────────────────┬─────────┐
  │            Target            │  Type  │ Vulnerabilities │ Secrets │
  ├──────────────────────────────┼────────┼─────────────────┼─────────┤
  │ nginx:alpine (alpine 3.22.2) │ alpine │        0        │    -    │
  └──────────────────────────────┴────────┴─────────────────┴─────────┘
  Legend:
  - '-': Not scanned
  - '0': Clean (no security findings detected)
  ```

* Patch and rebuild the image
  ```bash
  $ cd /opt/morc-api
  $ vim Dockerfile
  FROM nginx:1.29.0-alpine  # REMOVE THIS
  FROM nginx:alpine         # ADD THIS

  $ docker build -t morc-api:0.1-5_patched .
  Step 1/5 : FROM nginx:alpine
  alpine: Pulling from library/nginx
  2d35ebdb57d9: Pull complete 
  f80aba050ead: Pull complete 
  621a51978ed7: Pull complete 
  03e63548f209: Pull complete 
  83ce83cd9960: Pull complete 
  e2d0ea5d3690: Pull complete 
  7fb80c2f28bc: Pull complete 
  76c9bcaa4163: Pull complete 
  Digest: sha256:61e01287e546aac28a3f56839c136b31f590273f3b41187a36f46f6a03bbfe22
  Status: Downloaded newer image for nginx:alpine
  ---> 5e7abcdd2021
  Step 2/5 : RUN rm /etc/nginx/conf.d/default.conf
  ---> Running in 0f751e872bbe
  ---> Removed intermediate container 0f751e872bbe
  ---> f18f30f1449d
  Step 3/5 : COPY nginx.conf /etc/nginx/conf.d/default.conf
  ---> 65871ecfd54a
  Step 4/5 : COPY index.html /usr/share/nginx/html/index.html
  ---> 940241e0bb68
  Step 5/5 : EXPOSE 8989
  ---> Running in 3f19555464e5
  ---> Removed intermediate container 3f19555464e5
  ---> ca99f2af994f
  Successfully built ca99f2af994f
  Successfully tagged morc-api:0.1-5_patched

  $ docker save morc-api:0.1-5_patched -o /opt/morc-api/morc-api_0.1-5_patched.tar
  $ ctr -n k8s.io images import morc-api_0.1-5_patched.tar
  unpacking docker.io/library/morc-api:0.1-5_patched (sha256:3f8eaced5c379a955f61f00c5177dffbde3b3a4effdb9e3662886209f8ede2f5)...done

  $ crictl images
  docker.io/library/morc-api                 0.1-5               2e6fa8f233683       53.9MB
  docker.io/library/morc-api                 0.1-5_patched       ca99f2af994ff       54.2MB  # New image listed
  
  ```

* Edit the deployment manifest of `morc-api`:
  ```bash
  $ kubectl edit -n team-supply deployment morc-api
  ...
    spec:
      containers:
      - image: morc-api:0.1-5_patched    # UPDATE THIS
  ...
  deployment.apps/morc-api edited

  $ kubectl get pod -n team-supply 
  NAME                        READY   STATUS    RESTARTS   AGE
  morc-api-6bff6b8654-9jjxz   1/1     Running   0          15s
  ```
* Verify the new image using Trivy:
  ```bash
  $ trivy image morc-api:0.1-5_patched
  2025-10-14T08:57:59Z    INFO    [vuln] Vulnerability scanning is enabled
  2025-10-14T08:57:59Z    INFO    [secret] Secret scanning is enabled
  2025-10-14T08:57:59Z    INFO    [secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
  2025-10-14T08:57:59Z    INFO    [secret] Please see https://trivy.dev/v0.67/docs/scanner/secret#recommendation for faster secret detection
  2025-10-14T08:58:00Z    INFO    Detected OS     family="alpine" version="3.22.2"
  2025-10-14T08:58:00Z    INFO    [alpine] Detecting vulnerabilities...   os_version="3.22" repository="3.22" pkg_num=70
  2025-10-14T08:58:00Z    INFO    Number of language-specific files       num=0

  Report Summary

  ┌────────────────────────────────────────┬────────┬─────────────────┬─────────┐
  │                 Target                 │  Type  │ Vulnerabilities │ Secrets │
  ├────────────────────────────────────────┼────────┼─────────────────┼─────────┤
  │ morc-api:0.1-5_patched (alpine 3.22.2) │ alpine │        0        │    -    │
  └────────────────────────────────────────┴────────┴─────────────────┴─────────┘
  Legend:
  - '-': Not scanned
  - '0': Clean (no security findings detected)
  ```
* Generate the SBOM document with format CycloneDX:
  ```bash
  $ trivy image morc-api:0.1-5_patched --format cyclonedx --output /tmp/morc-api-patched.json

  $ cat /tmp/morc-api-patched.json
  ...
        {
        "ref": "pkg:apk/alpine/zlib@1.3.1-r2?arch=x86_64&distro=3.22.2",
        "dependsOn": [
          "pkg:apk/alpine/musl@1.2.5-r10?arch=x86_64&distro=3.22.2"
        ]
      },
      {
        "ref": "pkg:apk/alpine/zstd-libs@1.5.7-r0?arch=x86_64&distro=3.22.2",
        "dependsOn": [
          "pkg:apk/alpine/musl@1.2.5-r10?arch=x86_64&distro=3.22.2"
        ]
      }
    ],
    "vulnerabilities": []       # HAS ZERO VULNERABILITIES
  }
  ...
  ```

</details>