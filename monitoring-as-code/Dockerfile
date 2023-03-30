# Builder image to download binaries
FROM golang:1.20.1-alpine3.16 AS builder

# Download git, jsonnet and jsonnet-bundler
RUN apk add --no-cache git=2.36.5-r0 && \
  go install github.com/google/go-jsonnet/cmd/jsonnet@v0.17.0 && \
  go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1

WORKDIR /go/grafonnet
# Download grafonnet and grafana-builder
RUN jb init && \
  jb install https://github.com/grafana/grafonnet-lib/grafonnet && \
  jb install https://github.com/grafana/jsonnet-libs/grafana-builder

FROM alpine:3.17.3 AS runner

RUN apk -U upgrade

# Pass semver or PR from GitHub workflow
ARG MAC_VERSION
ENV MAC_VERSION $MAC_VERSION

COPY --from=builder /go/bin/* /usr/local/bin/
COPY --from=builder /go/grafonnet /
COPY src /src
COPY mixin-defs /mixin-defs
COPY run-mixin.sh /
RUN chmod a+x /usr/local/bin/jb /usr/local/bin/jsonnet /run-mixin.sh

ENTRYPOINT ["/run-mixin.sh"]
