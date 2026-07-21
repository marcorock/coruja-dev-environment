#!/usr/bin/env bash

doctor_check_services() {
    doctor_section "Verificando serviços..."

    if ! docker info >/dev/null 2>&1; then
        echo "• Diagnóstico de serviços ignorado"
        return 0
    fi

    docker compose ps
    echo

    if docker compose exec -T database \
        mariadb-admin ping \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}" \
        --silent >/dev/null 2>&1
    then
        echo "✓ MariaDB respondendo"
    else
        echo "✗ MariaDB indisponível"
        doctor_add_failure
    fi

    if docker compose exec -T redis \
        redis-cli ping 2>/dev/null |
        grep -q "PONG"
    then
        echo "✓ Redis respondendo"
    else
        echo "✗ Redis indisponível"
        doctor_add_failure
    fi

    if docker compose exec -T mail \
        true >/dev/null 2>&1
    then
        echo "✓ Mailpit em execução"
    else
        echo "✗ Mailpit indisponível"
        doctor_add_failure
    fi

    if docker compose exec -T gateway \
        test -S /var/run/docker.sock \
        >/dev/null 2>&1
    then
        echo "✓ Docker Socket disponível no Traefik"
    else
        echo "✗ Docker Socket indisponível no Traefik"
        doctor_add_failure
    fi
}