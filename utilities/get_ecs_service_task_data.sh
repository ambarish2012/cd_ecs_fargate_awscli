#!/bin/bash -e
CLUSTER_NAME_ARG=$1
SERVICE_NAME_ARG=$2

TASK_ARN=$(aws ecs list-tasks --cluster ${CLUSTER_NAME_ARG}  --service ${SERVICE_NAME_ARG} | jq -r ".taskArns[0]")
aws ecs describe-tasks --cluster ${CLUSTER_NAME_ARG} --tasks ${TASK_ARN}
