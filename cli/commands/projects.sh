#!/usr/bin/env bash

command_new() {
    local project_name="${1:-}"
    local template_name="php-mvc-basic"
    local argument

    shift || true

    if [[ -z "$project_name" ]]; then
        echo "Informe o nome do projeto."
        echo
        echo "Uso:"
        echo "  coruja new meu-projeto"
        echo "  coruja new meu-projeto --template=php-mvc-basic"
        exit 1
    fi

    for argument in "$@"; do
        case "$argument" in
            --template=*)
                template_name="${argument#--template=}"
                ;;

            *)
                echo "Opção desconhecida: ${argument}"
                exit 1
                ;;
        esac
    done

    if [[ -z "$template_name" ]]; then
        echo "Informe um template válido."
        exit 1
    fi

    "${CORUJA_ROOT}/scripts/new-project" \
        "$project_name" \
        "$template_name"
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