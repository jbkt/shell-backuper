#!/usr/bin/env bash
# Tue 20 Mar 13:39:26 2018 CET

# Build utilities
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# datetime prefix for logging
log_datetime() {
	echo "($(date +%T.%3N))"
}

# Functions for coloring echo commands
log_debug() {
  echo -e "$(log_datetime) \033[1;32m${@}\033[0m"
}


log_info() {
  echo -e "$(log_datetime) \033[1;34m${@}\033[0m"
}


log_warn() {
  echo -e "$(log_datetime) \033[1;35mWarning: ${@}\033[0m" >&2
}


log_error() {
  echo -e "$(log_datetime) \033[1;31mError: ${@}\033[0m" >&2
}


# Checks just if the variable is defined and has non-zero length
check_defined() {
  if [ -z "${!1+abc}" ]; then
    log_error "Variable ${1} is undefined - aborting...";
    exit 1
  elif [ -z "${!1}" ]; then
    log_error "Variable ${1} is zero-length - aborting...";
    exit 1
  fi
}


# Logs a given environment variable to the screen
log_env() {
  log_info "${1}=${!1}"
}


# Checks a given environment variable is set (non-zero size)
check_env() {
  check_defined "${1}"
  log_env "${1}"
}


# Checks a given environment variable array is set (non-zero size)
# Then prints all of its components
check_array_env() {
  check_defined "${1}"
  eval array=\( \${${1}[@]} \)
  for i in "${!array[@]}"; do
    log_info "${1}[${i}]=${array[${i}]}";
  done
}


# Exports a given environment variable, verbosely
export_env() {
  check_defined "${1}"
  export ${1}
  log_info "export ${1}=${!1}"
}


# Checks a given environment variable is set (non-zero size)
check_pass() {
  check_defined "${1}"
  log_info "${1}=********"
}


# Function for running command and echoing results
run_cmd() {
  log_info "$ ${@}"
  ${@}
  local status=$?
  if [ ${status} != 0 ]; then
    log_error "Command Failed \"${@}\""
    exit ${status}
  fi
}


# Given the number of seconds, change to days, hours, minutes and seconds
human_time() {
  echo $(date -ud "@$1" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')
}


# Checks all environment variables and prints values
IFS=':' read -a RESTIC_DATA <<< "${RESTIC_DATA}" #colon-separated to array
check_array_env RESTIC_DATA

IFS=':' read -a RESTIC_REPO <<< "${RESTIC_REPO}" #colon-separated to array
check_array_env RESTIC_REPO

if [ "${#RESTIC_DATA[@]}" != "${#RESTIC_REPO[@]}" ]; then
  log_error "Number of local folders (${#RESTIC_DATA[@]}) does not match remote repositories (${#RESTIC_REPO[@]}). Aborting..."
  exit 1
fi

check_pass B2_ACCOUNT_ID
export B2_ACCOUNT_ID
check_pass B2_ACCOUNT_KEY
export B2_ACCOUNT_KEY
check_pass RESTIC_PASSWORD

check_env BACKUP_CRON
check_env RESTIC_OPTIONS
check_env RESTIC_BACKUP_OPTIONS
check_env RESTIC_FORGET_OPTIONS
