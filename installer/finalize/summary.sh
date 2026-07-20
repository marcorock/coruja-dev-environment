#!/usr/bin/env bash

show_installation_summary() {
    output_step "Resumo da instalação"

    echo "Sistema:"
    echo "  ${OPERATING_SYSTEM}"
    echo

    echo "Instalação:"
    echo "  ${ROOT_DIR}"
    echo

    echo "Diretórios:"
    echo "  Projetos:  ${PROJECTS_ROOT}"
    echo "  Banco:     ${DB_DATA_PATH}"
    echo "  Redis:     ${REDIS_DATA_PATH}"
    echo "  Backups:   ${BACKUPS_PATH}"
    echo "  Templates: ${TEMPLATES_PATH}"
    echo

    echo "CLI:"
    echo "  Comando: ${CORUJA_CLI_NAME}"
    echo "  Caminho: $(command -v "${CORUJA_CLI_NAME}" 2>/dev/null || echo "não encontrado")"
    echo

    echo "Ambiente:"

    if [[ "$INSTALLER_ENVIRONMENT_STARTED" != true ]]; then
        echo "  Não iniciado durante a instalação"
    elif [[ "$INSTALLER_ENVIRONMENT_HEALTHY" == true ]]; then
        echo "  Iniciado e saudável"
    else
        echo "  Iniciado com pendências"
    fi

    echo

    if [[ "$INSTALLER_ENVIRONMENT_STARTED" == true ]]; then
        echo "Acessos:"
        echo "  phpMyAdmin: http://db.localhost"
        echo "  Mailpit:    http://mail.localhost"
        echo
    fi

    echo "Próximos comandos:"
    echo "  coruja doctor"
    echo "  coruja status"
    echo "  coruja projects"
    echo "  coruja new meu-projeto"
    echo

    if [[ "$INSTALLER_ENVIRONMENT_STARTED" != true ]]; then
        echo "Para iniciar o ambiente:"
        echo "  coruja up"
        echo
    fi

    if [[ "$INSTALLER_ENVIRONMENT_STARTED" == true &&
        "$INSTALLER_ENVIRONMENT_HEALTHY" != true ]]; then
        output_warning \
            "O ambiente foi iniciado, mas ainda possui pendências"

        output_info \
            "Execute 'coruja doctor' para obter o diagnóstico completo"

        return 0
    fi

    output_success "Coruja Dev Environment preparado para uso"
}