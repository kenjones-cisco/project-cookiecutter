#!/bin/bash

RUN_CMD=(docker run --rm -v "${ROOT}":/mnt "${IMAGE_NAME}")
LOCAL_OPTIONS=(--no-input --output-dir /mnt/_test_local /mnt)
REMOTE_OPTIONS=(--no-input --output-dir /mnt/_test_remote "https://github.com/kenjones-cisco/${PROJECT}.git")
CONFIG_OPTION="--config-file /mnt/examples"


clean() {
    rm -rf _test_local _test_remote
}

assert() {
    if ! result=$(diff -r _test_local _test_remote); then
        echo -e "\\tFAILED"
        echo "${result}"
    else
        echo -e "\\tPASSED"
    fi
}

run_test() {
    local name="$1"
    local cfgopt=${CONFIG_OPTION}/${name}
    if [[ -z "$1" ]]; then
        cfgopt=''
        name='default'
    fi

    clean
    "${RUN_CMD[@]}" ${cfgopt} "${LOCAL_OPTIONS[@]}"
    "${RUN_CMD[@]}" ${cfgopt} "${REMOTE_OPTIONS[@]}"

    echo "Test ${name}"
    assert
}

## Main

# run each example through as a test
mapfile -t testfiles < <(find ./examples/ -name "*.yaml")
for testfile in "${testfiles[@]}"; do
    run_test "$(basename "${testfile}")"
done

# test the default configuration
run_test

# clean up any test artifacts
clean
