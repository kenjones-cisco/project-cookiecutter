#!/bin/bash

# the linters are bound to the phase "validate" which always run
# prior to compilation.
mvn compile
