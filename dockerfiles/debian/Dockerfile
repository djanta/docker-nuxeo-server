# vim:set ft=dockerfile:

ARG BUILD_SDK_VERSION
ARG BUILD_DISTRIB

##
# Understanding build args: https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
##
FROM djanta/nuxeo-sdk:${BUILD_SDK_VERSION:-20.08}-${BUILD_DISTRIB:-debian}

ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_HASH
ARG BUILD_DISTRIB

ARG RELEASE_VERSION
ARG BUILD_JDK_VERSION
ARG BUILD_SDK_VERSION

ARG BUILD_NX_VARIANT
ARG BUILD_NX_VERSION
ARG BUILD_NX_CLID

ARG BUILD_NX_RUN
ARG BUILD_NX_DATA
ARG BUILD_NX_LOG

ARG NUXEO_BASE=/srv/nuxeo
ARG NUXEO_VARIANT=${BUILD_NX_VARIANT:-tomcat}
ARG NUXEO_VERSION=${BUILD_NX_VERSION:-10.10}

ENV NUXEO_USER nuxeo
ENV NUXEO_HOME $NUXEO_BASE/server
ENV HOME $NUXEO_HOME
ENV NUXEO_TPL_HOME $NUXEO_HOME/templates

ENV NUXEO_PORT=${PORT:-8080}
ENV NUXEO_CONF=$NUXEO_HOME/bin/nuxeo.conf
ENV NUXEO_RUN=${BUILD_NX_RUN:-/var/run/nuxeo}
ENV NUXEO_DATA=${BUILD_NX_DATA:-/var/lib/nuxeo/data}
ENV NUXEO_LOG=${BUILD_NX_LOG:-/var/log/nuxeo}
ENV NUXEO_TMP=$NUXEO_HOME/tmp

ENV CONFIG_D "/var/lib/nuxeo/config.d"
ENV PACKAGE_D "/var/lib/nuxeo/package.d"
#ENV INIT_D "/var/lib/nuxeo/init.d"
#ENV SHARED_D "/var/lib/nuxeo/shared"

LABEL maintainer="DJANTA, LLC <cloud.packager@djanta.io>"
LABEL author="Koffi Stanislas ASSOUTOVI"
LABEL company="DJANTA, LLC"
LABEL SDK=$BUILD_SDK_VERSION
LABEL relase=$RELEASE_VERSION

###
# Schema standardization reference
## http://label-schema.org/rc1/
###
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name=$BUILD_TAG
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vendor="DJANTA, LLC"
LABEL org.label-schema.url="https://djanta.io/"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.description="DJANTA.IO Nuxeo customized server"
LABEL org.label-schema.vcs-url="https://github.com/djanta/docker-nuxeo-server"
LABEL org.label-schema.vcs-ref=$BUILD_HASH

LABEL org.label-schema.docker.cmd.devel="docker run -it --name nuxeo-server-${NUXEO_VERSION}-${BUILD_DISTRIB} \
  -p 8080:8080 \
  -p 8787:8787 \
  -p 9443:9443 \
  -v $(pwd)/config.d:$CONFIG_D:ro \
  -e NUXEO_DEV_MODE=true \
  -e NUXEO_CTL_DEBUG=org.nuxeo \
  djanta/nuxeo-server:${NUXEO_VERSION}-${BUILD_DISTRIB}"

LABEL org.label-schema.docker.cmd="docker run -it --name nuxeo-server-${NUXEO_VERSION}-${BUILD_DISTRIB} \
  -p 8080:8080 \
  -v $(pwd)/config.d:$CONFIG_D:ro \
  djanta/nuxeo-server:${NUXEO_VERSION}-${BUILD_DISTRIB}"

# https://cdn.nuxeo.com/nuxeo-${NUXEO_VERSION}/nuxeo-server-${NUXEO_VERSION}-tomcat.zip
# ENV NUXEO_DIST_BASE http://community.nuxeo.com/static/releases/nuxeo-${NUXEO_VERSION}
# ENV NUXEO_MP_BASE http://community.nuxeo.com/static/releases/nuxeo-${NUXEO_VERSION}/mp

ENV NUXEO_DIST_BASE https://cdn.nuxeo.com/nuxeo-${NUXEO_VERSION}
ENV NUXEO_MP_BASE https://cdn.nuxeo.com/nuxeo-${NUXEO_VERSION}/mp
ENV NUXEO_SERVER_ARCHIVE $NUXEO_DIST_BASE/nuxeo-server-${NUXEO_VERSION}-${NUXEO_VARIANT}.zip

#90ef2ac005020e880b6277510800c30c
ENV NUXEO_MD5=29e67a19bba54099093b51d892926be1
ENV ZIP_OUTPUT="/tmp/nuxeo-distribution-${NUXEO_VARIANT}.zip"

## Remove setuid/setgid binaries from images for security
#RUN find / -perm 6000 -type f -exec chmod a-s {} \; || true

#set ulimit -n 65535 in the file /etc/init.d/docker

# Using NUXEO HOME as default user home
USER root

# hadolint:[DL4006] requires this line to be defined before any RUN command
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create Nuxeo user
#RUN useradd -m -d /home/$NUXEO_USER -g root -G sudo -u 1001 -s /bin/bash $NUXEO_USER

# Add distribution
RUN curl -fsSL "${NUXEO_SERVER_ARCHIVE}" -o $ZIP_OUTPUT \
# && echo "$NUXEO_MD5 $ZIP_OUTPUT" | md5sum -c - \
  && mkdir -p /tmp/nuxeo-distribution $(dirname $NUXEO_HOME) \
  && unzip -q -d /tmp/nuxeo-distribution $ZIP_OUTPUT \
  && DISTDIR=$(/bin/ls /tmp/nuxeo-distribution | head -n 1) \
  && mv /tmp/nuxeo-distribution/$DISTDIR $NUXEO_HOME \
  && sed -i -e "s/^org.nuxeo.distribution.package.*/org.nuxeo.distribution.package=docker/" \
  $NUXEO_HOME/templates/common/config/distribution.properties \
  && rm -rfv /tmp/nuxeo-distribution* \
# # For arbitrary user in the admin group
#  && chown -Rv 1001:0 $NUXEO_HOME \
  && chmod g+rwx $NUXEO_HOME \
  && chmod -Rv g+rwx $NUXEO_HOME/* \
  && chmod g+wx $NUXEO_HOME/bin/*ctl $NUXEO_HOME/bin/*.sh

# Protecting writeable directories to support arbitrary User IDs for OpenShift
# https://docs.openshift.com/container-platform/3.4/creating_images/guidelines.html
RUN \
  mkdir -p $NUXEO_DATA \
  && chmod -Rv g+rw $NUXEO_DATA \
  && mkdir -pv $NUXEO_LOG \
  && chmod -Rv g+rw $NUXEO_LOG \
  && mkdir -pv $NUXEO_RUN \
  && chmod -Rv g+rw $NUXEO_RUN \
  && mkdir -pv $NUXEO_TMP \
  && chmod -Rv g+rwx $NUXEO_TMP \
  && mkdir -pv $CONFIG_D \
  && chmod -Rv g+rx $CONFIG_D \

# package.d configuration ...
  && mkdir -pv /packages.d \
  && chmod -R g+rx /packages.d \

## Grant password permission
#  && chown -Rv 1001:0 /etc/passwd \
  && chmod g=u /etc/passwd

# Inject NUXEO into the system path
ENV PATH $NUXEO_HOME/bin:$PATH

## # Initialize the platform marketplace configuration by default.
#RUN \
#  nuxeoctl mp-init

# Copy the given config.d ...
ADD library /library

##
# Copy the pre-bundle to be installed ...
##
ADD packages /packages

# Copy the nuxeo license if provided at build time
RUN \
  if [ -n "$BUILD_NX_CLID" ]; then \
    BUILD_NX_CLID="${BUILD_NX_CLID/--/\\n}"; \
    printf "%b\n" "$BUILD_NX_CLID" >> "$NUXEO_DATA"/instance.clid; \
  fi

# Install all (hotfixes and addons) in the given order
RUN \
  for scope in "hotfixes" "addons"; do \
    for package in /packages/$scope/*; do \
      case $package in \
        *.zip) \
          nuxeoctl mp-install --accept=true --relax=true "$package" > /dev/null 2>&1; \
          ;; \
        *.jar) \
          cp "$package" "$NUXEO_HOME/nxserver/plugins/"; \
          ;; \
      esac \
    done; \
  done

# Download all provided preset marketplace distribution
RUN while read id; \
  do \
    echo "Installing package: $NUXEO_MP_BASE/$id.zip ..."; \
    nuxeoctl mp-install $id --accept=true --relax=true  > /dev/null 2>&1; \
  done < /packages/.pre-bundle

# Remove every local package once installed ...
RUN \
  rm -rfv /packages

# Switch back to nuxeo default user ID
#USER 1001

# Using NUXEO HOME as default user home
WORKDIR $NUXEO_HOME

COPY entrypoint.sh /

EXPOSE 8080
EXPOSE 8787
EXPOSE 9443
EXPOSE 5432

ENTRYPOINT ["/entrypoint.sh"]

# Run command
CMD ["nuxeoctl", "console"]

# vim:set et ts=2 sw=2:
