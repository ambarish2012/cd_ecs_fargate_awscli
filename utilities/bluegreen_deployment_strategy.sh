#!/bin/bash
function bluegreen_deployment_strategy {
    CLUSTER_NAME=$1
    SERVICE_NAME=$2
    REPO_DIR=$3
    DESIRED_TASK_COUNT=$4
    REVISION=$5
    VALIDATION_TASK_SCRIPT=$6

    rm $JOB_PREVIOUS_STATE/serviceId.env

    # Generate green service name
    if [ -f $JOB_PREVIOUS_STATE/serviceId.env ]; then
      . $JOB_PREVIOUS_STATE/serviceId.env
      EXISTING_BLUE_SERVICE_NAME=${SERVICE_NAME}-${serviceId}
      let "serviceId++"
    else
      EXISTING_BLUE_SERVICE_NAME=${SERVICE_NAME}
      serviceId=1
    fi

    GREEN_SERVICE_NAME=${SERVICE_NAME}-${serviceId}

    pushd $REPO_DIR/specs
    export DEPLOYED_SERVICE_NAME=${GREEN_SERVICE_NAME}
    shipctl replace servicedefinition.json
    popd

    # Deploy green service
    echo "Creating green service"${GREEN_SERVICE_NAME}
    aws ecs create-service --cli-input-json file://${REPO_DIR}/specs/servicedefinition.json
    retVal=$?
    if [ $retVal -ne 0 ]; then
      echo "creation of green service failed"
      return $retVal
    fi

    # Check status of green service
    source ${REPO_DIR}/utilities/check_service_stability.sh
    check_service_stability ${CLUSTER_NAME} ${GREEN_SERVICE_NAME} ${DESIRED_TASK_COUNT} 5
    retVal=$?
    if [ $retVal -ne 0 ]; then
      ${REPO_DIR}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME} ${GREEN_SERVICE_NAME}
      return $retVal
    fi

    # Run any validation task scripts
    if [ -f ${VALIDATION_TASK_SCRIPT} ]; then
      . ${VALIDATION_TASK_SCRIPT}
    fi

    # Increment and persist serviceId
    echo "serviceId=${serviceId}" > ./serviceId.env
    shipctl copy_file_to_state ./serviceId.env
    cat ${JOB_STATE}/serviceId.env

    # Delete service if it existed at the very first deployment
    if [ "${serviceId}" -eq 1 ]; then
      # Check if blue service was already running
      RUNNING_TASK_COUNT=$(aws ecs describe-services --cluster ${CLUSTER_NAME} --service ${EXISTING_BLUE_SERVICE_NAME} | jq ".services[0].runningCount")
      if [ "${RUNNING_TASK_COUNT}" -eq 1 ]; then
        ${REPO_DIR}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME} ${EXISTING_BLUE_SERVICE_NAME}
      fi
    else
      # Delete previously deployed blue service
      ${REPO_DIR}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME} ${EXISTING_BLUE_SERVICE_NAME}
      echo "Deployment is complete"
    fi

    return 0
}
