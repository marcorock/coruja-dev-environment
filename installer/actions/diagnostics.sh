#!/usr/bin/env bash
INSTALLER_ENVIRONMENT_HEALTHY=false

run_initial_diagnostic() {
    output_step "Executando diagnóstico inicial..."

    run_cli version

    echo

    if run_cli doctor; then
        INSTALLER_ENVIRONMENT_HEALTHY=true

        output_success "Diagnóstico inicial concluído sem problemas"
        return 0
    fi

    output_warning \
        "O diagnóstico inicial encontrou pendências no ambiente"

    output_info \
        "Isso pode ser esperado antes da inicialização dos containers"

    return 0
}

run_post_start_diagnostic() {
    local attempt
    local max_attempts="${CORUJA_DIAGNOSTIC_ATTEMPTS:-6}"
    local interval="${CORUJA_DIAGNOSTIC_INTERVAL:-5}"

    if [[ "$INSTALLER_ENVIRONMENT_STARTED" != true ]]; then
        output_info \
            "Diagnóstico pós-inicialização ignorado porque o ambiente não foi iniciado"
        return 0
    fi

    output_step "Validando o ambiente iniciado..."

    for ((attempt = 1; attempt <= max_attempts; attempt++)); do
        output_info \
            "Tentativa ${attempt} de ${max_attempts}"

        if run_cli doctor; then
            INSTALLER_ENVIRONMENT_HEALTHY=true
            
            output_success "Ambiente iniciado e validado com sucesso"
            return 0
        fi

        if ((attempt < max_attempts)); then
            output_info \
                "Serviços ainda estão inicializando. Nova tentativa em ${interval}s..."

            sleep "$interval"
        fi
    done

    output_error \
        "O ambiente foi iniciado, mas não ficou saudável no tempo esperado"

    output_info \
        "Execute 'coruja doctor' para verificar as pendências"

    INSTALLER_ENVIRONMENT_HEALTHY=false
    return 0
}