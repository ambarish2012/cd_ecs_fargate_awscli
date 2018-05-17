#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2
REPO_DIR=$3

echo "deleting existing service"
${REPO_DIR}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME} ${SERVICE_NAME}

echo "creating new service"
aws ecs create-service --cli-input-json file://${REPO_DIR}/specs/servicedefinition.json
