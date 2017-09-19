#!/bin/bash

PROJECT_FILE="${PROJECT_FILE:-project.yml}"
BASE_PKG=$(yaml read "${PROJECT_FILE}" metadata.import)

echo "==> Generating docs..."

for pkg in $(glide nv);
do
    for subpkg in $(go list ${pkg});
    do
        SUBPKG_DIR=${subpkg#$BASE_PKG}
        echo "--> ${subpkg}"
        mkdir -p ./docs/${SUBPKG_DIR}
        godoc2md ${subpkg} > ./docs$SUBPKG_DIR/README.md
    done
done
