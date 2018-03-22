#!/usr/bin/env bash

source $(dirname ${0})/functions.sh
source ${CONFIG_FILENAME}

# Checks all environment variables and prints values
IFS=':' read -a RESTIC_DATA <<< "${RESTIC_DATA}" #colon-separated to array
check_array_env RESTIC_DATA

IFS=':' read -a RESTIC_REPO <<< "${RESTIC_REPO}" #colon-separated to array
check_array_env RESTIC_REPO

if [ "${#RESTIC_DATA[@]}" != "${#RESTIC_REPO[@]}" ]; then
  log_error "Number of local folders (${#RESTIC_DATA[@]}) does not match remote repositories (${#RESTIC_REPO[@]}). Aborting..."
  exit 1
fi

check_env RESTIC_HOSTNAME
check_env RESTIC_OPTIONS
check_env RESTIC_BACKUP_OPTIONS
check_env RESTIC_FORGET_OPTIONS
check_pass B2_ACCOUNT_ID
check_pass B2_ACCOUNT_KEY
check_pass RESTIC_PASSWORD

log_info ""
log_info "Starting backup of ${#RESTIC_DATA[@]} repositories from ${RESTIC_HOSTNAME}..."
log_info ""

first_start=$(date +%s)


for index in "${!RESTIC_DATA[@]}"; do

  ldir=${RESTIC_DATA[${index}]}
  repo=${RESTIC_REPO[${index}]}

  log_info "## Starting backup ${ldir} -> ${repo}..."

  _start=$(date +%s)
  run_cmd restic --repo ${repo} ${RESTIC_OPTIONS} backup --hostname ${RESTIC_HOSTNAME} ${RESTIC_BACKUP_OPTIONS} ${ldir}
  _status=$?
  _end=$(date +%s)
  _htime=$(human_time $((_end-_start)))
  if [[ ${_status} != 0 ]]; then
    log_info "Failed backup ${ldir} -> ${repo}. Aborting..."
    run_cmd restic unlock
    kill 1
  fi

  log_info "## Finished backup ${ldir} -> ${repo} [${_htime}]"

  if [ -n "${RESTIC_FORGET_OPTIONS}" ]; then
    _start=$(date +%s)
    run_cmd restic --repo ${repo} ${RESTIC_OPTIONS} forget --host ${RESTIC_HOSTNAME} ${RESTIC_FORGET_OPTIONS}
    _status=$?
    if [[ ${_status} != 0 ]]; then
      echo "Failed forget of ${repo}"
      run_cmd restic unlock
    fi
    run_cmd restic --repo ${repo} ${RESTIC_OPTIONS} check --check-unused
    _status=$?
    if [[ ${_status} != 0 ]]; then
      echo "Failed check on ${repo}"
      run_cmd restic unlock
    fi
    _end=$(date +%s)
  fi
  _htime=$(human_time $((_end-_start)))

  log_info "## Finished forget/check of ${repo} [${_htime}]"

done


_end=$(date +%s)
_htime=$(human_time $((_end-first_start)))
log_info ""
log_info "Finished backup of ${#RESTIC_DATA[@]} repositories [${_htime}]"
log_info ""
