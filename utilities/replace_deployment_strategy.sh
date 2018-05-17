#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2
REPO_DIR=$3

${REPO_DIR}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME} ${SERVICE_NAME}
aws ecs create-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --cli-input-json file://${REPO_DIR}/specs/servicedefinition.json
