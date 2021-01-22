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
  echo "nuxeo.redis.maxIdle=${NUXEO_REDIS_MAX_IDLE:-8}" >> "$NUXEO_CONF"
  echo "nuxeo.redis.maxTotal=${NUXEO_REDIS_MAX_TOTAL:-16}" >> "$NUXEO_CONF"
  echo "nuxeo.redis.timeout=${NUXEO_REDIS_TIMEOUT-2000}" >> "$NUXEO_CONF"

    echo "nuxeo.redis.enabled=true" >> "$NUXEO_CONF"
    echo "nuxeo.redis.host=${NUXEO_REDIS_HOST}" >> "$NUXEO_CONF"
    echo "nuxeo.redis.port=${NUXEO_REDIS_PORT:-6379}" >> "$NUXEO_CONF"
    echo "nuxeo.redis.password=${NUXEO_REDIS_PASSWORD}" >> "$NUXEO_CONF"
    echo "nuxeo.redis.prefix=${NUXEO_REDIS_PREFIX:-nuxeo:}" >> "$NUXEO_CONF"

    ## Credit: https://jira.nuxeo.com/browse/NXP-14923
    echo "nuxeo.redis.timeout=${NUXEO_REDIS_TIMEOUT:-4000}" >> "$NUXEO_CONF"
    echo "nuxeo.redis.maxTotal=${NUXEO_REDIS_MAXTOTAL:-32}" >> "$NUXEO_CONF"
    echo "nuxeo.redis.maxIdle=${NUXEO_REDIS_MAXIDLE:-16}" >> "$NUXEO_CONF"
    echo "nuxeo.redis.queuing=${NUXEO_REDIS_QUEUING:-redis}" >> "$NUXEO_CONF"
    echo "repository.clustering.invalidation=${NUXEO_REDIS_INVALIDATION:-pubsub}" >> "$NUXEO_CONF"
    perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,redis/g" "$NUXEO_CONF"


#    ## Make sure we crate the target "redis" directory anyway ...
#    mkdir -p "$NUXEO_TPL_HOME"/redis
#
#    ## Edit the given nuxeo redis configuration
#    cat << EOF >> "$NUXEO_TPL_HOME"/redis/nuxeo.defaults
#nuxeo.template.includes=default
#redis.target=.
#
#
## Redis is automatically enabled when this template is used
#nuxeo.redis.prefix=${NUXEO_REDIS_PREFIX:=nuxeo:}
#nuxeo.redis.password=${NUXEO_REDIS_PASSWORD}
#nuxeo.redis.ssl=${NUXEO_REDIS_SSL:=false}
#nuxeo.redis.truststore.path=${NUXEO_REDIS_TRUSTSTORE_PATH}
#nuxeo.redis.truststore.password=${NUXEO_REDIS_TRUSTORE_PASSWORD}
#nuxeo.redis.truststore.type=${NUXEO_REDIS_TRUSTORE_TYPE}
#nuxeo.redis.keystore.path=${NUXEO_REDIS_KEYSTORE_PATH}
#nuxeo.redis.keystore.password=${NUXEO_REDIS_KEYSTORE_PASSWORD}
#nuxeo.redis.keystore.type=${NUXEO_REDIS_KEYSTORE_TYPE}
#nuxeo.redis.database=${NUXEO_REDIS_DATABASE:=0}
#nuxeo.redis.timeout=${NUXEO_REDIS_TIMEOUT:=2000}
#nuxeo.redis.maxTotal=${NUXEO_REDIS_MAX_TOTAL:=16}
#nuxeo.redis.maxIdle=${NUXEO_REDIS_MAX_IDLE:=8}
#
#nuxeo.redis.ha.enabled=${NUXEO_REDIS_HA_ENABLED:=false}
#nuxeo.redis.ha.master=${NUXEO_REDIS_HA_MASTER:=mymaster}
#nuxeo.redis.ha.hosts=${NUXEO_REDIS_HA_HOST:=localhost}
#nuxeo.redis.ha.timeout=${NUXEO_REDIS_HA_TIMEOUT:=300}
#nuxeo.redis.ha.port=${NUXEO_REDIS_HA_PORT:=26379}
#
#nuxeo.pubsub.provider=${NUXEO_REDIS_PUBSUB_PROVIDER:=redis}
#nuxeo.keyvalue.provider=${NUXEO_REDIS_KEYVALUE_PROVIDER:=redis}
#nuxeo.work.queuing=${NUXEO_REDIS_WORK_QUEUING:=redis}
#nuxeo.lock.manager=${NUXEO_REDIS_LOCK_MANAGER:=redis}
#
## by default use the KeyValueBlobTransientStore from the common template
##nuxeo.transientstore.provider=redis
#EOF

  perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,redis/g" "$NUXEO_CONF"
fi
