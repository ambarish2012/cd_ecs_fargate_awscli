#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2


TASK_ARN=$(aws ecs list-tasks --cluster ${CLUSTER_NAME}  --service ${SERVICE_NAME} | jq -r ".taskArns[0]")
aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_ARN}
