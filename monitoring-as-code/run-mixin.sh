#!/bin/sh
# Script to run a given mixin file

# Flags:
# -m: The name of the mixin to target, must be included
# -i: The path to the directory containing the mixin file, if not included defaults to mixin-defs
#     directory inside container
# -o: The path to the directory where you want the output to be copied to, will not copy if no
#     output path included
# -a: The type of account (np, pr or localhost), if not included defaults to localhost
# -r: Include if you only want to generate Prometheus rules, both generated if neither included
# -d: Include if you only want to generate Grafana dashboards, both generated if neither included

# Additional arguments are the namespaces/environments, if none included defaults to localhost

# Global variables
# Sets users monitoring-local path
MONITORING_LOCAL_PATH="${PWD}/.."
# Sets Git branch/tag currently checked out to be used in dashboard tags and rule labels
#MAC_VERSION=$(git symbolic-ref -q --short HEAD || git describe --tags --exact-match)
MAC_VERSION='v2.0.0'
# MaC container image to be used to package Prometheus and Grafana artefacts.
MAC_IMAGE='mac:latest'
# Prometheus container image to be used to syntax check rules.
PROMETHEUS_IMAGE='prom/prometheus'

# Default values
account="localhost"
generate_rules="false"
generate_dashboards="false"
input_path="./mixin-defs"

# Ingests flags
while getopts ':m:i:o:a:rd' OPT; do
  case "${OPT}" in
    m) mixin="${OPTARG}";;
    i) input_path="${OPTARG}";;
    o) output_path="${OPTARG}";;
    a) account="${OPTARG}";;
    r) generate_rules="true";;
    d) generate_dashboards="true";;
    ?) echo "Unknown flag" >&2
       exit 1;;
  esac
done

# Errors if any required flags not included
if [ -z "$mixin" ]; then
  echo "Missing -m flag" >&2
  exit 1
fi

# Errors if mixin file cannot be located
if [ ! -f "${input_path}/${mixin}-mixin.jsonnet" ]; then
  echo "Mixin file does not exist" >&2
  exit 1
fi

# Copy mixin file to TEMP-MIXIN file
cp "${input_path}"/"${mixin}"-mixin.jsonnet ./temporary-mixin/TEMP-MIXIN.jsonnet

# Errors if account is not np, pr or localhost
(echo "$account" | grep -v -Eq "^(np|pr|localhost)$") &&
  echo "Invalid account type" >&2 &&
  exit 1

# If neither -r or -d flags included set both to true
if [ "$generate_rules" = "false" ] && [ "$generate_dashboards" = "false" ]; then
  generate_rules="true"
  generate_dashboards="true"
fi

# Generate Prometheus recording rules should the -r flag be included
if [ "$generate_rules" = "true" ]; then
  # Gets environment arguments
  shift "$(( OPTIND - 1 ))"
  environments="$*"

  # If environment arguments excluded default to localhost
  if [ -z "$environments" ]; then
    environments="localhost"
  fi

  # Create output directory for Prometheus rules
  mkdir -p "$(pwd)"/_output/prometheus-rules

  for environment in $environments
  do
    # Generate Prometheus recording rules YAML
    jsonnet -J vendor --ext-str ENV="${environment}" --ext-str ACCOUNT="${account}" --ext-str MAC_VERSION="${MAC_VERSION}" -S -e "std.manifestYamlDoc((import \"temporary-mixin/TEMP-MIXIN.jsonnet\").prometheusRules)" > "$(pwd)"/_output/prometheus-rules/"${mixin}"-"${environment}"-recording-rules.yaml
    if [ $? -ne 0 ]; then echo "Failed to run recording rules for ${mixin} (environment ${environment}) - exiting"; exit; fi

    # Generate Prometheus alert rules YAML
    jsonnet -J vendor --ext-str ENV="${environment}" --ext-str ACCOUNT="${account}" --ext-str MAC_VERSION="${MAC_VERSION}" -S -e "std.manifestYamlDoc((import \"temporary-mixin/TEMP-MIXIN.jsonnet\").prometheusAlerts)" > "$(pwd)"/_output/prometheus-rules/"${mixin}"-"${environment}"-alert-rules.yaml
    if [ $? -ne 0 ]; then echo "Failed to run alert rules for ${mixin} (environment ${environment}) - exiting"; exit; fi

    # Test prometheus rules with promtool
    #docker run -a stdin -a stdout -a stderr -v "$(pwd)"/monitoring-config:/monitoring-config --entrypoint promtool $PROMETHEUS_IMAGE check rules "$(pwd)"/_output/prometheus-rules/"${mixin}"-"${environment}"-alert-rules.yaml "$(pwd)"/_output/prometheus-rules/"${mixin}"-"${environment}"-recording-rules.yaml
    #if [ $? -ne 0 ]; then echo "Validation of rules files failed for ${mixin} (environment ${environment}) - exiting"; exit 1; fi
  done

  # Copy Prometheus rules to monitoring local
  #cp -a "$(pwd)"/_output/prometheus-rules/. "$MONITORING_LOCAL_PATH"/local/prometheus/rule_configs

fi

# Generate Grafana dashboards should the -d flag be included
if [ "$generate_dashboards" = "true" ]; then

  # Create output directory for Grafana dashboards
  mkdir -p "$(pwd)"/_output/grafana-dashboards

  # Generate Grafana dashboards JSON
  jsonnet -J vendor --ext-str ENV="" --ext-str ACCOUNT="" --ext-str MAC_VERSION="${MAC_VERSION}" -m "$(pwd)"/_output/grafana-dashboards -e "(import \"temporary-mixin/TEMP-MIXIN.jsonnet\").grafanaDashboards"
  if [ $? -ne 0 ]; then echo "Failed to run dashboard generation rules for ${mixin} - exiting"; exit; fi

  # Transfer Grafana dashboards to monitoring local
  #mkdir -p "$MONITORING_LOCAL_PATH"/local/grafana/provisioning/dashboards/"${mixin}" && cp -a "$(pwd)"/_output/grafana-dashboards/"${mixin}"* "$MONITORING_LOCAL_PATH"/local/grafana/provisioning/dashboards/"${mixin}"

fi

# Transfer Prometheus rules and Grafana dashboards to output path
if [ -n "$output_path" ]; then
  cp -a "$(pwd)"/_output/. "${output_path}"
fi

# Remove the TEMP-MIXIN file
rm -rf ./temporary-mixin/TEMP-MIXIN.jsonnet

# Remove the _output directory
rm -rf ./_output
