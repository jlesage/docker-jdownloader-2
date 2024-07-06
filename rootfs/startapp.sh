#!/bin/sh

set -u # Treat unset variables as an error.

trap "exit" TERM QUIT INT
trap "kill_jd" EXIT

# JDownloader logs all environment variables.  Make sure to MyJDownloader
# credentials don't leak.
unset MYJDOWNLOADER_EMAIL
unset MYJDOWNLOADER_PASSWORD

log_debug() {
    if is-bool-val-true "${CONTAINER_DEBUG:-0}"; then
        echo "$@"
    fi
}

get_jd_pid() {
    PID=UNSET
    if [ -f /config/JD2.lock ]; then
        FUSER_STR="$(fuser /config/JD2.lock 2>/dev/null)"
        if [ $? -eq 0 ]; then
            echo "$FUSER_STR" | awk '{print $1}'
            return
        fi
    fi

    echo "UNSET"
}

is_jd_running() {
    [ "$(get_jd_pid)" != "UNSET" ]
}

start_jd() {
    ARGS="/tmp/.jd_args"

    # Handle max memory set via environment variable.
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
    PID="$(get_jd_pid)"
    if [ "$PID" != "UNSET" ]; then
        log_debug "terminating JDownloader2..."
        kill $PID
        wait $PID
        exit $?
    fi
}

# Start JDownloader.
log_debug "starting JDownloader2..."
start_jd

# Wait until it dies.
wait $!

TIMEOUT=10

while true
do
    if is_jd_running; then
        if [ "$TIMEOUT" -lt 10 ]; then
            log_debug "JDownloader2 has restarted."
        fi

        # Reset the timeout.
        TIMEOUT=10
    else
        if [ "$TIMEOUT" -eq 10 ]; then
            log_debug "JDownloader2 exited, checking if it is restarting..."
        elif [ "$TIMEOUT" -eq 0 ]; then
            log_debug "JDownloader2 not restarting, exiting..."
            break
        fi
        TIMEOUT="$(expr $TIMEOUT - 1)"
    fi
    sleep 1
done

# vim:ft=sh:ts=4:sw=4:et:sts=4
