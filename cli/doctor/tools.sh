#!/usr/bin/env bash

doctor_check_command() {
    local command_name="$1"
    local display_name="$2"

    if command_exists "$command_name"; then
        echo "✓ ${display_name}"
        return 0
    fi

    echo "✗ ${display_name}"
    return 1
}

doctor_check_file() {
    local label="$1"
    local file_path="$2"

    if [[ -f "$file_path" ]]; then
        echo "✓ ${label}"
        return 0
    fi

    echo "✗ ${label}"
    return 1
}

doctor_check_tools() {
    doctor_section "Verificando ferramentas..."

    if ! doctor_check_command \
        docker \
        "Docker instalado"
    then
        doctor_add_failure
    fi

    if ! doctor_check_command \
        curl \
        "curl disponível"
    then
        doctor_add_failure
    fi

    if docker info >/dev/null 2>&1; then
        echo "✓ Docker em execução"
    else
        echo "✗ Docker não está em execução"
        doctor_add_failure
    fi

    if docker compose version >/dev/null 2>&1; then
        echo "✓ Docker Compose disponível"
    else
        echo "✗ Docker Compose não disponível"
        doctor_add_failure
    fi

    if ! doctor_check_file \
        "Arquivo .env encontrado" \
        "${CORUJA_ROOT}/.env"
    then
        doctor_add_failure
    fi

    if ! doctor_check_file \
        "compose.yaml encontrado" \
        "${CORUJA_ROOT}/compose.yaml"
    then
        doctor_add_failure
    fi

    if [[ -x "${CORUJA_ROOT}/scripts/new-project" ]]; then
        echo "✓ Script new-project disponível"
    else
        echo "✗ Script new-project ausente ou sem permissão"
        doctor_add_failure
    fi
}