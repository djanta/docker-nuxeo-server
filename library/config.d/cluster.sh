#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# cluster.sh - This script will be use to provide our platform deployment architecture
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

if [ "$NUXEO_CLUSTERING_ENABLE" == "true" ]; then
  # FIXME: These following two line only available from nuxeo 11.x
  #echo "nuxeo.cluster.enabled=${NUXEO_CLUSTERING_ENABLE}" >> "$NUXEO_CONF"
  #echo "nuxeo.cluster.nodeid=${NUXEO_CLUSTERING_PREFIX:-""}${HOSTNAME}" >> "$NUXEO_CONF"

  # FIXME: Comment these when migrate to 11.x
  echo "repository.clustering.enabled=${NUXEO_CLUSTERING_ENABLE}" >> "$NUXEO_CONF"
  echo "repository.clustering.id=${NUXEO_CLUSTERING_PREFIX:-""}${HOSTNAME}" >> "$NUXEO_CONF"
fi
