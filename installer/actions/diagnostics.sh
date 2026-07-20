#!/usr/bin/env bash

run_initial_diagnostic() {
    output_step "Executando diagnóstico inicial..."

    run_cli version

    echo

    if run_cli doctor; then
        output_success "Diagnóstico inicial concluído sem problemas"
        return 0
    fi

    output_warning \
        "O diagnóstico inicial encontrou pendências no ambiente"

    output_info \
        "Isso pode ser esperado antes da inicialização dos containers"

    return 0
}