# Settings
set ignore-comments := true

# Builds the container image
[group('Development')]
build:
  #!/usr/bin/env bash

  set -euox pipefail

  RELEASE=2.4.0
  if [ -f "VERSION" ]; then
    RELEASE=$(cat VERSION)
  fi

  CUDA_TAG=12.8.1-cudnn-runtime-ubi9
  if [ -f "CUDA" ]; then
    CUDA_TAG=$(cat CUDA)
  fi

  podman build -t ghcr.io/cubt85iz/wyoming-faster-whisper-gpu:${RELEASE} \
    --build-arg=RELEASE=${RELEASE} --build-arg=CUDA_TAG=${CUDA_TAG} .


# Runs the container image with the supplied arguments.
[group('Development')]
run *args:
  #!/usr/bin/env bash

  set -euox pipefail

  podman run --rm -it ghcr.io/cubt85iz/wyoming-faster-whisper-gpu:2.4.0 {{ args }}
