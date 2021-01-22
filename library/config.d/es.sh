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

# shellcheck disable=SC1090
source "/library/common.sh"
source "/library/log.sh"

#TPL_NAME="elasticsearch"
#TPL_HOME=${NUXEO_TPL_HOME:-"./templates"}
#
if [ -n "$NUXEO_ES_HOST" ] && [ -f "$NUXEO_CONF" ]; then

  info "Configuring elasticsearch ..."

    REAL_ES_HOST="$NUXEO_ES_HOSTS"
    ES_URL="${NUXEO_ES_PROTOCOL:=https}:\/\/${REAL_ES_HOST}:${NUXEO_ES_PORT:-9200}"

    echo "Recomposed ES endpoint: ${ES_URL}"

    perl -p -i -e "s/^#?elasticsearch.addressList=.*$/elasticsearch.addressList=${ES_URL}/g" "$NUXEO_CONF"
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
    [ -n "$NUXEO_ES_PAGEPROVIDERS" ] && perl -p -i -e "s/^#?elasticsearch.override.pageproviders=.*$/elasticsearch.override.pageproviders=${NUXEO_ES_PAGEPROVIDERS}/g" "$NUXEO_CONF"

    if [ "$NUXEO_ES_PROTOCOL" == "https" ] && [ -f "$JAVA_TRUSTED_STORE" ]; then
      echo "elasticsearch.restClient.truststore.path=$JAVA_TRUSTED_STORE" >> "$NUXEO_CONF"
      echo "elasticsearch.restClient.truststore.password=${JAVA_TRUSTED_PWD:-changeit}" >> "$NUXEO_CONF"
      echo "elasticsearch.restClient.truststore.type=${JAVA_TRUSTED_TYPE:-jks}" >> "$NUXEO_CONF"
    fi

#  ## Make sure we crate the target "elasticsearch" directory anyway ...
#  mkdir -p ${TPL_HOME}/${TPL_NAME}
#
#  ## Edit the given nuxeo elasticsearch configuration
#  cat << EOF >> ${TPL_HOME}/${TPL_NAME}/nuxeo.defaults
#nuxeo.template.includes=default
#elasticsearch.target=.
#
###-----------------------------------------------------------------------------
### Elasticsearch configuration
###-----------------------------------------------------------------------------
### Enable or disable Elasticsearch integration, default is true.
#elasticsearch.enabled=${NUXEO_ES_ENABLE:-true}
#
### Choose the client protocol to access Elasticsearch, either RestClient
### or TransportClient
##elasticsearch.client=${NUXEO_ES_CLIENT:-RestClient}
#
### Address of the Elasticsearch cluster, comma separated list of nodes,
### node format for RestClient is http://server:9200
### node format for TransportClient is server:9300
### if empty Nuxeo uses an embedded Elasticsarch server, Not for production !
#elasticsearch.addressList=${NUXEO_ES_ADDRESSES:-http://localhost:9200}
#
### Name of the Elasticsearch index for the default document repository
#elasticsearch.indexName=${NUXEO_ES_INDEXNAME:-nuxeo}
#
### Number of replicas, default is 1
#elasticsearch.indexNumberOfReplicas=${NUXEO_ES_REPLICA_NUM:-0}
#
### Number of shards, default is 5
#elasticsearch.indexNumberOfShards=${NUXEO_ES_SHARDS_NUM:-1}
#
### Display Elasticsearch cluster and nodes information in admin center
### default is false (always true for embedded mode)
#elasticsearch.adminCenter.displayClusterInfo=${NUXEO_ES_CLUSTER_INFO:-true}
#
### Embedded elasticsearch server accept HTTP request on port 9200.
### Only requests from local machine are accepted.
#elasticsearch.httpEnabled=${NUXEO_ES_ENABLE_HTTP:-true}
#
### Comma separated list of CorePageProvider to supersede by Elasticsearch.
### The default is defined by nuxeo.defaults in template common-base
##elasticsearch.override.pageproviders=${NUXEO_ES_PAGE_PROVIDERS:-true}
#
### Enable or disable Elasticsearch as a backend for audit logs.
### Default is false in common-base template for upgrade purposes, to not break an existing instance.
### Set to true for activation on a new instance.
#audit.elasticsearch.enabled=${NUXEO_ELK_AUDIT_ENABLE:-true}
#
### Name of the Elasticsearch index for audit logs
#audit.elasticsearch.indexName=\${elasticsearch.indexName}-audit
#
### Name of the Elasticsearch index for the uid sequencer
#seqgen.elasticsearch.indexName=\${elasticsearch.indexName}-uidgen
#EOF
#
#  perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,elasticsearch/g" "$NUXEO_CONF"
#
##    if [ "$NUXEO_ES_FORCE_REINDEX" == "true"]; then
##      echo ""
##    fi
fi
