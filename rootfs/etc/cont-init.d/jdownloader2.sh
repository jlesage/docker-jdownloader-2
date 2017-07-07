#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

if [ ! -f /config/JDownloader.jar ]; then
    cp -r /defaults/* /config/
fi

# First-time run indication.
touch /tmp/.jd_not_started_yet

# Take ownership of the config directory.
chown -R $USER_ID:$GROUP_ID /config

# Take ownership of the output directory.
chown $USER_ID:$GROUP_ID /output

# vim: set ft=sh :
