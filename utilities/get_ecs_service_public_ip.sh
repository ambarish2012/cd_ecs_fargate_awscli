#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2
REPO_DIR=$3

TASK_DEFINITION_ID=$(aws ecs describe-services --cluster ${CLUSTER_NAME}  --service ${SERVICE_NAME} | jq ".services[0].events[1].message" | awk '{print $8}' | cut -d ')' -f 1)
TASK_DATA=$(aws ecs describe-tasks --cluster ${CLUSTER_NAME} --tasks ${TASK_DEFINITION_ID})
echo $TASK_DATA

TASK_DATA=$(${REPO_DIR}/utilities/get_ecs_service_task_data.sh ${CLUSTER_NAME} ${SERVICE_NAME})
NETWORK_INTERFACE_ID=$(echo ${TASK_DATA} | jq -r ".tasks[0].attachments[0].details[1].value")
aws ec2 describe-network-interfaces --filters Name=network-interface-id,Values=${NETWORK_INTERFACE_ID} | jq -r ".NetworkInterfaces[0].Association.PublicIp"
