#!/bin/bash

SCRIPTS=($(find bin -name "*.sh"))
LIBS=($(find lib -name "*.bash"))

shellcheck -x ${LIBS[*]} ${SCRIPTS[*]}
