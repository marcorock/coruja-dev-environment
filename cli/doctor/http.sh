#!/usr/bin/env bash

doctor_check_http_endpoint() {
    local label="$1"
    local url="$2"
    local expected_pattern="${3:-^[23]}"
    local host_header="${4:-}"
    local status_code

    if [[ -n "$host_header" ]]; then
        status_code="$(
            curl \
                --silent \
                --show-error \
                --output /dev/null \
                --write-out "%{http_code}" \
                --max-time 5 \
                --header "Host: ${host_header}" \
                "$url" 2>/dev/null ||
                true
        )"
    else
        status_code="$(
            curl \
                --silent \
                --show-error \
                --output /dev/null \
                --write-out "%{http_code}" \
                --max-time 5 \
                "$url" 2>/dev/null ||
                true
        )"
    fi

    if [[ "$status_code" =~ $expected_pattern ]]; then
        echo "✓ ${label}: HTTP ${status_code}"
        return 0
    fi

    if [[ -z "$status_code" || "$status_code" == "000" ]]; then
        echo "✗ ${label}: sem resposta HTTP"
    else
        echo "✗ ${label}: HTTP ${status_code}"
    fi

    return 1
}

doctor_find_project() {
    local project_path

    for project_path in "${CORUJA_PROJECTS_DIR}"/*; do
        [[ -d "${project_path}/public" ]] || continue

        basename "$project_path"
        return 0
    done

    return 1
}

doctor_check_http() {
    local http_port="${HTTP_PORT:-80}"
    local gateway_url="http://127.0.0.1:${http_port}"
    local project_name=""

    doctor_section "Verificando HTTP..."

    if ! command_exists curl ||
        ! docker info >/dev/null 2>&1
    then
        echo "• Diagnóstico HTTP ignorado"
        return 0
    fi

    if ! doctor_check_http_endpoint \
        "Traefik Gateway" \
        "$gateway_url" \
        "^[234]"
    then
        doctor_add_failure
    fi

    if ! doctor_check_http_endpoint \
        "phpMyAdmin" \
        "$gateway_url" \
        "^[23]" \
        "db.localhost"
    then
        doctor_add_failure
    fi

    if ! doctor_check_http_endpoint \
        "Mailpit" \
        "$gateway_url" \
        "^[23]" \
        "mail.localhost"
    then
        doctor_add_failure
    fi

    project_name="$(doctor_find_project || true)"

    if [[ -z "$project_name" ]]; then
        echo "• Projeto HTTP: nenhum projeto com pasta public encontrado"
        return 0
    fi

    if ! doctor_check_http_endpoint \
        "Projeto ${project_name}" \
        "$gateway_url" \
        "^[234]" \
        "${project_name}.localhost"
    then
        doctor_add_failure
    fi
}