#!/usr/bin/env bash

doctor_check_https_file() {
    local label="$1"
    local file_path="$2"

    if [[ -f "$file_path" ]]; then
        echo "✓ ${label}"
        return 0
    fi

    echo "✗ ${label}: arquivo não encontrado"
    return 1
}

doctor_check_https_port() {
    local https_port="${HTTPS_PORT:-}"

    if [[ -z "$https_port" ]]; then
        echo "✗ HTTPS_PORT não configurada"
        return 1
    fi

    if ! [[ "$https_port" =~ ^[0-9]+$ ]]; then
        echo "✗ HTTPS_PORT inválida: ${https_port}"
        return 1
    fi

    echo "✓ HTTPS_PORT configurada: ${https_port}"
}

doctor_check_https_mapping() {
    local https_port="${HTTPS_PORT:-443}"
    local compose_config

    if ! compose_config="$(docker compose config 2>/dev/null)"; then
        echo "✗ Não foi possível validar o mapeamento HTTPS"
        return 1
    fi

    if grep -Eq \
        "published:[[:space:]]*['\"]?${https_port}['\"]?" \
        <<< "$compose_config"
    then
        echo "✓ Porta HTTPS publicada: ${https_port}"
        return 0
    fi

    echo "✗ Porta HTTPS não publicada: ${https_port}"
    return 1
}

doctor_check_https_endpoint() {
    local label="$1"
    local hostname="$2"
    local expected_pattern="${3:-^[234]}"
    local https_port="${HTTPS_PORT:-443}"
    local status_code

    status_code="$(
        curl \
            --silent \
            --show-error \
            --insecure \
            --output /dev/null \
            --write-out "%{http_code}" \
            --max-time 5 \
            --resolve "${hostname}:${https_port}:127.0.0.1" \
            "https://${hostname}:${https_port}" \
            2>/dev/null ||
            true
    )"

    if [[ "$status_code" =~ $expected_pattern ]]; then
        echo "✓ ${label}: HTTPS ${status_code}"
        return 0
    fi

    if [[ -z "$status_code" || "$status_code" == "000" ]]; then
        echo "✗ ${label}: sem resposta HTTPS"
    else
        echo "✗ ${label}: HTTPS ${status_code}"
    fi

    return 1
}

doctor_check_http_redirect() {
    local hostname="$1"
    local http_port="${HTTP_PORT:-80}"
    local headers
    local status_code
    local redirect_location

    headers="$(
        curl \
            --silent \
            --show-error \
            --head \
            --max-time 5 \
            --header "Host: ${hostname}" \
            "http://127.0.0.1:${http_port}" \
            2>/dev/null ||
            true
    )"

    status_code="$(
        awk 'NR == 1 { print $2 }' <<< "$headers"
    )"

    redirect_location="$(
    awk '
        tolower($1) == "location:" {
            sub(/\r$/, "", $0)
            sub(/^[^:]+:[[:space:]]*/, "", $0)
            print
            exit
        }
    ' <<< "$headers"
)"

    if [[ "$status_code" =~ ^30[1278]$ ]] &&
        [[ "$redirect_location" == https://* ]]
    then
        echo "✓ Redirecionamento HTTP → HTTPS"
        return 0
    fi

    if [[ -z "$status_code" ]]; then
        echo "✗ Redirecionamento HTTP → HTTPS: sem resposta"
    elif [[ -z "$redirect_location" ]]; then
        echo "✗ Redirecionamento HTTP → HTTPS: HTTP ${status_code}, sem Location"
    else
        echo "✗ Redirecionamento HTTP → HTTPS: ${redirect_location}"
    fi

    return 1
}

doctor_check_https() {
    local certificate_file="${CORUJA_ROOT}/certs/localhost.pem"
    local certificate_key_file="${CORUJA_ROOT}/certs/localhost-key.pem"
    local tls_config_file="${CORUJA_ROOT}/config/traefik/dynamic/tls.yml"
    local project_name=""

    doctor_section "Verificando HTTPS..."

    if ! doctor_check_https_file \
        "Certificado localhost.pem" \
        "$certificate_file"
    then
        doctor_add_failure
    fi

    if ! doctor_check_https_file \
        "Chave localhost-key.pem" \
        "$certificate_key_file"
    then
        doctor_add_failure
    fi

    if ! doctor_check_https_file \
        "Configuração TLS do Traefik" \
        "$tls_config_file"
    then
        doctor_add_failure
    fi

    if ! doctor_check_https_port; then
        doctor_add_failure
    fi

    if ! command_exists curl ||
        ! docker info >/dev/null 2>&1
    then
        echo "• Diagnóstico de conectividade HTTPS ignorado"
        return 0
    fi

    if ! doctor_check_https_mapping; then
        doctor_add_failure
    fi

    if ! doctor_check_http_redirect "db.localhost"; then
        doctor_add_failure
    fi

    if ! doctor_check_https_endpoint \
        "phpMyAdmin" \
        "db.localhost" \
        "^[234]"
    then
        doctor_add_failure
    fi

    if ! doctor_check_https_endpoint \
        "Mailpit" \
        "mail.localhost" \
        "^[234]"
    then
        doctor_add_failure
    fi

    project_name="$(doctor_find_project || true)"

    if [[ -z "$project_name" ]]; then
        echo "• Projeto HTTPS: nenhum projeto com pasta public encontrado"
        return 0
    fi

    if ! doctor_check_https_endpoint \
        "Projeto ${project_name}" \
        "${project_name}.localhost" \
        "^[234]"
    then
        doctor_add_failure
    fi
}