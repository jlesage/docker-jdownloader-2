#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

run() {
    j=1
    while eval "\${pipestatus_$j+:} false"; do
        unset pipestatus_$j
        j=$(($j+1))
    done
    j=1 com= k=1 l=
    for a; do
        if [ "x$a" = 'x|' ]; then
            com="$com { $l "'3>&-
                        echo "pipestatus_'$j'=$?" >&3
                      } 4>&- |'
            j=$(($j+1)) l=
        else
            l="$l \"\$$k\""
        fi
        k=$(($k+1))
    done
    com="$com $l"' 3>&- >&4 4>&-
               echo "pipestatus_'$j'=$?"'
    exec 4>&1
    eval "$(exec 3>&1; eval "$com")"
    exec 4>&-
    j=1
    while eval "\${pipestatus_$j+:} false"; do
        eval "[ \$pipestatus_$j -eq 0 ]" || return 1
        j=$(($j+1))
    done
    return 0
}

log() {
    if [ -n "${1-}" ]; then
        echo "[cont-init.d] $(basename $0): $*"
    else
        while read OUTPUT; do
            echo "[cont-init.d] $(basename $0): $OUTPUT"
        done
    fi
}

# Install requested packages.
if [ "${INSTALL_EXTRA_PKGS:-UNSET}" != "UNSET" ]; then
    log "installing requested package(s)..."
    for PKG in $INSTALL_EXTRA_PKGS; do
        if cat /etc/apk/world | grep -wq "$PKG"; then
            log "package '$PKG' already installed"
        else
            log "installing '$PKG'..."
            run add-pkg "$PKG" 2>&1 \| log
        fi
    done
fi

# Make sure mandatory directories exist.
mkdir -p /config/logs

if [ ! -f /config/JDownloader.jar ]; then
    cp /defaults/JDownloader.jar /config
    cp -r /defaults/cfg /config/
fi

# Take ownership of the config directory content.
find /config -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;

# Take ownership of the output directory.
if ! chown $USER_ID:$GROUP_ID /output; then
    # Failed to take ownership of /output.  This could happen when,
    # for example, the folder is mapped to a network share.
    # Continue if we have write permission, else fail.
    TMPFILE="$(s6-setuidgid $USER_ID:$GROUP_ID mktemp /output/.test_XXXXXX 2>/dev/null)"
    if [ $? -eq 0 ]; then
        # Success, we were able to write file.
        s6-setuidgid $USER_ID:$GROUP_ID rm "$TMPFILE"
    else
        log "ERROR: Failed to take ownership and no write permission on /output."
        exit 1
    fi
fi

# vim: set ft=sh :
