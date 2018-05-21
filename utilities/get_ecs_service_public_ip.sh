#!/bin/bash -e
CLUSTER_NAME_ARG=$1
SERVICE_NAME_ARG=$2
REPO_DIR_ARG=$3

TASK_DATA=$(${REPO_DIR_ARG}/utilities/get_ecs_service_task_data.sh ${CLUSTER_NAME_ARG} ${SERVICE_NAME_ARG})
NETWORK_INTERFACE_ID=$(echo ${TASK_DATA} | jq -r ".tasks[0].attachments[0].details[1].value")
aws ec2 describe-network-interfaces --filters Name=network-interface-id,Values=${NETWORK_INTERFACE_ID} | jq -r ".NetworkInterfaces[0].Association.PublicIp"
