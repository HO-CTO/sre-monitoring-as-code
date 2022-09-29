#!/bin/sh
set -e

echo "jsonnetfmt -v && find . -name 'pkg' -prune -o -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | xargs -n 1 jsonnetfmt -n 2 --max-blank-lines 2 --string-style s --comment-style s --no-sort-imports -i" | docker run -i -v "$(pwd):/app/MaC" ghcr.io/ho-cto/sre-fmt-lint:latest /bin/sh
