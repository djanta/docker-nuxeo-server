#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# es.sh - This script will be use to provide our platform deployment architecture
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
# GNU General Public License at <http://www.gnu.org/licenses/> for more details.
# ---------------------------------------------------------------------------

#file="https://es.djanta.io:9200"
#echo "${file##*://}"

#ES_WITHOUT_PROTOCOL=${file##*://}
#NUXEO_ES_PROTOCOL=${NUXEO_ES_PROTOCOL:-$(echo "${file%:*}")}
#NUXEO_ES_PORT=${NUXEO_ES_PORT:-$(echo "${file##*:}")}
#echo "NUXEO_ES_PROTOCOL: $NUXEO_ES_PROTOCOL"
#echo "NUXEO_ES_PORT: $NUXEO_ES_PORT"
#echo "ES_WITHOUT_PROTOCOL: $ES_WITHOUT_PROTOCOL"

# shellcheck disable=SC1090
# shellcheck disable=SC2129

source "/library/common.sh"
source "/library/log.sh"

NUXEO_ES_PAGEPROVIDERS=${NUXEO_ES_PAGEPROVIDERS:-"default_search,default_document_suggestion,DEFAULT_DOCUMENT_SUGGESTION,advanced_document_content,domain_documents,expired_search,default_trash_search,REST_API_SEARCH_ADAPTER,all_collections"}
NUXEO_ES_ENABLED=${NUXEO_ES_ENABLED:-false}

if [ -n "$NUXEO_ES_HOST" ] && [ "$NUXEO_ES_ENABLED" == "true" ]; then
  info "Configuring elasticsearch ..."

#  NUXEO_ES_PROTOCOL=${NUXEO_ES_PROTOCOL:-$(echo "${NUXEO_ES_HOST%:*}")}
#  NUXEO_ES_PORT=${NUXEO_ES_PORT:-$(echo "${NUXEO_ES_HOST##*}")}
#  REAL_ES_HOST="$NUXEO_ES_HOSTS"
#  ES_URL="${NUXEO_ES_PROTOCOL:=https}:\/\/${REAL_ES_HOST}:${NUXEO_ES_PORT:-9200}"

  cat << EOF >> "$NUXEO_CONF"
##-----------------------------------------------------------------------------
## Auto generated configurated at runtime to inject Elasticsarch configuration. TO BE MODIFIED WITH CAUTION
## Date: $(date '+%Y-%m-%d %T.%3N')
## Source: $0
##-----------------------------------------------------------------------------
EOF
  perl -p -i -e "s/^#?elasticsearch.addressList=.*$/elasticsearch.addressList=${NUXEO_ES_HOST}${NUXEO_ES_PORT:-9200}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?elasticsearch.clusterName=.*$/elasticsearch.clusterName=${NUXEO_ES_CLUSTER_NAME:-elasticsearch}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?elasticsearch.indexName=.*$/elasticsearch.indexName=${NUXEO_ES_INDEX_NAME:-nuxeo}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?elasticsearch.indexNumberOfReplicas=.*$/elasticsearch.indexNumberOfReplicas=${NUXEO_ES_REPLICAS:-1}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?elasticsearch.indexNumberOfShards=.*$/elasticsearch.indexNumberOfShards=${NUXEO_ES_SHARDS:-5}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?elasticsearch.enabled=.*$/elasticsearch.enabled=${NUXEO_ES_ENABLED:-true}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?elasticsearch.client=.*$/elasticsearch.client=${NUXEO_ES_CLIENT:-RestClient}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?audit.elasticsearch.enabled=.*$/audit.elasticsearch.enabled=${NUXEO_ES_AUDIT_ENABLED:-false}/g" "$NUXEO_CONF"

  perl -p -i -e "s/^#?elasticsearch.adminCenter.displayClusterInfo=.*$/elasticsearch.adminCenter.displayClusterInfo=${NUXEO_ES_ADMIN_INFO:-true}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?audit.elasticsearch.indexName=.*$/audit.elasticsearch.indexName=${NUXEO_ES_INDEX_NAME:-nuxeo}-audit/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?seqgen.elasticsearch.indexName=.*$/seqgen.elasticsearch.indexName=${NUXEO_ES_INDEX_NAME:-nuxeo}-uidgen/g" "$NUXEO_CONF"

  echo "elasticsearch.restClient.username=$NUXEO_ES_USERNAME" >> "$NUXEO_CONF"
  echo "elasticsearch.restClient.password=$NUXEO_ES_PASSWORD" >> "$NUXEO_CONF"

  echo "elasticsearch.index.translog.durability=${NUXEO_ES_LOG_DURABILITY:-async}" >> "$NUXEO_CONF"
  echo "elasticsearch.indexing.maxThreads=${NUXEO_ES_INDEXING_THREADS:-6}" >> "$NUXEO_CONF"
  echo "elasticsearch.reindex.bucketReadSize=${NUXEO_ES_REINDEX_BKRSIZE:-1000}" >> "$NUXEO_CONF"
  echo "elasticsearch.reindex.bucketWriteSize=${NUXEO_ES_REINDEX_BKRWSIZE:-200}" >> "$NUXEO_CONF"

  # Force the default page providers to use Elasticsearch
  if [ -n "$NUXEO_ES_PAGEPROVIDERS" ]; then
    perl -p -i -e "s/^#?elasticsearch.override.pageproviders=.*$/elasticsearch.override.pageproviders=${NUXEO_ES_PAGEPROVIDERS}/g" "$NUXEO_CONF"
  fi

  TRUSTED_STORE=${ES_TRUSTED_STORE:-$(echo ${JAVA_TRUSTED_STORE:-""})}
  if [ "$NUXEO_ES_PROTOCOL" == "https" ] && [ -f "$TRUSTED_STORE" ]; then
    echo "elasticsearch.restClient.truststore.path=$TRUSTED_STORE" >> "$NUXEO_CONF"
    echo "elasticsearch.restClient.truststore.password=${ES_TRUSTSTORE_PWD:-$(echo ${JAVA_TRUSTED_PWD:-"changeit"})}" >> "$NUXEO_CONF"
    echo "elasticsearch.restClient.truststore.type=${ES_TRUSTSTORE_TYPE:-$(echo ${JAVA_TRUSTED_TYPE:-"jks"})}" >> "$NUXEO_CONF"
#    echo "elasticsearch.restClient.truststore.password=${JAVA_TRUSTED_PWD:-changeit}" >> "$NUXEO_CONF"
#    echo "elasticsearch.restClient.truststore.type=${JAVA_TRUSTED_TYPE:-jks}" >> "$NUXEO_CONF"
  fi
fi
