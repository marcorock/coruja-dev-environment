#!/usr/bin/env bash

command_db_list() {
    require_docker
    load_environment

    docker compose exec -T database mariadb \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}" \
        -e "SHOW DATABASES;"
}

command_db_create() {
    require_docker
    load_environment

    local database_name="${1:-}"

    if [[ -z "$database_name" ]]; then
        echo "Informe o nome do banco."
        echo ""
        echo "Exemplo:"
        echo "  coruja db create meu_banco"
        exit 1
    fi

    if ! [[ "$database_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Use apenas letras, números e underline."
        exit 1
    fi

    docker compose exec -T database mariadb \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${database_name}\`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON \`${database_name}\`.* TO '${MARIADB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "Banco criado: ${database_name}"
}

command_db_drop() {
    require_docker
    load_environment

    local database_name="${1:-}"

    if [[ -z "$database_name" ]]; then
        echo "Informe o nome do banco."
        echo ""
        echo "Exemplo:"
        echo "  coruja db drop meu_banco"
        exit 1
    fi

    if ! [[ "$database_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Use apenas letras, números e underline."
        exit 1
    fi

    read -r -p "Deseja realmente excluir o banco '${database_name}'? [s/N] " confirmation

    if [[ ! "$confirmation" =~ ^[sS]$ ]]; then
        echo "Operação cancelada."
        return
    fi

    docker compose exec -T database mariadb \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}" \
        -e "DROP DATABASE IF EXISTS \`${database_name}\`;"

    echo "Banco removido: ${database_name}"
}

command_db_shell() {
    require_docker
    load_environment

    docker compose exec database mariadb \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}"
}

command_db_backup() {
    require_docker
    load_environment

    local database_name="${1:-}"

    if [[ -z "$database_name" ]]; then
        echo "Informe o nome do banco."
        echo ""
        echo "Exemplo:"
        echo "  coruja db backup meu_banco"
        exit 1
    fi

    if ! [[ "$database_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Use apenas letras, números e underline."
        exit 1
    fi

    local backup_dir="${CORUJA_ROOT}/backups"
    local timestamp
    local backup_file

    mkdir -p "$backup_dir"

    timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
    backup_file="${backup_dir}/${database_name}_${timestamp}.sql"

    echo "Criando backup de '${database_name}'..."

    docker compose exec -T database mariadb-dump \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        "$database_name" > "$backup_file"

    if [[ ! -s "$backup_file" ]]; then
        rm -f "$backup_file"
        echo "Falha ao criar o backup."
        exit 1
    fi

    echo "Backup criado com sucesso:"
    echo "  ${backup_file}"
}

command_db_restore() {
    require_docker
    load_environment

    local input_file="${1:-}"
    local database_name="${2:-}"

    if [[ -z "$input_file" ]]; then
        echo "Informe o arquivo SQL."
        echo ""
        echo "Exemplo:"
        echo "  coruja db restore backups/meu_banco.sql"
        echo "  coruja db restore backups/meu_banco.sql banco_destino"
        exit 1
    fi

    if [[ "$input_file" != /* ]]; then
        input_file="${CORUJA_ROOT}/${input_file}"
    fi

    if [[ ! -f "$input_file" ]]; then
        echo "Arquivo não encontrado:"
        echo "  ${input_file}"
        exit 1
    fi

    if [[ -z "$database_name" ]]; then
        database_name="$(basename "$input_file" .sql)"
        database_name="${database_name%%_[0-9][0-9][0-9][0-9]-*}"
    fi

    if ! [[ "$database_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Nome de banco inválido: ${database_name}"
        echo "Use apenas letras, números e underline."
        exit 1
    fi

    read -r -p "Restaurar '${input_file}' no banco '${database_name}'? [s/N] " confirmation

    if [[ ! "$confirmation" =~ ^[sS]$ ]]; then
        echo "Operação cancelada."
        return
    fi

    docker compose exec -T database mariadb \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${database_name}\`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

GRANT ALL PRIVILEGES ON \`${database_name}\`.* TO '${MARIADB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "Restaurando banco '${database_name}'..."

    docker compose exec -T database mariadb \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}" \
        "$database_name" < "$input_file"

    echo "Restauração concluída."
}

command_db() {
    local action="${1:-help}"
    local argument="${2:-}"
    local second_argument="${3:-}"

    case "$action" in
        list)
            command_db_list
            ;;

        create)
            command_db_create "$argument"
            ;;

        drop)
            command_db_drop "$argument"
            ;;
        
        backup)
            command_db_backup "$argument"
                ;;

        restore)
            command_db_restore "$argument" "$second_argument"
            ;;

        shell)
            command_db_shell
            ;;

        help|-h|--help)
            echo ""
            echo "Uso:"
            echo "  coruja db <comando> [argumentos]"
            echo ""
            echo "Comandos:"
            echo "  list              Lista os bancos"
            echo "  create <nome>     Cria um banco"
            echo "  drop <nome>       Exclui um banco"
            echo "  backup <banco>             Cria backup SQL"
            echo "  restore <arquivo> [banco]  Restaura um backup"
            echo "  shell             Abre o MariaDB"
            echo ""
            ;;

        *)
            echo "Comando de banco desconhecido: ${action}"
            echo ""
            command_db help
            exit 1
            ;;
    esac
}