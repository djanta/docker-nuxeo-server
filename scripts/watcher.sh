
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

TARGET=~/incoming/
PROCESSED=~/processed/

argv() {
  arg_name="${2}"
  for i in ${@:3:$#}; do
    PARAM=`echo $i | awk -F= '{print $1}'`
    VALUE=`echo $i | awk -F= '{print $2}'`
    case ${PARAM} in
    "$arg_name")
      #value_=${i}
      eval "$1=\"${VALUE}\""  # Assign new value.
    ;;
    esac
  done
}

exists() {
  arg_name="${2}"
  for i in ${@:3:$#}; do
    PARAM=`echo $i | awk -F= '{print $1}'`
    VALUE=`echo $i | awk -F= '{print $2}'`
    case ${PARAM} in
    "$arg_name")
      eval "$1=true"  # Assign new value.
    ;;
    esac
  done
}

watch() {
  echo "Start watching: ${1} ..."

  local target="${1}"

  argv inevent '--event' ${@:1:$#}
  argv inplugin '--plugin-dir' ${@:1:$#}
  argv inbundle '--bundle-dir' ${@:1:$#}
  argv insource '--source' ${@:1:$#}

  ## inotify watch a directory with timestamps
  #inotifywait --monitor --timefmt '%F %T' --format '%T %w %e' --recursive $1

  #inotifywait -m -r --format '%f' -e modify -e move -e create -e delete /var/www/cloud/data | while read LINE;
  #do
  #    php /var/www/cloud/scannner/watcher.php;
  #done


  ##https://github.com/rvoicilas/inotify-tools/issues/5
  #modify,create,delete

  if [ -d "${insource}" ]; then

  inotifywait -m -e ${inevent:-modify,create,delete} -e moved_to --format "%f" ${target} | while read FILENAME
    do
      echo Detected $FILENAME, moving and zipping
      mv "$TARGET/$FILENAME" "$PROCESSED/$FILENAME"
      gzip "$PROCESSED/$FILENAME"
    done
  fi
}
