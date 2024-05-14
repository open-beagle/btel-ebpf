#!/usr/bin/env bash

set -ex

rm -rf $CARGO_HOME/config.toml
cp $PWD/.beagle/config.toml $CARGO_HOME/config.toml

rm -rf /usr/local/cargo/git
mkdir -p $PWD/agent/target/git
ln -s $PWD/agent/target/git /usr/local/cargo/git

rm -rf /usr/local/cargo/registry
mkdir -p $PWD/agent/target/registry
ln -s $PWD/agent/target/registry /usr/local/cargo/registry

cd agent

AGENT_ROOT=$PWD
AGENT_ARCH="${AGENT_ARCH:-amd64}"
AGENT_BUILD_ARCH=$(echo ${AGENT_ARCH} | sed 's|amd64|x86_64|' | sed 's|arm64|aarch64|')

# git config --global http.proxy "socks5://www.ali.wodcloud.com:1283"

cargo build --release --target="${AGENT_BUILD_ARCH}-unknown-linux-musl"

cargo build --release --bin deepflow-agent-ctl --target="${AGENT_BUILD_ARCH}-unknown-linux-musl"

mv ${AGENT_ROOT}/src/ebpf/deepflow-ebpfctl ${AGENT_ROOT}/target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release/

mkdir -p ${AGENT_ROOT}/target/downloads
curl \
  -x socks5://www.ali.wodcloud.com:1283 \
  -sL https://github.com/gojue/ecapture/releases/download/v0.8.0/ecapture-v0.8.0-linux-${AGENT_ARCH}.tar.gz > \
  ${AGENT_ROOT}/target/downloads/ecapture-v0.8.0-linux-${AGENT_ARCH}.tar.gz
rm -rf ${AGENT_ROOT}/target/ecapture-v0.8.0-linux-${AGENT_ARCH}
tar -xf ${AGENT_ROOT}/target/downloads/ecapture-v0.8.0-linux-${AGENT_ARCH}.tar.gz -C ${AGENT_ROOT}/target
mv ${AGENT_ROOT}/target/ecapture-v0.8.0-linux-${AGENT_ARCH}/ecapture ${AGENT_ROOT}/target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release/
rm -rf ${AGENT_ROOT}/target/downloads ${AGENT_ROOT}/target/ecapture-v0.8.0-linux-${AGENT_ARCH}

ls -alh ${AGENT_ROOT}/target/${AGENT_BUILD_ARCH}-unknown-linux-musl/release
