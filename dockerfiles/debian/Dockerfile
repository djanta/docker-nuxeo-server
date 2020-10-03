# vim:set ft=dockerfile:

ARG BUILD_SDK_VERSION
ARG BUILD_DISTRIBUTION_ID

##
# Understanding build args: https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
##
FROM djanta/nuxeo-sdk-${BUILD_DISTRIBUTION_ID}:${BUILD_SDK_VERSION:-20.08}

ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_HASH
ARG BUILD_HASH
#ARG BUILD_TAG
ARG RELEASE_VERSION

# JDK specific build arguments
ARG BUILD_JDK_VERSION

# SDK base image reference build arguments
ARG BUILD_SDK_VERSION

# Nuxeo specific nuxeo build arguments
ARG BUILD_NX_VARIANT
ARG BUILD_NX_VERSION

ARG BUILD_NX_RUN
ARG BUILD_NX_DATA
ARG BUILD_NX_LOG

ARG NUXEO_BASE=/srv/nuxeo
ARG NUXEO_VARIANT=${BUILD_NX_VARIANT:-tomcat}
ARG NUXEO_VERSION=${BUILD_NX_VERSION:-10.10}

ENV CONFIG_D "/var/lib/nuxeo/config.d"
ENV INIT_D "/var/lib/nuxeo/init.d"
ENV SHARED_LIB "/var/lib/nuxeo/shared"

ENV NUXEO_USER nuxeo
ENV NUXEO_HOME $NUXEO_BASE/server
ENV HOME $NUXEO_BASE/server
ENV NUXEO_TPL_HOME $NUXEO_HOME/templates

ENV NUXEO_PORT=${PORT:-8080}
ENV NUXEO_CONF=$NUXEO_HOME/bin/nuxeo.conf
ENV NUXEO_RUN=${BUILD_NX_RUN:-/var/run/nuxeo}
ENV NUXEO_DATA=${BUILD_NX_DATA:-/var/lib/nuxeo/data}
ENV NUXEO_LOG=${BUILD_NX_LOG:-/var/log/nuxeo}
ENV NUXEO_TMP=$NUXEO_HOME/tmp

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

LABEL org.label-schema.docker.cmd.devel="docker run -it --name nuxeo-server-${NUXEO_VERSION} \
  -p 8080:8080 \
  -v $(pwd)/config.d:$CONFIG_D:ro \
  -e NUXEO_DEV_MODE=true \
  $BUILD_TAG"

LABEL org.label-schema.docker.cmd="docker run -it --name nuxeo-server-${NUXEO_VERSION} \
  -p 8080:8080 \
  -v $(pwd)/config.d:$CONFIG_D:ro \
  $BUILD_TAG"

#https://cdn.nuxeo.com/nuxeo-${NUXEO_VERSION}/nuxeo-server-${NUXEO_VERSION}-tomcat.zip
#ENV NUXEO_DIST_BASE http://community.nuxeo.com/static/releases/nuxeo-${NUXEO_VERSION}
#ENV NUXEO_MP_BASE http://community.nuxeo.com/static/releases/nuxeo-${NUXEO_VERSION}/mp

ENV NUXEO_DIST_BASE https://cdn.nuxeo.com/nuxeo-${NUXEO_VERSION}
ENV NUXEO_MP_BASE https://cdn.nuxeo.com/nuxeo-${NUXEO_VERSION}/mp
ENV NUXEO_SERVER_ARCHIVE $NUXEO_DIST_BASE/nuxeo-server-${NUXEO_VERSION}-${NUXEO_VARIANT}.zip

#90ef2ac005020e880b6277510800c30c
ENV NUXEO_MD5=29e67a19bba54099093b51d892926be1
ENV ZIP_OUTPUT="/tmp/nuxeo-distribution-${NUXEO_VARIANT}.zip"

# Remove setuid/setgid binaries from images for security
RUN find / -perm 6000 -type f -exec chmod a-s {} \; || true

# Install OpenJDK 8
# Source: https://adoptopenjdk.net/installation.html?variant=openjdk8&jvmVariant=hotspot
#RUN \
#  # This required to make (adoptopenjdk) work properly
#  mkdir -p /usr/share/man/man1 \
#  && apt-get update \
#  && apt-get install software-properties-common -y \
#  && wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
#  && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
#  && apt-get update -y \
#  && apt-get install adoptopenjdk-8-hotspot -y \
#  && apt-get install openjdk-9-jdk -y

# use jdk8
#update-java-alternatives --set java-8-oracle

#set ulimit -n 65535 in the file /etc/init.d/docker

# Create Nuxeo user
RUN useradd -m -d /home/$NUXEO_USER -u 1000 -s /bin/bash $NUXEO_USER

# Add distribution
RUN curl -fsSL "${NUXEO_SERVER_ARCHIVE}" -o $ZIP_OUTPUT \
#    && echo "$NUXEO_MD5 $ZIP_OUTPUT" | md5sum -c - \
    && mkdir -p /tmp/nuxeo-distribution $(dirname $NUXEO_HOME) \
    && unzip -q -d /tmp/nuxeo-distribution $ZIP_OUTPUT \
    && DISTDIR=$(/bin/ls /tmp/nuxeo-distribution | head -n 1) \
    && mv /tmp/nuxeo-distribution/$DISTDIR $NUXEO_HOME \
    && sed -i -e "s/^org.nuxeo.distribution.package.*/org.nuxeo.distribution.package=docker/" \
    $NUXEO_HOME/templates/common/config/distribution.properties \
    && rm -rfv /tmp/nuxeo-distribution* \
    && chmod +x $NUXEO_HOME/bin/*ctl $NUXEO_HOME/bin/*.sh \
#    # For arbitrary user in the admin group
#    && chmod g+rwX $NUXEO_HOME/bin/*ctl $NUXEO_HOME/bin/*.sh \
    && chown -R 1000:0 $NUXEO_HOME && chmod -R g+rwX $NUXEO_HOME

# Protecting writeable directories to support arbitrary User IDs for OpenShift
# https://docs.openshift.com/container-platform/3.4/creating_images/guidelines.html
RUN mkdir -p ${NUXEO_DATA} && chown -R 1000:0 ${NUXEO_DATA} && chmod -R g+rwX ${NUXEO_DATA} \
  && mkdir -p ${NUXEO_LOG} && chown -R 1000:0 ${NUXEO_LOG} && chmod -R g+rwX ${NUXEO_LOG} \
  && mkdir -p ${NUXEO_RUN} && chown -R 1000:0 ${NUXEO_RUN} && chmod -R g+rwX ${NUXEO_RUN} \
  && mkdir -p ${NUXEO_TMP} && chown -R 1000:0 ${NUXEO_TMP} && chmod -R g+rwX ${NUXEO_TMP} \
  && mkdir -p ${CONFIG_D} && chown -R 1000:0 ${CONFIG_D} && chmod -R g+rX ${CONFIG_D} \
  && mkdir -p ${INIT_D} && chown -R 1000:0 ${INIT_D} && chmod -R g+rX ${INIT_D} \
  && mkdir -p ${SHARED_LIB} && chown -R 1000:0 ${SHARED_LIB} && chmod -R g+rX ${SHARED_LIB} \
  && mkdir -p /packages.d && chown -R 1000:0 /packages.d && chmod -R g+rX /packages.d \
  && chmod g=u /etc/passwd

# Copy the given config.d ...
COPY library $SHARED_LIB/

RUN \
  chmod -R +rx $SHARED_LIB/*.sh \
  ## Make the init.d available and writable for and by the downstream
  && chmod -R g+rwX ${SHARED_LIB}/init.d

#Create and copy the .bundle file into the current working directory
RUN mkdir -pv /packages

COPY packages/* /packages/

# Download all provided preset marketplace distribution
RUN while read FILE; \
  do \
    echo "Downloading package: ${NUXEO_MP_BASE}/${FILE}.zip"; \
    curl -fsSL "${NUXEO_MP_BASE}/${FILE}.zip" -o /packages.d/${FILE}.zip; \
  done < /packages/.bundle

# Empty the installable package directories
RUN \
  rm -rf /packages

# Inject NUXEO into system path
ENV PATH $NUXEO_HOME/bin:$PATH

# Using NUXEO HOME as default user home
WORKDIR $NUXEO_HOME

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080

CMD ["nuxeoctl", "console"]

# Switch back to nuxeo default user ID
USER 1000

# vim:set et ts=2 sw=2:
