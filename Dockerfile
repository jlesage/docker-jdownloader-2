#
# jdownloader-2 Dockerfile
#
# https://github.com/jlesage/docker-jdownloader-2
#
# NOTES:
#   - We are using JRE version 8 because recent versions are much bigger.
#   - JRE for ARM 32-bits on Alpine is very hard to get:
#     - The version in Alpine repo is very, very slow.
#     - The glibc version doesn't work well on Alpine with a compatibility
#       layer (gcompat or libc6-compat).  The `__xstat` symbol is missing and
#       implementing a wrapper is not straight-forward because the `struct stat`
#       is not constant across architectures (32/64 bits) and glibc/musl.
#

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software download URLs.
ARG JDOWNLOADER_URL=https://installer.jdownloader.org/JDownloader.jar

# Download JDownloader2
FROM --platform=$BUILDPLATFORM alpine:3.20 AS jd2
ARG JDOWNLOADER_URL
RUN \
    apk --no-cache add curl && \
    mkdir -p /defaults && \
    curl -# -L -o /defaults/JDownloader.jar ${JDOWNLOADER_URL}

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.20-v4.10.2

ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN \
    add-pkg \
        java-common \
        openjdk8-jre \
        # Needed by the init script.
        jq \
        # We need a font.
        ttf-dejavu \
        # For fixing JD installation.
        curl \
        # For ffmpeg and ffprobe tools.
        ffmpeg \
        # For rtmpdump tool.
        rtmpdump \
        # Need for the sponge tool.
        moreutils

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/jdownloader-2-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=jd2 /defaults/JDownloader.jar /defaults/JDownloader.jar

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "JDownloader 2" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Set public environment variables.
ENV \
    MYJDOWNLOADER_EMAIL= \
    MYJDOWNLOADER_PASSWORD= \
    MYJDOWNLOADER_DEVICE_NAME= \
    JDOWNLOADER_HEADLESS=0 \
    JDOWNLOADER_MAX_MEM=

# Define mountable directories.
VOLUME ["/output"]

# Expose ports.
#   - 3129: For MyJDownloader in Direct Connection mode.
EXPOSE 3129

# Metadata.
LABEL \
      org.label-schema.name="jdownloader-2" \
      org.label-schema.description="Docker container for JDownloader 2" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-jdownloader-2" \
      org.label-schema.schema-version="1.0"
