#!/usr/bin/env bash

run_cli() {

    if [[ $# -eq 0 ]]; then
        output_error "Nenhum comando informado para a CLI."
        return 1
    fi

    if ! command -v "${CORUJA_CLI_NAME}" >/dev/null 2>&1; then
        output_error "CLI '${CORUJA_CLI_NAME}' não encontrada."

        return 1
    fi

    output_info "Executando: ${CORUJA_CLI_NAME} $*"

    "${CORUJA_CLI_NAME}" "$@"

}