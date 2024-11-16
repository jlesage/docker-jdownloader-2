#!/bin/sh

set -u # Treat unset variables as an error.

trap "terminate" TERM QUIT INT

# JDownloader logs all environment variables.  Make sure the MyJDownloader
# credentials don't leak.
unset MYJDOWNLOADER_EMAIL
unset MYJDOWNLOADER_PASSWORD

log_debug() {
    if is-bool-val-true "${CONTAINER_DEBUG:-0}"; then
        echo "$@"
    fi
}

is_jd_running() {
    pgrep java >/dev/null
}

start_jd() {
    ARGS="/tmp/.jd_args"

    # Handle max memory from environment variable.
    if [ -n "${JDOWNLOADER_MAX_MEM:-}" ]; then
        # NOTE: It is assumed that the max memory value has already been
        # validated.
        echo "-Xmx$JDOWNLOADER_MAX_MEM" >> "$ARGS"
    fi

    # Support for JDownloader2.vmoptions.
    # https://support.jdownloader.org/Knowledgebase/Article/View/vmoptions-file
    if [ -f /config/JDownloader2.vmoptions ]; then
        cat /config/JDownloader2.vmoptions >> "$ARGS"
    fi

    if is-bool-val-true "${JDOWNLOADER_HEADLESS:-0}"; then
        echo "-XX:-UsePerfData" >> "$ARGS"
        echo "-Djava.awt.headless=true" >> "$ARGS"
    else
        echo "-XX:-UsePerfData" >> "$ARGS"
        echo "-Dawt.useSystemAAFontSettings=gasp" >> "$ARGS"
        echo "-Djava.awt.headless=false" >> "$ARGS"
    fi

    echo "-jar" >> "$ARGS"
    echo "/config/JDownloader.jar" >> "$ARGS"

    cat "$ARGS" | grep -v "^\s*#" | tr '\n' '\0' | xargs -0 \
        /usr/bin/java >/config/logs/output.log 2>&1 &
}

kill_jd() {
    # Kill JDownloader.
    killall java 2>/dev/null

    # Wait for JDownloader to terminate.
    while is_jd_running; do
        sleep 0.25
    done
}

terminate() {
    log_debug "terminating JDownloader2..."
    kill_jd
    log_debug "JDownloader2 terminated."
    exit 0
}

# Start JDownloader.
#
# NOTE: Because JDownloader can restart itself (e.g. during an update), we have
#       to launch JDownloader in background and monitor its status. This is
#       needed to make sure the container doesn't terminate itself during a
#       restart of JDownloader.
log_debug "starting JDownloader2..."
start_jd

# Wait until it dies.
wait $!

# Now monitor its state. At this point, we cannot "wait" on the process since
# it has not been launched by us.
while true
do
    if ! is_jd_running; then
        log_debug "JDownloader2 not running, exiting..."
        break
    fi
    sleep 1
done

# vim:ft=sh:ts=4:sw=4:et:sts=4
