#!/usr/bin/env bash

source $(dirname ${0})/functions.sh

log_info "Storing environment variables to ${SCRIPTS_DIR}/config.sh..."

truncate_config
save_to_config RESTIC_HOSTNAME
save_to_config RESTIC_DATA
save_to_config RESTIC_REPO
save_to_config B2_ACCOUNT_ID
save_to_config B2_ACCOUNT_KEY
save_to_config RESTIC_PASSWORD
save_to_config RESTIC_OPTIONS
save_to_config RESTIC_BACKUP_OPTIONS
save_to_config RESTIC_FORGET_OPTIONS

log_info "Starting container..."
run_cmd restic version

check_env RESTIC_HOSTNAME
check_zero_length RESTIC_HOSTNAME
check_env BACKUP_CRON

log_info "Setting up cron daemon [runs at: ${BACKUP_CRON}]..."
echo "${BACKUP_CRON} ${SCRIPTS_DIR}/run.sh >> /var/log/cron.log 2>&1" > /var/spool/cron/crontabs/root

run_cmd touch /var/log/cron.log

# start the cron deamon
run_cmd crond

log_info "Container started."
tail -fn0 /var/log/cron.log
