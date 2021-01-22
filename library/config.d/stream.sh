#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# stream.sh - This script will be use to provide our platform deployment architecture
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

#nuxeo.stream.audit.batch.size=1000
#nuxeo.stream.audit.batch.threshold.ms=1000

    # Audit log optimization
    [ -n "$NUXEO_AUDIT_LOG_BATCH_THRESHOLD" ] && echo "nuxeo.stream.audit.batch.threshold.ms=$NUXEO_AUDIT_LOG_BATCH_THRESHOLD" >> "$NUXEO_CONF"
    [ -n "$NUXEO_AUDIT_LOG_BATCH_SIZE" ] && echo "nuxeo.stream.audit.batch.size=$NUXEO_AUDIT_LOG_BATCH_SIZE" >> "$NUXEO_CONF"

    # Bulk Stream configuration
    [ -n "$NUXEO_BULK_DONE_CONCURRENCY_MAX" ] && echo "nuxeo.core.bulk.done.concurrencyMax=$NUXEO_BULK_DONE_CONCURRENCY_MAX" >> "$NUXEO_CONF"
    [ -n "$NUXEO_BULK_SCROLL_CONCURRENCY_MAX" ] && echo "nuxeo.core.bulk.scroller.concurrencyMax=$NUXEO_BULK_SCROLL_CONCURRENCY_MAX" >> "$NUXEO_CONF"
    [ -n "$NUXEO_BULK_STATUS_CONCURRENCY_MAX" ] && echo "nuxeo.core.bulk.status.concurrencyMax=$NUXEO_BULK_STATUS_CONCURRENCY_MAX" >> "$NUXEO_CONF"
