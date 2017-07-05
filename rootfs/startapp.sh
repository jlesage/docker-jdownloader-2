#!/bin/sh

set -u # Treat unset variables as an error.

# Make sure we appear with a proper name under `ps`.
#if [ ! -L "$0" ]; then
#    ln -s run "$(dirname "$0")/jdstarter"
#    exec "$(dirname "$0")/jdstarter" "$@"
#fi

trap "exit" TERM QUIT INT
trap "kill_jd" EXIT

log() {
    echo "[jdstarter] $*"
}

is_jd_running() {
    ps | grep -vw "grep" | grep -qw "JDownloader.jar"
}

start_jd() {
    /usr/lib/jvm/java-1.8-openjdk/jre/bin/java \
        -Dawt.useSystemAAFontSettings=gasp \
        -Djava.awt.headless=false \
        -jar /config/JDownloader.jar &>/config/output.log &
}

kill_jd() {
    PID="$(ps -o pid,args | grep -w "JDownloader.jar" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    if [ "${PID:-UNSET}" != "UNSET" ]; then
        log "Terminating JDownloader2..."
        kill $PID
        while is_jd_running; do sleep 1; done
    fi
}

JD_STARTED=0
JD_STOPPED=0
while [ "$JD_STOPPED" -le 2 ]
do
    if is_jd_running; then
        JD_STARTED=1
        JD_STOPPED=0
    elif [ "$JD_STARTED" -eq 0 ]; then
        log "JDownloader2 not started yet.  Proceeding..."
        start_jd
        JD_STARTED=1
    else
        JD_STOPPED="$(expr $JD_STOPPED + 1)"
    fi
    sleep 1
done

log "JDownloader2 no longer running.  Exiting..."
