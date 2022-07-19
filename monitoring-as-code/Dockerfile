FROM golang:1.18-alpine3.15

WORKDIR /jsonnet-generator

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories && \
 apk add --no-cache git=2.34.4-r0 && \
 go install github.com/google/go-jsonnet/cmd/jsonnet@latest && \
 go install github.com/google/go-jsonnet/cmd/jsonnetfmt@latest && \
 go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest && \
 jb init && \
 jb install https://github.com/grafana/grafonnet-lib/grafonnet && \
 jb install https://github.com/grafana/jsonnet-libs/grafana-builder && \
 apk add --no-cache busybox=1.34.1-r5
