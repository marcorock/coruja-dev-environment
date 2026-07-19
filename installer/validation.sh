#!/usr/bin/env bash

validate_environment() {

    local failures=0

    echo
    echo "Validando configuração..."
    echo

    local required_variables=(
        CORUJA_HOME
        PROJECTS_ROOT
        DB_DATA_PATH
        REDIS_DATA_PATH
        BACKUPS_PATH
        TEMPLATES_PATH
    )

    for variable in "${required_variables[@]}"; do

        if [[ -z "${!variable:-}" ]]; then

            echo "✗ ${variable}"

            failures=$((failures + 1))

        else

            echo "✓ ${variable}"

        fi

    done

    echo

    if (( failures > 0 )); then

        echo "Foram encontradas ${failures} configuração(ões) inválida(s)."

        return 1

    fi

    echo "Configuração válida."

}