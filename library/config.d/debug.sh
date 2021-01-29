#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# debug.sh - This script will be use to provide our platform deployment architecture
#
# Copyright 2020, Stanislas Koffi ASSOUTOVI <team.docker@djanta.io>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for more details.
# ---------------------------------------------------------------------------

# shellcheck disable=SC1090
# shellcheck disable=SC2129
source "/library/common.sh"
source "/library/log.sh"

# shellcheck disable=SC2116
DEBUG=${DEBUG:-$(echo "${NUXEO_DEV_MODE:-false}")}

##
# Enable java debug option by default only of NUXEO_DEV_MODE is activated
##
if [ "$DEBUG" == "true" ]; then

  echo "JAVA_OPTS=\$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=${DEBUG_PORT:-8787}," \
      "server=${DEBUG_SERVER_SIDE:-y},suspend=${DEBUG_SUSPEND:-n}" >> "$NUXEO_CONF"

  DEBUG_SSL=${DEBUG_SSL:-true}
  if [ "$DEBUG_SSL" == "true" ]; then
    echo "JAVA_OPTS=\$JAVA_OPTS -Djavax.net.debug=ssl:record -Djavax.net.debug=ssl:handshake" >> "$NUXEO_CONF"
  fi

  ## Log and stack tracing
  echo "org.nuxeo.rest.stack.enable=${DEBUG:-false}" >> "$NUXEO_CONF"
  echo "org.nuxeo.automation.trace=${DEBUG:-false}" >> "$NUXEO_CONF"
  echo "org.nuxeo.automation.trace.printable=${DEBUG:-false}" >> "$NUXEO_CONF"
fi
