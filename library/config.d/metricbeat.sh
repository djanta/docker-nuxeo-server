#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# metricbeat.sh - This script will be use to provide our platform deployment architecture
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

# shellcheck disable=SC1090
# shellcheck disable=SC2116

source "/library/common.sh"
source "/library/log.sh"

METRICBEAT=${METRICBEAT:-true}

if command_exists "metricbeat" && ${METRICBEAT}; then
  info "Metricbeat installed!"

#  mkdir -pv /etc/metricbeat/modules.d
#  cat << EOF >> /etc/metricbeat/modules.d/docker.yml
#output.elasticsearch:
#  hosts: ["<es_url>"]
#  username: "elastic"
#  password: "<password>"
#setup.kibana:
#  host: "<kibana_url>"
#EOF

  # Credit: https://www.elastic.co/guide/en/beats/metricbeat/6.4/load-kibana-dashboards.html#load-dashboards-logstash
#  metricbeat setup -e \
#    -E output.logstash.enabled=false \
#    -E output.elasticsearch.hosts=['localhost:9200'] \
#    -E output.elasticsearch.username=metricbeat_internal \
#    -E output.elasticsearch.password=YOUR_PASSWORD \
#    -E setup.kibana.host=localhost:5601

#  mkdir -pv /etc/metricbeat/modules.d
#  cat << EOF >> /etc/metricbeat/modules.d/docker.yml
#docker.container.ip_addresses
#EOF

  # Enable and configure the docker module
#  metricbeat modules enable docker
  # Start the metricbeat background service ...
#  metricbeat setup
#  service metricbeat start
fi
