#!/bin/bash

# ---------------------------------------------------------------------------
# buildx.sh - This script will be use to provide our platform deployment build.sh architecture
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

argv0=$(echo "$0" | sed -e 's,\\,/,g')
basedir=$(dirname "$(readlink "$0" || echo "$argv0")")

case "$(uname -s)" in
  Linux) basedir=$(dirname "$(readlink -f "$0" || echo "$argv0")");;
  *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

# shellcheck disable=SC2206
LTS=(${2:-8.10 9.10 10.10})
# shellcheck disable=SC2206
JDK=(${3:-8})
# shellcheck disable=SC2206
DISTRIBUTIONS=(${1:-debian ubuntu})

YEAR=$(date -u +'%y')
MONTH=$(date -u +'%m')

#PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x"
PLATFORM="linux/386,linux/amd64,linux/arm64"

for jdkver in "${JDK[@]}"; do
  JDK_VERSION="$jdkver"
  for lts in "${LTS[@]}"; do
    NUXEO_LTS="$lts"
    NUXEO_SHORT_LTS=${NUXEO_LTS%.*}
    SDK_VERSION="${JDK_VERSION}".$(date -u +'%y.%m')

    VERSION_SURFIX=${YEAR}$((10#$MONTH))
    BUILD_VERSION=$(date -u +'%y.%m.%d')-"$NUXEO_SHORT_LTS"
    #VERSION_TAG="$NUXEO_SHORT_LTS.${SDK_VERSION##*.}.$VERSION_SURFIX"
    VERSION_TAG="$NUXEO_SHORT_LTS.$JDK_VERSION.$VERSION_SURFIX"
    for dist in "${DISTRIBUTIONS[@]}"; do
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
        --tag djanta/nuxeo-server:"$FULL_TAG" \
        --file $(pwd)/dockerfiles/$dist/Dockerfile ./

      #docker buildx prune -f -a --verbose
    done
  done
done
