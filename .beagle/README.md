# Btel-ebpf

## git

<https://github.com/deepflowio/deepflow>

```bash
git remote add upstream git@github.com:deepflowio/deepflow.git

git fetch upstream

git merge v6.5.5
```

## build

```bash
# build-server
docker run -it --rm \
-v $PWD/:/go/src/github.com/deepflowio/deepflow \
-w /go/src/github.com/deepflowio/deepflow \
registry.cn-qingdao.aliyuncs.com/wod/golang:1.20-alpine \
bash .beagle/btel-ebpf-server.sh

# build-agent
docker run -it --rm \
-v $PWD/:/go/src/github.com/deepflowio/deepflow \
-w /go/src/github.com/deepflowio/deepflow \
-e AGENT_ARCH="amd64" \
registry.cn-qingdao.aliyuncs.com/wod/btel-ebpf-agent:build-1.30-amd64 \
bash .beagle/btel-ebpf-agent.sh

docker run -it --rm \
-v $PWD/:/go/src/github.com/deepflowio/deepflow \
-w /go/src/github.com/deepflowio/deepflow \
-e AGENT_ARCH="arm64" \
registry.cn-qingdao.aliyuncs.com/wod/btel-ebpf-agent:build-1.30-arm64 \
bash .beagle/btel-ebpf-agent.sh
```

## images

```bash
docker pull ghcr.io/deepflowio/rust-build:1.30 && \
docker tag ghcr.io/deepflowio/rust-build:1.30 registry.cn-qingdao.aliyuncs.com/wod/btel-ebpf-agent:build-1.30-amd64 && \
docker push registry.cn-qingdao.aliyuncs.com/wod/btel-ebpf-agent:build-1.30-amd64

docker pull ghcr.io/deepflowio/rust-build:1.30-arm64 && \
docker tag ghcr.io/deepflowio/rust-build:1.30-arm64 registry.cn-qingdao.aliyuncs.com/wod/btel-ebpf-agent:build-1.30-arm64 && \
docker push registry.cn-qingdao.aliyuncs.com/wod/btel-ebpf-agent:build-1.30-arm64
```

## cache

```bash
# 构建缓存-->推送缓存至服务器
docker run --rm \
  -e PLUGIN_REBUILD=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="btel-ebpf" \
  -e DRONE_COMMIT_BRANCH="v6.5.4" \
  -e PLUGIN_MOUNT="./.git,./server/vendor,./message/opentelemetry,./agent/src/ebpf/libs/jattach,./agent/target" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0

# 读取缓存-->将缓存从服务器拉取到本地
docker run --rm \
  -e PLUGIN_RESTORE=true \
  -e PLUGIN_ENDPOINT=$PLUGIN_ENDPOINT \
  -e PLUGIN_ACCESS_KEY=$PLUGIN_ACCESS_KEY \
  -e PLUGIN_SECRET_KEY=$PLUGIN_SECRET_KEY \
  -e DRONE_REPO_OWNER="open-beagle" \
  -e DRONE_REPO_NAME="btel-ebpf" \
  -e DRONE_COMMIT_BRANCH="v6.5.4" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  registry.cn-qingdao.aliyuncs.com/wod/devops-s3-cache:1.0
```
