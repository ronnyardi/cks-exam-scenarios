# Step 1: Generate Certificate Pairs for a User

Generate a certificate pair for a user to authenticate with the Kubernetes cluster. The user name should be `jack` and assign him to the group `security`. Make the user to be included in the Kubernetes config by adding `jack` to the cluster context. Inspect the existing context to get the cluster name.

Tips: don't forget to approve the client certificate before adding to clutster context.

<details>
  <summary>Solution</summary>
  
* Generate certificate pair for `jack` using `openssl`:
```
openssl genrsa -out jack.key 2048
openssl req -new -key jack.key -out jack.csr -subj "/CN=jack/O=observer"
```

* Create certificate signing request object in kubernetes using the following manifest:
```
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: <user>
spec:
  request: <base64-encoded-csr-file>
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400
  usages:
  - client auth
EOF
```

* Approve the CSR: `kubectl certificate approve jack`

* Retrieve the approved CSR to get the client certificate: `kubectl get csr jack -o jsonpath='{.status.certificate}' | base64 -d > jack.crt`

* Add user `jack` to the cluster context: 
```
kubectl config set-credentials jack --client-certificate=<client-cert> --client-key=<client-key> --embed-certs=true
kubectl config set-context jack --cluster=<cluster-name> --user=jack
```
  
</details>
