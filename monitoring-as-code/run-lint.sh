#!/bin/bash

jsonnet-lint -v
find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | xargs -n 1 jsonnet-lint -J vendor