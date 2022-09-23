#!/bin/bash

jsonnetfmt -v
find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | xargs -n 1 jsonnetfmt -n 2 --max-blank-lines 2 --string-style s --comment-style s --no-sort-imports -i