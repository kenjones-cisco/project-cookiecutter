#!/bin/bash

echo "==> Generating docs ..."

# See: http://swagger2markup.github.io/swagger2markup/1.1.1/#_introduction
# See: http://asciidoctor.org/docs/asciidoctor-maven-plugin/#distribution
# Both are configured in pom.xml
mvn generate-resources
