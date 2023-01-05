#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure mandatory directories exist.
mkdir -p /config/logs

# Set default configuration on new install.
if [ ! -f /config/JDownloader.jar ]; then
    cp /defaults/JDownloader.jar /config/
    cp -r /defaults/cfg /config/
fi

# Set MyJDownloader credentials.
if [ -n "${MYJDOWNLOADER_EMAIL:-}" ] && [ -n "${MYJDOWNLOADER_PASSWORD:-}" ]
then
    TMP="$(mktemp)"
    jq -c -M ".email=\"$MYJDOWNLOADER_EMAIL\" | .password = \"$(echo "$MYJDOWNLOADER_PASSWORD" | sed 's/"/\\"/g')\"" /config/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json > "$TMP"
    mv "$TMP" /config/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
fi

# Set the MyKDownloader device name.
if [ -n "${MYJDOWNLOADER_DEVICE_NAME:-}" ]; then
    TMP="$(mktemp)"
    jq -c -M ".devicename = \"$(echo "$MYJDOWNLOADER_DEVICE_NAME" | sed 's/"/\\"/g')\"" /config/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json > "$TMP"
    mv "$TMP" /config/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
fi

# Handle dark mode change.
if [ "${DARK_MODE:-0}" -eq 0 ]; then
    # Dark mode disabled.  Change theme only if it is currently set to our dark mode.
    CURRENT_THEME="$(jq -r -c -M '.lookandfeeltheme' /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json)"
    if [ "$CURRENT_THEME" = "FLATLAF_DRACULA" ]; then
        TMP="$(mktemp)"
        jq -c -M '.lookandfeeltheme = "DEFAULT"' /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json > "$TMP"
        mv "$TMP" /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json
    fi
else
    # Dark mode enabled.  Force theme.
    TMP="$(mktemp)"
    jq -c -M '.lookandfeeltheme = "FLATLAF_DRACULA"' /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json > "$TMP"
    mv "$TMP" /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json
fi

# Take ownership of the output directory.
if ! chown $USER_ID:$GROUP_ID /output 2>/dev/null; then
    # Failed to take ownership of /output.  This could happen when,
    # for example, the folder is mapped to a network share.
    # Continue if we have write permission, else fail.
    TMPFILE="$(su-exec $USER_ID:$GROUP_ID mktemp /output/.test_XXXXXX 2>/dev/null)"
    if [ $? -eq 0 ]; then
        # Success, we were able to write file.
        su-exec $USER_ID:$GROUP_ID rm "$TMPFILE"
    else
        log "ERROR: Failed to take ownership and no write permission on /output."
        exit 1
    fi
fi

# vim: set ft=sh :
