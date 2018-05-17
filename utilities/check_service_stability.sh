#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2
DESIRED_TASK_COUNT=$3
MINUTES_TO_POLL=$4

SUCCESS=0
RUNNING_TASK_COUNT=0
format='%Y%m%d%H%M%S'
currDate=$(date +${format})
finalDate=$(date -d 'now + '${MINUTES_TO_POLL}' minutes' +${format})

while [ "$currDate" -lt "$finalDate" ]
do
    RUNNING_TASK_COUNT=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services[0].runningCount")
    echo "Running task count "${RUNNING_TASK_COUNT}

    if [ "$RUNNING_TASK_COUNT" -eq "$DESIRED_TASK_COUNT" ]; then
        SUCCESS=1
        break
    fi

    currDate=$(date +${format})
    sleep 2
done

if [ "$SUCCESS" -eq 0 ]; then
  echo "Desired count of tasks has not been reached in time specified, please check ECS service event logs for more details"
  exit 1
else
  echo "Deployment is complete"
  exit 0
fi
