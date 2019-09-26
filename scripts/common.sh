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

clean_up() { # Perform pre-exit housekeeping
  return
}

error_exit() {
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  clean_up
  exit ${2:-1}
}

graceful_exit() {
  clean_up
  exit
}

signal_exit() { # Handle trapped signals
  case $1 in
    INT)
      error_exit "Program interrupted by user" ;;
    TERM)
      echo -e "\n$PROGNAME: Program terminated" >&2
      graceful_exit ;;
    *)
      error_exit "$PROGNAME: Terminating on unknown signal" ;;
  esac
}

die() {
    ret=${1}
    shift
    printf "${CYAN}${@}${NORMAL}\n" 1>&2
    exit ${ret}
}

colored() {
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
      echo -en "$1"
      echo -en "\033[00m"
      shift
  done
  if [ ! $one_line ]; then
    echo
  fi
}

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

export_properties() {
  if [ "$#" -eq 0 ]; then
    error_exit "Insuffisant function argument. At least the target proprerties file must be specified."
  elif [ ! -f "${1}" ]; then
   error_exit "The given file: (${1}0 must be an existing file."
  fi

  # read file line by line and populate the array. Field separator is "="
  #declare -A arr
  while IFS='=' read -r k v; do
    #arr["$k"]="$v"
    colored --cyan "Export ${k} -> ${v}"
    $(export ${k}="$v")
  done < ${1}
}

####
# Check whether the given command has existed
###
command_exists () {
  command -v "$1" >/dev/null 2>&1;
}
