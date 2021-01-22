#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# redis.sh - This script will be use to provide our platform deployment architecture
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

# shellcheck disable=SC2129
if [ "$NUXEO_REDIS_ENABLED" == "true" ] && [ -n "$NUXEO_REDIS_HOST" ]; then

  echo "nuxeo.redis.enabled=$NUXEO_REDIS_ENABLED" >> "$NUXEO_CONF"
  echo "nuxeo.redis.host=$NUXEO_REDIS_HOST" >> "$NUXEO_CONF"
  echo "nuxeo.redis.port=${NUXEO_REDIS_PORT:-6379}" >> "$NUXEO_CONF"
  echo "nuxeo.redis.prefix=${NUXEO_REDIS_PREFIX:-nuxeo:}" >> "$NUXEO_CONF"
  echo "nuxeo.work.queuing=${NUXEO_REDIS_WORK_QUEUING:-redis}" >> "$NUXEO_CONF"

  # Timeout and sizing configuration
  ## Credit: https://jira.nuxeo.com/browse/NXP-14923
  echo "nuxeo.redis.timeout=${NUXEO_REDIS_TIMEOUT:-4000}" >> "$NUXEO_CONF"
  echo "nuxeo.redis.maxTotal=${NUXEO_REDIS_MAXTOTAL:-32}" >> "$NUXEO_CONF"
  echo "nuxeo.redis.maxIdle=${NUXEO_REDIS_MAXIDLE:-16}" >> "$NUXEO_CONF"
  echo "nuxeo.redis.queuing=${NUXEO_REDIS_QUEUING:-redis}" >> "$NUXEO_CONF"
  echo "repository.clustering.invalidation=${NUXEO_REDIS_INVALIDATION:-pubsub}" >> "$NUXEO_CONF"

  perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,redis/g" "$NUXEO_CONF"
fi
