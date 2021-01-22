#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# s3.sh - This script will be use to provide our platform deployment architecture
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

# shellcheck disable=SC2034
# shellcheck disable=SC2199
# shellcheck disable=SC2129

if [ -n "$NUXEO_AWS_S3_BUCKET" ]; then

  cat << EOF >> "$NUXEO_CONF"
##-----------------------------------------------------------------------------
## Auto generated configurated at runtime to inject S3 configuration. TO BE MODIFIED WITH CAUSION
## Date: $(date '+%Y-%m-%d %T.%3N')
## Source: $0
##-----------------------------------------------------------------------------
EOF
  echo "nuxeo.aws.accessKeyId=$NUXEO_AWS_S3_ACCESS_KEY" >> "$NUXEO_CONF"
  echo "nuxeo.aws.secretKey=$NUXEO_AWS_S3_SECRET_KEY" >> "$NUXEO_CONF"
  echo "nuxeo.aws.region=$NUXEO_AWS_S3_REGION" >> "$NUXEO_CONF"
  echo "nuxeo.s3storage.endpoint=${NUXEO_AWS_S3_ENDPOINT_PROTOCOL:-https}:\/\/${NUXEO_AWS_S3_ENDPOINT}" >> "$NUXEO_CONF"
  echo "nuxeo.s3storage.pathstyleaccess=${NUXEO_AWS_PATHSTYLE_ACCESS:-false}" >> "$NUXEO_CONF"
  echo "nuxeo.s3storage.bucket=$NUXEO_AWS_S3_BUCKET" >> "$NUXEO_CONF"
  echo "nuxeo.s3storage.digest=${NUXEO_AWS_S3_DIGEST:-"SHA-1"}" >> "$NUXEO_CONF"
  echo "nuxeo.core.binarymanager=${NUXEO_S3_BINARYMANAGER:-"org.nuxeo.ecm.core.storage.sql.S3BinaryManager"}" >> "$NUXEO_CONF"

  if [ -n "$NUXEO_AWS_S3_FOLDER" ]; then echo "nuxeo.s3storage.bucket_prefix=$NUXEO_AWS_S3_FOLDER" >> "$NUXEO_CONF"; fi

  # Temporally deactivation till ES and S3 certificate issue is solve
  perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,aws/g" "$NUXEO_CONF"
fi
