#!/bin/sh
# Tactical script to deploy monitoring framework

# Clear down MaC output directory
rm -rf `pwd`/monitoring-config/output/*/

# Executes run-mixin.sh script to create rules and dashboards for given mixin files
sh run-mixin.sh -m monitoring -r -d

sh run-mixin.sh -m summary -d
