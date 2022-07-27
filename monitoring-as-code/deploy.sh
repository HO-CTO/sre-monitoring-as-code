#!/bin/sh
# Tactical script to deploy monitoring framework

# Clear down MaC output directory
rm -rf "$PWD"/output/*/

# Executes docker image to create rules and dashboards for monitoring and summary mixin files
docker run --mount type=bind,source="$PWD"/output,target=/output --mount type=bind,source="$PWD"/mixin-defs,target=/input -it sre-monitoring-as-code:latest -m monitoring -rd -i input -o output

docker run --mount type=bind,source="$PWD"/output,target=/output --mount type=bind,source="$PWD"/mixin-defs,target=/input -it sre-monitoring-as-code:latest -m summary -d -i input -o output
