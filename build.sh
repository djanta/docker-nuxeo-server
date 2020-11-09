#!/bin/bash

# ---------------------------------------------------------------------------
# build.sh - This script will be use to provide our platform deployment build.sh architecture
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

#set -e

argv0=$(echo "$0" | sed -e 's,\\,/,g')
basedir=$(dirname "$(readlink "$0" || echo "$argv0")")

case "$(uname -s)" in
  Linux) basedir=$(dirname "$(readlink -f "$0" || echo "$argv0")");;
  *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

#BASE=`dirname ${basedir}`
#CWD=$(pwd)
#docker system prune -a -f

YEAR=$(date -u +'%y')
MONTH=$(date -u +'%m')

DISTRIBUTION=${1:-debian}
NUXEO_LTS=${2:-10.10}
NUXEO_SHORT_LTS=${NUXEO_LTS%.*}
JDK_VERSION=8
SDK_VERSION=$(date -u +'%y.%m')."${JDK_VERSION}"

#VERSION_PREFIX=$(date -u +'%y.%m')
VERSION_SURFIX=${YEAR}$((10#$MONTH))
BUILD_VERSION=$(date -u +'%y.%m.%d')-"$NUXEO_SHORT_LTS"
#LTS.SDK.YEARMONTH-VARIANT
VERSION_TAG="$NUXEO_SHORT_LTS.${SDK_VERSION##*.}.$VERSION_SURFIX"
#VERSION_TAG="$VERSION_PREFIX.$NUXEO_SHORT_LTS"
#SDK_VERSION=$(date -u +'%y.%m')."$NUXEO_SHORT_LTS"

#docker --debug build --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t $IMAGE_TAG \
#  --file $CWD/dockerfiles/$VERSION/Dockerfile .

docker --debug build -t djanta/nuxeo-server-"$DISTRIBUTION":"$VERSION_TAG" \
  --build-arg BUILD_VERSION="$BUILD_VERSION" \
  --build-arg BUILD_HASH=$(git rev-parse HEAD) \
  --build-arg RELEASE_VERSION="$VERSION_TAG" \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg BUILD_SDK_VERSION="$SDK_VERSION" \
  --build-arg BUILD_NX_VERSION="$NUXEO_LTS" \
  --build-arg BUILD_DISTRIBUTION_ID="$DISTRIBUTION" \
  --file $(pwd)/dockerfiles/"$DISTRIBUTION"/Dockerfile .
