ARG CUDA_TAG=${CUDA_TAG:-11.8.0-cudnn8-runtime-ubuntu22.04}
ARG RELEASE=${RELEASE:-2.2.0}

FROM docker.io/nvidia/cuda:${CUDA_TAG} AS build

ARG RELEASE

# Install prerequisites
RUN apt-get update && apt-get -y install --no-install-recommends git python3 python3-pip python3-venv

# Create build environment & build wheel package.
WORKDIR /usr/src
RUN git clone https://github.com/rhasspy/wyoming-faster-whisper.git && \
  cd wyoming-faster-whisper && \
  git checkout tags/v${RELEASE} && \
  script/setup && \
  script/package

FROM docker.io/nvidia/cuda:${CUDA_TAG}

ARG RELEASE

WORKDIR /

# Copy wheel package from build stage.
COPY --from=build /usr/src/wyoming-faster-whisper/dist/wyoming_faster_whisper-${RELEASE}-py3-none-any.whl /

# Override LD_LIBRARY_PATH; otherwise whisper will fail to find them.
# Existing paths don't exist.
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

# Install wyoming_faster_whisper package.
RUN apt-get update && apt-get -y install --no-install-recommends python3 python3-pip && \
  pip install --no-cache-dir --break-system-packages /wyoming_faster_whisper-${RELEASE}-py3-none-any.whl && \
  rm -rf /var/lib/apt/lists/*

# Maintain syntax with existing official container (i.e., arguments passed as command)
ENTRYPOINT [ "/usr/bin/python3", "-m", "wyoming_faster_whisper", "--uri", "tcp://0.0.0.0:10300", "--data-dir", "/data", "--download-dir", "/data" ]