#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# tomcat.sh - This script will be use to provide our platform deployment architecture
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

# Tomcat configuration
if [ -n "$NUXEO_HTTP_UPLOAD_TIMEOUT" ]; then echo "nuxeo.server.http.connectionUploadTimeout=$NUXEO_HTTP_UPLOAD_TIMEOUT" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_HTTP_MAX_THREAD" ]; then echo "nuxeo.server.http.maxThreads=$NUXEO_HTTP_MAX_THREAD" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_HTTP_ACCEPTCOUNT" ]; then echo "nuxeo.server.http.acceptCount=$NUXEO_HTTP_ACCEPTCOUNT" >> "$NUXEO_CONF"; fi
