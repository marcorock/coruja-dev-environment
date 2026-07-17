#!/usr/bin/env bash

command_up() {
    require_docker
    docker compose up -d
}

command_down() {
    require_docker
    docker compose down
}

command_restart() {
    require_docker
    docker compose restart
}

command_build() {
    require_docker
    docker compose up -d --build
}

command_status() {
    require_docker
    docker compose ps
}

command_logs() {
    require_docker

    local service="${1:-}"

    if [[ -n "$service" ]]; then
        docker compose logs -f "$service"
    else
        docker compose logs -f
    fi
}

command_shell() {
    require_docker
    docker compose exec --user developer web zsh
}