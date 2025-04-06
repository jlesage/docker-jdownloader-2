#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Make sure mandatory directories exist.
mkdir -p /config/logs

# Fix installation if requested.
# https://support.jdownloader.org/en/knowledgebase/article/fix-jdownloader-installation
if [ -f /config/.fix_jd_install ]; then
    TO_REMOVE="
        Core.Jar
        JDownloader.jar
        tmp
        update
    "

    echo "fixing JDownloader installation..."
    echo "$TO_REMOVE" | while read -r FILE; do
        [ -n "$FILE" ] || continue
        echo "removing /config/$FILE..."
        rm -rf /config/"$FILE"
    done

    if [ "$(cat /config/.fix_jd_install)" = "download" ]; then
        JDOWNLOADER_URL=https://installer.jdownloader.org/JDownloader.jar
        echo "downloading JDownloader installer..."
        if curl -s -L --show-error --fail --max-time 120 -o /tmp/JDownloader.jar.download "$JDOWNLOADER_URL"
        then
            mv /tmp/JDownloader.jar.download /config/JDownloader.jar
        else
            echo "failed to download JDownloader installer."
        fi
    fi

    echo "installation fix done."
    rm /config/.fix_jd_install
fi

# Remove JDownloader.jar if it has been corrupted.
if [ -f /config/JDownloader.jar ]; then
    if ! unzip -t /config/JDownloader.jar 2>/dev/null; then
        echo "JDownloader.jar corrupted, removing."
        rm /config/JDownloader.jar
    fi
fi

# Set default configuration on new install.
[ -f /config/JDownloader.jar ] || {
    cp -v /defaults/JDownloader.jar /config/JDownloader.jar
    # Since JDownloader.jar have been copied, keep the installation in a
    # compatible state by making sure Core.jar and the update directory are
    # removed.
    rm -rf /config/Core.jar /config/update
}
[ -d /config/cfg ] || cp -rv /defaults/cfg /config/cfg

# Set MyJDownloader credentials.
if [ -n "${MYJDOWNLOADER_EMAIL:-}" ] && [ -n "${MYJDOWNLOADER_PASSWORD:-}" ]
then
    jq -c -M ".email=\"$MYJDOWNLOADER_EMAIL\" | .password = \"$(echo "$MYJDOWNLOADER_PASSWORD" | sed 's/"/\\"/g')\"" /config/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json | sponge /config/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
fi

# Set the MyJDownloader device name.
if [ -n "${MYJDOWNLOADER_DEVICE_NAME:-}" ]; then
    jq -c -M ".devicename = \"$(echo "$MYJDOWNLOADER_DEVICE_NAME" | sed 's/"/\\"/g')\"" /config/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json | sponge /config/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
fi

# Validate the max memory value.
if [ -n "${JDOWNLOADER_MAX_MEM:-}" ]; then
    if ! echo "$JDOWNLOADER_MAX_MEM" | grep -q "^[0-9]\+[g|G|m|M|k|K]$"
    then
        echo "ERROR: invalid value for JDOWNLOADER_MAX_MEM variable: '$JDOWNLOADER_MAX_MEM'."
        exit 1
    fi
    echo "JDownloader 2 maximum memory is set to $JDOWNLOADER_MAX_MEM"
fi

# Handle dark mode change.
if is-bool-val-false "${DARK_MODE:-0}"; then
    # Dark mode disabled.  Change theme only if it is currently set to our dark mode.
    CURRENT_THEME="$(jq -r -c -M '.lookandfeeltheme' /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json)"
    if [ "$CURRENT_THEME" = "FLATLAF_DRACULA" ]; then
        jq -c -M '.lookandfeeltheme = "DEFAULT"' /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json | sponge /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json
    fi
else
    # Dark mode enabled.  Force theme.
    jq -c -M '.lookandfeeltheme = "FLATLAF_DRACULA"' /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json | sponge /config/cfg/org.jdownloader.settings.GraphicalUserInterfaceSettings.json
fi

# Take ownership of the output directory.
take-ownership --not-recursive /output

# vim:ft=sh:ts=4:sw=4:et:sts=4
