#
# jdownloader-2 Dockerfile
#
# https://github.com/jlesage/docker-jdownloader-2
#
# ##############################################################################
# 7-Zip-JBinding Workaround
#
# JDownloader works well with the native openjdk8-jre package.  There is one
# exception: the auto archive extractor.  This feature uses 7-Zip-JBinding,
# which provides a platform-specific library (.so).  The one for Linux x86_64
# has been compiled against glibc and this is not loading correctly on Alpine.
#
# To work around this issue (until we get a proper support of 7-Zip-JBinding on
# Alpine), we need to:
#     - Get glibc, by using the glibc version of the baseimage.
#     - Use Oracle JRE, to have a glibc-based Java VM.
# ##############################################################################

# Pull base image.
# NOTE: Need to keep Alpine 3.5 until the following bug is resolved:
#       https://bugs.alpinelinux.org/issues/7372
# NOTE: glibc version of the image is needed for the 7-Zip-JBinding workaround.
FROM jlesage/baseimage-gui:alpine-3.5-glibc-v3.3.2

# Define software download URLs.
ARG JDOWNLOADER_URL=http://installer.jdownloader.org/JDownloader.jar
ARG ORACLEJAVAJRE_URL=http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/server-jre-8u131-linux-x64.tar.gz

# Define working directory.
WORKDIR /tmp

# Download JDownloader 2.
RUN \
    mkdir -p /defaults && \
    wget ${JDOWNLOADER_URL} -O /defaults/JDownloader.jar

# Download and install Oracle JRE.
# NOTE: This is needed only for the 7-Zip-JBinding workaround.
RUN \
    add-pkg --virtual build-dependencies curl && \
    mkdir /opt/jre && \
    curl -# -L -H "Cookie: oraclelicense=accept-securebackup-cookie" ${ORACLEJAVAJRE_URL} | tar -xz --strip 2 -C /opt/jre jdk1.8.0_131/jre && \
    rm -r /opt/jre/lib/oblique-fonts && \
    del-pkg build-dependencies

# Install dependencies.
RUN \
    add-pkg \
        # For the 7-Zip-JBinding workaround, Oracle JRE is needed instead of
        # the Alpine Linux's openjdk native package.
        # The libstdc++ package is also needed as part of the 7-Zip-JBinding
        # workaround.
        #openjdk8-jre \
        libstdc++ \
        ttf-dejavu

# Maximize only the main/initial window.
RUN \
    sed-patch 's/<application type="normal">/<application type="normal" title="JDownloader 2">/' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/jdownloader-2-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="JDownloader 2" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]
VOLUME ["/output"]

# Metadata.
LABEL \
      org.label-schema.name="jdownloader-2" \
      org.label-schema.description="Docker container for JDownloader 2" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-jdownloader-2" \
      org.label-schema.schema-version="1.0"
