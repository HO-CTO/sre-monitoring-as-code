#!/bin/sh

# env var replacement with comma delimiter to avoid conflict with url strings
sed "s/@@YACE_ENVIRONMENT_TAG@@/${YACE_ENVIRONMENT_TAG}/g" "/config/config.yml" > "/config/newconfig.yml"

# Invoke yace config and set flags
exec yace \
--config.file=/config/newconfig.yml \
--scraping-interval=60 \
--debug=false