#!/usr/bin/env bash

configure_directories() {
    CORUJA_HOME="${CORUJA_HOME:-$(dirname "$ROOT_DIR")}"

    PROJECTS_ROOT="${PROJECTS_ROOT:-${CORUJA_HOME}/projects}"
    DB_DATA_PATH="${DB_DATA_PATH:-${CORUJA_HOME}/data/mariadb}"
    REDIS_DATA_PATH="${REDIS_DATA_PATH:-${CORUJA_HOME}/data/redis}"
    BACKUPS_PATH="${BACKUPS_PATH:-${CORUJA_HOME}/backups}"
    TEMPLATES_PATH="${TEMPLATES_PATH:-${CORUJA_HOME}/templates}"
}

create_directory() {
    local label="$1"
    local directory="$2"

    if [[ -d "$directory" ]]; then
        echo "✓ ${label}: já existe"
        return 0
    fi

    if mkdir -p "$directory"; then
        echo "✓ ${label}: criado"
        return 0
    fi

    echo "✗ ${label}: não foi possível criar"
    echo "  ${directory}"
    return 1
}

create_directories() {
    local failures=0

    configure_directories

    echo
    echo "Preparando diretórios..."
    echo
    echo "Diretório raiz: ${CORUJA_HOME}"
    echo

    if ! create_directory "Projetos" "$PROJECTS_ROOT"; then
        failures=$((failures + 1))
    fi

    if ! create_directory "MariaDB" "$DB_DATA_PATH"; then
        failures=$((failures + 1))
    fi

    if ! create_directory "Redis" "$REDIS_DATA_PATH"; then
        failures=$((failures + 1))
    fi

    if ! create_directory "Backups" "$BACKUPS_PATH"; then
        failures=$((failures + 1))
    fi

    if ! create_directory "Templates" "$TEMPLATES_PATH"; then
        failures=$((failures + 1))
    fi

    echo

    if ((failures > 0)); then
        echo "Não foi possível preparar ${failures} diretório(s)."
        return 1
    fi

    echo "Diretórios preparados com sucesso."
}