#!/bin/sh

set -u # Treat unset variables as an error.

trap "exit" TERM QUIT INT
trap "kill_jd" EXIT

log() {
    echo "[jdsupervisor] $*"
}

getpid_jd() {
    PID=UNSET
    if [ -f /config/JDownloader.pid ]; then
        PID="$(cat /config/JDownloader.pid)"
        # Make sure the saved PID is still running and is associated to
        # JDownloader.
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "JDownloader.jar"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -o pid,args | grep -w "JDownloader.jar" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_jd_running() {
    [ "$(getpid_jd)" != "UNSET" ]
}

start_jd() {
    /usr/bin/java \
        -Dawt.useSystemAAFontSettings=gasp \
        -Djava.awt.headless=false \
        -jar /config/JDownloader.jar >/config/logs/output.log 2>&1 &
}

kill_jd() {
    PID="$(getpid_jd)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating JDownloader2..."
        kill $PID
        wait $PID
    fi
}

if ! is_jd_running; then
    log "JDownloader2 not started yet.  Proceeding..."
    start_jd
fi

JD_NOT_RUNNING=0
while [ "$JD_NOT_RUNNING" -lt 5 ]
do
    if is_jd_running; then
        JD_NOT_RUNNING=0
    else
        JD_NOT_RUNNING="$(expr $JD_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "JDownloader2 no longer running.  Exiting..."
