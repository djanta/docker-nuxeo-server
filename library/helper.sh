# ---------------------------------------------------------------------------
# helper.sh - This script will be use to provide our platform deployment helper.sh architecture

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

PROGNAME=${0##*/}
DEV_MODE=0
NUXEO_DEFAULT_TPL="nuxeo.defaults"

ERROR_BOLD="\e[1;31m"
ERROR_NORMAL="\e[0;31m"
DEBUG_BOLD="\e[1;35m"
DEBUG_NORMAL="\e[0;35m"
RESET="\e[00m"

RED="\033[31;01m"
CYAN="\033[36;01m"
YELLOW="\033[33;01m"
NORMAL="\033[00m"

d=`date +%m-%d-%Y`
FULL_DATE=`date '+%A %d-%B, %Y'`

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

colored(){
  while [ "$1" ]; do
    case "$1" in
      -normal|--normal)         color="$NORMAL" ;;
      -black|--black)           color="\033[30;01m" ;;
      -red|--red)               color="$RED" ;;
      -green|--green)           color="\033[32;01m" ;;
      -yellow|--yellow)         color="$YELLOW" ;;
      -blue|--blue)             color="\033[34;01m" ;;
      -magenta|--magenta)       color="\033[35;01m" ;;
      -cyan|--cyan)             color="$CYAN" ;;
      -white|--white)           color="\033[37;01m" ;;
      -n)                       one_line=1;   shift ; continue ;;
      *)                        echo -n "$1"; shift ; continue ;;
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

command_exists () {
  command -v "$1" >/dev/null 2>&1;
}

clean_up () { # Perform pre-exit housekeeping
  return
}

error_exit () {
  echo -e "${PROGNAME}: ${1:-"Unknown Error"}" >&2
  clean_up
  exit 1
}

graceful_exit () {
  clean_up
  exit
}

signal_exit () { # Handle trapped signals
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

#########################################################################
#           NUXEO SPECIFIC FUNCTIONS DECLARATION                        #
#########################################################################

##
# Enable the given nuxeo tempalte.
##
nuxeo_tpl_enable () {
  if [[ -n "${1}" ]]  &&  [[ -f "${NUXEO_CONF}" ]]; then
    echo "Enabling the given nuxen template entry: $1"
    perl -p -i -e "s/^#?(nuxeo.templates=.*$)/\1,${1}/g" $NUXEO_CONF
  fi
}

##
# Create the given redis nuxeo template resourses folder
##
nuxeo_tpl_redis () {
  if [[ -n "$NUXEO_REDIS_HOST" ]] && [[ -f "$NUXEO_CONF" ]]; then
    ## Make sure we crate the target "redis" directory anyway ...
    mkdir -p "$NUXEO_TPL_HOME/redis"

    ## Edit the given nuxeo redis configuration
    cat << EOF >> "$NUXEO_TPL_HOME/redis/$NUXEO_DEFAULT_TPL"
nuxeo.template.includes=default
redis.target=.

# Redis specific configuration
nuxeo.redis.enabled=${NUXEO_REDIS_ENABLED:=true}
nuxeo.redis.host=${NUXEO_REDIS_HOST}
nuxeo.redis.port=${NUXEO_REDIS_PORT:=6379}

# Redis is automatically enabled when this template is used
nuxeo.redis.prefix=${NUXEO_REDIS_PREFIX:=nuxeo:}
nuxeo.redis.password=${NUXEO_REDIS_PASSWORD}
nuxeo.redis.ssl=${NUXEO_REDIS_SSL:=false}
nuxeo.redis.truststore.path=${NUXEO_REDIS_TRUSTSTORE_PATH}
nuxeo.redis.truststore.password=${NUXEO_REDIS_TRUSTORE_PASSWORD}
nuxeo.redis.truststore.type=${NUXEO_REDIS_TRUSTORE_TYPE}
nuxeo.redis.keystore.path=${NUXEO_REDIS_KEYSTORE_PATH}
nuxeo.redis.keystore.password=${NUXEO_REDIS_KEYSTORE_PASSWORD}
nuxeo.redis.keystore.type=${NUXEO_REDIS_KEYSTORE_TYPE}
nuxeo.redis.database=${NUXEO_REDIS_DATABASE:=0}
nuxeo.redis.timeout=${NUXEO_REDIS_TIMEOUT:=2000}
nuxeo.redis.maxTotal=${NUXEO_REDIS_MAX_TOTAL:=16}
nuxeo.redis.maxIdle=${NUXEO_REDIS_MAX_IDLE:=8}

nuxeo.redis.ha.enabled=${NUXEO_REDIS_HA_ENABLED:=false}
nuxeo.redis.ha.master=${NUXEO_REDIS_HA_MASTER:=mymaster}
nuxeo.redis.ha.hosts=${NUXEO_REDIS_HA_HOST:=localhost}
nuxeo.redis.ha.timeout=${NUXEO_REDIS_HA_TIMEOUT:=300}
nuxeo.redis.ha.port=${NUXEO_REDIS_HA_PORT:=26379}

nuxeo.pubsub.provider=${NUXEO_REDIS_PUBSUB_PROVIDER:=redis}
nuxeo.keyvalue.provider=${NUXEO_REDIS_KEYVALUE_PROVIDER:=redis}
nuxeo.work.queuing=${NUXEO_REDIS_WORK_QUEUING:=redis}
nuxeo.lock.manager=${NUXEO_REDIS_LOCK_MANAGER:=redis}

# by default use the KeyValueBlobTransientStore from the common template
#nuxeo.transientstore.provider=redis
EOF

  # Now let enable the redis confiuration
  nuxeo_tpl_enable "redis"
  fi
}

##
# Create the given redis nuxeo template resourses folder
##
nuxeo_tpl_elasticsearch() {
  if [[ -n "$NUXEO_ES_HOSTS" ]] && [[ -f "$NUXEO_CONF" ]]; then
    ## Make sure we crate the target "elasticsearch" directory anyway ...
    mkdir -p "$NUXEO_TPL_HOME/elasticsearch"

    ## Edit the given nuxeo redis configuration
    cat << EOF >> "$NUXEO_TPL_HOME/elasticsearch/$NUXEO_DEFAULT_TPL"
nuxeo.template.includes=default
elasticsearch.target=.
# Elasticsearch specific configuration
elasticsearch.addressList=${NUXEO_ES_HOSTS}
elasticsearch.clusterName=${NUXEO_ES_CLUSTER_NAME:=elasticsearch}
elasticsearch.indexName=${NUXEO_ES_INDEX_NAME:=nuxeo}
elasticsearch.indexNumberOfReplicas=${NUXEO_ES_REPLICAS:=1}
elasticsearch.indexNumberOfShards=${NUXEO_ES_SHARDS:=5}
EOF

  # Now let enable the redis confiuration
  nuxeo_tpl_enable "elasticsearch"
  fi
}

#
# Gets the current running docker self host unique identifier
# Credit: https://stackoverflow.com/questions/20995351/docker-how-to-get-container-information-from-within-the-container
#
self_hostname(){
  echo "$(cat /etc/hostname || hostname)"
}

docker_container_names() {
  docker ps -a --format "{{.Names}}" | xargs
}

dockerip () {
  docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

dockerallip () {
  docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
}

dockerips () {
  docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
}

dipall () {
  for container_name in $(docker_container_names);
  do
    local container_ip=$(dip $container_name)
    if [[ -n "$container_ip" ]]; then
      echo $(dip $container_name) " $container_name"
    fi
  done | sort -t . -k 3,3n -k 4,4n
}

# Get the IP address of a particular container
dip () {
  local network
  network='YOUR-NETWORK-HERE'
  docker inspect --format "{{ .NetworkSettings.Networks.$network.IPAddress }}" "$@"
}

dcontainer () {
  # get all running docker container names
  #containers=$(sudo docker ps | awk '{if(NR>1) print $NF}')
  containers=$(docker ps | awk '{if(NR>1) print $NF}')
  host=$(hostname)

    # loop through all containers
    for container in $containers
    do
      echo "Container: $container"
      percentages=($(sudo docker exec $container /bin/sh -c "df -h | grep -vE '^Filesystem|shm|boot' | awk '{ print +\$5 }'"))
      mounts=($(sudo docker exec $container /bin/sh -c "df -h | grep -vE '^Filesystem|shm|boot' | awk '{ print \$6 }'"))

      for index in ${!mounts[*]}; do
        echo "Mount ${mounts[index]}: ${percentages[index]}%"

        if (( ${percentages[index]} > 70 )); then
          message="[ERROR] At $host and Docker container $container the mount ${mounts[index]} is at ${percentages[index]}% of its disk space. Please check this."
          echo $message
        fi
      done
      echo ================================
    done
}

#
# Gets the current running docker self container full id
# Credit: https://stackoverflow.com/questions/20995351/docker-how-to-get-container-information-from-within-the-container
#
docker_self_container_id() {
  echo "$(cat /proc/self/cgroup | head -n 1 | cut -d '/' -f3)"
}

#
# Get the current running docker self if address
#
docker_self_ip() {
  echo "$(dockerip $(docker_self_container_id))"
}
