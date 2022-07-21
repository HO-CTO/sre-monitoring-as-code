#Builder image to download binaries
FROM golang:1.18-alpine3.15 AS builder

WORKDIR /jsonnet-generator

#Download git, jsonnet and jsonnet-bundler. Initialise jsonnet-bundler and install grafonnet and grafana-builder.
RUN  apk add --no-cache git=2.34.4-r0 && \
 go install github.com/google/go-jsonnet/cmd/jsonnet@v0.18.0 && \
 go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1 && \
 jb init && \
 jb install https://github.com/grafana/grafonnet-lib/grafonnet && \
 jb install https://github.com/grafana/jsonnet-libs/grafana-builder