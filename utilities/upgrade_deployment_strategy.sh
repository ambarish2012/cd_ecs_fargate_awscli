#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2
REPO_DIR=$3

aws ecs update-service --cli-input-json file://${REPO_DIR}/specs/servicedefinition.json --force-new-deployment true
