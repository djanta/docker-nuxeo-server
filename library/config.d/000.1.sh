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
if [ "$NUXEO_DEV_MODE" == "false" ] || [ -z "$NUXEO_DEV_MODE" ] && [ ! -f "$NUXEO_DATA/instance.clid" ] || \
  [ -z "$(cat $"NUXEO_DATA"/instance.clid)" ]; then
    echo "org.nuxeo.connect.server.reachable=${NUXEO_CONNECT_REACHABLE:-false}" >> "$NUXEO_CONF"
fi

  if [ -n "$NUXEO_AWS_S3_BUCKET" ]; then
    # Configuring S3 storage parameters
    echo "nuxeo.aws.accessKeyId=$NUXEO_AWS_S3_ACCESS_KEY" >> "$NUXEO_CONF"
    echo "nuxeo.aws.secretKey=$NUXEO_AWS_S3_SECRET_KEY" >> "$NUXEO_CONF"
    echo "nuxeo.aws.region=$NUXEO_AWS_S3_REGION" >> "$NUXEO_CONF"
    echo "nuxeo.s3storage.endpoint=${NUXEO_AWS_S3_ENDPOINT_PROTOCOL:-https}:\/\/${NUXEO_AWS_S3_ENDPOINT}" >> "$NUXEO_CONF"
    echo "nuxeo.s3storage.pathstyleaccess=$NUXEO_AWS_PATHSTYLE_ACCESS" >> "$NUXEO_CONF"
    echo "nuxeo.core.binarymanager=org.nuxeo.ecm.core.storage.sql.S3BinaryManager" >> "$NUXEO_CONF"
    echo "nuxeo.s3storage.bucket=$NUXEO_AWS_S3_BUCKET" >> "$NUXEO_CONF"
    echo "nuxeo.s3storage.digest=$NUXEO_AWS_S3_DIGEST" >> "$NUXEO_CONF"

    [[ -n "$NUXEO_AWS_S3_FOLDER" ]] && echo "nuxeo.s3storage.bucket_prefix=$NUXEO_AWS_S3_FOLDER" >> "$NUXEO_CONF"

    # Temporally deactivation till ES and S3 certificate issue is solve
    perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,aws/g" "$NUXEO_CONF"
  fi
