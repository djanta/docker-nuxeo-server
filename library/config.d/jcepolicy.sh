#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# java.sh - This script will be use to provide our platform deployment architecture
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
source "/library/common.sh"
source "/library/log.sh"

#cacerts="${TRUSTED_STORE:-$JAVA_HOME/lib/security/cacerts}"
if [ -d "$CONFIGD/jcepolicy" ]; then
  log "Importing JCE policy files ..."

#  #cd /Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home/jre/lib/security
#  #ls
#
#  #Rename existing policy
#  sudo mv local_policy.jar local_policy.jar.bak
#  sudo mv US_export_policy.jar US_export_policy.jar.bak
#
#  #Extract downloaded zip
#  tar -xzf ~/Downloads/jce_policy-8.zip
#
#  #Copy new files
#  sudo cp ~/Downloads/UnlimitedJCEPolicyJDK8/local_policy.jar local_policy.jar
#  sudo cp ~/Downloads/UnlimitedJCEPolicyJDK8/US_export_policy.jar US_export_policy.jar

fi
