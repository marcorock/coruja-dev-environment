#!/usr/bin/env bash

INSTALLER_ASSUME_YES=false

ask_confirmation() {

    local message="$1"

    if [[ "$INSTALLER_ASSUME_YES" == true ]]; then
        return 0
    fi

    local answer

    if ! read -r -p "${message} [s/N] " answer; then
        return 1
    fi

    [[ "$answer" =~ ^[sS]$ ]]

}