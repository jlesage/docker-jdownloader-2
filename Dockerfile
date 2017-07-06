#
# jdownloader-2 Dockerfile
#
# https://github.com/jlesage/docker-jdownloader-2
#

# Pull base image.
# NOTE: Need to keep Alpine 3.5 until the following bug is resolved:
#       https://bugs.alpinelinux.org/issues/7372
FROM jlesage/baseimage-gui:alpine-3.5-v1.5.0

# Define software download URLs.
ARG JDOWNLOADER_URL=http://installer.jdownloader.org/JDownloader.jar

# Define working directory.
WORKDIR /tmp

# Download JDownloader 2.
RUN \
    mkdir -p /defaults && \
    wget ${JDOWNLOADER_URL} -O /defaults/JDownloader.jar

# Install dependencies.
RUN \
    apk --no-cache add \
        openjdk8-jre \
        ttf-dejavu

# Maximize only the main/initial window.
RUN \
    sed -i 's/<application type="normal">/<application type="normal" title="JDownloader 2">/' \
        $HOME/.config/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/jdownloader-2-icon.png && \
    /opt/install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="JDownloader 2" \
    S6_KILL_FINISH_MAXTIME=20000

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
