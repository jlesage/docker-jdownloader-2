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
# NOTE: glibc version of the image is needed for the 7-Zip-JBinding workaround.
FROM jlesage/baseimage-gui:alpine-3.9-glibc-v3.5.2

# Define software versions.
ARG JAVAJRE_VERSION=8.212.04.2

# Define software download URLs.
ARG JDOWNLOADER_URL=http://installer.jdownloader.org/JDownloader.jar
ARG JAVAJRE_URL=https://d3pxv6yz143wms.cloudfront.net/${JAVAJRE_VERSION}/amazon-corretto-${JAVAJRE_VERSION}-linux-x64.tar.gz

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
    curl -# -L ${JAVAJRE_URL} | tar -xz --strip 2 -C /opt/jre amazon-corretto-${JAVAJRE_VERSION}-linux-x64/jre && \
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
        ttf-dejavu \
        # For ffmpeg and ffprobe tools.
        ffmpeg \
        # For rtmpdump tool.
        rtmpdump

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
VOLUME ["/output"]

# Expose ports.
#   - 3129: For MyJDownloader in Direct Connection mode.
EXPOSE 3129

# Metadata.
LABEL \
      org.label-schema.name="jdownloader-2" \
      org.label-schema.description="Docker container for JDownloader 2" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-jdownloader-2" \
      org.label-schema.schema-version="1.0"
