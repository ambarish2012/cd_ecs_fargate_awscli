#!/bin/bash -e

function check_service_stability {
    CLUSTER_NAME_ARG=$1
    SERVICE_NAME_ARG=$2
    DESIRED_TASK_COUNT_ARG=$3
    MINUTES_TO_POLL=$4

    SUCCESS=1
    RUNNING_TASK_COUNT=0
    format='%Y%m%d%H%M%S'
    currDate=$(date +${format})
    finalDate=$(date -d 'now + '${MINUTES_TO_POLL}' minutes' +${format})

    while [ "${currDate}" -lt "${finalDate}" ]
    do
        RUNNING_TASK_COUNT=$(aws ecs describe-services --cluster ${CLUSTER_NAME_ARG} --service ${SERVICE_NAME_ARG} | jq ".services[0].runningCount")
        echo "Running task count "${RUNNING_TASK_COUNT}

        if [ "${RUNNING_TASK_COUNT}" -eq "${DESIRED_TASK_COUNT_ARG}" ]; then
            SUCCESS=0
            break
        fi

        currDate=$(date +${format})
        sleep 2
    done

    if [ "${SUCCESS}" -ne 0 ]; then
      echo "Desired count of tasks has not been reached in time specified, please check ECS service event logs for more details"
    else
      echo "Deployment is complete"
    fi

    return ${SUCCESS}
}
