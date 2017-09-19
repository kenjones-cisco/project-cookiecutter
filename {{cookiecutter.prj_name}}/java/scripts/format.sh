#!/bin/bash

java -jar /opt/java-formater.jar -i $(find src/ -type f -name "*.java")
