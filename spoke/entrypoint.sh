#!/bin/bash
set -e

SLEEP_DUR=${SLEEP_DUR:-10}
LOG_DIR=${LOG_DIR:-/log}
ERR_LOG=${ERR_LOG:-"$LOG_DIR/$HOSTNAME/echo_stderr.log"}

restart_message() {
    echo "Container restart on $(date)."
    echo -e "\nContainer restart on $(date)." | tee -a $ERR_LOG
}

normal_start() {
    exec /opt/echo.sh $SLEEP_DUR
}

if [ ! -e /tmp/echo_first_run ]; then
    touch /tmp/echo_first_run
    normal_start
else
    restart_message
    normal_start
fi
