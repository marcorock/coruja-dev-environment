#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(
    cd -P "$(dirname "${BASH_SOURCE[0]}")" &&
    pwd
)"

source "${ROOT_DIR}/installer/core/common.sh"
source "${ROOT_DIR}/installer/core/output.sh"
source "${ROOT_DIR}/installer/core/system.sh"

source "${ROOT_DIR}/installer/checks/dependencies.sh"
source "${ROOT_DIR}/installer/checks/validation.sh"

source "${ROOT_DIR}/installer/setup/directories.sh"
source "${ROOT_DIR}/installer/setup/environment.sh"

source "${ROOT_DIR}/installer/actions/install_cli.sh"

main() {
    show_banner

    detect_system

    check_dependencies

    create_directories

    generate_environment_file

    validate_environment

    install_cli

    echo
    echo "Instalador inicializado com sucesso."
}

main "$@"