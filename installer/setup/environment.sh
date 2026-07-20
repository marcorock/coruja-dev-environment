#!/usr/bin/env bash

generate_environment_file() {
    local environment_file="${ROOT_DIR}/.env"
    local user_uid
    local user_gid

    if [[ -f "$environment_file" ]]; then
        echo
        echo "✓ Arquivo .env já existe"
        echo "  ${environment_file}"
        return 0
    fi

    if [[ "${OPERATING_SYSTEM}" == "macOS" ]]; then
        user_uid=1000
        user_gid=1000
    else
        user_uid="$(id -u)"
        user_gid="$(id -g)"
    fi

    echo
    echo "Gerando configuração do ambiente..."
    echo

    if ! cat > "$environment_file" <<EOF
# Diretório raiz compartilhado pelo ambiente.
CORUJA_HOME=${CORUJA_HOME}

# Diretórios persistentes usados pelo Docker e pela CLI.
PROJECTS_ROOT=${PROJECTS_ROOT}
DB_DATA_PATH=${DB_DATA_PATH}
REDIS_DATA_PATH=${REDIS_DATA_PATH}
BACKUPS_PATH=${BACKUPS_PATH}
TEMPLATES_PATH=${TEMPLATES_PATH}

# Portas publicadas no host.
HTTP_PORT=80
TRAEFIK_DASHBOARD_PORT=8082
DB_PORT=3306

# Credenciais locais do MariaDB.
MARIADB_ROOT_PASSWORD=root
MARIADB_DATABASE=development
MARIADB_USER=developer
MARIADB_PASSWORD=developer

# Identificação do usuário do host.
USER_UID=${user_uid}
USER_GID=${user_gid}
EOF
    then
        echo "✗ Não foi possível criar o arquivo .env"
        return 1
    fi

    echo "✓ Arquivo .env criado"
    echo "  ${environment_file}"
}