#!/usr/bin/env bash

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

command_doctor() {
    show_header
    load_environment

    local failures=0

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

    check_directory "Projetos" "$CORUJA_PROJECTS_DIR" || ((failures++))
    check_database_directory || ((failures++))
    check_directory "Redis" "$CORUJA_REDIS_DIR" || ((failures++))
    check_directory "Backups" "$CORUJA_BACKUPS_DIR" || ((failures++))
    check_directory "Templates" "$CORUJA_TEMPLATES_DIR" || ((failures++))

    echo ""
    echo "Verificando ferramentas..."
    echo ""

    if command_exists docker; then
        echo "✓ Docker instalado"
    else
        echo "✗ Docker não instalado"
        ((failures++))
    fi

    if docker info >/dev/null 2>&1; then
        echo "✓ Docker em execução"
    else
        echo "✗ Docker não está em execução"
        ((failures++))
    fi

    if docker compose version >/dev/null 2>&1; then
        echo "✓ Docker Compose disponível"
    else
        echo "✗ Docker Compose não disponível"
        ((failures++))
    fi

    if [[ -f "${CORUJA_ROOT}/.env" ]]; then
        echo "✓ Arquivo .env encontrado"
    else
        echo "✗ Arquivo .env não encontrado"
        ((failures++))
    fi

    if [[ -f "${CORUJA_ROOT}/compose.yaml" ]]; then
        echo "✓ compose.yaml encontrado"
    else
        echo "✗ compose.yaml não encontrado"
        ((failures++))
    fi

    if [[ -x "${CORUJA_ROOT}/scripts/new-project" ]]; then
        echo "✓ Script new-project disponível"
    else
        echo "✗ Script new-project ausente ou sem permissão"
        ((failures++))
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
            ((failures++))
        fi

        if docker compose exec -T redis \
            redis-cli ping 2>/dev/null |
            grep -q "PONG"; then
            echo "✓ Redis respondendo"
        else
            echo "✗ Redis indisponível"
            ((failures++))
        fi

        if docker compose exec -T mail true >/dev/null 2>&1; then
            echo "✓ Mailpit em execução"
        else
            echo "✗ Mailpit indisponível"
            ((failures++))
        fi

        if docker compose exec -T gateway \
            test -S /var/run/docker.sock >/dev/null 2>&1; then
            echo "✓ Docker Socket disponível no Traefik"
        else
            echo "✗ Docker Socket indisponível no Traefik"
            ((failures++))
        fi
    fi

    echo ""

    if ((failures == 0)); then
        echo "Ambiente saudável."
        return 0
    fi

    echo "Foram encontrados ${failures} problema(s)."
    return 1
}