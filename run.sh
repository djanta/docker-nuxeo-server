#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# run.sh - This script will be use to provide our platform deployment dockerjs.sh architecture
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
CWD=$(pwd)
USER_HOME="$(eval echo ~)"

#VARIANT=${1:-openjdk}
#VERSION=${2:-10.10}
#IMAGE_TAG="djanta/nuxeo-server-${VARIANT}:${VERSION}"

DISTRIBUTION=${1:-debian}
NUXEO_FULL_VERSION=${2:-10.10}
NUXEO_SHORT_VERSION=${NUXEO_FULL_VERSION%.*}
VERSION_PREFIX=$(date -u +'%y.%m')


VERSION_TAG="$VERSION_PREFIX.$NUXEO_SHORT_VERSION"
IMAGE_TAG=djanta/nuxeo-server-"$DISTRIBUTION":"$VERSION_TAG"

#docker run -it --name nx-server-${VERSION} -v /Users/stanislas/Downloads/Projects:/volumes/nuxeo/projects \
#  -p 8080:8080 -e LIVE_PROJECT=/volumes/nuxeo/projects "${IMAGE_TAG}"

#docker container rm nuxeo-server-${VARIANT}-${VERSION} -f
docker run -it --name nuxeo-server-"$DISTRIBUTION"-"$VERSION_TAG" -p 8080:8080 -e SKIP_WIZARD=true \
  -e NUXEO_DEV_MODE=true "${IMAGE_TAG}"
