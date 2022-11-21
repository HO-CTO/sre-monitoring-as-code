#!/bin/sh

# YACE Job Type variable assignment
JOB=$YACE_JOB_TYPE

# Conditional to check for static or auto-discovery job type in global environment variables
if [ "$JOB" = "static" ]; then
  # if static merge files and remove all first lines from all but first file
  awk '
      FNR==1 && NR!=1 { while (/^static:/) getline; }
      1 {print}
  ' /config/static/*.yml > /config/config.yml

elif [ "$JOB" = "discovery" ]; then
  # if discovery, env var replacement with comma delimiter to avoid conflict with url strings
  sed "s/@@YACE_ENVIRONMENT_TAG@@/${YACE_ENVIRONMENT_TAG}/g" "/config/discovery/config.yml" > "/config/config.yml"
else
  # else no yace job type set exit with error prompt
  echo "no yace config file has been supplied"
  exit
fi

# Invoke yace config and set flags
exec yace \
--config.file=/config/config.yml \
--scraping-interval=60 \
--debug=false