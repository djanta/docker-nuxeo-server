#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# slowquery.sh - This script will be use to provide our platform deployment architecture
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

#https://doc.nuxeo.com/nxdoc/monitoring-slow-nxql-queries/

#org.nuxeo.vcs.query.log_min_duration_ms=100
#org.nuxeo.dbs.query.log_min_duration_ms=100

#if [ -n "$NUXEO_VCS_MIN_DURATION" ]; then echo "org.nuxeo.vcs.query.log_min_duration_ms=$NUXEO_VCS_MIN_DURATION" >> "$NUXEO_CONF"; fi
#if [ -n "$NUXEO_DBS_MIN_DURATION" ]; then echo "org.nuxeo.dbs.query.log_min_duration_ms=$NUXEO_DBS_MIN_DURATION" >> "$NUXEO_CONF"; fi

if [ -n "$NUXEO_VCS_SLOWQUERY_DURATION" ]; then echo "org.nuxeo.vcs.query.log_min_duration_ms=${NUXEO_VCS_SLOWQUERY_DURATION}" >> "$NUXEO_CONF"; fi
## For DBS (since Nuxeo Platform 8.3)
if [ -n "$NUXEO_DBS_SLOWQUERY_DURATION" ]; then echo "org.nuxeo.dbs.query.log_min_duration_ms=${NUXEO_DBS_SLOWQUERY_DURATION}" >> "$NUXEO_CONF"; fi
