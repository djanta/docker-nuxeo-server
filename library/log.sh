#
# Copyright 2019 DJANTA, LLC (https://www.djanta.io)
#
# Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed toMap in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

PROGNAME=${0##*/}
datestamp=$(date +%Y%m%d%H%M%S)
DEV_MODE=0

argv0=$(echo "$0" | sed -e 's,\\,/,g')
basedir=$(dirname "$(readlink "$0" || echo "$argv0")")

case "$(uname -s)" in
  Linux) basedir=$(dirname "$(readlink -f "$0" || echo "$argv0")");;
  *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

#source $(pwd)/common.sh

ERROR_BOLD="\e[1;31m"
ERROR_NORMAL="\e[0;31m"
DEBUG_BOLD="\e[1;35m"
DEBUG_NORMAL="\e[0;35m"
RESET="\e[00m"

RED="\033[31;01m"
CYAN="\033[36;01m"
YELLOW="\033[33;01m"
NORMAL="\033[00m"

if [[ -n "$COLORS" ]] && [[ ! "$COLORS" =~ ^(always|yes|true|1)$ ]]; then
  unset ERROR_BOLD
  unset ERROR_NORMAL
  unset DEBUG_BOLD
  unset DEBUG_NORMAL
  unset RESET
  unset RED="\\e[0;31m"
  unset CYAN="\\e[0;36m"
  unset YELLOW="\\e[0;33m"
  unset NORMAL="\\e[0;0m"
fi

argv() {
  arg_name="${2}"
  for i in "${@:3:$#}"; do
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

__print__() {
  argv level '--level' "${@:1:$#}"
  argv msg '--level' "${@:3:$#}"

  while [ "$1" ]; do
    case "$1" in
      -normal|--normal)     color="$NORMAL" ;;
      -black|--black)       color="\033[30;01m" ;;
      -red|--red)           color="$RED" ;;
      -green|--green)       color="\033[32;01m" ;;
      -yellow|--yellow)     color="$YELLOW" ;;
      -blue|--blue)         color="\033[34;01m" ;;
      -magenta|--magenta)   color="\033[35;01m" ;;
      -cyan|--cyan)         color="$CYAN" ;;
      -white|--white)       color="\033[37;01m" ;;
      -n)             one_line=1;   shift ; continue ;;
      *)              echo -n "$1"; shift ; continue ;;
    esac
    shift
      echo -en "$color"
      #echo -en "[$(date --rfc-3339=seconds)] [${level:-LOG}] - $msg"
      #echo -en "[$(date '+%Y-%m-%d %H:%M:%S')] [${level:-LOG}] - $msg"
      echo -en "[$(date '+%Y-%m-%d %T.%3N')] [${level:-LOG}] \t- $msg"
      echo -en "\033[00m"
      shift
  done
  if [ ! $one_line ]; then
    echo
  fi
}


log () {
  __print__ --normal --level="LOG" "$@"
}

debug () {
  __print__ --magenta --level="DEBUG" "$@"
}

warn () {
   __print__ --yellow --level="WARN" "$@"
}

error () {
   __print__ --red --level="ERROR" "$@"
}

info () {
   __print__ --white --level="INFO" "$@"
}

happy () {
   __print__ --green --level="DEBUG" "$@"
}
