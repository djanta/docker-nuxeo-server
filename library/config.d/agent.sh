#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# agent.sh - This script will be use to provide our platform deployment architecture
#
# Copyright 2015, Stanislas Koffi ASSOUTOVI <team.docker@djanta.io>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.
# ---------------------------------------------------------------------------

# shellcheck disable=SC1090
# shellcheck disable=SC2129

source "/library/common.sh"
source "/library/log.sh"

JVM_AGENT_JAR_PATH="$CONFIG_D/agent/${JVM_AGENT_NAME:-""}/agent.jar"
JVM_AGENT_PROFILE_PATH="$CONFIG_D/agent/${JVM_AGENT_NAME:-""}/config/agent.profile"

if [ -f "$JVM_AGENT_JAR_PATH" ]; then
  echo "JAVA_OPTS=\$JAVA_OPTS -javaagent:$JVM_AGENT_JAR_PATH -DagentName=${HOSTNAME}" >> "$NUXEO_CONF"
  echo "JAVA_OPTS=\$JAVA_OPTS -Dcom.sun.management.jmxremote=true -DagentProfile=${JVM_AGENT_PROFILE_PATH:-""}" >> "$NUXEO_CONF"
else
  warn "Missing JVM Agent $JVM_AGENT_JAR_PATH"
fi
