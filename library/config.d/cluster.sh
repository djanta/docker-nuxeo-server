#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# properties.sh - This script will be use to provide our platform deployment architecture
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

#set -ex

if [ "$NUXEO_DEV_MODE" == "true" ]; then perl -p -i -e "s/^#?org.nuxeo.dev=.*$/org.nuxeo.dev=${NUXEO_DEV_MODE}/g" "$NUXEO_CONF"; fi
if [ -n "$VIRTUAL_HOST" ]; then perl -p -i -e "s/^#?nuxeo.virtual.host=.*$/nuxeo.virtual.host=${VIRTUAL_HOST}/g" "$NUXEO_CONF"; fi
if [ -n "$LOOPBACK_URL" ]; then perl -p -i -e "s/^#?nuxeo.loopback.url=.*$/nuxeo.loopback.url=${LOOPBACK_URL}/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_AUTOMATION_TRACE" ]; then perl -p -i -e "s/^#?org.nuxeo.automation.trace=.*$/org.nuxeo.automation.trace=$NUXEO_AUTOMATION_TRACE/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_DDL_MODE" ]; then perl -p -i -e "s/^#?nuxeo.vcs.ddlmode=.*$/nuxeo.vcs.ddlmode=${NUXEO_DDL_MODE}/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_BINARY_STORE" ]; then perl -p -i -e "s/^#?repository.binary.store=.*$/repository.binary.store=${NUXEO_BINARY_STORE}/g" "$NUXEO_CONF"; fi
if [ -n "$NUXEO_TEMPLATES" ]; then perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,${NUXEO_TEMPLATES}/g" "$NUXEO_CONF"; fi
