#!/usr/bin/env bash

node_show_help() {
    cat <<'EOF'
Uso:
  coruja node [projeto] <argumentos>
  coruja npm [projeto] <argumentos>
  coruja npx [projeto] <argumentos>
  coruja pnpm [projeto] <argumentos>
  coruja yarn [projeto] <argumentos>

Exemplos:
  coruja node --version
  coruja npm --version
  coruja npm meu-projeto install
  coruja npm meu-projeto run dev
  coruja npx meu-projeto vite
  coruja pnpm meu-projeto install
  coruja yarn meu-projeto install

Quando um projeto é informado, o comando é executado em:
  /var/www/projects/<projeto>
EOF
}

node_require_service() {
    require_docker

    if ! docker compose config --services |
        grep -qx "node"
    then
        echo "Serviço Node.js não encontrado no compose.yaml."
        return 1
    fi

    if ! docker compose ps \
        --status running \
        --services |
        grep -qx "node"
    then
        echo "Iniciando o serviço Node.js..."

        docker compose up -d node
    fi
}

node_validate_project_name() {
    local project_name="$1"

    if [[ ! "$project_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]]; then
        echo "Nome de projeto inválido: ${project_name}"
        return 1
    fi
}

node_resolve_workdir() {
    local project_name="${1:-}"

    if [[ -z "$project_name" ]]; then
        echo "/var/www/projects"
        return 0
    fi

    node_validate_project_name "$project_name" || return 1

    if [[ ! -d "${CORUJA_PROJECTS_DIR}/${project_name}" ]]; then
        echo "Projeto não encontrado: ${project_name}" >&2
        echo "Diretório esperado:" >&2
        echo "  ${CORUJA_PROJECTS_DIR}/${project_name}" >&2
        return 1
    fi

    echo "/var/www/projects/${project_name}"
}

node_run_tool() {
    local tool="$1"
    shift

    local project_name=""
    local workdir=""

    load_environment
    node_require_service

    if (($# == 0)); then
        node_show_help
        return 1
    fi

    case "${1:-}" in
        help|-h|--help)
            node_show_help
            return 0
            ;;

        -*)
            workdir="$(node_resolve_workdir)"
            ;;

        *)
            project_name="$1"
            shift

            workdir="$(node_resolve_workdir "$project_name")" ||
                return 1
            ;;
    esac

    if (($# == 0)); then
        echo "Nenhum argumento informado para ${tool}."
        echo
        node_show_help
        return 1
    fi

    docker compose exec \
        --workdir "$workdir" \
        node \
        "$tool" \
        "$@"
}