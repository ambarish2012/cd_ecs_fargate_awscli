#!/bin/bash
SERVICE_NAME_ARG=$1

# Generate green service name
. $JOB_STATE/serviceId.env
echo ${SERVICE_NAME_ARG}-${serviceId}
