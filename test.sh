#!/bin/bash

CLUSTER_NAME="deploy-ecs-fargate"
SERVICE_NAME="node_app_service"

# SERVICE_COUNT=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services | length")
# echo "SERVICE_COUNT:"$SERVICE_COUNT
#
# if [ $SERVICE_COUNT -eq 1 ]
# then
#   STATUS=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services[0].status")
#   echo "STATUS is"$STATUS
#
#   if [ "$STATUS" != "\"INACTIVE\"" ]
#   then
#     echo "scaling down service"
#     aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --desired-count 0
#     aws ecs delete-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME}
#   fi
#
#   while [ "$STATUS" != "\"INACTIVE\"" ]
#   do
#       sleep 5
#       STATUS=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} | jq ".services[0].status")
#       echo "STATUS is"$STATUS
#   done
# fi

aws ecs create-service --service-name ${SERVICE_NAME} --cli-input-json file:///Users/ambarish/ambarcsamples/cd_ecs_fargate_awscli/specs/servicedefinition0.json --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={assignPublicIp=ENABLED,subnets=[subnet-34378e50],securityGroups=[sg-a23ee1d0]}"
