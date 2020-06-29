# ---------------------------------------------------------------------------
# watcher.sh - This script will be use to provide our platform deployment watcher.sh architecture

# Copyright 2015, Stanislas Koffi ASSOUTOVI <team.docker@djanta.io>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.
# ---------------------------------------------------------------------------

#https://www.linuxjournal.com/content/linux-filesystem-events-inotify

#unset IFS                                 # default of space, tab and nl
#                                          # Wait for filesystem events
#inotifywait -m -e close_write \
#   /tmp /var/tmp /home/oracle/arch-orcl/ |
#
#while read dir op file
#do [[ "${dir}" == '/tmp/' && "${file}" == *.txt ]] &&
#      echo "Import job should start on $file ($dir $op)."
#
#   [[ "${dir}" == '/var/tmp/' && "${file}" == CLOSE_WEEK*.txt ]] &&
#      echo Weekly backup is ready.
#
#   [[ "${dir}" == '/home/oracle/arch-orcl/' && "${file}" == *.ARC ]] &&
#      su - oracle -c 'ORACLE_SID=orcl ~oracle/bin/log_shipper' &
#
#   [[ "${dir}" == '/tmp/' && "${file}" == SHUT ]] && break
#
#   ((step+=1))
#done
#
#echo We processed $step events.

argv0=$(echo "$0" | sed -e 's,\\,/,g')
basedir=$(dirname "$(readlink "$0" || echo "$argv0")")

case "$(uname -s)" in
  Linux) basedir=$(dirname "$(readlink -f "$0" || echo "$argv0")");;
  *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

BASE=`dirname ${basedir}`
CWD=$(pwd)
SCRIPT_DIR=$(cd "${BASE}"; pwd)

TARGET=~/incoming/
PROCESSED=~/processed/

watch () {
  argv inevent '--event' "${@:1:$#}"
  argv insource '--source' "${@:1:$#}"
  argv inlog '--log' "${@:1:$#}"

  ## inotify watch a directory with timestamps
  #inotifywait --monitor --timefmt '%F %T' --format '%T %w %e' --recursive $1

  ##https://github.com/rvoicilas/inotify-tools/issues/5
  #https://unix.stackexchange.com/questions/163749/inotifywait-get-old-and-new-file-name-when-renaming
  #https://unix.stackexchange.com/questions/140679/using-inotify-to-monitor-a-directory-but-not-working-100

  declare -A cache
  while read event file
  do
    colored --cyan "Incoming event: ${event}, file: ${file}"

#    echo "Incoming event: ${event}, file: ${file}" >> "${inlog}"

#    if [ "$event" = "MOVED_FROM" ]; then
#      cache[$id]=$file
#    fi
#    if [ "$event" = "MOVED_TO" ]; then
#      if [ "${cache[$id]}" ]; then
#          echo "processing ..."
#          unset cache[$id]
#      else
#          echo "mismatch for $id"
#      fi
#    fi

    exec nuxeoctl --help
  done < <(inotifywait -r -m -e "${inevent:-modify,create,delete}" --format '%e %f' "${insource}")
}
