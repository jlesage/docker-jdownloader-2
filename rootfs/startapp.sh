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
    if is-bool-val-true "${JDOWNLOADER_HEADLESS:-0}"; then
        /usr/bin/java \
            -XX:-UsePerfData \
            -Djava.awt.headless=true \
            -jar /config/JDownloader.jar >/config/logs/output.log 2>&1 &
    else
        /usr/bin/java \
            -XX:-UsePerfData \
            -Dawt.useSystemAAFontSettings=gasp \
            -Djava.awt.headless=false \
            -jar /config/JDownloader.jar >/config/logs/output.log 2>&1 &
    fi
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
