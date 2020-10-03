#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# es-reinddex.sh - This script will be use to provide our platform deployment architecture
#
# Copyright 2019, Stanislas Koffi ASSOUTOVI <team.docker@djanta.io>
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

if [ "$NUXEO_ES_FORCE_REINDEX" == "true" ] && [ "$NUXEO_ES_ENABLE" == "true" ]; then
  echo "Forcing elasticsearch re-indexation ..."
fi
