#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# docker.sh - This script will be use to provide our platform deployment dockerjs.sh architecture
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

#
# Adapted from NUXEO Original docker distribution distribution #
#

set -e

argv0=$(echo "$0" | sed -e 's,\\,/,g')
basedir=$(dirname "$(readlink "$0" || echo "$argv0")")

case "$(uname -s)" in
  Linux) basedir=$(dirname "$(readlink -f "$0" || echo "$argv0")");;
  *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

BASE=`dirname ${basedir}`
CWD=$(pwd)
USER_HOME="$(eval echo ~)"
SCRIPT_DIR=$(cd "$BASE/scripts/"; pwd)

echo "BASE Dir: ${BASE}"
echo "Current Working Dir: ${CWD}"
echo "User Home: ${USER_HOME}"
echo "Script Dir: ${SCRIPT_DIR}"

# Source the given script ...
FNC_SCRIPT="$SCRIPT_DIR/helper.sh"

if [ -f "$FNC_SCRIPT" ]; then
  echo "Docker utils script located as: $FNC_SCRIPT"
  #chmod +x "$FNC_SCRIPT" && source "$FNC_SCRIPT"
  source "$FNC_SCRIPT"
else
    echo "[Docker] [entrypoint] Following resource: [$FNC_SCRIPT] cannot be found ;("
fi

export DOCKER_HOST_IP=`netstat -nr | grep '^0\.0\.0\.0' | awk '{print $2}'`

#docker-machine ip default

# The given frontend container used to expose the current container such: (Apache2 Server, NGinx, etc ...)
[[ ! -z "$FRONTEND_CONTAINER" ]] && FRONTEND_NAME="$FRONTEND_CONTAINER" || FRONTEND_NAME=""

[[ ! -z "${MAX_FD//}" ]] && ULIMIT="$MAX_FD" || ULIMIT=63536
[[ ! -z "$LIVE_PROJECT" && -d "$LIVE_PROJECT" ]] && IS_DEBUG_JS="yes" || IS_DEBUG_JS="no"
[[ ! -z "$DEBUG_PORT" ]] && IS_DEBUG_JS="yes" || IS_DEBUG_JS="$IS_DEBUG_JS"

# Expositing the given publc interface
[[ ! -z "$PUBLIC_DNS_NAME" ]] && DNS_NAME="$PUBLIC_DNS_NAME" || DNS_NAME=$(self_hostname)
[[ ! -z "$PUBLIC_DNS_CONTAINER" ]] && DNS_CONTAINER=$(dockerip "$PUBLIC_DNS_CONTAINER") || DNS_CONTAINER=""
[[ ! -z "$PUBLIC_DNS_ENABLED" ]] && DNS_ENABLED="$PUBLIC_DNS_ENABLED" || DNS_ENABLED="yes"

# Pre Packaging configuration
[[ ! -z "$DJANTA_BUNDLE_PKG" ]] && DJANTA_BUNDLE="$DJANTA_BUNDLE_PKG" || DJANTA_BUNDLE=""
[[ ! -z "$NUXEO_UI_PKG" ]] && NUXEO_UI="$NUXEO_UI_PKG" || NUXEO_UI="nuxeo-web-ui nuxeo-dam nuxeo-drive"

echo "Public exposing interface: ${DNS_NAME}"
echo "Internal container ip: ${DOCKER_HOST_IP}"

#"djanta.nuxeo.public.dns.enabled=true"
#"djanta.nuxeo.public.dns.address=127.0.0.8"

NUXEO_PACKAGES="${NUXEO_PACKAGES} ${NUXEO_UI_PKG} ${DJANTA_BUNDLE_PKG}"

NUXEO_CONF=$NUXEO_HOME/bin/nuxeo.conf
NUXEO_DATA=${NUXEO_DATA:-/var/lib/nuxeo/data}
NUXEO_LOG=${NUXEO_LOG:-/var/log/nuxeo}

NONINTERACTIVE=${MODE_RELAX:-true}
DOCKER_LIB_SCRIPT=scripts/docker.sh

# Allow supporting arbitrary user id
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    sed /^nuxeo/d /etc/passwd > /tmp/passwd && cp /tmp/passwd /etc/passwd
    echo "${NUXEO_USER:-nuxeo}:x:$(id -u):0:${NUXEO_USER:-nuxeo} user:${NUXEO_HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

if [ "$1" = 'nuxeoctl' ]; then
  if [ ! -f $NUXEO_HOME/configured ]; then

    # PostgreSQL conf
    if [ -n "$NUXEO_DB_TYPE" ]; then

      if [ -z "$NUXEO_DB_HOST" ]; then
        echo "You have to setup a NUXEO_DB_HOST if not using default DB type"
        exit 1
      fi

      NUXEO_DB_HOST=${NUXEO_DB_HOST}
      NUXEO_DB_NAME=${NUXEO_DB_NAME:-nuxeo}
      NUXEO_DB_USER=${NUXEO_DB_USER:-nuxeo}
      NUXEO_DB_PASSWORD=${NUXEO_DB_PASSWORD:-nuxeo}

    	perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,${NUXEO_DB_TYPE}/g" $NUXEO_CONF
    	perl -p -i -e "s/^#?nuxeo.db.host=.*$/nuxeo.db.host=${NUXEO_DB_HOST}/g" $NUXEO_CONF
    	perl -p -i -e "s/^#?nuxeo.db.name=.*$/nuxeo.db.name=${NUXEO_DB_NAME}/g" $NUXEO_CONF
    	perl -p -i -e "s/^#?nuxeo.db.user=.*$/nuxeo.db.user=${NUXEO_DB_USER}/g" $NUXEO_CONF
    	perl -p -i -e "s/^#?nuxeo.db.password=.*$/nuxeo.db.password=${NUXEO_DB_PASSWORD}/g" $NUXEO_CONF
    fi

    if [ -n "$NUXEO_TEMPLATES" ]; then
      perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,${NUXEO_TEMPLATES}/g" $NUXEO_CONF
    fi

    # nuxeo.url
    [ -n "$NUXEO_URL" ] && echo "nuxeo.url=$NUXEO_URL" >> $NUXEO_CONF || echo "" > /dev/null

    if [ -n "$NUXEO_REDIS_HOST" ]; then
      nuxeo_tpl_redis
    fi

    if [ -n "$NUXEO_ES_HOSTS" ]; then
      nuxeo_tpl_elasticsearch
    fi

    if [ "$NUXEO_AUTOMATION_TRACE" = "true" ]; then
      echo "org.nuxeo.automation.trace=true" >> $NUXEO_CONF
    fi

    if [ "$NUXEO_DEV_MODE" = "true" ]; then
      echo "org.nuxeo.dev=true" >> $NUXEO_CONF
    fi

    if [ -n "$NUXEO_DDL_MODE" ]; then
      echo "nuxeo.vcs.ddlmode=${NUXEO_DDL_MODE}" >> $NUXEO_CONF
    fi

    if [ -n "$NUXEO_CUSTOM_PARAM" ]; then
      printf "%b\n" "$NUXEO_CUSTOM_PARAM" >> $NUXEO_CONF
    fi

    if [ -n "$NUXEO_BINARY_STORE" ]; then
      echo "repository.binary.store=$NUXEO_BINARY_STORE" >> $NUXEO_CONF
    fi

    if [ -n "$NUXEO_TRANSIENT_STORE" ]; then
      #removes transients stores if exists to allow symbolic link creation
      if [ -d $NUXEO_DATA/transientstores ]; then
          rm -rf $NUXEO_DATA/transientstores
      fi
      mkdir -p $NUXEO_DATA/transientstores
      ln -s $NUXEO_TRANSIENT_STORE $NUXEO_DATA/transientstores/default
    fi

    cat << EOF >> $NUXEO_CONF
nuxeo.log.dir=$NUXEO_LOG
nuxeo.pid.dir=/var/run/nuxeo
nuxeo.data.dir=$NUXEO_DATA
nuxeo.wizard.done=true
EOF

    if [ -f /nuxeo.conf ]; then
      cat /nuxeo.conf >> $NUXEO_CONF
    fi

    nuxeoctl mp-init

    touch $NUXEO_HOME/configured
  fi

  # instance.clid
  if [ -n "$NUXEO_CLID" ]; then
    # Replace --  by a carriage return
    NUXEO_CLID="${NUXEO_CLID/--/\\n}"
    printf "%b\n" "$NUXEO_CLID" >> $NUXEO_DATA/instance.clid
  fi

  for f in /docker-entrypoint-initnuxeo.d/*; do
    case "$f" in
      *.sh)  echo "$0: running $f"; . "$f" ;;
      *.zip) echo "$0: installing Nuxeo package $f"; nuxeoctl mp-install $f --accept=true ;;
      *.clid) echo "$0: copying clid to $NUXEO_DATA"; cp $f $NUXEO_DATA/ ;;
      *)     echo "$0: ignoring $f" ;;
    esac
    echo
  done

  ## Executed at each start
  if [ -n "$NUXEO_CLID"  ] && [ ${NUXEO_INSTALL_HOTFIX:='true'} == "true" ]; then
      nuxeoctl mp-hotfix --accept=true
  fi

  # Install packages if exist
  if [ -n "$NUXEO_PACKAGES" ]; then
    echo ""
    # nuxeoctl mp-install $NUXEO_PACKAGES --relax=false --accept=true
#    nuxeoctl mp-install "${NUXEO_PACKAGES}" --relax=${NONINTERACTIVE:-true} --accept=true
  fi

  # Activate the hard or soft remote file sync for dev model only
  if [ -n "$LIVE_SYNC" ]; then
    echo "FIXME : Activate the HOT File sync & hot reload mode "
  fi

  if [ "$2" = "console" ]; then
    exec nuxeoctl console
  else
    exec "$@"
  fi
fi

## Main entry point ...
exec "$@"
