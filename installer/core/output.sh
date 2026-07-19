#!/usr/bin/env bash

output_info() {
    local message="$1"

    echo "• ${message}"
}

output_success() {
    local message="$1"

    echo "✓ ${message}"
}

output_warning() {
    local message="$1"

    echo "⚠ ${message}"
}

output_error() {
    local message="$1"

    echo "✗ ${message}" >&2
}

output_step() {
    local message="$1"

    echo
    echo "${message}"
    echo
}