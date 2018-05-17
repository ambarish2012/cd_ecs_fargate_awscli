#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2
DESIRED_TASK_COUNT=$3
SECONDS_TO_POLL=$4

RUNNING_TASK_COUNT=0
format='%Y%m%d%S'
currDate=$(date +${format})
finalDate=$(date --date 'now + '${SECONDS_TO_POLL}+'seconds' +${format})

while [ "$currDate" -lt "$finalDate" ]
do
    RUNNING_TASK_COUNT = $(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services[0].runningCount")

    if [ "$RUNNING_TASK_COUNT" -eq "$DESIRED_TASK_COUNT"  ]; then
        echo "Deployment is complete"
        break
    fi

    currDate=$(date +${format})
    sleep 2
done

echo "Desired count of tasks has not been reached in time specified, please check ECS service event logs"