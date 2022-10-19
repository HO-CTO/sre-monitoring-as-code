#!/bin/sh
# Script to run a given mixin file

# Flags:
# -m: The name of the mixin to target, must be included
# -o: The path to the directory where you want the output to be copied to, must be included
# -i: The path to the directory containing the mixin file, if not included defaults to mixin-defs
#     directory inside container
# -a: The type of account (np, pr or localhost), if not included defaults to localhost
# -r: Include if you only want to generate Prometheus rules, both generated if neither included
# -d: Include if you only want to generate Grafana dashboards, both generated if neither included

# Additional arguments are the namespaces/environments, if none included defaults to localhost

# Global variables
# Pass semver or PR from GitHub workflow to dashboard and rules label.
MAC_VERSION=${MAC_VERSION:-'local'}

# Remove temporary directories if not removed after previous execution
rm -rf "$PWD"/_input
rm -rf "$PWD"/_output

# Default values
account="localhost"
generate_rules="false"
generate_dashboards="false"
input_path="$PWD"/mixin-defs
custom_metric_types_filename="custom-metric-types.libsonnet"

# Ingests flags
while getopts ":m:o:i:a:rd" OPT; do
  case "$OPT" in
    m) mixin="$OPTARG";;
    o) output_path="$OPTARG";;
    i) input_path="$OPTARG";;
    a) account="$OPTARG";;
    r) generate_rules="true";;
    d) generate_dashboards="true";;
    ?) echo "Unknown flag" >&2
       exit 1;;
  esac
done

CUSTOM_METRIC_TYPES="false"
if [ -f "/$input_path/$custom_metric_types_filename" ]; then
  cp "/$input_path/$custom_metric_types_filename" /mixin-defs/$custom_metric_types_filename
  CUSTOM_METRIC_TYPES="true"
fi

# Errors if any required flags not included
if [ -z "$mixin" ] || [ -z "$output_path" ]; then
  echo "Missing required flags" >&2
  exit 1
fi

# Errors if mixin file cannot be located
if [ ! -f "$input_path"/"$mixin"-mixin.jsonnet ]; then
  echo "Mixin file does not exist" >&2
  exit 1
fi

# Creates temporary _input directory
mkdir "$PWD"/_input

# Copy mixin file to _input directory
cp "$input_path"/"$mixin"-mixin.jsonnet "$PWD"/_input/mixin.jsonnet

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

  # Create temporary _output directory with Prometheus rules directory
  mkdir -p "$PWD"/_output/prometheus-rules

  for environment in $environments
  do
    # Generate Prometheus recording rules YAML
    if ! jsonnet -J vendor --ext-str ENV="$environment" --ext-str ACCOUNT="$account" --ext-str MAC_VERSION="$MAC_VERSION" --ext-str CUSTOM_METRIC_TYPES="$CUSTOM_METRIC_TYPES" -S -e "std.manifestYamlDoc((import \"${PWD}/_input/mixin.jsonnet\").prometheusRules)" > "$PWD"/_output/prometheus-rules/sre-mac-"$mixin"-"$environment"-recording-rules.yaml;
    then echo "Failed to run recording rules for ${mixin} (environment ${environment}) - exiting"; exit; fi

    # Generate Prometheus alert rules YAML
    if ! jsonnet -J vendor --ext-str ENV="$environment" --ext-str ACCOUNT="$account" --ext-str MAC_VERSION="$MAC_VERSION" --ext-str CUSTOM_METRIC_TYPES="$CUSTOM_METRIC_TYPES" -S -e "std.manifestYamlDoc((import \"${PWD}/_input/mixin.jsonnet\").prometheusAlerts)" > "$PWD"/_output/prometheus-rules/sre-mac-"$mixin"-"$environment"-alert-rules.yaml;
    then echo "Failed to run alert rules for ${mixin} (environment ${environment}) - exiting"; exit; fi

  done
fi

# Generate Grafana dashboards should the -d flag be included
if [ "$generate_dashboards" = "true" ]; then
  # Create temporary _output directory with Grafana dashboards directory
  mkdir -p "$PWD"/_output/grafana-dashboards

  # Generate Grafana dashboards JSON
  if ! jsonnet -J vendor --ext-str ENV="" --ext-str ACCOUNT="" --ext-str MAC_VERSION="$MAC_VERSION" --ext-str CUSTOM_METRIC_TYPES="$CUSTOM_METRIC_TYPES" -m "$PWD"/_output/grafana-dashboards -e "(import \"${PWD}/_input/mixin.jsonnet\").grafanaDashboards";
  then echo "Failed to run dashboard generation rules for ${mixin} - exiting"; exit; fi
fi

# Transfer Prometheus rules and Grafana dashboards to output path
cp -a "$PWD"/_output/. "$output_path"

# Remove temporary directories
rm -rf "$PWD"/_input
rm -rf "$PWD"/_output
