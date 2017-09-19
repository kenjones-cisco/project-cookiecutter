#!/bin/bash

set -o errexit
set -o pipefail

SIMPLE_RESULTS=/dev/stdout
DETAILED_RESULTS=/dev/stdout

set_opts() {

read -r COMMON_OPTS << EOM
    --skip=.glide \{% if cookiecutter.use_codegen == "y" %}
    --skip=models \
    --skip=client \
    --skip=restapi/ops \{% endif %}
    --tests \
    --vendor
EOM

read -r SIMPLE_OPTS << EOM
    ${COMMON_OPTS} \
    --disable=aligncheck \
    --disable=gotype \
    --disable=structcheck \
    --disable=varcheck \
    --disable=interfacer \
    --disable=unconvert \
    --disable=dupl \
    --cyclo-over=15 \
    --deadline=60s \
    ./...
EOM

# The following checks get into lower level detailed analysis of the code, but they
# all are common in that they scan the project differently then the others above that
# accept a simple base path recursion.
read -r DETAILED_OPTS << EOM
    ${COMMON_OPTS} \
    --deadline=60s \
    --disable-all \
    --enable=unused \
    --enable=structcheck \
    --enable=varcheck \
    --enable=interfacer \
    --enable=unconvert
EOM

}

# Excludes:
#   - when using defer there is no way to check to returned value so ignore
#   - some generated code has output parameters named as err that result in vetshadow issue so ignore

# The --exclude statements get passed directly to avoid bash interpolation or escaping of the single quotes
# that results in gometalinter ignore the exclude lines.
check() {
    gometalinter \
        --exclude='error return value not checked.*(Close|Log|Print|Shutdown).*\(errcheck\)$' \
        ${SIMPLE_OPTS} > ${SIMPLE_RESULTS}

    gometalinter ${DETAILED_OPTS} > ${DETAILED_RESULTS}
}

case "$1" in
    --jenkins)
        SIMPLE_RESULTS=simple-checks.out
        DETAILED_RESULTS=detailed-checks.out
        touch ${SIMPLE_RESULTS}
        touch ${DETAILED_RESULTS}
        ;;
    *)
        ;;
esac

set_opts
check
