#!/usr/bin/env bash

command_doctor() {
    show_header

    echo "Verificando ambiente..."
    echo ""

    check_directory "Projetos" "$CORUJA_PROJECTS_DIR"
    check_database_directory
    check_directory "Backups" "$CORUJA_BACKUPS_DIR"
    check_directory "Templates" "$CORUJA_TEMPLATES_DIR"
    check_directory "Redis" "$CORUJA_REDIS_DIR"

    if command_exists docker; then
        echo "✓ Docker instalado"
    else
        echo "✗ Docker não instalado"
    fi

    if docker info >/dev/null 2>&1; then
        echo "✓ Docker em execução"
    else
        echo "✗ Docker não está em execução"
    fi

    if docker compose version >/dev/null 2>&1; then
        echo "✓ Docker Compose disponível"
    else
        echo "✗ Docker Compose não disponível"
    fi

    if [[ -f "${CORUJA_ROOT}/.env" ]]; then
        echo "✓ Arquivo .env encontrado"
    else
        echo "✗ Arquivo .env não encontrado"
    fi

    if [[ -f "${CORUJA_ROOT}/compose.yaml" ]]; then
        echo "✓ compose.yaml encontrado"
    else
        echo "✗ compose.yaml não encontrado"
    fi

    if [[ -x "${CORUJA_ROOT}/scripts/new-project" ]]; then
        echo "✓ Script new-project disponível"
    else
        echo "✗ Script new-project ausente ou sem permissão"
    fi

    echo ""

    if docker info >/dev/null 2>&1; then
        docker compose ps
    fi

    if docker compose exec -T redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
        echo "✓ Redis respondendo"
    else
        echo "✗ Redis indisponível"
    fi

    if docker compose exec -T mail true >/dev/null 2>&1; then
        echo "✓ Mailpit respondendo"
    else
        echo "✗ Mailpit indisponível"
    fi

}

load_environment

echo "Instalação:"
echo "  ${CORUJA_ROOT}"
echo ""

echo "Diretórios:"
echo "  Projetos:  ${CORUJA_PROJECTS_DIR}"
echo "  Banco:     ${CORUJA_DATABASE_DIR}"
echo "  Backups:   ${CORUJA_BACKUPS_DIR}"
echo "  Templates: ${CORUJA_TEMPLATES_DIR}"
echo ""

check_directory() {
    local label="$1"
    local directory="$2"

    if [[ ! -d "$directory" ]]; then
        echo "✗ ${label}: pasta não encontrada"
        return
    fi

    if [[ -w "$directory" ]]; then
        echo "✓ ${label}: escrita permitida"
    else
        echo "✗ ${label}: sem permissão de escrita"
    fi
}

check_database_directory() {
    if [[ ! -d "$CORUJA_DATABASE_DIR" ]]; then
        echo "✗ Banco: diretório não encontrado"
    else
        echo "✓ Banco: diretório gerenciado pelo MariaDB"
    fi
}