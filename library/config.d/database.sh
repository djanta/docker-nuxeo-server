#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# database.sh - This script will be use to provide our platform deployment architecture
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

if [ -n "$NUXEO_DB_TYPE" ] && [ -n "$NUXEO_DB_HOST" ]; then

  perl -p -i -e "s/^#?nuxeo.db.host=.*$/nuxeo.db.host=${NUXEO_DB_HOST}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?nuxeo.db.name=.*$/nuxeo.db.name=${NUXEO_DB_NAME:-nuxeo}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?nuxeo.db.user=.*$/nuxeo.db.user=${NUXEO_DB_USER:-nuxeo}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?nuxeo.db.password=.*$/nuxeo.db.password=${NUXEO_DB_PASSWORD:-nuxeo}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?nuxeo.db.port=.*$/nuxeo.db.port=${NUXEO_DB_PORT}/g" "$NUXEO_CONF"

  # append the database type as template
  perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,${NUXEO_DB_TYPE}/g" "$NUXEO_CONF"

#  else
#    #error_exit "You have to setup a NUXEO_DB_HOST if not using default DB type"
#    # using default h2 type as template
#    perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,h2/g" "$NUXEO_CONF"
fi
