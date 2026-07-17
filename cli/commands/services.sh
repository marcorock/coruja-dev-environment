#!/usr/bin/env bash

command_service_status() {
    require_docker
    docker compose ps
}

command_service_restart() {
    require_docker

    local service="${1:-}"

    if [[ -z "$service" ]]; then
        echo "Informe o serviço."
        echo ""
        echo "Exemplo:"
        echo "  coruja service restart redis"
        exit 1
    fi

    docker compose restart "$service"
}

command_service_logs() {
    require_docker

    local service="${1:-}"

    if [[ -z "$service" ]]; then
        echo "Informe o serviço."
        echo ""
        echo "Exemplo:"
        echo "  coruja service logs redis"
        exit 1
    fi

    docker compose logs -f "$service"
}

command_service() {
    local action="${1:-help}"
    local service="${2:-}"

    case "$action" in
        status)
            command_service_status
            ;;

        restart)
            command_service_restart "$service"
            ;;

        logs)
            command_service_logs "$service"
            ;;

        help|-h|--help)
            echo ""
            echo "Uso:"
            echo "  coruja service <comando> [serviço]"
            echo ""
            echo "Comandos:"
            echo "  status                  Lista os serviços"
            echo "  restart <serviço>       Reinicia um serviço"
            echo "  logs <serviço>          Exibe os logs"
            echo ""
            ;;

        *)
            echo "Comando de serviço desconhecido: ${action}"
            command_service help
            exit 1
            ;;
    esac
}