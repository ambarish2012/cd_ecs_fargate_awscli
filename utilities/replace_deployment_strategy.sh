#!/bin/bash -e
CLUSTER_NAME_ARG=$1
SERVICE_NAME_ARG=$2
REPO_DIR_ARG=$3

echo "deleting existing service"
${REPO_DIR_ARG}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME_ARG} ${SERVICE_NAME_ARG}

echo "creating new service"
aws ecs create-service --cli-input-json file://${REPO_DIR_ARG}/specs/servicedefinition.json
