FROM golang:1.19.0-alpine3.16 AS builder

WORKDIR /go/app

RUN apk add --no-cache git

RUN go install github.com/google/go-jsonnet/cmd/jsonnet@v0.17.0
RUN go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1
RUN go install github.com/google/go-jsonnet/cmd/jsonnetfmt@v0.17.0
RUN go install github.com/google/go-jsonnet/cmd/jsonnet-lint@v0.18.0

RUN PATH=$PATH:$GOPATH/bin

RUN jb init
RUN jb install https://github.com/grafana/grafonnet-lib/grafonnet
RUN jb install https://github.com/grafana/jsonnet-libs/grafana-builder

FROM alpine:3.16.2 AS runner

COPY --from=builder /go/bin/jsonnetfmt /usr/local/bin
COPY --from=builder /go/bin/jsonnet-lint /usr/local/bin

WORKDIR /app

COPY --from=builder /go/app/vendor /app/vendor