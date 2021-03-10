#!/bin/sh -
readonly LOGFILE="/tmp/${0##*/}.log"
readonly PROCNAME=${0##*/}

function log_warn() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "\033[0;33mWARN:\033[0;39m $(date '+%Y-%m-%dT%H:%M:%S') ${PROCNAME} (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" | tee -a ${LOGFILE}
}

function log_info() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "\033[0;32mINFO:\033[0;39m $(date '+%Y-%m-%dT%H:%M:%S') ${PROCNAME} (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" | tee -a ${LOGFILE}
}

function log_error() {
    local fname=${BASH_SOURCE[1]##*/}
    echo -e "\033[0;31mERROR:\033[0;39m $(date '+%Y-%m-%dT%H:%M:%S') ${PROCNAME} (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" | tee -a ${LOGFILE}
}
