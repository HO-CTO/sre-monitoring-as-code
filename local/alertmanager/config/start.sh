#!/bin/sh

# env var replacement with comma delimiter to avoid conflict with url strings
sed "s,@@AM_SLACK_API_URL@@,${AM_SLACK_API_URL},g; \
s,@@AM_SLACK_CHANNEL@@,${AM_SLACK_CHANNEL},g" "/config/config.yaml" > "/config/newconfig.yaml"

# env var replacement with comma delimiter to avoid conflict with url strings
#sed -i "s,@@AM_SLACK_API_URL@@,${AM_SLACK_API_URL},g" "/config/ebsaconfig.yaml" > "/config/newebsaconfig.yml"

# Invoke yace config and set flags
exec /bin/alertmanager \
--config.file=/config/newconfig.yaml \
--storage.path=/alertmanager