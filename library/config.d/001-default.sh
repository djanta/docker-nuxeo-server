#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# 001-default.sh - This script will be use to provide our platform deployment architecture
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

#########
# Credit: https://doc.nuxeo.com/nxdoc/configuration-parameters-index-nuxeoconf/
#########

if [ "$NUXEO_DEV_MODE" == "true" ]; then perl -p -i -e "s/^#?org.nuxeo.dev=.*$/org.nuxeo.dev=${NUXEO_DEV_MODE}/g" "$NUXEO_CONF"; fi
if [ -n "$VIRTUAL_HOST" ]; then perl -p -i -e "s/^#?nuxeo.virtual.host=.*$/nuxeo.virtual.host=${VIRTUAL_HOST}/g" "$NUXEO_CONF"; fi
if [ -n "$LOOPBACK_URL" ]; then perl -p -i -e "s/^#?nuxeo.loopback.url=.*$/nuxeo.loopback.url=${LOOPBACK_URL}/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_AUTOMATION_TRACE" ]; then perl -p -i -e "s/^#?org.nuxeo.automation.trace=.*$/org.nuxeo.automation.trace=$NUXEO_AUTOMATION_TRACE/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_DDL_MODE" ]; then perl -p -i -e "s/^#?nuxeo.vcs.ddlmode=.*$/nuxeo.vcs.ddlmode=${NUXEO_DDL_MODE}/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_BINARY_STORE" ]; then perl -p -i -e "s/^#?repository.binary.store=.*$/repository.binary.store=${NUXEO_BINARY_STORE}/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_TEMPLATES" ]; then perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,${NUXEO_TEMPLATES}/g" "$NUXEO_CONF"; fi

##
# Desable contacting nuxeo connect server
##
#if [ "$NUXEO_DEV_MODE" == "false" ] || [ -z "$NUXEO_DEV_MODE" ] && [ ! -f "$NUXEO_DATA/instance.clid" ] || \
#  [ -z "$(cat $"NUXEO_DATA"/instance.clid)" ]; then
#    echo "org.nuxeo.connect.server.reachable=${NUXEO_CONNECT_OFFILINE:-false}" >> "$NUXEO_CONF"
#fi

if [ -n "$NUXEO_CONNECT_OFFILINE" ]; then echo "org.nuxeo.connect.server.reachable=false" >> "$NUXEO_CONF"; fi

## Do not use Redis for directory cache
#[ -n "$NUXEO_CACHE_TYPE" ] && echo "nuxeo.cache.type=$NUXEO_CACHE_TYPE" >> "$NUXEO_CONF"
#[ -n "$NUXEO_CACHE_MAXSIZE" ] && echo "nuxeo.cache.maxsize=$NUXEO_CACHE_MAXSIZE" >> "$NUXEO_CONF"
#[ -n "$NUXEO_CACHE_TTL" ] && echo "nuxeo.cache.ttl=$NUXEO_CACHE_TTL" >> "$NUXEO_CONF"
#[ -n "$NUXEO_CACHE_CONCURRENT_LEVEL" ] && echo "nuxeo.cache.concurrencylevel=$NUXEO_CACHE_CONCURRENT_LEVEL" >> "$NUXEO_CONF"

# Disabling Java SSL Validation
if [ -z "$JAVA_SSL_VALIDATION" ] || [ "$JAVA_SSL_VALIDATION" = "true" ] ; then
  #perl -p -i -e "s/^#?(JAVA_OPTS=.*$)/\1, -Dcom.sun.net.ssl.checkRevocation=false/g" $NUXEO_CONF
  echo "JAVA_OPTS=\$JAVA_OPTS -Dcom.sun.net.ssl.checkRevocation=false" >> "$NUXEO_CONF"
fi

if [ -f "$JAVA_TRUSTED_STORE" ]; then
  echo "JAVA_OPTS=\$JAVA_OPTS -Djavax.net.ssl.trustStore=$JAVA_TRUSTED_STORE -Djavax.net.ssl.trustStoreType=${JAVA_TRUSTED_TYPE:-jks} -Djavax.net.ssl.trustStorePassword=${JAVA_TRUSTED_PWD:-changeit}" >> "$NUXEO_CONF"
  #echo "JAVA_OPTS=\$JAVA_OPTS -Djavax.net.debug=ssl:record -Djavax.net.debug=ssl:handshake" >> "$NUXEO_CONF"
fi

# Enabling HTTPS & SSL debu omly in nuxeo dev mode ...
#[ "$NUXEO_DEV_MODE" == "true" ] && echo "JAVA_OPTS=\$JAVA_OPTS -Djavax.net.debug=ssl:record -Djavax.net.debug=ssl:handshake" >> "$NUXEO_CONF"

# FIXME: Will be enabled when we'll move all the packages offline
#echo "org.nuxeo.connect.server.reachable=false" >> "$NUXEO_CONF"

if [ "$NUXEO_CLUSTERING_ENABLE" == "true" ]; then
  # FIXME: These following two line only available from nuxeo 11.x
  #echo "nuxeo.cluster.enabled=${NUXEO_CLUSTERING_ENABLE}" >> "$NUXEO_CONF"
  #echo "nuxeo.cluster.nodeid=${NUXEO_CLUSTERING_PREFIX:-""}${HOSTNAME}" >> "$NUXEO_CONF"

  # FIXME: Comment these when migrate to 11.x
  echo "repository.clustering.enabled=${NUXEO_CLUSTERING_ENABLE}" >> "$NUXEO_CONF"
  echo "repository.clustering.id=${NUXEO_CLUSTERING_PREFIX:-""}${HOSTNAME}" >> "$NUXEO_CONF"
fi
#
#  # Nuxeo context path setting
#  #perl -p -i -e "s/^#?org.nuxeo.ecm.contextPath=.*$/org.nuxeo.ecm.contextPath=/${NUXEO_CONTEXT_PATH:-nuxeo}/g" "$NUXEO_CONF"
#
#  # Misc Queue worker thread resizing
#  [ -n "$NUXEO_WORKER_DEFAULT_THREADS" ] && echo "nuxeo.worker.default.threads=$NUXEO_WORKER_DEFAULT_THREADS" >> "$NUXEO_CONF"
#  [ -n "$NUXEO_WORKER_PICTURE_THREADS" ] && echo "nuxeo.worker.picture.threads=$NUXEO_WORKER_PICTURE_THREADS" >> "$NUXEO_CONF"
#  [ -n "$NUXEO_WORKER_VIDEO_THREADS" ] && echo "nuxeo.worker.video.threads=$NUXEO_WORKER_VIDEO_THREADS" >> "$NUXEO_CONF"
#  [ -n "$NUXEO_WORKER_ELASTICSEARCH_THREADS" ] && echo "nuxeo.worker.elasticsearch.threads=$NUXEO_WORKER_ELASTICSEARCH_THREADS" >> "$NUXEO_CONF"
#
#  ## Tomcat configuration
#  [ -n "$NUXEO_HTTP_UPLOAD_TIMEOUT" ] && echo "nuxeo.server.http.connectionUploadTimeout=$NUXEO_HTTP_UPLOAD_TIMEOUT" >> "$NUXEO_CONF"
#  [ -n "$NUXEO_HTTP_MAX_THREAD" ] && echo "nuxeo.server.http.maxThreads=$NUXEO_HTTP_MAX_THREAD" >> "$NUXEO_CONF"
#  [ -n "$NUXEO_HTTP_ACCEPTCOUNT" ] && echo "nuxeo.server.http.acceptCount=$NUXEO_HTTP_ACCEPTCOUNT" >> "$NUXEO_CONF"
