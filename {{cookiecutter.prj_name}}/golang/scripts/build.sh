#!/bin/bash

PROJECT_FILE="${PROJECT_FILE:-project.yml}"


get_targets() {
    local data

    data=$(yaml -j read project.yml metadata.build[*] | jq -r '.[] | [ .["target"] ] | join(" ")')
    echo "$data"
}

build() {
    local import_path
    local ldflags

    import_path=$(yaml read "${PROJECT_FILE}" metadata.import)

    ldflags="-X ${import_path}/version.GitCommit=$(git rev-parse --short HEAD)"
    ldflags="${ldflags} -X ${import_path}/version.GitDescribe=$(git describe --tags --always)"

    mapfile -t targets < <(get_targets)
    for target in "${targets[@]}"; do
        echo "building: $target"
        go build -ldflags "${ldflags}" -o "bin/$(basename "$target")" "${import_path}/$target"
    done
}

build
