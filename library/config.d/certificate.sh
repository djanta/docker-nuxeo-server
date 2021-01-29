#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# certificate.sh - This script will be use to provide our platform deployment architecture
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
# GNU General Public License at <http://www.gnu.org/licenses/> for more details.
# ---------------------------------------------------------------------------

# shellcheck disable=SC1090
# shellcheck disable=SC2116

source "/library/common.sh"
source "/library/log.sh"

TRUSTED_STORE=${JAVA_TRUSTED_STORE:-$(echo "$JAVA_HOME/lib/security/cacerts")}

# shellcheck disable=SC2045
if [ -f "$TRUSTED_STORE" ]; then
  log "Certificate trusted store found at -> $TRUSTED_STORE"

  echo "JAVA_OPTS=\$JAVA_OPTS -Djavax.net.ssl.trustStore=$JAVA_TRUSTED_STORE -Djavax.net.ssl.trustStoreType=${JAVA_TRUSTED_TYPE:-jks} -Djavax.net.ssl.trustStorePassword=${JAVA_TRUSTED_PWD:-changeit}" >> "$NUXEO_CONF"

  if [ -d "$CONFIGD/certs" ]; then
    for file in $(ls "$CONFIGD/certs"/); do
      case $file in
        *.cer | *.pem | *.der)
          debug "Importing certificate file from: $file, with alias: ${file%.*}"

          #if [ -n "$DEBUG" ]; then keytool -v -printcert -file "$TRUSTED_STORE"; fi
          keytool -importcert -alias "${file%.*}" \
            -keystore "$TRUSTED_STORE" -file "$file" \
            -storepass "${TRUSTED_PASSWORD:-changeit}"
          ;;
        *)
          warn "$0: ignoring $file" ;;
      esac
    done

    if [ -n "$DEBUG" ]; then
      keytool -v -list -keystore "$TRUSTED_STORE" -storepass "${TRUSTED_PASSWORD:-changeit}";
    fi
  fi
#else
#  warn "The given trusted store -> $TRUSTED_STORE, cannot be found."
fi
