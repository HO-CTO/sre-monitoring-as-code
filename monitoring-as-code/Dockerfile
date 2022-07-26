# Builder image to download binaries
FROM golang:1.18-alpine3.15 AS builder

# Download git, jsonnet and jsonnet-bundler
RUN apk add --no-cache git=2.34.4-r0 curl jq wget && \
     go install github.com/google/go-jsonnet/cmd/jsonnet@v0.18.0 && \
     go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1

# Download promtool
RUN VERSION=$(curl -Ls https://api.github.com/repos/prometheus/prometheus/releases/latest | jq ".tag_name" | xargs | cut -c2-) &&  \
     wget -qO- "https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-$VERSION.linux-amd64.tar.gz" \
     | tar xvzf - "prometheus-$VERSION.linux-amd64"/promtool --strip-components=1 && cp promtool /go/bin/promtool

FROM alpine:3.15
RUN apk --no-cache add git bash

# Download grafonnet and grafana-builder
COPY --from=builder /go/bin/* /usr/local/bin/
RUN jb init && \
     jb install https://github.com/grafana/grafonnet-lib/grafonnet && \
     jb install https://github.com/grafana/jsonnet-libs/grafana-builder

COPY src /src
COPY mixin-defs /mixin-defs
COPY run-mixin.sh /
RUN chmod a+x /usr/local/bin/jb /usr/local/bin/jsonnet /run-mixin.sh

ENTRYPOINT ["/run-mixin.sh"]
