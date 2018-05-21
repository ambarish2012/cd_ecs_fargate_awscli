#!/bin/bash
function bluegreen_deployment_strategy {
    CLUSTER_NAME_ARG=$1
    SERVICE_NAME_ARG=$2
    REPO_DIR_ARG=$3
    DESIRED_TASK_COUNT_ARG=$4
    VALIDATION_TASK_SCRIPT_ARG=$5

    rm $JOB_PREVIOUS_STATE/serviceId.env

    # Generate green service name
    if [ -f $JOB_PREVIOUS_STATE/serviceId.env ]; then
      . $JOB_PREVIOUS_STATE/serviceId.env
      EXISTING_BLUE_SERVICE_NAME=${SERVICE_NAME_ARG}-${serviceId}
      let "serviceId++"
    else
      EXISTING_BLUE_SERVICE_NAME=${SERVICE_NAME_ARG}
      serviceId=1
    fi

    GREEN_SERVICE_NAME=${SERVICE_NAME_ARG}-${serviceId}

    pushd $REPO_DIR_ARG/specs
    export DEPLOYED_SERVICE_NAME=${GREEN_SERVICE_NAME}
    shipctl replace servicedefinition.json
    cat servicedefinition.json
    popd

    # Deploy green service
    echo "Creating green service"${GREEN_SERVICE_NAME}
    aws ecs create-service --cli-input-json file://${REPO_DIR_ARG}/specs/servicedefinition.json
    retVal=$?
    if [ $retVal -ne 0 ]; then
      echo "creation of green service failed"
      return $retVal
    fi

    # Check status of green service
    source ${REPO_DIR_ARG}/utilities/check_service_stability.sh
    check_service_stability ${CLUSTER_NAME_ARG} ${GREEN_SERVICE_NAME} ${DESIRED_TASK_COUNT_ARG} 5
    retVal=$?
    if [ $retVal -ne 0 ]; then
      ${REPO_DIR_ARG}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME_ARG} ${GREEN_SERVICE_NAME}
      return $retVal
    fi

    # Run any validation task scripts
    if [ -f ${VALIDATION_TASK_SCRIPT_ARG} ]; then
      . ${VALIDATION_TASK_SCRIPT_ARG}
    fi

    # Increment and persist serviceId
    echo "serviceId=${serviceId}" > ./serviceId.env
    shipctl copy_file_to_state ./serviceId.env

    # Delete service if it existed at the very first deployment
    if [ "${serviceId}" -eq 1 ]; then
      # Check if blue service was already running
      RUNNING_TASK_COUNT=$(aws ecs describe-services --cluster ${CLUSTER_NAME_ARG} --service ${EXISTING_BLUE_SERVICE_NAME} | jq ".services[0].runningCount")
      if [ "${RUNNING_TASK_COUNT}" -eq 1 ]; then
        ${REPO_DIR_ARG}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME_ARG} ${EXISTING_BLUE_SERVICE_NAME}
      fi
    else
      # Delete previously deployed blue service
      ${REPO_DIR_ARG}/utilities/delete_existing_ecs_service.sh ${CLUSTER_NAME_ARG} ${EXISTING_BLUE_SERVICE_NAME}
      echo "Deployment is complete"
    fi

    return 0
}
