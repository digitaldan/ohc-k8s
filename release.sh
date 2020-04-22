#!/usr/bin/env bash

set -e

# Replace the Host URL in the config.json with injected "OPENHABCLOUD_ADDRESS"
if [ ! -z "${OPENHABCLOUD_ADDRESS}" ]; then
    git checkout config.json
    sed -i -e "s/localhost/${OPENHABCLOUD_ADDRESS}/g" config.json
fi

# Build the application and push it to container regsitry
docker build --file deployment/docker/node/Dockerfile . -t openhab/openhabcloud-app:1.0.11
git checkout config.json
docker push openhab/openhabcloud-app:1.0.11

# Add default values to helm release-name and ingress variables in case there are not set
if [ -z "${RELEASENAME}" ]; then
    RELEASENAME=myopenhab
fi
if [ -z "${OPENHABCLOUD_ADDRESS}" ]; then
    OPENHABCLOUD_ADDRESS=myopenhab.org
fi

# Create temp. folder for Helm execution
mkdir -p /tmp/charts
yes | cp -rf deployment/charts/* /tmp/charts
cd /tmp/charts/openhab-cloud

# Install Helm chart with --force option to prune previous installs/attempts
helm dep update
helm upgrade --install --force ${RELEASENAME}-openhabcloud /tmp/charts/openhab-cloud --set image.secret=ohcjenkins,ingress.host=${OPENHABCLOUD_ADDRESS}
