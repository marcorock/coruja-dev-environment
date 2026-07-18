#!/usr/bin/env bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

show_header() {
    echo ""
    echo "Coruja Dev Environment"
    echo "Versão ${VERSION}"
    echo ""
}

require_docker() {
    if ! command_exists docker; then
        echo "Docker não foi encontrado."
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        echo "Docker não está em execução."
        exit 1
    fi
}

load_environment() {
    if [[ ! -f "${CORUJA_ROOT}/.env" ]]; then
        echo "Arquivo .env não encontrado."
        exit 1
    fi

    set -a
    source "${CORUJA_ROOT}/.env"
    set +a

    load_coruja_config
}

load_coruja_config() {
    local config_file="${CORUJA_ROOT}/config/coruja.conf"

    if [[ ! -f "$config_file" ]]; then
        echo "Configuração da CLI não encontrada:"
        echo "  ${config_file}"
        exit 1
    fi

    source "$config_file"
}

replace_env_value() {
    local file="$1"
    local key="$2"
    local value="$3"
    local temporary_file

    if [[ ! -f "$file" ]]; then
        echo "Arquivo não encontrado: ${file}"
        return 1
    fi

    temporary_file="$(mktemp "${TMPDIR:-/tmp}/coruja-env.XXXXXX")"

    awk \
        -v key="$key" \
        -v value="$value" '
        BEGIN {
            updated = 0
        }

        $0 ~ "^" key "=" {
            print key "=" value
            updated = 1
            next
        }

        {
            print
        }

        END {
            if (!updated) {
                print key "=" value
            }
        }
    ' "$file" > "$temporary_file"

    cat "$temporary_file" > "$file"
    rm -f "$temporary_file"
}