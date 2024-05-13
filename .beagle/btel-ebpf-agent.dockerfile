ARG BASE

FROM $BASE

ARG AUTHOR
ARG VERSION

LABEL maintainer=$AUTHOR version=$VERSION

ARG AGENT_BUILD_ARCH

COPY ./agent/target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release/deepflow-agent /bin/
COPY ./agent/target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release/deepflow-agent-ctl /bin/

COPY ./agent/target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release/deepflow-ebpfctl /bin/

COPY ./agent/docker/require/${AGENT_BUILD_ARCH}/libpcap.so.1 /usr/lib/${AGENT_BUILD_ARCH}-linux-gnu/
COPY ./agent/target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release/ecapture /usr/bin/

RUN chmod 600 /etc/passwd && \
  echo "deepflow:x:1000:1000::/home/deepflow:/bin/bash" >> /etc/passwd && \
  echo "root:root" | chpasswd && \
  chmod 000 /etc/passwd && \
  mkdir -p /lib64 && \
  apt update && \
  apt install -y iproute2 bridge-utils

CMD ["/bin/deepflow-agent", "-f", "/etc/deepflow-agent/deepflow-agent.yaml"]