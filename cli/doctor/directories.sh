#!/usr/bin/env bash

doctor_check_directory() {
    local label="$1"
    local directory="$2"

    if [[ ! -d "$directory" ]]; then
        echo "✗ ${label}: pasta não encontrada"
        return 1
    fi

    if [[ -w "$directory" ]]; then
        echo "✓ ${label}: escrita permitida"
        return 0
    fi

    echo "✗ ${label}: sem permissão de escrita"
    return 1
}

doctor_check_database_directory() {
    if [[ ! -d "$CORUJA_DATABASE_DIR" ]]; then
        echo "✗ Banco: diretório não encontrado"
        return 1
    fi

    echo "✓ Banco: diretório gerenciado pelo MariaDB"
    return 0
}

doctor_check_redis_directory() {
    if [[ ! -d "$CORUJA_REDIS_DIR" ]]; then
        echo "✗ Redis: diretório não encontrado"
        return 1
    fi

    echo "✓ Redis: diretório gerenciado pelo container"
    return 0
}

doctor_check_directories() {
    doctor_section "Verificando diretórios..."

    if ! doctor_check_directory \
        "Projetos" \
        "$CORUJA_PROJECTS_DIR"
    then
        doctor_add_failure
    fi

    if ! doctor_check_database_directory; then
        doctor_add_failure
    fi

    if ! doctor_check_redis_directory; then
        doctor_add_failure
    fi

    if ! doctor_check_directory \
        "Backups" \
        "$CORUJA_BACKUPS_DIR"
    then
        doctor_add_failure
    fi

    if ! doctor_check_directory \
        "Templates" \
        "$CORUJA_TEMPLATES_DIR"
    then
        doctor_add_failure
    fi
}