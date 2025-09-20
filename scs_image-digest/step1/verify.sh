#!/bin/bash

# Define the images to check
images=("alpine:3.17.9" "nginx:1.27.0-alpine3.19" "busybox:1.35.0")
digests=()

# Pull the images and get their digests
for image in "${images[@]}"; do
  docker pull $image
  digest=$(docker inspect $image --format='{{index .RepoDigests 0}}')
  echo "Pulled digest for $image: $digest"
  digests+=($digest)
done

# Read the digests from the answer file
answer_file="/opt/digest/answer"

# Verify each digest
for digest in "${digests[@]}"; do
  if ! grep -q "$digest" "$answer_file"; then
    echo "Digest $digest not found in $answer_file"
    exit 1
  fi
done

echo "All digests match."
exit 0
