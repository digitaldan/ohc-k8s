#!/usr/bin/env bash

#
# Copyright (c) 2010-2019 Contributors to the openHAB project
#
# See the NOTICE file(s) distributed with this work for additional
# information.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# http://www.eclipse.org/legal/epl-2.0
#
# SPDX-License-Identifier: EPL-2.0
#

# Contributors:
#    Mehmet Arziman (home-iX) - initial contribution

set -e

KUBERNETES_NAMESPACE=openhab-cloud
KUBERNETES_ACCOUNT=openhabcloud

if [[ ! -d ./openhab-cloud ]]
then
    git clone https://github.com/openhab/openhab-cloud.git
fi

docker build -t openhabcloud-app -f Dockerfile.ohc ./openhab-cloud
docker build -t ohc-nginx -f Dockerfile.nginx ./

echo DEPLOYING OPENHAB-CLOUD TO KUBERNETES

# Creating the openHAB-cloud namespace

kubectl create namespace $KUBERNETES_NAMESPACE

# Creating a service account in the namespace

kubectl create serviceaccount $KUBERNETES_ACCOUNT --namespace $KUBERNETES_NAMESPACE


### Create openHAB-cloud from template

echo Creating openHAB-cloud from template ...

kubectl create -f ohc.yaml --namespace $KUBERNETES_NAMESPACE

echo Creating openHAB-cloud from template ... done!

echo DEPLOYED OPENHAB-CLOUD TO KUBERNETES

export POD_NAME=$(kubectl get pods -n default -l "app=kubernetes-dashboard,release=dashboard" -o jsonpath="{.items[0].metadata.name}")

echo "https://localhost:8443"

kubectl -n default port-forward $POD_NAME 8443:8443
