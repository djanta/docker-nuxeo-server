#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# cache.sh - This script will be use to provide our platform deployment architecture
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

# Do not use Redis for directory cache
if [ -n "$NUXEO_CACHE_TYPE" ]; then echo "nuxeo.cache.type=$NUXEO_CACHE_TYPE" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_CACHE_MAXSIZE" ]; then echo "nuxeo.cache.maxsize=$NUXEO_CACHE_MAXSIZE" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_CACHE_TTL" ]; then echo "nuxeo.cache.ttl=$NUXEO_CACHE_TTL" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_CACHE_CONCURRENT_LEVEL" ]; then echo "nuxeo.cache.concurrencylevel=$NUXEO_CACHE_CONCURRENT_LEVEL" >> "$NUXEO_CONF"; fi
