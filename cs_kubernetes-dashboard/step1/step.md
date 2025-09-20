# Step 1: Harden the Kubernetes Dashboard

There is a deployed Kubernetes Dashboard in the namespace `kubernetes-dashboard` that still use these configurations:

* Allow insecure access by skipping the authentication process

* Allow access from external with dedicated port

To harden it, you need to set the Kubernetes Dashboard deployment to use these:

* Enable HTTPS by enforcing the use of certificate. This will need a directory to store the certificate pair

* Allow access only from internal, so you don't need a dedicated port configuration anymore

* Don't skip the authentication process 


<details>
  <summary>Solution</summary>

* Get the current Kubernetes Dashboard deployment: `kubectl get deployment -n kubernetes-dashbaord kubernetes-dashboard -o yaml`

* Edit the Kubernetes Dashboard deployment container template arguments:
```
# Before
  - --namespace=kubernetes-dashboard
  - --insecure-port=9000        # remove
  - --enable-skip-login=true    # remove
  - --enable-insecure-login     # remove

# After
  - --namespace=kubernetes-dashboard
  - --auto-generate-certificates    # add
```
* Verify that the deployment is running well: `kubectl get deployment -n kubernetes-dashboard kubernetes-dashboard`

* Learn more about [Kubernetes Arguments Documentation](https://github.com/kubernetes/dashboard/blob/master/docs/common/arguments.md)

</details>
   

