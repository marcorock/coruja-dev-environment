#!/usr/bin/env bash

check_command() {
    local command_name="$1"
    local display_name="${2:-$1}"

    if command -v "$command_name" >/dev/null 2>&1; then
        output_success "${display_name}"
        return 0
    fi

    output_error "${display_name} não encontrado"
    return 1
}

check_docker_running() {
    if docker info >/dev/null 2>&1; then
        output_success "Docker em execução"
        return 0
    fi

    output_error "Docker instalado, mas não está em execução"
    return 1
}

check_docker_compose() {
    if docker compose version >/dev/null 2>&1; then
        output_success "Docker Compose"
        return 0
    fi

    output_error "Docker Compose não disponível"
    return 1
}

check_dependencies() {
    local failures=0

    output_step "Verificando dependências..."

    if ! check_command bash "Bash"; then
        failures=$((failures + 1))
    fi

    if ! check_command git "Git"; then
        failures=$((failures + 1))
    fi

    if ! check_command curl "curl"; then
        failures=$((failures + 1))
    fi

    if check_command docker "Docker"; then
        if ! check_docker_running; then
            failures=$((failures + 1))
        fi

        if ! check_docker_compose; then
            failures=$((failures + 1))
        fi
    else
        failures=$((failures + 1))
    fi

    echo

    if ((failures > 0)); then
        output_error "Foram encontradas ${failures} dependência(s) ausente(s) ou indisponível(is)."
        return 1
    fi

    output_success "Todas as dependências estão disponíveis."
}