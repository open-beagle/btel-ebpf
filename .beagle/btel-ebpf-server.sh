#!/usr/bin/env bash

set -ex

cd server

apk update
apk add protoc python3 py3-ujson make git

go install github.com/gogo/protobuf/protoc-gen-gofast@v1.3.2 
go install github.com/gogo/protobuf/protoc-gen-gogo@v1.3.2 
go install github.com/benbjohnson/tmpl@v1.1.0

mkdir -p $GOPATH/src/github.com/gogo
ln -s "$GOPATH/pkg/mod/github.com/gogo/protobuf@v1.3.2" "$GOPATH/src/github.com/gogo/protobuf" 

export GOARCH=amd64
make all
mv ./bin/deepflow-server ./bin/deepflow-server-$GOARCH

export GOARCH=arm64
make all
mv ./bin/deepflow-server ./bin/deepflow-server-$GOARCH
