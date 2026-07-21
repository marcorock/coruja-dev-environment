#!/usr/bin/env bash

doctor_show_environment_info() {
    echo "Instalação:"
    echo "  ${CORUJA_ROOT}"
    echo

    echo "Diretórios:"
    echo "  Projetos:  ${CORUJA_PROJECTS_DIR}"
    echo "  Banco:     ${CORUJA_DATABASE_DIR}"
    echo "  Redis:     ${CORUJA_REDIS_DIR}"
    echo "  Backups:   ${CORUJA_BACKUPS_DIR}"
    echo "  Templates: ${CORUJA_TEMPLATES_DIR}"
}

doctor_summary() {
    echo

    if ((DOCTOR_FAILURES == 0)); then
        echo "Ambiente saudável."
        return 0
    fi

    echo "Foram encontrados ${DOCTOR_FAILURES} problema(s)."
    return 1
}