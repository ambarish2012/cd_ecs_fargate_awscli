#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2
TASK_DEFINITION=$3

aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_DEFINITION} --force-new-deployment
