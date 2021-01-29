#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# worker.sh - This script will be use to provide our platform deployment architecture
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

# Misc Queue worker thread resizing
if [ -n "$NUXEO_WORKER_DEFAULT_THREADS" ]; then echo "nuxeo.worker.default.threads=$NUXEO_WORKER_DEFAULT_THREADS" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_WORKER_PICTURE_THREADS" ]; then echo "nuxeo.worker.picture.threads=$NUXEO_WORKER_PICTURE_THREADS" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_WORKER_VIDEO_THREADS" ]; then echo "nuxeo.worker.video.threads=$NUXEO_WORKER_VIDEO_THREADS" >> "$NUXEO_CONF"; fi
if [ -n "$NUXEO_WORKER_ELASTICSEARCH_THREADS" ]; then echo "nuxeo.worker.elasticsearch.threads=$NUXEO_WORKER_ELASTICSEARCH_THREADS" >> "$NUXEO_CONF"; fi
