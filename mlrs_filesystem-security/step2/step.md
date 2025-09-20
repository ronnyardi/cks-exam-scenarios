# Step 2: Configure Writable Paths

You should see a permission error indicating that the root filesystem is read-only. Therefore, the folder `/tmp` should be writable. 

To make this, create a `emptyDir` volume then mount it to the pod with the respective directory as mentioned above. Verify that the specified writable path is functioning correctly while the rest of the filesystem remains read-only.


<details>
  <summary>Solution</summary>

* Edit the pod manifest to add volume and volumeMounts:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  namespace: secure-fs
spec:
  containers:
  ...
    volumeMounts:                   # add this
    - mountPath: /tmp               # add this
      name: volume                  # add this
      readOnly: false               # add this
  volumes:                          # add this
  - name: volume                    # add this
    emptyDir: {}                    # add this
```

* Inspect the logs of the `secure-app` Pod to verify that it is writing to the writable path: `kubectl logs -f secure-app -n secure-fs`

* Check if the root filesystem is read-only by attempting to write to a read-only path: `kubectl exec -n secure-fs secure-app -- touch hello-world`
</details>
