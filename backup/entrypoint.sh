#!/usr/bin/env bash

source $(dirname ${0})/functions.sh

log_info "Starting container..."
run_cmd restic version

log_info "Setting up cron daemon [runs at: ${BACKUP_CRON}]..."
echo "${BACKUP_CRON} ${SCRIPTS_DIR}/run.sh >> /var/log/cron.log 2>&1" > /var/spool/cron/crontabs/root

run_cmd touch /var/log/cron.log

# start the cron deamon
run_cmd crond

log_info "Container started."
tail -fn0 /var/log/cron.log
