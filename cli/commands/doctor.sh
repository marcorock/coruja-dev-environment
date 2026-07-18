#!/usr/bin/env bash

doctor_add_failure() {
    local current_failures="$1"
    echo $((current_failures + 1))
}

check_directory() {
    local label="$1"
    local directory="$2"

    if [[ ! -d "$directory" ]]; then
        echo "✗ ${label}: pasta não encontrada"
        return 1
    fi

    if [[ -w "$directory" ]]; then
        echo "✓ ${label}: escrita permitida"
        return 0
    fi

    echo "✗ ${label}: sem permissão de escrita"
    return 1
}

check_database_directory() {
    if [[ ! -d "$CORUJA_DATABASE_DIR" ]]; then
        echo "✗ Banco: diretório não encontrado"
        return 1
    fi

    echo "✓ Banco: diretório gerenciado pelo MariaDB"
    return 0
}

check_redis_directory() {
    if [[ ! -d "$CORUJA_REDIS_DIR" ]]; then
        echo "✗ Redis: diretório não encontrado"
        return 1
    fi

    echo "✓ Redis: diretório gerenciado pelo container"
    return 0
}

check_http_endpoint() {
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

find_doctor_project() {
    local project_path

    for project_path in "${CORUJA_PROJECTS_DIR}"/*; do
        [[ -d "${project_path}/public" ]] || continue
        basename "$project_path"
        return 0
    done

    return 1
}

command_doctor() {
    show_header
    load_environment

    local failures=0
    local http_port="${HTTP_PORT:-80}"
    local gateway_url="http://127.0.0.1:${http_port}"
    local project_name=""

    echo "Instalação:"
    echo "  ${CORUJA_ROOT}"
    echo ""

    echo "Diretórios:"
    echo "  Projetos:  ${CORUJA_PROJECTS_DIR}"
    echo "  Banco:     ${CORUJA_DATABASE_DIR}"
    echo "  Redis:     ${CORUJA_REDIS_DIR}"
    echo "  Backups:   ${CORUJA_BACKUPS_DIR}"
    echo "  Templates: ${CORUJA_TEMPLATES_DIR}"
    echo ""

    echo "Verificando diretórios..."
    echo ""

    if ! check_directory "Projetos" "$CORUJA_PROJECTS_DIR"; then
        failures="$(doctor_add_failure "$failures")"
    fi

    if ! check_database_directory; then
        failures="$(doctor_add_failure "$failures")"
    fi

    if ! check_redis_directory; then
        failures="$(doctor_add_failure "$failures")"
    fi

    if ! check_directory "Backups" "$CORUJA_BACKUPS_DIR"; then
        failures="$(doctor_add_failure "$failures")"
    fi

    if ! check_directory "Templates" "$CORUJA_TEMPLATES_DIR"; then
        failures="$(doctor_add_failure "$failures")"
    fi

    echo ""
    echo "Verificando ferramentas..."
    echo ""

    if command_exists docker; then
        echo "✓ Docker instalado"
    else
        echo "✗ Docker não instalado"
        failures="$(doctor_add_failure "$failures")"
    fi

    if command_exists curl; then
        echo "✓ curl disponível"
    else
        echo "✗ curl não encontrado"
        failures="$(doctor_add_failure "$failures")"
    fi

    if docker info >/dev/null 2>&1; then
        echo "✓ Docker em execução"
    else
        echo "✗ Docker não está em execução"
        failures="$(doctor_add_failure "$failures")"
    fi

    if docker compose version >/dev/null 2>&1; then
        echo "✓ Docker Compose disponível"
    else
        echo "✗ Docker Compose não disponível"
        failures="$(doctor_add_failure "$failures")"
    fi

    if [[ -f "${CORUJA_ROOT}/.env" ]]; then
        echo "✓ Arquivo .env encontrado"
    else
        echo "✗ Arquivo .env não encontrado"
        failures="$(doctor_add_failure "$failures")"
    fi

    if [[ -f "${CORUJA_ROOT}/compose.yaml" ]]; then
        echo "✓ compose.yaml encontrado"
    else
        echo "✗ compose.yaml não encontrado"
        failures="$(doctor_add_failure "$failures")"
    fi

    if [[ -x "${CORUJA_ROOT}/scripts/new-project" ]]; then
        echo "✓ Script new-project disponível"
    else
        echo "✗ Script new-project ausente ou sem permissão"
        failures="$(doctor_add_failure "$failures")"
    fi

    echo ""
    echo "Verificando serviços..."
    echo ""

    if docker info >/dev/null 2>&1; then
        docker compose ps
        echo ""

        if docker compose exec -T database \
            mariadb-admin ping \
            -uroot \
            -p"${MARIADB_ROOT_PASSWORD}" \
            --silent >/dev/null 2>&1; then
            echo "✓ MariaDB respondendo"
        else
            echo "✗ MariaDB indisponível"
            failures="$(doctor_add_failure "$failures")"
        fi

        if docker compose exec -T redis \
            redis-cli ping 2>/dev/null |
            grep -q "PONG"; then
            echo "✓ Redis respondendo"
        else
            echo "✗ Redis indisponível"
            failures="$(doctor_add_failure "$failures")"
        fi

        if docker compose exec -T mail true >/dev/null 2>&1; then
            echo "✓ Mailpit em execução"
        else
            echo "✗ Mailpit indisponível"
            failures="$(doctor_add_failure "$failures")"
        fi

        if docker compose exec -T gateway \
            test -S /var/run/docker.sock >/dev/null 2>&1; then
            echo "✓ Docker Socket disponível no Traefik"
        else
            echo "✗ Docker Socket indisponível no Traefik"
            failures="$(doctor_add_failure "$failures")"
        fi
    fi

    echo ""
    echo "Verificando HTTP..."
    echo ""

    if command_exists curl && docker info >/dev/null 2>&1; then
        # O Traefik pode responder 404 na raiz. Isso ainda comprova
        # que o Gateway está acessível e escutando na porta configurada.
        if ! check_http_endpoint \
            "Traefik Gateway" \
            "$gateway_url" \
            "^[234]"; then
            failures="$(doctor_add_failure "$failures")"
        fi

        if ! check_http_endpoint \
            "phpMyAdmin" \
            "$gateway_url" \
            "^[23]" \
            "db.localhost"; then
            failures="$(doctor_add_failure "$failures")"
        fi

        if ! check_http_endpoint \
            "Mailpit" \
            "$gateway_url" \
            "^[23]" \
            "mail.localhost"; then
            failures="$(doctor_add_failure "$failures")"
        fi

        project_name="$(find_doctor_project || true)"

        if [[ -n "$project_name" ]]; then
            if ! check_http_endpoint \
                "Projeto ${project_name}" \
                "$gateway_url" \
                "^[234]" \
                "${project_name}.localhost"; then
                failures="$(doctor_add_failure "$failures")"
            fi
        else
            echo "• Projeto HTTP: nenhum projeto com pasta public encontrado"
        fi
    else
        echo "• Diagnóstico HTTP ignorado"
    fi

    echo ""

    if ((failures == 0)); then
        echo "Ambiente saudável."
        return 0
    fi

    echo "Foram encontrados ${failures} problema(s)."
    return 1
}