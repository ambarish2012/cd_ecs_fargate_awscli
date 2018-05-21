#!/bin/bash -e
CLUSTER_NAME_ARG=$1
SERVICE_NAME_ARG=$2
TASK_DEFINITION_ARg=$3

aws ecs update-service --cluster ${CLUSTER_NAME_ARG} --service ${SERVICE_NAME_ARG} --task-definition ${TASK_DEFINITION_ARG} --force-new-deployment
