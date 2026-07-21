#!/usr/bin/env bash

source "${CORUJA_ROOT}/cli/doctor/common.sh"
source "${CORUJA_ROOT}/cli/doctor/directories.sh"
source "${CORUJA_ROOT}/cli/doctor/tools.sh"
source "${CORUJA_ROOT}/cli/doctor/services.sh"
source "${CORUJA_ROOT}/cli/doctor/http.sh"
source "${CORUJA_ROOT}/cli/doctor/https.sh"
source "${CORUJA_ROOT}/cli/doctor/summary.sh"

command_doctor() {
    show_header
    load_environment

    doctor_init

    doctor_show_environment_info

    doctor_check_directories
    doctor_check_tools
    doctor_check_services
    doctor_check_http
    doctor_check_https

    doctor_summary
}