# Step 2: Update Pod Image with Digest

Update the image of all pods in the `digest` namespace to use the image digest retrieved from Docker Hub that you've collected before. 

<details>
  <summary>Solution</summary>
  
Patch the image of the pods: 
  1. `kubectl patch pod batlle-pie -n digest --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"nginx@sha256:208b70eefac13ee9be00e486f79c695b15cef861c680527171a27d253d834be9"}]'`
  2. `kubectl patch pod frog-prizzies -n digest --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"alpine@sha256:ef813b2faa3dd1a37f9ef6ca98347b72cd0f55e4ab29fb90946f1b853bf032d9"}]'`
  3. `kubectl patch pod salamander-pipe -n digest --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"busybox@sha256:5be7104a4306abe768359a5379e6050ef69a29e9a5f99fcf7f46d5f7e9ba29a2"}]'`
</details>
