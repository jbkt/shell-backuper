#!/usr/bin/env bash

source $(dirname ${0})/functions.sh

log_info ""
log_info "Starting backup of ${#RESTIC_DATA[@]} repositories..."
log_info ""

first_start=$(date +%s)

for index in "${!RESTIC_DATA[@]}"; do

  ldir=${RESTIC_DATA[${index}]}
  repo=${RESTIC_REPO[${index}]}

  log_info ""
  log_info "Starting backup ${ldir} -> ${repo}..."
  log_info ""

  _start=$(date +%s)
  run_cmd restic --repo ${repo} ${RESTIC_OPTIONS} backup ${RESTIC_BACKUP_OPTIONS} ${ldir}
  _status=$?
  _end=$(date +%s)
  _htime=$(human_time $((_end-_start)))
  if [[ ${_status} != 0 ]]; then
    log_info "Failed backup ${ldir} -> ${repo}. Aborting..."
    run_cmd restic unlock
    kill 1
  fi

  log_info ""
  log_info "Finished backup ${ldir} -> ${repo} [${_htime} seconds]"
  log_info ""

  if [ -n "${RESTIC_FORGET_OPTIONS}" ]; then
    _start=$(date +%s)
    restic --repo ${repo} ${RESTIC_OPTIONS} forget ${RESTIC_FORGET_ARGS}
    _status=$?
    if [[ ${_status} != 0 ]]; then
      echo "Failed forget of ${repo}"
      run_cmd restic unlock
    fi
    restic --repo ${repo} ${RESTIC_OPTIONS} check --check-unused
    _status=$?
    if [[ ${_status} != 0 ]]; then
      echo "Failed check on ${repo}"
      run_cmd restic unlock
    fi
    _end=$(date +%s)
  fi
  _htime=$(human_time $((_end-_start)))

  log_info ""
  log_info "Finished forget of ${repo} [${_htime} seconds]"
  log_info ""

_end=$(date +%s)
htime=$(human_time $((_end-first_start)))
log_info ""
log_info "Finished backup of ${#RESTIC_DATA[@]} repositories [${htime} seconds]"
log_info ""
