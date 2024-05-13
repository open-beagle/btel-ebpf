#!/usr/bin/env bash

set -ex

cp .beagle/config.toml /usr/local/cargo/config

cd agent

AGENT_ROOT=$PWD
AGENT_ARCH="${AGENT_ARCH:-amd64}"
AGENT_BUILD_ARCH=$(echo ${AGENT_ARCH}|sed 's|amd64|x86_64|'|sed 's|arm64|aarch64|')

git config --global http.proxy 'socks5://www.ali.wodcloud.com:1283'

cargo build --release --target=${AGENT_BUILD_ARCH}-unknown-linux-musl

cargo build --release --bin deepflow-agent-ctl --target=${AGENT_BUILD_ARCH}-unknown-linux-musl

mv ./src/ebpf/deepflow-ebpfctl ./target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release/

mkdir -p .rpmbuild/downloads
curl \
  -x socks5://www.ali.wodcloud.com:1283 \
  -sL https://github.com/gojue/ecapture/releases/download/v0.8.0/ecapture-v0.8.0-linux-${AGENT_ARCH}.tar.gz > \
  $AGENT_ROOT/.rpmbuild/downloads/ecapture-v0.8.0-linux-${AGENT_ARCH}.tar.gz
rm -rf $AGENT_ROOT/.rpmbuild/ecapture-v0.8.0-linux-${AGENT_ARCH}
tar -xf $AGENT_ROOT/.rpmbuild/downloads/ecapture-v0.8.0-linux-${AGENT_ARCH}.tar.gz -C $AGENT_ROOT/.rpmbuild
mv $AGENT_ROOT/.rpmbuild/ecapture-v0.8.0-linux-${AGENT_ARCH}/ecapture $AGENT_ROOT/target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release/

ls -alh target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release
