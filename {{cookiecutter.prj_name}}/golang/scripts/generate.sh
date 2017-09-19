#!/bin/bash

PROJECT_FILE="${PROJECT_FILE:-project.yml}"
PROJECT=$(yaml read "${PROJECT_FILE}" metadata.name)
API_FILE=$(yaml read "${PROJECT_FILE}" metadata.apifile)

# exit if validation fails
if ! valid=$(swagger validate "${API_FILE}" 2>&1); then
    echo "spec validation failed: ${valid}"
    exit 1
fi

# generate server
#   Reference: https://goswagger.io/generate/server.html
# -A name of the application; avoids default which is hard to read
# -a the package to save the operations; shorten from default to make more readable
swagger generate server -A {{cookiecutter.product_name|replace(' ', '')}} -a ops -f "${API_FILE}"

# remove the use of local imports eg. ../../
find cmd -type f -print0 | xargs -0 sed -i "s|../../${PROJECT}/src/||g"
find restapi -type f -print0 | xargs -0 sed -i "s|../../${PROJECT}/src/||g"

# generate client
#   Reference: https://goswagger.io/generate/client.html
# -A name of the application; avoids default which is hard to read
swagger generate client -A {{cookiecutter.product_name|replace(' ', '')}} -f "${API_FILE}"

# remove the use of local imports eg. ../../
find client -type f -print0 | xargs -0 sed -i "s|../../${PROJECT}/src/||g"
