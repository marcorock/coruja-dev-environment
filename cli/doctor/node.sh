#!/usr/bin/env bash

doctor_check_node_service() {
    if ! docker compose config --services |
        grep -qx "node"
    then
        echo "✗ Serviço Node.js não encontrado"
        return 1
    fi

    echo "✓ Serviço Node.js configurado"
}

doctor_check_node_running() {
    if docker compose ps \
        --status running \
        --services |
        grep -qx "node"
    then
        echo "✓ Serviço Node.js em execução"
        return 0
    fi

    echo "✗ Serviço Node.js não está em execução"
    return 1
}

doctor_check_node_command() {
    local label="$1"
    local command_name="$2"
    local version_output

    version_output="$(
        docker compose exec -T \
            node \
            "$command_name" \
            --version \
            2>/dev/null ||
            true
    )"

    if [[ -n "$version_output" ]]; then
        echo "✓ ${label}: ${version_output}"
        return 0
    fi

    echo "✗ ${label}: indisponível"
    return 1
}

doctor_check_node_user() {
    local container_uid
    local expected_uid="${USER_UID:-1000}"

    container_uid="$(
        docker compose exec -T \
            node \
            id -u \
            2>/dev/null ||
            true
    )"

    if [[ "$container_uid" == "$expected_uid" ]]; then
        echo "✓ Usuário Node.js: UID ${container_uid}"
        return 0
    fi

    if [[ -z "$container_uid" ]]; then
        echo "✗ Não foi possível identificar o usuário Node.js"
    else
        echo "✗ UID Node.js: ${container_uid}, esperado ${expected_uid}"
    fi

    return 1
}

doctor_check_node_workdir() {
    local workdir

    workdir="$(
        docker compose exec -T \
            node \
            pwd \
            2>/dev/null ||
            true
    )"

    if [[ "$workdir" == "/var/www/projects" ]]; then
        echo "✓ Diretório Node.js: ${workdir}"
        return 0
    fi

    if [[ -z "$workdir" ]]; then
        echo "✗ Não foi possível identificar o diretório Node.js"
    else
        echo "✗ Diretório Node.js inesperado: ${workdir}"
    fi

    return 1
}

doctor_check_node() {
    doctor_section "Verificando Node.js..."

    if ! docker info >/dev/null 2>&1; then
        echo "• Diagnóstico Node.js ignorado"
        return 0
    fi

    if ! doctor_check_node_service; then
        doctor_add_failure
        return 0
    fi

    if ! doctor_check_node_running; then
        doctor_add_failure
        echo "• Verificações internas do Node.js ignoradas"
        return 0
    fi

    if ! doctor_check_node_command "Node.js" "node"; then
        doctor_add_failure
    fi

    if ! doctor_check_node_command "npm" "npm"; then
        doctor_add_failure
    fi

    if ! doctor_check_node_command "npx" "npx"; then
        doctor_add_failure
    fi

    if ! doctor_check_node_command "Corepack" "corepack"; then
        doctor_add_failure
    fi

    if ! doctor_check_node_command "pnpm" "pnpm"; then
        doctor_add_failure
    fi

    if ! doctor_check_node_command "Yarn" "yarn"; then
        doctor_add_failure
    fi

    if ! doctor_check_node_user; then
        doctor_add_failure
    fi

    if ! doctor_check_node_workdir; then
        doctor_add_failure
    fi
}