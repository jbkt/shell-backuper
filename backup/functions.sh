#!/usr/bin/env bash
# Tue 20 Mar 13:39:26 2018 CET

# Build utilities
SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# datetime prefix for logging
log_datetime() {
	echo "($(date +'%Y-%m-%d %H:%M:%S'))"
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


# Checks just if the variable has non-zero length
check_zero_length() {
  if [ -z "${!1}" ]; then
    log_error "Variable ${1} is zero-length - aborting...";
    exit 1
  fi
}


# Checks just if the variable is defined and has non-zero length
check_defined() {
  if [ -z "${!1+abc}" ]; then
    log_error "Variable ${1} is undefined - aborting...";
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
# $1: number of seconds ellapsed
human_time() {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))

  # creates string
  local value=""
  [[ $D > 0 ]] && value="$D days"
  if [[ $H > 0 ]]; then
    if [ -n "${value}" ]; then value="${value}, "; fi
    value="${value}$H hours"
  fi
  if [[ $M > 0 ]]; then
    if [ -n "${value}" ]; then value="${value}, "; fi
    value="${value}$M minutes"
  fi
  if [[ $S > 0 ]]; then
    if [ -n "${value}" ]; then value="${value}, "; fi
    value="${value}$S seconds"
  fi

  echo "${value}"
}

CONFIG_FILENAME=${SCRIPTS_DIR}/config.sh

# Truncates the configuration file
truncate_config() {
  log_info "Truncating contents of ${CONFIG_FILENAME}..."
  echo "# Created at $(date)" > ${CONFIG_FILENAME}
}


# Saves the content of a variable to a source-able config file
# $1: name of the variable to save
save_to_config() {
  log_info "Storing contents of \${${1}} to ${CONFIG_FILENAME}..."
  echo "export ${1}=\"${!1}\"" >> ${CONFIG_FILENAME}
}
