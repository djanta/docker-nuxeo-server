#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# vcs.sh - This script will be use to provide our platform deployment architecture
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
source "/library/common.sh"
source "/library/log.sh"

if [ -n "$NUXEO_VCS_FULLTEXT_SEARCH" ]; then echo "nuxeo.vcs.fulltext.search.disabled=${NUXEO_VCS_FULLTEXT_SEARCH}" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_VCS_PATH_OPTIMIZATION" ]; then echo "nuxeo.vcs.optimizations.path.enabled=${NUXEO_VCS_PATH_OPTIMIZATION}" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_VCS_ACL_OPTIMIZATION" ]; then echo "nuxeo.vcs.optimizations.acl.enabled=${NUXEO_VCS_ACL_OPTIMIZATION}" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_VCS_MIN_POOL" ]; then echo "nuxeo.vcs.min-pool-size=${NUXEO_VCS_MIN_POOL}" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_VCS_MAX_POOL" ]; then echo "nuxeo.vcs.max-pool-size=${NUXEO_VCS_MAX_POOL}" >> "$NUXEO_CONF"; fi
