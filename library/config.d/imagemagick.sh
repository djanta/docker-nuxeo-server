#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# imagemagick.sh - This script will be use to provide our platform deployment architecture
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

# shellcheck disable=SC2230

##
# ImageMagick resource configuration: https://imagemagick.org/script/resources.php
##

#Environment Variables
#Environment variables recognized by ImageMagick include:
#
#HOME:	Set path to search for configuration files in $HOME/.config/ImageMagick if the directory exists.
#LD_LIBRARY_PATH:	Set path to the ImageMagick shareable libraries and other dependent libraries.
#MAGICK_AREA_LIMIT:	Set the maximum width * height of an image that can reside in the pixel cache memory. Images that exceed the area limit are cached to disk (see MAGICK_DISK_LIMIT) and optionally memory-mapped.
#MAGICK_CODER_FILTER_PATH:	Set search path to use when searching for filter process modules (invoked via -process). This path permits the user to extend ImageMagick's image processing functionality by adding loadable modules to a preferred location rather than copying them into the ImageMagick installation directory. The formatting of the search path is similar to operating system search paths (i.e. colon delimited for Unix, and semi-colon delimited for Microsoft Windows). This user specified search path is searched before trying the default search path.
#MAGICK_CODER_MODULE_PATH:	Set path where ImageMagick can locate its coder modules. This path permits the user to arbitrarily extend the image formats supported by ImageMagick by adding loadable coder modules from an preferred location rather than copying them into the ImageMagick installation directory. The formatting of the search path is similar to operating system search paths (i.e. colon delimited for Unix, and semi-colon delimited for Microsoft Windows). This user specified search path is searched before trying the default search path.
#MAGICK_CONFIGURE_PATH:	Set path where ImageMagick can locate its configuration files. Use this search path to search for configuration (.xml) files. The formatting of the search path is similar to operating system search paths (i.e. colon delimited for Unix, and semi-colon delimited for Microsoft Windows). This user specified search path is searched before trying the default search path.
#MAGICK_DEBUG:	Set debug options. See -debug for a description of debugging options.
#MAGICK_DISK_LIMIT:	Set maximum amount of disk space in bytes permitted for use by the pixel cache. When this limit is exceeded, the pixel cache is not be created and an error message is returned.
#MAGICK_ERRORMODE:	Set the process error mode (Windows only). A typical use might be a value of 1 to prevent error mode dialogs from displaying a message box and hanging the application.
#MAGICK_FILE_LIMIT:	Set maximum number of open pixel cache files. When this limit is exceeded, any subsequent pixels cached to disk are closed and reopened on demand. This behavior permits a large number of images to be accessed simultaneously on disk, but with a speed penalty due to repeated open/close calls.
#MAGICK_FONT_PATH:	Set path ImageMagick searches for TrueType and Postscript Type1 font files. This path is only consulted if a particular font file is not found in the current directory.
#MAGICK_HEIGHT_LIMIT:	Set the maximum height of an image.
#MAGICK_HOME:	Set the path at the top of ImageMagick installation directory. This path is consulted by uninstalled builds of ImageMagick which do not have their location hard-coded or set by an installer.
#MAGICK_LIST_LENGTH_LIMIT:	Set the maximum length of an image sequence.
#MAGICK_MAP_LIMIT:	Set maximum amount of memory map in bytes to allocate for the pixel cache. When this limit is exceeded, the image pixels are cached to disk (see MAGICK_DISK_LIMIT).
#MAGICK_MEMORY_LIMIT:	Set maximum amount of memory in bytes to allocate for the pixel cache from the heap. When this limit is exceeded, the image pixels are cached to memory-mapped disk (see MAGICK_MAP_LIMIT).
#MAGICK_OCL_DEVICE:	Set to off to disable hardware acceleration of certain accelerated algorithms (e.g. blur, convolve, etc.).
#MAGICK_PRECISION:	Set the maximum number of significant digits to be printed.
#MAGICK_SHRED_PASSES:	If you want to keep the temporary files ImageMagick creates private, overwrite them with zeros or random data before they are removed. On the first pass, the file is zeroed. For subsequent passes, random data is written.
#MAGICK_SYNCHRONIZE:	Set to "true" to ensure all image data is fully flushed and synchronized to disk. There is a performance penalty, however, the benefits include ensuring a valid image file in the event of a system crash and early reporting if there is not enough disk space for the image pixel cache.
#MAGICK_TEMPORARY_PATH:	Set path to store temporary files.
#MAGICK_THREAD_LIMIT:	Set maximum parallel threads. Many ImageMagick algorithms run in parallel on multi-processor systems. Use this environment variable to set the maximum number of threads that are permitted to run in parallel.
#MAGICK_THROTTLE_LIMIT:	Periodically yield the CPU for at least the time specified in milliseconds.
#MAGICK_TIME_LIMIT:	Set maximum time in seconds. When this limit is exceeded, an exception is thrown and processing stops.
#MAGICK_WIDTH_LIMIT:	Set the maximum width of an image.
#SOURCE_DATE_EPOCH:	A UNIX timestamp, defined as the number of seconds, excluding leap seconds, since 01 Jan 1970 00:00:00 UTC.


#if which imagemagick > /dev/null 2>&1; then
if which convert > /dev/null 2>&1; then

  if convert -list policy > /dev/null 2>&1; then
      echo "ImageMagick policy configuration has been successfully loaded ..."
#      ls -als /etc/ | grep "ImageMagick"
#      echo "PATH = $PATH"
#      echo "MAGICK_HOME = $MAGICK_HOME"
#      echo "HOME = $HOME"
  else
      echo "No ImageMagick policy file has been loaded ..."

##
# Credit: https://www.aptgetlife.co.uk/add-policy-imagemagick-debian/
# https://gist.github.com/rawdigits/d73312d21c8584590783a5e07e124723
##
  cat << EOF >> /etc/ImageMagick/policy.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policymap [
<!ELEMENT policymap (policy)+>
<!ELEMENT policy (#PCDATA)>
<!ATTLIST policy domain (delegate|coder|filter|path|resource) #IMPLIED>
<!ATTLIST policy name CDATA #IMPLIED>
<!ATTLIST policy rights CDATA #IMPLIED>
<!ATTLIST policy pattern CDATA #IMPLIED>
<!ATTLIST policy value CDATA #IMPLIED>
]>
<!--
  ##-----------------------------------------------------------------------------
  ## Auto generated configuration at runtime.
  ## Date: $(date '+%Y-%m-%d %T.%3N')
  ## Source: $0
  ##-----------------------------------------------------------------------------

  Configure ImageMagick policies.
  Domains include system, delegate, coder, filter, path, or resource.
  Rights include none, read, write, and execute.  Use | to combine them,
  for example: "read | write" to permit read from, or write to, a path.
  Use a glob expression as a pattern.
  Suppose we do not want users to process MPEG video images:
    <policy domain="delegate" rights="none" pattern="mpeg:decode" />
  Here we do not want users reading images from HTTP:
    <policy domain="coder" rights="none" pattern="HTTP" />
  Lets prevent users from executing any image filters:
    <policy domain="filter" rights="none" pattern="*" />
  The /repository file system is restricted to read only.  We use a glob
  expression to match all paths that start with /repository:

    <policy domain="path" rights="read" pattern="/repository/*" />
  Let's prevent possible exploits by removing the right to use indirect reads.
    <policy domain="path" rights="none" pattern="@*" />
  Any large image is cached to disk rather than memory:
    <policy domain="resource" name="area" value="1GB"/>
  Define arguments for the memory, map, area, width, height, and disk resources
  with SI prefixes (.e.g 100MB).  In addition, resource policies are maximums
  for each instance of ImageMagick (e.g. policy memory limit 1GB, -limit 2GB
  exceeds policy maximum so memory limit is 1GB).
-->
<policymap>
  <!-- <policy domain="resource" name="temporary-path" value="/tmp"/> -->

  <policy domain="resource" name="memory" value="256MiB"/>
  <policy domain="resource" name="map" value="512MiB"/>
  <policy domain="resource" name="width" value="16KP"/>
  <policy domain="resource" name="height" value="16KP"/>
  <policy domain="resource" name="area" value="128MB"/>
  <policy domain="resource" name="disk" value="1GiB"/>

  <!-- Concurrent active thread 1 by default -->
  <policy domain="resource" name="thread" value="${IMAGE_MAGICK_MAX_TREAD:-1}"/>

  <!-- <policy domain="resource" name="file" value="768"/> -->
  <!-- <policy domain="resource" name="throttle" value="0"/> -->
  <!-- <policy domain="resource" name="time" value="3600"/> -->
  <!-- <policy domain="system" name="precision" value="6"/> -->
  <!-- not needed due to the need to use explicitly by mvg: -->
  <!-- <policy domain="delegate" rights="none" pattern="MVG" /> -->

  <!-- use curl -->
  <policy domain="delegate" rights="none" pattern="URL" />
  <policy domain="delegate" rights="none" pattern="HTTPS" />
  <policy domain="delegate" rights="none" pattern="HTTP" />

  <!-- in order to avoid to get image with password text -->
  <policy domain="path" rights="none" pattern="@*"/>
  <policy domain="cache" name="shared-secret" value="passphrase" stealth="true"/>

  <!-- disable ghostscript format types -->
  <policy domain="coder" rights="none" pattern="PS" />
  <policy domain="coder" rights="none" pattern="EPI" />
  <policy domain="coder" rights="read|write" pattern="PDF" />
  <policy domain="coder" rights="none" pattern="XPS" />
</policymap>
EOF

    ## Display the ImageMagick configuration ...
    convert -list policy
  fi
else
  echo "imagemagick does not exist!"
fi
