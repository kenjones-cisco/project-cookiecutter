#!/bin/bash

set -eo pipefail

PROJECT_FILE="${PROJECT_FILE:-project.yml}"
API_FILE=$(yaml read "${PROJECT_FILE}" metadata.apifile)

CODEGEN_JAR="/opt/swagger-codegen-cli.jar"
JAVA_OPTS=${JAVA_OPTS:"-XX:MaxPermSize=256M -Xmx1024M -DloggerPath=conf/log4j.properties"}

# validate the API spec
java ${JAVA_OPTS} -jar ${CODEGEN_JAR} validate -i "${API_FILE}"

# generate server
#   Reference: https://github.com/swagger-api/swagger-codegen/blob/master/README.md
java ${JAVA_OPTS} -jar ${CODEGEN_JAR} generate -i "${API_FILE}" --lang spring -c config/swagger_config.json
