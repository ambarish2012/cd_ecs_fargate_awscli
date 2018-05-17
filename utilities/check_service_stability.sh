#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2
DESIRED_TASK_COUNT=$3
MINUTES_TO_POLL=$4

RUNNING_TASK_COUNT=0
format='%Y%m%d%H%M%S'
currDate=$(date +${format})
finalDate=$(date -d 'now + '${MINUTES_TO_POLL}' minutes' +${format})

echo "current DateTime: "${currDate}
echo "final DateTime: "${finalDate}

while [ "$currDate" -lt "$finalDate" ]
do
    RUNNING_TASK_COUNT=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services[0].runningCount")
    echo "Running task count "${RUNNING_TASK_COUNT}

    if [ "$RUNNING_TASK_COUNT" -eq "$DESIRED_TASK_COUNT" ]; then
        echo "Deployment is complete"
        break
    fi

    currDate=$(date +${format})
    sleep 2
done

echo "Desired count of tasks has not been reached in time specified, please check ECS service event logs"

date --date 'now + '4' minutes' +'%Y%m%d%S'
