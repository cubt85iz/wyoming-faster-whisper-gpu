# wyoming-faster-whisper-gpu

Container based on nVidia CUDA image that includes wyoming-faster-whisper python package.

## Usage

Example for quadlet shown below. Example uses drop-ins to specify variable values.

```systemd
# wyoming-faster-whisper-gpu.container

[Unit]
Description=Container for Whisper STT
Requires=network-online.target nss-lookup.target
After=network-online.target nss-lookup.target

[Container]
ContainerName=%p
Image=ghcr.io/cubt85iz/wyoming-faster-whisper-gpu:2.4.0
Exec=--model ${MODEL} --language ${LANG} --device cuda
Volume=${CONTAINER_PATH}/data:/data:Z
PublishPort=${PORT}:10300
AutoUpdate=registry

[Service]
ExecCondition=/usr/bin/test -d "${CONTAINER_PATH}/data"
Restart=on-failure

[Install]
WantedBy=default.target

```

```systemd
# wyoming-faster-whisper-gpu.container.d/00-vars.conf

[Service]
CONTAINER_PATH=/path/to/some/location
LANG=en
MODEL=distil-small.en
PORT=10300
```
