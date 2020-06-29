FROM djanta/nuxeo-sdk:8.10-develop AS NX810

ARG BUILD_VERSION
ARG BUILD_HASH

LABEL maintainer="DJANTA, LLC <team.docker@djanta.io>"
LABEL author="Stanislas Koffi ASSOUTOVI"
LABEL company="DJANTA, LLC"
## http://label-schema.org/rc1/
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="djanta/nuxeo-server"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vendor="DJANTA, LLC"
LABEL org.label-schema.url="https://djanta.io/"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.description="DJANTA.IO Nuxeo customized server"
LABEL org.label-schema.vcs-url="https://github.com/djanta/docker-nuxeo-server"
LABEL org.label-schema.vcs-ref=$BUILD_HASH
LABEL org.label-schema.docker.cmd.devel = "docker run -d -p 8080:8080 -v ~/projects:/projects -e LIVE_PROJECT=/projects djanta/nuxeo-server:$BUILD_VERSION"
LABEL org.label-schema.docker.cmd="docker run -p 8080:8080 -d djanta/nuxeo-server:$BUILD_VERSION"

# Remove setuid/setgid binaries from images for security
RUN find / -perm 6000 -type f -exec chmod a-s {} \; || true

ENV NUXEO_USER nuxeo
ENV NUXEO_BASE /srv/nuxeo
ENV NUXEO_HOME $NUXEO_BASE/server
ENV HOME $NUXEO_BASE/server
ENV NUXEO_TPL_HOME $NUXEO_HOME/templates
ENV NUXEO_PORT=${PORT:-8080}

ENV NUXEO_VARIANT=${VARIANT:-tomcat}
ENV NUXEO_VERSION=${VERSION:-8.10}

ENV NUXEO_DIST_BASE http://community.nuxeo.com/static/releases/nuxeo-${NUXEO_VERSION}
ENV NUXEO_MP_BASE http://community.nuxeo.com/static/releases/nuxeo-${NUXEO_VERSION}/mp
ENV NUXEO_SERVER_ARCHIVE=$NUXEO_DIST_BASE/nuxeo-server-${NUXEO_VERSION}-${NUXEO_VARIANT}.zip

ARG NUXEO_MD5=29e67a19bba54099093b51d892926be1
ARG ZIP_OUTPUT="/tmp/nuxeo-distribution-${NUXEO_VARIANT}.zip"

# Create Nuxeo user
RUN useradd -m -d /home/$NUXEO_USER -u 1000 -s /bin/bash $NUXEO_USER

# Add distribution
RUN curl -fsSL "${NUXEO_SERVER_ARCHIVE}" -o $ZIP_OUTPUT \
    && echo "$NUXEO_MD5 $ZIP_OUTPUT" | md5sum -c - \
    && mkdir -p /tmp/nuxeo-distribution $(dirname $NUXEO_HOME) \
    && unzip -q -d /tmp/nuxeo-distribution $ZIP_OUTPUT \
    && DISTDIR=$(/bin/ls /tmp/nuxeo-distribution | head -n 1) \
    && mv /tmp/nuxeo-distribution/$DISTDIR $NUXEO_HOME \
    && sed -i -e "s/^org.nuxeo.distribution.package.*/org.nuxeo.distribution.package=docker/" \
    $NUXEO_HOME/templates/common/config/distribution.properties \

    && rm -rf /tmp/nuxeo-distribution* \
    && chmod +x $NUXEO_HOME/bin/*ctl $NUXEO_HOME/bin/*.sh \

    # For arbitrary user in the admin group
    && chmod g+rwX $NUXEO_HOME/bin/*ctl $NUXEO_HOME/bin/*.sh \
    && chown -R 1000:0 $NUXEO_HOME && chmod -R g+rwX $NUXEO_HOME

# Protecting writeable directories to support arbitrary User IDs for OpenShift
# https://docs.openshift.com/container-platform/3.4/creating_images/guidelines.html
RUN mkdir -p /var/lib/nuxeo/data \
    && chown -R 1000:0 /var/lib/nuxeo/data && chmod -R g+rwX /var/lib/nuxeo/data \
    && mkdir -p /var/log/nuxeo \
    && chown -R 1000:0 /var/log/nuxeo && chmod -R g+rwX /var/log/nuxeo \
    && mkdir -p /var/run/nuxeo \
    && chown -R 1000:0 /var/run/nuxeo && chmod -R g+rwX /var/run/nuxeo \
    && mkdir -p /docker-entrypoint-initnuxeo.d \
    && chown -R 1000:0 /docker-entrypoint-initnuxeo.d && chmod -R g+rwX /docker-entrypoint-initnuxeo.d \
    && chmod g=u /etc/passwd

#Create and copy the .bundle file into the current working directory
RUN mkdir -pv /packages
COPY packages/.* /packages/

# Download all provided preset marketplace distribution
RUN while read file; \
  do \
    curl -fsSL "${NUXEO_MP_BASE}/${file}.zip" -o /docker-entrypoint-initnuxeo.d/${file}.zip; \
  done < /packages/.nuxeo

ENV PATH $NUXEO_HOME/bin:$PATH
WORKDIR $NUXEO_HOME

# Properly create the guest script directory ...
RUN mkdir -p /scripts
COPY entrypoint.sh /

# Copy the given script directory into the current root directory ...
COPY scripts/*.sh /scripts/

# Ensure the file to be executable
RUN chmod -R +x /*.sh
RUN chmod -R +x /scripts/*.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE $NUXEO_PORT
CMD ["nuxeoctl", "console"]

USER 1000
