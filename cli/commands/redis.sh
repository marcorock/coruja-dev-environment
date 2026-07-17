#!/usr/bin/env bash

command_redis_ping() {
    require_docker

    docker compose exec -T redis redis-cli ping
}

command_redis_shell() {
    require_docker

    docker compose exec redis redis-cli
}

command_redis_info() {
    require_docker

    docker compose exec -T redis redis-cli info server
}

command_redis_flush() {
    require_docker

    read -r -p "Deseja realmente apagar todos os dados do Redis? [s/N] " confirmation

    if [[ ! "$confirmation" =~ ^[sS]$ ]]; then
        echo "Operação cancelada."
        return
    fi

    docker compose exec -T redis redis-cli FLUSHALL

    echo "Dados do Redis removidos."
}

command_redis() {
    local action="${1:-help}"

    case "$action" in
        ping)
            command_redis_ping
            ;;

        shell)
            command_redis_shell
            ;;

        info)
            command_redis_info
            ;;

        flush)
            command_redis_flush
            ;;

        help|-h|--help)
            echo ""
            echo "Uso:"
            echo "  coruja redis <comando>"
            echo ""
            echo "Comandos:"
            echo "  ping       Testa a conexão"
            echo "  shell      Abre o redis-cli"
            echo "  info       Mostra informações"
            echo "  flush      Apaga todos os dados"
            echo ""
            ;;

        *)
            echo "Comando Redis desconhecido: ${action}"
            command_redis help
            exit 1
            ;;
    esac
}