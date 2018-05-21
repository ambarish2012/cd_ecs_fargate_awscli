#!/bin/bash
SERVICE_NAME=$1

# Generate green service name
. $JOB_STATE/serviceId.env
echo ${SERVICE_NAME}-${serviceId}
