#!/bin/bash -e
CLUSTER_NAME=$1
SERVICE_NAME=$2

# check if the service exists
SERVICE_COUNT=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services | length")
echo "SERVICE_COUNT:"$SERVICE_COUNT

if [ $SERVICE_COUNT -eq 1 ]
then
    STATUS=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services[0].status")
    echo "STATUS is"$STATUS

    if [ "$STATUS" != "\"INACTIVE\"" ]
    then
      echo "scaling down service"
      aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --desired-count 0
      aws ecs delete-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME}
    fi

    # wait until the service drains
    while [ "$STATUS" != "\"INACTIVE\"" ]
    do
        sleep 5
        STATUS=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services[0].status")
        echo "STATUS is"$STATUS
    done
fi
