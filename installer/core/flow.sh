#!/usr/bin/env bash

prepare_installation() {

    detect_system

    check_dependencies

    create_directories

    generate_environment_file

    validate_environment

}

execute_installation() {

    install_cli

}

finish_installation() {

    output_step "Instalação concluída"

    output_success "Coruja Dev Environment preparado."

}