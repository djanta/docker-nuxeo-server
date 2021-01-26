#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# entrypoint.sh - This script will be use to provide our platform deployment entrypoint.sh architecture
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

if [[ "x $@" =~ " -d" || "x $@" =~ " --debug" || -n "$RUN_DEBUG" || -n "$LAUNCHER_DEBUG" ]]; then
  set -x
#  set -ex
fi

argv0=$(echo "$0" | sed -e 's,\\,/,g')
basedir=$(dirname "$(readlink "$0" || echo "$argv0")")

case "$(uname -s)" in
  Linux) basedir=$(dirname "$(readlink -f "$0" || echo "$argv0")");;
  *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

BASE=`dirname ${basedir}`

all=("common.sh" "helper.sh" "log.sh")

# shellcheck disable=SC1090
for file in "${all[@]}"; do source "/library/${file}"; done

# Detecting java home after sourcing all shared libraries ...
detect_javahome

#regex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
#url='http://www.google.com/test/link.php'
#if [[ $url =~ $regex ]]
#then
#    echo "$url IS valid"
#else
#    echo "$url IS NOT valid"
#fi

## Fix syntax: https://github.com/koalaman/shellcheck/wiki/SC2236
[[ -n "${MAX_FD//}" ]] && ULIMIT="${MAX_FD}" || ULIMIT=63536

# Allow supporting arbitrary user id
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    sed /^nuxeo/d /etc/passwd > /tmp/passwd && cp /tmp/passwd /etc/passwd
    echo "${NUXEO_USER:-nuxeo}:x:$(id -u):0:${NUXEO_USER:-nuxeo} user:${NUXEO_HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

# shellcheck disable=SC2034
# shellcheck disable=SC2015
[ -f /var/run/docker.sock ] && warn "You're now running docker in docker" && DOCKER_IN_DOCKER=true || echo ""
[ -n "$JAVA_HOME" ] && debug "Java Home detected at: $JAVA_HOME" || warn "Java Home not found!"

if [ "$1" = 'nuxeoctl' ]; then

  # Reset an existing "$NUXEO_HOME"/configured
  [ "$DRY_MODE" = "true" ] && log "Reset and clean up any existing configuration"
  [ -n "$FORCE_RECREATE" ] && [ ! -f "$NUXEO_HOME"/configured ] && warn "Clean up and recreating configuration ..." \
    || log "No force recreation"

  # Re-configure nuxeo environment ...
  if [ ! -f "$NUXEO_HOME"/configured ]; then

    ######
    # NUXEO INTERNAL PROPERTIES CONFIGURATION
    ######

    # Update the system timezone
    [ -n "$TIMEZONE" ] && echo "$TIMEZONE" > /etc/timezone || echo "" > /dev/null 2>&1

    # Override nuxeo url
    [ -n "$NUXEO_URL" ] && echo "nuxeo.url=$NUXEO_URL" >> "$NUXEO_CONF" || echo "" > /dev/null 2>&1

    # Skip Nuxeo Install & Configuration the first time
    [ -n "$SKIP_WIZARD" ] && perl -p -i -e "s/^#?nuxeo.wizard.done=.*$/nuxeo.wizard.done=$SKIP_WIZARD/g" "$NUXEO_CONF" \
      || perl -p -i -e "s/^#?nuxeo.wizard.done=.*$/nuxeo.wizard.done=true/g" "$NUXEO_CONF"

#    [ -d "$NUXEO_LOG" ] && perl -p -i -e "s/^#?nuxeo.log.dir=.*$/nuxeo.log.dir=\/${NUXEO_LOG#?}/g" "$NUXEO_CONF"
#    [ -d "$NUXEO_RUN" ] && perl -p -i -e "s/^#?nuxeo.pid.dir=.*$/nuxeo.pid.dir=\/${NUXEO_RUN#?}/g" "$NUXEO_CONF"
#    [ -d "$NUXEO_DATA" ] && perl -p -i -e "s/^#?nuxeo.data.dir=.*$/nuxeo.data.dir=\/${NUXEO_DATA#?}/g" "$NUXEO_CONF"
#    [ -d "$NUXEO_TMP" ] && perl -p -i -e "s/^#?nuxeo.tmp.dir=.*$/nuxeo.tmp.dir=\/${NUXEO_TMP#?}/g" "$NUXEO_CONF"

    # Nuxeo connect token control
    [ -z "$NUXEO_CONNECT_TOKEN" ] && warn "Missing NUXEO_CONNECT_TOKEN variable."
    [ -z "$NUXEO_CONNECT_USERID" ] && warn "Missing NUXEO_CONNECT_USERID variable."

    # instance.clid
    if [ -n "$NUXEO_CLID" ]; then
      # Replace --  by a carriage return
      NUXEO_CLID="${NUXEO_CLID/--/\\n}"
      printf "%b\n" "$NUXEO_CLID" >> "$NUXEO_DATA"/instance.clid
    fi

    # Install hotfixes from nuxeo remote marketplace platform
    [ -n "$NUXEO_CLID"  ] && [ "$INSTALL_HOTFIX" == "true" ] && nuxeoctl mp-hotfix --accept=true \
      --relax=true > /dev/null 2>&1 || info "Hotfixes installation deactivated"

    # Install packages if any given
    [ -n "$NUXEO_PACKAGES" ] && nuxeoctl mp-install "$NUXEO_PACKAGES" --accept=true \
      --relax=true > /dev/null 2>&1 || info "No package to be installed"

#    if [ -n "$NUXEO_TRANSIENT_STORE" ]; then
#      #removes transients stores if exists to allow symbolic link creation
#      [[ -d $NUXEO_DATA/transientstores ]] && rm -rf $NUXEO_DATA/transientstores
#
#      mkdir -p $NUXEO_DATA/transientstores
#      ln -s $NUXEO_TRANSIENT_STORE $NUXEO_DATA/transientstores/default
#    fi

    ######
    # EXTERNAL SCRIPT CONFIGURATION
    ######

    if [ -d "$CONFIG_D" ]; then
      deploy=("$CONFIG_D")
      #TMPD="/tmp/$(date -u +'%Y%m%dT_%H%M%SZ')"
      TMPD="/tmp/$(date -u +'%Y%m%d%H%M%S')"
      mkdir -pv "$TMPD"/config.d

      # When user define a specific environment to use
      [ -n "$DEPLOY_ENV" ] && [ -d "$CONFIG_D/$DEPLOY_ENV" ] && info "Using user defined deployment environment: \
        $DEPLOY_ENV" && deploy+=("$CONFIG_D/$DEPLOY_ENV") || debug "no deployment environment defined"

      for dir in "${deploy[@]}"; do
        warn "Scanning ($dir) directory for deployment ..."
        [ -f "$dir/nuxeo.conf" ] && warn "Overrride $NUXEO_CONF with $dir/nuxeo.conf" && cat "$dir/nuxeo.conf" > "$NUXEO_CONF"
        [ -f "$dir/license" ] && cat "$dir/license" >  "$NUXEO_DATA/instance.clid" || echo "" > /dev/null 2>&1
        [ -d "$dir/log" ] && cp -Rv "$dir/log/*" "$NUXEO_HOME/lib/" || log "Unchanged log configuration"
        [ -d "$dir/config" ] && cp -Rv "$dir/config/*" "$NUXEO_HOME/nxserver/config/" || echo "" > /dev/null 2>&1
        [ -d "$dir/templates" ] && cp -Rv "$dir/templates/*" "$NUXEO_HOME/templates/" || echo "" > /dev/null 2>&1

        # Copy all user defined config.d
        [ -d "$dir/config.d" ] && cp -Rv "$dir/config.d/*" "$TMPD/config.d/" || echo "" > /dev/null 2>&1
      done

  #    # Copy user shared configuration ...
  #    for file in "$CONFIGD/init.d"/*; do
  #      debug "Copying init.d resource from $file -> "$TMPD"/config.d"
  #      cp "$file" "$TMPD"/config.d/
  #    done

      #info "Merging built-in config.d with user provided init.d"
      for file in /library/config.d/*; do
        [ ! -f "$TMPD/config.d/$file" ] && debug "Copying shared file: $file to $TMPD/config.d" \
          && cp "$file" "$TMPD"/config.d/ || debug "Target file: [$TMPD/config.d/$file] has been contributed"
      done

      for file in "$TMPD"/config.d/*; do
        debug "About to execute file: $file"
        case $file in
          *.sh)
            bash < "$file" #> /dev/null 2>&1
          ;;
          *)
           warn "$0: ignoring unsupported $file" ;;
        esac
      done

      package_d=("$PACKAGE_D")
      for dir in "${deploy[@]}"; do
        for scope in "package.d/hotfixes" "package.d/addons"; do
          [ -d "$dir/$scope" ] && package_d+=("$dir/$scope")
        done
      done

      # Install all external provisioned packages
      for dir in "${package_d[@]}"; do
        if [ -d "$dir" ]; then
          info "Scanning folder: $dir"
          # shellcheck disable=SC2045
          for package in $(ls "$dir"); do
            info "Processing package: $dir/$package"
            case $package in
              *.zip)
                debug "Installing package: ($package), from: $dir/$package"
                nuxeoctl mp-install --accept=true --relax=true "$dir/$package" > /dev/null 2>&1
                ;;
              *.jar)
                debug "Copying jar file: ("$dir/$package"), from local resource as ."
                cp -v "$dir/$package" "$NUXEO_HOME/nxserver/plugins/"
                ;;
              *)
                warn "$0: ignoring $package"
                ;;
            esac
          done
        fi
      done
      nuxeoctl mp-list
    else
      debug "Missing use defined shared resource volume: $CONFIG_D"
    fi

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

export TMPD_BASE=$TMPD
EOF
    #rm -rfv "$TMPD"/config.d # remove the temp directory
  else
    cat "$NUXEO_HOME"/configured
    happy "Container already configured ..."

    # shellcheck disable=SC1090
    # Soure to export all preview variables ...
    source "$NUXEO_HOME"/configured
  fi
fi

# Always try to uninstall the given marketplace package.
if [ -n "$NUXEO_PACKAGE_UNINSTALL" ]; then
  for package in $(echo "$NUXEO_PACKAGE_UNINSTALL" | tr "," "\n"); do
    nuxeoctl mp-uninstall --accept=true --relax=true "$package" > /dev/null 2>&1
  done
fi

# Always try to install the given marketplace package.
if [ -n "$NUXEO_PACKAGE_INSTALL" ]; then
  for package in $(echo "$NUXEO_PACKAGE_INSTALL" | tr "," "\n"); do
    nuxeoctl mp-install --accept=true --relax=true "$package" > /dev/null 2>&1
  done
fi

# Always try to install the given marketplace template.
if [ -n "$NUXEO_TEMPLATE_INSTALL" ]; then
  for template in $(echo "$NUXEO_TEMPLATE_UNINSTALL" | tr "," "\n"); do
    perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,${template}/g" "$NUXEO_CONF"
  done
fi

## From here we can re-run the background scripts ...
#for background in "$SHARED_D"/init.d/*; do
#  case $background in
#    *.sh)
#      if [ -x "$background" ]; then
#        bash "$background" &
#      else
#        error "$background is not or has no executable permission"
#      fi
#    ;;
#    *)
#     warn "$0: ignoring unknown file: $background" ;;
#  esac
#done

[ "$1" = 'nuxeoctl' ] && [ -n "$NUXEO_CTL_DEBUG" ] && exec "$@" "-d" "$NUXEO_CTL_DEBUG" || exec "$@"

#trap cleanup EXIT
