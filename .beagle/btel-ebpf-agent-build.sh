#!/usr/bin/env bash

set -ex

cd agent

AGENT_ROOT=$PWD

# 安装基本工具
apt update
apt install -y clang-11 gcc llvm-11 llvm-11-dev libpcap0.8-dev libelf-dev make

# 添加软链接
ln -s /usr/bin/clang-11 /usr/bin/clang
ln -s /usr/bin/llvm-objdump-11 /usr/bin/llvm-objdump
ln -s /usr/bin/llc-11 /usr/bin/llc
ln -s /usr/bin/llvm-strip-11 /usr/bin/llvm-strip

mkdir -p .rpmbuild/downloads

# bcc
apt install -y arping bison clang-format cmake dh-python \
  dpkg-dev pkg-kde-tools ethtool flex inetutils-ping iperf \
  libbpf-dev libclang-dev libclang-cpp-dev libedit-dev libelf-dev \
  libfl-dev libzip-dev linux-libc-dev llvm-dev libluajit-5.1-dev \
  luajit python3-netaddr python3-pyroute2 python3-setuptools python3

git config --global http.proxy 'socks5://www.ali.wodcloud.com:1283'
curl \
  -x socks5://www.ali.wodcloud.com:1283 \
  -sL https://github.com/iovisor/bcc/releases/download/v0.25.0/bcc-src-with-submodule.tar.gz > \
  $AGENT_ROOT/.rpmbuild/downloads/bcc-src-with-submodule-v0.25.0.tar.gz
tar -xf $AGENT_ROOT/.rpmbuild/downloads/bcc-src-with-submodule-v0.25.0.tar.gz -C $AGENT_ROOT/.rpmbuild
mv $AGENT_ROOT/.rpmbuild/bcc $AGENT_ROOT/.rpmbuild/bcc-v0.25.0
cd $AGENT_ROOT/.rpmbuild/bcc-v0.25.0
cmake .
make && make install

# bddisasm
git clone https://github.com/bitdefender/bddisasm $AGENT_ROOT/.rpmbuild/bddisasm
cd $AGENT_ROOT/.rpmbuild/bddisasm
make && make install && make clean
ln -s /usr/local/lib/libbddisasm.a /usr/lib/libbddisasm.a

# zlib
curl \
  -x socks5://www.ali.wodcloud.com:1283 \
  -sL https://www.zlib.net/fossils/zlib-1.2.12.tar.gz > \
  $AGENT_ROOT/.rpmbuild/downloads/zlib-1.2.12.tar.gz
tar -xf $AGENT_ROOT/.rpmbuild/downloads/zlib-1.2.12.tar.gz -C $AGENT_ROOT/.rpmbuild
cd $AGENT_ROOT/.rpmbuild/zlib-1.2.12
./configure --prefix=/usr
make && make install && make clean

# libdwarf
curl \
  -x socks5://www.ali.wodcloud.com:1283 \
  -sL https://github.com/davea42/libdwarf-code/releases/download/v0.4.1/libdwarf-0.4.1.tar.xz > \
  $AGENT_ROOT/.rpmbuild/downloads/libdwarf-0.4.1.tar.xz
tar -xf $AGENT_ROOT/.rpmbuild/downloads/libdwarf-0.4.1.tar.xz -C $AGENT_ROOT/.rpmbuild
cd $AGENT_ROOT/.rpmbuild/libdwarf-0.4.1
CFLAGS="-fpic" ./configure --prefix=/usr --disable-dependency-tracking
make && make install && make clean

# libelf
curl \
  -x socks5://www.ali.wodcloud.com:1283 \
  -sL https://sourceware.org/elfutils/ftp/0.187/elfutils-0.187.tar.bz2 > \
  $AGENT_ROOT/.rpmbuild/downloads/elfutils-0.187.tar.bz2
tar -xf $AGENT_ROOT/.rpmbuild/downloads/elfutils-0.187.tar.bz2 -C $AGENT_ROOT/.rpmbuild
cd $AGENT_ROOT/.rpmbuild/elfutils-0.187
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
make
make install
make clean

# libGoReSym
GO_ARCH="${GO_ARCH:-amd64}"
curl \
  -x socks5://www.ali.wodcloud.com:1283 \
  -sL https://dl.google.com/go/go1.18.10.linux-$GO_ARCH.tar.gz > \
  $AGENT_ROOT/.rpmbuild/downloads/go1.18.10.linux-$GO_ARCH.tar.gz
tar -C /usr/local -xzf $AGENT_ROOT/.rpmbuild/downloads/go1.18.10.linux-$GO_ARCH.tar.gz
export GOROOT=/usr/local/go
export GOPATH=/go
export GOPROXY=https://goproxy.cn

mkdir -p /usr/lib64
curl \
  -x socks5://www.ali.wodcloud.com:1283 \
  -sL https://github.com/deepflowio/libGoReSym/archive/refs/tags/v0.0.1-2.tar.gz > \
  $AGENT_ROOT/.rpmbuild/downloads/libGoReSym-v0.0.1-2.tar.gz
tar -xzf $AGENT_ROOT/.rpmbuild/downloads/libGoReSym-v0.0.1-2.tar.gz -C $AGENT_ROOT/.rpmbuild
cd $AGENT_ROOT/.rpmbuild/libGoReSym-0.0.1-2
make && make install && make clean

apt install -y protobuf-compiler bc

mv /etc/apt/sources.list /etc/apt/sources.list.old
cat >/etc/apt/sources.list <<-EOF
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ sid main contrib non-free
deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ sid main contrib non-free
EOF

apt update && apt install -y openjdk-8-jdk-headless

cd $AGENT_ROOT
cargo build --release