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

NUXEO_PRODUCT_VERSION=${NUXEO_PRODUCT_VERSION:-$(echo ${NUXEO_VERSION:-""})}
if [ "$NUXEO_DEV_MODE" == "true" ]; then NUXEO_PROD_MODE=false; fi

perl -p -i -e "s/^#?org.nuxeo.dev=.*$/org.nuxeo.dev=${NUXEO_DEV_MODE:-true}/g" "$NUXEO_CONF"
echo "org.nuxeo.prod=${NUXEO_PROD_MODE:-false}" >> "$NUXEO_CONF"

# Generic configuration setup
echo "org.nuxeo.connect.server.reachable=${NUXEO_CONNECT_OFFILINE:-false}" >> "$NUXEO_CONF"
echo "org.nuxeo.ecm.product.name=${NUXEO_PRODUCT_NAME:-"DJANTA.IO Customized Nuxeo Server"}" >> "$NUXEO_CONF"
echo "org.nuxeo.ecm.instance.description=${NUXEO_SERVER_DESC:-"DJANTA.IO Customized Nuxeo Server"}" >> "$NUXEO_CONF"
echo "org.nuxeo.ecm.instance.name=${NUXEO_SERVER_NAME:-"DJANTA.IO Nuxeo Server"}" >> "$NUXEO_CONF"
echo "org.nuxeo.ecm.product.version=${NUXEO_PRODUCT_VERSION:-$(echo ${NUXEO_VERSION:-""})}" >> "$NUXEO_CONF"

#if [ "$NUXEO_DEV_MODE" == "true" ]; then perl -p -i -e "s/^#?org.nuxeo.dev=.*$/org.nuxeo.dev=${NUXEO_DEV_MODE}/g" "$NUXEO_CONF"; fi
if [ -n "$VIRTUAL_HOST" ]; then perl -p -i -e "s/^#?nuxeo.virtual.host=.*$/nuxeo.virtual.host=${VIRTUAL_HOST}/g" "$NUXEO_CONF"; fi
if [ -n "$LOOPBACK_URL" ]; then perl -p -i -e "s/^#?nuxeo.loopback.url=.*$/nuxeo.loopback.url=${LOOPBACK_URL}/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_DDL_MODE" ]; then perl -p -i -e "s/^#?nuxeo.vcs.ddlmode=.*$/nuxeo.vcs.ddlmode=${NUXEO_DDL_MODE}/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_BINARY_STORE" ]; then perl -p -i -e "s/^#?repository.binary.store=.*$/repository.binary.store=${NUXEO_BINARY_STORE}/g" "$NUXEO_CONF"; fi

perl -p -i -e "s/^#?org.nuxeo.automation.trace=.*$/org.nuxeo.automation.trace=${NUXEO_AUTOMATION_TRACE:-$(echo ${DEBUG:-false})}/g" "$NUXEO_CONF"

## Nuxeo context path setting
perl -p -i -e "s/^#?org.nuxeo.ecm.contextPath=.*$/org.nuxeo.ecm.contextPath=\/${NUXEO_CONTEXT_PATH:-nuxeo}/g" "$NUXEO_CONF"

# Disabling Java SSL Validation
if [ -z "$JAVA_SSL_VALIDATION" ] || [ "$JAVA_SSL_VALIDATION" = "true" ] ; then
  #perl -p -i -e "s/^#?(JAVA_OPTS=.*$)/\1, -Dcom.sun.net.ssl.checkRevocation=false/g" $NUXEO_CONF
  echo "JAVA_OPTS=\$JAVA_OPTS -Dcom.sun.net.ssl.checkRevocation=false" >> "$NUXEO_CONF"
fi
