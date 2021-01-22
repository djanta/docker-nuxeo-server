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

# shellcheck disable=SC2206
LTS=(${2:-8.10 9.10 10.10})

# shellcheck disable=SC2206
JDK=(${3:-8})

# shellcheck disable=SC2206
DISTRIBUTIONS=(${1:-debian ubuntu})

YEAR=$(date -u +'%y')
MONTH=$(date -u +'%m')

#DISTRIBUTION=${1:-debian}
#NUXEO_LTS=${2:-10.10}
#NUXEO_SHORT_LTS=${NUXEO_LTS%.*}
#JDK_VERSION=8
#SDK_VERSION=$(date -u +'%y.%m')."${JDK_VERSION}"
#
##VERSION_PREFIX=$(date -u +'%y.%m')
#VERSION_SURFIX=${YEAR}$((10#$MONTH))
#BUILD_VERSION=$(date -u +'%y.%m.%d')-"$NUXEO_SHORT_LTS"
##LTS.SDK.YEARMONTH-VARIANT
#VERSION_TAG="$NUXEO_SHORT_LTS.${SDK_VERSION##*.}.$VERSION_SURFIX"
##VERSION_TAG="$VERSION_PREFIX.$NUXEO_SHORT_LTS"
##SDK_VERSION=$(date -u +'%y.%m')."$NUXEO_SHORT_LTS"

#docker --debug build -t djanta/nuxeo-server-"$DISTRIBUTION":"$VERSION_TAG" \
#  --build-arg BUILD_VERSION="$BUILD_VERSION" \
#  --build-arg BUILD_HASH=$(git rev-parse HEAD) \
#  --build-arg RELEASE_VERSION="$VERSION_TAG" \
#  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
#  --build-arg BUILD_SDK_VERSION="$SDK_VERSION" \
#  --build-arg BUILD_NX_VERSION="$NUXEO_LTS" \
#  --build-arg BUILD_DISTRIBUTION_ID="$DISTRIBUTION" \
#  --file $(pwd)/dockerfiles/"$DISTRIBUTION"/Dockerfile .

PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x"

#--cache-from "type=local,src=/tmp/.buildx-cache" \
#--cache-to "type=local,dest=/tmp/.buildx-cache" \

for jdkver in "${JDK[@]}";
do
  JDK_VERSION="$jdkver"
  for lts in "${LTS[@]}";
  do
    NUXEO_LTS="$lts"
    NUXEO_SHORT_LTS=${NUXEO_LTS%.*}
    SDK_VERSION="${JDK_VERSION}".$(date -u +'%y.%m')

    VERSION_SURFIX=${YEAR}$((10#$MONTH))
    BUILD_VERSION=$(date -u +'%y.%m.%d')-"$NUXEO_SHORT_LTS"
    #VERSION_TAG="$NUXEO_SHORT_LTS.${SDK_VERSION##*.}.$VERSION_SURFIX"
    VERSION_TAG="$NUXEO_SHORT_LTS.$JDK_VERSION.$VERSION_SURFIX"
    for dist in "${DISTRIBUTIONS[@]}";
    do
      FULL_TAG="$VERSION_TAG-$dist"
      docker buildx build \
        --platform "$PLATFORM" \
        --build-arg BUILD_VERSION="$VERSION_TAG" \
        --build-arg BUILD_HASH=$(git rev-parse HEAD) \
        --build-arg RELEASE_VERSION="$VERSION_TAG" \
        --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
        --build-arg BUILD_SDK_VERSION="$SDK_VERSION" \
        --build-arg BUILD_NX_VERSION="$NUXEO_LTS" \
        --build-arg BUILD_DISTRIB="$dist" \
        --output "type=image,push=false" \
        --tag "$FULL_TAG" \
        --file $(pwd)/dockerfiles/$dist/Dockerfile ./

#      #echo "SDK VERSION: $SDK_VERSION , TAG VERSION: $VERSION_TAG , FULL VERSION: $FULL_TAG"
#      docker --debug build -t djanta/nuxeo-server:"$FULL_TAG" \
#        --build-arg BUILD_VERSION="$VERSION_TAG" \
#        --build-arg BUILD_HASH=$(git rev-parse HEAD) \
#        --build-arg RELEASE_VERSION="$VERSION_TAG" \
#        --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
#        --build-arg BUILD_SDK_VERSION="$SDK_VERSION" \
#        --build-arg BUILD_NX_VERSION="$NUXEO_LTS" \
#        --build-arg BUILD_DISTRIB="$dist" \
#        --file $(pwd)/dockerfiles/$dist/Dockerfile .
    done
  done

#        --build-arg BUILD_VERSION="$BUILD_VERSION" \

#  VERSION_TAG="$jdkver.$VERSION_SUFFIX"
#  BUILD_VERSION=$(date -u +'%y.%m.%d')-"$jdkver"
#
#  for dist in "${distributions[@]}";
#    do
#    FULL_TAG="$VERSION_TAG-$dist"
##    docker --debug build -t djanta/nuxeo-sdk:"$FULL_TAG" \
##      --build-arg RELEASE_VERSION="$VERSION_TAG" \
##      --build-arg BUILD_VERSION="$BUILD_VERSION" \
##      --build-arg BUILD_HASH=$(git rev-parse HEAD) \
##      --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
##      --build-arg BUILD_JDK_VERSION="$jdkver" \
##      --build-arg BUILD_JDK_VARIANT="$JDK_VARIANT" \
##      --file $(pwd)/dockerfiles/$dist/Dockerfile .
#  done
done
