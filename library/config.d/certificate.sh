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

cacerts="${TRUSTED_STORE:-$JAVA_HOME/lib/security/cacerts}"
if [ -f "$cacerts" ]; then
  echo "Certificate trusted store found at -> $cacerts"
  if [ -n "$CONFIGD" ] && [ -d "$CONFIGD/certs" ]; then
    for file in "$CONFIGD/certs"/*; do
      case $file in
        *.cer | *.pem | *.der)
          #if [ -n "$DEBUG" ]; then keytool -v -printcert -file "$cacerts"; fi
          keytool -importcert -alias "${file%.*}" -keystore "$cacerts" \
            -file "$file" -storepass "${TRUSTED_PASSWORD:-changeit}"
          ;;
        *)
          #colored --red "$0: ignoring $file" ;;
      esac
    done
  fi
  if [ -n "$DEBUG" ]; then keytool -v -list -keystore "$cacerts" -storepass "${TRUSTED_PASSWORD:-changeit}"; fi
else
  echo "The given trusted store -> $cacerts, cannot be found."
fi
