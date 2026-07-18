#!/usr/bin/env bash

project_exists() {
    local project_name="$1"
    load_environment

    [[ -d "${CORUJA_PROJECTS_DIR}/${project_name}" ]]
}

command_project_list() {
    command_projects
}

command_project_info() {
    load_environment

    local project_name="${1:-}"

    if [[ -z "$project_name" ]]; then
        echo "Informe o nome do projeto."
        echo ""
        echo "Exemplo:"
        echo "  coruja project info meu-projeto"
        exit 1
    fi

    local project_path="${CORUJA_PROJECTS_DIR}/${project_name}"

    if [[ ! -d "$project_path" ]]; then
        echo "Projeto não encontrado: ${project_name}"
        exit 1
    fi

    echo ""
    echo "Projeto: ${project_name}"
    echo "Pasta:   ${project_path}"

    if [[ -f "${project_path}/.env" ]]; then
        local app_url
        local database_name

        app_url="$(grep '^APP_URL=' "${project_path}/.env" | cut -d '=' -f2- || true)"
        database_name="$(grep '^DB_DATABASE=' "${project_path}/.env" | cut -d '=' -f2- || true)"

        [[ -n "$app_url" ]] && echo "URL:     ${app_url}"
        [[ -n "$database_name" ]] && echo "Banco:   ${database_name}"
    fi

    if [[ -d "${project_path}/.git" ]]; then
        local branch
        branch="$(git -C "$project_path" branch --show-current 2>/dev/null || true)"

        echo "Git:     iniciado"
        [[ -n "$branch" ]] && echo "Branch:  ${branch}"
    else
        echo "Git:     não iniciado"
    fi

    if [[ -f "${project_path}/composer.json" ]]; then
        echo "Composer: configurado"
    else
        echo "Composer: não configurado"
    fi

    echo ""
}

command_project_remove() {
    load_environment

    local project_name="${1:-}"

    if [[ -z "$project_name" ]]; then
        echo "Informe o nome do projeto."
        echo ""
        echo "Exemplo:"
        echo "  coruja project remove meu-projeto"
        exit 1
    fi

    if ! [[ "$project_name" =~ ^[a-z0-9-]+$ ]]; then
        echo "Nome de projeto inválido."
        echo "Use apenas letras minúsculas, números e hífens."
        exit 1
    fi

    local project_path="${CORUJA_PROJECTS_DIR}/${project_name}"
    local projects_directory
    local database_name=""
    local remove_database="n"
    local confirmation
    local temporary_path

    projects_directory="$(dirname "$project_path")"

    if [[ ! -d "$project_path" ]]; then
        echo "Projeto não encontrado: ${project_name}"
        exit 1
    fi

    if [[ -f "${project_path}/.env" ]]; then
        database_name="$(
            grep '^DB_DATABASE=' "${project_path}/.env" |
            cut -d '=' -f2- ||
            true
        )"

        database_name="${database_name%\"}"
        database_name="${database_name#\"}"
        database_name="${database_name%\'}"
        database_name="${database_name#\'}"
    fi

    echo ""
    echo "Projeto: ${project_name}"
    echo "Pasta:   ${project_path}"

    if [[ -n "$database_name" ]]; then
        echo "Banco:   ${database_name}"
    else
        echo "Banco:   não identificado"
    fi

    echo ""

    read -r -p \
        "Deseja realmente remover este projeto? [s/N] " \
        confirmation

    if [[ ! "$confirmation" =~ ^[sS]$ ]]; then
        echo "Operação cancelada."
        return 0
    fi

    if [[ -n "$database_name" ]]; then
        read -r -p \
            "Remover também o banco '${database_name}'? [s/N] " \
            remove_database
    fi

    if [[ ! -w "$project_path" ]] ||
        [[ ! -w "$projects_directory" ]]; then
        echo "Sem permissão para remover:"
        echo "  ${project_path}"
        return 1
    fi

    temporary_path="$(
        mktemp -d \
            "${projects_directory}/.${project_name}.removing.XXXXXX"
    )"

    rmdir "$temporary_path"

    if ! mv "$project_path" "$temporary_path"; then
        echo "Não foi possível preparar o projeto para remoção."
        return 1
    fi

    if [[ "$remove_database" =~ ^[sS]$ ]] &&
        [[ -n "$database_name" ]]; then
        if ! command_db_drop "$database_name" true; then
            echo "A remoção do banco falhou."
            echo "Restaurando o projeto..."

            if mv "$temporary_path" "$project_path"; then
                echo "Projeto restaurado: ${project_name}"
            else
                echo "Falha crítica ao restaurar o projeto."
                echo "Arquivos preservados em:"
                echo "  ${temporary_path}"
            fi

            return 1
        fi
    fi

    if ! rm -rf -- "$temporary_path"; then
        echo "O projeto foi retirado do ambiente, mas os arquivos"
        echo "temporários não puderam ser apagados:"
        echo "  ${temporary_path}"
        return 1
    fi

    echo "Projeto removido: ${project_name}"
}

command_project_clone() {
    load_environment
    require_docker

    local source_name="${1:-}"
    local target_name="${2:-}"

    if [[ -z "$source_name" || -z "$target_name" ]]; then
        echo "Informe o projeto de origem e o novo nome."
        echo ""
        echo "Exemplo:"
        echo "  coruja project clone projeto-base novo-projeto"
        exit 1
    fi

    if ! [[ "$target_name" =~ ^[a-z0-9-]+$ ]]; then
        echo "O novo nome deve usar letras minúsculas, números e hífens."
        exit 1
    fi

    local source_path="${CORUJA_PROJECTS_DIR}/${source_name}"
    local target_path="${CORUJA_PROJECTS_DIR}/${target_name}"
    local target_database="${target_name//-/_}"

    if [[ ! -d "$source_path" ]]; then
        echo "Projeto de origem não encontrado: ${source_name}"
        exit 1
    fi

    if [[ -e "$target_path" ]]; then
        echo "O destino já existe: ${target_path}"
        exit 1
    fi

    echo "Clonando projeto..."

    cp -R "$source_path" "$target_path"

    rm -rf "${target_path}/.git"
    rm -rf "${target_path}/vendor"

    if [[ -f "${target_path}/.env" ]]; then
        replace_env_value \
            "${target_path}/.env" \
            "APP_NAME" \
            "\"${target_name}\""

        replace_env_value \
            "${target_path}/.env" \
            "APP_URL" \
            "http://${target_name}.localhost"

        replace_env_value \
            "${target_path}/.env" \
            "DB_DATABASE" \
            "${target_database}"
    fi

    command_db_create "$target_database"

    docker compose exec -T \
        --user developer \
        -e HOME=/home/developer \
        -e COMPOSER_HOME=/home/developer/.composer \
        -w "/var/www/projects/${target_name}" \
        web composer install

    echo ""
    echo "Projeto clonado com sucesso."
    echo "Origem:  ${source_name}"
    echo "Destino: ${target_name}"
    echo "Banco:   ${target_database}"
    echo "URL:     http://${target_name}.localhost"
}

command_project() {
    local action="${1:-help}"
    local first_argument="${2:-}"
    local second_argument="${3:-}"

    case "$action" in
        list)
            command_project_list
            ;;

        info)
            command_project_info "$first_argument"
            ;;

        remove)
            command_project_remove "$first_argument"
            ;;

        clone)
            command_project_clone "$first_argument" "$second_argument"
            ;;

        help|-h|--help)
            echo ""
            echo "Uso:"
            echo "  coruja project <comando> [argumentos]"
            echo ""
            echo "Comandos:"
            echo "  list                       Lista os projetos"
            echo "  info <nome>                Mostra informações"
            echo "  remove <nome>              Remove um projeto"
            echo "  clone <origem> <destino>   Duplica um projeto"
            echo ""
            ;;

        *)
            echo "Comando de projeto desconhecido: ${action}"
            echo ""
            command_project help
            exit 1
            ;;
    esac
}