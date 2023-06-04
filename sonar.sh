#!/usr/bin/env bash
echo $PWD
exec java -XX:+UseZGC -jar lib/sonar-application-"${SONAR_VERSION}".jar -Dsonar.log.console=true "$@"
