#!/usr/bin/env bash

prepare_installation() {

    detect_system

    check_dependencies

    create_directories

    generate_environment_file

    prepare_local_certificates

    validate_environment

}

execute_installation() {
    install_cli

    run_initial_diagnostic

    if [[ "$INSTALLER_SSL_READY" != true ]]; then
        output_warning "O ambiente não será iniciado sem os certificados HTTPS"
        output_info "Instale o mkcert e execute novamente './install.sh'"
        return 0
    fi

    start_environment

    run_post_start_diagnostic
}

finish_installation() {

    show_installation_summary

    show_getting_started

}