#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2

TASK_DEFINITION_ID=$(aws ecs describe-services --cluster ${CLUSTER_NAME}  --service ${SERVICE_NAME} | jq ".services[0].events[1].message" | awk '{print $8}' | cut -d ')' -f 1)
aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_DEFINITION_ID}
