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

    run_initial_diagnostic

    start_environment

    run_post_start_diagnostic

}

finish_installation() {

    output_step "Instalação concluída"

    output_success "Coruja Dev Environment preparado."

}