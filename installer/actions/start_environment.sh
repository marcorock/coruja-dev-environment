#!/usr/bin/env bash
INSTALLER_ENVIRONMENT_STARTED=false

start_environment() {
    output_step "Inicialização do ambiente"

    if ! ask_confirmation "Deseja iniciar o ambiente agora?"; then
        output_info "Inicialização do ambiente ignorada"
        return 0
    fi

    output_info "Iniciando os containers..."

    if run_cli up; then
        INSTALLER_ENVIRONMENT_STARTED=true

        output_success "Ambiente iniciado"
        return 0
    fi

    output_error "Não foi possível iniciar o ambiente"
    return 1
}