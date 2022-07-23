#Builder image to download binaries
FROM golang:1.18-alpine3.15 AS builder

#Download git, jsonnet and jsonnet-bundler. Initialise jsonnet-bundler and install grafonnet and grafana-builder.
RUN  apk add --no-cache git=2.34.4-r0 && \
 go install github.com/google/go-jsonnet/cmd/jsonnet@v0.18.0 && \
 go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1


FROM alpine:3.15
RUN apk --no-cache add git bash

COPY --from=builder /go/bin/* /usr/local/bin/
RUN jb init && \
     jb install https://github.com/grafana/grafonnet-lib/grafonnet && \
     jb install https://github.com/grafana/jsonnet-libs/grafana-builder

COPY monitoring-config /monitoring-config
COPY run-mixin.sh /
RUN chmod a+x /usr/local/bin/jb /usr/local/bin/jsonnet /run-mixin.sh

ENTRYPOINT ["/run-mixin.sh"]