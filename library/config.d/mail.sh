#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# email.sh - This script will be use to provide our platform deployment architecture
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

if [ -n "$NUXEO_EMAIL_TRANSPORT_HOST" ] || [ -n "$NUXEO_EMAIL_STORE_HOST" ]; then

  perl -p -i -e "s/^#?mail.from=.*$/mail.from=${NUXEO_EMAIL_FROM:-donotreply@local.host}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?mail.debug=.*$/mail.debug=${NUXEO_EMAIL_DEBUG:-true}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?nuxeo.notification.eMailSubjectPrefix=.*$/nuxeo.notification.eMailSubjectPrefix=${NUXEO_EMAIL_PREFIX:-[NUXEO]::}/g" "$NUXEO_CONF"
  perl -p -i -e "s/^#?nuxeo.notification.eMailSigner=.*$/nuxeo.notification.eMailSigner=${NUXEO_EMAIL_SIGNER:-Nuxeo Platform}/g" "$NUXEO_CONF"

  ## Configure email store.
  if [ -n "$NUXEO_EMAIL_TRANSPORT_HOST" ]; then
    perl -p -i -e "s/^#?mail.transport.host=.*$/mail.transport.host=${NUXEO_EMAIL_TRANSPORT_HOST}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.transport.port=.*$/mail.transport.port=${NUXEO_EMAIL_TRANSPORT_PORT:-25}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.transport.usetls=.*$/mail.transport.usetls=${NUXEO_EMAIL_TRANSPORT_TLS:-false}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.transport.auth=.*$/mail.transport.auth=${NUXEO_EMAIL_TRANSPORT_AUTH:-true}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.transport.protocol=.*$/mail.transport.protocol=${NUXEO_EMAIL_TRANSPORT_PROTOCOL:-smtp}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.transport.user=.*$/mail.transport.user=${NUXEO_EMAIL_TRANSPORT_USER}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.transport.password=.*$/mail.transport.password=${NUXEO_EMAIL_TRANSPORT_PASSWORD}/g" "$NUXEO_CONF"
  fi

  ## Configure email store.
  if [ -n "$NUXEO_EMAIL_STORE_HOST" ]; then
    perl -p -i -e "s/^#?mail.store.host=.*$/mail.store.host=${NUXEO_EMAIL_STORE_HOST}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.store.port=.*$/mail.store.port=${NUXEO_EMAIL_STORE_HOST}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.store.protocol=.*$/mail.store.protocol=${NUXEO_EMAIL_STORE_PROTOCOL:-pop3}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.store.user=.*$/mail.store.user=${NUXEO_EMAIL_STORE_USER}/g" "$NUXEO_CONF"
    perl -p -i -e "s/^#?mail.store.password=.*$/mail.store.password=${NUXEO_EMAIL_STORE_PASSWORD}/g" "$NUXEO_CONF"
  fi
fi
