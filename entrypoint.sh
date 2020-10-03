#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# docker-entrypoint.sh - This script will be use to provide our platform deployment docker-entrypoint.sh architecture
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

set -e

argv0=$(echo "$0" | sed -e 's,\\,/,g')
basedir=$(dirname "$(readlink "$0" || echo "$argv0")")

case "$(uname -s)" in
  Linux) basedir=$(dirname "$(readlink -f "$0" || echo "$argv0")");;
  *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

BASE=`dirname ${basedir}`
#LIB_CONFIGD=$(cd "$BASE"library/config.d/; pwd)
#LIBRARY=$(cd "$BASE"library/common/; pwd)
#
## Source the given script ...
#HELPER=$LIBRARY/helper.sh
#COMMON=$LIBRARY/common.sh
#WATCHER=$LIBRARY/watcher.sh
#
## shellcheck disable=SC1090
#[[ -f "$HELPER" ]] && source "$HELPER" && source "${COMMON}" || \
#  echo "[entrypoint] Following resource: [$HELPER] cannot be found ;("
#
#source "$LIBRARY"/log.sh

all=("common.sh" "helper.sh" "log.sh")
for file in "${all[@]}"; do source "${SHARED_LIB}/${file}"; done

#regex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
#url='http://www.google.com/test/link.php'
#if [[ $url =~ $regex ]]
#then
#    echo "$url IS valid"
#else
#    echo "$url IS NOT valid"
#fi

## Fix syntax: https://github.com /koalaman/shellcheck/wiki/SC2236
[[ -n "${MAX_FD//}" ]] && ULIMIT="${MAX_FD}" || ULIMIT=63536

happy "Max ULIMIT: ${ULIMIT}"

# Allow supporting arbitrary user id
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    sed /^nuxeo/d /etc/passwd > /tmp/passwd && cp /tmp/passwd /etc/passwd
    echo "${NUXEO_USER:-nuxeo}:x:$(id -u):0:${NUXEO_USER:-nuxeo} user:${NUXEO_HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

[ -f /var/run/docker.sock ] && warn "You're now running docker in docker"

if [ "$1" = 'nuxeoctl' ]; then

  # Reset an existing "$NUXEO_HOME"/configured
  [ -n "$DRY_MODE" ] && [ "$DRY_MODE" = "true" ] && log "Reset and clean up any existing configuration"

  [ -n "$FORCE_RECREATE" ] && [ ! -f "$NUXEO_HOME"/configured ]  \
    && warn "Clean up and recreate the deployment configuration" \
    || log "No force recreation"

  # Re-configure nuxeo environment ...
  if [ ! -f "$NUXEO_HOME"/configured ]; then
    mergeable=("$CONFIG_D")
    TMPD="/tmp/$(date -u +'%Y%m%dT_%H%M%SZ')"

    mkdir -p "$TMPD"

    [ -z "$NUXEO_CONNECT_TOKEN" ] && warn "Missing NUXEO_CONNECT_TOKEN variable."
    [ -z "$NUXEO_CONNECT_USERID" ] && warn "Missing NUXEO_CONNECT_USERID variable."

    [ -n "$DEPLOY_ENV" ] && [ -d "$CONFIG_D/$DEPLOY_ENV" ] && mergeable+=("$CONFIG_D/$DEPLOY_ENV")
    for dir in "${mergeable[@]}"; do
      warn "Scanning ($dir) directory for deploy."
      [ -f "$dir/nuxeo.conf" ] && warn "Overrride nuxeo.conf @ $dir/nuxeo.conf" && cat "$dir/nuxeo.conf" > "$NUXEO_CONF"
      [ -f "$dir/license" ] && cat "$dir/license" >  "$NUXEO_DATA/instance.clid" || echo "" > /dev/null 2>&1
      [ -d "$dir/log" ] && mv -Rv "$dir/log/*" "$NUXEO_HOME/lib/" || log "Unchanged log configuration"
      [ -d "$dir/config" ] && mv -Rv "$dir/config/*" "$NUXEO_HOME/nxserver/config/" || echo "" > /dev/null 2>&1
      [ -d "$dir/templates" ] && mv -Rv "$dir/templates/*" "$NUXEO_HOME/templates/" || echo "" > /dev/null 2>&1
    done

    ######
    # NUXEO INTERNAL PROPERTIES CONFIGURATION
    ######

    # Override nuxeo url
    [ -n "$NUXEO_URL" ] && echo "nuxeo.url=$NUXEO_URL" >> "$NUXEO_CONF" || echo "" > /dev/null 2>&1

    # Skip Nuxeo Install & Configuration the first time
    [ -n "$SKIP_WIZARD" ] && perl -p -i -e "s/^#?nuxeo.wizard.done=.*$/nuxeo.wizard.done=$SKIP_WIZARD/g" "$NUXEO_CONF"

#    [ -d "$NUXEO_LOG" ] && perl -p -i -e "s/^#?nuxeo.log.dir=.*$/nuxeo.log.dir=\/${NUXEO_LOG#?}/g" "$NUXEO_CONF"
#    [ -d "$NUXEO_RUN" ] && perl -p -i -e "s/^#?nuxeo.pid.dir=.*$/nuxeo.pid.dir=\/${NUXEO_RUN#?}/g" "$NUXEO_CONF"
#    [ -d "$NUXEO_DATA" ] && perl -p -i -e "s/^#?nuxeo.data.dir=.*$/nuxeo.data.dir=\/${NUXEO_DATA#?}/g" "$NUXEO_CONF"
#    [ -d "$NUXEO_TMP" ] && perl -p -i -e "s/^#?nuxeo.tmp.dir=.*$/nuxeo.tmp.dir=\/${NUXEO_TMP#?}/g" "$NUXEO_CONF"

    config="$TMPD"/@config.d
    mkdir -p "$config"

#    # Copy user shared configuration ...
#    for file in "$CONFIGD/init.d"/*; do
#      debug "Copying init.d resource from $file -> $config"
#      cp "$file" "$config"/
#    done

    info "Merging built-in config.d with user provided init.d"
    for file in "${SHARED_LIB}"/config.d/*; do
      [ ! -f "$config/$file" ] && debug "Copying config.d resource from $file to $config" \
        && cp "$file" "$config"/ || debug "Target file: [$config/$file] has been contributed"
    done

    for file in "$config"/*; do
      case $file in
        *.sh)
          bash < "$file" #> /dev/null 2>&1
        ;;
        *)
         warn "$0: ignoring $file" ;;
      esac
    done

#    if [ -n "$NUXEO_TRANSIENT_STORE" ]; then
#      #removes transients stores if exists to allow symbolic link creation
#      [[ -d $NUXEO_DATA/transientstores ]] && rm -rf $NUXEO_DATA/transientstores
#
#      mkdir -p $NUXEO_DATA/transientstores
#      ln -s $NUXEO_TRANSIENT_STORE $NUXEO_DATA/transientstores/default
#    fi

  cat << EOF >> "$NUXEO_CONF"
##-----------------------------------------------------------------------------
## Auto generated configuration at runtime.
## Date: $(date '+%Y-%m-%d %T.%3N')
## Source: $0
##-----------------------------------------------------------------------------
nuxeo.log.dir=$NUXEO_LOG
nuxeo.pid.dir=$NUXEO_RUN
nuxeo.data.dir=$NUXEO_DATA
nuxeo.tmp.dir=$NUXEO_TMP

### BEGIN - DO NOT EDIT BETWEEN BEGIN AND END ###
EOF

    cat << EOF >> "$NUXEO_HOME/configured"
##-----------------------------------------------------------------------------
## Auto generated configuration at runtime.
## Date: $(date '+%Y-%m-%d %T.%3N')
## Source: $0
##-----------------------------------------------------------------------------
EOF

    rm -rf "$config" # remove the temp directory
    nuxeoctl mp-init # Initialize the platform marketplace configuration by default.
  else
    happy "Container already configured ..."
  fi

  # instance.clid
  if [ -n "$NUXEO_CLID" ]; then
    # Replace --  by a carriage return
    NUXEO_CLID="${NUXEO_CLID/--/\\n}"
    printf "%b\n" "$NUXEO_CLID" >> "$NUXEO_DATA"/instance.clid
  fi

  for file in /packages.d/*; do
    case $file in
      *.sh)
        bash < "$file" > /dev/null 2>&1
        ;;
      *.zip)
        nuxeoctl mp-install "$file" --accept=true --relax="${NONINTERACTIVE:-true}" > /dev/null 2>&1
        ;;
      *.jar)
        cp "$file" "$NUXEO_HOME/nxserver/plugin/"
        ;;
      *.clid)
        cp "$file" "$NUXEO_DATA"/
        ;;
      *)
        info "$0: ignoring $file" ;;
    esac
  done

  if [ -n "$NUXEO_CLID"  ] && [ "$NUXEO_INSTALL_HOTFIX" == "true" ]; then
      nuxeoctl mp-hotfix --accept=true > /dev/null 2>&1
  fi

  # Install packages if given
  if [ -n "$NUXEO_PACKAGES" ]; then
    nuxeoctl mp-install "$NUXEO_PACKAGES" --relax=false --accept=true > /dev/null 2>&1
  fi

  for file in "${SHARED_LIB}"/init.d/*; do
    case $file in
      *.sh)
        if [ -x "$file" ]; then
          bash "$file" &
        else
          error "$file cannot be executed."
        fi
      ;;
      *)
#       warn "$0: ignoring $file" ;;
    esac
  done
fi

exec "$@"

#trap cleanup EXIT
