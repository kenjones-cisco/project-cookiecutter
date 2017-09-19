#!/bin/bash

case "$1" in
  --jenkins)
    mvn cobertura:cobertura -Dcobertura.report.format=xml ;;
  *)
    mvn cobertura:cobertura ;;
esac
