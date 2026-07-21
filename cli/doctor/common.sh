#!/usr/bin/env bash

DOCTOR_FAILURES=0

doctor_init() {
    DOCTOR_FAILURES=0
}

doctor_add_failure() {
    DOCTOR_FAILURES=$((DOCTOR_FAILURES + 1))
}

doctor_section() {
    local title="$1"

    echo
    echo "${title}"
    echo
}