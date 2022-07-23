#!/bin/sh
# Tactical script to deploy monitoring framework

# Clear down MaC output directory
rm -rf `pwd`/monitoring-config/output/*/

# Executes run-mixin.sh script to create rules and dashboards for given mixin files
sh run-mixin.sh -m flapi -rd -i `pwd`/input -o `pwd`/output

#sh run-mixin.sh -m summary -d
