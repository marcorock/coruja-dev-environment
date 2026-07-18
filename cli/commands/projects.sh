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

    local project_path
    local project_names=()

    for project_path in "${CORUJA_PROJECTS_DIR}"/*; do
        [[ -d "$project_path" ]] || continue
        project_names+=("$(basename "$project_path")")
    done

    if (( ${#project_names[@]} == 0 )); then
        echo "Nenhum projeto encontrado."
        return 0
    fi

    printf '%s\n' "${project_names[@]}" | sort
}