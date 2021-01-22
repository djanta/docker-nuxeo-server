#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# heap.sh - This script will be use to provide our platform deployment architecture
#
# Copyright 2020, Stanislas Koffi ASSOUTOVI <team.docker@djanta.io>
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

case "$(uname -s)" in
  Linux | *CYGWIN*) TOTAL_MEMORY_INKB=$(awk '/MemTotal/ {print $2}' /proc/meminfo);;
#  *CYGWIN*) TOTAL_MEMORY_INKB=$(awk '/MemTotal/ {print $2}' /proc/meminfo);;
  Darwin) TOTAL_MEMORY_INKB=$(sysctl -n hw.memsize);;
esac

# Default jvm exported variable
JVM_FILE="jvm.options"

##
# Adapted in part from: https://github.com/jboss-openshift/cct_module/blob/master/dynamic-resources/dynamic_resources.sh
# https://geekflare.com/important-jvm-options/
##

# For backward compatibility: CONTAINER_HEAP_PERCENT is old variable name
JAVA_MAX_MEM_RATIO=${JAVA_MAX_MEM_RATIO:-$(echo "${CONTAINER_HEAP_PERCENT:-0.5}" "100" | awk '{ printf "%d", $1 * $2 }')}
JAVA_INITIAL_MEM_RATIO=${JAVA_INITIAL_MEM_RATIO:-${INITIAL_HEAP_PERCENT:+$(echo "${INITIAL_HEAP_PERCENT}" "100" | awk '{ printf "%d", $1 * $2 }')}}

echo "JAVA_MAX_MEM_RATIO: $JAVA_MAX_MEM_RATIO"
echo "JAVA_INITIAL_MEM_RATIO: $JAVA_INITIAL_MEM_RATIO"

#TOTAL_MEMORY_INKB="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
#memoryInKb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"

heapSize="$(expr $TOTAL_MEMORY_INKB / 1024 / 1000 / 2)"

# deprecated, left for backward compatibility
function get_heap_size {
  echo "$(expr $TOTAL_MEMORY_INKB / 1024 / 1000 / 2)"
}

#sed -i "s/#*-Xmx[0-9]\+g/-Xmx${heapSize}g/g" "$NUXEO_CONF"
#sed -i "s/#*-Xms[0-9]\+g/-Xms${heapSize}g/g" "$NUXEO_CONF"

#perl -p -i -e "s/^#?*-Xmx[0-9]\+g/-Xmx${heapSize}g/g" "$NUXEO_CONF"
#perl -p -i -e "s/^#?*-Xms[0-9]\+g/-Xms${heapSize}g/g" "$NUXEO_CONF"

#echo $(sed -i -r "s/#*-Xmx[0-9]\+g/-Xmx${heapSize}g/g" "$NUXEO_CONF")
#
#echo "===> Memory heap size: $heapSize"
#
#cat "$NUXEO_CONF" | grep "JAVA_OPTS"

#debug "------------------------------------"
#ps -ef | grep java | grep Xmx


#if [ "$NUXEO_DEV_MODE" == "true" ] && [ -n "$DEBUG" ]; then
#    echo "JAVA_OPTS=\$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=${DEBUG_PORT:-8787}," \
#      "server=${DEBUG_SERVER_SIDE:-y},suspend=${DEBUG_SUSPEND:-n}" >> "$NUXEO_CONF"
#fi

## Print GC
#-verbose:gc - logs garbage collector runs and how long they're taking.
#-XX:+PrintGCDetails - includes the data from -verbose:gc but also adds information about the size of the new generation and more accurate timings.
#-XX:-PrintGCTimeStamps - Print timestamps at garbage collection.

## Handling ‘OutOfMemory’ Error
#-XX:+HeapDumpOnOutOfMemoryError
#-XX:HeapDumpPath= [path-to-heap-dump-directory]
#-XX:+UseGCOverheadLimit
#-XX:OnOutOfMemoryError="< cmd args >;< cmd args >"
#-XX:OnOutOfMemoryError="shutdown -r"

## Profiling
#-Xprof
#-Xrunhprof

## Trace classloading and unloading
#-XX:+TraceClassLoading
#-XX:+TraceClassUnloading
