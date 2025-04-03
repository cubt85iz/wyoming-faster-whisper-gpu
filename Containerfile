ARG CUDA_TAG=${CUDA_TAG:-12.8.1-cudnn-runtime-ubi9}
ARG RELEASE=${RELEASE:-2.4.0}

FROM docker.io/nvidia/cuda:${CUDA_TAG} AS build

ARG RELEASE

# Install prerequisites
RUN dnf -y install git python3-pip

# Create build environment
WORKDIR /usr/src
RUN git clone https://github.com/rhasspy/wyoming-faster-whisper.git && \
  cd wyoming-faster-whisper && \
  git checkout tags/v${RELEASE} && \
  script/setup && \
  script/package

FROM docker.io/nvidia/cuda:${CUDA_TAG}

ARG RELEASE

WORKDIR /

# Copy package from build.
COPY --from=build /usr/src/wyoming-faster-whisper/dist/wyoming_faster_whisper-${RELEASE}-py3-none-any.whl /

# Install prerequisites
RUN dnf -y install python3-pip && \
  pip install --no-cache-dir /wyoming_faster_whisper-${RELEASE}-py3-none-any.whl

ENTRYPOINT [ "/usr/bin/python3", "-m", "wyoming_faster_whisper" ]