#!/usr/bin/env bash

command_new() {
    local project_name="${1:-}"

    if [[ -z "$project_name" ]]; then
        echo "Informe o nome do projeto."
        echo ""
        echo "Exemplo:"
        echo "  coruja new meu-projeto"
        exit 1
    fi

    "${CORUJA_ROOT}/scripts/new-project" "$project_name"
}

command_projects() {
    load_environment

    echo ""
    echo "Projetos em ${CORUJA_PROJECTS_DIR}:"
    echo ""

    if [[ ! -d "$CORUJA_PROJECTS_DIR" ]]; then
        echo "A pasta de projetos não existe."
        exit 1
    fi

    find "$CORUJA_PROJECTS_DIR" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf "%f\n" \
        | sort
}