#!/bin/sh
set -e

echo "find . -name 'pkg' -prune -o -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | xargs -n 1 jsonnet-lint -J vendor" | docker run -i -v "$(pwd):/app/MaC" jsonnet-dev-tool /bin/sh