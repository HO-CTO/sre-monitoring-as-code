#!/bin/sh
# Tactical script to deploy monitoring framework

# Global variables
RULES_DIRECTORY="$PWD"/output/prometheus-rules/
DASHBOARD_DIRECTORY="$PWD"/output/grafana-dashboards/
TRANSFER_RULES="true"
TRANSFER_DASHBOARDS="true"
LOCAL_PATH="$PWD"/../local/

# Clear down MaC output directory
rm -rf "$PWD"/output/*/

# Set array of mixins which will be executed
set -- overview generic monitoring testing

# Loop through mixin array
for mixin in "$@";
  do

  if [ "$mixin" = "overview" ]; then
   #Executes docker image to create dashboards for overview mixin
   docker run --mount type=bind,source="$PWD"/output,target=/output --mount type=bind,source="$PWD"/mixin-defs,target=/input -it sre-monitoring-as-code:latest -m "$mixin" -d -i input -o output;
  else
   #Executes docker image to create dashboards and rules for all mixins other than overview
   docker run --mount type=bind,source="$PWD"/output,target=/output --mount type=bind,source="$PWD"/mixin-defs,target=/input -it sre-monitoring-as-code:latest -m "$mixin" -rd -i input -o output;
  fi

  # Copy Grafana dashboards to monitoring local
  if [ "$TRANSFER_DASHBOARDS" = "true" ]; then
    for dashboard_file_path in "$DASHBOARD_DIRECTORY"/*"$mixin"*
    do
      dashboard_file="${dashboard_file_path##*/}"

      mkdir -p "$LOCAL_PATH"/grafana/provisioning/dashboards/"$mixin"
      cp "$DASHBOARD_DIRECTORY"/"$dashboard_file" "$LOCAL_PATH"/grafana/provisioning/dashboards/"$mixin"/"$dashboard_file"
    done
  fi

done

## Copy Prometheus rules to monitoring local
if [ "$TRANSFER_RULES" = "true" ]; then
  cp -a "$RULES_DIRECTORY"/. "$LOCAL_PATH"/prometheus/rule_configs
fi


