#!/bin/sh
# Tactical script to deploy monitoring framework

# Global variables
RULES_DIRECTORY="$PWD"/output/prometheus-rules/
DASHBOARD_DIRECTORY="$PWD"/output/grafana-dashboards/
LOCAL_PATH="$PWD"/../local/

# Clear down MaC output directory
rm -rf "$PWD"/output/*/

#Executes docker image to create rules and dashboards for monitoring and summary mixin files
#docker run --mount type=bind,source="$PWD"/output,target=/output --mount type=bind,source="$PWD"/mixin-defs,target=/input -it sre-monitoring-as-code:latest -m monitoring -rd -i input -o output
#
#docker run --mount type=bind,source="$PWD"/output,target=/output --mount type=bind,source="$PWD"/mixin-defs,target=/input -it sre-monitoring-as-code:latest -m summary -d -i input -o output

docker run --mount type=bind,source="$PWD"/output,target=/output --mount type=bind,source="$PWD"/mixin-defs,target=/input -it sre-monitoring-as-code:latest -m ledsproperty -rd -i input -o output


# Copy Prometheus rules to monitoring local
cp -a "$RULES_DIRECTORY"/. "$LOCAL_PATH"/prometheus/rule_configs

# Copy Grafana dashboards to monitoring local
for dashboard_file_path in "$DASHBOARD_DIRECTORY"/*
do
  dashboard_file="${dashboard_file_path##*/}"
  mixin="${dashboard_file%%\-*}"

  mkdir -p "$LOCAL_PATH"/grafana/provisioning/dashboards/"$mixin"
  cp "$DASHBOARD_DIRECTORY"/"$dashboard_file" "$LOCAL_PATH"/grafana/provisioning/dashboards/"$mixin"/"$dashboard_file"
done
